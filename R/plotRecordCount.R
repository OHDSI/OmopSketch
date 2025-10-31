#' Create a ggplot of the records' count trend.
#' `r lifecycle::badge('deprecated')`
#' @param result Output from summariseRecordCount().
#' @param facet Columns to face by. Formula format can be provided. See possible
#' columns to face by with: `visOmopResults::tidyColumns()`.
#' @param colour Columns to colour by. See possible columns to colour by with:
#' `visOmopResults::tidyColumns()`.
#' @return A ggplot showing the table counts
#' @export
#' @examples
#' \donttest{
#' library(OmopSketch)
#'
#' cdm <- mockOmopSketch()
#'
#' summarisedResult <- summariseRecordCount(
#'   cdm = cdm,
#'   omopTableName = "condition_occurrence",
#'   ageGroup = list("<=20" = c(0, 20), ">20" = c(21, Inf)),
#'   sex = TRUE
#' )
#'
#' plotRecordCount(result = summarisedResult, colour = "age_group", facet = sex ~ .)
#'
#' CDMConnector::cdmDisconnect(cdm = cdm)
#' }
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
