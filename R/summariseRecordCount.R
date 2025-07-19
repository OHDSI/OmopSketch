#' Summarise record counts of an omop_table using a specific time interval. Only
#' records that fall within the observation period are considered.
#'
#' @param cdm A cdm_reference object.
#' @param omopTableName A character vector of omop tables from the cdm.
#' @inheritParams interval
#' @param ageGroup A list of age groups to stratify results by.
#' @param sex Whether to stratify by sex (TRUE) or not (FALSE).
#' @inheritParams dateRange-startDate
#' @param sample An integer to sample the tables to only that number of records.
#' If NULL no sample is done.
#' @return A summarised_result object.
#' @export
#' @examples
#' \donttest{
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
#' summarisedResult |>
#'   glimpse()
#'
#' PatientProfiles::mockDisconnect(cdm = cdm)
#' }
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
                        dateRange = dateRange))
}


