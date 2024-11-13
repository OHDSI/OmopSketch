#' Create a visual table from a summariseMissingData() result.
#' @param result A summarised_result object.
#' @param type Type of formatting output table, either "gt" or "flextable".
#' @return A gt or flextable object with the summarised data.
#' @export
#'
#'
tableMissingData <- function(result,
                                 type = "gt") {
  # initial checks
  omopgenerics::validateResultArgument(result)
  omopgenerics::assertChoice(type, choicesTables())

  # subset to result_type of interest
  result <- result |>
    visOmopResults::filterSettings(
      .data$result_type == "summarise_missing_data")

  # check if it is empty
  if (nrow(result) == 0) {
    warnEmpty("summarise_missing_data")
    return(emptyTable(type))
  }

  result |>
    formatColumn(c("variable_name", "variable_level")) |>
    visOmopResults::visOmopTable(
      type = type,
      estimateName = c(
        "N (%)" = "<na_percentage> (%)",
        "N" = "<na_count>"),
      header = c("cdm_name"),
      rename = c("Database name" = "cdm_name"),
      groupColumn = c("omop_table", visOmopResults::strataColumns(result))
    )
}
