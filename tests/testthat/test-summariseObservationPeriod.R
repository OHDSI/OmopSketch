test_that("check summariseObservationPeriod works", {
  skip_on_cran()

  nPoints <- 512

  # Load mock database
  cdm <- omopgenerics::cdmFromTables(
    tables = list(
      person = dplyr::tibble(
        person_id = as.integer(1:4),
        gender_concept_id = c(8507L, 8532L, 8532L, 8507L),
        year_of_birth = 2010L,
        month_of_birth = 1L,
        day_of_birth = 1L,
        race_concept_id = 0L,
        ethnicity_concept_id = 0L
      ),
      observation_period = dplyr::tibble(
        observation_period_id = as.integer(1:8),
        person_id = c(1, 1, 1, 2, 2, 3, 3, 4) |> as.integer(),
        observation_period_start_date = as.Date(c(
          "2020-03-01", "2020-03-25", "2020-04-25", "2020-08-10", "2020-03-10",
          "2020-03-01", "2020-04-10", "2020-03-10"
        )),
        observation_period_end_date = as.Date(c(
          "2020-03-20", "2020-03-30", "2020-08-15", "2020-12-31", "2020-03-27",
          "2020-03-09", "2020-05-08", "2020-12-10"
        )),
        period_type_concept_id = 0L
      )
    ),
    cdmName = "mock data"
  ) |>
    copyCdm()

  # simple run
  expect_no_error(resAll <- summariseObservationPeriod(cdm$observation_period))
  expect_no_error(
    resAllD <- summariseObservationPeriod(cdm$observation_period, estimates = "density")
  )
  expect_no_error(
    resAllN <- summariseObservationPeriod(cdm$observation_period,
      estimates = c(
        "mean", "sd", "min", "q05", "q25",
        "median", "q75", "q95", "max"
      )
    )
  )
  expect_equal(
    resAllD |> dplyr::filter(!is.na(variable_level)) |>
      dplyr::mutate(estimate_value = as.numeric(estimate_value)),
    resAll |> dplyr::filter(!is.na(variable_level)) |>
      dplyr::mutate(estimate_value = as.numeric(estimate_value)),
    ignore_attr = TRUE
  )

  # test estimates
  expect_no_error(
    resEst <- cdm$observation_period |>
      summariseObservationPeriod(estimates = c("mean", "median"), quality = FALSE, missing = FALSE)
  )
  expect_true(all(
    resEst |>
      dplyr::filter(!.data$variable_name %in% c("Number records", "Number subjects", "Type concept id")) |>
      dplyr::pull("estimate_name") |>
      unique() %in% c("mean", "median")
  ))

  # counts
  expect_identical(resAll$estimate_value[resAll$variable_name == "Number records"], "8")
  x <- dplyr::tibble(
    group_level = c("all", "1st", "2nd", "3rd"),
    variable_name = "Number subjects",
    estimate_value = c("4", "4", "3", "1")
  )
  expect_identical(nrow(x), resAll |> dplyr::inner_join(x, by = colnames(x)) |> nrow())

  # records per person
  expect_identical(
    resAll |>
      dplyr::filter(
        variable_name == "Records per person", estimate_name == "mean"
      ) |>
      dplyr::pull("estimate_value"),
    "2"
  )

  # duration
  expect_identical(
    resAll |>
      dplyr::filter(variable_name == "Duration in days", estimate_name == "mean") |>
      dplyr::pull("estimate_value"),
    as.character(c(
      mean(c(20, 6, 113, 144, 18, 9, 29, 276)),
      mean(c(20, 18, 9, 276)),
      mean(c(6, 29, 144)), 113
    ))
  )

  # days to next observation period
  expect_identical(
    resAll |>
      dplyr::filter(variable_name == "Days to next observation period", estimate_name == "mean") |>
      dplyr::pull("estimate_value"),
    as.character(c(
      mean(c(5, 32, 136, 26)),
      mean(c(5, 32, 136)), 26, NA
    ))
  )

  # duration - density
  xx <- resAllD |>
    dplyr::filter(variable_name == "Duration in days", !is.na(variable_level)) |>
    dplyr::group_by(group_level) |>
    dplyr::summarise(
      n = dplyr::n(),
      area = sum(as.numeric(estimate_value[estimate_name == "density_y"])) * (
        max(as.numeric(estimate_value[estimate_name == "density_x"])) -
          min(as.numeric(estimate_value[estimate_name == "density_x"]))
      ) / (nPoints - 1)
    )
  expect_identical(xx$n |> unique() |> sort(decreasing = TRUE), c(as.integer(nPoints * 2L), 6L))
  expect_identical(xx$area |> round(2) |> unique() |> sort(decreasing = TRUE), c(1, 0))

  # days to next observation period - density
  xx <- resAll |>
    dplyr::filter(
      variable_name == "Days to next observation period",
      !is.na(variable_level)
    ) |>
    dplyr::group_by(group_level) |>
    dplyr::summarise(
      n = dplyr::n(),
      area = sum(as.numeric(estimate_value[estimate_name == "density_y"])) * (
        max(as.numeric(estimate_value[estimate_name == "density_x"])) -
          min(as.numeric(estimate_value[estimate_name == "density_x"]))
      ) / (nPoints - 1)
    )
  expect_identical(xx$n |> unique() |> sort(decreasing = TRUE), c(as.integer(nPoints * 2L), 6L))
  expect_identical(xx$area[xx$group_level != "2nd"] |> round(2) |> unique(), 1)

  # only one exposure per individual
  cdm$observation_period <- cdm$observation_period |>
    dplyr::group_by(person_id) |>
    dplyr::filter(observation_period_id == min(observation_period_id, na.rm = TRUE)) |>
    dplyr::ungroup() |>
    dplyr::compute(name = "observation_period", temporary = FALSE)

  expect_no_error(resOne <- summariseObservationPeriod(cdm$observation_period))

  # counts
  expect_identical(resOne$estimate_value[resOne$variable_name == "Number records"], "4")
  x <- dplyr::tibble(
    group_level = c("all", "1st"),
    variable_name = "Number subjects",
    estimate_value = c("4", "4")
  )
  expect_identical(nrow(x), resOne |> dplyr::inner_join(x, by = colnames(x)) |> nrow())

  # Check result type
  checkResultType(resOne, "summarise_observation_period")

  # empty observation period
  cdm$observation_period <- cdm$observation_period |>
    dplyr::filter(person_id == 0) |>
    dplyr::compute(name = "observation_period", temporary = FALSE)

  expect_no_error(resEmpty <- summariseObservationPeriod(cdm$observation_period))
  expect_true(nrow(resEmpty) == 0)

  # table works
  expect_no_error(tableObservationPeriod(resAll))
  expect_no_error(tableObservationPeriod(resAll, type = "datatable"))
  expect_no_error(tableObservationPeriod(resOne))
  expect_warning(tableObservationPeriod(resEmpty))
  expect_no_error(tableMissingData(resAll))
  # plot works
  expect_no_error(plotObservationPeriod(resAll))
  expect_no_error(plotObservationPeriod(resOne))
  # expect_warning(plotObservationPeriod(resEmpty)) THIS TEST NEEDS DISCUSSION

  # check all plots combinations
  expect_no_error(
    resAll |>
      plotObservationPeriod(
        variableName = "Number subjects", plotType = "barplot"
      )
  )
  expect_error(
    resAll |>
      plotObservationPeriod(
        variableName = "Number subjects", plotType = "boxplot"
      )
  )
  expect_error(
    resAll |>
      plotObservationPeriod(
        variableName = "Number subjects", plotType = "densityplot"
      )
  )
  expect_error(
    resAll |>
      plotObservationPeriod(
        variableName = "Number subjects", plotType = "random"
      )
  )
  expect_error(
    resAll |>
      plotObservationPeriod(
        variableName = "Duration in days", plotType = "barplot"
      )
  )
  expect_no_error(
    resAll |>
      plotObservationPeriod(
        variableName = "Duration in days", plotType = "boxplot"
      )
  )
  expect_error(
    resAllN |>
      plotObservationPeriod(
        variableName = "Duration in days", plotType = "densityplot"
      )
  )
  expect_no_error(
    resAllD |>
      plotObservationPeriod(
        variableName = "Duration in days", plotType = "densityplot"
      )
  )
  expect_error(
    resAll |>
      plotObservationPeriod(
        variableName = "Duration in days", plotType = "random"
      )
  )
  expect_error(
    resAll |>
      plotObservationPeriod(
        variableName = "Records per person", plotType = "barplot"
      )
  )
  expect_no_error(
    resAll |>
      plotObservationPeriod(
        variableName = "Records per person", plotType = "boxplot"
      )
  )
  expect_error(
    resAllN |>
      plotObservationPeriod(
        variableName = "Records per person", plotType = "densityplot"
      )
  )
  expect_no_error(
    resAllD |>
      plotObservationPeriod(
        variableName = "Records per person", plotType = "densityplot"
      )
  )
  expect_error(
    resAll |>
      plotObservationPeriod(
        variableName = "Records per person", plotType = "random"
      )
  )
  expect_error(
    resAll |>
      plotObservationPeriod(
        variableName = "Days to next observation period", plotType = "barplot"
      )
  )
  expect_no_error(
    resAll |>
      plotObservationPeriod(
        variableName = "Days to next observation period", plotType = "boxplot"
      )
  )
  expect_error(
    resAllN |>
      plotObservationPeriod(
        variableName = "Days to next observation period", plotType = "densityplot"
      )
  )
  expect_no_error(
    resAllD |>
      plotObservationPeriod(
        variableName = "Days to next observation period", plotType = "densityplot"
      )
  )
  expect_error(
    resAll |>
      plotObservationPeriod(
        variableName = "Days to next observation period", plotType = "random"
      )
  )

  dropCreatedTables(cdm = cdm)
})

