#' Create a gt table from a summarised omop_table.
#'
#' @param omopTable A summarised_result object with the output from summariseOmopTable().
#' @param unit Whether to stratify by "year" or by "month"
#' @param unitInterval Number of years or months to be used
#'
#' @return A gt object with the summarised data.
#'
#' @importFrom rlang :=
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

}
