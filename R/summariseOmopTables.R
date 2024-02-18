
#' Summarise the omop_table objects present in a cdm_reference using the
#' function summariseOmopTable().
#'
#' @param cdm An cdm_reference object.
#' @param byYear Whether to stratify the analysis by year.
#'
#' @export
#'
summariseOmopTables <- function(cdm, byYear = FALSE) {
  # initial checks
  checkmate::assertClass(cdm, "cdm_reference")

  # summary

}
