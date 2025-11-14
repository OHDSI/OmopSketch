
#' Create a visual table from a summariseTrend() result
#'
#' @param result A summarised_result object (output of `summariseTrend()`).
#' @param type Type of formatting output table between `gt`, `datatable` and
#' `reactable`. Default is `"gt"`.
#' @inheritParams style-table
#'
#' @return A formatted table visualisation.
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
#' result <- summariseTrend(
#'   cdm = cdm,
#'   episode = "observation_period",
#'   event = c("drug_exposure", "condition_occurrence"),
#'   interval = "years",
#'   ageGroup = list("<=20" = c(0, 20), ">20" = c(21, Inf)),
#'   sex = TRUE
#' )
#'
#' tableTrend(result = result)
#'
#' cdmDisconnect(cdm = cdm)
#' }
#'
tableTrend <- function(result,
                       type = NULL,
                       style = NULL) {
  # initial checks
  rlang::check_installed("visOmopResults")
  omopgenerics::validateResultArgument(result)
  style <- validateStyle(style = style, obj = "table")

  type <- validateType(type)


  # subset to result_type of interest
  result <- result |>
    omopgenerics::filterSettings(
      .data$result_type == "summarise_trend"
    ) |>
    dplyr::arrange(.data$variable_name, .data$additional_level)

  # check if it is empty
  if (nrow(result) == 0) {
    warnEmpty("summarise_trend")
    return(emptyTable(type))
  }

  additionals <- omopgenerics::additionalColumns(result)
  strata <- omopgenerics::strataColumns(result)
  setting_cols <- omopgenerics::settingsColumns(result)
  setting_cols <- setting_cols[!setting_cols %in% c("study_period_end", "study_period_start", "interval")]

  formatEstimates <- c(
    "N (%)" = "<count> (<percentage>%)",
    "Median" = "<median>"
  )
  rename_vec <- c(
    "Database name" = "cdm_name",
    "OMOP table" = "omop_table"
  )
  variables <- result$variable_name |> unique()
  time <- omopgenerics::settings(result) |> dplyr::pull(.data$interval) |> unique()
  tables <- result$group_level |> unique()
  result |>
    visOmopResults::visOmopTable(
      header = c("cdm_name", setting_cols[setting_cols!= "type"]),
      estimateName = formatEstimates,
      groupColumn = c("type", "omop_table"),
      rename = rename_vec,
      type = type,
      style = style,
      hide = "variable_level",
      settingsColumn = setting_cols,
      columnOrder = c("variable_name", additionals, strata, "estimate_name"),
      .options = list(merge = "all_columns",
                      caption = paste0("Summary of ",
                                       paste(variables, collapse = ", "), ifelse(time != "overall", paste0(" by ", time), ""),
                                       " in ", paste(tables, collapse = ", "), ifelse(length(tables) > 1, " tables", " table")))
    ) |>
    suppressMessages()
}
