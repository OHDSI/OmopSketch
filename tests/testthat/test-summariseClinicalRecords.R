test_that("summariseClinicalRecords() works", {
  skip_on_cran()
  # Load mock database ----
  cdm <- cdmEunomia()

  # Check all tables work ----
  expect_true(inherits(summariseClinicalRecords(cdm, "observation_period"),"summarised_result"))
  expect_no_error(op <- summariseClinicalRecords(cdm, "observation_period"))
  expect_no_error(vo <- summariseClinicalRecords(cdm, "visit_occurrence"))
  expect_no_error(summariseClinicalRecords(cdm, "condition_occurrence"))
  expect_no_error(summariseClinicalRecords(cdm, "drug_exposure"))
  expect_no_error(summariseClinicalRecords(cdm, "procedure_occurrence"))
  expect_warning(summariseClinicalRecords(cdm, "device_exposure"))
  expect_no_error(m <- summariseClinicalRecords(cdm, "measurement"))
  expect_no_error(summariseClinicalRecords(cdm, "observation"))
  expect_warning(summariseClinicalRecords(cdm, "death"))

  #Check result type
  checkResultType(op, "summarise_clinical_records")

  expect_no_error(all <- summariseClinicalRecords(cdm, c("observation_period", "visit_occurrence", "measurement")))
  expect_equal(
    dplyr::bind_rows(op, vo,m) |>
      dplyr::mutate(estimate_value = dplyr::if_else(
        .data$variable_name == "records_per_person",
        as.character(round(as.numeric(.data$estimate_value), 3)),
        .data$estimate_value
      )),
    all |>
      dplyr::mutate(estimate_value = dplyr::if_else(
        .data$variable_name == "records_per_person",
        as.character(round(as.numeric(.data$estimate_value), 3)),
        .data$estimate_value
      ))
  )

  # Check inputs ----
  expect_true(summariseClinicalRecords(cdm, "condition_occurrence",
                                 recordsPerPerson = NULL) |>
                dplyr::filter(variable_name %in% "records_per_person") |>
                dplyr::tally() |>
                dplyr::pull() == 0)
  expect_true(summariseClinicalRecords(cdm, "condition_occurrence",
                                 inObservation = FALSE) |>
                dplyr::filter(variable_name %in% "In observation") |>
                dplyr::tally() |>
                dplyr::pull() == 0)
  expect_true(summariseClinicalRecords(cdm, "condition_occurrence",
                                 standardConcept = FALSE) |>
                dplyr::filter(variable_name %in% "Standard concept") |>
                dplyr::tally() |>
                dplyr::pull() == 0)
  expect_true(summariseClinicalRecords(cdm, "condition_occurrence",
                                 sourceVocabulary = FALSE) |>
                dplyr::filter(variable_name %in% "Source vocabulary") |>
                dplyr::tally() |>
                dplyr::pull() == 0)
  expect_true(summariseClinicalRecords(cdm, "condition_occurrence",
                                 domainId = FALSE) |>
                dplyr::filter(variable_name %in% "Domain") |>
                dplyr::tally() |>
                dplyr::pull() == 0)
  expect_true(summariseClinicalRecords(cdm, "condition_occurrence",
                                 typeConcept = FALSE) |>
                dplyr::filter(variable_name %in% "Type concept id") |>
                dplyr::tally() |>
                dplyr::pull() == 0)
  expect_true(summariseClinicalRecords(cdm, "condition_occurrence",
                                 recordsPerPerson = NULL,
                                 inObservation = FALSE,
                                 standardConcept = FALSE,
                                 sourceVocabulary = FALSE,
                                 domainId = FALSE,
                                 typeConcept = FALSE) |>
                dplyr::tally() |> dplyr::pull() == 3)

  PatientProfiles::mockDisconnect(cdm = cdm)
})

