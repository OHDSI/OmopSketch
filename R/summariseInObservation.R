#' Summarise the number of people in observation during a specific interval of
#' time.
#'`r lifecycle::badge('deprecated')`
#' @param observationPeriod An observation_period omop table. It must be part of
#' a cdm_reference object.
#' @inheritParams interval
#' @param output Output format. It can be either the number of records
#' ("record") that are in observation in the specific interval of time, the
#' number of person-days ("person-days"), the number of subjects ("person"),
#' the number of females ("sex") or the median age of population in observation ("age").
#' @param ageGroup A list of age groups to stratify results by.
#' @param sex Boolean variable. Whether to stratify by sex (TRUE) or not
#' (FALSE). For output = "sex" this stratification is not applied.
#' @inheritParams dateRange-startDate
#' @return A summarised_result object.
#' @export
#' @examples
#' \donttest{
#' library(dplyr, warn.conflicts = FALSE)
#' library(OmopSketch)
#'
#' cdm <- mockOmopSketch()
#'
#' result <- summariseInObservation(
#'   observationPeriod = cdm$observation_period,
#'   interval = "months",
#'   output = c("person-days", "record"),
#'   ageGroup = list("<=60" = c(0, 60), ">60" = c(61, Inf)),
#'   sex = TRUE
#' )
#'
#' result |>
#'   glimpse()
#'
#' PatientProfiles::mockDisconnect(cdm)
#' }
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
