#' Create a visual table from a summariseConceptIdCounts() result.
#' @param result A summarised_result object.
#' @param type Type of formatting output table, either "gt" or "flextable".
#' @return A gt or flextable object with the summarised data.
#' @export
#'
#'
tableConceptIdCounts <- function(result,
                                 type = "gt") {
  # initial checks
  rlang::check_installed("visOmopResults")
  omopgenerics::validateResultArgument(result)
  omopgenerics::assertChoice(type, visOmopResults::tableType())
  strata_cols <- omopgenerics::strataColumns(result)
  # subset to result_type of interest
  result <- result |>
    omopgenerics::filterSettings(
      .data$result_type == "summarise_concept_id_counts"
    ) |>
    omopgenerics::splitStrata() |>
    dplyr::arrange(.data$variable_name, dplyr::across(dplyr::all_of(strata_cols)), .data$additional_level) |>
    omopgenerics::uniteStrata(strata_cols)

  # check if it is empty
  if (nrow(result) == 0) {
    warnEmpty("summarise_concept_id_counts")
    return(emptyTable(type))
  }

  estimate_names <- result |>
    dplyr::distinct(.data$estimate_name) |>
    dplyr::pull()
  estimateName <- c()
  if ("count_records" %in% estimate_names) {
    estimateName <- c(estimateName, "N records" = "<count_records>")
  }
  if ("count_subjects" %in% estimate_names) {
    estimateName <- c(estimateName, "N persons" = "<count_subjects>")
  }
  header <- c("cdm_name", "estimate_name")

  result |>
    formatColumn(c("variable_name", "variable_level")) |>
    visOmopResults::visOmopTable(
      type = type,
      estimateName = estimateName,
      header = header,
      rename = c("Database name" = "cdm_name", "Concept name" = "variable_name", "Concept id" = "variable_level"),
      groupColumn = c(omopgenerics::additionalColumns(result)),
      columnOrder = c("omop_table", "variable_name", "variable_level", strata_cols),
      .options = list(groupAsColumn = TRUE, merge = "all_columns")
    )
}
