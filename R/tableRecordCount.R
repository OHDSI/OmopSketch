
#' Create a visual table from a summariseRecordCount() result
#'
#' `r lifecycle::badge('deprecated')`
#'
#' @param result A summarised_result object (output of `summariseRecordCount()`
#' ).
#' @param  type Type of formatting output table. See
#' `visOmopResults::tableType()` for allowed options. Default is `"gt"`.
#'
#' @return A formatted table visualisation.
#' @export
#'
#' @examples
#' \donttest{
#' library(OmopSketch)
#' library(omock)
#'
#' cdm <- mockCdmFromDataset(datasetName = "GiBleed", source = "duckdb")
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
#' cdmDisconnect(cdm = cdm)
#' }
#'
tableRecordCount <- function(result,
                             type = "gt") {
  lifecycle::deprecate_warn(
    when = "1.0.0",
    what = "tableRecordCount()",
    with = "tableTrend()"
  )
  return(tableTrend(result = result, type = type))
}
