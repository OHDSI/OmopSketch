
#' Summarise a cdm_reference object creating a snapshot with the metadata of the
#' cdm_reference object.
#'
#' @param cdm A cdm_reference object.
#' @return A summarised_result object.
#' @export
#' @examples
#' \donttest{
#' cdm <- mockOmopSketch(numberIndividuals = 10)
#'
#' summariseOmopSnapshot(cdm)
#' }
summariseOmopSnapshot <- function(cdm) {

  cdm <- omopgenerics::validateCdmArgument(cdm)

  summaryTable <- summary(cdm)

  summaryTable <- summaryTable |>
    internalTibble() |>
    omopgenerics::newSummarisedResult(settings = createSettings(
      result_type = "summarise_omop_snapshot"
    ))


  return(summaryTable)
}

internalTibble <- function(summaryTable){
  summaryTable |>
    dplyr::inner_join(
      dplyr::tibble(
        "variable_name" = c("person_count", "snapshot_date", "vocabulary",
                            "cdm", "cdm", "cdm", "cdm", "cdm", "cdm", "cdm",
                            "observation_period_count", "observation_period_start_date", "observation_period_end_date"),
        "estimate_name" = c("count", "value", "version",
                            "description", "documentation_reference", "holder_name", "release_date", "source_name","source_type","version",
                            "count", "min","max"),
        "variable_name1" = c("general", "general", "general",
                             "cdm", "cdm", "cdm", "cdm", "cdm", "cdm", "cdm",
                             "observation_period", "observation_period", "observation_period"),
        "estimate_name1" = c("person_count", "snapshot_date", "vocabulary_version",
                             "description", "documentation_reference", "holder_name", "release_date", "source_name","source_type","version",
                             "count", "start_date", "end_date")
      ),
      by = c("variable_name", "estimate_name")
    ) |>
    dplyr::select(-c("variable_name", "estimate_name")) |>
    dplyr::rename("variable_name" = "variable_name1", "estimate_name" = "estimate_name1")
}
