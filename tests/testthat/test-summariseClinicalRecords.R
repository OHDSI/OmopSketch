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

test_that("summariseClinicalRecords() check sex argument", {
  # Load mock database ----
  cdm <- cdmEunomia()

  # Check that works ----
  expect_no_error(x <- summariseClinicalRecords(cdm$condition_occurrence, sex = TRUE))

  # Check that the sum Male+Female = Overall
  x1 <- x |>
    dplyr::filter(variable_name != "Records per person", estimate_name != "percentage") |>
    dplyr::summarise(value = sum(as.numeric(estimate_value), na.rm = TRUE), .by = c("strata_name","variable_name", "estimate_name")) |>
    tidyr::pivot_wider(names_from = "strata_name", values_from = "value")
  expect_true(sum(x1$sex - x1$overall, na.rm = TRUE) == 0)

  x1 <- cdm$drug_exposure |>
    dplyr::select("person_id") |>
    dplyr::distinct() |>
    PatientProfiles::addSexQuery() |>
    dplyr::group_by(sex) |>
    dplyr::tally() |>
    dplyr::collect() |>
    dplyr::arrange(sex) |>
    dplyr::pull(n)

  x2 <- summariseClinicalRecords(cdm$drug_exposure, sex = TRUE) |>
    dplyr::filter(variable_name == "Number of subjects", estimate_name == "count", strata_name != "overall") |>
    dplyr::select("strata_level", "estimate_value") |>
    dplyr::collect() |>
    dplyr::arrange(strata_level) |>
    dplyr::pull(estimate_value) |>
    as.numeric()

  expect_equal(x1,x2)

  PatientProfiles::mockDisconnect(cdm = cdm)
})



