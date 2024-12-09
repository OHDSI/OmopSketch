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
#' library(dplyr)
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
#'   filter(variable_name == "Number subjects") |>
#'   plotConceptCounts(facet = "codelist_name", colour = "standard_concept_name")
#'
#' PatientProfiles::mockDisconnect(cdm)
#' }
plotConceptCounts <- function(result,
                              facet = NULL,
                              colour = NULL){

  rlang::check_installed("ggplot2")
  rlang::check_installed("visOmopResults")

  # initial checks
  omopgenerics::validateResultArgument(result)

  # subset to results of interest
  result <- result |>
    omopgenerics::filterSettings(.data$result_type == "summarise_concept_counts")

  if (nrow(result) == 0) {
    cli::cli_abort(c("!" = "No records found with result_type == summarise_concept_counts"))
  }

  # check only one estimate is contained
 variable <- unique(result$variable_name)
  if (length(variable) > 1) {
    cli::cli_abort(c(
      "!" = "Subset to the variable of interest, there are results from: {variable}.",
      "i" = "result |> dplyr::filter(variable_name == '{variable[1]}')"
    ))
  }

  result1 <- result |> omopgenerics::splitAdditional()
  # Detect if there are several time intervals
  if("time_interval" %in% colnames(result1)){
    # Line plot where each concept is a different line
    p <- result1 |>
      dplyr::filter(.data$time_interval != "overall") |>
      omopgenerics::uniteAdditional(cols = c("time_interval", "standard_concept_name", "standard_concept_id", "source_concept_name", "source_concept_id", "domain_id")) |>
      visOmopResults::scatterPlot(x = "time_interval",
                                  y = "count",
                                  line   = TRUE,
                                  point  = TRUE,
                                  ribbon = TRUE,
                                  group  = c("standard_concept_name", "standard_concept_id"),
                                  facet  = facet,
                                  colour = colour)
  }else{
    if("standard_concept_name" %in% colnames(result1)){
      p <- result |>
        visOmopResults::barPlot(x = c("standard_concept_name", "standard_concept_id"),
                                y = "count",
                                facet = facet,
                                colour = colour)
    }else{
      p <- result |>
        visOmopResults::barPlot(x = "codelist_name",
                                y = "count",
                                facet = facet,
                                colour = colour)
    }
    p <- p +
      ggplot2::labs(
        x = "Concept name"
      )
  }

 p +
    ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 90, vjust = 0.5, hjust = 1))
}
