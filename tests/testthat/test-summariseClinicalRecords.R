test_that("summariseClinicalRecords() works", {
  skip_on_cran()
  # Load mock database ----
  cdm <- cdmEunomia()

  # Check all tables work ----
  expect_true(inherits(summariseClinicalRecords(cdm, "observation_period"), "summarised_result"))
  expect_no_error(op <- summariseClinicalRecords(cdm, "observation_period"))
  expect_no_error(vo <- summariseClinicalRecords(cdm, "visit_occurrence"))
  expect_no_error(summariseClinicalRecords(cdm, "condition_occurrence"))
  expect_no_error(summariseClinicalRecords(cdm, "drug_exposure"))
  expect_no_error(summariseClinicalRecords(cdm, "procedure_occurrence"))
  expect_warning(summariseClinicalRecords(cdm, "device_exposure"))
  expect_no_error(m <- summariseClinicalRecords(cdm, "measurement"))
  expect_no_error(summariseClinicalRecords(cdm, "observation"))
  expect_warning(de <- summariseClinicalRecords(cdm, "death"))

  # Check result type
  checkResultType(op, "summarise_clinical_records")
  checkResultType(de, "summarise_clinical_records")

  expect_no_error(all <- summariseClinicalRecords(cdm, c("observation_period", "visit_occurrence", "measurement")))
  expect_equal(
    dplyr::bind_rows(op, vo, m) |>
      dplyr::mutate(estimate_value = dplyr::if_else(
        .data$variable_name == "records_per_person",
        as.character(round(as.numeric(.data$estimate_value), 3)),
        .data$estimate_value
      )) |> dplyr::arrange(.data$group_level, .data$variable_name, .data$variable_level, .data$estimate_name),
    all |>
      dplyr::mutate(estimate_value = dplyr::if_else(
        .data$variable_name == "records_per_person",
        as.character(round(as.numeric(.data$estimate_value), 3)),
        .data$estimate_value
      )) |> dplyr::arrange( .data$group_level, .data$variable_name, .data$variable_level, .data$estimate_name)
  )

  # Check inputs ----
  expect_true(summariseClinicalRecords(cdm, "condition_occurrence",
    recordsPerPerson = NULL
  ) |>
    dplyr::filter(variable_name %in% "records_per_person") |>
    dplyr::tally() |>
    dplyr::pull() == 0)
  expect_true(summariseClinicalRecords(cdm, "condition_occurrence",
    inObservation = FALSE
  ) |>
    dplyr::filter(variable_name %in% "In observation") |>
    dplyr::tally() |>
    dplyr::pull() == 0)
  expect_true(summariseClinicalRecords(cdm, "condition_occurrence",
    standardConcept = FALSE
  ) |>
    dplyr::filter(variable_name %in% "Standard concept") |>
    dplyr::tally() |>
    dplyr::pull() == 0)
  expect_true(summariseClinicalRecords(cdm, "condition_occurrence",
    sourceVocabulary = FALSE
  ) |>
    dplyr::filter(variable_name %in% "Source vocabulary") |>
    dplyr::tally() |>
    dplyr::pull() == 0)
  expect_true(summariseClinicalRecords(cdm, "condition_occurrence",
    domainId = FALSE
  ) |>
    dplyr::filter(variable_name %in% "Domain") |>
    dplyr::tally() |>
    dplyr::pull() == 0)
  expect_true(summariseClinicalRecords(cdm, "condition_occurrence",
    typeConcept = FALSE
  ) |>
    dplyr::filter(variable_name %in% "Type concept id") |>
    dplyr::tally() |>
    dplyr::pull() == 0)
  expect_true(summariseClinicalRecords(cdm, "condition_occurrence",
    recordsPerPerson = NULL,
    inObservation = FALSE,
    standardConcept = FALSE,
    sourceVocabulary = FALSE,
    domainId = FALSE,
    typeConcept = FALSE,
    missingData = FALSE,
    endBeforeStart = FALSE,
    startBeforeBirth = FALSE
  ) |>
    dplyr::tally() |> dplyr::pull() == 3)

  PatientProfiles::mockDisconnect(cdm = cdm)
})

