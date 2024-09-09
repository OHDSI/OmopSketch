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
#'library(CDMConnector)
#'library(DBI)
#'library(duckdb)
#'library(OmopSketch)
#'
#'# Connect to Eunomia database
#'if (Sys.getenv("EUNOMIA_DATA_FOLDER") == "") Sys.setenv("EUNOMIA_DATA_FOLDER" = tempdir())
#'if (!dir.exists(Sys.getenv("EUNOMIA_DATA_FOLDER"))) dir.create(Sys.getenv("EUNOMIA_DATA_FOLDER"))
#'if (!eunomia_is_available()) downloadEunomiaData()
#'con <- DBI::dbConnect(duckdb::duckdb(), CDMConnector::eunomia_dir())
#'cdm <- CDMConnector::cdmFromCon(
#' con = con, cdmSchema = "main", writeSchema = "main"
#')
#'
#'# Run summarise clinical tables
#'summarisedPopulation <- summarisePopulationCharacteristics(cdm = cdm,
#'                                                           studyPeriod = c("2010-01-01",NA),
#'                                                           sex = TRUE,
#'                                                           ageGroup = NULL
#'                                                           )
#'summarisedPopulation |> print()
#'PatientProfiles::mockDisconnect(cdm = cdm)
#'}
summarisePopulationCharacteristics <- function(cdm,
                                               studyPeriod = c(NA, NA),
                                               sex = FALSE,
                                               ageGroup = NULL) {

  studyPeriod <- checkStudyPeriod(cdm, studyPeriod)
  assertLogical(sex, length = 1)
  checkAgeGroup(ageGroup)

  cohort <- CohortConstructor::demographicsCohort(cdm = cdm, name = "summarised_population") |>
    CohortConstructor::trimToDateRange(dateRange = studyPeriod) |>
    PatientProfiles::addAge(indexDate = "cohort_end_date",
                            ageName = "age_at_end")

  if(sex && !is.null(ageGroup)) {
    cohort <- cohort |>
      PatientProfiles::addDemographics(ageGroup = ageGroup,
                                       age = FALSE,
                                       priorObservation = FALSE,
                                       futureObservation = FALSE)
     strata <- list("sex", "age_group", c("sex", "age_group"))
  } else if(sex && is.null(ageGroup)) {
    cohort <- cohort |>
      PatientProfiles::addSex()
    strata <- list("sex")
  } else if(!sex && !is.null(ageGroup)) {
    cohort <- cohort |>
      PatientProfiles::addAge(ageGroup = ageGroup)
    strata <- list("age_group")
  } else {
    strata <- list()
  }

  summarisedCohort <- cohort |>
    CohortCharacteristics::summariseCharacteristics(strata = strata,
                                                    otherVariables = "age_at_end")

  return(summarisedCohort)
}