test_that("check summariseObservationPeriod strata works", {
  skip_on_cran()
  # helper function

  nPoints <- 512

  # Load mock database
  cdm <- omopgenerics::cdmFromTables(
    tables = list(
      person = dplyr::tibble(
        person_id = as.integer(1:4),
        gender_concept_id = c(8507L, 8532L, 8532L, 8507L),
        year_of_birth = c(2010L, 2010L, 2011L, 2012L),
        month_of_birth = 1L,
        day_of_birth = 1L,
        race_concept_id = 0L,
        ethnicity_concept_id = 0L
      ),
      observation_period = dplyr::tibble(
        observation_period_id = as.integer(1:8),
        person_id = c(1, 1, 1, 2, 2, 3, 3, 4) |> as.integer(),
        observation_period_start_date = as.Date(c(
          "2020-03-01", "2020-03-25", "2020-04-25", "2020-08-10", "2020-03-10",
          "2020-03-01", "2020-04-10", "2020-03-10"
        )),
        observation_period_end_date = as.Date(c(
          "2020-03-20", "2020-03-30", "2020-08-15", "2020-12-31", "2020-03-27",
          "2020-03-09", "2020-05-08", "2020-12-10"
        )),
        period_type_concept_id = 0L
      )
    ),
    cdmName = "mock data"
  ) |>
    copyCdm()

  # simple run
  expect_no_error(summariseObservationPeriod(cdm$observation_period,
    estimates = c("mean"),
    ageGroup = list(c(0, 9), c(10, Inf))
  ))

  expect_no_error(resAll <- summariseObservationPeriod(cdm$observation_period,
    estimates = c("mean", "sd", "min", "max", "median", "density")
  ))
  expect_no_error(resStrata <- summariseObservationPeriod(cdm$observation_period,
    estimates = c("mean", "sd", "min", "max", "median", "density"),
    ageGroup = list("<10" = c(0, 9), ">=10" = c(10, Inf)),
    sex = TRUE,
    quality = FALSE,
    missingData = FALSE
  ))
  expect_equal(
    resStrata |> dplyr::filter(group_level == "all" & strata_level == "overall") |> dplyr::distinct(variable_name),
    resStrata |> dplyr::filter(group_level == "all" & strata_level != "overall") |> dplyr::distinct(variable_name)
  )

  # test overall
  x <- resStrata |>
    dplyr::filter(strata_name == "overall", strata_level == "overall") |>
    dplyr::rename("strata" = "estimate_value") |>
    dplyr::inner_join(
      resAll |>
        dplyr::rename("all" = "estimate_value")
    )
  expect_identical(x$strata, x$all)

  # check strata groups have the expected value
  expect_identical(resStrata |>
    dplyr::filter(
      variable_name == "Number subjects",
      strata_level == "Female",
      group_level == "2nd"
    ) |>
    dplyr::pull("estimate_value"), "2")

  expect_identical(resStrata |>
    omopgenerics::splitStrata() |>
    dplyr::filter(
      variable_name == "Number subjects",
      sex == "Male",
      age_group == ">=10",
      group_level == "3rd"
    ) |>
    dplyr::pull("estimate_value"), "1")

  # duration
  expect_identical(
    resStrata |>
      dplyr::filter(variable_name == "Duration in days", estimate_name == "mean", strata_level == ">=10") |>
      dplyr::pull("estimate_value"),
    as.character(c(
      mean(c(20, 18, 6, 144, 113)),
      mean(c(20, 18)),
      mean(c(6, 144)),
      mean(113)
    ))
  )

  expect_identical(
    resStrata |>
      dplyr::filter(variable_name == "Duration in days", estimate_name == "mean", strata_level == "<10") |>
      dplyr::pull("estimate_value"),
    as.character(c(
      mean(c(9, 276, 29)),
      mean(c(9, 276)),
      mean(c(29))
    ))
  )

  # days to next observation period
  expect_identical(
    resStrata |>
      omopgenerics::splitStrata() |>
      dplyr::filter(
        variable_name == "Days to next observation period", estimate_name == "mean",
        sex == "Female", age_group == "<10", group_level == "1st"
      ) |>
      dplyr::pull("estimate_value"), "32"
  )

  expect_no_error(x <- summariseObservationPeriod(cdm$observation_period, estimates = "density", sex = TRUE, ageGroup = list(c(0, 9), c(10, Inf))))
  expect_no_error(
    x |>
      plotObservationPeriod(
        variableName = "Duration in days", plotType = "densityplot", colour = "sex", facet = "age_group"
      )
  )

  expect_no_error(
    x |>
      plotObservationPeriod(
        variableName = "Days to next observation period", plotType = "densityplot", colour = "sex", facet = "age_group"
      )
  )
  expect_no_error(
    x |>
      plotObservationPeriod(
        variableName = "Records per person", plotType = "densityplot", colour = "sex", facet = "age_group"
      )
  )

  expect_error(x |>
    plotObservationPeriod(
      variableName = "Number records", plotType = "densityplot", colour = "sex", facet = "age_group"
    ))
  y <- summariseObservationPeriod(cdm$observation_period, estimates = "mean", sex = TRUE, ageGroup = list(c(0, 9), c(10, Inf)))
  expect_error(
    y |>
      plotObservationPeriod(
        variableName = "Records per person", plotType = "densityplot", colour = "sex", facet = "age_group"
      )
  )

  dropCreatedTables(cdm = cdm)
})

