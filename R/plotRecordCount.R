#' Create a gt table from a summarised omop_table.
#'
#' @param summarisedRecordCount A summarised_result object with the output from summariseTableCounts().
#'
#' @return A ggplot showing the table counts
#'
#' @export
#'
plotRecordCount <- function(summarisedRecordCount){
  # Initial checks ----
  assertClass(summarisedRecordCount, "summarised_result")

  if(summarisedRecordCount |> dplyr::tally() |> dplyr::pull("n") == 0){
    cli::cli_warn("summarisedOmopTable is empty.")
    return(
      summarisedRecordCount |>
        ggplot2::ggplot()
    )
  }

  # Plot ----
  summarisedRecordCount |>
    dplyr::mutate(count = as.numeric(.data$estimate_value),
                  time = as.Date(.data$variable_level)) |>
    dplyr::mutate(colour_by = paste0(.data$group_level,"; ",.data$strata_level)) |>
    ggplot2::ggplot(ggplot2::aes(x = .data$time,
                                 y = .data$count,
                                 group = .data$colour_by,
                                 color = .data$colour_by)) +
    ggplot2::geom_point() +
    ggplot2::geom_line() +
    ggplot2::facet_wrap(facets = "cdm_name") +
    ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 90, vjust = 0.5, hjust=1)) +
    ggplot2::xlab("Time") +
    ggplot2::ylab("Counts") +
    ggplot2::labs(color = "Strata") +
    ggplot2::theme_bw()
}
