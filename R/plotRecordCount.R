#' Create a ggplot of the records' count trend.
#'
#' @param summarisedRecordCount Output from summariseRecordCount().
#' @param facet columns in data to facet. If the facet position wants to be specified, use the formula class for the input
#' (e.g., strata_level ~ group_level + cdm_name). Variables before "~" will be facet by on horizontal axis, whereas those after "~" on vertical axis.
#' Only the following columns are allowed to be facet by: "cdm_name", "group_level", "strata_level".
#'
#' @return A ggplot showing the table counts
#'
#' @export
#' @examples
#' \donttest{
#'library(dplyr)
#'library(CDMConnector)
#'library(DBI)
#'library(duckdb)
#'library(OmopSketch)
#'
#'# Connect to Eunomia database
#'if (Sys.getenv("EUNOMIA_DATA_FOLDER") == "") Sys.setenv("EUNOMIA_DATA_FOLDER" = tempdir())
#'if (!dir.exists(Sys.getenv("EUNOMIA_DATA_FOLDER"))) dir.create(Sys.getenv("EUNOMIA_DATA_FOLDER"))
#'if (!eunomia_is_available()) downloadEunomiaData()
#'con <- DBI::dbConnect(duckdb::duckdb(), CDMConnector::eunomia_dir())
#'cdm <- CDMConnector::cdmFromCon(
#' con = con, cdmSchema = "main", writeSchema = "main"
#')
#'
#'# Run summarise clinical tables
#'summarisedResult <- summariseRecordCount(omopTable = cdm$condition_occurrence,
#'                                       unit = "year",
#'                                       unitInterval = 10,
#'                                       ageGroup = list("<=20" = c(0,20), ">20" = c(21, Inf)),
#'                                       sex = TRUE)
#'plotRecordCount(summarisedResult, facet = strata_level ~ .)
#'PatientProfiles::mockDisconnect(cdm = cdm)
#'}
plotRecordCount <- function(summarisedRecordCount, facet = NULL){
  internalPlot(summarisedResult = summarisedRecordCount,
               facet = facet)
}
