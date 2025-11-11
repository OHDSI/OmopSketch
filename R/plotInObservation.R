
#' Create a ggplot2 plot from the output of summariseInObservation()
#'
#' `r lifecycle::badge('deprecated')`
#'
#' @param result A summarised_result object (output of
#' `summariseInObservation()`).
#' @inheritParams consistent-doc
#'
#' @return A plot visualisation.
#' @export
#'
#' @examples
#' \donttest{
#' library(dplyr)
#' library(OmopSketch)
#' library(omock)
#'
#' cdm <- mockCdmFromDataset(datasetName = "GiBleed", source = "duckdb")
#'
#' result <- summariseInObservation(
#'   observationPeriod = cdm$observation_period,
#'   output = c("person-days", "record"),
#'   ageGroup = list("<=40" = c(0, 40), ">40" = c(41, Inf)),
#'   sex = TRUE
#' )
#'
#' result |>
#'   filter(variable_name == "Person-days") |>
#'   plotInObservation(facet = "sex", colour = "age_group")
#'
#' cdmDisconnect(cdm = cdm)
#' }
#'
plotInObservation <- function(result,
                              facet = NULL,
                              colour = NULL) {
  lifecycle::deprecate_warn(
    when = "1.0.0",
    what = "plotInObservation()",
    with = "plotTrend()"
  )
  return(plotTrend(result = result, facet = facet, colour = colour))
}
