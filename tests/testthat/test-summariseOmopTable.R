test_that("summariseOmopTable() works", {

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

# Check all tables work
  expect_no_error(summariseOmopTable(cdm$observation_period))
  expect_no_error(summariseOmopTable(cdm$visit_occurrence))
  expect_no_error(summariseOmopTable(cdm$condition_occurrence))
  expect_no_error(summariseOmopTable(cdm$drug_exposure))
  expect_no_error(summariseOmopTable(cdm$procedure_occurrence))
  expect_no_error(summariseOmopTable(cdm$device_exposure))
  expect_no_error(summariseOmopTable(cdm$measurement))
  expect_no_error(summariseOmopTable(cdm$observation))
  expect_error(summariseOmopTable(cdm$death))
})
