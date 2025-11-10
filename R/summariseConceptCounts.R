#' Summarise concept counts in patient-level data
#'
#' Only concepts recorded during observation period are counted.
#'
#' `r lifecycle::badge('deprecated')`
#'
#' @inheritParams consistent-doc
#' @param conceptId List of concept IDs to summarise.
#' @param countBy Either "record" for record-level counts or "person" for
#' person-level counts
#' @param concept TRUE or FALSE. If TRUE code use will be summarised by concept.
#' @inheritParams dateRange-startDate
#'
#' @return A `summarised_result` object with the results.
#' @export
#'
summariseConceptCounts <- function(cdm,
                                   conceptId,
                                   countBy = c("record", "person"),
                                   concept = TRUE,
                                   interval = "overall",
                                   sex = FALSE,
                                   ageGroup = NULL,
                                   dateRange = NULL) {
  lifecycle::deprecate_warn(
    when = "0.2.0",
    what = "summariseConceptCounts()",
    with = NULL
  )
  summariseConceptSetCounts(
    cdm = cdm,
    conceptSet = conceptId,
    countBy = countBy,
    concept = concept,
    interval = interval,
    sex = sex,
    ageGroup = ageGroup,
    dateRange = dateRange
  )
}
