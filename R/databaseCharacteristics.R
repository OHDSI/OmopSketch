#' Summarise Database Characteristics for OMOP CDM
#'
#' @param cdm A `cdm_reference` object representing the Common Data Model (CDM) reference.
#' @param omopTableName A character vector specifying the OMOP tables from the CDM to include in the analysis.
#' If "person" is present, it will only be used for missing value summarisation.
#' @inheritParams interval
#' @param ageGroup A list of age groups to stratify the results by. Each element represents a specific age range.
#' @param sex Logical; whether to stratify results by sex (`TRUE`) or not (`FALSE`).
#' @inheritParams dateRange-startDate
#' @param conceptIdCount Logical; whether to summarise concept ID counts (`TRUE`) or not (`FALSE`).
#' @param ... additional arguments passed to the OmopSketch functions that are used internally.
#' @return A `summarised_result` object containing the results of the characterisation.
#' @export
#' @examples
#' \donttest{
#' cdm <- mockOmopSketch(numberIndividuals = 100)
#'
#' result <- databaseCharacteristics(cdm)
#'
#' PatientProfiles::mockDisconnect(cdm)
#' }

databaseCharacteristics <- function(cdm,
                                    omopTableName = c(
                                      "person", "observation_period", "visit_occurrence", "condition_occurrence", "drug_exposure", "procedure_occurrence",
                                      "device_exposure", "measurement", "observation", "death"
                                    ),
                                    sex = FALSE,
                                    ageGroup = NULL,
                                    dateRange = NULL,
                                    interval = "overall",
                                    conceptIdCount = FALSE,
                                    ...) {

  rlang::check_installed("CohortCharacteristics")

  cdm <- omopgenerics::validateCdmArgument(cdm)
  opts <- omopgenerics::omopTables()
  opts <- opts[opts %in% names(cdm)]
  omopgenerics::assertChoice(omopTableName, choices = opts)
  omopgenerics::assertLogical(sex, length = 1)
  ageGroup <- omopgenerics::validateAgeGroupArgument(ageGroup, multipleAgeGroup = FALSE)
  dateRange <- validateStudyPeriod(cdm, dateRange)
  omopgenerics::assertChoice(interval, c("overall", "years", "quarters", "months"), length = 1)
  omopgenerics::assertLogical(conceptIdCount, length = 1)

  args_list <- list(...)

  cli::cli_inform(paste("The characterisation will focus on the following OMOP tables: {omopTableName}"))

  startTime <- Sys.time()
  startTables <- CDMConnector::listSourceTables(cdm)
  result <- list()
  # Snapshot
  cli::cli_inform(paste(cli::symbol$arrow_right,"Getting cdm snapshot"))
  result$snapshot <- summariseOmopSnapshot(cdm)

  # Population Characteristics
  cli::cli_inform(paste(cli::symbol$arrow_right,"Getting population characteristics"))

  sexCohort <- if (sex) "Both"
  dateRangeCohort <- dateRange %||% c(NA, NA)


  if (!is.null(ageGroup)) {
    cdm <- omopgenerics::bind(
      CohortConstructor::demographicsCohort(cdm, "population_1", sex = sexCohort),
      CohortConstructor::demographicsCohort(cdm, "population_2", sex = sexCohort, ageRange = ageGroup$age_group),
      name = "population"
    )

    set <- omopgenerics::settings(cdm$population) |>
      dplyr::mutate(cohort_name = tolower(dplyr::if_else(
        is.na(.data$age_range), "general_population", paste0("age_group_", .data$age_range)
      ))) |>
      dplyr::select("cohort_definition_id", "cohort_name")
  } else {
    cdm$population <- CohortConstructor::demographicsCohort(cdm, "population", sex = sexCohort)

    set <- omopgenerics::settings(cdm$population) |>
      dplyr::mutate(cohort_name = "general_population") |>
      dplyr::select("cohort_definition_id", "cohort_name")
  }


  cdm$population <- cdm$population |>
    omopgenerics::newCohortTable(cohortSetRef = set, .softValidation = TRUE) |>
    CohortConstructor::trimToDateRange(dateRange = dateRangeCohort)

  if (sex) {
    cdm$population <- cdm$population |>
      PatientProfiles::addSexQuery()
  }

  result$populationCharacteristics <- cdm$population |>
    CohortCharacteristics::summariseCharacteristics(
      strata = list("sex")[sex],
      estimates = list(
        date = c("min", "q25", "median", "q75", "max"),
        numeric = c("min", "q25", "median", "q75", "max", "mean", "sd", "density"),
        categorical = c("count", "percentage"),
        binary = c("count", "percentage")
      )
    )

  omopgenerics::dropSourceTable(cdm = cdm, c("population_1", "population_2", "population"))


  # Summarise missing data
  cli::cli_inform(paste(cli::symbol$arrow_right,"Summarising missing data"))
  result$missingData <- do.call(
    summariseMissingData,
    c(list(
      cdm,
      omopTableName = omopTableName,
      sex = sex,
      ageGroup = ageGroup,
      interval = interval,
      dateRange = dateRange
    ), filter_args(summariseMissingData, args_list))
  )

  omopTableName <- omopTableName[omopTableName != "person"]

  if (conceptIdCount) {
    cli::cli_inform(paste(cli::symbol$arrow_right,"Summarising concept id counts"))
    result$conceptIdCount <- do.call(
      summariseConceptIdCounts,
      c(list(
        cdm,
        omopTableName = omopTableName,
        sex = sex,
        ageGroup = ageGroup,
        interval = interval,
        dateRange = dateRange
      ), filter_args(summariseConceptIdCounts, args_list))
    )
  }

  # Summarise clinical records
  cli::cli_inform(paste(cli::symbol$arrow_right,"Summarising clinical records"))
  result$clinicalRecords <- do.call(
    summariseClinicalRecords,
    c(list(
      cdm,
      omopTableName = omopTableName,
      sex = sex,
      ageGroup = ageGroup,
      dateRange = dateRange
    ), filter_args(summariseClinicalRecords, args_list))
  )

  # Summarize record counts
  cli::cli_inform(paste(cli::symbol$arrow_right,"Summarising record counts"))
  result$recordCounts <- do.call(
    summariseRecordCount,
    c(list(
      cdm,
      omopTableName,
      sex = sex,
      ageGroup = ageGroup,
      interval = interval,
      dateRange = dateRange
    ), filter_args(summariseRecordCount, args_list))
  )

  # Summarize in observation records
  cli::cli_inform(paste(cli::symbol$arrow_right,"Summarising in observation records, subjects, person-days, age and sex"))
  result$inObservation <- do.call(
    summariseInObservation,
    c(list(
      cdm$observation_period,
      output = c("record", "person", "person-days", "age", "sex"),
      interval = interval,
      sex = sex,
      ageGroup = ageGroup,
      dateRange = dateRange
    ), filter_args(summariseInObservation, args_list))
  )

  # Summarise observation period
  cli::cli_inform(paste(cli::symbol$arrow_right, "Summarising observation period"))
  result$observationPeriod <- do.call(
    summariseObservationPeriod,
    c(list(
      cdm$observation_period,
      sex = sex,
      ageGroup = ageGroup,
      dateRange = dateRange
    ), filter_args(summariseObservationPeriod, args_list))
  )

  # Combine results and export
  result <- result |>
    omopgenerics::bind()


  # Calculate duration and log
  dur <- abs(as.numeric(Sys.time() - startTime, units = "secs"))
  cli::cli_inform(
    paste(
      cli::symbol$smiley,
      "Database characterisation finished. Code ran in",
      floor(dur / 60), "min and",
      dur %% 60 %/% 1, "sec"
    )
  )
  endTables <- CDMConnector::listSourceTables(cdm)
  newTables <- setdiff(endTables, startTables)

  if(length(newTables)) {
    cli::cli_inform(c(
      "i" = "{length(newTables)} table{?s} created: {.val {newTables}}."
    ))
  }

  return(result)
}


filter_args <- function(fun, args) {
  x <- args[names(args) %in% names(formals(fun))]
  if (length(x) > 0) {
    return(as.list(x))
  }
  return(NULL)
}
