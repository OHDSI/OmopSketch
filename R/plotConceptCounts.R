#' Title
#'
#' @param result A summarised_result object (output of summariseInObservation).
#' @param facet Columns to face by. Formula format can be provided. See possible
#' columns to face by with: `visOmopResults::tidyColumns()`.
#' @param colour Columns to colour by. See possible columns to colour by with:
#' `visOmopResults::tidyColumns()`.
#'
#' @return A ggplot showing the concept counts
#' @export
#'
#' @examples
#' \dontrun{
#' library(OmopSketch)
#' library(dplyr)
#'
#' con <- DBI::dbConnect(duckdb::duckdb(),
#'                       dbdir = CDMConnector::eunomia_dir())
#' cdm <- CDMConnector::cdm_from_con(con,
#'                                   cdm_schem = "main",
#'                                   write_schema = "main")
#'
#' results <- summariseConceptCounts(cdm,
#'          conceptId = list(poliovirus_vaccine = c(40213160)))
#'
#' plotConceptCounts(result)
#'
#' PatientProfiles::mockDisconnect(cdm)
#' }
plotConceptCounts <- function(result,
                              facet = NULL,
                              colour = NULL){
  # initial checks
  omopgenerics::validateResultArgument(result)

  # subset to results of interest
  result <- result |>
    visOmopResults::filterSettings(.data$result_type == "summarise_concept_counts")
  if (nrow(result) == 0) {
    cli::cli_abort(c("!" = "No records found with result_type == summarise_in_observation"))
  }

  # check only one estimate is contained
  estimate <- unique(result$estimate_name)
  if (length(estimate) > 1) {
    cli::cli_abort(c(
      "!" = "Subset to the estimate of interest, there are results from: {estimate}.",
      "i" = "result |> dplyr::filter(estimate_name == '{estimate[1]}')"
    ))
  }

  result |>
    visOmopResults::tidy() |>
    visOmopResults::barPlot(x = "variable_name",
                            y = "record_count",
                            facet = facet,
                            colour = colour) +
    ggplot2::labs(
      x = "Concept name"
    ) +
    ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 90, vjust = 0.5, hjust = 1))
}
