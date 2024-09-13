
#' Summarise characteristics of the individuals at the start of their
#' observation period.
#'
#' @param cdm A cdm_reference object.
#' @param byYear Whether to stratify the reuslts by year.
#'
#' @export
#'
summariseEntryCharacteristics <- function(cdm, byYear = FALSE) {
  # initial checks
  omopgenerics::assertClass(cdm, "cdm_reference")

  cohort <- cdm$observation_period |>
    dplyr::group_by(.data$person_id) |>
    dplyr::filter(.data$observation_period_start_date == min(
      .data$observation_period_start_date, na.rm = TRUE
    )) |>
    dplyr::ungroup() |>
    dplyr::select(
      "subject_id" = "person_id",
      "cohort_start_date" = "observation_period_start_date",
      "cohort_end_date" = "observation_period_end_date"
    ) |>
    dplyr::mutate("cohort_definition_id" = 1) |>
    omopgenerics::newCohortTable(cohortSetRef = dplyr::tibble(
      "cohort_definition_id" = 1, "cohort_name" = "first_entry"
    ))
  if (byYear) {
    cohort <- cohort %>%
      dplyr::mutate("year" = !!CDMConnector::datepart("cohort_start_date"))
    strata <- list("year")
  } else {
    strata <- list()
  }
  result <- cohort |>
    CohortCharacteristics::summariseCharacteristics(strata = strata) |>
    dplyr::filter(.data$variable_name != "Prior observation") |>
    dplyr::mutate(
      "variable_name" = dplyr::if_else(
        .data$variable_name == "Future observation",
        "Follow up",
        .data$variable_name
      ),
      "result_type" = "summarised_characteristics_entry",
      "package_name" = "OmopSketch",
      "package_version" = as.character(utils::packageVersion("OmopSketch"))
    ) |>
    omopgenerics::newSummarisedResult()
  return(result)
}
