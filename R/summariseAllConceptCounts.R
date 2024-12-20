
#' Summarise concept use in patient-level data
#'
#' @param cdm A cdm object
#' @param omopTableName A character vector of the names of the tables to
#' summarise in the cdm object.
#' @param countBy Either "record" for record-level counts or "person" for
#' person-level counts
#' @param year TRUE or FALSE. If TRUE code use will be summarised by year.
#' @param sex TRUE or FALSE. If TRUE code use will be summarised by sex.
#' @param ageGroup A list of ageGroup vectors of length two. Code use will be
#' thus summarised by age groups.
#' @param sample An integer to sample the tables to only that number of records.
#' If NULL no sample is done.
#' @param dateRange A list containing the minimum and the maximum dates
#' defining the time range within which the analysis is performed.
#'
#' @return A summarised_result object with results overall and, if specified, by
#' strata.
#'
#' @export
#'
#' @examples
#' \donttest{
#' library(OmopSketch)
#' library(CDMConnector)
#' library(duckdb)
#'
#' requireEunomia()
#' con <- dbConnect(duckdb(), eunomiaDir())
#' cdm <- cdmFromCon(con = con, cdmSchema = "main", writeSchema = "main")
#'
#' summariseAllConceptCounts(cdm, "condition_occurrence")
#' }
#'
summariseAllConceptCounts <- function(cdm,
                                      omopTableName,
                                      countBy = "record",
                                      year = FALSE,
                                      sex = FALSE,
                                      ageGroup = NULL,
                                      sample = NULL,
                                      dateRange = NULL) {
  lifecycle::deprecate_warn(
    when = "0.2.0",
    what = "summariseAllConceptCounts()",
    with = "summariseConceptIdCounts()"
  )
  summariseConceptIdCounts(
    cdm = cdm,
    omopTableName = omopTableName,
    countBy = countBy,
    year = year,
    sex = sex,
    ageGroup = ageGroup,
    sample = sample,
    dateRange = dateRange
  )
}
