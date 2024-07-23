test_that("summariseClinicalRecords() works", {

  # Load mock database ----
  con <- DBI::dbConnect(duckdb::duckdb(), CDMConnector::eunomia_dir())
  cdm <- CDMConnector::cdmFromCon(
    con = con, cdmSchema = "main", writeSchema = "main"
  )

  # Check all tables work ----
  expect_true(inherits(summariseClinicalRecords(cdm$observation_period),"summarised_result"))
  expect_no_error(summariseClinicalRecords(cdm$observation_period))
  expect_no_error(summariseClinicalRecords(cdm$visit_occurrence))
  expect_no_error(summariseClinicalRecords(cdm$condition_occurrence))
  expect_no_error(summariseClinicalRecords(cdm$drug_exposure))
  expect_no_error(summariseClinicalRecords(cdm$procedure_occurrence))
  expect_warning(summariseClinicalRecords(cdm$device_exposure))
  expect_no_error(summariseClinicalRecords(cdm$measurement))
  expect_no_error(summariseClinicalRecords(cdm$observation))
  expect_warning(summariseClinicalRecords(cdm$death))


  # Check inputs ----
  expect_true(summariseClinicalRecords(cdm$condition_occurrence,
                                 recordsPerPerson = NULL) |>
                dplyr::filter(variable_name %in% "records_per_person") |>
                dplyr::tally() |>
                dplyr::pull() == 0)
  expect_true(summariseClinicalRecords(cdm$condition_occurrence,
                                 inObservation = FALSE) |>
                dplyr::filter(variable_name %in% "In observation") |>
                dplyr::tally() |>
                dplyr::pull() == 0)
  expect_true(summariseClinicalRecords(cdm$condition_occurrence,
                                 standardConcept = FALSE) |>
                dplyr::filter(variable_name %in% "Standard concept") |>
                dplyr::tally() |>
                dplyr::pull() == 0)
  expect_true(summariseClinicalRecords(cdm$condition_occurrence,
                                 sourceVocabulary = FALSE) |>
                dplyr::filter(variable_name %in% "Source vocabulary") |>
                dplyr::tally() |>
                dplyr::pull() == 0)
  expect_true(summariseClinicalRecords(cdm$condition_occurrence,
                                 domainId = FALSE) |>
                dplyr::filter(variable_name %in% "Domain") |>
                dplyr::tally() |>
                dplyr::pull() == 0)
  expect_true(summariseClinicalRecords(cdm$condition_occurrence,
                                 typeConcept = FALSE) |>
                dplyr::filter(variable_name %in% "Type concept id") |>
                dplyr::tally() |>
                dplyr::pull() == 0)
  expect_true(summariseClinicalRecords(cdm$condition_occurrence,
                                 recordsPerPerson = NULL,
                                 inObservation = FALSE,
                                 standardConcept = FALSE,
                                 sourceVocabulary = FALSE,
                                 domainId = FALSE,
                                 typeConcept = FALSE) |>
                dplyr::tally() |> dplyr::pull() == 3)
})


test_that("tableClinicalRecords() works", {
  # Load mock database ----
  con <- DBI::dbConnect(duckdb::duckdb(), CDMConnector::eunomia_dir())
  cdm <- CDMConnector::cdmFromCon(
    con = con, cdmSchema = "main", writeSchema = "main"
  )

  # Check that works ----
  expect_no_error(x <- tableClinicalRecords(summariseClinicalRecords(cdm$condition_occurrence)))
  expect_true(inherits(x,"gt_tbl"))
  expect_warning(tableClinicalRecords(summariseClinicalRecords(cdm$death)))
  expect_true(inherits(tableClinicalRecords(summariseClinicalRecords(cdm$death)),"gt_tbl"))

})

