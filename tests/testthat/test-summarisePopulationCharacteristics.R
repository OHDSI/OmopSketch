test_that("summarisePopulationCharacteristics() works", {
  skip_on_cran()
  # Load mock database ----
  cdm <- cdmEunomia()

  # Check that works ----
  expect_no_error(summarisedPopulation <- summarisePopulationCharacteristics(cdm = cdm))
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

  expect_no_error(summarisedPopulationEqual <- summarisePopulationCharacteristics(
    cdm = cdm,
    studyPeriod = NULL)
  )
  expect_equal(summarisedPopulation, summarisedPopulationEqual)

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
                    dplyr::pull() |>
                    sort() ==
                    c("age_group_at_start", "age_group_at_start &&& sex", "overall", "sex")))
  expect_true(all(summarisedPopulation |>
                    dplyr::filter(variable_name == "Number records") |>
                    dplyr::select("estimate_value") |>
                    dplyr::pull() |>
                    sort() ==
                    c(101,1250,1271,1321,1372,172,2521,2693,71)))
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
                    dplyr::pull() |>
                    sort() ==
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
                    dplyr::pull() |>
                    sort() ==
                    c("age_group_at_start", "overall")))

  # Check result type
  checkResultType(summarisedPopulation, "summarise_population_characteristics")

  PatientProfiles::mockDisconnect(cdm = cdm)
})

test_that("summarisePopulationCharacteristics() works", {
  # Load mock database ----
  cdm <- omock::mockCdmReference() |>
    omock::mockPerson(seed = 1L) |>
    omock::mockObservationPeriod(seed = 1L) |>
    copyCdm()

  # Add sex and age group strata
  expect_no_error(summarisedPopulation <- summarisePopulationCharacteristics(
    cdm = cdm,
    sex = TRUE,
    ageGroup = list(c(0,20),c(21,150)))
  )
  expect_true(inherits(summarisedPopulation,"summarised_result"))
  expect_true(all(summarisedPopulation |>
                    dplyr::select("strata_name") |>
                    dplyr::distinct() |>
                    dplyr::pull() |>
                    sort() ==
                    c("age_group_at_start", "age_group_at_start &&& sex", "overall", "sex")))

  expect_true(all(summarisedPopulation |>
                    dplyr::filter(variable_name == "Number records") |>
                    dplyr::arrange(strata_name, strata_level) |>
                    dplyr::select("estimate_value") |>
                    dplyr::pull() ==
                    c(4,6,1,3,4,2,10,5,5)))

  PatientProfiles::mockDisconnect(cdm = cdm)
})

test_that("summarisePopulationCharacteristics() expected errors", {
  skip_on_cran()
  # Load mock database ----
  cdm <- cdmEunomia()

  expect_error(summarisePopulationCharacteristics("cdm"))
  expect_error(summarisePopulationCharacteristics(cdm, studyPeriod = c("2000-01-01", "1990-01-01")))
  expect_error(summarisePopulationCharacteristics(cdm, studyPeriod = c(NA, "1990-51-01")))
  expect_error(summarisePopulationCharacteristics(cdm, studyPeriod = c("1990-01-01")))
  expect_error(summarisePopulationCharacteristics(cdm, studyPeriod = c("01/31/1990", "2000-01-01")))
  expect_error(summarisePopulationCharacteristics(cdm, studyPeriod = NULL, sex = "Female"))
  expect_error(summarisePopulationCharacteristics(cdm, studyPeriod = NULL, ageGroup = c(0,20,40)))

  PatientProfiles::mockDisconnect(cdm = cdm)
})

test_that("tablePopulationCharacteristics() works", {
  skip_on_cran()
  # Load mock database ----
  cdm <- cdmEunomia()

  # Check that works ----
  x <- summarisePopulationCharacteristics(cdm)
  expect_no_error(y <- tablePopulationCharacteristics(x))
  expect_true(inherits(y,"gt_tbl"))

  x <- x |> dplyr::filter(.data$result_id == -1)
  expect_warning(tablePopulationCharacteristics(x))
  expect_warning(inherits(tablePopulationCharacteristics(x),"gt_tbl"))

  PatientProfiles::mockDisconnect(cdm = cdm)
})

test_that("summarisePopulationCharacteristics() works with mockOmopSKetch", {
  cdm <- mockOmopSketch(numberIndividuals = 2, seed = 1)
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
                    2))
  expect_true(all(summarisedPopulation |>
                    dplyr::filter(variable_name == "Cohort start date" & estimate_name == "min") |>
                    dplyr::select("estimate_value") |>
                    dplyr::pull() ==
                    "1999-04-05"))
  expect_true(summarisedPopulation |>
                dplyr::filter(variable_name == "Age at end", estimate_name == "median") |>
                dplyr::pull("estimate_value") ==
                as.character(mean(c(40,16))))
  expect_true(all(summarisedPopulation |>
                    dplyr::filter(variable_name == "Cohort end date" & estimate_name == "max") |>
                    dplyr::select("estimate_value") |>
                    dplyr::pull() ==
                    "2013-06-29"))
  expect_true(all(summarisedPopulation |>
                    dplyr::filter(variable_name == "Sex", estimate_name == "percentage") |>
                    dplyr::select("estimate_value") |>
                    dplyr::pull() ==
                    c(50,50)))
  expect_true(all(summarisedPopulation |>
                    dplyr::filter(variable_name == "Age at start", estimate_name %in% c("min","max")) |>
                    dplyr::pull("estimate_value") |>
                    sort() ==
                    cdm$observation_period |>
                    PatientProfiles::addAge(indexDate = "observation_period_start_date") |>
                    dplyr::pull("age") |>
                    sort()))

})
