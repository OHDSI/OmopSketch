#' Create a gt table from a summarised population characteristics table.
#'
#' @param result Output from summarisePopulationCharacteristics().
#'
#' @return A gt object with the summarised data.
#'
#' @export
#' @examples
#' \donttest{
#' library(dplyr)
#' library(OmopSketch)
#'
#'# Connect to a mock database
#' cdm <- mockOmopSketch()
#'
#'# Run summarise clinical tables
#' summarisedPopulation <- summarisePopulationCharacteristics(
#'                        cdm = cdm,
#'                        studyPeriod = c("2010-01-01",NA),
#'                        sex = TRUE,
#'                        ageGroup = list("<=60" = c(0, 60), ">60" = c(61, Inf))
#'                        )
#' tablePopulationCharacteristics(summarisedPopulation)
#' PatientProfiles::mockDisconnect(cdm = cdm)
#'}
tablePopulationCharacteristics <- function(result){
  # Initial checks ----
  omopgenerics::assertClass(result, "summarised_result")

  if(result |> dplyr::tally() |> dplyr::pull("n") == 0){
    cli::cli_warn("summarisedClinicalRecords is empty.")

    return(
      result |>
        visOmopResults::splitGroup() |>
        visOmopResults::formatHeader(header = "cdm_name") |>
        dplyr::select(-c("estimate_type", "result_id",
                         "additional_name", "additional_level",
                         "strata_name", "strata_level")) |>
        dplyr::rename(
          "Variable" = "variable_name", "Level" = "variable_level",
          "Estimate" = "estimate_name"
        ) |>
        gt::gt()
    )
  }

  # Function
  result <- result |>
    visOmopResults::filterSettings(.data$result_type == "summarise_population_characteristics") |>
    visOmopResults::visOmopTable(
      hide = c("cohort_name"),
      formatEstimateName = c("N%" = "<count> (<percentage>)",
                             "N" = "<count>",
                             "Mean (SD)" = "<mean> (<sd>)"),
      renameColumns = c("Database name" = "cdm_name"),
      header = c("cdm_name"),
      groupColumn = visOmopResults::strataColumns(result))

  return(result)

}