test_that("dateRnge argument works", {
  skip_on_cran()
  # Load mock database ----
  cdm <- cdmEunomia()

  expect_no_error(summariseObservationPeriod(cdm$observation_period, dateRange = as.Date(c("1940-01-01", "2018-01-01"))))
  expect_message(x <- summariseObservationPeriod(cdm$observation_period, dateRange = as.Date(c("1940-01-01", "2024-01-01")), estimates = "min"))
  observationRange <- cdm$observation_period |>
    dplyr::summarise(
      minobs = min(.data$observation_period_start_date, na.rm = TRUE),
      maxobs = max(.data$observation_period_end_date, na.rm = TRUE)
    )
  expect_no_error(y <- summariseObservationPeriod(cdm$observation_period, dateRange = as.Date(c("1940-01-01", observationRange |> dplyr::pull("maxobs"))), estimates = "min"))
  expect_equal(x, y, ignore_attr = TRUE)
  expect_false(settings(x)$study_period_end == settings(y)$study_period_end)
  expect_error(summariseObservationPeriod(cdm$observation_period, dateRange = as.Date(c("2015-01-01", "2014-01-01"))))
  expect_warning(z <- summariseObservationPeriod(cdm$observation_period, dateRange = as.Date(c("2020-01-01", "2021-01-01"))))
  expect_equal(z, omopgenerics::emptySummarisedResult(), ignore_attr = TRUE)
  expect_equal(summariseObservationPeriod(cdm$observation_period, dateRange = as.Date(c("1940-01-01", NA)), estimates = "min"), y, ignore_attr = TRUE)
  checkResultType(z, "summarise_observation_period")
  expect_equal(colnames(settings(z)), colnames(settings(x)))

  ageGroup <- lapply(split(0:99, (0:99) %/% 2), c)
  expect_no_error(result <- summariseObservationPeriod(cdm$observation_period, ageGroup = ageGroup, dateRange = as.Date(c("2015-01-01", "2018-01-01"))))
  x <- result |>
    omopgenerics::splitStrata() |>
    dplyr::filter(age_group == "overall", variable_name == "Number records") |>
    dplyr::pull(estimate_value) |>
    as.numeric()
  y <- cdm$observation_period |>
    dplyr::filter(.data$observation_period_end_date >= as.Date("2015-01-01") & .data$observation_period_start_date <= as.Date("2018-01-01")) |>
    dplyr::tally() |>
    dplyr::pull("n") |>
    as.numeric()
  expect_equal(x, y)

  dropCreatedTables(cdm = cdm)
})

