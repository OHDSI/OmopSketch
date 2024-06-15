#' Create a gt table from a summarised omop_table.
#'
#' @param summarisedTableCounts A summarised_result object with the output from summariseTableCounts().
#'
#' @return A ggplot showing the table counts
#'
#' @export
#'
plotTableCounts <- function(summarisedTableCounts) {
  # Initial checks ----
  assertClass(summarisedTableCounts, "summarised_result")

  if(summarisedTableCounts |> dplyr::tally() |> dplyr::pull("n") == 0){
    cli::cli_warn("summarisedOmopTable is empty.")
    return(
      summarisedTableCounts |>
        ggplot2::ggplot()
    )
  }

  # Plot ----
  summarisedTableCounts |>
    dplyr::mutate(count = as.numeric(.data$estimate_value),
                  time = as.Date(.data$variable_level)) |>
    visOmopResults::splitGroup() |>
    ggplot2::ggplot(ggplot2::aes(x = .data$time, y = .data$count, group = .data$omop_table, color = .data$omop_table)) +
    ggplot2::geom_point() +
    ggplot2::geom_line() +
    ggplot2::facet_wrap(facets = "cdm_name") +
    ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 90, vjust = 0.5, hjust=1)) +
    ggplot2::xlab("Time") +
    ggplot2::ylab("Counts") +
    ggplot2::labs(color = "Omop table")
}
