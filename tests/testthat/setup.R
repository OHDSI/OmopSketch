
dbToTest <- Sys.getenv("DB_TO_TEST", "duckdb-CDMConnector")

# prepare eunomia and save it in temp directory
cdmLocal <- omock::mockCdmFromDataset(datasetName = "GiBleed")
tabs <- c(
  "observation_period", "visit_occurrence", "visit_detail", "specimen",
  "note", "condition_occurrence", "drug_exposure", "procedure_occurrence",
  "device_exposure", "measurement", "observation", "death"
)
personIds <- cdmLocal$person |>
  dplyr::distinct(.data$person_id) |>
  dplyr::pull()
for (tab in tabs) {
  start <- omopgenerics::omopColumns(table = tab, field = "start_date")
  id <- omopgenerics::omopColumns(table = tab, field = "unique_id")
  cdmLocal[[tab]] <- cdmLocal[[tab]] |>
    dplyr::filter(.data$person_id %in% .env$personIds)
  if (nrow(cdmLocal[[tab]]) > 0) {
    cdmLocal[[tab]] <- cdmLocal[[tab]] |>
      dplyr::group_by(dplyr::across(dplyr::all_of(id))) |>
      dplyr::filter(.data[[start]] == min(.data[[start]], na.rm = TRUE)) |>
      dplyr::ungroup()
  }
}
pathEunomia <- file.path(tempdir(), "OmopSketchEunomia.RDS")
saveRDS(object = cdmLocal, file = pathEunomia)

cdmEunomia <- function() {
  copyCdm(cdm = readRDS(file = pathEunomia))
}
copyCdm <- function(cdm) {
  pref <- "oi_"
  if (dbToTest == "duckdb-CDMConnector") {
    to <- CDMConnector::dbSource(
      con = duckdb::dbConnect(drv = duckdb::duckdb(dbdir = ":memory:")),
      writeSchema = c(schema = "main", prefix = pref)
    )
  } else if (dbToTest == "sqlserver-CDMConnector") {
    to <- CDMConnector::dbSource(
      con = DBI::dbConnect(
        odbc::odbc(),
        Driver = "ODBC Driver 18 for SQL Server",
        Server = Sys.getenv("CDM5_SQL_SERVER_SERVER"),
        Database = Sys.getenv("CDM5_SQL_SERVER_CDM_DATABASE"),
        UID = Sys.getenv("CDM5_SQL_SERVER_USER"),
        PWD = Sys.getenv("CDM5_SQL_SERVER_PASSWORD"),
        TrustServerCertificate = "yes",
        Port = 1433
      ),
      writeSchema = c(
        schema = Sys.getenv("CDM5_SQL_SERVER_OHDSI_SCHEMA"),
        prefix = pref
      )
    )
  } else if (dbToTest == "redshift-CDMConnector") {
    to <- CDMConnector::dbSource(
      con = DBI::dbConnect(
        RPostgres::Redshift(),
        dbname = Sys.getenv("CDM5_REDSHIFT_DBNAME"),
        port = Sys.getenv("CDM5_REDSHIFT_PORT"),
        host = Sys.getenv("CDM5_REDSHIFT_HOST"),
        user = Sys.getenv("CDM5_REDSHIFT_USER"),
        password = Sys.getenv("CDM5_REDSHIFT_PASSWORD")
      ),
      writeSchema = c(
        schema = Sys.getenv("CDM5_REDSHIFT_SCRATCH_SCHEMA"),
        prefix = pref
      )
    )
  } else if (dbToTest == "postgres-CDMConnector") {
    to <- CDMConnector::dbSource(
      con = RPostgres::dbConnect(
        RPostgres::Postgres(),
        dbname = stringr::str_split_1(Sys.getenv("CDM5_POSTGRESQL_SERVER"), "/")[2],
        host = stringr::str_split_1(Sys.getenv("CDM5_POSTGRESQL_SERVER"), "/")[1],
        user = Sys.getenv("CDM5_POSTGRESQL_USER"),
        password = Sys.getenv("CDM5_POSTGRESQL_PASSWORD")
      ),
      writeSchema = c(schema = "public", prefix = pref)
    )
  } else if (dbToTest == "snowflake-CDMConnector") {
    to <- CDMConnector::dbSource(
      con = odbc::dbConnect(
        odbc::odbc(),
        SERVER = stringr::str_extract(Sys.getenv("CDM_SNOWFLAKE_CONNECTION_STRING"), "(?<=//)[^?]+(?=\\?)"),
        UID = Sys.getenv("CDM_SNOWFLAKE_USER"),
        PWD = Sys.getenv("CDM_SNOWFLAKE_PASSWORD"),
        DATABASE = "ATLAS",
        WAREHOUSE = stringr::str_extract(Sys.getenv("CDM_SNOWFLAKE_CONNECTION_STRING"), "(?i)(?<=\\bwarehouse=)[^&?#]+"),
        Driver = "SnowflakeDSIIDriver"
      ),
      writeSchema = c(catalog = "ATLAS", schema = "RESULTS", prefix = pref)
    )
  } else if (dbToTest != "local-omopgenerics") {
    cli::cli_abort(c(x = "Not supported dbToTest: {.pkg {dbToTest}}"))
  }

  if (dbToTest != "local-omopgenerics") {
    cdm <- omopgenerics::insertCdmTo(cdm = cdm, to = to)
  }

  return(cdm)
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
    dplyr::collect() |>
    dplyr::arrange(dplyr::across(dplyr::everything()))
}
dropCreatedTables <- function(cdm) {
  omopgenerics::dropSourceTable(cdm = cdm, name = dplyr::everything())
  omopgenerics::cdmDisconnect(cdm = cdm)
}
