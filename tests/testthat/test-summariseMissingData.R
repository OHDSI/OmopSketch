test_that("summariseMissingData() works", {
  skip_on_cran()
  # Load mock database ----
  cdm <- cdmEunomia()


  # Check all tables work ----
  expect_true(inherits(summariseMissingData(cdm, "drug_exposure"), "summarised_result"))
  expect_no_error(y <- summariseMissingData(cdm, "observation_period"))
  checkResultType(y, "summarise_missing_data")
  expect_no_error(x <- summariseMissingData(cdm, "visit_occurrence"))
  expect_no_error(summariseMissingData(cdm, "condition_occurrence"))
  expect_no_error(summariseMissingData(cdm, "drug_exposure"))

  expect_no_error(summariseMissingData(cdm, "procedure_occurrence", interval = "years"))
  expect_warning(summariseMissingData(cdm, "device_exposure"))
  expect_no_error(z <- summariseMissingData(cdm, "measurement"))
  expect_no_error(s <- summariseMissingData(cdm, "observation"))

  expect_warning(de <- summariseMissingData(cdm, "death"))
  checkResultType(de, "summarise_missing_data")
  expect_warning(p <- summariseMissingData(cdm, "person", ageGroup = list(c(0, 50))))
  expect_true(omopgenerics::settings(p)$strata == "")

  expect_no_error(all <- summariseMissingData(cdm, c("observation_period", "visit_occurrence", "measurement")))
  expect_equal(all, dplyr::bind_rows(y, x, z))
  expect_equal(summariseMissingData(cdm, "observation"), summariseMissingData(cdm, "observation", col = colnames(cdm[["observation"]])))
  x <- summariseMissingData(cdm, "procedure_occurrence", col = "procedure_date")

  expect_equal(summariseMissingData(cdm, c("procedure_occurrence", "observation"), col = "procedure_date"), dplyr::bind_rows(x, s))
  y <- summariseMissingData(cdm, "observation", col = "observation_date")
  expect_equal(summariseMissingData(cdm, c("procedure_occurrence", "observation"), col = c("procedure_date", "observation_date")), dplyr::bind_rows(x, y))

  # Check inputs ----
  expect_true(summariseMissingData(cdm, "procedure_occurrence", col = "person_id") |>
    dplyr::select(estimate_value) |>
    dplyr::mutate(estimate_value = as.numeric(estimate_value)) |>
    dplyr::summarise(sum = sum(estimate_value)) |>
    dplyr::pull() == 0)

  expect_true(summariseMissingData(cdm, "procedure_occurrence", col = "person_id", sex = TRUE, ageGroup = list(c(0, 50), c(51, Inf))) |>
    dplyr::distinct(.data$strata_level) |>
    dplyr::tally() |>
    dplyr::pull() == 9)

  expect_true(summariseMissingData(cdm, "procedure_occurrence", col = "person_id", ageGroup = list(c(0, 50))) |>
    dplyr::distinct(.data$strata_level) |>
    dplyr::tally() |>
    dplyr::pull() == 3)

  cdm$procedure_occurrence <- cdm$procedure_occurrence |>
    dplyr::mutate(procedure_concept_id = NA_integer_) |>
    dplyr::compute(name = "procedure_occurrence", temporary = FALSE)

  expect_warning(summariseMissingData(cdm, "procedure_occurrence", col = "procedure_concept_id", ageGroup = list(c(0, 50))))
  expect_warning(summariseMissingData(cdm, "procedure_occurrence", col = "procedure_concept_id", ageGroup = list(c(0, 50)), sample = 100))
})

