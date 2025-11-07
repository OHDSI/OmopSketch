#' Create a visual table from a summariseMissingData() result.
#' @param result A summarised_result object.
#' @param  type Type of formatting output table. See `visOmopResults::tableType()` for allowed options. Default is `"gt"`.
#' @inheritParams style
#' @return A formatted table object with the summarised data.
#' @export
#' @examples
#' \donttest{
#' library(OmopSketch)
#' library(omock)
#' cdm <- mockCdmFromDataset(datasetName = "GiBleed", source = "duckdb")
#'
#' result <- summariseMissingData(
#'   cdm = cdm,
#'   omopTableName = c("condition_occurrence", "visit_occurrence")
#' )
#'
#' tableMissingData(result = result)
#'
#' cdmDisconnect(cdm = cdm)
#' }
tableMissingData <- function(result,
                             type = "gt",
                             style = "default") {
  # initial checks
  rlang::check_installed("visOmopResults")
  omopgenerics::validateResultArgument(result)
  omopgenerics::assertChoice(type, visOmopResults::tableType())

  # subset to result_type of interest
  result <- result |>
    omopgenerics::filterSettings(
      .data$result_type %in% c("summarise_missing_data", "summarise_clinical_records")
    ) |>
    dplyr::filter(grepl("na", .data$estimate_name) | grepl("zero", .data$estimate_name)) |>
    omopgenerics::bind(
      result |>
        omopgenerics::filterSettings(
          .data$result_type == "summarise_observation_period"
        ) |>
        dplyr::filter(grepl("na", .data$estimate_name) | grepl("zero", .data$estimate_name)) |>
        dplyr::select(!c("group_name", "group_level")) |>
        dplyr::mutate("omop_table" = "observation_period") |>
        omopgenerics::uniteGroup(cols = "omop_table") |>
        omopgenerics::newSummarisedResult()
    )

  # check if it is empty
  if (nrow(result) == 0) {
    warnEmpty("summarise_missing_data")
    return(emptyTable(type))
  }

  header <- c("cdm_name")
  tables <- result$group_level |> unique()

  result |>
    dplyr::arrange(.data$variable_level, .data$additional_level) |>
    visOmopResults::visOmopTable(
      type = type,
      style = style,
      estimateName = c(
        "N missing data (%)" = "<na_count> (<na_percentage>%)",
        "N zeros (%)" = "<zero_count> (<zero_percentage>%)"
      ),
      header = header,
      rename = c("Database name" = "cdm_name", "Column name" = "variable_level"),
      groupColumn = c("omop_table", omopgenerics::strataColumns(result)),
      hide = c("variable_name"),
      .options = list(caption = paste0("Summary of missingness in ", paste(tables, collapse = ", "), ifelse(length(tables) > 1, " tables", " table")))
    ) |>
    suppressMessages()
}
