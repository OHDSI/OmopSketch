
#' Summarise the person table
#'
#' @param cdm A cdm_reference object.
#'
#' @return A summarised_result object with the summary of the person table.
#' @export
#'
#' @examples
#' \donttest{
#' library(dplyr, warn.conflicts = FALSE)
#'
#' cdm <- mockOmopSketch(numberIndividuals = 100)
#'
#' result <- summarisePerson(cdm = cdm)
#'
#' result |>
#'   glimpse()
#'
#' PatientProfiles::mockDisconnect(cdm)
#' }
summarisePerson <- function(cdm) {
  # input check
  cdm <- omopgenerics::validateCdmArgument(cdm = cdm)

  # start empty result
  result <- list()

  # summary subjects
  number_subjects <- omopgenerics::numberSubjects(cdm$person)
  result[["Number subjects"]] <- dplyr::tibble(count = number_subjects)

  # summary sex
  result[["Sex"]] <- cdm$person |>
    PatientProfiles::addSexQuery() |>
    addCount(variable = "sex", den = number_subjects, labels = c("Female", "Male", "None"))
  result[["Sex source"]] <- cdm$person |>
    addCount(variable = "gender_source_value", den = number_subjects)

  # summary race
  result[["Race"]] <- cdm$person |>
    PatientProfiles::addConceptName(column = "race_concept_id", nameStyle = "race") |>
    addCount(variable = "race", den = number_subjects)
  result[["Race source"]] <- cdm$person |>
    addCount(variable = "race_source_value", den = number_subjects)

  # summary ethnicity
  result[["Ethnicity"]] <- cdm$person |>
    PatientProfiles::addConceptName(column = "ethnicity_concept_id", nameStyle = "ethnicity") |>
    addCount(variable = "ethnicity", den = number_subjects)
  result[["Ethnicity source"]] <- cdm$person |>
    addCount(variable = "ethnicity_source_value", den = number_subjects)

  # summary year of birth
  result[["Year of birth"]] <- cdm$person |>
    addCount(variable = "year_of_birth", den = number_subjects)

  # summary month of birth
  result[["Month of birth"]] <- cdm$person |>
    addCount(variable = "month_of_birth", den = number_subjects)

  # summary month of birth
  result[["Day of birth"]] <- cdm$person |>
    addCount(variable = "day_of_birth", den = number_subjects)

  # summary location_id
  result[["Location"]] <- cdm$person |>
    summariseNumeric(variable = "location_id", den = number_subjects)

  # summary provider_id
  result[["Provider"]] <- cdm$person |>
    summariseNumeric(variable = "provider_id", den = number_subjects)

  # summary care_site_id
  result[["Care site"]] <- cdm$person |>
    summariseNumeric(variable = "care_site_id", den = number_subjects)

  # format results
  result <- result |>
    dplyr::bind_rows(.id = "variable_name") |>
    dplyr::mutate(
      cdm_name = omopgenerics::cdmName(x = cdm),
      result_type = "summarise_person",
      package_name = "OmopSketch",
      package_version = as.character(utils::packageVersion("OmopSketch"))
    ) |>
    omopgenerics::transformToSummarisedResult(
      estimates = c("count", "percentage", "count_missing", "count_0", "distinct_values", "percentage_missing"),
      settings = c("result_type", "package_name", "package_version")
    ) |>
    dplyr::mutate(estimate_type = dplyr::if_else(
      .data$estimate_type %in% c("percentage", "percentage_missing"),
      "percentage",
      .data$estimate_type
    ))

  result
}
addCount <- function(x, variable, den, labels = NULL) {
  x <- x |>
    dplyr::rename(variable_level = !!variable) |>
    dplyr::group_by(.data$variable_level) |>
    dplyr::summarise(count = as.integer(dplyr::n())) |>
    dplyr::collect()
  if (!is.null(labels)) {
    x <- x |>
      dplyr::full_join(
        dplyr::tibble(variable_level = labels),
        by = "variable_level"
      )
  }
  x |>
    dplyr::arrange(.data$variable_level) |>
    dplyr::mutate(
      dplyr::mutate(count = dplyr::coalesce(.data$count, 0L)),
      variable_level = as.character(.data$variable_level),
      variable_level = dplyr::coalesce(.data$variable_level, "Missing"),
      percentage = 100 * .data$count / .env$den
    )
}
summariseNumeric <- function(x, variable, den) {
  x |>
    dplyr::rename(variable_level = !!variable) |>
    dplyr::summarise(
      count_missing = as.integer(sum(as.numeric(is.na(.data$variable_level)), na.rm = TRUE)),
      count_0 = as.integer(sum(as.numeric(.data$variable_level == 0), na.rm = TRUE)),
      distinct_values = as.integer(dplyr::n_distinct(.data$variable_level))
    ) |>
    dplyr::collect() |>
    dplyr::mutate(
      count_missing = dplyr::coalesce(.data$count_missing, 0L),
      count_0 = dplyr::coalesce(.data$count_0, 0L),
      distinct_values = dplyr::coalesce(.data$distinct_values, 0L),
      percentage_missing = 100 * .data$count_missing / .env$den
    )
}
