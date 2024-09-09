test_that("summarisePopulationCharacteristics() works", {
  # Load mock database ----
  cdm <- cdmEunomia()

  # Check that works ----
  expect_no_error(summarisedPopulation <- summarisePopulationCharacteristics(
    cdm = cdm)
    )
  expect_true(inherits(summarisedPopulation,"summarised_result"))
  expect_true(all(summarisedPopulation |>
                    dplyr::select("strata_name") |>
                    dplyr::distinct() |>
                    dplyr::pull() ==
                    c("overall")))
  expect_true(all(summarisedPopulation |>
                    dplyr::filter(variable_name == "Number records") |>
                    dplyr::select("estimate_value") |>
                    dplyr::pull() ==
                    2694))
  expect_true(all(summarisedPopulation |>
                    dplyr::filter(variable_name == "Cohort start date" & estimate_name == "min") |>
                    dplyr::select("estimate_value") |>
                    dplyr::pull() ==
                    "1908-09-22"))
  expect_true(summarisedPopulation |>
                dplyr::filter(variable_name == "Age at end") |>
                dplyr::tally() |>
                dplyr::pull() !=
                0)

  # Add date range
  expect_no_error(summarisedPopulation <- summarisePopulationCharacteristics(
    cdm = cdm,
    studyPeriod = c("1900-01-01", "2010-01-01"))
  )
  expect_true(inherits(summarisedPopulation,"summarised_result"))
  expect_true(all(summarisedPopulation |>
                    dplyr::select("strata_name") |>
                    dplyr::distinct() |>
                    dplyr::pull() ==
                    c("overall")))
  expect_true(all(summarisedPopulation |>
                    dplyr::filter(variable_name == "Number records") |>
                    dplyr::select("estimate_value") |>
                    dplyr::pull() ==
                    2694))
  expect_true(all(summarisedPopulation |>
                    dplyr::filter(variable_name == "Cohort end date" & estimate_name == "max") |>
                    dplyr::select("estimate_value") |>
                    dplyr::pull() ==
                    "2010-01-01"))

  # Add sex and age group strata
  expect_no_error(summarisedPopulation <- summarisePopulationCharacteristics(
    cdm = cdm,
    studyPeriod = c("1950-01-01", NA),
    sex = TRUE,
    ageGroup = list(c(0,20),c(21,150)))
    )
  expect_true(inherits(summarisedPopulation,"summarised_result"))
  expect_true(all(summarisedPopulation |>
                    dplyr::select("strata_name") |>
                    dplyr::distinct() |>
                    dplyr::pull() ==
                    c("overall", "sex", "age_group", "sex &&& age_group")))
  expect_true(all(summarisedPopulation |>
                    dplyr::filter(variable_name == "Number records") |>
                    dplyr::select("estimate_value") |>
                    dplyr::pull() ==
                    c(2693,1372,1321,2521,172,1271,101,1250,71)))
  expect_true(summarisedPopulation |>
                dplyr::filter(variable_name == "Age at end" & strata_level == "0 to 20" & estimate_name == "min") |>
                dplyr::pull("estimate_value") <
                summarisedPopulation |>
                dplyr::filter(variable_name == "Age at end" & strata_level == "21 to 150" & estimate_name == "min") |>
                dplyr::pull("estimate_value"))

  # Only sex
  expect_no_error(summarisedPopulation <- summarisePopulationCharacteristics(
    cdm = cdm,
    sex = TRUE
  ))
  expect_true(inherits(summarisedPopulation,"summarised_result"))
  expect_true(all(summarisedPopulation |>
                    dplyr::select("strata_name") |>
                    dplyr::distinct() |>
                    dplyr::pull() ==
                    c("overall", "sex")))

  # Only age group
  expect_no_error(summarisedPopulation <- summarisePopulationCharacteristics(
    cdm = cdm,
    ageGroup = list(c(0,1), c(2,Inf))
  ))
  expect_true(inherits(summarisedPopulation,"summarised_result"))
  expect_true(all(summarisedPopulation |>
                    dplyr::select("strata_name") |>
                    dplyr::distinct() |>
                    dplyr::pull() ==
                    c("overall", "age_group")))

  PatientProfiles::mockDisconnect(cdm = cdm)
})


test_that("summarisePopulationCharacteristics() expected errors", {
  # Load mock database ----
  cdm <- cdmEunomia()

  expect_error(summarisePopulationCharacteristics("cdm"))
  expect_error(summarisePopulationCharacteristics(cdm, studyPeriod = NULL))
  expect_error(summarisePopulationCharacteristics(cdm, studyPeriod = NULL, sex = "Female"))
  expect_error(summarisePopulationCharacteristics(cdm, studyPeriod = NULL, ageGroup = c(0,20,40)))

  PatientProfiles::mockDisconnect(cdm = cdm)
})

