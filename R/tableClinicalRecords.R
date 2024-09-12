#' Create a gt table from a summarised omop_table.
#'
#' @param summarisedClinicalRecords Output from summariseClinicalRecords().
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
#'# Connect to Eunomia database
#'if (Sys.getenv("EUNOMIA_DATA_FOLDER") == "") Sys.setenv("EUNOMIA_DATA_FOLDER" = tempdir())
#'if (!dir.exists(Sys.getenv("EUNOMIA_DATA_FOLDER"))) dir.create(Sys.getenv("EUNOMIA_DATA_FOLDER"))
#'if (!eunomia_is_available()) downloadEunomiaData()
#'con <- DBI::dbConnect(duckdb::duckdb(), CDMConnector::eunomia_dir())
#'cdm <- CDMConnector::cdmFromCon(
#' con = con, cdmSchema = "main", writeSchema = "main"
#')
#'
#'# Run summarise clinical tables
#'summarisedResult <- summariseClinicalRecords(cdm = cdm,
#'                                             omopTableName = "condition_occurrence",
#'                                             recordsPerPerson = c("mean", "sd"),
#'                                             inObservation = TRUE,
#'                                             standardConcept = TRUE,
#'                                             sourceVocabulary = TRUE,
#'                                             domainId = TRUE,
#'                                             typeConcept = TRUE)
#'tableClinicalRecords(summarisedResult)
#'}
tableClinicalRecords <- function(summarisedClinicalRecords) {

  # Initial checks ----
  assertClass(summarisedClinicalRecords, "summarised_result")

  if(summarisedClinicalRecords |> dplyr::tally() |> dplyr::pull("n") == 0){
    cli::cli_warn("summarisedClinicalRecords is empty.")

    return(
      summarisedClinicalRecords |>
      visOmopResults::splitGroup() |>
      visOmopResults::formatHeader(header = "cdm_name") |>
      dplyr::select(-c("estimate_type", "result_id",
                       "additional_name", "additional_level",
                       "strata_name", "strata_level")) |>
      dplyr::rename(
        "Variable" = "variable_name", "Level" = "variable_level",
        "Estimate" = "estimate_name"
      ) |>
      gt::gt()
    )
  }

  t <- summarisedClinicalRecords |>
    dplyr::mutate(order = dplyr::case_when(
      variable_name == "Number of subjects"  ~ 1,
      variable_name == "Number of records" ~ 2,
      variable_name == "Records per person" ~ 3,
      variable_name == "In observation" ~ 4,
      variable_name == "Standard concept" ~ 5,
      variable_name == "Source vocabulary" ~ 6,
      variable_name == "Domain" ~ 7,
      variable_name == "Type concept id" ~ 8
    )) |>
    dplyr::arrange(order, dplyr::desc(as.numeric(.data$estimate_value))) |>
    visOmopResults::splitGroup() |>
    visOmopResults::formatEstimateValue() |>
    visOmopResults::formatEstimateName(
      estimateNameFormat = c(
        "N (%)" = "<count> (<percentage>%)",
        "N"     = "<count>",
        "median [IQR]" = "<median> [<q25> - <q75>]",
        "mean (sd)" = "<mean> (<sd>)"
      ),
      keepNotFormatted = TRUE
    ) |>
    suppressMessages() |>
    visOmopResults::formatHeader(header = "cdm_name") |>
    dplyr::select(-c("estimate_type", "order","result_id",
                     "additional_name", "additional_level",
                     "strata_name", "strata_level")) |>
    dplyr::rename(
      "Variable" = "variable_name", "Level" = "variable_level",
      "Estimate" = "estimate_name"
    )

  names <- t |> colnames()

  t |>
    visOmopResults::gtTable(
      groupColumn = "omop_table",
      colsToMergeRows = c("Variable", "Level")
    ) |>
    gt::tab_style(
      style = gt::cell_borders(
        sides = c("left"),
        color = NULL,
        style = "solid",
        weight = gt::px(2)
      ),
      locations = list(
        gt::cells_body(
          columns = .data$Variable,
          rows = gt::everything()
        )
      )
    ) |>
    gt::tab_style(
      style = gt::cell_borders(
        sides = c("right"),
        color = NULL,
        style = "solid",
        weight = gt::px(2)
      ),
      locations = list(
        gt::cells_body(
          columns = names[length(names)],
          rows = gt::everything()
        )
      )
    )

}
