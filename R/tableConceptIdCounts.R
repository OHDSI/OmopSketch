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
  omopgenerics::assertChoice(type, choicesTables())

  # subset to result_type of interest
  result <- result |>
    omopgenerics::filterSettings(
      .data$result_type == "summarise_all_concept_counts")

  # check if it is empty
  if (nrow(result) == 0) {
    warnEmpty("summarise_all_concept_counts")
    return(emptyTable(type))
  }

  estimate_names <- result |>
    dplyr::distinct(.data$estimate_name) |>
    dplyr::pull()
  estimateName <- c()
  if ("record_count" %in% estimate_names) {
    estimateName <- c(estimateName, "N records" = "<record_count>")
  }
  if ("person_count" %in% estimate_names) {
    estimateName <- c(estimateName, "N persons" = "<person_count>")
  }

  result |>
    formatColumn(c("variable_name", "variable_level")) |>
    visOmopResults::visOmopTable(
      type = type,
      estimateName = estimateName,
        header = c("cdm_name"),
        rename = c("Database name" = "cdm_name"),
        groupColumn = c("omop_table", omopgenerics::strataColumns(result))
      )
}
