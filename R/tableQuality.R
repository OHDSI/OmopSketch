#' Create a visual table from a summariseTableQuality() result.
#' @param result A summarised_result object.
#' @param  type Type of formatting output table. See `visOmopResults::tableType()` for allowed options. Default is `"gt"`.
#' @return A formatted table object with the summarised data.
#' @noRd
#' @examples
#' \donttest{
#' cdm <- mockOmopSketch(numberIndividuals = 100)
#'
#' result <- summariseTableQuality(cdm, omopTableName = "drug_exposure")
#'
#' tableQuality(result = result)
#'
#' PatientProfiles::mockDisconnect(cdm = cdm)
#' }
tableQuality <- function(result,
                                   type = "gt") {
  # initial checks
  rlang::check_installed("visOmopResults")
  omopgenerics::validateResultArgument(result)
  omopgenerics::assertChoice(type, visOmopResults::tableType())

  # subset to result_type of interest
  result <- result |>
    omopgenerics::filterSettings(
      .data$result_type == "summarise_table_quality"
    ) |> dplyr::arrange(.data$variable_name, .data$additional_level, .data$strata_level)
  strata <- c(omopgenerics::additionalColumns(result), omopgenerics::strataColumns(result))
  # check if it is empty
  if (nrow(result) == 0) {
    warnEmpty("summarise_observation_period")
    return(emptyTable(type))
  }
  formatEstimates <- c(
    "N (%)" = "<count> (<percentage>%)")

  visOmopResults::visOmopTable(result = result,
                               estimateName = formatEstimates,
                               header = c("cdm_name"),
                               groupColumn = c("omop_table"),
                               type = type,
                               hide = c("estimate_type", "variable_level"),
                               columnOrder = c("variable_name", strata, "estimate_name"),
                               .options = list(groupAsColumn = TRUE, merge = "all_columns"))

}


