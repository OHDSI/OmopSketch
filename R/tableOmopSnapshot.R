
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
    return(emptyTable(type))
  }

  setting_cols <- omopgenerics::settingsColumns(result)
  setting_cols <- setting_cols[!setting_cols %in% c("study_period_end", "study_period_start")]

  header <- c("cdm_name", setting_cols)
  cdms <- result$cdm_name |> unique()
  result <- result |>
    formatColumn(c("variable_name", "estimate_name")) |>
    visOmopResults::visOmopTable(
      type = type,
      style = style,
      hide = c("variable_level"),
      estimateName = c("N" = "<Count>"),
      header = header,
      rename = c(
        "Database name" = "cdm_name",
        "Estimate" = "estimate_name",
        "Variable" = "variable_name"
      ),
      groupColumn = "variable_name",
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
emptyTable <- function(type) {
  pkg <- type
  pkg[pkg == "tibble"] <- "dplyr"
  pkg[pkg == "datatable"] <- "DT"
  rlang::check_installed(pkg = pkg)
  x <- dplyr::tibble(`Table has no data` = character())
  switch(type,
    "tibble" = x,
    "gt" = gt::gt(x),
    "flextable" = flextable::flextable(x),
    "DT" = DT::datatable(x),
    "reactable" = reactable::reactable(x)
  )
}

formatColumn <- function(result, col) {
  col <- intersect(col, colnames(result))
  for (x in col) {
    result <- result |>
      dplyr::mutate(!!x := gsub("_", " ", stringr::str_to_sentence(.data[[x]])))
  }
  return(result)
}
