#' Create a gt table from a summarised population characteristics table.
#'
#' @param result Output from summarisePopulationCharacteristics().
#' @param type Type of table.
#'
#' @return A visual table.
#'
#' @export
#' @examples
#' \donttest{
#'
#' # Connect to a mock database
#' cdm <- mockOmopSketch()
#'
#' # Run summarise clinical tables
#' summarisedPopulation <- summarisePopulationCharacteristics(
#'   cdm = cdm,
#'   studyPeriod = c("2010-01-01",NA),
#'   sex = TRUE,
#'   ageGroup = list("<=60" = c(0, 60), ">60" = c(61, Inf))
#' )
#'
#' # Create a visual table
#' tablePopulationCharacteristics(summarisedPopulation)
#'
#' # delete mock data
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
        "Mean (SD)" = "<mean> (<sd>)"),
      rename = c("Database name" = "cdm_name"),
      header = c("cdm_name"),
      groupColumn = visOmopResults::strataColumns(result))

  return(result)
}
