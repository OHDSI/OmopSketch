#' Summarise the characteristics of the base population of a cdm object.
#'
#' @param cdm A cdm object.
#' @param studyPeriod Dates to trim the observation period. If NA, start_observation_period and/or end_observation_period are used.
#' @param sex Boolean variable. Whether to stratify the results by sex.
#' @param ageGroup List of age groups to stratify by at index date. Set to NULL if no stratification is needed.
#'
#' @return A summarised_result object.
#'
#' @export
#' @examples
#' \donttest{
#'library(dplyr)
#'library(OmopSketch)
#'
#' # Connect to a mock database
#' cdm <- mockOmopSketch()
#'
#'# Run summarise population characteristics
#' summarisedPopulation <- summarisePopulationCharacteristics(cdm = cdm,
#'                                                           studyPeriod = c("2010-01-01",NA),
#'                                                           sex = TRUE,
#'                                                           ageGroup = NULL
#'                                                           )
#' summarisedPopulation |> print()
#' PatientProfiles::mockDisconnect(cdm = cdm)
#'
#'}
summarisePopulationCharacteristics <- function(cdm,
                                               studyPeriod = c(NA, NA),
                                               sex = FALSE,
                                               ageGroup = NULL) {

  omopgenerics::validateCdmArgument(cdm)
  studyPeriod <- validateStudyPeriod(cdm, studyPeriod)
  omopgenerics::assertLogical(sex, length = 1)
  omopgenerics::validateAgeGroupArgument(ageGroup)

  cohort <- CohortConstructor::demographicsCohort(cdm = cdm,
                                                  name = omopgenerics::uniqueTableName()) |>
    dplyr::rename("person_id" = "subject_id") |>
    dplyr::rename("subject_id" = "person_id") |>
    CohortConstructor::trimToDateRange(dateRange = studyPeriod) |>
    PatientProfiles::addAge(indexDate = "cohort_end_date",
                            ageName = "age_at_end")

  cohort <- cohort |>
    PatientProfiles::addDemographics(ageGroup = ageGroup, sex = sex,
                                     priorObservation = F,
                                     futureObservation = F,
                                     age = F)
  if(!is.null(ageGroup)) {
    cohort <- cohort |>
    dplyr::rename("age_group_at_start" = "age_group")
    }

  strata <- switch(
    paste(is.null(ageGroup), sex),
    "TRUE TRUE" = list("sex"),
    "TRUE FALSE" = list(),
    "FALSE TRUE" = list("age_group_at_start", "sex", c("age_group_at_start", "sex")),
    "FALSE FALSE" = list("age_group_at_start")
  )

  summarisedCohort <- cohort |>
    CohortCharacteristics::summariseCharacteristics(strata = strata,
                                                    otherVariables = "age_at_end") |>
    dplyr::mutate(variable_name = dplyr::if_else(.data$variable_name == "Age", "Age at start", .data$variable_name)) |>
    dplyr::mutate(variable_name = factor(.data$variable_name,
                                         levels = c("Number records", "Number subjects", "Cohort start date", "Cohort end date",
                                                    "Age at start", "Age at end", "Sex", "Prior observation", "Future observation"))) |>
    dplyr::arrange(.data$variable_name) |>
    omopgenerics::newSummarisedResult(
      settings = dplyr::tibble(
      "result_id" = 1L,
      "package_name" = "OmopSketch",
      "package_version" = as.character(utils::packageVersion(
        "OmopSketch"
      )),
      "result_type" = "summarise_population_characteristics"
    ))

  return(summarisedCohort)
}
