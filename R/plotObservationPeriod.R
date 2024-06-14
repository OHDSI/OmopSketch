#' Create a gt table from a summarised omop_table.
#'
#' @param summarisedObservationPeriod A summarised_result object with the output from summariseObservationPeriod().
#'
#' @return A ggplot showing the table counts
#'
#' @export
#'
plotObservationPeriod <- function(summarisedObservationPeriod){
  # Initial checks ----
  assertClass(summarisedObservationPeriod, "summarised_result")

  if(summarisedObservationPeriod |> dplyr::tally() |> dplyr::pull("n") == 0){
    cli::cli_warn("summarisedObservationPeriod is empty.")
    return(
      summarisedObservationPeriod |>
        ggplot2::ggplot()
    )
  }

  # Plot ----
  summarisedObservationPeriod |>
    dplyr::filter(.data$estimate_name == "count") |>
    dplyr::mutate(individuals_in_observation = as.numeric(.data$estimate_value),
                  time = .data$strata_level) |>
    ggplot2::ggplot(ggplot2::aes(x = .data$time, y = .data$individuals_in_observation, group = .data$cdm_name, color = .data$cdm_name)) +
    ggplot2::geom_point() +
    ggplot2::geom_line() +
    ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 90, vjust = 0.5, hjust=1)) +
    ggplot2::xlab("Time interval") +
    ggplot2::ylab("Individuals in observation") +
    ggplot2::labs(color = "CDM table")

}

