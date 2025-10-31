#' Create a visual table from a summariseRecordCount() result.
#' `r lifecycle::badge('deprecated')`
#' @param result A summarised_result object.
#' @param  type Type of formatting output table. See `visOmopResults::tableType()` for allowed options. Default is `"gt"`.
#' @return A formatted table object with the summarised data.
#' @export
#' @examples
#' \donttest{
#' library(OmopSketch)
#' library(dplyr, warn.conflicts = FALSE)
#'
#' cdm <- mockOmopSketch()
#'
#' summarisedResult <- summariseRecordCount(
#'   cdm = cdm,
#'   omopTableName = c("condition_occurrence", "drug_exposure"),
#'   interval = "years",
#'   ageGroup = list("<=20" = c(0, 20), ">20" = c(21, Inf)),
#'   sex = TRUE
#' )
#'
#' tableRecordCount(result = summarisedResult)
#'
#' CDMConnector::cdmDisconnect(cdm = cdm)
#' }
tableRecordCount <- function(result,
                             type = "gt") {
  lifecycle::deprecate_warn(
    when = "1.0.0",
    what = "tableRecordCount()",
    with = "tableTrend()"
  )
  return(tableTrend(result = result, type = type))
}
