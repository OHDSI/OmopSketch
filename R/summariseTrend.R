summariseTrend <- function(cdm,
                           omopTableName,
                           interval = "overall",
                           ageGroup = NULL,
                           sex = FALSE,
                           dateRange = NULL)
{
  cdm <- omopgenerics::validateCdmArgument(cdm)
  omopgenerics::assertCharacter(omopTableName)
  omopgenerics::assertChoice(omopTableName, omopgenerics::omopTables(version = omopgenerics::cdmVersion(cdm) ))
  omopgenerics::assertChoice(interval, c("overall", "years", "quarters", "months"), length = 1)
  ageGroup <- omopgenerics::validateAgeGroupArgument(ageGroup, ageGroupName = "age_group")
  omopgenerics::assertLogical(sex, length = 1)
  dateRange <- validateStudyPeriod(cdm, dateRange)
  omopgenerics::assertChoice(output, choices = c("person-days", "record", "person", "age", "sex"))


  set <- createSettings(
    result_type = "summarise_trend", study_period = dateRange
  ) |>
    dplyr::mutate(interval = .env$interval)

  prefix <- omopgenerics::tmpPrefix()

  purrr::map(omopTableName, \(table) {
    # get table
    omopTable <- dplyr::ungroup(cdm[[table]])
    if (table == "observation_period") {
      omopTable <- omopTable |>
        trimStudyPeriod(dateRange = dateRange)
    } else {
      omopTable <- omopTable |>
        restrictStudyPeriod(dateRange = dateRange)
    }
    if (is.null(omopTable)) {
      return(omopgenerics::emptySummarisedResult())
    }


  })

}
