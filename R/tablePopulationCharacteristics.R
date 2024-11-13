
#' Create a visual table from a summarise_population_characteristics result.
#'
#' @param result Output from summarisePopulationCharacteristics().
#' @param type Type of formatting output table, either "gt" or "flextable".
#' @return A gt or flextable object with the summarised data.
#' @export
#' @examples
#' \donttest{
#' cdm <- mockOmopSketch()
#'
#' summarisedPopulation <- summarisePopulationCharacteristics(
#'   cdm = cdm,
#'   studyPeriod = c("2010-01-01", NA),
#'   sex = TRUE,
#'   ageGroup = list("<=60" = c(0, 60), ">60" = c(61, Inf))
#' )
#'
#' summarisedPopulation |>
#'   suppress(minCellCount = 5) |>
#'   tablePopulationCharacteristics()
#'
#' PatientProfiles::mockDisconnect(cdm = cdm)
#'}
tablePopulationCharacteristics <- function(result,
                                           type = "gt") {
  # Initial checks ----
  omopgenerics::validateResultArgument(result)
  omopgenerics::assertChoice(type, choicesTables())

  # subset to result_type of interest
  result <- result |>
    visOmopResults::filterSettings(
      .data$result_type == "summarise_population_characteristics")

  # check if it is empty
  if (nrow(result) == 0) {
    warnEmpty("summarise_population_characteristics")
    return(emptyTable(type))
  }

  # Function
  result <- result |>
    visOmopResults::visOmopTable(
      hide = c("cohort_name"),
      estimateName = c(
        "N%" = "<count> (<percentage>)",
        "N" = "<count>",
        "Median [Q25 - Q75]" = "<median> [<q25> - <q75>]",
        "Mean (SD)" = "<mean> (<sd>)",
        "Range" = "<min> to <max>"),
      rename = c("Database name" = "cdm_name"),
      header = c("cdm_name"),
      groupColumn = visOmopResults::strataColumns(result))

  return(result)
}
