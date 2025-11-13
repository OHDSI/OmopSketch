
#' Summarise person table
#'
#' @inheritParams consistent-doc
#'
#' @return A `summarised_result` object with the results.
#' @export
#'
#' @examples
#' \donttest{
#' library(OmopSketch)
#' library(dplyr, warn.conflicts = FALSE)
#' library(omock)
#'
#' cdm <- mockCdmFromDataset(datasetName = "GiBleed", source = "duckdb")
#'
#' result <- summarisePerson(cdm = cdm)
#'
#' tablePerson(result = result)
#'
#' cdmDisconnect(cdm = cdm)
#' }
#'
summarisePerson <- function(cdm) {
  # input check
  cdm <- omopgenerics::validateCdmArgument(cdm = cdm)

  # start empty result
  result <- list()

  # summary subjects
  number_subjects <- as.numeric(omopgenerics::numberSubjects(cdm$person))
  number_subjects_no_op <- cdm$person |>
    dplyr::anti_join(cdm$observation_period, by = "person_id") |>
    omopgenerics::numberSubjects() |>
    as.numeric()
  result[["Number subjects"]] <- dplyr::tibble(
    count = as.integer(number_subjects)
  )
  result[["Number subjects not in observation"]] <- dplyr::tibble(
    count = as.integer(number_subjects_no_op),
    percentage = 100 * number_subjects_no_op / number_subjects
  )

  if (number_subjects_no_op > 0) {
    cli::cli_warn(c("!" = "There {?is/are} {number_subjects_no_op} individual{?s} with no observation period defined."))
  }

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
    summariseNumeric1(variable = "year_of_birth")

  # summary month of birth
  result[["Month of birth"]] <- cdm$person |>
    summariseNumeric1(variable = "month_of_birth")

  # summary month of birth
  result[["Day of birth"]] <- cdm$person |>
    summariseNumeric1(variable = "day_of_birth")

  # summary location_id
  result[["Location"]] <- cdm$person |>
    summariseNumeric2(variable = "location_id", den = number_subjects)

  # summary provider_id
  result[["Provider"]] <- cdm$person |>
    summariseNumeric2(variable = "provider_id", den = number_subjects)

  # summary care_site_id
  result[["Care site"]] <- cdm$person |>
    summariseNumeric2(variable = "care_site_id", den = number_subjects)

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
      estimates = c(
        "count", "percentage", "count_missing", "percentage_missing", "count_0",
        "percentage_0", "distinct_values", "min", "q05", "q25", "median", "q75",
        "q95", "max"
      ),
      settings = c("result_type", "package_name", "package_version")
    ) |>
    dplyr::mutate(estimate_type = dplyr::if_else(
      .data$estimate_type %in% c("percentage", "percentage_missing", "percentage_0"),
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
      count = dplyr::coalesce(.data$count, 0L),
      variable_level = as.character(.data$variable_level),
      variable_level = dplyr::coalesce(.data$variable_level, "Missing"),
      percentage = 100 * as.numeric(.data$count) / .env$den
    )
}
summariseNumeric1 <- function(x, variable) {
  x |>
    dplyr::select()
  PatientProfiles::summariseResult(
    table = x,
    variables = variable,
    estimates = c(
      "count_missing", "percentage_missing", "min", "q05", "q25", "median",
      "q75", "q95", "max"
    ),
    counts = FALSE
  ) |>
    suppressMessages() |>
    omopgenerics::tidy() |>
    dplyr::select(!c("cdm_name", "variable_name"))
}
summariseNumeric2 <- function(x, variable, den) {
  x |>
    dplyr::rename(variable_level = !!variable) |>
    dplyr::summarise(
      # The previous method `sum(as.numeric(is.na(...)))` generates a
      # `CAST(boolean AS NUMERIC)` SQL statement, which fails on PostgreSQL.
      # Using `if_else` generates a portable `CASE WHEN` statement that is
      # compatible with all database backends.
      count_missing = sum(dplyr::if_else(is.na(.data$variable_level), 1L, 0L), na.rm = TRUE),
      count_0 = sum(dplyr::if_else(.data$variable_level == 0, 1L, 0L), na.rm = TRUE),
      distinct_values = as.integer(dplyr::n_distinct(.data$variable_level))
    ) |>
    dplyr::collect() |>
    dplyr::mutate(
      count_missing = dplyr::coalesce(as.integer(.data$count_missing), 0L),
      count_0 = dplyr::coalesce(as.integer(.data$count_0), 0L),
      distinct_values = dplyr::coalesce(as.integer(.data$distinct_values), 0L),
      percentage_missing = 100 * as.numeric(.data$count_missing) / .env$den,
      percentage_0 = 100 * as.numeric(.data$count_0) / .env$den
    )
}

#' Visualise the results of `summarisePerson()` into a table
#'
#' @param result A summarised_result object (output of `summarisePerson()`).
#' @inheritParams style-table
#'
#' @return A formatted table visualisation.
#' @export
#'
#' @examples
#' \donttest{
#' library(OmopSketch)
#' library(omock)
#'
#' cdm <- mockCdmFromDataset(datasetName = "GiBleed", source = "duckdb")
#'
#' result <- summarisePerson(cdm = cdm)
#'
#' tablePerson(result = result)
#' }
#'
tablePerson <- function(result,
                        type = NULL,
                        style = NULL) {
  rlang::check_installed("visOmopResults")

  # input check
  result <- omopgenerics::validateResultArgument(result = result)
  type <- validateType(type)

  # visualise results
  visOmopResults::visOmopTable(
    result = result,
    estimateName = c(
      "N (%)" = "<count> (<percentage>%)",
      "N" = "<count>",
      "Zeros N (%)" = "<count_0> (<percentage_0>%)",
      "Missing N (%)" = "<count_missing> (<percentage_missing>%)",
      "Median [Q25 - Q75]" = "<median> [<q25> - <q75>]",
      "Q05 - Q95" = "<q05> - <q95>",
      "Range" = "<min> to <max>",
      "Distinct values" = "<distinct_values>"
    ),
    header = c("cdm_name"),
    type = type
  ) |>
    suppressWarnings()
}
