
#' Create a visual table from a summariseConceptIdCounts() result
#'
#' @param result A summarised_result object (output of
#' `summariseConceptIdCounts()`).
#' @param display A character string indicating which subset of the data to
#' display. Options are:
#'   - `"overall"`: Show all source and standard concepts.
#'   - `"standard"`: Show only standard concepts.
#'   - `"source"`: Show only source codes.
#'   - `"missing standard"`: Show only source codes that are missing a
#'   mapped standard concept.
#' @param type Type of formatting output table, either "reactable" or
#' "datatable".
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
#' result <- summariseConceptIdCounts(cdm = cdm, omopTableName = "condition_occurrence")
#' tableConceptIdCounts(result = result, display = "standard")
#'
#' cdmDisconnect(cdm = cdm)
#' }
#'
tableConceptIdCounts <- function(result,
                                 display = "overall",
                                 type = "reactable") {
  # initial checks
  rlang::check_installed("visOmopResults")
  omopgenerics::validateResultArgument(result)
  omopgenerics::assertChoice(type, c("reactable", "datatable"))
  omopgenerics::assertChoice(display, c("overall", "standard", "source", "missing standard", "missing source"))
  strata_cols <- omopgenerics::strataColumns(result)
  additional_cols <- omopgenerics::additionalColumns(result)
  additional_cols <- additional_cols[!grepl("source_concept", additional_cols)]
  setting_cols <- omopgenerics::settingsColumns(result)
  setting_cols <- setting_cols[!setting_cols %in% c("study_period_end", "study_period_start")]


  # subset to result_type of interest
  result <- result |>
    omopgenerics::filterSettings(
      .data$result_type == "summarise_concept_id_counts"
    ) |>
    omopgenerics::splitStrata() |>
    omopgenerics::splitAdditional() |>
    dplyr::arrange(dplyr::across(dplyr::all_of(additional_cols)), .data$variable_name, dplyr::across(dplyr::all_of(strata_cols))) |>
    dplyr::rename("standard_concept_id" = "variable_level", "standard_concept_name" = "variable_name") |>
    omopgenerics::addSettings()

  if (nrow(result) == 0) {
    warnEmpty("summarise_concept_id_counts")
    return(emptyTable(type))
  }

  if (display == "overall") {
    cols_to_format <- c("standard_concept_name", "standard_concept_id", "source_concept_name", "source_concept_id")
  } else if (display == "standard") {
    cols_to_format <- c("standard_concept_name", "standard_concept_id")
    result <- result |>
      dplyr::select(!dplyr::any_of(c("source_concept_id", "source_concept_name")))
  } else if (display == "source") {
    cols_to_format <- c("source_concept_name", "source_concept_id")
    result <- result |>
      dplyr::select(!dplyr::any_of(c("standard_concept_id", "standard_concept_name")))
  } else if (display == "missing standard") {
    result <- result |>
      dplyr::filter(as.integer(.data$standard_concept_id) == 0L) |>
      dplyr::select(!dplyr::any_of(c("standard_concept_id", "standard_concept_name")))
    cols_to_format <- c("source_concept_name", "source_concept_id")
  } else if (display == "missing source") {
    result <- result |>
      dplyr::filter(as.integer(.data$source_concept_id) == 0L | is.na(.data$source_concept_id)) |>
      dplyr::select(!dplyr::any_of(c("source_concept_id", "source_concept_name")))

    cols_to_format <- c("standard_concept_name", "standard_concept_id")
  }

  multiple_pairs <- result |>
    dplyr::group_by(dplyr::across(-c("estimate_value"))) |>
    dplyr::tally() |>
    dplyr::pull(.data$n) |>
    max()

  if (multiple_pairs > 1) {
    estimates <- result$estimate_name |> unique()
    res <- list()
    if ("count_subjects" %in% estimates) {
      res[["count_subjects"]] <- result |>
        dplyr::filter(.data$estimate_name == "count_subjects") |>
        dplyr::group_by(dplyr::across(-"estimate_value")) |>
        dplyr::summarise(
          count_subjects_min = max(as.numeric(.data$estimate_value), na.rm = TRUE),
          count_subjects_max = sum(as.numeric(.data$estimate_value), na.rm = TRUE),
          .groups = "drop"
        ) |>
        dplyr::select(-"estimate_name") |>
        tidyr::pivot_longer(cols = c("count_subjects_min", "count_subjects_max"), names_to = "estimate_name", values_to = "estimate_value") |>
        dplyr::mutate(estimate_value = as.character(.data$estimate_value))
    }
    if ("count_records" %in% estimates) {
      res[["count_records"]] <- result |>
        dplyr::filter(.data$estimate_name == "count_records") |>
        dplyr::group_by(dplyr::across(-"estimate_value")) |>
        dplyr::summarise(estimate_value = as.character(sum(as.numeric(.data$estimate_value))), .groups = "drop")
    }
    result <- res |> dplyr::bind_rows()
  }


  formatted_result <- result |>
    formatColumn(cols_to_format) |>
    dplyr::mutate(
      estimate_value = as.numeric(.data$estimate_value),
      estimate_name = dplyr::case_when(
        .data$estimate_name == "count_subjects" ~ "N subjects",
        .data$estimate_name == "count_subjects_min" ~ "N subjects - Min",
        .data$estimate_name == "count_subjects_max" ~ "N subjects - Max",
        .data$estimate_name == "count_records" ~ "N records",
        TRUE ~ .data$estimate_name
      )
    ) |>
    dplyr::select(
      dplyr::any_of(c(
        "cdm_name",
        setting_cols,
        "group_level",
        additional_cols,
        "standard_concept_name",
        "standard_concept_id",
        "source_concept_name",
        "source_concept_id",
        "estimate_name",
        "estimate_value",
        strata_cols
      ))
    )

  rename_vec <- c(
    "Database name" = "cdm_name",
    "OMOP table" = "group_level",
    "Standard concept name" = "standard_concept_name",
    "Standard concept id" = "standard_concept_id",
    "Source concept name" = "source_concept_name",
    "Source concept id" = "source_concept_id",
    "Sex" = "sex",
    "Age group" = "age_group",
    "In observation" = "in_observation",
    "Time interval" = "time_interval"
  )


  rename_vec <- rename_vec[rename_vec %in% names(formatted_result)]

  if (length(c(strata_cols, additional_cols)) > 0) {
    formatted_result <- formatted_result |>
      dplyr::arrange(dplyr::across(dplyr::all_of(c(strata_cols, additional_cols))))
  }
  formatted_result |>
    dplyr::rename(!!!rename_vec) |>
    visOmopResults::formatHeader(
      header = c("Database name", "estimate_name"),
      includeHeaderName = FALSE
    ) |>
    visOmopResults::formatTable(type = type, groupColumn = list(" " = c(setting_cols, "OMOP table")))
}
