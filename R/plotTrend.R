#' Create a ggplot2 plot from the output of summariseTrend().
#'
#' @param result A summarised_result object (output of summariseTrend).
#' @param output The output to plot.  Accepted values are: `"record"`, `"person"`,
#'  `"person-days"`, `"age"`, and `"sex"`.
#'  If not specified, the function will default to:
#'   - the only available output if there is just one in the results, or
#'   - `"record"` if multiple outputs are present.
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
#' result <- summariseTrend(cdm
#'   episode = "observation_period",
#'   output = c("person-days","record"),
#'   interval = "years",
#'   ageGroup = list("<=40" = c(0, 40), ">40" = c(41, Inf)),
#'   sex = TRUE
#' )
#'
#' plotTrend(result, output = "record", colour = "sex", facet = "age_group")
#'
#'
#' PatientProfiles::mockDisconnect(cdm)
#' }
plotTrend <- function(result,
                      output = NULL,
                      facet = "type",
                      colour = NULL) {

  rlang::check_installed("ggplot2")
  rlang::check_installed("visOmopResults")
  # initial checks
  omopgenerics::validateResultArgument(result)
  validateFacet(facet, result) # To remove when there's a version in omopgenerics
  available_output <- fromVariableNameToOutput(unique(result$variable_name))
  if (is.null(output)){
    if (length(available_output) == 1){
      output <- available_output
    } else{
      output <- "record"
    }
  }
  omopgenerics::assertChoice(output, choices = available_output, length = 1L)
  # subset to results of interest
  variableName <- fromOutputToVariableName(output = output)
  result <- result |>
    omopgenerics::filterSettings(
      .data$result_type == "summarise_trend"
    ) |>
    dplyr::filter(variable_name == variableName) |>
    omopgenerics::addSettings(settingsColumn = "type")
  if (nrow(result) == 0) {
    cli::cli_abort(c("!" = "No records found with result_type == summarise_trend"))
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
        y = variableName,
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
fromOutputToVariableName <- function(output){
  if (output == "record") {
    return("Records in observation")
  } else if(output == "person") {
    return("Subjects in observation")
  } else if(output == "person-days"){
    return("Person-days")
  } else if(output == "age") {
    return("Age in observation")
  } else if (output == "sex"){
    return("Females in observation")
  }
}
fromVariableNameToOutput <- function(variableName) {
  output <- c()
  if ("Records in observation" %in% variableName) {
    output <- c(output, "record")
  }
  if ("Subjects in observation" %in% variableName) {
    output <- c(output, "person")
  }
  if ("Person-days" %in% variableName) {
    output <- c(output, "person-days")
  }
  if ("Age in observation" %in% variableName) {
    output <- c(output, "age")
  }
  if ("Females in observation" %in% variableName) {
    output <- c(output, "sex")
  }
  return(output)
}