test_that("no tables created", {
  skip_on_cran()
  # Load mock database ----
  cdm <- cdmEunomia()

  startNames <- omopgenerics::listSourceTables(cdm)

  results <- summariseObservationPeriod(cdm$observation_period,
    sex = TRUE,
    ageGroup = list(
      c(0, 17),
      c(18, 65),
      c(66, 100)
    ),
    dateRange = as.Date(c("2012-01-01", "2018-01-01"))
  )

  endNames <- omopgenerics::listSourceTables(cdm)

  expect_true(length(setdiff(endNames, startNames)) == 0)

  dropCreatedTables(cdm = cdm)
})

test_that("missingData works", {
  skip_on_cran()
  # Load mock database ----
  cdm <- cdmEunomia()

  expect_no_error(x <- summariseObservationPeriod(cdm = cdm))
  expect_true(all(c("na_count", "na_percentage", "zero_count", "zero_percentage") %in% unique(x$estimate_name)))
  x <- x |>
    dplyr::filter(.data$group_level != "all")
  expect_true(!(any(c("na_count", "na_percentage", "zero_count", "zero_percentage") %in% unique(x$estimate_name))))

  expect_no_error(x <- summariseObservationPeriod(cdm, quality = F))

  y <- summariseMissingData(cdm, "observation_period")

  expect_equal(x |> dplyr::filter(variable_name == "Column name") |> dplyr::select(!c("group_name", "group_level")), y |> dplyr::select(!c("group_name", "group_level")), ignore_attr = TRUE)

  expect_no_error(x <- summariseObservationPeriod(cdm, sex = T, ageGroup = list(c(0, 50), c(51, 100)), quality = F))
  y <- summariseMissingData(cdm, "observation_period", sex = T, ageGroup = list(c(0, 50), c(51, 100)))

  expect_equal(x |> dplyr::filter(variable_name == "Column name") |> dplyr::arrange(.data$variable_level, .data$strata_name, .data$strata_level) |> dplyr::select(!c("group_name", "group_level")), y |> dplyr::arrange(.data$variable_level, .data$strata_name, .data$strata_level) |> dplyr::select(!c("group_name", "group_level")), ignore_attr = TRUE)

  dropCreatedTables(cdm = cdm)
})

