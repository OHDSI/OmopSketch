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
  rlang::check_installed("visOmopResults")

  # initial checks
  omopgenerics::validateResultArgument(result)
  validateFacet(facet, result) # To remove when there's a version in omopgenerics

  # subset to results of interest
  result <- result |>
    omopgenerics::filterSettings(
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
                                  group = c("cdm_name", "omop_table", omopgenerics::strataColumns(result))) +
      ggplot2::labs(
        y = "Number records",
        x = "Date"
      )
    p$data <- p$data |>
      dplyr::arrange(.data$time_interval) |>
      dplyr::group_by(.data$omop_table) |>
      dplyr::mutate(
        show_label = if (dplyr::cur_group_id() == 1) {
          seq_along(.data$time_interval) %% ceiling(dplyr::n() / 20) == 0
        } else {
          FALSE
        }
      ) |>
      dplyr::ungroup()

    # Modify the plot
    p <- p +
      ggplot2::scale_x_discrete(
        breaks = p$data$time_interval[p$data$show_label],
        labels = p$data$time_interval[p$data$show_label]
      ) +
      ggplot2::theme(
        axis.text.x = ggplot2::element_text(angle = 90, hjust = 1, size = 8),
        plot.margin = ggplot2::margin(t = 5, r = 5, b = 30, l = 5)
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

