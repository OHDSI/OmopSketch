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

  # Check all tables work ----
  expect_true(inherits(summariseOmopTable(cdm$observation_period),"summarised_result"))
  expect_no_error(summariseOmopTable(cdm$observation_period))
  expect_no_error(summariseOmopTable(cdm$visit_occurrence))
  expect_no_error(summariseOmopTable(cdm$condition_occurrence))
  expect_no_error(summariseOmopTable(cdm$drug_exposure))
  expect_no_error(summariseOmopTable(cdm$procedure_occurrence))
  expect_warning(summariseOmopTable(cdm$device_exposure))
  expect_no_error(summariseOmopTable(cdm$measurement))
  expect_no_error(summariseOmopTable(cdm$observation))
  expect_warning(summariseOmopTable(cdm$death))


  # Check inputs ----
  expect_true(summariseOmopTable(cdm$condition_occurrence,
                                 recordsPerPerson = NULL) |>
                dplyr::filter(variable_name %in% "records_per_person") |>
                dplyr::tally() |>
                dplyr::pull() == 0)
  expect_true(summariseOmopTable(cdm$condition_occurrence,
                                 inObservation = FALSE) |>
                dplyr::filter(variable_name %in% "In observation") |>
                dplyr::tally() |>
                dplyr::pull() == 0)
  expect_true(summariseOmopTable(cdm$condition_occurrence,
                                 standardConcept = FALSE) |>
                dplyr::filter(variable_name %in% "Standard concept") |>
                dplyr::tally() |>
                dplyr::pull() == 0)
  expect_true(summariseOmopTable(cdm$condition_occurrence,
                                 sourceVocabulary = FALSE) |>
                dplyr::filter(variable_name %in% "Source vocabulary") |>
                dplyr::tally() |>
                dplyr::pull() == 0)
  expect_true(summariseOmopTable(cdm$condition_occurrence,
                                 domainId = FALSE) |>
                dplyr::filter(variable_name %in% "Domain") |>
                dplyr::tally() |>
                dplyr::pull() == 0)
  expect_true(summariseOmopTable(cdm$condition_occurrence,
                                 typeConcept = FALSE) |>
                dplyr::filter(variable_name %in% "Type concept id") |>
                dplyr::tally() |>
                dplyr::pull() == 0)
  expect_true(summariseOmopTable(cdm$condition_occurrence,
                                 recordsPerPerson = NULL,
                                 inObservation = FALSE,
                                 standardConcept = FALSE,
                                 sourceVocabulary = FALSE,
                                 domainId = FALSE,
                                 typeConcept = FALSE) |>
                dplyr::tally() |> dplyr::pull() == 3)


  DBI::dbDisconnect(db)
})


test_that("tableOmopTable() works", {
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

  # Check that works ----
  expect_no_error(x <- tableOmopTable(summariseOmopTable(cdm$condition_occurrence)))
  expect_true(inherits(x,"gt_tbl"))
  expect_warning(tableOmopTable(summariseOmopTable(cdm$death)))
  expect_true(inherits(tableOmopTable(summariseOmopTable(cdm$death)),"gt_tbl"))

  # DBI::dbDisconnect(db)
})

