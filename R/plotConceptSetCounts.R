
#' Plot the concept counts of a summariseConceptSetCounts output
#'
#' `r lifecycle::badge('deprecated')`
#'
#' @param result A summarised_result object (output of
#' `summariseConceptSetCounts()`).
#' @inheritParams consistent-doc
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
#' result <- summariseConceptSetCounts(
#'   cdm = cdm,
#'   conceptSet = list(
#'     "asthma" = c(4051466, 317009),
#'     "rhinitis" = c(4280726, 4048171, 40486433)
#'   )
#' )
#'
#' result |>
#'   filter(variable_name == "Number subjects") |>
#'   plotConceptSetCounts(
#'     facet = "codelist_name",
#'     colour = "standard_concept_name"
#'   )
#'
#' cdmDisconnect(cdm = cdm)
#' }
#'
plotConceptSetCounts <- function(result,
                                 facet = NULL,
                                 colour = NULL) {
  lifecycle::deprecate_warn(
    when = "0.5.0",
    what = "plotConceptSetCounts()",
    with = NULL
  )

  rlang::check_installed("ggplot2")
  rlang::check_installed("visOmopResults")

  # initial checks
  omopgenerics::validateResultArgument(result)

  # subset to results of interest
  result <- result |>
    omopgenerics::filterSettings(.data$result_type == "summarise_concept_set_counts")

  if (nrow(result) == 0) {
    cli::cli_abort(c("!" = "No records found with result_type == summarise_concept_set_counts"))
  }

  # check only one estimate is contained
  variable <- unique(result$variable_name)
  if (length(variable) > 1) {
    cli::cli_abort(c(
      "!" = "Subset to the variable of interest, there are results from: {variable}.",
      "i" = "result |> dplyr::filter(variable_name == '{variable[1]}')"
    ))
  }

  result1 <- result |> omopgenerics::splitAll()
  # Detect if there are several time intervals
  if ("time_interval" %in% colnames(result1)) {
    # Line plot where each concept is a different line
    p <- result1 |>
      dplyr::filter(.data$time_interval != "overall") |>
      omopgenerics::pivotEstimates() |>
      visOmopResults::scatterPlot(
        x = "time_interval",
        y = "count",
        line = TRUE,
        point = TRUE,
        ribbon = TRUE,
        group = c("standard_concept_name", "standard_concept_id"),
        facet = facet,
        colour = colour
      )
  } else {
    if ("standard_concept_name" %in% colnames(result1)) {
      p <- result1 |>
        omopgenerics::pivotEstimates() |>
        visOmopResults::barPlot(
          x = c("standard_concept_name", "standard_concept_id"),
          y = "count",
          facet = facet,
          colour = colour
        )
      p$data <- p$data |>
        dplyr::mutate(
          standard_concept_name_standard_concept_id = factor(
            .data$standard_concept_name_standard_concept_id,
            levels = c("overall - overall", sort(setdiff(.data$standard_concept_name_standard_concept_id, "overall - overall")))
          )
        )
    } else {
      p <- result1 |>
        visOmopResults::barPlot(
          x = "codelist_name",
          y = "count",
          facet = facet,
          colour = colour
        )
      p$data <- p$data |>
        dplyr::arrange(.data$codelist_name)
    }
    p <- p +
      ggplot2::labs(
        x = "Concept name"
      )
  }

  p +
    ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 90, vjust = 0.5, hjust = 1))
}
