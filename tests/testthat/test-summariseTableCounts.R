test_that("summariseTableCounts() works", {

  # Load mock database ----
  con <- DBI::dbConnect(duckdb::duckdb(), CDMConnector::eunomia_dir())
  cdm <- CDMConnector::cdmFromCon(
    con = con, cdmSchema = "main", writeSchema = "main"
  )

  # Check inputs ----
  expect_true(inherits(summariseTableCounts(omopTable = cdm$observation_period, unit = "month"),"summarised_result"))
  expect_true(inherits(summariseTableCounts(omopTable = cdm$observation_period, unitInterval = 5),"summarised_result"))

  expect_no_error(summariseTableCounts(cdm$observation_period))
  expect_no_error(summariseTableCounts(cdm$visit_occurrence))
  expect_no_error(summariseTableCounts(cdm$condition_occurrence))
  expect_no_error(summariseTableCounts(cdm$drug_exposure))
  expect_no_error(summariseTableCounts(cdm$procedure_occurrence))
  expect_warning(summariseTableCounts(cdm$device_exposure))
  expect_no_error(summariseTableCounts(cdm$measurement))
  expect_no_error(summariseTableCounts(cdm$observation))
  expect_warning(summariseTableCounts(cdm$death))

  # Check inputs ----
  expect_true(
    (summariseTableCounts(cdm$observation_period) |>
       dplyr::filter(strata_level == 1963) |>
       dplyr::pull("estimate_value") |>
       as.numeric()) ==
      (cdm$observation_period |>
         dplyr::ungroup() |>
         dplyr::mutate(year = lubridate::year(observation_period_start_date)) |>
         dplyr::filter(year == 1963) |>
         dplyr::tally() |>
         dplyr::pull("n"))
  )

  expect_true(
  summariseTableCounts(cdm$condition_occurrence, unit = "month") |>
    dplyr::filter(strata_level == "1961-02") |>
    dplyr::pull("estimate_value") |>
    as.numeric() ==
  (cdm$condition_occurrence |>
      dplyr::ungroup() |>
      dplyr::mutate(year = lubridate::year(condition_start_date)) |>
      dplyr::mutate(month = lubridate::month(condition_start_date)) |>
      dplyr::filter(year == 1961, month == 2) |>
      dplyr::tally() |>
      dplyr::pull("n"))
  )

  expect_true(
    (summariseTableCounts(cdm$condition_occurrence, unit = "month", unitInterval = 3) |>
      dplyr::filter(strata_level %in% c("1984-01 to 1984-03")) |>
      dplyr::pull("estimate_value") |>
      as.numeric()) ==
      (cdm$condition_occurrence |>
         dplyr::ungroup() |>
         dplyr::mutate(year = lubridate::year(condition_start_date)) |>
         dplyr::mutate(month = lubridate::month(condition_start_date)) |>
         dplyr::filter(year == 1984, month %in% c(1:3)) |>
         dplyr::tally() |>
         dplyr::pull("n"))
  )

  expect_true(
    (summariseTableCounts(cdm$drug_exposure, unitInterval = 8) |>
       dplyr::filter(strata_level == "1981 to 1988") |>
       dplyr::pull("estimate_value") |>
       as.numeric()) ==
      (cdm$drug_exposure |>
         dplyr::ungroup() |>
         dplyr::mutate(year = lubridate::year(drug_exposure_start_date)) |>
         dplyr::filter(year %in% c(1981:1988)) |>
         dplyr::tally() |>
         dplyr::pull("n"))
  )

  # summariseTableCounts plot
  expect_true(inherits(plotTableCounts(summariseTableCounts(cdm$drug_exposure, unitInterval = 8)),"ggplot"))
  expect_warning(inherits(plotTableCounts(summariseTableCounts(cdm$death, unitInterval = 8)),"ggplot"))
  expect_true(inherits(plotTableCounts(summariseTableCounts(cdm$death, unitInterval = 8)),"ggplot"))

})
