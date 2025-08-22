#' Summarise a cdm_reference object creating a snapshot with the metadata of the
#' cdm_reference object.
#'
#' @param cdm A cdm_reference object.
#' @return A summarised_result object.
#' @export
#' @examples
#' \donttest{
#' library(OmopSketch)
#'
#' cdm <- mockOmopSketch(numberIndividuals = 10)
#'
#' summariseOmopSnapshot(cdm = cdm)
#' }
summariseOmopSnapshot <- function(cdm) {
  rlang::check_installed(pkg = "omopgenerics", version = "1.3.0")

  # initial checks
  cdm <- omopgenerics::validateCdmArgument(cdm)

  # extract information from cdm object
  result <- summary(cdm) |>
    dplyr::select(
      "variable_name", "estimate_name", "estimate_type", "estimate_value"
    ) |>
    # update names
    dplyr::left_join(
      dplyr::tribble(
        ~variable_name, ~estimate_name, ~new_variable_name, ~new_estimate_name,
        "person_count", "count", "general", "person_count",
        "snapshot_date", "value", "general", "snapshot_date",
        "vocabulary", "version", "general", "vocabulary_version",
        "observation_period_count", "count", "observation_period", "count",
        "observation_period_start_date", "min", "observation_period", "start_date",
        "observation_period_end_date", "max", "observation_period", "end_date"
      ),
      by = c("variable_name", "estimate_name")
    ) |>
    dplyr::mutate(
      variable_name = dplyr::coalesce(.data$new_variable_name, .data$variable_name),
      estimate_name = dplyr::coalesce(.data$new_estimate_name, .data$estimate_name)
    ) |>
    dplyr::filter(.data$estimate_name != "source_type") |>
    dplyr::select(!c("new_variable_name", "new_estimate_name")) |>
    # add source information
    dplyr::union_all(
      summary(omopgenerics::cdmSource(x = cdm)) |>
        purrr::map(\(x) dplyr::tibble(estimate_value = x)) |>
        dplyr::bind_rows(.id = "estimate_name") |>
        dplyr::mutate(variable_name = "cdm_source", estimate_type = "character")
    ) |>
    # order result
    dplyr::mutate(order_id = dplyr::case_when(
      .data$variable_name == "general" ~ 1L,
      .data$variable_name == "cdm" ~ 2L,
      .data$variable_name == "observation_period" ~ 3L,
      .data$variable_name == "cdm_source" ~ 4L,
      .default = NA_integer_
    )) |>
    dplyr::arrange(.data$order_id) |>
    dplyr::select(!"order_id") |>
    # build summarised_result
    dplyr::mutate(
      result_id = 1L,
      variable_level = NA_character_,
      cdm_name = omopgenerics::cdmName(x = cdm)
    ) |>
    omopgenerics::uniteGroup() |>
    omopgenerics::uniteStrata() |>
    omopgenerics::uniteAdditional() |>
    omopgenerics::newSummarisedResult(settings = createSettings(
      result_type = "summarise_omop_snapshot"
    ))

  vocab_version <- cdm$vocabulary |>
    dplyr::filter(.data$vocabulary_id == "None") |>
    dplyr::pull("vocabulary_version")

  vocab_from_source <- result$estimate_value[result$estimate_name == "vocabulary_version"]

  if (!identical(vocab_version, vocab_from_source)) {
    cli::cli_warn(c(
      x = "Vocabulary version in `cdm_source` ({.emph {vocab_from_source}}) doesn't match the one in the `vocabulary` table ({.emph {vocab_version}})."
    ))
  }

  # update vocabulary version
  result$estimate_value[result$estimate_name == "vocabulary_version"] <- vocab_version

  return(result)
}
