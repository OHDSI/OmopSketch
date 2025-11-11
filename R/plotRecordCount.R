#' Create a ggplot of the records' count trend
#'
#' `r lifecycle::badge('deprecated')`
#'
#' @param result A summarised_result object (output of
#' `summariseRecordCount()`).
#' @inheritParams consistent-doc
#'
#' @return A plot visualisation.
#' @export
#'
#' @examples
#' \donttest{
#' library(omock)
#' library(OmopSketch)
#'
#' cdm <- mockCdmFromDataset(datasetName = "GiBleed", source = "duckdb")
#'
#' summarisedResult <- summariseRecordCount(
#'   cdm = cdm,
#'   omopTableName = "condition_occurrence",
#'   ageGroup = list("<=20" = c(0, 20), ">20" = c(21, Inf)),
#'   sex = TRUE
#' )
#'
#' plotRecordCount(
#'   result = summarisedResult,
#'   colour = "age_group",
#'   facet = sex ~ .
#' )
#'
#' cdmDisconnect(cdm = cdm)
#' }
#'
plotRecordCount <- function(result,
                            facet = NULL,
                            colour = NULL) {
  lifecycle::deprecate_warn(
    when = "1.0.0",
    what = "plotRecordCount()",
    with = "plotTrend()"
  )
  return(plotTrend(result = result, facet = facet, colour = colour))
}
