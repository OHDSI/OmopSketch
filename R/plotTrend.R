
#' Create a ggplot2 plot from the output of summariseTrend()
#'
#' @param result A summarised_result object (output of `summariseTrend()`).
#' @param output The output to plot.  Accepted values are: `"record"`, `"person"`,
#'  `"person-days"`, `"age"`, and `"sex"`.
#'  If not specified, the function will default to:
#'  - the only available output if there is just one in the results, or
#'  - `"record"` if multiple outputs are present.
#' @inheritParams consistent-doc
#' @inheritParams plot-doc
#'
#' @return A plot visualisation.
#' @export
#'
#' @examples
#' \donttest{
#' library(dplyr)
#' library(OmopSketch)
#' library(omock)
#'
#' cdm <- mockCdmFromDataset(datasetName = "GiBleed", source = "duckdb")
#'
#' result <- summariseTrend(cdm,
#'   episode = "observation_period",
#'   output = c("person-days", "record"),
#'   interval = "years",
#'   ageGroup = list("<=40" = c(0, 40), ">40" = c(41, Inf)),
#'   sex = TRUE
#' )
#'
#' plotTrend(
#'   result = result,
#'   output = "record",
#'   colour = "sex",
#'   facet = "age_group"
#' )
#'
#' cdmDisconnect(cdm = cdm)
#' }
#'
plotTrend <- function(result,
                      output = NULL,
                      facet = "type",
                      colour = NULL,
                      style = NULL) {
  rlang::check_installed("ggplot2")
  rlang::check_installed("visOmopResults")
  # initial checks
  omopgenerics::validateResultArgument(result)
  validateFacet(facet, result) # To remove when there's a version in omopgenerics

   result <- result |>
    omopgenerics::filterSettings(
      .data$result_type == "summarise_trend"
    )
   # check if it is empty
   if (nrow(result) == 0) {
     warnEmpty("summarise_trend")
     return(visOmopResults::emptyPlot(subtitle = "`result` does not contain any `summarise_trend` data", style = style))
   }

  available_output <- fromVariableNameToOutput(unique(result$variable_name))
  if (is.null(output)) {
    if (length(available_output) == 1) {
      output <- available_output
    } else if (length(available_output) > 1) {
      return(visOmopResults::emptyPlot(subtitle = "Trying to plot multiple outputs at the same time.
                                       \n Please select one using the `output` argument or filter results.",
                                       style = style))
    } else {
      output <- "record"
    }
  }
  omopgenerics::assertChoice(output, choices = available_output, length = 1L)
  style <- validateStyle(style = style, obj = "plot")

  # subset to results of interest
  variableName <- fromOutputToVariableName(output = output)
  result <- result |>
    dplyr::filter(.data$variable_name == variableName) |>
    omopgenerics::addSettings(settingsColumn = "type")

  if (nrow(result) == 0) {
    return(visOmopResults::emptyPlot(subtitle = "No results found with for output {output}", style = style))
  }

  estimate <- unique(result$estimate_name)
  estimate <- estimate[estimate != "percentage"]
  # warn
  warnFacetColour(result, list(facet = asCharacterFacet(facet), colour = colour, "additional_level"))

  # --- Add automatic title with interval ---
  vars <- c(facet, colour)
  vars <- vars[vars != "" & vars != "type"]

  if (length(vars) > 0) {
    clean_vars <- stringr::str_to_sentence(gsub("[-_]", " ", vars))
    by_part <- paste("by", paste(clean_vars, collapse = " and "))
  } else by_part <- ""



  # plot
  if (length(unique(result$additional_level)) > 1) {
    interval_type <- omopgenerics::settings(result)$interval |> unique()

      if (grepl("year", interval_type)) {
        interval_label <- "Yearly"
      } else if (grepl("month", interval_type)) {
        interval_label <- "Monthly"
      } else if (grepl("quarter", interval_type)) {
        interval_label <- "Quarterly"
      } else {
        interval_label <- NA_character_
      }

    title_text <- paste(interval_label, "trend of", variableName, by_part)

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
        style = style,
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

  } else {
    title_text <- paste(variableName, by_part)
    p <- result |>
      dplyr::filter(.data$estimate_name == estimate) |>
      visOmopResults::barPlot(
        width = 0.8,
        x = "variable_name",
        y = estimate,
        facet = facet,
        colour = colour,
        style = style
      )
  }
  p + ggplot2::labs(title = stringr::str_squish(title_text)) +
    ggplot2::theme(plot.title = ggplot2::element_text(hjust = 0.5, face = "bold"),
                   legend.position = "top")

}
fromOutputToVariableName <- function(output) {
  if (output == "record") {
    return("Number of records")
  } else if (output == "person") {
    return("Number of subjects")
  } else if (output == "person-days") {
    return("Person-days")
  } else if (output == "age") {
    return("Age")
  } else if (output == "sex") {
    return("Number of females")
  }
}
fromVariableNameToOutput <- function(variableName) {
  output <- c()
  if ("Number of records" %in% variableName) {
    output <- c(output, "record")
  }
  if ("Number of subjects" %in% variableName) {
    output <- c(output, "person")
  }
  if ("Person-days" %in% variableName) {
    output <- c(output, "person-days")
  }
  if ("Age" %in% variableName) {
    output <- c(output, "age")
  }
  if ("Number of females" %in% variableName) {
    output <- c(output, "sex")
  }
  return(output)
}
