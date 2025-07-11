#' Create a visual table from a summariseMissingData() result.
#' @param result A summarised_result object.
#' @param  type Type of formatting output table. See `visOmopResults::tableType()` for allowed options. Default is `"gt"`.
#' @return A formatted table object with the summarised data.
#' @export
#' @examples
#' \donttest{
#' cdm <- mockOmopSketch(numberIndividuals = 100)
#'
#' result <- summariseMissingData(cdm = cdm,
#' omopTableName = c("condition_occurrence", "visit_occurrence"))
#'
#' tableMissingData(result = result)
#'
#' PatientProfiles::mockDisconnect(cdm = cdm)
#' }
tableMissingData <- function(result,
                             type = "gt") {
  # initial checks
  rlang::check_installed("visOmopResults")
  omopgenerics::validateResultArgument(result)
  omopgenerics::assertChoice(type, visOmopResults::tableType())

  # subset to result_type of interest
  result <- result |>
    omopgenerics::filterSettings(
      .data$result_type == "summarise_missing_data"
    )

  # check if it is empty
  if (nrow(result) == 0) {
    warnEmpty("summarise_missing_data")
    return(emptyTable(type))
  }

  header <- c("cdm_name")

  result |>
    visOmopResults::visOmopTable(
      type = type,
      estimateName = c("N missing data (%)" = "<na_count> (<na_percentage>%)",
                       "N zeros (%)" = "<zero_count> (<zero_percentage>%)"),
      header = header,
      rename = c("Database name" = "cdm_name", "Column name" = "variable_name"),
      groupColumn = c("omop_table", omopgenerics::strataColumns(result)),
      hide = c("variable_level")
    ) |> suppressMessages()
}
