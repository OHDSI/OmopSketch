#' Summarise an omop_table from a cdm_reference object. You will obtain
#' information related to the number of records, number of subjects, whether the
#' records are in observation, number of present domains and number of present
#' concepts.
#'
#' @param omopTable An omop_table object.
#' @param recordsPerPerson Estimates to summarise the number of records per
#' person.
#' @param inObservation Whether to include the percentage of records in
#' observation.
#' @param standardConcept Whether to summarise standard concept.
#' @param sourceVocabulary Whether to summarise source concept.
#' @param domainId Whether to summarise domain id of standard concept id.
#' @param typeConcept Whether to summarise type concept id field.
#'
#' @return A summarised_result object with the summarised data.
#'
#' @export
#'
tableOmopTable <- function(summarisedOmopTable) {

  # Initial checks ----
  assertClass(summarisedOmopTable, "summarised_result")

  summarisedOmopTable |>
    omopgenerics::settings()
    dplyr::mutate(order = dplyr::case_when(
      variable_name == "number_records"  ~ 1,
      variable_name == "number_subjects" ~ 2,
      variable_name == "records_per_person" ~ 3,
      variable_name == "In observation" ~ 4,
      variable_name == "Standard concept" ~ 5,
      variable_name == "Source vocabulary" ~ 6,
      variable_name == "Domain" ~ 7,
      variable_name == "Type concept id" ~ 8
    )) |>
    dplyr::arrange(order) |>
    visOmopResults::formatEstimateValue() |>
    visOmopResults::formatEstimateName(
      estimateNameFormat = c(
        "N (%)" = "<count> (<percentage>%)",
        "N"     = "<count>",
        "median [IQR]" = "<median> [<q25> - <q75>]",
        "mean (sd)" = "<mean> (<sd>)"
      ),
      keepNotFormatted = FALSE
    ) |>
    dplyr::select(-"estimate_type") |>
    dplyr::rename(
      "Variable" = "variable_name", "Level" = "variable_level",
      "Estimate" = "estimate_name"
    ) |>
    visOmopResults::gtTable(
      groupColumn =
      colsToMergeRows = c("Variable", "Level")
    )

}
