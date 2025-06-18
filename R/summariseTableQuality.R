#' Summarise table quality issues in an OMOP table using a specific time interval.
#'
#' This function assesses potential data quality issues in a given OMOP table, such as records
#' with an end date before the start date or a start date before the person's birthdate.
#'
#' @param cdm A `cdm_reference` object.
#' @param omopTableName A character vector of OMOP table names from the CDM.
#' @inheritParams interval
#' @param sex Logical. Should results be stratified by sex? Default is `FALSE`.
#' @param ageGroup A list of age groups to stratify results by. Default is `NULL`.
#' @param sample An integer specifying the number of records to sample from each table.
#' If `NULL`, no sampling is done.
#' @inheritParams dateRange-startDate
#' @param endBeforeStart Logical. Whether the function should check for records where the end date
#' is before the start date. Default is `TRUE`.
#' @param startBeforeBirth Logical. Whether the function should check for records where the start date
#' is before the patient's birthdate. Default is `TRUE`.
#'
#' @return A `summarised_result` object with counts and percentages of potential quality issues,
#' stratified as specified.
#' @noRd
#' @examples
#' \donttest{
#' library(dplyr)
#'
#' cdm <- mockOmopSketch()
#'
#' qualitySummary <- summariseTableQuality(
#'   cdm = cdm,
#'   omopTableName = c("condition_occurrence", "drug_exposure"),
#'   interval = "years",
#'   sex = TRUE,
#'   ageGroup = list("<=20" = c(0, 20), ">20" = c(21, Inf)),
#'   endBeforeStart = TRUE,
#'   startBeforeBirth = TRUE
#' )
#'
#' qualitySummary |> glimpse()
#'
#' PatientProfiles::mockDisconnect(cdm = cdm)
#' }
summariseTableQuality <- function(cdm,
                                  omopTableName,
                                  interval = "overall",
                                  sex = FALSE,
                                  ageGroup = NULL,
                                  sample = NULL,
                                  dateRange = NULL,
                                  endBeforeStart = TRUE,
                                  startBeforeBirth = TRUE){


  cdm <- omopgenerics::validateCdmArgument(cdm)

  omopgenerics::assertLogical(sex, length = 1)
  omopgenerics::assertChoice(interval, c("overall", "years", "quarters", "months"), length = 1)
  omopgenerics::assertChoice(omopTableName, choices = omopgenerics::omopTables(), unique = TRUE)
  omopgenerics::assertNumeric(sample, null = TRUE, integerish = TRUE, length = 1, min = 1)
  dateRange <- validateStudyPeriod(cdm, dateRange)
  ageGroup <- omopgenerics::validateAgeGroupArgument(ageGroup, multipleAgeGroup = FALSE, null = TRUE, ageGroupName = "age_group")
  omopgenerics::assertLogical(endBeforeStart, length = 1)
  omopgenerics::assertLogical(startBeforeBirth, length = 1)

  set <- createSettings(result_type = "summarise_table_quality", result_id = 1L, study_period = dateRange)
  tablePrefix <- omopgenerics::tmpPrefix()
  strata <- c("sex"[sex], "age_group"[!is.null(ageGroup)], "interval"[interval != "overall"])
  stratification <- c(list(character()),omopgenerics::combineStrata(strata))


  result <- purrr::map(omopTableName, function(table) {

    omopTable <- cdm[[table]]
    if (omopgenerics::isTableEmpty(omopTable)) {
      cli::cli_warn(paste0(table, "omop table is empty."))
      return(NULL)
    }
    omopTable <- restrictStudyPeriod(omopTable = omopTable, dateRange = dateRange)
    if (omopgenerics::isTableEmpty(omopTable)) {
      return(NULL)
    }
    omopTable <- sampleOmopTable(omopTable, sample = sample)

    start_date_name <- omopgenerics::omopColumns(table = table, field = "start_date")
    end_date_name <- omopgenerics::omopColumns(table = table, field = "end_date")

    omopTable <- addStratifications(omopTable, indexDate = start_date_name, sex = sex, ageGroup = ageGroup, interval = interval,intervalName = "interval", name = omopgenerics::uniqueTableName(prefix = tablePrefix))
    denominator <- omopTable |>
      summariseCountsInternal(strata = stratification, counts = "records")
    res <- list()
    if (endBeforeStart) {
      res$endBeforeStart <- summariseEndBeforeStart(omopTable = omopTable, strata = stratification, start_date_name = start_date_name, end_date_name = end_date_name)
    }
    if (startBeforeBirth) {
      res$startBeforeBirth <- summariseStartBeforeBirth(cdm = cdm, omopTable = omopTable, strata = stratification, start_date_name = start_date_name)
    }
    res <- dplyr::bind_rows(res)

    if (nrow(res) == 0) {
      return(omopgenerics::emptySummarisedResult(settings = set))
    }

    res <- res |> dplyr::bind_rows(res |> dplyr::left_join(denominator |> dplyr::select(dplyr::any_of(strata), "estimate_type", "denominator" = "estimate_value"), by = c("estimate_type", strata)) |>
                                     dplyr::mutate(estimate_value = sprintf("%.2f", as.numeric(.data$estimate_value) / as.numeric(denominator) * 100),
                                                   estimate_name = "percentage",
                                                   estimate_type = "percentage") |>
                                     dplyr::select(!denominator)) |>
      dplyr::mutate(omop_table = table)
    res
  }) |>
    dplyr::bind_rows()

if (nrow(result) == 0){
  return(omopgenerics::emptySummarisedResult(settings = set))
}
result <- result |>
  omopgenerics::uniteStrata(cols = strata[strata!= "interval"]) |>
  addTimeInterval() |>
  omopgenerics::uniteAdditional(cols = "time_interval") |>
  omopgenerics::uniteGroup(cols = "omop_table") |>
  dplyr::arrange(.data$additional_level) |>
  dplyr::mutate(result_id = 1L,
                cdm_name = omopgenerics::cdmName(cdm),
                variable_level = NA_character_) |>
  omopgenerics::newSummarisedResult(settings = set)

# drop temp tables
omopgenerics::dropSourceTable(cdm = cdm, name = dplyr::starts_with(tablePrefix))

return(result)
}


summariseEndBeforeStart <- function(omopTable, strata, start_date_name, end_date_name) {

  result <- omopTable |>
    dplyr::filter(.data[[end_date_name]] < .data[[start_date_name]]) |>
    summariseCountsInternal(strata = strata, counts = "records") |>
    dplyr::mutate(estimate_name = "count",
                  variable_name = "Records with end date before start date")
  return(result)
}

summariseStartBeforeBirth <- function(cdm, omopTable, strata, start_date_name) {

  result <- omopTable |> dplyr::left_join(cdm$person |> dplyr::select("person_id", "birth_datetime" ), by = "person_id") |>
    dplyr::filter(as.Date(.data[[start_date_name]]) < as.Date(.data$birth_datetime)) |>
    summariseCountsInternal(strata = strata, counts = "records")|>
    dplyr::mutate(estimate_name = "count",
                  variable_name = "Records with start date before birthdate")
  return(result)
}
