#' Create a gt table from a summarised omop_table.
#'
#' @param result Output from summariseClinicalRecords().
#'
#' @return A gt object with the summarised data.
#'
#' @export
#' @examples
#' \donttest{
#'library(dplyr)
#'library(CDMConnector)
#'library(DBI)
#'library(duckdb)
#'library(OmopSketch)
#'
#'# Connect to a mock database
#' cdm <- mockOmopSketch()
#'
#'# Run summarise clinical tables
#' summarisedResult <- summariseClinicalRecords(cdm = cdm,
#'                                             omopTableName = "condition_occurrence",
#'                                             recordsPerPerson = c("mean", "sd"),
#'                                             inObservation = TRUE,
#'                                             standardConcept = TRUE,
#'                                             sourceVocabulary = TRUE,
#'                                             domainId = TRUE,
#'                                             typeConcept = TRUE)
#' tableClinicalRecords(summarisedResult)
#' PatientProfiles::cdmDisconnect(cdm)
#'}
tableClinicalRecords <- function(result) {

  # Initial checks ----
  omopgenerics::assertClass(result, "summarised_result")

  if(result |> dplyr::tally() |> dplyr::pull("n") == 0){
    cli::cli_warn("result is empty.")

    return(
      result |>
        visOmopResults::splitGroup() |>
        visOmopResults::formatHeader(header = "cdm_name") |>
        dplyr::select(-c("estimate_type", "result_id", "strata_name", "strata_level",
                         "additional_name", "additional_level")) |>
        dplyr::rename(
          "Variable" = "variable_name", "Level" = "variable_level",
          "Estimate" = "estimate_name"
        ) |>
        gt::gt()
    )
  }

  result |>
    visOmopResults::filterSettings(result_type == "summarise_clinical_records") |>
    visOmopResults::visOmopTable(
      formatEstimateName = c("N%" = "<count> (<percentage>)",
                             "N" = "<count>",
                             "Mean (SD)" = "<mean> (<sd>)"),
      header = c("cdm_name"),
      renameColumns = c("Database name" = "cdm_name"),
      groupColumn = c("omop_table", visOmopResults::strataColumns(result))
    )
}
