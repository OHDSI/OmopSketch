source(here::here("tests", "testthat", "setup.R"))
if (grepl("CDMConnector", dbToTest)) {
  con <- connection()
  writeSchema <- schema(pref = "os_")
  ls <- CDMConnector::listTables(con = con, schema = writeSchema)
  to <- CDMConnector::dbSource(con = con, writeSchema = writeSchema)
  omopgenerics::dropSourceTable(cdm = to, name = ls)
}
