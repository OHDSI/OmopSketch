
dbToTest <- Sys.getenv("DB_TO_TEST", "duckdb-CDMConnector")
cdmEunomia <- function() {

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
  cdm <- cdmLocal |>
    copyCdm()

  return(cdm)
}

copyCdm <- function(cdm) {
  pref <- "oi_"
  if (dbToTest == "duckdb-CDMConnector") {
    to <- CDMConnector::dbSource(
      con = duckdb::dbConnect(drv = duckdb::duckdb(dbdir = ":memory:")),
      writeSchema = c(schema = "main", prefix = pref)
    )
  } else if (dbToTest == "sql server-CDMConnector") {
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
    # TODO
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
    dplyr::arrange(dplyr::across(dplyr::everything()))
}
