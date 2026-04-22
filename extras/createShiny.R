
library(OmopSketch)
pak::pkg_install("ohdsi/omock")

# TRUE only for GitHub actions
deleteMockData <- as.logical(Sys.getenv("GITHUB_ACTIONS", "FALSE"))
print(deleteMockData)

# set timeout to 10 minutes
options(timeout = 600)

# databases to characterise
databases <- omock::availableMockDatasets()
databases <- databases[!grepl("empty", databases)]

# create results
results <- purrr::map(databases, \(dbName) {

  cli::cli_inform(c(i = "Starting {.strong {dbName}} characterisation"))

  # download dataset
  res <- tryCatch(expr = {
    if (!omock::isMockDatasetDownloaded(datasetName = dbName)) {
      omock::downloadMockDataset(datasetName = dbName, overwrite = FALSE) |>
        suppressMessages()
    }
    cli::cli_inform(c(v = "{.strong {dbName}} downloaded."))

    # create cdm reference
    duckFile <- tempfile(fileext = ".duckdb")
    drv <- duckdb::duckdb(dbdir = duckFile)
    src <- CDMConnector::dbSource(con = duckdb::dbConnect(drv = drv), writeSchema = "main")
    cdm <- omock::mockCdmFromDataset(datasetName = dbName)
    attr(cdm, "cdm_name") <- dbName
    cdm <- omopgenerics::insertCdmTo(cdm = cdm, to = src)
    cli::cli_inform(c(v = "{.cls cdm_reference} created for {.strong {dbName}}."))

    # characterise databas
    start <- Sys.time()
    x <- databaseCharacteristics(
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
    omopgenerics::cdmDisconnect(cdm = cdm)
    duckdb::duckdb_shutdown(drv = drv)
    unlink(duckFile)
    if (deleteMockData) {
      unlink(file.path(omock::mockDatasetsFolder(), paste0(dbName, ".zip")))
    }

    x
  }, error = function(e) {
    cli::cli_inform(c("x" = "{dbName} could not be characterised"))
    omopgenerics::emptySummarisedResult()
  })
}) |>
  omopgenerics::bind()

shinyCharacteristics(
  result = results,
  directory = here::here("extras"),
  background = here::here("extras", "background-synthetic-data.md"),
  logo = here::here("man", "figures", "logo.png")
)
