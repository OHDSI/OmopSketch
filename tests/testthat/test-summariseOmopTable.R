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
  expect_warning(summariseOmopTable(cdm$observation_period))
  expect_no_error(summariseOmopTable(cdm$visit_occurrence))
  expect_no_error(summariseOmopTable(cdm$condition_occurrence))
  expect_no_error(summariseOmopTable(cdm$drug_exposure))
  expect_no_error(summariseOmopTable(cdm$procedure_occurrence))
  expect_error(summariseOmopTable(cdm$device_exposure))
  expect_no_error(summariseOmopTable(cdm$measurement))
  expect_no_error(summariseOmopTable(cdm$observation))
  expect_error(summariseOmopTable(cdm$death))


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
})