test_that("dateRange argument works", {
  skip_on_cran()
  # Load mock database ----
  cdm <- cdmEunomia()

  expect_no_error(summariseMissingData(cdm, "condition_occurrence", dateRange = as.Date(c("2012-01-01", "2018-01-01"))))
  expect_message(x <- summariseMissingData(cdm, "drug_exposure", dateRange = as.Date(c("2012-01-01", "2025-01-01"))))
  observationRange <- cdm$observation_period |>
    dplyr::summarise(
      minobs = min(.data$observation_period_start_date, na.rm = TRUE),
      maxobs = max(.data$observation_period_end_date, na.rm = TRUE)
    )
  expect_no_error(y <- summariseMissingData(cdm, "drug_exposure", dateRange = as.Date(c("2012-01-01", observationRange |> dplyr::pull("maxobs")))))
  expect_equal(x, y, ignore_attr = TRUE)
  expect_false(settings(x)$study_period_end == settings(y)$study_period_end)
  expect_error(summariseMissingData(cdm, "drug_exposure", dateRange = as.Date(c("2015-01-01", "2014-01-01"))))
  expect_warning(z <- summariseMissingData(cdm, "drug_exposure", dateRange = as.Date(c("2020-01-01", "2021-01-01"))))
  expect_equal(z, omopgenerics::emptySummarisedResult(), ignore_attr = TRUE)
  expect_equal(summariseMissingData(cdm, "drug_exposure", dateRange = as.Date(c("2012-01-01", NA))), y, ignore_attr = TRUE)
  checkResultType(z, "summarise_missing_data")
  expect_equal(colnames(settings(z)), colnames(settings(x)))
  PatientProfiles::mockDisconnect(cdm = cdm)
})

test_that("tableMissingData() works", {
  skip_on_cran()
  # Load mock database ----
  cdm <- cdmEunomia()

  # Check that works ----
  expect_no_error(x <- tableMissingData(summariseMissingData(cdm, "condition_occurrence")))
  expect_true(inherits(x, "gt_tbl"))
  expect_no_error(y <- tableMissingData(summariseMissingData(cdm, c(
    "observation_period",
    "measurement"
  ))))
  expect_true(inherits(y, "gt_tbl"))
  expect_warning(t <- summariseMissingData(cdm, "death"))
  expect_warning(inherits(tableMissingData(t), "gt_tbl"))

  PatientProfiles::mockDisconnect(cdm = cdm)
})

test_that("col not present in table", {
  skip_on_cran()
  # Load mock database ----
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
  )
  cdm <- CDMConnector::copyCdmTo(
    con = connection(), cdm = cdm, schema = schema()
  )

  expect_no_error(expect_message(summariseMissingData(cdm, "person", col = NULL)))

  PatientProfiles::mockDisconnect(cdm = cdm)
})

test_that("no tables created", {
  skip_on_cran()
  # Load mock database ----
  cdm <- cdmEunomia()

  startNames <- CDMConnector::listSourceTables(cdm)

  results <- summariseMissingData(
    cdm = cdm,
    omopTableName = c("drug_exposure", "condition_occurrence"),
    interval = "years",
    sex = TRUE,
    ageGroup = list(
      c(0, 17),
      c(18, 65),
      c(66, 100)
    ),
    dateRange = as.Date(c("2012-01-01", "2018-01-01")),
    sample = 100
  )

  endNames <- CDMConnector::listSourceTables(cdm)

  expect_true(length(setdiff(endNames, startNames)) == 0)


  PatientProfiles::mockDisconnect(cdm = cdm)
})

