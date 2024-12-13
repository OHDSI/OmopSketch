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
  rlang::check_installed("visOmopResults")
  omopgenerics::validateResultArgument(result)
  omopgenerics::assertChoice(type, choicesTables())

  # subset to result_type of interest
  result <- result |>
    omopgenerics::filterSettings(
      .data$result_type == "summarise_missing_data")

  # check if it is empty
  if (nrow(result) == 0) {
    warnEmpty("summarise_missing_data")
    return(emptyTable(type))
  }

  result |>
    visOmopResults::visOmopTable(
      type = type,
       estimateName = c("N missing data (%)" = "<na_count> (<na_percentage>%)"),
      header = c("cdm_name"),
      rename = c("Database name" = "cdm_name", "Column name"= "variable_name"),
      groupColumn = c("omop_table", omopgenerics::strataColumns(result)),
      hide = c("variable_level")
    )
}
