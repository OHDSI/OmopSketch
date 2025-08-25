#' Create a ggplot2 plot from the output of summariseInObservation().
#'
#' @param result A summarised_result object (output of summariseInObservation).
#' @param facet Columns to face by. Formula format can be provided. See possible
#' columns to face by with: `visOmopResults::tidyColumns()`.
#' @param colour Columns to colour by. See possible columns to colour by with:
#' `visOmopResults::tidyColumns()`.
#' @return A ggplot showing the table counts
#' @export
#' @examples
#' \donttest{
#' library(dplyr)
#' library(OmopSketch)
#'
#' cdm <- mockOmopSketch()
#'
#' result <- summariseInObservation(
#'   observationPeriod = cdm$observation_period,
#'   output = c("person-days","record"),
#'   ageGroup = list("<=40" = c(0, 40), ">40" = c(41, Inf)),
#'   sex = TRUE
#' )
#'
#' result |>
#'   filter(variable_name == "Person-days") |>
#'   plotInObservation(facet = "sex", colour = "age_group")
#'
#' PatientProfiles::mockDisconnect(cdm)
#' }
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
