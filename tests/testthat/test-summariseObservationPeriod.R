test_that("check summariseObservationPeriod works", {
  # Load mock database ----
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
    con = connection(), cdm = cdm, schema = schema())

  # simple run
  expect_no_error(resAll <- summariseObservationPeriod(cdm$observation_period))

  # counts
  expect_identical(resAll$estimate_value[resAll$variable_name == "number records"], "8")
  x <- dplyr::tibble(
    strata_level = c("overall", "1st", "2nd", "3rd"),
    variable_name = "number subjects",
    estimate_value = c("4", "4", "3", "1"))
  expect_identical(nrow(x), resAll |> dplyr::inner_join(x, by = colnames(x)) |> nrow())

  # only one exposure per individual
  cdm$observation_period <- cdm$observation_period |>
    dplyr::group_by(person_id) |>
    dplyr::filter(observation_period_id == min(observation_period_id, na.rm = TRUE)) |>
    dplyr::ungroup() |>
    dplyr::compute(name = "observation_period", temporary = FALSE)

  expect_no_error(resOne <- summariseObservationPeriod(cdm$observation_period))

  # counts
  expect_identical(resOne$estimate_value[resOne$variable_name == "number records"], "4")
  x <- dplyr::tibble(
    strata_level = c("overall", "1st"),
    variable_name = "number subjects",
    estimate_value = c("4", "4"))
  expect_identical(nrow(x), resOne |> dplyr::inner_join(x, by = colnames(x)) |> nrow())

  # empty observation period
  cdm$observation_period <- cdm$observation_period |>
    dplyr::filter(person_id == 0) |>
    dplyr::compute(name = "observation_period", temporary = FALSE)

  expect_no_error(resEmpty <- summariseObservationPeriod(cdm$observation_period))
  expect_true(nrow(resEmpty) == 2)
  expect_identical(unique(resEmpty$estimate_value), "0")

  # table works
  # expect_no_error(tableObservationPeriod(resAll))
  # expect_no_error(tableObservationPeriod(resOne))
  # expect_no_error(tableObservationPeriod(resEmpty))

  # plot works
  # expect_no_error(plotObservationPeriod(resAll))
  # expect_no_error(plotObservationPeriod(resOne))
  # expect_no_error(plotObservationPeriod(resEmpty))

  PatientProfiles::mockDisconnect(cdm = cdm)
})
