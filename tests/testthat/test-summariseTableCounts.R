test_that("summariseTableCounts() works", {

  # Load mock database ----
  dbName <- "GiBleed"
  pathEunomia <- here::here("Eunomia")
  if (!dir.exists(pathEunomia)) {
    dir.create(pathEunomia)
  }
  CDMConnector::downloadEunomiaData(datasetName = dbName, pathToData = pathEunomia)
  Sys.setenv("EUNOMIA_DATA_FOLDER" = pathEunomia)

  db <- DBI::dbConnect(duckdb::duckdb(), CDMConnector::eunomia_dir())

  cdm <- CDMConnector::cdmFromCon(
    con = db,
    cdmSchema = "main",
    writeSchema = "main",
    cdmName = dbName
  )

  # Check inputs ----
  summariseTableCounts(omopTable = cdm$observation_period,
                       unit = "month",
                       unitInterval = 1)
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

  DBI::dbDisconnect(db)

  unlink(here::here("Eunomia"), recursive = TRUE)
})
