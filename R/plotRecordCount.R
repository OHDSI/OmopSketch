#' Create a ggplot of the records' count trend.
#'
#' @param result Output from summariseRecordCount().
#' @param facet Columns to face by. Formula format can be provided. See possible
#' columns to face by with: `visOmopResults::tidyColumns()`.
#' @param colour Columns to colour by. See possible columns to colour by with:
#' `visOmopResults::tidyColumns()`.
#'
#' @return A ggplot showing the table counts
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
#'summarisedResult <- summariseRecordCount(cdm = cdm,
#'                                          omopTableName = "condition_occurrence",
#'                                          unit = "year",
#'                                          unitInterval = 10,
#'                                          ageGroup = list("<=20" = c(0,20), ">20" = c(21, Inf)),
#'                                          sex = TRUE)
#'plotRecordCount(summarisedResult, facet = sex + age_group ~ .)
#'PatientProfiles::mockDisconnect(cdm = cdm)
#'}
plotRecordCount <- function(result,
                            facet = NULL,
                            colour = NULL){
  # initial checks
  omopgenerics::validateResultArgument(result)

  # subset to results of interest
  result <- result |>
    visOmopResults::filterSettings(
      .data$result_type == "summarise_record_count")
  if (nrow(result) == 0) {
    cli::cli_abort(c("!" = "No records found with result_type == summarise_record_count"))
  }

  # plot
  result |>
    dplyr::mutate(variable_level = as.Date(stringr::str_extract(
      .data$variable_level, "^[^ to]+"))) |>
    dplyr::filter(.data$estimate_name == "count") |>
    visOmopResults::scatterPlot(
      x = "variable_level",
      y = "count",
      line = TRUE,
      point = TRUE,
      ribbon = FALSE,
      ymin = NULL,
      ymax = NULL,
      facet = facet,
      colour = colour,
      group = c("cdm_name", "omop_table", visOmopResults::strataColumns(result))
    ) +
    ggplot2::labs(
      y = "Incident records",
      x = "Date"
    )
}
