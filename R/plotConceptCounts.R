#' Plot the concept counts of a summariseConceptCounts output.
#'
#' @param result A summarised_result object (output of summariseConceptCounts).
#' @param facet Columns to face by. Formula format can be provided. See possible
#' columns to face by with: `visOmopResults::tidyColumns()`.
#' @param colour Columns to colour by. See possible columns to colour by with:
#' `visOmopResults::tidyColumns()`.
#' @return A ggplot2 object showing the concept counts.
#' @export
#' @examples
#' \donttest{
#' library(dplyr, warn.conflicts = FALSE)
#'
#' cdm <- mockOmopSketch()
#'
#' result <- cdm |>
#'   summariseConceptCounts(
#'     conceptId = list(
#'       "Renal agenesis" = 194152,
#'       "Manic mood" = c(4226696, 4304866, 37110496, 40371897)
#'     )
#'   )
#'
#' result |>
#'   filter(estimate_name == "person_count", variable_name == "overall") |>
#'   plotConceptCounts(facet = "codelist_name", colour = "codelist_name")
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
    cli::cli_abort(c("!" = "No records found with result_type == summarise_concept_counts"))
  }

  # check only one estimate is contained
  estimate <- unique(result$estimate_name)
  if (length(estimate) > 1) {
    cli::cli_abort(c(
      "!" = "Subset to the estimate of interest, there are results from: {estimate}.",
      "i" = "result |> dplyr::filter(estimate_name == '{estimate[1]}')"
    ))
  }

  order <- c("overall", sort(unique(result$variable_name[result$variable_name != "overall"])))
  result |>
    dplyr::mutate(variable_name = factor(.data$variable_name,
                                         levels = order)) |>
    visOmopResults::barPlot(x = "variable_name",
                            y = estimate,
                            facet = facet,
                            colour = colour) +
    ggplot2::labs(
      x = "Concept name"
    ) +
    ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 90, vjust = 0.5, hjust = 1))
}
