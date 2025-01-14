
on_github <- function() {
  !interactive() && !identical(Sys.getenv("NOT_CRAN"), "false")
}
if (on_github()) {
  withr::local_envvar(
    R_USER_CACHE_DIR = tempfile(),
    .local_envir = testthat::teardown_env(),
    EUNOMIA_DATA_FOLDER = Sys.getenv("EUNOMIA_DATA_FOLDER", unset = tempfile())
  )
  CDMConnector::downloadEunomiaData(overwrite = TRUE)
}
schema <- function(type = Sys.getenv("DB_TO_TEST", "duckdb")) {
  switch(
    type,
    "duckdb" = c(schema = "main", prefix = "omop_sketch_"),
    "postgres" = c(schema = "results", prefix = "os_")
  )
}
cdmEunomia <- function() {
  con <- connection()
  schema <- schema()
  conDuck <- DBI::dbConnect(duckdb::duckdb(), CDMConnector::eunomiaDir())
  cdmDuck <- CDMConnector::cdmFromCon(
    con = conDuck, cdmSchema = "main", writeSchema = "main"
  )
  # correct eunomia problems
  tabs <- c(
    "observation_period", "visit_occurrence", "visit_detail", "specimen",
    "note", "condition_occurrence", "drug_exposure", "procedure_occurrence",
    "device_exposure", "measurement", "observation", "death"
  )
  for (tab in tabs) {
    start <- omopgenerics::omopColumns(table = tab, field = "start_date")
    id <- omopgenerics::omopColumns(table = tab, field = "unique_id")
    cdmDuck[[tab]] <- cdmDuck[[tab]] |>
      dplyr::inner_join(
        cdmDuck$person |>
          dplyr::select("person_id"),
        by = "person_id"
      ) |>
      dplyr::group_by(dplyr::across(dplyr::all_of(id))) |>
      dplyr::filter(.data[[start]] == min(.data[[start]], na.rm = TRUE)) |>
      dplyr::ungroup() |>
      dplyr::compute()
  }
  cdm <- CDMConnector::copyCdmTo(con = con, cdm = cdmDuck, schema = schema)
  CDMConnector::cdmDisconnect(cdm = cdmDuck)
  return(cdm)
}
writeSchema <- function(dbToTest = Sys.getenv("DB_TO_TEST", "duckdb")) {
  prefix <- paste0("coco_", sample(letters, 4) |> paste0(collapse = ""), "_")
  switch(dbToTest,
         "duckdb" = c(schema = "main", prefix = prefix),
         "sql server" = c(catalog = "ohdsi", schema = "dbo", prefix = prefix),
         "redshift" = c(schema = "resultsv281", prefix = prefix)
  )
}
connection <- function(dbToTest = Sys.getenv("DB_TO_TEST", "duckdb")) {
  switch(dbToTest,
         "duckdb" = DBI::dbConnect(duckdb::duckdb(), ":memory:"),
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
  CDMConnector::copyCdmTo(
    con = connection(), cdm = cdm, schema = writeSchema(), overwrite = TRUE
  )
}
checkResultType <- function(result, result_type){
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
