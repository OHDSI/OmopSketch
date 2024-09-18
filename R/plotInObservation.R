
#' Create a gt table from a summarised omop_table.
#'
#' @param result A summarised_result object (output of summariseInObservation).
#' @param facet Columns to face by. Formula format can be provided. See possible
#' columns to face by with: `visOmopResults::tidyColumns()`.
#' @param colour Columns to colour by. See possible columns to colour by with:
#' `visOmopResults::tidyColumns()`.
#'
#' @return A ggplot showing the table counts
#'
#' @export
#' @examples
#'
#' \dontrun{
#' library(OmopSketch)
#' library(dplyr)
#'
#' cdm <- mockOmopSketch()
#'
#' result <- summariseInObservation(cdm$observation_period,
#'                     unit = "month",
#'                     unitInterval = 6,
#'                     output = c("person-days","records"),
#'                     ageGroup = list("<=60" = c(0,60), ">60" = c(61, Inf)),
#'                     sex = TRUE)
#'
#' plotInObservation(result)
#'
#' PatientProfiles::mockDisconnect(cdm)
#' }
plotInObservation <- function(result,
                              facet = NULL,
                              colour = NULL) {
  # initial checks
  omopgenerics::validateResultArgument(result)
  validateFacet(facet) # To remove when there's a version in omopgenerics

  # subset to results of interest
  result <- result |>
    visOmopResults::filterSettings(
      .data$result_type == "summarise_in_observation")
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
      y = variable,
      x = "Date"
    )
}
