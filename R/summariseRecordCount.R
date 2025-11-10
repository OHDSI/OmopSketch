
#' Summarise record counts of an omop_table using a specific time interval
#'
#' Only records that fall within the observation period are considered.
#'
#'`r lifecycle::badge('deprecated')`
#'
#' @inheritParams consistent-doc
#' @inheritParams dateRange-startDate
#'
#' @return A `summarised_result` object with the results.
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
#' result <- summariseRecordCount(
#'   cdm = cdm,
#'   omopTableName = c("condition_occurrence", "drug_exposure"),
#'   interval = "years",
#'   ageGroup = list("<=20" = c(0, 20), ">20" = c(21, Inf)),
#'   sex = TRUE
#' )
#'
#' tableRecordCount(result = result)
#'
#' cdmDisconnect(cdm = cdm)
#' }
#'
summariseRecordCount <- function(cdm,
                                 omopTableName,
                                 interval = "overall",
                                 ageGroup = NULL,
                                 sex = FALSE,
                                 sample = NULL,
                                 dateRange = NULL) {
  lifecycle::deprecate_warn(
    when = "1.0.0",
    what = "summariseRecordCount()",
    with = "summariseTrend()"
  )

  return(summariseTrend(cdm,
    episode = omopTableName,
    output = "record",
    ageGroup = ageGroup,
    interval = interval,
    sex = sex,
    dateRange = dateRange
  ))
}