test_that("quality works", {
  skip_on_cran()
  # Load mock database ----
  cdm <- cdmEunomia()

  expect_no_error(x <- summariseObservationPeriod(cdm, missingData = F, estimates = "mean"))
  expect_true(all(c("Subjects not in person table", "End date before start date", "Start date before birth date") %in% unique(x$variable_name)))
  x <- x |>
    dplyr::filter(.data$group_level != "all")
  expect_false(any(c("Subjects not in person table", "End date before start date", "Start date before birth date") %in% unique(x$variable_name)))

  expect_no_error(x <- summariseObservationPeriod(cdm, sex = T, ageGroup = list(c(0, 50))))
  x <- x |>
    dplyr::filter(.data$strata_level != "overall")
  expect_false("Subjects not in person table" %in% unique(x$variable_name))

  person_id <- cdm$observation_period |>
    head(1) |>
    dplyr::pull(.data$person_id)
  cdm$person <- cdm$person |> dplyr::filter(.data$person_id != .env$person_id)
  expect_warning(y <- summariseObservationPeriod(cdm))
  n_subjects <- cdm$observation_period |> omopgenerics::numberSubjects()
  expect_equal(y |> dplyr::filter(.data$variable_name == "Subjects not in person table" & .data$estimate_name == "count") |> dplyr::pull(.data$estimate_value), "1")
  expect_equal(y |> dplyr::filter(.data$variable_name == "Subjects not in person table" & .data$estimate_name == "percentage") |> dplyr::pull(.data$estimate_value), sprintf("%.2f", 100 * 1 / n_subjects))

  ids <- cdm$observation_period |>
    dplyr::distinct(observation_period_id) |>
    dplyr::pull()
  set.seed(123)
  shuffled <- sample(ids)
  vec1 <- shuffled[1:10]
  vec2 <- shuffled[11:20]
  cdm$observation_period <- cdm$observation_period |>
    dplyr::mutate(observation_period_start_date = dplyr::if_else(.data$observation_period_id %in% vec1,
      as.Date("3000-01-01"),
      dplyr::if_else(.data$observation_period_id %in% vec2,
        as.Date("1900-01-01"),
        .data$observation_period_start_date
      )
    ))

  x <- summariseObservationPeriod(cdm, missingData = F)
  y <- cdm$observation_period |>
    dplyr::filter(.data$observation_period_end_date < .data$observation_period_start_date)
  z <- cdm$observation_period |>
    dplyr::inner_join(cdm$person |> dplyr::select(person_id, birth_datetime), by = "person_id") |>
    dplyr::filter(.data$observation_period_start_date < as.Date(.data$birth_datetime))

  expect_equal(
    y |> dplyr::tally() |> dplyr::pull("n") |> as.numeric(),
    x |> dplyr::filter(variable_name == "End date before start date", estimate_name == "count") |> dplyr::pull(estimate_value) |> as.numeric()
  )

  expect_equal(
    z |> dplyr::tally() |> dplyr::pull("n") |> as.numeric(),
    x |> dplyr::filter(variable_name == "Start date before birth date", estimate_name == "count") |> dplyr::pull(estimate_value) |> as.numeric()
  )

  expect_no_error(x <- summariseObservationPeriod(cdm, missingData = F, sex = TRUE))
  x <- x |> omopgenerics::splitStrata()

  expect_equal(
    y |>
      PatientProfiles::addSexQuery() |>
      dplyr::filter(sex == "Female") |>
      dplyr::tally() |>
      dplyr::pull("n") |>
      as.numeric(),
    x |>
      dplyr::filter(sex == "Female" & variable_name == "End date before start date" & estimate_name == "count") |>
      dplyr::pull(estimate_value) |>
      as.numeric()
  )

  expect_equal(
    z |>
      PatientProfiles::addSexQuery() |>
      dplyr::filter(sex == "Female") |>
      dplyr::tally() |>
      dplyr::pull("n") |>
      as.numeric(),
    x |>
      dplyr::filter(sex == "Female" & variable_name == "Start date before birth date" & estimate_name == "count") |>
      dplyr::pull(estimate_value) |>
      as.numeric()
  )

  dropCreatedTables(cdm = cdm)
})
