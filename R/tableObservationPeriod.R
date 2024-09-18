
#' Create a table from the output of summariseObservationPeriod().
#'
#' @param result A summarised result object.
#' @param type Type of table either `gt` or `flextable`.
#'
#' @return A gt or flextable table.
#' @export
#'
tableObservationPeriod <- function(result,
                                   type = "gt") {
  omopgenerics::validateResultArgument(result)

  result <- result |>
    visOmopResults::filterSettings(
      .data$result_type == "summarise_observation_period")
  if (nrow(result) == 0) {
    "No results found for `result_type` == 'summarise_observation_period'" |>
      cli::cli_abort()
  }
  omopgenerics::assertChoice(type, c("gt", "flextable"))

  result |>
    dplyr::filter(is.na(.data$variable_level)) |>
    visOmopResults::visOmopTable(
      estimateName = c(
        "N" = "<count>",
        "mean (sd)" = "<mean> (<sd>)",
        "median [Q25 - Q75]" = "<median> [<q25> - <q75>]"),
      header = "cdm_name",
      split = c("group", "additional"),
      groupColumn = visOmopResults::strataColumns(result),
      hide = c(
        "result_id", "estimate_type", "strata_name", "variable_level"),
      type = type,
      .options = list(keepNotFormatted = FALSE)
    )
}