test_that("interval argument works", {
  skip_on_cran()
  # Load mock database ----
  cdm <- cdmEunomia()
  expect_no_error(y <- summariseMissingData(
    cdm = cdm,
    omopTableName = "drug_exposure",
    interval = "years"
  ))

  expect_no_error(o <- summariseMissingData(
    omopTableName = "drug_exposure",
    cdm = cdm,
    interval = "overall"
  ))
  expect_no_error(q <- summariseMissingData(
    omopTableName = "drug_exposure",
    cdm = cdm,
    interval = "quarters"
  ))
  expect_no_error(m <- summariseMissingData(
    omopTableName = "drug_exposure",
    cdm = cdm,
    interval = "months"
  ))



  m_quarters <- m |>
    omopgenerics::splitAdditional() |>
    omopgenerics::pivotEstimates() |>
    dplyr::filter(time_interval != "overall") |>
    dplyr::mutate(
      start_date = as.Date(sub(" to .*", "", time_interval)),
      quarter_start = lubridate::quarter(start_date, type = "date_first"),
      quarter_end = lubridate::quarter(start_date, type = "date_last"),
      quarter = paste(quarter_start, "to", quarter_end)
    ) |>
    dplyr::select(!c("time_interval", "start_date", "quarter_start", "quarter_end")) |>
    dplyr::group_by(quarter, variable_name) |>
    dplyr::summarise(na_count = sum(na_count), .groups = "drop") |>
    dplyr::rename("time_interval" = quarter) |>
    dplyr::arrange(time_interval)

  q_quarters <- q |>
    omopgenerics::splitAdditional() |>
    omopgenerics::pivotEstimates() |>
    dplyr::filter(time_interval != "overall") |>
    dplyr::select(time_interval, variable_name, na_count) |>
    dplyr::arrange(time_interval)

  expect_equal(m_quarters |>
    sortTibble(), q_quarters |> sortTibble())

  m_year <- m |>
    omopgenerics::splitAdditional() |>
    dplyr::filter(time_interval != "overall") |>
    dplyr::mutate(
      # Extract the start date
      start_date = clock::date_parse(stringr::str_extract(time_interval, "^\\d{4}-\\d{2}-\\d{2}")),
      # Convert start_date to a year-month-day object and extract the year
      year = clock::get_year(clock::as_year_month_day(start_date))
    ) |>
    omopgenerics::pivotEstimates() |>
    dplyr::group_by(year, variable_name) |>
    dplyr::summarise(
      na_count = sum(na_count),
      .groups = "drop"
    ) |>
    dplyr::arrange(year)
  y_year <- y |>
    omopgenerics::splitAdditional() |>
    dplyr::filter(time_interval != "overall") |>
    dplyr::mutate(
      # Extract the start date
      start_date = clock::date_parse(stringr::str_extract(time_interval, "^\\d{4}-\\d{2}-\\d{2}")),
      # Convert start_date to a year-month-day object and extract the year
      year = clock::get_year(clock::as_year_month_day(start_date))
    ) |>
    omopgenerics::pivotEstimates() |>
    dplyr::select(year, variable_name, na_count) |>
    dplyr::arrange(year)

  expect_equal(m_year |> sortTibble(), y_year |> sortTibble())

  o <- o |>
    omopgenerics::splitAdditional() |>
    omopgenerics::pivotEstimates() |>
    dplyr::select(variable_name, na_count)

  expect_equal(y_year |> dplyr::group_by(variable_name) |> dplyr::summarise(na_count = sum(na_count), .groups = "drop") |> sortTibble(), o |> sortTibble())


  q_year <- q |>
    omopgenerics::splitAdditional() |>
    dplyr::filter(time_interval != "overall") |>
    dplyr::mutate(
      # Extract the start date
      start_date = clock::date_parse(stringr::str_extract(time_interval, "^\\d{4}-\\d{2}-\\d{2}")),
      # Convert start_date to a year-month-day object and extract the year
      year = clock::get_year(clock::as_year_month_day(start_date))
    ) |>
    omopgenerics::pivotEstimates() |>
    dplyr::group_by(year, variable_name) |>
    dplyr::summarise(
      na_count = sum(na_count),
      .groups = "drop"
    ) |>
    dplyr::arrange(year)

  expect_equal(q_year |> sortTibble(), y_year |> sortTibble())

  expect_no_error(x <- summariseMissingData(cdm, "drug_exposure", sex = TRUE, interval = "years"))
  expect_true(x |> dplyr::distinct(.data$additional_level) |> dplyr::tally() > 1)
  PatientProfiles::mockDisconnect(cdm = cdm)
})

