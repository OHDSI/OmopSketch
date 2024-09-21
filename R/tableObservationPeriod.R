
#' Create a table from the output of summariseObservationPeriod().
#'
#' @param result A summarised result object.
#' @param type Type of table.
#'
#' @return A gt or flextable table.
#' @export
#'
#' @examples
#' cdm <- mockOmopSketch()
#'
#' result <- summariseObservationPeriod(cdm$observation_period)
#'
#' tableObservationPeriod(result)
#'
#' PatientProfiles::mockDisconnect(cdm)
#'
tableObservationPeriod <- function(result,
                                   type = "gt") {
  # initial checks
  omopgenerics::validateResultArgument(result)
  omopgenerics::assertChoice(type, choicesTables())

  # subset to result_type of interest
  result <- result |>
    visOmopResults::filterSettings(
      .data$result_type == "summarise_observation_period")

  # check if it is empty
  if (nrow(result) == 0) {
    warnEmpty("summarise_observation_period")
    return(emptyTable(type))
  }

  result |>
    dplyr::filter(is.na(.data$variable_level)) |> # to remove density
    formatColumn("variable_name") |>
    visOmopResults::visOmopTable(
      estimateName = c(
        "N" = "<count>",
        "mean (sd)" = "<mean> (<sd>)",
        "median [Q25 - Q75]" = "<median> [<q25> - <q75>]"),
      header = "cdm_name",
      groupColumn = visOmopResults::strataColumns(result),
      hide = c(
        "result_id", "estimate_type", "strata_name", "variable_level"),
      type = type,
      .options = list(keepNotFormatted = FALSE) # to consider removing this? If
      # the user adds some custom estimates they are not going to be displayed in
    )
}