test_that("summariseClinicalRecords() sex and ageGroup argument work", {
  skip_on_cran()
  # Load mock database ----
  cdm <- cdmEunomia()

  # Check all tables work ----
  expect_true(inherits(summariseClinicalRecords(cdm, "observation_period", sex = TRUE, ageGroup = list(">= 30" = c(30, Inf), "<30" = c(0, 29))), "summarised_result"))
  expect_no_error(op <- summariseClinicalRecords(cdm, "observation_period", sex = TRUE, ageGroup = list(">= 30" = c(30, Inf), "<30" = c(0, 29))))
  expect_no_error(vo <- summariseClinicalRecords(cdm, "visit_occurrence", sex = TRUE, ageGroup = list(">= 30" = c(30, Inf), "<30" = c(0, 29))))
  expect_no_error(m <- summariseClinicalRecords(cdm, "measurement", sex = TRUE, ageGroup = list(">= 30" = c(30, Inf), "<30" = c(0, 29))))
  # expect_no_error(summariseClinicalRecords(cdm,
  #                                          c("condition_occurrence", "drug_exposure", "procedure_occurrence"),
  #                                          sex = FALSE,
  #                                          ageGroup = list(c(30, Inf))))
  # expect_warning(summariseClinicalRecords(cdm,c("device_exposure","observation","death"), sex = FALSE,ageGroup = list(c(30, Inf))))

  expect_no_error(all <- summariseClinicalRecords(cdm,
    c("observation_period", "visit_occurrence", "measurement"),
    sex = TRUE,
    ageGroup = list(">= 30" = c(30, Inf), "<30" = c(0, 29))
  ))

  expect_identical(
    dplyr::bind_rows(op, vo, m) |>
      dplyr::mutate(estimate_value = dplyr::if_else(
        .data$estimate_type != "integer",
        as.character(round(as.numeric(.data$estimate_value), 3)),
        .data$estimate_value
      )) |>
      dplyr::anti_join(
        all |>
          dplyr::mutate(estimate_value = dplyr::if_else(
            .data$estimate_type != "integer",
            as.character(round(as.numeric(.data$estimate_value), 3)),
            .data$estimate_value
          ))
      ) |> nrow(),
    0L
  )

  # Check subjects and records value ----
  x <- cdm[["measurement"]] |>
    PatientProfiles::addAgeQuery(indexDate = "measurement_date", ageGroup = list(">= 30" = c(30, Inf), "<30" = c(0, 29))) |>
    dplyr::select("person_id", "age_group")
  n_records <- x |>
    dplyr::group_by(age_group) |>
    dplyr::summarise(estimate_value = dplyr::n()) |>
    dplyr::collect() |>
    dplyr::arrange(age_group) |>
    dplyr::mutate(dplyr::across(dplyr::everything(), as.character))
  n_subjects <- x |>
    dplyr::group_by(person_id, age_group) |>
    dplyr::ungroup() |>
    dplyr::distinct() |>
    dplyr::group_by(age_group) |>
    dplyr::summarise(estimate_value = dplyr::n()) |>
    dplyr::collect() |>
    dplyr::arrange(age_group) |>
    dplyr::mutate(dplyr::across(dplyr::everything(), as.character))

  m_records <- m |>
    dplyr::filter(variable_name == "Number records", strata_level %in% c("<30", ">= 30"), estimate_name == "count") |>
    dplyr::select("age_group" = "strata_level", "estimate_value") |>
    dplyr::collect() |>
    dplyr::arrange(age_group)
  m_subjects <- m |>
    dplyr::filter(variable_name == "Number subjects", strata_level %in% c("<30", ">= 30"), estimate_name == "count") |>
    dplyr::select("age_group" = "strata_level", "estimate_value") |>
    dplyr::collect() |>
    dplyr::arrange(age_group)

  expect_equal(m_records, n_records, ignore_attr = TRUE)
  expect_equal(m_subjects, n_subjects, ignore_attr = TRUE)

  # Check sex and age group---
  x <- summariseClinicalRecords(cdm, "condition_occurrence", sex = TRUE, ageGroup = list(">= 30" = c(30, Inf), "<30" = c(0, 29))) |>
    dplyr::filter(
      variable_name == "Number subjects", estimate_name == "count",
      strata_name == "sex" | strata_name == "overall"
    ) |>
    dplyr::select("strata_name", "strata_level", "estimate_value") |>
    dplyr::mutate(group = dplyr::if_else(strata_name == "overall", 1, 2)) |>
    dplyr::summarise(n = sum(as.numeric(estimate_value), na.rm = TRUE), .by = group)

  expect_equal(x$n[[1]], x$n[[2]])

  x <- summariseClinicalRecords(cdm, "condition_occurrence", sex = TRUE, ageGroup = list(">= 30" = c(30, Inf), "<30" = c(0, 29))) |>
    dplyr::filter(
      variable_name == "Number records", estimate_name == "count",
      strata_name == "sex" | strata_name == "overall"
    ) |>
    dplyr::select("strata_name", "strata_level", "estimate_value") |>
    dplyr::mutate(group = dplyr::if_else(strata_name == "overall", 1, 2)) |>
    dplyr::summarise(n = sum(as.numeric(estimate_value), na.rm = TRUE), .by = group)

  expect_equal(x$n[[1]], x$n[[2]])

  x <- summariseClinicalRecords(cdm, "condition_occurrence", sex = TRUE, ageGroup = list(">= 30" = c(30, Inf), "<30" = c(0, 29))) |>
    dplyr::filter(
      variable_name == "Number records", estimate_name == "count",
      strata_name == "age_group" | strata_name == "overall"
    ) |>
    dplyr::select("strata_name", "strata_level", "estimate_value") |>
    dplyr::mutate(group = dplyr::if_else(strata_name == "overall", 1, 2)) |>
    dplyr::summarise(n = sum(as.numeric(estimate_value), na.rm = TRUE), .by = group)

  expect_equal(x$n[[1]], x$n[[2]])

  PatientProfiles::mockDisconnect(cdm = cdm)

  # Check statistics
  cdm <- omopgenerics::cdmFromTables(
    tables = list(
      person = dplyr::tibble(
        person_id = as.integer(1:5),
        gender_concept_id = c(8507L, 8532L, 8532L, 8507L, 8507L),
        year_of_birth = c(2000L, 2000L, 2011L, 2012L, 2013L),
        month_of_birth = 1L,
        day_of_birth = 1L,
        race_concept_id = 0L,
        ethnicity_concept_id = 0L
      ),
      observation_period = dplyr::tibble(
        observation_period_id = as.integer(1:9),
        person_id = c(1, 1, 1, 2, 2, 3, 3, 4, 5) |> as.integer(),
        observation_period_start_date = as.Date(c(
          "2020-03-01", "2020-03-25", "2020-04-25", "2020-08-10",
          "2020-03-10", "2020-03-01", "2020-04-10", "2020-03-10",
          "2020-03-10"
        )),
        observation_period_end_date = as.Date(c(
          "2020-03-20", "2020-03-30", "2020-08-15", "2020-12-31",
          "2020-03-27", "2020-03-09", "2020-05-08", "2020-12-10",
          "2020-03-10"
        )),
        period_type_concept_id = 0L
      )
    ),
    cdmName = "mock data"
  )

  cdm <- CDMConnector::copyCdmTo(
    con = connection(), cdm = cdm, schema = schema()
  )

  result <- summariseClinicalRecords(
    cdm = cdm,
    omopTableName = "observation_period",
    inObservation = FALSE,
    standardConcept = FALSE,
    sourceVocabulary = FALSE,
    domainId = FALSE,
    typeConcept = FALSE,
    sex = TRUE,
    ageGroup = list("old" = c(10, Inf), "young" = c(0, 9))
  )

  # Check num records
  records <- result |>
    dplyr::filter(variable_name == "Number records", estimate_name == "count")
  expect_identical(records |> dplyr::filter(strata_name == "overall") |> dplyr::pull(estimate_value), "9")
  expect_identical(records |> dplyr::filter(strata_level == "old") |> dplyr::pull(estimate_value), "5")
  expect_identical(records |> dplyr::filter(strata_level == "young") |> dplyr::pull(estimate_value), "4")
  expect_identical(records |> dplyr::filter(strata_level == "Male") |> dplyr::pull(estimate_value), "5")
  expect_identical(records |> dplyr::filter(strata_level == "Female") |> dplyr::pull(estimate_value), "4")
  expect_identical(records |> dplyr::filter(strata_level == "old &&& Male") |> dplyr::pull(estimate_value), "3")
  expect_identical(records |> dplyr::filter(strata_level == "old &&& Female") |> dplyr::pull(estimate_value), "2")
  expect_identical(records |> dplyr::filter(strata_level == "young &&& Male") |> dplyr::pull(estimate_value), "2")
  expect_identical(records |> dplyr::filter(strata_level == "young &&& Female") |> dplyr::pull(estimate_value), "2")

  # Check stats
  records <- result |>
    dplyr::filter(variable_name == "records_per_person")
  expect_true(records |> dplyr::filter(strata_name == "overall", estimate_name == "mean") |> dplyr::pull(estimate_value) == "1.8000")
  expect_true(records |> dplyr::filter(strata_level == "old &&& Male", estimate_name == "median") |> dplyr::pull(estimate_value) == "3")
})

