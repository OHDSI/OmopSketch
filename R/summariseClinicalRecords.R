#' Summarise an omop table from a cdm object. You will obtain
#' information related to the number of records, number of subjects, whether the
#' records are in observation, number of present domains, number of present
#' concepts, missing data and inconsistencies
#'
#' @param cdm A cdm_reference object.
#' @param omopTableName A character vector of the names of the tables to
#' summarise in the cdm object. Run `OmopSketch::clinicalTables()` to check the
#' available options.
#' @param recordsPerPerson Generates summary statistics for the number of
#' records per person. Set to NULL if no summary statistics are required.
#' @param inObservation Boolean variable. Whether to include the percentage of
#' records in observation.
#' @param standardConcept Boolean variable. Whether to summarise standard
#' concept information.
#' @param sourceVocabulary Boolean variable.  Whether to summarise source
#' vocabulary information.
#' @param domainId  Boolean variable. Whether to summarise domain id of standard
#' concept id information.
#' @param typeConcept  Boolean variable. Whether to summarise type concept id
#' field information.
#' @param missingData Boolean variable. Whether to summarise the number of missing data
#' @param endBeforeStart  Boolean variable. Whether to summarise the number of records
#'  with end date before start date
#' @param startBeforeBirth  Boolean variable. Whether to summarise the number of records
#' with start date before the person's birth date.
#' @param ageGroup A list of age groups to stratify results by.
#' @param sex Boolean variable. Whether to stratify by sex (TRUE) or not
#' (FALSE).
#' @inheritParams dateRange-startDate
#' @param .options A named list with additional argument for summarise missing data.
#' `OmopSketch::missingDataOptions()` shows allowed arguments and their default values.
#' @return A summarised_result object.
#' @export
#' @examples
#' \donttest{
#' cdm <- mockOmopSketch()
#'
#' summarisedResult <- summariseClinicalRecords(
#'   cdm = cdm,
#'   omopTableName = "condition_occurrence",
#'   recordsPerPerson = c("mean", "sd"),
#'   inObservation = TRUE,
#'   standardConcept = TRUE,
#'   sourceVocabulary = TRUE,
#'   domainId = TRUE,
#'   typeConcept = TRUE,
#'   missingData = TRUE,
#'   endBeforeStart = TRUE,
#'   startBeforeBirth = TRUE
#' )
#'
#' summarisedResult
#'
#' PatientProfiles::mockDisconnect(cdm = cdm)
#' }
summariseClinicalRecords <- function(cdm,
                                     omopTableName,
                                     recordsPerPerson = c("mean", "sd", "median", "q25", "q75", "min", "max"),
                                     inObservation = TRUE,
                                     standardConcept = TRUE,
                                     sourceVocabulary = TRUE,
                                     domainId = TRUE,
                                     typeConcept = TRUE,
                                     missingData = TRUE,
                                     endBeforeStart = TRUE,
                                     startBeforeBirth = TRUE,
                                     sex = FALSE,
                                     ageGroup = NULL,
                                     dateRange = NULL,
                                     .options = NULL) {
  # Initial checks ----
  cdm <- omopgenerics::validateCdmArgument(cdm)
  omopgenerics::assertChoice(omopTableName, choices = clinicalTables(), unique = TRUE)
  dateRange <- validateStudyPeriod(cdm, dateRange)
  estimates <- PatientProfiles::availableEstimates(
    variableType = "numeric", fullQuantiles = TRUE
  ) |>
    dplyr::pull("estimate_name")
  omopgenerics::assertChoice(recordsPerPerson, choices = estimates, null = TRUE)
  recordsPerPerson <- unique(recordsPerPerson)
  if (is.null(recordsPerPerson)) recordsPerPerson <- character()
  omopgenerics::assertLogical(inObservation, length = 1)
  omopgenerics::assertLogical(standardConcept, length = 1)
  omopgenerics::assertLogical(sourceVocabulary, length = 1)
  omopgenerics::assertLogical(domainId, length = 1)
  omopgenerics::assertLogical(typeConcept, length = 1)
  omopgenerics::assertLogical(sex, length = 1)
  ageGroup <- omopgenerics::validateAgeGroupArgument(ageGroup, multipleAgeGroup = FALSE)

  .options <- defaultOptions(.options)

  # warnings for observation_period
  warnStandardConcept <- standardConcept & !missing(standardConcept)
  warnSourceVocabulary <- sourceVocabulary & !missing(sourceVocabulary)
  warnDomainId <- domainId & !missing(domainId)
  warnEndBeforeStart <- endBeforeStart & !missing(endBeforeStart)

  # prefix
  prefix <- omopgenerics::tmpPrefix()

  # get strata
  strata <- c(
    list(character()),
    omopgenerics::combineStrata(strataCols(sex = sex, ageGroup = ageGroup))
  )

  # create denominator for record count
  den <- denominator(
    cdm = cdm,
    sex = sex,
    ageGroup = ageGroup,
    name = omopgenerics::uniqueTableName(prefix)
  )

  set <- createSettings(
    result_type = "summarise_clinical_records", study_period = dateRange
  )

  result <- purrr::map(omopTableName, \(table) {
    # check that table is not empty
    omopTable <- dplyr::ungroup(cdm[[table]])
    if (omopgenerics::isTableEmpty(omopTable)) {
      cli::cli_warn("{table} is empty.")
      return(omopgenerics::emptySummarisedResult())
    }
    prefix <- omopgenerics::tmpPrefix()

    # warn if observation_period
    if ("observation_period" == table) {
      if (warnStandardConcept) {
        "standardConcept turned to FALSE for observation_period OMOP table" |>
          rlang::set_names("i") |>
          cli::cli_inform()
      }
      standardConcept <- FALSE
      if (warnSourceVocabulary) {
        "sourceVocabulary turned to FALSE for observation_period OMOP table" |>
          rlang::set_names("i") |>
          cli::cli_inform()
      }
      sourceVocabulary <- FALSE
      if (warnDomainId) {
        "domainId turned to FALSE for observation_period OMOP table" |>
          rlang::set_names("i") |>
          cli::cli_inform()
      }
      domainId <- FALSE
    }
    if (omopgenerics::omopColumns(table = table, field = "start_date") == omopgenerics::omopColumns(table = table, field = "end_date")){
      if (warnEndBeforeStart){
        "endBeforeStart turned to FALSE for {.pkg {table}}" |>
          rlang::set_names("i") |>
          cli::cli_inform()
      }
      endBeforeStart <- FALSE
    }
    # restrict study period
    omopTable <- restrictStudyPeriod(omopTable, dateRange)
    if (is.null(omopTable)) {
      return(omopgenerics::emptySummarisedResult())
    }
    cli::cli_inform(c("i" = "Adding variables of interest to {.pkg {table}}."))
    omopTable <- omopTable |>
      addStratifications(
        indexDate = omopgenerics::omopColumns(table, field = "start_date"),
        sex = sex,
        ageGroup = ageGroup,
        interval = "overall",
        name = omopgenerics::uniqueTableName(prefix)
      )
    x <- omopTable |>
      addVariables(
        tableName = table, inObservation = inObservation,
        standardConcept = standardConcept,
        sourceVocabulary = sourceVocabulary,
        domainId = domainId,
        typeConcept = typeConcept,
        startBeforeBirth = startBeforeBirth,
        endBeforeStart = endBeforeStart
      ) |>
      dplyr::compute(name = omopgenerics::uniqueTableName(prefix))
    result <- list()
    cli::cli_inform(c("i" = "Summarising records per person in {.pkg {table}}."))
    result$recordPerPerson <- summariseRecordsPerPerson(
      x = x, den = den, strata = strata, estimates = recordsPerPerson
    ) |>
      dplyr::select(!dplyr::starts_with("group_"))

    variables <- variablesToSummarise(inObservation = inObservation, standardConcept = standardConcept, sourceVocabulary = sourceVocabulary, domainId = domainId, typeConcept = typeConcept, startBeforeBirth = startBeforeBirth, endBeforeStart = endBeforeStart)

    if (length(variables)) {
    res <- list()
    if (inObservation) {
      cli::cli_inform(c("i" = "Summarising records in observation in {.pkg {table}}."))
      strataInObs <- lapply(strata, function(x) c(x, "in_observation"))
      res$inObs <- x |>
        summariseCountsInternal(strata = strataInObs, counts = "records") |>
        dplyr::mutate(
          estimate_name = "count",
          variable_name = "In observation",
          variable_level = dplyr::if_else(.data$in_observation == 1, "Yes", "No")
        )
    }
    if (domainId) {
      cli::cli_inform(c("i" = "Summarising domains in {.pkg {table}}."))
      strataDomain <- lapply(strata, function(x) c(x, "domain_id"))
      res$domain <- x |>
        summariseCountsInternal(strata = strataDomain, counts = "records") |>
        dplyr::mutate(
          estimate_name = "count",
          variable_name = "Domain",
          variable_level = .data$domain_id
        )
    }
    if (standardConcept) {
      cli::cli_inform(c("i" = "Summarising standard concepts in {.pkg {table}}."))
      strataStandard <- lapply(strata, function(x) c(x, "standard_concept"))
      res$standardConcept <- x |>
        summariseCountsInternal(strata = strataStandard, counts = "records") |>
        dplyr::mutate(
          estimate_name = "count",
          variable_name = "Standard concept",
          variable_level = .data$standard_concept
        )
    }
    if (sourceVocabulary) {
      cli::cli_inform(c("i" = "Summarising source vocabularies in {.pkg {table}}."))
      strataSource <- lapply(strata, function(x) c(x, "source_vocabulary"))

      # Summarise and annotate
      res$sourceVocab <- x |>
        summariseCountsInternal(strata = strataSource, counts = "records") |>
        dplyr::mutate(
          estimate_name = "count",
          variable_name = "Source vocabulary",
          variable_level = .data$source_vocabulary
        )
    }
    if (typeConcept) {
      cli::cli_inform(c("i" = "Summarising concept types in {.pkg {table}}."))
      strataType <- lapply(strata, function(x) c(x, "type_concept"))
      res$typeConcept <- x |>
        summariseCountsInternal(strata = strataType, counts = "records") |>
        dplyr::mutate(
          estimate_name = "count",
          variable_name = "Type concept id",
          type_concept = as.integer(.data$type_concept)
        ) |>
        dplyr::left_join(conceptTypes, by = "type_concept") |>
        dplyr::mutate(type_name = dplyr::coalesce(
          .data$type_name, paste0("Unknown type concept: ", .data$type_concept)
        )) |>
        dplyr::rename(variable_level = "type_name")
    }
    if (startBeforeBirth) {
      cli::cli_inform(c("i" = "Summarising records with start before birth date in {.pkg {table}}."))
      res$sbb <- x |>
        dplyr::filter(.data$start_before_birth == 1) |>
        summariseCountsInternal(strata = strata, counts = "records") |>
        dplyr::mutate(
          estimate_name = "count",
          variable_name = "Start date before birth date",
          variable_level = NA_character_
        )
    }
    if (endBeforeStart) {
      cli::cli_inform(c("i" = "Summarising records with end date before start date in {.pkg {table}}."))
      res$ebs <- x |>
        dplyr::filter(.data$end_before_start == 1) |>
        summariseCountsInternal(strata = strata, counts = "records") |>
        dplyr::mutate(
          estimate_name = "count",
          variable_name = "End date before start date",
          variable_level = NA_character_
        )
    }

    denominator <- resultsRecordPerPerson |>
      dplyr::filter(.data$variable_name == "Number records") |>
      dplyr::select("strata_name", "strata_level", den = "estimate_value")

    res <- res |>
      dplyr::bind_rows() |>
      dplyr::select(!dplyr::any_of(variables)) |>
      omopgenerics::uniteStrata(cols = strataCols(sex = sex, ageGroup = ageGroup))

    result$variables <- res |>
      dplyr::bind_rows(
        res |>
          dplyr::select("strata_name", "strata_level", "variable_name", "variable_level", "estimate_value") |>
          dplyr::left_join(denominator, by = c("strata_name", "strata_level")) |>
          dplyr::mutate(
            estimate_value = sprintf("%.2f", 100 * as.numeric(.data$estimate_value) / as.numeric(.data$den)),
            estimate_name = "percentage",
            estimate_type = "percentage"
          )
      ) |>
      dplyr::select(!"den") |>
      omopgenerics::uniteAdditional()
    }

    if (missingData) {
      cli::cli_inform(c("i" = "Summarising missing data in {.pkg {table}}."))
      strataMissing <- c(
        list(character()),
        omopgenerics::combineStrata(c(strataCols(sex = sex, ageGroup = ageGroup, interval = .options[["interval"]])))
      )
      result$missing <- summariseMissingDataFromTable(
        omopTable = omopTable,
        table = table,
        cdm = cdm,
        col = .options[["col"]],
        dateRange = NULL,
        sample = .options[["sample"]],
        sex = FALSE,
        ageGroup = NULL,
        interval = .options[["interval"]],
        strata = strataMissing
      ) |>
        omopgenerics::uniteStrata(cols = strataCols(sex = sex, ageGroup = ageGroup)) |>
        dplyr::mutate(variable_name = "Column name") |>
        dplyr::rename("variable_level" = "column_name") |>
        addTimeInterval() |>
        omopgenerics::uniteAdditional(cols = "time_interval")
    }

    fullResult <- dplyr::bind_rows(result) |>
      dplyr::mutate(omop_table = .env$table) |>
      omopgenerics::uniteGroup(cols = "omop_table")

    # drop temp tables
    omopgenerics::dropSourceTable(cdm = cdm, name = dplyr::starts_with(prefix))

    # order
    fullResult |>
      dplyr::select("strata_name", "strata_level") |>
      dplyr::distinct() |>
      dplyr::cross_join(dplyr::tibble(variable_name = unique(c(
        "Number subjects", "Number records", "records_per_person",
        unique(fullResult$variable_name)
      )))) |>
      dplyr::mutate(order_id = dplyr::row_number()) |>
      dplyr::right_join(
        fullResult,
        by = c("strata_name", "strata_level", "variable_name"),
        relationship = "many-to-many"
      ) |>
      dplyr::arrange(.data$order_id, .data$variable_level, .data$estimate_name) |>
      dplyr::select(!"order_id")
  }) |>
    dplyr::bind_rows() |>
    dplyr::mutate(
      result_id = 1L,
      cdm_name = omopgenerics::cdmName(cdm)
    ) |>
  omopgenerics::newSummarisedResult(settings = set)

  # drop temp tables
  omopgenerics::dropSourceTable(cdm = cdm, name = dplyr::starts_with(prefix))

  return(result)
}

