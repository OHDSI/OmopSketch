
# databases to characterise
devtools::load_all()
databases <- omock::availableMockDatasets()
databases <- databases[!databases %in% c("empty_cdm")]

# create results
results <- purrr::map(databases, \(dbName) {

  cli::cli_inform(c(i = "Starting {.strong {dbName}} characterisation"))

  # download dataset
  omock::downloadMockDataset(datasetName = dbName, overwrite = FALSE) |>
    suppressMessages()
  cli::cli_inform(c(v = "{.strong {dbName}} downloaded."))

  # create cdm reference
  duckFile <- tempfile(fileext = ".duckdb")
  drv <- duckdb::duckdb(dbdir = duckFile)
  src <- CDMConnector::dbSource(con = duckdb::dbConnect(drv = drv), writeSchema = "main")
  cdm <- omock::mockCdmFromDataset(datasetName = dbName) |>
    omopgenerics::insertCdmTo(to = src) |>
    suppressMessages()
  cli::cli_inform(c(v = "{.cls cdm_reference} created for {.strong {dbName}}."))

  # characterise databas
  start <- Sys.time()
  res <- databaseCharacteristics(
    cdm = cdm,
    interval = "years",
    conceptIdCounts = TRUE
  ) |>
    suppressMessages()
  diff <- difftime(time1 = Sys.time(), time2 = start, units = "secs") |>
    as.numeric() |>
    round()
  cli::cli_inform(c(v = "{.strong {dbName}} characterised in {diff} seconds."))

  # disconnect
  CDMConnector::cdmDisconnect(cdm = cdm)
  duckdb::duckdb_shutdown(drv = drv)
  unlink(duckFile)

  res
}) |>
  omopgenerics::bind()

shinyCharacteristics(
  result = results,
  directory = here::here("extras")
)