test_that("dateRange argument works", {
  skip_on_cran()
  # Load mock database ----
  cdm <- cdmEunomia()
  expect_no_error(summariseClinicalRecords(cdm, "condition_occurrence", dateRange = as.Date(c("2012-01-01", "2018-01-01"))))
  expect_message(x <- summariseClinicalRecords(cdm, "drug_exposure", dateRange = as.Date(c("2012-01-01", "2025-01-01"))))
  observationRange <- cdm$observation_period |>
    dplyr::summarise(
      minobs = min(.data$observation_period_start_date, na.rm = TRUE),
      maxobs = max(.data$observation_period_end_date, na.rm = TRUE)
    )
  expect_no_error(y <- summariseClinicalRecords(cdm, "drug_exposure", dateRange = as.Date(c("2012-01-01", observationRange |> dplyr::pull("maxobs")))))
  expect_equal(x|>dplyr::arrange(.data$variable_name, .data$variable_level, .data$estimate_name), y|>dplyr::arrange(.data$variable_name, .data$variable_level, .data$estimate_name), ignore_attr = TRUE)
  expect_false(settings(x)$study_period_end == settings(y)$study_period_end)
  expect_error(summariseClinicalRecords(cdm, "drug_exposure", dateRange = as.Date(c("2015-01-01", "2014-01-01"))))
  expect_warning(z <- summariseClinicalRecords(cdm, "drug_exposure", dateRange = as.Date(c("2020-01-01", "2021-01-01"))))
  expect_equal(z, omopgenerics::emptySummarisedResult(), ignore_attr = TRUE)
  expect_equal(summariseClinicalRecords(cdm, "drug_exposure", dateRange = as.Date(c("2012-01-01", NA)))|>dplyr::arrange(.data$variable_name, .data$variable_level, .data$estimate_name), y|>dplyr::arrange(.data$variable_name, .data$variable_level, .data$estimate_name), ignore_attr = TRUE)
  checkResultType(z, "summarise_clinical_records")
  expect_equal(colnames(settings(z)), colnames(settings(x)))
})


