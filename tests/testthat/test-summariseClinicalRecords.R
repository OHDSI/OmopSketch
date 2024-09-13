test_that("summariseClinicalRecords() works", {

  # Load mock database ----
  cdm <- cdmEunomia()

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

  PatientProfiles::mockDisconnect(cdm = cdm)
})

test_that("tableClinicalRecords() works", {
  # Load mock database ----
  cdm <- cdmEunomia()

  # Check that works ----
  expect_no_error(x <- tableClinicalRecords(summariseClinicalRecords(cdm$condition_occurrence)))
  expect_true(inherits(x,"gt_tbl"))
  expect_warning(t <- summariseClinicalRecords(cdm$death))
  expect_warning(inherits(tableClinicalRecords(t),"gt_tbl"))

  PatientProfiles::mockDisconnect(cdm = cdm)
})

cdm <- mockOmopSketch()
omopTable <- cdm$condition_occurrence
recordsPerPerson = c("mean", "sd", "median", "q25", "q75", "min", "max")
inObservation = TRUE
standardConcept = TRUE
sourceVocabulary = FALSE
domainId = TRUE
typeConcept = TRUE
sex = TRUE
ageGroup <- list(">20" = c(21,40), "<= 20" = c(0,20))

