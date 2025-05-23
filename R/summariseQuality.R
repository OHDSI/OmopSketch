summariseTableQuality <- function(cdm,
                                  omopTableName,
                                  interval = "overall",
                                  sex = FALSE,
                                  ageGroup = NULL,
                                  sample = NULL,
                                  dateRange = NULL,
                                  endBeforeStart = TRUE,
                                  birthDate = TRUE){


  cdm <- omopgenerics::validateCdmArgument(cdm)

  omopgenerics::assertLogical(sex, length = 1)
  omopgenerics::assertChoice(interval, c("overall", "years", "quarters", "months"), length = 1)
  omopgenerics::assertChoice(omopTableName, choices = omopgenerics::omopTables(), unique = TRUE)
  omopgenerics::assertNumeric(sample, null = TRUE, integerish = TRUE, length = 1, min = 1)
  dateRange <- validateStudyPeriod(cdm, dateRange)
  ageGroup <- omopgenerics::validateAgeGroupArgument(ageGroup, multipleAgeGroup = FALSE, null = TRUE, ageGroupName = "age_group")
  omopgenerics::assertLogical(endBeforeStart, length = 1)
  omopgenerics::assertLogical(birthDate, length = 1)



  result <- purrr::map(omopTableName, function(table) {
    omoTable <- cdm[[table]]
    omopTable <- restrictStudyPeriod(omopTable = omopTable, dateRange = dateRange)
    omopTable <- sampleOmopTable(omopTable = omopTable, sample = sample)
    res <- list()
    if (endBeforeStart) {
      res$endBeforeStart <- summariseEndBeforeStart(omopTable,  interval = interval, sex = sex, ageGroup = ageGroup)
    }
    if (birthDate) {
      res$birthDate <- summariseBirthDate(omopTable, interval = interval, sex = sex, ageGroup = ageGroup)
    }
    dplyr::bind_rows(res)
  }) |>
    purrr::compact()


}

