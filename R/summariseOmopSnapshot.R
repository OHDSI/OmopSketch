#' Summarise OMOP database and create snapshot
#' @param cdm A cdm reference object
#' @return A summarised result object
#' @export
#' @examples
#' \donttest{
#'library(dplyr)
#'library(OmopSketch)
#'
#'# Connect to Eunomia database
#'
#'cdm <- mockOmopSketch(numberIndividuals = 1000)
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