summariseRecordsPerPerson <- function(x, den, strata, estimates) {
  # strata
  strataCols <- unique(unlist(strata))

  cdm <- omopgenerics::cdmReference(x)
  prefix <- omopgenerics::tmpPrefix()
  nm <- omopgenerics::uniqueTableName(prefix = prefix)

  res <- den |>
    dplyr::full_join(
      x |>
        dplyr::group_by(dplyr::across(dplyr::all_of(c("person_id", strataCols)))) |>
        dplyr::summarise(n = as.integer(dplyr::n()), .groups = "drop"),
      by = c("person_id", strataCols)
    ) |>
    dplyr::mutate(n = dplyr::coalesce(.data$n, 0L)) |>
    dplyr::compute(name = nm, temporary = FALSE)

  result <- purrr::map(strata, \(stratax) {
    if (length(strata) > 1) {
      nm <- omopgenerics::uniqueTableName(prefix = prefix)
      resultx <- res |>
        dplyr::group_by(dplyr::across(dplyr::all_of(c("person_id", stratax)))) |>
        dplyr::summarise(n = sum(.data$n, na.rm = TRUE), .groups = "drop") |>
        dplyr::compute(name = nm, temporary = FALSE)
    } else {
      resultx <- res
    }
    resultx |>
      dplyr::mutate(number_subjects = dplyr::if_else(.data$n == 0, 0L, 1L)) |>
      dplyr::select(!"person_id") |>
      PatientProfiles::summariseResult(
        group = list(),
        includeOverallGroup = FALSE,
        strata = list(stratax),
        includeOverallStrata = FALSE,
        counts = FALSE,
        variables = list("number_subjects", "n"),
        estimates = list(c("count", "percentage"), c(estimates, "sum"))
      ) |>
      suppressMessages() |>
      dplyr::mutate(variable_name = dplyr::if_else(.data$variable_name == "number subjects", "Number subjects", .data$variable_name))
  }) |>
    dplyr::bind_rows() |>
    dplyr::mutate(
      variable_name = dplyr::if_else(
        .data$variable_name == "n",
        dplyr::if_else(.data$estimate_name == "sum", "Number records", "records_per_person"),
        .data$variable_name
      ),
      estimate_name = dplyr::if_else(
        .data$variable_name == "Number records", "count", .data$estimate_name
      ),
      estimate_value = reduceDemicals(.data$estimate_value, 4)
    )

  omopgenerics::dropSourceTable(cdm = cdm, name = dplyr::starts_with(prefix))

  return(result)
}
variablesToSummarise <- function(inObservation, standardConcept, sourceVocabulary, domainId, typeConcept, startBeforeBirth, endBeforeStart) {
  c(
    "in_observation"[inObservation], "standard_concept"[standardConcept],
    "source_vocabulary"[sourceVocabulary], "domain_id"[domainId],
    "type_concept"[typeConcept], "start_before_birth"[startBeforeBirth], "end_before_start"[endBeforeStart]
  )
}

