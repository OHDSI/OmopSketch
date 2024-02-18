
#' Summarise an omop_table from a cdm_reference object. You will obtain
#' information related to the number of records, number of subjects, whether the
#' records are in observation, number of present domains and number of present
#' concepts.
#'
#' @param omopTable An omop_table object.
#' @param byYear Whether to stratify the analysis by year.
#'
#' @export
#'
summariseOmopTable <- function(omopTable, byYear = FALSE) {
  # initial checks
  checkmate::assertClass(omopTable, "omop_table")

  # summary

}
