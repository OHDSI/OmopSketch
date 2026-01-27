
#' Create a plot from the output of summariseObservationPeriod()
#'
#' @param result A summarised_result object (output of
#' `summariseObservationPeriod()`).
#' @param variableName The variable to plot it can be: "Number subjects",
#' "Records per person", "Duration in days" or
#' "Days to next observation period".
#' @param plotType The plot type, it can be: "barplot", "boxplot" or
#' "densityplot".
#' @inheritParams consistent-doc
#' @inheritParams plot-doc
#'
#' @return A plot visualisation.
#' @export
#'
#' @inherit summariseObservationPeriod examples
#'
plotObservationPeriod <- function(result,
                                  variableName = "Number subjects",
                                  plotType = "barplot",
                                  facet = NULL,
                                  colour = NULL,
                                  style = NULL,
                                  type = NULL) {
  rlang::check_installed("ggplot2")
  rlang::check_installed("visOmopResults")
  # initial checks
  omopgenerics::validateResultArgument(result)
  style <- validateStyle(style = style, obj = "plot")
  omopgenerics::assertChoice(type, choices = visOmopResults::plotType(), length = 1, null = TRUE)

  # subset to result_type of interest
  result <- result |>
    omopgenerics::filterSettings(
      .data$result_type == "summarise_observation_period"
    )

  # check if it is empty
  if (nrow(result) == 0) {
    warnEmpty("summarise_observation_period")
    return(visOmopResults::emptyPlot(title = "`result` does not contain any `summarise_observation_period` data", style = style, type = type))
  }

  variableNames <- unique(availablePlotObservationPeriod()$variable_name)
  omopgenerics::assertChoice(variableName, variableNames, length = 1)
  plotTypes <- availablePlotObservationPeriod() |>
    dplyr::filter(.data$variable_name == .env$variableName) |>
    dplyr::pull("plot_type")
  omopgenerics::assertChoice(plotType, plotTypes, length = 1)

  result <- result |>
    dplyr::filter(.data$variable_name == .env$variableName)

  validateFacet(facet, result)

  optFacetColour <- c(
    "cdm_name", "observation_period_ordinal",
    omopgenerics::strataColumns(result)
  )
  omopgenerics::assertChoice(facet, optFacetColour, null = TRUE)

  # this is due to bug in visOmopResults to remove in next release
  # https://github.com/darwin-eu/visOmopResults/issues/246
  if (length(facet) == 0) facet <- NULL
  if (length(colour) == 0) colour <- NULL

  if (length(omopgenerics::groupColumns(result)) == 0) {
    result <- result |>
      dplyr::mutate(group_name = "observation_period_ordinal")
  }

  main_title <- paste0(
    stringr::str_to_sentence(variableName),
    " (", stringr::str_to_sentence(plotType), ") in observation_period "
  )


  # combine facet and colour names
  vars <- c(colour, facet)
  vars <- vars[vars != ""]

  if (length(vars) > 0) {
    # clean names: replace "_" or "-" with space and title case
    clean_vars <- stringr::str_to_sentence(gsub("[-_]", " ", vars))
    main_title <- paste(main_title, "by", paste(clean_vars, collapse = " and "))
  }

  if (plotType == "barplot") {
    p <- visOmopResults::barPlot(
      result = result,
      x = "observation_period_ordinal",
      y = "count",
      facet = facet,
      colour = colour,
      style = style,
      width = 0.8,
      type = "ggplot"
    )  +
      ggplot2::ylab(stringr::str_to_sentence(unique(result$variable_name)))
  } else if (plotType == "boxplot") {
    p <- visOmopResults::boxPlot(
      result = result,
      x = "observation_period_ordinal",
      facet = facet,
      colour = colour,
      style = style,
      type = "ggplot"
    )
  } else if (plotType == "densityplot") {
    p <- visOmopResults::scatterPlot(
      result = result,
      x = "density_x",
      y = "density_y",
      line = TRUE,
      point = FALSE,
      ribbon = FALSE,
      facet = facet,
      colour = colour,
      group = optFacetColour,
      style = style,
      type = "ggplot"
    ) +
      ggplot2::xlab(stringr::str_to_sentence(unique(result$variable_name))) +
      ggplot2::ylab("Density")
  }
  p$data <- p$data |>
    dplyr::mutate(
      observation_period_order = dplyr::if_else(
        .data$observation_period_ordinal == "all",
        0,
        as.numeric(gsub("\\D", "", .data$observation_period_ordinal))
      )
    ) |>
    dplyr::mutate(
      observation_period_ordinal = factor(
        .data$observation_period_ordinal,
        levels = unique(.data$observation_period_ordinal[order(.data$observation_period_order)])
      )
    )
  p <- p +
    ggplot2::theme(legend.position = "top") +
    ggplot2::labs(title = main_title) +
    ggplot2::theme(plot.title = ggplot2::element_text(hjust = 0.5, face = "bold"))


  if(identical(type, "plotly")) {
    rlang::check_installed("plotly")
    p <- plotly::ggplotly(p)
  }
  return(p)
}

availablePlotObservationPeriod <- function() {
  dplyr::tribble(
    ~variable_name, ~plot_type, ~facet,
    "Number subjects", "barplot", "cdm_name+observation_period_ordinal",
    "Records per person", "densityplot", "cdm_name",
    "Records per person", "boxplot", "cdm_name",
    "Duration in days", "densityplot", "cdm_name+observation_period_ordinal",
    "Duration in days", "boxplot", "cdm_name+observation_period_ordinal",
    "Days to next observation period", "densityplot", "cdm_name+observation_period_ordinal",
    "Days to next observation period", "boxplot", "cdm_name+observation_period_ordinal",
  )
}
