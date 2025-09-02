#' Create a visual table from a summariseTrend() result.
#' @param result A summarised_result object.
#' @param type Type of formatting output table between `gt`, `datatable` and `reactable`. Default is `"gt"`.
#' @inheritParams style
#' @return A formatted table object with the summarised data.
#' @export
#' @examples
#' \donttest{
#' library(OmopSketch)
#' library(dplyr, warn.conflicts = FALSE)
#'
#' cdm <- mockOmopSketch()
#'
#' summarisedResult <- summariseTrend(
#'   cdm = cdm,
#'   episode = "observation_period",
#'   event = c("drug_exposure", "condition_occurrence"),
#'   interval = "years",
#'   ageGroup = list("<=20" = c(0, 20), ">20" = c(21, Inf)),
#'   sex = TRUE
#' )
#'
#' tableTrend(result = summarisedResult)
#'
#' PatientProfiles::mockDisconnect(cdm = cdm)
#' }
tableTrend <- function(result,
                       type = "gt",
                       style = "default") {
  # initial checks
  rlang::check_installed("visOmopResults")
  omopgenerics::validateResultArgument(result)
  omopgenerics::assertChoice(type, c("gt","reactable", "datatable"))
  strata_cols <- omopgenerics::strataColumns(result)
  additional_cols <- omopgenerics::additionalColumns(result)

  # subset to result_type of interest
  result <- result |>
    omopgenerics::filterSettings(
      .data$result_type == "summarise_trend"
    ) |>
    dplyr::arrange(.data$additional_level)
  additionals <- omopgenerics::additionalColumns(result)
  strata <- omopgenerics::strataColumns(result)

  # check if it is empty
  if (nrow(result) == 0) {
    warnEmpty("summarise_record_count")
    return(emptyTable(type))
  }
  formatEstimates <- c(
    "N (%)" = "<count> (<percentage>%)",
    "Median" = "<median>"
  )
  rename_vec <- c(
      "Database name" = "cdm_name",
      "OMOP table" = "omop_table"
    )
  result |> visOmopResults::visOmopTable(
    header = c("cdm_name"),
    estimateName = formatEstimates,
    settingsColumn = "type",
    groupColumn = c("type", "omop_table"),
    rename = rename_vec,
    type = type,
    style = style,
    hide = "variable_level",
    columnOrder = c("variable_name", additionals, strata, "estimate_name"),
    .options = list(merge = "all_columns")

  )|>
    suppressMessages()

}
