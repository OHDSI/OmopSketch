#' Create a visual table from a summariseObservationPeriod() result.
#' @param result A summarised_result object.
#' @param  type Type of formatting output table. See `visOmopResults::tableType()` for allowed options. Default is `"gt"`.
#' @inheritParams style
#' @return A formatted table object with the summarised data.
#' @export
#' @examples
#' \donttest{
#' library(OmopSketch)
#'
#' cdm <- mockOmopSketch(numberIndividuals = 100)
#'
#' result <- summariseObservationPeriod(observationPeriod = cdm$observation_period)
#'
#' tableObservationPeriod(result = result)
#'
#' PatientProfiles::mockDisconnect(cdm = cdm)
#' }
tableObservationPeriod <- function(result,
                                   type = "gt",
                                   style = "default") {
  # initial checks
  rlang::check_installed("visOmopResults")
  omopgenerics::validateResultArgument(result)
  omopgenerics::assertChoice(type, visOmopResults::tableType())

  # subset to result_type of interest
  result <- result |>
    omopgenerics::filterSettings(
      .data$result_type == "summarise_observation_period"
    )

  # check if it is empty
  if (nrow(result) == 0) {
    warnEmpty("summarise_observation_period")
    return(emptyTable(type))
  }

  header <- c("cdm_name")
  byOrdinal <- result |> dplyr::summarise(n = dplyr::n_distinct(.data$group_level)) |> dplyr::pull("n") > 1


  hide <- c("result_id", "estimate_type", "strata_name","observation_period_ordinal"[!byOrdinal])

  custom_order <- c("Number records", "Number subjects", "Subjects not in person table", "Records per person", "Duration in days","Days to next observation period", "Type concept id", "Start date before birth date", "End date before start date", "Column name")

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
      groupColumn = omopgenerics::strataColumns(result),
      hide = hide,
      type = type,
      style = style,
      .options = list(keepNotFormatted = FALSE) # to consider removing this? If
      # the user adds some custom estimates they are not going to be displayed in
    ) |> suppressMessages()
}