test_that("tableClinicalRecords() works", {
  skip_on_cran()
  # Load mock database ----
  cdm <- cdmEunomia()

  # Check that works ----
  expect_no_error(x <- tableClinicalRecords(summariseClinicalRecords(cdm, "condition_occurrence")))
  expect_true(inherits(x, "gt_tbl"))
  expect_no_error(y <- tableClinicalRecords(summariseClinicalRecords(cdm, c(
    "observation_period",
    "measurement"
  ))))
  expect_true(inherits(y, "gt_tbl"))
  expect_warning(t <- summariseClinicalRecords(cdm, "death"))
  expect_warning(inherits(tableClinicalRecords(t), "gt_tbl"))
  expect_no_error(x <- tableClinicalRecords(summariseClinicalRecords(cdm, "condition_occurrence"), type = "datatable"))
  PatientProfiles::mockDisconnect(cdm = cdm)
})

test_that("summariseClinicalRecords() works with mock data", {
  skip_on_cran()
  # Load mock database ----
  cdm <- mockOmopSketch()

  # Check all tables work ----
  expect_no_error(vo <- summariseClinicalRecords(cdm, "visit_occurrence"))
  expect_no_error(summariseClinicalRecords(cdm, "drug_exposure"))
  expect_no_error(summariseClinicalRecords(cdm, "procedure_occurrence"))
  expect_no_error(summariseClinicalRecords(cdm, "death"))

  PatientProfiles::mockDisconnect(cdm = cdm)
})

