#' Create a ggplot of the records' count trend.
#'
#' @param result Output from summariseRecordCount().
#' @param facet Columns to face by. Formula format can be provided. See possible
#' columns to face by with: `visOmopResults::tidyColumns()`.
#' @param colour Columns to colour by. See possible columns to colour by with:
#' `visOmopResults::tidyColumns()`.
#' @return A ggplot showing the table counts
#' @export
#' @examples
#' \donttest{
#' cdm <- mockOmopSketch()
#'
#' summarisedResult <- summariseRecordCount(
#'   cdm = cdm,
#'   omopTableName = "condition_occurrence",
#'   ageGroup = list("<=20" = c(0,20), ">20" = c(21, Inf)),
#'   sex = TRUE
#' )
#'
#' plotRecordCount(summarisedResult, colour = "age_group", facet = sex ~ .)
#'
#' PatientProfiles::mockDisconnect(cdm = cdm)
#' }
plotRecordCount <- function(result,
                            facet = NULL,
                            colour = NULL){

  rlang::check_installed("ggplot2")

  # initial checks
  omopgenerics::validateResultArgument(result)
  validateFacet(facet, result) # To remove when there's a version in omopgenerics

  # subset to results of interest
  result <- result |>
    visOmopResults::filterSettings(
      .data$result_type == "summarise_record_count")
  if (nrow(result) == 0) {
    cli::cli_abort(c("!" = "No records found with result_type == summarise_record_count"))
  }

  # Detect if there are several time intervals
  if(length(unique(result$additional_level)) > 1 ){
    # Line plot where each concept is a different line
    p <- result |>
      dplyr::filter(.data$additional_level != "overall") |>
      dplyr::filter(.data$estimate_name == "count") |>
      visOmopResults::scatterPlot(x = "time_interval",
                                  y = "count",
                                  line   = TRUE,
                                  point  = TRUE,
                                  ribbon = FALSE,
                                  facet  = facet,
                                  colour = colour,
                                  group = c("cdm_name", "omop_table", visOmopResults::strataColumns(result))) +
      ggplot2::labs(
        y = "Number records",
        x = "Date"
      )
  }else{
    p <- result |>
      visOmopResults::barPlot(x = "variable_name",
                              y = "count",
                              facet = facet,
                              colour = colour)  +
      ggplot2::labs(
        y = "Count",
        x = ""
      )
  }
  p
}
