
#' Create a visual table from a summariseObservationPeriod() result.
#' @param result A summarised_result object.
#' @param type Type of formatting output table, either "gt" or "flextable".
#' @return A gt or flextable object with the summarised data.
#' @export
#' @examples
#' \donttest{
#' cdm <- mockOmopSketch(numberIndividuals = 100)
#'
#' result <- summariseObservationPeriod(cdm$observation_period)
#'
#' tableObservationPeriod(result)
#'
#' PatientProfiles::mockDisconnect(cdm)
#' }
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

