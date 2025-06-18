#' Create a visual table from a summariseClinicalRecord() output.
#'
#' @param result Output from summariseClinicalRecords().
#' @param type Type of formatting output table. See `visOmopResults::tableType()` for allowed options.
#' @return A formatted table object with the summarised data.
#' @export
#' @examples
#' \donttest{
#' cdm <- mockOmopSketch()
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
#' PatientProfiles::mockDisconnect(cdm)
#' }
tableClinicalRecords <- function(result,
                                 type = "gt") {
  # initial checks
  rlang::check_installed("visOmopResults")
  omopgenerics::validateResultArgument(result)
  omopgenerics::assertChoice(type, visOmopResults::tableType())

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

  header <- c("cdm_name")
  custom_order <- c("Number records", "Number subjects", "Records per person", "In observation", "Domain", "Source vocabulary", "Standard concept", "Type concept id")
  result |>
    formatColumn(c("variable_name", "variable_level")) |>
    dplyr::mutate(variable_name = factor(.data$variable_name, levels = custom_order)) |>
    dplyr::arrange(.data$variable_name, .data$variable_level) |>
    visOmopResults::visOmopTable(
      type = type,
      estimateName = c(
        "N (%)" = "<count> (<percentage>%)",
        "N" = "<count>",
        "Mean (SD)" = "<mean> (<sd>)",
        "Median [Q25 - Q75]" = "<median> [<q25> - <q75>]",
        "Range [min to max]" = "[<min> to <max>]"
      ),
      header = header,
      rename = c("Database name" = "cdm_name"),
      groupColumn = c("omop_table", omopgenerics::strataColumns(result))
    ) |> suppressMessages()
}
