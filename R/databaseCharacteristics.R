
#' Summarise Database Characteristics for OMOP CDM
#'
#' @inheritParams consistent-doc
#' @inheritParams dateRange-startDate
#' @param conceptIdCounts Logical; whether to summarise concept ID counts
#' (`TRUE`) or not (`FALSE`).
#' @param ... additional arguments passed to the OmopSketch functions that are
#' used internally.
#'
#' @return A `summarised_result` object with the results.
#' @export
#'
#' @examples
#' \dontrun{
#' library(OmopSketch)
#' library(omock)
#' library(dplyr)
#' library(here)
#'
#' cdm <- mockCdmFromDataset(datasetName = "GiBleed", source = "duckdb")
#'
#' result <- databaseCharacteristics(
#'   cdm = cdm,
#'   sample = 100,
#'   omopTableName = c("drug_exposure", "condition_occurrence"),
#'   sex = TRUE,
#'   ageGroup = list(c(0, 50), c(51, 100)),
#'   interval = "years",
#'   conceptIdCounts = FALSE
#' )
#'
#' result |>
#'   glimpse()
#'
#' shinyCharacteristics(result = result, directory = here())
#'
#' cdmDisconnect(cdm = cdm)
#' }
#'
databaseCharacteristics <- function(cdm,
                                    omopTableName = c("visit_occurrence", "visit_detail",
                                      "condition_occurrence", "drug_exposure", "procedure_occurrence",
                                      "device_exposure", "measurement", "observation", "death"),
                                    sample = NULL,
                                    sex = FALSE,
                                    ageGroup = NULL,
                                    dateRange = NULL,
                                    interval = "overall",
                                    conceptIdCounts = FALSE,
                                    ...) {
  rlang::check_installed("CohortCharacteristics")
  rlang::check_installed("CohortConstructor")

  cdm <- omopgenerics::validateCdmArgument(cdm)
  opts <- clinicalTables()
  opts <- opts[opts %in% names(cdm)]
  if (missing(omopTableName)) {
    omopTableName <- omopTableName[omopTableName %in% names(cdm)]
  }

  omopgenerics::assertChoice(omopTableName, choices = opts)
  omopgenerics::assertLogical(sex, length = 1)
  ageGroup <- omopgenerics::validateAgeGroupArgument(ageGroup, multipleAgeGroup = FALSE)
  dateRange <- validateStudyPeriod(cdm, dateRange)
  omopgenerics::assertChoice(interval, c("overall", "years", "quarters", "months"), length = 1)
  omopgenerics::assertLogical(conceptIdCounts, length = 1)
  sample <- validateSample(sample = sample, cdm = cdm)
  args_list <- list(...)

  empty_tables <- c()
  for (table in omopTableName) {
    empty_tables <- c(empty_tables, table[omopgenerics::isTableEmpty(cdm[[table]])])
  }
  omopTableName <- omopTableName[!(omopTableName %in% empty_tables)]
  cli::cli_inform(paste("The characterisation will focus on the following OMOP tables: {omopTableName}"))

  startTime <- Sys.time()
  startTables <- omopgenerics::listSourceTables(cdm)

  if (!is.null(sample)) {
    cli::cli_inform(paste("The cdm is sampled to {sample}"))
    cdm <- sampleCdm(cdm = cdm, tables = c(omopTableName, "observation_period", "person"), sample = sample)
  }
  result <- list()
  # Snapshot
  cli::cli_inform(paste(cli::symbol$arrow_right, "Getting cdm snapshot"))
  result$snapshot <- summariseOmopSnapshot(cdm)

  # Population Characteristics
  cli::cli_inform(paste(cli::symbol$arrow_right, "Getting population characteristics"))

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

  # Summarising Person table
  cli::cli_inform(paste(cli::symbol$arrow_right, "Summarising person table"))

  result$person <- do.call(
    summarisePerson,
    c(list(cdm), filter_args(summarisePerson, args_list))
  )

  if (conceptIdCounts) {
    cli::cli_inform(paste(cli::symbol$arrow_right, "Summarising concept id counts"))
    result$conceptIdCounts <- do.call(
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
  cli::cli_inform(paste(cli::symbol$arrow_right, "Summarising clinical records"))
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


  # Summarise observation period
  cli::cli_inform(paste(cli::symbol$arrow_right, "Summarising observation period"))
  result$observationPeriod <- do.call(
    summariseObservationPeriod,
    c(list(
      cdm,
      sex = sex,
      ageGroup = ageGroup,
      dateRange = dateRange
    ), filter_args(summariseObservationPeriod, args_list))
  )

  # Summarize in observation records
  cli::cli_inform(paste(cli::symbol$arrow_right, "Summarising trends: records, subjects, person-days, age and sex"))
  result$trend <- do.call(
    summariseTrend,
    c(list(
      cdm = cdm,
      episode = "observation_period",
      event = c(omopTableName, "observation_period"),
      output = c("record", "person", "person-days", "age", "sex"),
      interval = interval,
      sex = sex,
      ageGroup = ageGroup,
      dateRange = dateRange
    ), filter_args(summariseTrend, args_list))
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
  endTables <- omopgenerics::listSourceTables(cdm)
  newTables <- setdiff(endTables, startTables)

  if (length(newTables)) {
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
