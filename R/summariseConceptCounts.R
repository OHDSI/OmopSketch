#' Summarise concept counts in patient-level data. Only concepts recorded during observation period are counted.
#'
#' `r lifecycle::badge('deprecated')`
#'
#' @param cdm A cdm object
#' @param conceptId List of concept IDs to summarise.
#' @param countBy Either "record" for record-level counts or "person" for
#' person-level counts
#' @param concept TRUE or FALSE. If TRUE code use will be summarised by concept.
#' @inheritParams interval
#' @param sex TRUE or FALSE. If TRUE code use will be summarised by sex.
#' @param ageGroup A list of ageGroup vectors of length two. Code use will be
#' thus summarised by age groups.
#' @inheritParams dateRange-startDate
#'
#' @return A summarised_result object with results overall and, if specified, by
#' strata.
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
    with = "summariseConceptSetCounts()"
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