test_that("summariseClinicalRecords() sex and ageGroup argument work", {
  skip_on_cran()
  # Load mock database ----
  cdm <- cdmEunomia()

  # Check all tables work ----
  expect_true(inherits(summariseClinicalRecords(cdm, "observation_period", sex = TRUE, ageGroup = list(">= 30" = c(30, Inf), "<30" = c(0, 29))),"summarised_result"))
  expect_no_error(op <- summariseClinicalRecords(cdm, "observation_period", sex = TRUE, ageGroup = list(">= 30" = c(30, Inf), "<30" = c(0, 29))))
  expect_no_error(vo <- summariseClinicalRecords(cdm, "visit_occurrence", sex = TRUE, ageGroup = list(">= 30" = c(30, Inf), "<30" = c(0, 29))))
  expect_no_error(summariseClinicalRecords(cdm, "condition_occurrence", sex = TRUE, ageGroup = list(">= 30" = c(30, Inf))))
  expect_no_error(summariseClinicalRecords(cdm, "drug_exposure", sex = TRUE, ageGroup = list(">= 30" = c(30, Inf), "<30" = c(0, 29))))
  expect_no_error(summariseClinicalRecords(cdm, "procedure_occurrence", sex = TRUE, ageGroup = list(">= 30" = c(30, Inf), "<30" = c(0, 29))))
  expect_warning(summariseClinicalRecords(cdm, "device_exposure", sex = TRUE, ageGroup = list(">= 30" = c(30, Inf), "<30" = c(0, 29))))
  expect_no_error(m <- summariseClinicalRecords(cdm, "measurement", sex = TRUE, ageGroup = list(">= 30" = c(30, Inf), "<30" = c(0, 29))))
  expect_no_error(summariseClinicalRecords(cdm, "observation", sex = TRUE, ageGroup = list(">= 30" = c(30, Inf), "<30" = c(0, 29))))
  expect_warning(summariseClinicalRecords(cdm, "death", sex = TRUE, ageGroup = list(">= 30" = c(30, Inf), "<30" = c(0, 29))))

  expect_no_error(all <- summariseClinicalRecords(cdm,
                                                  c("observation_period", "visit_occurrence", "measurement"),
                                                  sex = TRUE,
                                                  ageGroup = list(">= 30" = c(30, Inf), "<30" = c(0, 29))))


  expect_identical(
    dplyr::bind_rows(op, vo,m) |>
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
      ) |>
      nrow(),
    0L
  )

  # Check sex and age group---
  x <- summariseClinicalRecords(cdm, "condition_occurrence", sex = TRUE, ageGroup = list(">= 30" = c(30, Inf), "<30" = c(0, 29))) |>
    dplyr::filter(variable_name == "number subjects", estimate_name == "count",
                  strata_name == "sex" | strata_name == "overall") |>
    dplyr::select("strata_name", "strata_level", "estimate_value") |>
    dplyr::mutate(group = dplyr::if_else(strata_name == "overall",1, 2)) |>
    dplyr::summarise(n = sum(as.numeric(estimate_value), na.rm = TRUE), .by = group)

  expect_equal(x$n[[1]], x$n[[2]])

  x <- summariseClinicalRecords(cdm, "condition_occurrence", sex = TRUE, ageGroup = list(">= 30" = c(30, Inf), "<30" = c(0, 29))) |>
    dplyr::filter(variable_name == "number records", estimate_name == "count",
                  strata_name == "sex" | strata_name == "overall") |>
    dplyr::select("strata_name", "strata_level", "estimate_value") |>
    dplyr::mutate(group = dplyr::if_else(strata_name == "overall",1, 2)) |>
    dplyr::summarise(n = sum(as.numeric(estimate_value), na.rm = TRUE), .by = group)

  expect_equal(x$n[[1]], x$n[[2]])

  x <- summariseClinicalRecords(cdm, "condition_occurrence", sex = TRUE, ageGroup = list(">= 30" = c(30, Inf), "<30" = c(0, 29))) |>
    dplyr::filter(variable_name == "number records", estimate_name == "count",
                  strata_name == "age_group" | strata_name == "overall") |>
    dplyr::select("strata_name", "strata_level", "estimate_value") |>
    dplyr::mutate(group = dplyr::if_else(strata_name == "overall",1, 2)) |>
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
    con = connection(), cdm = cdm, schema = schema())

  result <- summariseClinicalRecords(cdm, "observation_period",
                           inObservation = FALSE,
                           standardConcept = FALSE,
                           sourceVocabulary = FALSE,
                           domainId = FALSE,
                           typeConcept = FALSE,
                           sex = TRUE,
                           ageGroup = list("old" = c(10, Inf), "young" = c(0, 9)))

  # Check num records
  records <- result |>
    dplyr::filter(variable_name == "number records", estimate_name == "count")
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
  expect_true(records |> dplyr::filter(strata_name == "overall", estimate_name == "mean") |> dplyr::pull(estimate_value) == "1.8")
  expect_true(records |> dplyr::filter(strata_level == "old &&& Male", estimate_name == "median") |> dplyr::pull(estimate_value) == "3")

  PatientProfiles::mockDisconnect(cdm = cdm)
})


test_that("tableClinicalRecords() works", {
  skip_on_cran()
  # Load mock database ----
  cdm <- cdmEunomia()

  # Check that works ----
  expect_no_error(x <- tableClinicalRecords(summariseClinicalRecords(cdm, "condition_occurrence")))
  expect_true(inherits(x,"gt_tbl"))
  expect_no_error(y <- tableClinicalRecords(summariseClinicalRecords(cdm, c("observation_period",
                                                                            "measurement"))))
  expect_true(inherits(y,"gt_tbl"))
  expect_warning(t <- summariseClinicalRecords(cdm, "death"))
  expect_warning(inherits(tableClinicalRecords(t),"gt_tbl"))

  PatientProfiles::mockDisconnect(cdm = cdm)
})