test_that("summariseMissingData() works", {
  skip_on_cran()
  # Load mock database ----
  cdm <- cdmEunomia()


  # Check all tables work ----
  expect_true(inherits(summariseMissingData(cdm, "drug_exposure"), "summarised_result"))
  expect_no_error(y <- summariseMissingData(cdm, "observation_period"))
  checkResultType(y, "summarise_missing_data")
  expect_no_error(x <- summariseMissingData(cdm, "visit_occurrence"))
  expect_no_error(summariseMissingData(cdm, "condition_occurrence"))
  expect_no_error(summariseMissingData(cdm, "drug_exposure"))

  expect_no_error(summariseMissingData(cdm, "procedure_occurrence", interval = "years"))
  expect_warning(summariseMissingData(cdm, "device_exposure"))
  expect_no_error(z <- summariseMissingData(cdm, "measurement"))
  expect_no_error(s <- summariseMissingData(cdm, "observation"))

  expect_warning(de <- summariseMissingData(cdm, "death"))
  checkResultType(de, "summarise_missing_data")
  expect_warning(p <- summariseMissingData(cdm, "person", ageGroup = list(c(0, 50))))
  expect_true(omopgenerics::settings(p)$strata == "")

  expect_no_error(all <- summariseMissingData(cdm, c("observation_period", "visit_occurrence", "measurement")))
  expect_equal(all, dplyr::bind_rows(y, x, z))
  expect_equal(summariseMissingData(cdm, "observation"), summariseMissingData(cdm, "observation", col = colnames(cdm[["observation"]])))
  x <- summariseMissingData(cdm, "procedure_occurrence", col = "procedure_date")

  expect_equal(summariseMissingData(cdm, c("procedure_occurrence", "observation"), col = "procedure_date"), dplyr::bind_rows(x, s))
  y <- summariseMissingData(cdm, "observation", col = "observation_date")
  expect_equal(summariseMissingData(cdm, c("procedure_occurrence", "observation"), col = c("procedure_date", "observation_date")), dplyr::bind_rows(x, y))

  # Check inputs ----
  expect_true(summariseMissingData(cdm, "procedure_occurrence", col = "person_id") |>
    dplyr::select(estimate_value) |>
    dplyr::mutate(estimate_value = as.numeric(estimate_value)) |>
    dplyr::summarise(sum = sum(estimate_value)) |>
    dplyr::pull() == 0)

  expect_true(summariseMissingData(cdm, "procedure_occurrence", col = "person_id", sex = TRUE, ageGroup = list(c(0, 50), c(51, Inf))) |>
    dplyr::distinct(.data$strata_level) |>
    dplyr::tally() |>
    dplyr::pull() == 9)

  expect_true(summariseMissingData(cdm, "procedure_occurrence", col = "person_id", ageGroup = list(c(0, 50))) |>
    dplyr::distinct(.data$strata_level) |>
    dplyr::tally() |>
    dplyr::pull() == 3)

  cdm$procedure_occurrence <- cdm$procedure_occurrence |>
    dplyr::mutate(procedure_concept_id = NA_integer_) |>
    dplyr::compute(name = "procedure_occurrence", temporary = FALSE)

  expect_warning(summariseMissingData(cdm, "procedure_occurrence", col = "procedure_concept_id", ageGroup = list(c(0, 50))))
  expect_warning(summariseMissingData(cdm, "procedure_occurrence", col = "procedure_concept_id", ageGroup = list(c(0, 50)), sample = 100))
})

