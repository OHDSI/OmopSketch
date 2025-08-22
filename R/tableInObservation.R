#' Create a visual table from a summariseInObservation() result.
#' @param result A summarised_result object.
#' @param  type Type of formatting output table. See `visOmopResults::tableType()` for allowed options. Default is `"gt"`
#' @return A formatted table object with the summarised data.
#' @export
#' @examples
#' \donttest{
#' library(dplyr, warn.conflicts = FALSE)
#'
#' cdm <- mockOmopSketch()
#'
#' result <- summariseInObservation(
#'   observationPeriod = cdm$observation_period,
#'   interval = "months",
#'   output = c("person-days", "record"),
#'   ageGroup = list("<=60" = c(0, 60), ">60" = c(61, Inf)),
#'   sex = TRUE
#' )
#'
#' result |>
#'   tableInObservation()
#'
#' PatientProfiles::mockDisconnect(cdm)
#' }
tableInObservation <- function(result,
                               type = "gt") {
  lifecycle::deprecate_warn(
    when = "1.0.0",
    what = "tableInObservation()",
    with = "tableTrend()"
  )
  return(tableTrend(result = result, type = type))
}
