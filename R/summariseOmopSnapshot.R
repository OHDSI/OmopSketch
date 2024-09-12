#' Summarise OMOP database and create snapshot
#' @param cdm A cdm reference object
#' @return A summarised result object
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
#'
#'if (Sys.getenv("EUNOMIA_DATA_FOLDER") == "") Sys.setenv("EUNOMIA_DATA_FOLDER" = tempdir())
#'if (!dir.exists(Sys.getenv("EUNOMIA_DATA_FOLDER"))) dir.create(Sys.getenv("EUNOMIA_DATA_FOLDER"))
#'if (!eunomia_is_available()) downloadEunomiaData()
#'
#'con <- DBI::dbConnect(duckdb::duckdb(), CDMConnector::eunomia_dir())
#'
#'cdm <- CDMConnector::cdmFromCon(con = con, cdmSchema = "main", writeSchema = "main")
#'
#'# Run OMOP database snapshot
#'
#'snapshot <- summariseOmopSnapshot(cdm)
#'}

summariseOmopSnapshot <- function(cdm) {
  summaryTable <- summary(cdm)

  summaryTable <- summaryTable |>
    omopgenerics::newSummarisedResult(settings = dplyr::tibble(
      result_id = unique(summaryTable$result_id),
      package_name = "omopSketch",
      package_version = as.character(utils::packageVersion("OmopSketch")),
      result_type = "summarise_omop_snapshot"
    ))

  return(summaryTable)
}
