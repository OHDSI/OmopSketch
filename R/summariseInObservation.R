
#' Summarise the number of people in observation during a specific interval of
#' time
#'
#' `r lifecycle::badge('deprecated')`
#'
#' @param observationPeriod An observation_period omop table. It must be part of
#' a cdm_reference object.
#' @inheritParams consistent-doc
#' @param output Output format. It can be either the number of records
#' ("record") that are in observation in the specific interval of time, the
#' number of person-days ("person-days"), the number of subjects ("person"),
#' the number of females ("sex") or the median age of population in observation
#' ("age").
#' @inheritParams dateRange-startDate
#'
#' @return A `summarised_result` object with the results.
#' @export
#'
summariseInObservation <- function(observationPeriod,
                                   interval = "overall",
                                   output = "record",
                                   ageGroup = NULL,
                                   sex = FALSE, dateRange = NULL) {
  lifecycle::deprecate_warn(
    when = "1.0.0",
    what = "summariseInObservation()",
    with = "summariseTrend()"
  )
  cdm <- omopgenerics::cdmReference(observationPeriod)
  return(summariseTrend(cdm,
    episode = "observation_period",
    output = output,
    ageGroup = ageGroup,
    interval = interval,
    sex = sex,
    dateRange = dateRange
  ))
}