test_that("dateRange argument works", {
  skip_on_cran()
  # Load mock database ----
  cdm <- cdmEunomia()

  expect_no_error(summariseMissingData(cdm, "condition_occurrence", dateRange = as.Date(c("2012-01-01", "2018-01-01"))))
  expect_message(x <- summariseMissingData(cdm, "drug_exposure", dateRange = as.Date(c("2012-01-01", "2025-01-01"))))
  observationRange <- cdm$observation_period |>
    dplyr::summarise(
      minobs = min(.data$observation_period_start_date, na.rm = TRUE),
      maxobs = max(.data$observation_period_end_date, na.rm = TRUE)
    )
  expect_no_error(y <- summariseMissingData(cdm, "drug_exposure", dateRange = as.Date(c("2012-01-01", observationRange |> dplyr::pull("maxobs")))))
  expect_equal(x, y, ignore_attr = TRUE)
  expect_false(settings(x)$study_period_end == settings(y)$study_period_end)
  expect_error(summariseMissingData(cdm, "drug_exposure", dateRange = as.Date(c("2015-01-01", "2014-01-01"))))
  expect_warning(z <- summariseMissingData(cdm, "drug_exposure", dateRange = as.Date(c("2020-01-01", "2021-01-01"))))
  expect_equal(z, omopgenerics::emptySummarisedResult(), ignore_attr = TRUE)
  expect_equal(summariseMissingData(cdm, "drug_exposure", dateRange = as.Date(c("2012-01-01", NA))), y, ignore_attr = TRUE)
  checkResultType(z, "summarise_missing_data")
  expect_equal(colnames(settings(z)), colnames(settings(x)))
  PatientProfiles::mockDisconnect(cdm = cdm)
})

test_that("tableMissingData() works", {
  skip_on_cran()
  # Load mock database ----
  cdm <- cdmEunomia()

  # Check that works ----
  expect_no_error(x <- tableMissingData(summariseMissingData(cdm, "condition_occurrence")))
  expect_true(inherits(x, "gt_tbl"))
  expect_no_error(y <- tableMissingData(summariseMissingData(cdm, c(
    "observation_period",
    "measurement"
  ))))
  expect_true(inherits(y, "gt_tbl"))
  expect_warning(t <- summariseMissingData(cdm, "death"))
  expect_warning(inherits(tableMissingData(t), "gt_tbl"))

  PatientProfiles::mockDisconnect(cdm = cdm)
})

test_that("col not present in table", {
  skip_on_cran()
  # Load mock database ----
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
  )
  cdm <- CDMConnector::copyCdmTo(
    con = connection(), cdm = cdm, schema = schema()
  )

  expect_no_error(expect_message(summariseMissingData(cdm, "person", col = NULL)))

  PatientProfiles::mockDisconnect(cdm = cdm)
})

test_that("no tables created", {
  skip_on_cran()
  # Load mock database ----
  cdm <- cdmEunomia()

  startNames <- CDMConnector::listSourceTables(cdm)

  results <- summariseMissingData(
    cdm = cdm,
    omopTableName = c("drug_exposure", "condition_occurrence"),
    interval = "years",
    sex = TRUE,
    ageGroup = list(
      c(0, 17),
      c(18, 65),
      c(66, 100)
    ),
    dateRange = as.Date(c("2012-01-01", "2018-01-01")),
    sample = 100
  )

  endNames <- CDMConnector::listSourceTables(cdm)

  expect_true(length(setdiff(endNames, startNames)) == 0)


  PatientProfiles::mockDisconnect(cdm = cdm)
})

test_that("zero count argument works", {
  skip_on_cran()
  # Load mock database ----
  cdm <- cdmEunomia()
  cdm$person <- cdm$person |>
    dplyr::mutate(person_id = dplyr::if_else(.data$person_id == 6, 0, .data$person_id))
  expect_equal(summariseMissingData(cdm, omopTableName = "person") |>
    dplyr::filter(variable_name == "person_id" & estimate_name == "zero_count") |>
    dplyr::pull(.data$estimate_value) |> as.integer(), 1L)


  columns <- cdm$drug_exposure |> colnames()
  columns_zero <- columns[grepl("_id$", columns)]
  expect_equal(summariseMissingData(cdm, "drug_exposure") |>
    dplyr::filter(estimate_name == "zero_count") |>
    dplyr::distinct(variable_name) |>
    dplyr::pull() |> sort(), columns_zero |> sort())


  PatientProfiles::mockDisconnect(cdm = cdm)
})
