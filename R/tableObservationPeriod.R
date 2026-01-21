
#' Create a visual table from a summariseObservationPeriod() result
#'
#' @param result A summarised_result object (output of
#' `summariseObservationPeriod()`).
#' @inheritParams style-table
#'
#' @return A formatted table visualisation.
#' @export
#'
#' @inherit summariseObservationPeriod examples
#'
tableObservationPeriod <- function(result,
                                   header = "cdm_name",
                                   hide = omopgenerics::settingsColumns(result),
                                   groupColumn = omopgenerics::strataColumns(result),
                                   type = NULL,
                                   style = NULL) {
  # initial checks
  rlang::check_installed("visOmopResults")
  omopgenerics::validateResultArgument(result)

  style <- validateStyle(style = style, obj = "table")
  type <- validateType(type)

  # subset to result_type of interest
  result <- result |>
    omopgenerics::filterSettings(
      .data$result_type == "summarise_observation_period"
    )

  # check if it is empty
  if (nrow(result) == 0) {
    warnEmpty("summarise_observation_period")
    return(visOmopResults::emptyTable(type = type, style = style))
  }

  byOrdinal <- result |>
    dplyr::summarise(n = dplyr::n_distinct(.data$group_level)) |>
    dplyr::pull("n") > 1

  setting_cols <- omopgenerics::settingsColumns(result)

  hide <- c(hide, "observation_period_ordinal"[!byOrdinal])


  custom_order <- c("Number records", "Number subjects", "Subjects not in person table", "Records per person", "Duration in days", "Days to next observation period", "Type concept id", "Start date before birth date", "End date before start date", "Column name")

  result |>
    dplyr::filter(!grepl("density", .data$estimate_name)) |>
    formatColumn(c("variable_name", "variable_level")) |>
    dplyr::mutate(variable_name = factor(.data$variable_name, levels = custom_order)) |>
    dplyr::arrange(.data$variable_name, .data$variable_level) |>
    # Arrange by observation period ordinal
    dplyr::mutate(order = dplyr::coalesce(as.numeric(stringr::str_extract(.data$group_level, "\\d+")), 0)) |>
    dplyr::arrange(.data$order) |>
    dplyr::select(-"order") |>
    visOmopResults::visOmopTable(
      estimateName = c(
        "N (%)" = "<count> (<percentage>%)",
        "N" = "<count>",
        "Mean (SD)" = "<mean> (<sd>)",
        "Median [Q25 - Q75]" = "<median> [<q25> - <q75>]",
        "Range [min to max]" = "[<min> to <max>]",
        "N missing data (%)" = "<na_count> (<na_percentage>%)",
        "N zeros (%)" = "<zero_count> (<zero_percentage>%)"
      ),
      header = header,
      groupColumn = groupColumn,
      hide = hide,
      type = type,
      style = style,
      settingsColumn = setting_cols,
      .options = list(keepNotFormatted = FALSE,
                     caption = "Summary of observation_period table") # to consider removing this? If
      # the user adds some custom estimates they are not going to be displayed in
    ) |>
    suppressMessages()
}