denominator <- function(cdm, sex, ageGroup, name) {
  ageGroup <- ageGroup$age_group
  # denominator
  demographics <- CohortConstructor::demographicsCohort(
    cdm = cdm, name = name, ageRange = ageGroup
  ) |>
    suppressMessages()
  set <- omopgenerics::settings(demographics)
  if (sex) {
    demographics <- PatientProfiles::addSexQuery(demographics)
  }
  if (is.null(ageGroup)) {
    set <- set |>
      dplyr::select("cohort_definition_id")
  } else {
    set <- set |>
      dplyr::left_join(
        dplyr::tibble(
          age_group = names(ageGroup),
          age_range = purrr::map_chr(ageGroup, \(x) paste0(x[1], "_", x[2]))
        ),
        by = "age_range"
      ) |>
      dplyr::mutate(age_group = dplyr::coalesce(.data$age_group, .data$age_range)) |>
      dplyr::select("cohort_definition_id", "age_group")
  }
  nm <- omopgenerics::uniqueTableName()
  cdm <- omopgenerics::insertTable(cdm = cdm, name = nm, table = set)

  demographics <- demographics |>
    dplyr::select(dplyr::any_of(c(
      "cohort_definition_id",
      "person_id" = "subject_id", "sex"
    ))) |>
    dplyr::inner_join(cdm[[nm]], by = "cohort_definition_id") |>
    dplyr::select(!"cohort_definition_id") |>
    dplyr::distinct() |>
    dplyr::compute(name = name, temporary = FALSE)

  omopgenerics::dropSourceTable(cdm = cdm, name = nm)

  return(demographics)
}
addVariables <- function(x, tableName, inObservation, standardConcept, sourceVocabulary, domainId, typeConcept, startBeforeBirth, endBeforeStart) {
  newNames <- c(
    # here to support death table
    person_id = "person_id",
    id = omopgenerics::omopColumns(table = tableName, field = "unique_id"),
    start_date = omopgenerics::omopColumns(table = tableName, field = "start_date"),
    end_date = omopgenerics::omopColumns(table = tableName, field = "end_date"),
    standard = omopgenerics::omopColumns(table = tableName, field = "standard_concept"),
    source = omopgenerics::omopColumns(table = tableName, field = "source_concept"),
    type_concept = omopgenerics::omopColumns(table = tableName, field = "type_concept")
  )

  newNames <- newNames[!is.na(newNames)]
  cdm <- omopgenerics::cdmReference(x)

  x <- x |>
    dplyr::select(dplyr::all_of(newNames), dplyr::any_of(c("sex", "age_group"))) |>
    dplyr::mutate(end_date = dplyr::coalesce(.data$end_date, .data$start_date))


  # In observation
  if (inObservation) {
    x <- x |>
      dplyr::left_join(
        x |>
          dplyr::inner_join(
            cdm[["observation_period"]] |>
              dplyr::select(
                "person_id",
                obs_start = "observation_period_start_date",
                obs_end = "observation_period_end_date"
              ),
            by = "person_id"
          ) |>
          dplyr::filter(
            .data$start_date >= .data$obs_start &
              .data$end_date <= .data$obs_end
          ) |>
          dplyr::mutate(in_observation = 1L) |>
          dplyr::select(c("in_observation", "id", "person_id")),
        by = c("person_id", "id")
      ) |>
      dplyr::mutate(in_observation = dplyr::coalesce(.data$in_observation, 0L))
  }

  # Domain and standard
  if (domainId | standardConcept) {
    x <- x |>
      dplyr::left_join(
        cdm$concept |>
          dplyr::select(
            standard = "concept_id", "domain_id", "standard_concept"
          ),
        by = "standard"
      )
    if (standardConcept) {
      x <- x |>
        dplyr::mutate(standard = dplyr::case_when(
          .data$standard == 0 ~ "No matching concept",
          .data$standard_concept == "S" ~ "Standard",
          .data$standard_concept == "C" ~ "Classification",
          .default = "Source"
        ))
    }
  }

  # Source
  if (sourceVocabulary) {
    x <- x |>
      dplyr::left_join(
        cdm$concept |>
          dplyr::select(
            source = "concept_id", source_vocabulary = "vocabulary_id"
          ),
        by = "source"
      ) |>
      dplyr::mutate(source_vocabulary = dplyr::coalesce(
        .data$source_vocabulary, "No matching concept"
      ))
  }
  if (endBeforeStart) {
    x <- x |>
      dplyr::mutate(end_before_start = dplyr::if_else(.data[["end_date"]] < .data[["start_date"]], 1L, 0L))
  }
  if (startBeforeBirth) {
    if (!("birth_datetime" %in% colnames(cdm$person))) {
      person_tbl <- cdm$person |>
        dplyr::mutate(
          birthdate = as.Date(paste0(
            .data$year_of_birth, "-",
            dbplyr::sql("LPAD(CAST(month_of_birth AS VARCHAR), 2, '0')"), "-",
            dbplyr::sql("LPAD(CAST(day_of_birth AS VARCHAR), 2, '0')")
            )))  |>
        dplyr::select("person_id", "birthdate")
    } else {

      person_tbl <- cdm$person |>
        dplyr::mutate(
          birthdate = dplyr::case_when(
            !is.na(.data$birth_datetime) ~ as.Date(.data$birth_datetime),
            TRUE ~ as.Date(paste0(
              .data$year_of_birth, "-",
              dbplyr::sql("LPAD(CAST(month_of_birth AS VARCHAR), 2, '0')"), "-",
              dbplyr::sql("LPAD(CAST(day_of_birth AS VARCHAR), 2, '0')")
            ))
          )
        ) |>
        dplyr::select("person_id", "birthdate")
      }

    x <- x |>
      dplyr::left_join(person_tbl, by = "person_id") |>
      dplyr::mutate(
        start_before_birth = dplyr::if_else(
           as.Date(.data$start_date) < .data$birthdate,
          1L,
          0L
        )
      )
  }
  variables <- c("id", "person_id", "start_date", "sex", "age_group", variablesToSummarise(
    inObservation, standardConcept, sourceVocabulary, domainId, typeConcept, startBeforeBirth, endBeforeStart
  ))

  x |>
    dplyr::select(dplyr::any_of(variables))
}
reduceDemicals <- function(x, n) {
  id <- grepl(pattern = ".", x = x, fixed = TRUE) & !is.na(suppressWarnings(as.numeric(x)))
  x[id] <- sprintf(paste0("%.", n, "f"), as.numeric(x[id]))
  return(x)
}


defaultOptions <- function(userOptions) {
  defaultOpts <- list(
    col = NULL,
    interval = "overall",
    sample = 1000000
  )

  for (opt in names(userOptions)) {
    defaultOpts[[opt]] <- userOptions[[opt]]
  }

  return(defaultOpts)
}

#' Additional customisable arguments for summarising missingness in the `summariseClinicalRecords()` function.
#'
#' @description
#' This function provides a list of allowed inputs for the `.option` argument in
#' `summariseClinicalRecords`, and their corresponding default values.
#'
#' @return A named list of default options.
#'
#' @export
#'
#' @examples
#' missingDataOptions()
#'
missingDataOptions <- function() {
  return(defaultOptions(NULL))
}
