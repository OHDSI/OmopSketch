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
    visOmopResults::filterSettings(.data$result_type == "summarise_concept_counts") |>
    dplyr::mutate(variable_level = gsub(" to.*","",.data$variable_level)) |>
    dplyr::mutate(variable_level = gsub("-01$","",.data$variable_level))

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

  # Detect if there are several time intervals
  if(length(unique(result$variable_level)) > 1 ){
    # Line plot where each concept is a different line
    p <- result |>
      dplyr::filter(.data$variable_level != "overall") |>
      visOmopResults::scatterPlot(x = "variable_level",
                                  y = "count",
                                  line   = TRUE,
                                  point  = TRUE,
                                  ribbon = TRUE,
                                  group  = "standard_concept_name",
                                  facet  = facet,
                                  colour = colour)
  }else{
    p <- result |>
      visOmopResults::barPlot(x = "standard_concept_name",
                              y = "count",
                              facet = facet,
                              colour = colour)  +
      ggplot2::labs(
        x = "Concept name"
      )
  }

 p +
    ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 90, vjust = 0.5, hjust = 1))
}