test_that("no tables created", {
  skip_on_cran()
  # Load mock database ----
  cdm <- cdmEunomia()

  startNames <- CDMConnector::listSourceTables(cdm)

  results <- summariseClinicalRecords(
    cdm = cdm,
    omopTableName = c("drug_exposure", "condition_occurrence"),
    sex = TRUE,
    ageGroup = list(
      c(0, 17),
      c(18, 65),
      c(66, 100)
    ),
    dateRange = as.Date(c("2012-01-01", "2018-01-01"))
  )

  endNames <- CDMConnector::listSourceTables(cdm)

  expect_true(length(setdiff(endNames, startNames)) == 0)


  PatientProfiles::mockDisconnect(cdm = cdm)
})

test_that("record outside observaton period", {
  skip_on_cran()

  cdm <- mockOmopSketch()

  drug_exposure <- dplyr::tibble(
    drug_exposure_id = c(1, 2, 3),
    person_id = c(1, 2, 5) |> as.integer(),
    drug_exposure_start_date = as.Date(c(
      "2020-03-10", "2020-08-11", "2021-03-25"
    )),
    drug_exposure_end_date = as.Date(c(
      "2020-03-11", "2020-08-12", "2021-03-30"
    )),
    drug_concept_id = 0L,
    drug_type_concept_id = 1L,
    drug_source_concept_id = 2L
  )

  observation_period <- dplyr::tibble(
    observation_period_id = as.integer(1:9),
    person_id = c(1, 1, 1, 2, 2, 3, 3, 4, 5) |> as.integer(),
    observation_period_start_date = as.Date(c(
      "2020-03-01", "2020-03-25", "2020-04-25", "2020-08-10",
      "2020-03-10", "2020-03-01", "2020-04-10", "2020-03-10",
      "2020-03-10"
    )),
    observation_period_end_date = as.Date(c(
      "2020-03-20", "2020-03-30", "2020-08-15", "2020-12-31",
      "2020-03-27", "2020-03-09", "2020-05-08", "2020-12-10",
      "2020-03-10"
    )),
    period_type_concept_id = 0L
  )

  cdm <- omopgenerics::insertTable(cdm, name = "drug_exposure", table = drug_exposure)
  cdm <- omopgenerics::insertTable(cdm, name = "observation_period", table = observation_period)

  age_groups <- list()
  for (i in seq(0, 100, by = 2)) {
    age_groups <- c(age_groups, list(c(i, i + 1)))
  }
  r <- summariseClinicalRecords(cdm, "drug_exposure", ageGroup = age_groups)
  percentages <- r |>
    dplyr::filter(estimate_name == "percentage" & strata_level == "overall") |>
    dplyr::mutate(estimate_value = as.numeric(.data$estimate_value)) |>
    dplyr::group_by(variable_name) |>
    dplyr::summarise(summ = sum(.data$estimate_value), .groups = "drop") |>
    dplyr::pull(summ)
  expect_true(sum(percentages > 100) == 0)

  PatientProfiles::mockDisconnect(cdm = cdm)
})
test_that("arguments EndBeforeStart and StartBeforeBirth work", {
  skip_on_cran()
  cdm <- cdmEunomia()
  ids <- cdm$drug_exposure |> dplyr::distinct(drug_exposure_id) |> dplyr::pull()
  set.seed(123)
  shuffled <- sample(ids)
  vec1 <- shuffled[1:10]
  vec2 <- shuffled[11:20]
  cdm$drug_exposure <- cdm$drug_exposure |>
    dplyr::mutate(drug_exposure_start_date = dplyr::if_else(.data$drug_exposure_id %in% vec1,
                                                            as.Date("3000-01-01"),
                                                            dplyr::if_else(.data$drug_exposure_id %in% vec2,
                                                                           as.Date("1900-01-01"),
                                                                           .data$drug_exposure_start_date)))



  expect_no_error(x <- summariseClinicalRecords(cdm, "drug_exposure", recordsPerPerson = NULL,sourceVocabulary = F,missingData = F, inObservation = F, typeConcept = F, standardConcept = F, domainId = F))
  y <- cdm$drug_exposure |>
    dplyr::filter(.data$drug_exposure_end_date < .data$drug_exposure_start_date)
  z <- cdm$drug_exposure |>
    dplyr::inner_join(cdm$person |> dplyr::select(person_id, birth_datetime), by = "person_id") |>
    dplyr::filter(.data$drug_exposure_start_date < .data$birth_datetime)

  expect_equal(y |> dplyr::tally() |> dplyr::pull(n),
               x |> dplyr::filter(variable_name == "End date before start date", estimate_name == "count") |> dplyr::pull(estimate_value) |> as.numeric()
  )

  expect_equal(z |> dplyr::tally() |> dplyr::pull(n),
               x |> dplyr::filter(variable_name == "Start date before birth date", estimate_name == "count") |> dplyr::pull(estimate_value) |> as.numeric()
  )

  expect_no_error(x <- summariseClinicalRecords(cdm, "drug_exposure", recordsPerPerson = NULL,sourceVocabulary = F,missingData = F, inObservation = F, typeConcept = F, standardConcept = F, domainId = F, sex = TRUE))
  x <- x |> omopgenerics::splitStrata()


  expect_equal(y |>
                 PatientProfiles::addSexQuery() |>
                 dplyr::filter(sex == "Female") |>
                 dplyr::tally() |> dplyr::pull(n),
               x |>
                 dplyr::filter(sex == "Female" & variable_name == "End date before start date" & estimate_name == "count") |>
                 dplyr::pull(estimate_value) |>
                 as.numeric() )

  expect_equal(z |>
                 PatientProfiles::addSexQuery() |>
                 dplyr::filter(sex == "Female") |>
                 dplyr::tally() |> dplyr::pull(n),
               x |>
                 dplyr::filter(sex == "Female" & variable_name == "Start date before birth date" & estimate_name == "count") |>
                 dplyr::pull(estimate_value) |>
                 as.numeric() )

  expect_no_error(x <- summariseClinicalRecords(cdm, "drug_exposure", recordsPerPerson = NULL,sourceVocabulary = F,missingData = F, inObservation = F, typeConcept = F, standardConcept = F, domainId = F, dateRange = as.Date(c("1910-01-01", NA))))


  ids <- cdm$condition_occurrence |> dplyr::distinct(condition_occurrence_id) |> dplyr::pull()
  set.seed(123)
  shuffled <- sample(ids)
  vec <- shuffled[1:10]

  cdm$condition_occurrence <- cdm$condition_occurrence |>
    dplyr::mutate(condition_start_date = dplyr::if_else(.data$condition_occurrence_id %in% vec,
                                                        as.Date("3000-01-01"),
                                                        .data$condition_start_date))
  y <- cdm$condition_occurrence |>
    dplyr::filter(.data$condition_end_date < .data$condition_start_date)


  expect_no_error(x <- summariseClinicalRecords(cdm, "condition_occurrence", recordsPerPerson = NULL,sourceVocabulary = F,missingData = F, inObservation = F, typeConcept = F, standardConcept = F, domainId = F))
  expect_equal(y |> dplyr::tally() |> dplyr::pull(n), x |> dplyr::filter(estimate_name == "count", variable_name == "End date before start date") |> dplyr::pull(estimate_value)|> as.numeric())
  expect_equal(0L, x |> dplyr::filter(estimate_name == "count", variable_name == "Start date before birth date") |> dplyr::pull(estimate_value)|> as.numeric())


  ids <- cdm$observation_period |> dplyr::distinct(observation_period_id) |> dplyr::pull()
  set.seed(123)
  shuffled <- sample(ids)
  vec <- shuffled[1:10]

  cdm$observation_period <- cdm$observation_period |>
    dplyr::mutate(observation_period_start_date = dplyr::if_else(.data$observation_period_id %in% vec,
                                                                 as.Date("1900-01-01"),
                                                                 .data$observation_period_start_date))

  z <- cdm$observation_period |>
    dplyr::inner_join(cdm$person |> dplyr::select(person_id, birth_datetime), by = "person_id") |>
    dplyr::filter(.data$observation_period_start_date < .data$birth_datetime)

  expect_no_error(x <- summariseClinicalRecords(cdm, "observation_period", recordsPerPerson = NULL,sourceVocabulary = F,missingData = F, inObservation = F, typeConcept = F, standardConcept = F, domainId = F))
  expect_equal(z|>dplyr::tally() |> dplyr::pull(n), x |> dplyr::filter(variable_name == "Start date before birth date" & estimate_name == "count") |> dplyr::pull(estimate_value) |> as.numeric())

  expect_equal(0L, x |> dplyr::filter(estimate_name == "count", variable_name == "End date before start date") |> dplyr::pull(estimate_value)|> as.numeric())


  expect_no_error(summariseClinicalRecords(cdm, "procedure_occurrence", recordsPerPerson = NULL,sourceVocabulary = F,missingData = F, inObservation = F, typeConcept = F, standardConcept = F, domainId = F))
  expect_no_error(summariseClinicalRecords(cdm, "measurement", recordsPerPerson = NULL,sourceVocabulary = F,missingData = F, inObservation = F, typeConcept = F, standardConcept = F, domainId = F))
  expect_warning(summariseClinicalRecords(cdm, "death", recordsPerPerson = NULL,sourceVocabulary = F,missingData = F, inObservation = F, typeConcept = F, standardConcept = F, domainId = F))




  CDMConnector::cdmDisconnect(cdm)


})
test_that("argument missingData works", {
  skip_on_cran()
  cdm <- cdmEunomia()


  expect_no_error(x <- summariseClinicalRecords(cdm, "drug_exposure", recordsPerPerson = NULL,sourceVocabulary = F, inObservation = F, typeConcept = F, standardConcept = F, domainId = F, endBeforeStart = F, startBeforeBirth = F))

  y <- summariseMissingData(cdm, "drug_exposure")

  expect_equal(x |> dplyr::filter(variable_name == "Column name"), y, ignore_attr = TRUE)

  expect_no_error(x <- summariseClinicalRecords(cdm, "drug_exposure",sex = T, ageGroup = list(c(0,50), c(51, 100)), recordsPerPerson = NULL,sourceVocabulary = F, inObservation = F, typeConcept = F, standardConcept = F, domainId = F, endBeforeStart = F, startBeforeBirth = F))
  y <- summariseMissingData(cdm, "drug_exposure", sex = T, ageGroup = list(c(0,50), c(51, 100)))

  expect_equal(x |> dplyr::filter(variable_name == "Column name") |> dplyr::arrange(.data$variable_level, .data$strata_name, .data$strata_level), y |> dplyr::arrange(.data$variable_level, .data$strata_name, .data$strata_level), ignore_attr = TRUE)

  expect_no_error(x <- summariseClinicalRecords(cdm, "drug_exposure", dateRange = as.Date(c("1990-01-01", "1999-12-31")), recordsPerPerson = NULL,sourceVocabulary = F, inObservation = F, typeConcept = F, standardConcept = F, domainId = F, endBeforeStart = F, startBeforeBirth = F))
  y <- summariseMissingData(cdm, "drug_exposure", dateRange = as.Date(c("1990-01-01", "1999-12-31")))

  expect_equal(x |> dplyr::filter(variable_name == "Column name") |> dplyr::arrange(.data$variable_level), y |> dplyr::arrange(.data$variable_level), ignore_attr = TRUE)

  expect_no_error(x <- summariseClinicalRecords(cdm, "drug_exposure", .options = list( col = "drug_concept_id", interval = "years"), recordsPerPerson = NULL,sourceVocabulary = F, inObservation = F, typeConcept = F, standardConcept = F, domainId = F, endBeforeStart = F, startBeforeBirth = F))
  y <- summariseMissingData(cdm, "drug_exposure", col = "drug_concept_id", interval = "years")

  expect_equal(x |>
                 dplyr::filter(variable_name == "Column name") |>
                 dplyr::arrange(.data$variable_level,.data$estimate_name, .data$additional_level)
               ,
               y |> dplyr::arrange(.data$variable_level,.data$estimate_name, .data$additional_level),
               ignore_attr = TRUE)
  expect_no_error(x <- summariseClinicalRecords(cdm, "drug_exposure", .options = list(sample = 100), recordsPerPerson = NULL,sourceVocabulary = F, inObservation = F, typeConcept = F, standardConcept = F, domainId = F, endBeforeStart = F, startBeforeBirth = F))
  expect_equal(x |> dplyr::filter(.data$variable_level == "sig" & .data$estimate_name == "na_count") |> dplyr::pull(.data$estimate_value) |> as.numeric(), 100)

  CDMConnector::cdmDisconnect(cdm)


})




