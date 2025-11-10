
#' Create a visual table from a summariseInObservation() result
#'
#' `r lifecycle::badge('deprecated')`
#'
#' @param result A summarised_result object (output of
#' `summariseInObservation()`).
#' @param  type Type of formatting output table. See
#' `visOmopResults::tableType()` for allowed options. Default is `"gt"`.
#'
#' @return A formatted table visualisation.
#' @export
#'
#' @examples
#' \donttest{
#' library(OmopSketch)
#' library(dplyr, warn.conflicts = FALSE)
#' library(omock)
#'
#' cdm <- mockCdmFromDataset(datasetName = "GiBleed", source = "duckdb")
#'
#' result <- summariseInObservation(
#'   observationPeriod = cdm$observation_period,
#'   interval = "years",
#'   output = c("person-days", "record"),
#'   ageGroup = list("<=60" = c(0, 60), ">60" = c(61, Inf)),
#'   sex = TRUE
#' )
#'
#' result |>
#'   tableInObservation()
#'
#' cdmDisconnect(cdm = cdm)
#' }
#'
tableInObservation <- function(result,
                               type = "gt") {
  lifecycle::deprecate_warn(
    when = "1.0.0",
    what = "tableInObservation()",
    with = "tableTrend()"
  )
  return(tableTrend(result = result, type = type))
}
