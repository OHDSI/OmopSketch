#' Create a gt table from a summarised omop_table.
#'
#' @param result A summarised_result object (output of summariseInObservation).
#' @param facet columns in data to facet. If the facet position wants to be specified, use the formula class for the input
#' (e.g., strata_level ~ group_level + cdm_name). Variables before "~" will be facet by on horizontal axis, whereas those after "~" on vertical axis.
#' Only the following columns are allowed to be facet by: "cdm_name", "group_level", "strata_level".
#'
#' @return A ggplot showing the table counts
#'
#' @export
#'
plotInObservation <- function(result,
                              variable,
                              facet = NULL){

  result <- cdmEunomia()$observation_period |>
    summariseInObservation(output = "all")
  omopgenerics::validateResultArguemnt(result)
  omopgenerics::assertCharacter(facet, null = TRUE)
  result <- result |>
    visOmopResults::filterSettings(
      .data$result_type == "summarised_observation_period")
  if (nrow(result) == 0) {
    cli::cli_abort(c("!" = "No records found with result_type == summarised_observation_period"))
  }
  # check variable
  result <-

  result <- result |>
    dplyr::mutate(variable_level = as.Date(stringr::str_extract(
      .data$variable_level, "^[^ to]+")))
  visOmopResults::plotScatter(
    result = result,
    x = "variable_level",
    y = "count",
    line = TRUE,
    point = TRUE,
    ribbon = FALSE,
    ymin = NULL,
    ymax = NULL,
    facet = NULL
  )
  internalPlot(summarisedResult = result,
               facet = facet)
}
