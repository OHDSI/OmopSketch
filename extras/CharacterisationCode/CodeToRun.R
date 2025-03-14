
renv::restore()

dbName <- "synthea-covid19-10k"

CDMConnector::requireEunomia(datasetName = dbName)

con <- duckdb::dbConnect(duckdb::duckdb(), CDMConnector::eunomiaDir(datasetName = dbName))

cdm <- CDMConnector::cdmFromCon(con = con, cdmSchema = "main", writeSchema = "main", cdmName = dbName)

minCellCount = 5

source("RunCharacterisation.R")
