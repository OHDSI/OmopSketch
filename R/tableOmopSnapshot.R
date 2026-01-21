
#' Create a visual table from a summarise_omop_snapshot result
#'
#' @param result A summarised_result object (output of `summariseOmopSnapshot()`
#' ).
#' @inheritParams style-table
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
#' result <- summariseOmopSnapshot(cdm = cdm)
#'
#' tableOmopSnapshot(result = result)
#'
#' cdmDisconnect(cdm = cdm)
#' }
#'
tableOmopSnapshot <- function(result,
                              header = "cdm_name",
                              hide = "variable_level",
                              groupColumn = "variable_name",
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
      .data$result_type == "summarise_omop_snapshot"
    )

  # check if it is empty
  if (nrow(result) == 0) {
    warnEmpty("summarise_omop_snapshot")
    return(visOmopResults::emptyTable(type = type, style = style)) }

  cdms <- result$cdm_name |> unique()
  setting_cols <- omopgenerics::settingsColumns(result)
  result <- result |>
    formatColumn(c("variable_name", "estimate_name")) |>
    visOmopResults::visOmopTable(
      type = type,
      style = style,
      hide = hide,
      estimateName = c("N" = "<Count>"),
      header = header,
      rename = c(
        "Database name" = "cdm_name",
        "Estimate" = "estimate_name",
        "Variable" = "variable_name"
      ),
      groupColumn = groupColumn,
      settingsColumn = setting_cols,
      .options = list(caption = paste0("Snapshot of the cdm ", paste(cdms, collapse = ", ")))
    )

  return(result)
}

warnEmpty <- function(resultType) {
  message <- "`result` does not contain any `{resultType}` data." |>
    stringr::str_glue()
  cli::cli_warn(message = message)
  return(message)
}

formatColumn <- function(result, col) {
  col <- intersect(col, colnames(result))
  for (x in col) {
    result <- result |>
      dplyr::mutate(!!x := gsub("_", " ", stringr::str_to_sentence(.data[[x]])))
  }
  return(result)
}
