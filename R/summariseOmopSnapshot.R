#' Summarise OMOP database and create snapshot
#'
#' @param cdm A cdm reference object
#' @return A summarised result object
#' @examples
#' # example code
#'
#' cdm <- cdmEunomia()
#'
#' snapshot <- summariseOmopSnapshot(cdm)
#'
#' omopgenerics::settings(snapshot)
#'
#' @export

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
