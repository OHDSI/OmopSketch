test_that("summariseRecordCount() works", {

  # Load mock database ----
  con <- DBI::dbConnect(duckdb::duckdb(), CDMConnector::eunomia_dir())
  cdm <- CDMConnector::cdmFromCon(
    con = con, cdmSchema = "main", writeSchema = "main"
  )

  # Check inputs ----
  expect_true(inherits(summariseRecordCount(omopTable = cdm$observation_period, unit = "month"),"summarised_result"))
  expect_true(inherits(summariseRecordCount(omopTable = cdm$observation_period, unitInterval = 5),"summarised_result"))

  expect_no_error(summariseRecordCount(cdm$observation_period))
  expect_no_error(summariseRecordCount(cdm$visit_occurrence))
  expect_no_error(summariseRecordCount(cdm$condition_occurrence))
  expect_no_error(summariseRecordCount(cdm$drug_exposure))
  expect_no_error(summariseRecordCount(cdm$procedure_occurrence))
  expect_warning(summariseRecordCount(cdm$device_exposure))
  expect_no_error(summariseRecordCount(cdm$measurement))
  expect_no_error(summariseRecordCount(cdm$observation))
  expect_warning(summariseRecordCount(cdm$death))

  # Check inputs ----
  expect_true(
    (summariseRecordCount(cdm$observation_period) |>
       dplyr::filter(variable_level == "1963-01-01 to 1963-12-31") |>
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
  summariseRecordCount(cdm$condition_occurrence, unit = "month") |>
    dplyr::filter(variable_level == "1961-02-01 to 1961-02-28") |>
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
    (summariseRecordCount(cdm$condition_occurrence, unit = "month", unitInterval = 3) |>
      dplyr::filter(variable_level %in% c("1984-01-01 to 1984-03-31")) |>
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
    (summariseRecordCount(cdm$drug_exposure, unitInterval = 8) |>
       dplyr::filter(variable_level == "1981-01-01 to 1988-12-31") |>
       dplyr::pull("estimate_value") |>
       as.numeric()) ==
      (cdm$drug_exposure |>
         dplyr::ungroup() |>
         dplyr::mutate(year = lubridate::year(drug_exposure_start_date)) |>
         dplyr::filter(year %in% c(1981:1988)) |>
         dplyr::tally() |>
         dplyr::pull("n"))
  )

  # summariseRecordCount plot ----
  expect_true(inherits(plotTableCounts(summariseRecordCount(cdm$drug_exposure, unitInterval = 8)),"ggplot"))
  expect_warning(inherits(plotTableCounts(summariseRecordCount(cdm$death, unitInterval = 8)),"ggplot"))
  expect_true(inherits(plotTableCounts(summariseRecordCount(cdm$death, unitInterval = 8)),"ggplot"))
})

test_that("summariseOmopTable() ageGroup argument works", {
  # Load mock database ----
  con <- DBI::dbConnect(duckdb::duckdb(), CDMConnector::eunomia_dir())
  cdm <- CDMConnector::cdmFromCon(
    con = con, cdmSchema = "main", writeSchema = "main"
  )

  # Check that works ----
  expect_no_error(t <- summariseRecordCount(cdm$condition_occurrence, ageGroup = list(">=65" = c(65, Inf), "<65" = c(0,64))))
  x <- t |>
    dplyr::select("strata_level", "variable_level", "estimate_value") |>
    dplyr::filter(strata_level != "overall") |>
    dplyr::group_by(variable_level) |>
    dplyr::summarise(estimate_value = sum(as.numeric(estimate_value))) |>
    dplyr::arrange(variable_level) |>
    dplyr::pull("estimate_value")
  y <- t |>
    dplyr::select("strata_level", "variable_level", "estimate_value") |>
    dplyr::filter(strata_level == "overall") |>
    dplyr::arrange(variable_level) |>
    dplyr::mutate(estimate_value = as.numeric(estimate_value)) |>
    dplyr::pull("estimate_value")
  expect_equal(x,y)



  expect_no_error(t <- summariseRecordCount(cdm$condition_occurrence, ageGroup = list("<=20" = c(0,20), "21 to 40" = c(21,40), "41 to 60" = c(41,60), ">60" = c(61, Inf))))
  x <- t |>
    dplyr::select("strata_level", "variable_level", "estimate_value") |>
    dplyr::filter(strata_level != "overall") |>
    dplyr::group_by(variable_level) |>
    dplyr::summarise(estimate_value = sum(as.numeric(estimate_value))) |>
    dplyr::arrange(variable_level) |>
    dplyr::pull("estimate_value")
  y <- t |>
    dplyr::select("strata_level", "variable_level", "estimate_value") |>
    dplyr::filter(strata_level == "overall") |>
    dplyr::arrange(variable_level) |>
    dplyr::mutate(estimate_value = as.numeric(estimate_value)) |>
    dplyr::pull("estimate_value")
  expect_equal(x,y)

})
