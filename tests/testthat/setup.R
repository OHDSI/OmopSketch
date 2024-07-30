on_cran <- function() {
  !interactive() && !isTRUE(as.logical(Sys.getenv("NOT_CRAN", "false")))
}

if (!on_cran()) {
  withr::local_envvar(
    R_USER_CACHE_DIR = tempfile(),
    .local_envir = testthat::teardown_env(),
    EUNOMIA_DATA_FOLDER = Sys.getenv("EUNOMIA_DATA_FOLDER", unset = tempfile()),
    DB_TO_TEST = "postgres" #"duckdb"/"postgres" # Write which db you want to use
  )
  CDMConnector::downloadEunomiaData(overwrite = TRUE)
}

connection <- function(type = Sys.getenv("DB_TO_TEST", "duckdb")) {
  switch(
    type,
    "duckdb" = DBI::dbConnect(duckdb::duckdb(), ":memory:")
  )
}
schema <- function(type = Sys.getenv("DB_TO_TEST", "duckdb")) {
  switch(
    type,
    "duckdb" = c(schema = "main", prefix = "os_")
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

