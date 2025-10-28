
schema <- function(type = Sys.getenv("DB_TO_TEST", "duckdb-CDMConnector")) {
  switch(type,
    "duckdb-CDMConnector" = c(schema = "main", prefix = "omop_sketch_"),
    "postgres" = c(schema = "results", prefix = "os_"),
    "sql server" = c(catalog = "ohdsi", schema = "dbo", prefix = prefix),
    "redshift" = c(schema = "resultsv281", prefix = prefix)
  )
}
cdmEunomia <- function() {
  con <- connection()
  schema <- schema()
  cdmLocal <- omock::mockCdmFromDataset(datasetName = "GiBleed")
  # correct eunomia problems
  tabs <- c(
    "observation_period", "visit_occurrence", "visit_detail", "specimen",
    "note", "condition_occurrence", "drug_exposure", "procedure_occurrence",
    "device_exposure", "measurement", "observation", "death"
  )
  for (tab in tabs) {
    start <- omopgenerics::omopColumns(table = tab, field = "start_date")
    id <- omopgenerics::omopColumns(table = tab, field = "unique_id")
    cdmLocal[[tab]] <- cdmLocal[[tab]] |>
      dplyr::inner_join(
        cdmLocal$person |>
          dplyr::select("person_id"),
        by = "person_id"
      )
    if (nrow(cdmLocal[[tab]]) > 0) {
      cdmLocal[[tab]] <- cdmLocal[[tab]] |>
        dplyr::group_by(dplyr::across(dplyr::all_of(id))) |>
        dplyr::filter(.data[[start]] == min(.data[[start]], na.rm = TRUE)) |>
        dplyr::ungroup()
    }
  }

  # insert cdm
  to <- CDMConnector::dbSource(con = con, writeSchema = schema)
  cdm <- omopgenerics::insertCdmTo(cdm = cdmLocal, to = to)

  return(cdm)
}
connection <- function(dbToTest = Sys.getenv("DB_TO_TEST", "duckdb-CDMConnector")) {
  switch(dbToTest,
    "duckdb-CDMConnector" = DBI::dbConnect(duckdb::duckdb(), ":memory:"),
    "sql server" = DBI::dbConnect(
      odbc::odbc(),
      Driver = "ODBC Driver 18 for SQL Server",
      Server = Sys.getenv("CDM5_SQL_SERVER_SERVER"),
      Database = Sys.getenv("CDM5_SQL_SERVER_CDM_DATABASE"),
      UID = Sys.getenv("CDM5_SQL_SERVER_USER"),
      PWD = Sys.getenv("CDM5_SQL_SERVER_PASSWORD"),
      TrustServerCertificate = "yes",
      Port = 1433
    ),
    "redshift" = DBI::dbConnect(
      RPostgres::Redshift(),
      dbname = Sys.getenv("CDM5_REDSHIFT_DBNAME"),
      port = Sys.getenv("CDM5_REDSHIFT_PORT"),
      host = Sys.getenv("CDM5_REDSHIFT_HOST"),
      user = Sys.getenv("CDM5_REDSHIFT_USER"),
      password = Sys.getenv("CDM5_REDSHIFT_PASSWORD")
    )
  )
}
copyCdm <- function(cdm) {
  to <- CDMConnector::dbSource(con = connection(), writeSchema = schema())
  omopgenerics::insertCdmTo(cdm = cdm, to = to)
}
checkResultType <- function(result, result_type) {
  expect_true(
    result |>
      omopgenerics::settings() |>
      dplyr::pull("result_type") == result_type
  )
}
sortTibble <- function(x) {
  x |>
    dplyr::arrange(dplyr::across(dplyr::everything()))
}
