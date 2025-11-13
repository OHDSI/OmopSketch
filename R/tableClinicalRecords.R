
#' Create a visual table from a summariseClinicalRecord() output
#'
#' @param result A summarised_result object (output of
#' `summariseClinicalRecords()`).
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
#' summarisedResult <- summariseClinicalRecords(
#'   cdm = cdm,
#'   omopTableName = c("condition_occurrence", "drug_exposure"),
#'   recordsPerPerson = c("mean", "sd"),
#'   inObservation = TRUE,
#'   standardConcept = TRUE,
#'   sourceVocabulary = TRUE,
#'   domainId = TRUE,
#'   typeConcept = TRUE
#' )
#'
#' summarisedResult |>
#'   suppress(minCellCount = 5) |>
#'   tableClinicalRecords()
#'
#' cdmDisconnect(cdm = cdm)
#' }
#'
tableClinicalRecords <- function(result,
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
      .data$result_type == "summarise_clinical_records"
    )

  # check if it is empty
  if (nrow(result) == 0) {
    warnEmpty("summarise_clinical_records")
    return(emptyTable(type))
  }
  setting_cols <- omopgenerics::settingsColumns(result)
  setting_cols <- setting_cols[!setting_cols %in% c("study_period_end", "study_period_start")]
  header <- c("cdm_name", setting_cols)
  custom_order <- c("Number records", "Number subjects", "Subjects not in person table", "Records per person", "In observation", "Domain", "Source vocabulary", "Standard concept", "Type concept id","Concept class", "Start date before birth date", "End date before start date", "Column name")
  tables <- result$group_level |> unique()
  result |>
    formatColumn(c("variable_name", "variable_level")) |>
    dplyr::mutate(variable_name = factor(.data$variable_name, levels = custom_order)) |>
    dplyr::arrange(.data$variable_name, .data$variable_level) |>
    visOmopResults::visOmopTable(
      type = type,
      style = style,
      estimateName = c(
        "N (%)" = "<count> (<percentage>%)",
        "N" = "<count>",
        "Mean (SD)" = "<mean> (<sd>)",
        "Median [Q25 - Q75]" = "<median> [<q25> - <q75>]",
        "Range [min to max]" = "[<min> to <max>]",
        "N missing data (%)" = "<na_count> (<na_percentage>%)",
        "N zeros (%)" = "<zero_count> (<zero_percentage>%)"
      ),
      header = header,
      rename = c("Database name" = "cdm_name"),
      settingsColumn = setting_cols,
      groupColumn = c("omop_table", omopgenerics::strataColumns(result)),
      .options = list(caption = paste0("Summary of ", paste(tables, collapse = ", "), ifelse(length(tables) > 1, " tables", " table"))
)
    ) |>
    suppressMessages()
}
