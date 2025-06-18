#' Create a ggplot2 plot from the output of summariseInObservation().
#'
#' @param result A summarised_result object (output of summariseInObservation).
#' @param facet Columns to face by. Formula format can be provided. See possible
#' columns to face by with: `visOmopResults::tidyColumns()`.
#' @param colour Columns to colour by. See possible columns to colour by with:
#' `visOmopResults::tidyColumns()`.
#' @return A ggplot showing the table counts
#' @export
#' @examples
#' \donttest{
#' library(dplyr)
#'
#' cdm <- mockOmopSketch()
#'
#' result <- summariseInObservation(
#'   observationPeriod = cdm$observation_period,
#'   output = c("person-days","record"),
#'   ageGroup = list("<=40" = c(0, 40), ">40" = c(41, Inf)),
#'   sex = TRUE
#' )
#'
#' result |>
#'   filter(variable_name == "Number person-days") |>
#'   plotInObservation(facet = "sex", colour = "age_group")
#'
#' PatientProfiles::mockDisconnect(cdm)
#' }
plotInObservation <- function(result,
                              facet = NULL,
                              colour = NULL) {
  rlang::check_installed("ggplot2")

  # initial checks
  omopgenerics::validateResultArgument(result)
  validateFacet(facet, result) # To remove when there's a version in omopgenerics

  # subset to results of interest
  result <- result |>
    omopgenerics::filterSettings(
      .data$result_type == "summarise_in_observation"
    )
  if (nrow(result) == 0) {
    cli::cli_abort(c("!" = "No records found with result_type == summarise_in_observation"))
  }

  # check only one variable is contained
  variable <- unique(result$variable_name)
  if (length(variable) > 1) {
    cli::cli_abort(c(
      "!" = "Subset to the variable of interest, there are results from: {variable}.",
      "i" = "result |> dplyr::filter(variable_name == '{variable[1]}')"
    ))
  }
  estimate <- unique(result$estimate_name)
  estimate <- estimate[estimate != "percentage"]
  # warn
  warnFacetColour(result, list(facet = asCharacterFacet(facet), colour = colour, "additional_level"))

  # plot
  if (length(unique(result$additional_level)) > 1) {
    p <- result |>
      dplyr::filter(.data$additional_level != "overall") |>
      dplyr::filter(.data$estimate_name == estimate) |>
      visOmopResults::scatterPlot(
        x = "time_interval",
        y = estimate,
        line = TRUE,
        point = TRUE,
        ribbon = FALSE,
        ymin = NULL,
        ymax = NULL,
        facet = facet,
        colour = colour,
        group = c("cdm_name", "omop_table", omopgenerics::strataColumns(result))
      ) +
      ggplot2::labs(
        y = variable,
        x = "Date"
      )
    p$data <- p$data |>
      dplyr::arrange(.data$time_interval) |>
      dplyr::mutate(
        show_label = seq_along(.data$time_interval) %% ceiling(nrow(p$data) / 20) == 0
      )

    p <- p +
      ggplot2::scale_x_discrete(
        breaks = p$data$time_interval[p$data$show_label]
      ) +
      ggplot2::theme(
        axis.text.x = ggplot2::element_text(angle = 90, hjust = 1, size = 8),
        plot.margin = ggplot2::margin(t = 5, r = 5, b = 30, l = 5)
      )
    p
  } else {
    result |>
      dplyr::filter(.data$estimate_name == estimate) |>
      visOmopResults::barPlot(
        x = "variable_name",
        y = estimate,
        facet = facet,
        colour = colour
      )
  }
}
