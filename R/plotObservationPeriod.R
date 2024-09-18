
#' Create a plot from the output of summariseObservationPeriod().
#'
#' @param result A summarised_result object.
#' @param variableName The variable to plot it can be: "number subjects",
#' "records per person", "duration" or "days to next observation period".
#' @param plotType The plot type, it can be: "barplot", "boxplot" or
#' "densityplot".
#' @param facet Elements to facet by, it can be "cdm_name",
#' "observation_period_ordinal", both or none.
#'
#' @return A ggplot2 object.
#' @export
#'
#' @examples
#' \dontrun{
#' library(dplyr)
#' library(OmopSketch)
#'
#' # Connect to a mock database
#' cdm <- mockOmopSketch()
#'
#' result <- summariseObservationPeriod(cdm$observation_period)
#'
#' result |>
#'   plotObservationPeriod()
#'
#' PatientProfiles::cdmDisconnect(cdm)
#' }
#'
plotObservationPeriod <- function(result,
                                  variableName = "number subjects",
                                  plotType = "barplot",
                                  facet = "cdm_name") {
  # initial checks
  omopgenerics::assertClass(result, class = "summarised_result")
  result <- result |>
    visOmopResults::filterSettings(
      .data$result_type == "summarise_observation_period")
  if (nrow(result) == 0) {
    "No results found for `result_type` == 'summarise_observation_period'" |>
      cli::cli_abort()
  }
  if (result$estimate_value[result$variable_name == "number records"] == "0") {
    cli::cli_warn("Obsevation period table was empty.")
    return(ggplot2::ggplot())
  }
  variableNames <- availablePlotObservationPeriod() |>
    dplyr::pull("variable_name") |>
    unique()
  omopgenerics::assertChoice(variableName, variableNames, length = 1)
  plotTypes <- availablePlotObservationPeriod() |>
    dplyr::filter(.data$variable_name == .env$variableName) |>
    dplyr::pull("plot_type")
  omopgenerics::assertChoice(plotType, plotTypes, length = 1)
  optFacetColour <- availablePlotObservationPeriod() |>
    dplyr::filter(.data$variable_name == .env$variableName,
                  .data$plot_type == .env$plotType) |>
    dplyr::pull("facet") |>
    strsplit(split = "+", fixed = TRUE) |>
    unlist()
  omopgenerics::assertChoice(facet, optFacetColour, unique = TRUE, null = TRUE)
  colour <- optFacetColour[!optFacetColour %in% facet]

  neededEstimates <- needEstimates(plotType)
  result <- result |>
    dplyr::filter(
      .data$variable_name == .env$variableName,
      .data$estimate_name %in% .env$neededEstimates)
  allEstimates <- result$estimate_name |> unique()
  missingEstimates <- neededEstimates[!neededEstimates %in% allEstimates]
  if (length(missingEstimates)) {
    if (plotType == "densityplot") {
      cli::cli_abort("No density estimates found, please use: summariseObservationPeriod(density = TRUE).")
    } else {
      cli::cli_abort("estimates not found: {missingEstimates}.")
    }
  }

  result <- result |>
    visOmopResults::pivotEstimates() |>
    visOmopResults::splitAll() |>
    dplyr::select(-c("result_id", "variable_name", "variable_level")) |>
    uniteVariable(cols = colour, colname = "colour", def = "")

  if (plotType != "densityplot") {
    result <- result |>
      dplyr::mutate("x" = .data$colour)
  }

  if (plotType == "barplot") {
    result <- result |>
      dplyr::filter(.data$observation_period_ordinal != "overall")
    p <- ggplot2::ggplot(
      data = result,
      mapping = ggplot2::aes(
        x = .data$x, y = .data$count, colour = .data$colour,
        fill = .data$colour)
    ) +
      ggplot2::geom_col() +
      ggplot2::xlab("Observation period")
  } else if (plotType == "boxplot") {
    p <- ggplot2::ggplot(
      data = result,
      mapping = ggplot2::aes(
        x = .data$x, ymin = .data$min, lower = .data$q25, middle = .data$median,
        upper = .data$q75, ymax = .data$max, colour = .data$colour)
    ) +
      ggplot2::geom_boxplot(stat = "identity") +
      ggplot2::xlab("Observation period") +
      ggplot2::ylab(stringr::str_to_sentence(variableName))
  } else {
    p <- ggplot2::ggplot(
      data = result,
      mapping = ggplot2::aes(
        x = .data$x, y = .data$y, colour = .data$colour, group = .data$colour)
    ) +
      ggplot2::geom_line() +
      ggplot2::ylab("") +
      ggplot2::xlab(paste0(stringr::str_to_sentence(variableName), " (days)"))
  }

  if (!is.null(facet)) {
    p <- p +
      ggplot2::facet_wrap(facet)
  }

  return(p)
}

availablePlotObservationPeriod <- function() {
  dplyr::tribble(
    ~variable_name, ~plot_type, ~facet,
    "number subjects", "barplot", "cdm_name+observation_period_ordinal",
    "records per person", "densityplot", "cdm_name",
    "records per person", "boxplot", "cdm_name",
    "duration", "densityplot", "cdm_name+observation_period_ordinal",
    "duration", "boxplot", "cdm_name+observation_period_ordinal",
    "days to next observation period", "densityplot", "cdm_name+observation_period_ordinal",
    "days to next observation period", "boxplot", "cdm_name+observation_period_ordinal",
  )
}
needEstimates <- function(plotType) {
  dplyr::tribble(
    ~plot_type, ~estimate_name,
    "barplot", "count",
    "densityplot", "x",
    "densityplot", "y",
    "boxplot", "median",
    "boxplot", "q25",
    "boxplot", "q75",
    "boxplot", "min",
    "boxplot", "max"
  ) |>
    dplyr::filter(.data$plot_type == .env$plotType) |>
    dplyr::pull("estimate_name")
}
uniteVariable <- function(res, cols, colname, def) {
  if (length(cols) > 0) {
    res <- res |>
      tidyr::unite(
        col = !!colname, dplyr::all_of(cols), sep = " - ", remove = FALSE)
  } else {
    res <- res |> dplyr::mutate(!!colname := !!def)
  }
  return(res)
}
