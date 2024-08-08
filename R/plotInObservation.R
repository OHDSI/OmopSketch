#' Create a gt table from a summarised omop_table.
#'
#' @param summarisedInObservation Output from summariseInObservation().
#' @param facet columns in data to facet. If the facet position wants to be specified, use the formula class for the input
#' (e.g., strata_level ~ group_level + cdm_name). Variables before "~" will be facet by on horizontal axis, whereas those after "~" on vertical axis.
#' Only the following columns are allowed to be facet by: "cdm_name", "group_level", "strata_level".
#'
#' @return A ggplot showing the table counts
#'
#' @export
#'
plotInObservation <- function(summarisedInObservation, facet = NULL){
  internalPlot(summarisedResult = summarisedInObservation,
               facet = facet)
}
