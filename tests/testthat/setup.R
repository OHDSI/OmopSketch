
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

connection <- function(type = Sys.getenv("DB_TO_TEST", "duckdb")) {
  switch(
    type,
    "duckdb" = DBI::dbConnect(duckdb::duckdb(), ":memory:"),
    "postgres" = DBI::dbConnect(RPostgres::Postgres(),
                                dbname = Sys.getenv("server_dbi"),
                                port = Sys.getenv("port"),
                                host = Sys.getenv("host"),
                                user = Sys.getenv("user"),
                                password = Sys.getenv("password"))
  )
}

schema <- function(type = Sys.getenv("DB_TO_TEST", "duckdb")) {
  switch(
    type,
    "duckdb" = c(schema = "main", prefix = "os_"),
    "postgres" = c(schema = "results", prefix = "os_")
  )
}

cdmEunomia <- function() {
  con <- connection()
  schema <- schema()
  conDuck <- DBI::dbConnect(duckdb::duckdb(), CDMConnector::eunomia_dir())
  cdmDuck <- CDMConnector::cdmFromCon(
    con = conDuck, cdmSchema = "main", writeSchema = "main"
  )
  cdm <- CDMConnector::copyCdmTo(con = con, cdm = cdmDuck, schema = schema)
  CDMConnector::cdmDisconnect(cdm = cdmDuck)
  return(cdm)
}

