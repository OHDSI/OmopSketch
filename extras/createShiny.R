
# databases to characterise
devtools::load_all()
databases <- c("GiBleed", "synthea-covid19-10k")

# create results
results <- purrr::map(databases, \(dbName) {
  cli::cli_inform(c(i = "Starting {.strong {dbName}} characterisation"))
  CDMConnector::requireEunomia(datasetName = dbName) |>
    suppressMessages()
  cli::cli_inform(c(v = "{.strong {dbName}} downloaded"))
  res <- dbName |>
    CDMConnector::eunomiaDir() |>
    duckdb::duckdb() |>
    duckdb::dbConnect() |>
    CDMConnector::cdmFromCon(
      cdmSchema = "main", writeSchema = "main", cdmName = dbName
    ) |>
    databaseCharacteristics(
      interval = "years",
      conceptIdCounts = TRUE
    ) |>
    suppressMessages()
  cli::cli_inform(c(v = "{.strong {dbName}} characterised"))

  res
}) |>
  omopgenerics::bind()

shinyCharacteristics(
  result = results,
  directory = here::here("extras")
  )
