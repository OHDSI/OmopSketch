#' Summarise a cdm_reference object creating a snapshot with the metadata of the
#' cdm_reference object.
#'
#' @param cdm A cdm_reference object.
#' @return A summarised_result object.
#' @export
#' @examples
#' \donttest{
#' cdm <- mockOmopSketch(numberIndividuals = 10)
#'
#' summariseOmopSnapshot(cdm = cdm)
#' }
summariseOmopSnapshot <- function(cdm) {
  cdm <- omopgenerics::validateCdmArgument(cdm)

  summaryTable <- summary(cdm)

  summaryTable <- summaryTable |>
    internalTibble() |>
    omopgenerics::newSummarisedResult(settings = createSettings(
      result_type = "summarise_omop_snapshot"
    ))

  vocab_version <- cdm$vocabulary |>
    dplyr::filter(.data$vocabulary_id == "None") |>
    dplyr::pull(.data$vocabulary_version)

  vocab_from_source <- summaryTable |>
    dplyr::filter(.data$estimate_name == "vocabulary_version") |>
    dplyr::pull(.data$estimate_value)

  if (!(isTRUE(vocab_version == vocab_from_source) ||
        (is.na(vocab_version) && is.na(vocab_from_source)))) {
    cli::cli_warn("Vocabulary version in cdm_source ({vocab_from_source}) doesn't match the one in the vocabulary table ({vocab_version})")
  }

  summaryTable <- summaryTable |>
    dplyr::mutate(estimate_value = dplyr::if_else(.data$estimate_name == "vocabulary_version", vocab_version, .data$estimate_value))

  return(summaryTable)
}

internalTibble <- function(summaryTable) {
  summaryTable |>
    dplyr::inner_join(
      dplyr::tibble(
        "variable_name" = c(
          "person_count", "snapshot_date", "vocabulary",
          "cdm", "cdm", "cdm", "cdm", "cdm", "cdm", "cdm",
          "observation_period_count", "observation_period_start_date", "observation_period_end_date"
        ),
        "estimate_name" = c(
          "count", "value", "version",
          "description", "documentation_reference", "holder_name", "release_date", "source_name", "source_type", "version",
          "count", "min", "max"
        ),
        "variable_name1" = c(
          "general", "general", "general",
          "cdm", "cdm", "cdm", "cdm", "cdm", "cdm", "cdm",
          "observation_period", "observation_period", "observation_period"
        ),
        "estimate_name1" = c(
          "person_count", "snapshot_date", "vocabulary_version",
          "description", "documentation_reference", "holder_name", "release_date", "source_name", "source_type", "version",
          "count", "start_date", "end_date"
        )
      ),
      by = c("variable_name", "estimate_name")
    ) |>
    dplyr::select(-c("variable_name", "estimate_name")) |>
    dplyr::rename("variable_name" = "variable_name1", "estimate_name" = "estimate_name1")
}
