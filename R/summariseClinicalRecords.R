
#' Summarise an omop table from a cdm object. You will obtain
#' information related to the number of records, number of subjects, whether the
#' records are in observation, number of present domains and number of present
#' concepts.
#'
#' @param cdm A cdm_reference object.
#' @param omopTableName A character vector of the names of the tables to
#' summarise in the cdm object.
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
#' @param ageGroup A list of age groups to stratify results by.
#' @param sex Boolean variable. Whether to stratify by sex (TRUE) or not
#' (FALSE).
#' @inheritParams dateRange-startDate
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
#'   typeConcept = TRUE
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
                                     sex = FALSE,
                                     ageGroup = NULL,
                                     dateRange = NULL) {
  # Initial checks ----
  cdm <- omopgenerics::validateCdmArgument(cdm)
  opts <- omopgenerics::omopTables()
  opts <- opts[opts %in% names(cdm)]
  omopgenerics::assertChoice(omopTableName, choices = opts)
  dateRange <- validateStudyPeriod(cdm, dateRange)
  estimates <- PatientProfiles::availableEstimates(
    variableType = "numeric", fullQuantiles = TRUE) |>
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


  # warnings for observation_period
  warnStandardConcept <- standardConcept & !missing(standardConcept)
  warnSourceVocabulary <- sourceVocabulary & !missing(sourceVocabulary)
  warnDomainId <- domainId & !missing(domainId)

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

    # restrict study period
    omopTable <- restrictStudyPeriod(omopTable, dateRange)
    if (is.null(omopTable)) return(omopgenerics::emptySummarisedResult())

    cli::cli_inform(c("i" = "Adding variables of interest to {.pkg {table}}."))
    omopTable <- omopTable |>
      # add variables of interest
      addVariables(inObservation, standardConcept, sourceVocabulary, domainId, typeConcept) |>
      # add demographics and year
      addStratifications(
        indexDate = "start_date",
        sex = sex,
        ageGroup = ageGroup,
        interval = "overall",
        name = omopgenerics::uniqueTableName(prefix)
      )

    cli::cli_inform(c("i" = "Summarising records per person in {.pkg {table}}."))
    resultsRecordPerPerson <- summariseRecordsPerPerson(
      x = omopTable, den = den, strata = strata, estimates = recordsPerPerson
    ) |>
      dplyr::select(!dplyr::starts_with("group_"))

    # Summary
    if (inObservation | standardConcept | sourceVocabulary | domainId | typeConcept) {
      denominator <- resultsRecordPerPerson |>
        dplyr::filter(.data$variable_name == "Number records") |>
        dplyr::select("strata_name", "strata_level", den = "estimate_value")
      variables <- variablesToSummarise(
        inObservation, standardConcept, sourceVocabulary, domainId, typeConcept
      )
      cli::cli_inform(c("i" = "Summarising {.pkg {table}}: {.var {variables}}."))
      resultVariables <- purrr::map(strata, \(stratax) {
        agregated <- omopTable |>
          dplyr::group_by(dplyr::across(dplyr::all_of(c(stratax, variables)))) |>
          dplyr::summarise(n = as.integer(dplyr::n()), .groups = "drop") |>
          dplyr::collect() |>
          omopgenerics::uniteStrata(cols = stratax)
        purrr::map(variables, \(var) {
          res <- agregated |>
            dplyr::group_by(dplyr::across(dplyr::all_of(c(
              "strata_name", "strata_level", var
            )))) |>
            dplyr::summarise(count = sum(.data$n), .groups = "drop")|>
            dplyr::inner_join(
              denominator, by = c("strata_name", "strata_level")
            ) |>
            dplyr::mutate(
              percentage = sprintf("%.2f", 100 * as.numeric(.data$count) / as.numeric(.data$den)),
              count = sprintf("%i", as.integer(.data$count))
            ) |>
            dplyr::select(!"den") |>
            tidyr::pivot_longer(
              cols = c("count", "percentage"),
              names_to = "estimate_name",
              values_to = "estimate_value"
            ) |>
            dplyr::mutate(estimate_type = dplyr::if_else(
              .data$estimate_name == "count", "integer", "percentage"
            ))
          if (var == "in_observation") {
            res <- res |>
              dplyr::mutate(
                variable_name = "In observation",
                variable_level = dplyr::if_else(.data[[var]] == 1, "Yes", "No")
              )
          } else if (var == "doamin_id") {
            res <- res |>
              dplyr::mutate(
                variable_name = "Domain",
                variable_level = .data[[var]]
              )
          } else if (var == "standard_concept") {
            res <- res |>
              dplyr::mutate(
                variable_name = "Standard concept",
                variable_level = .data[[var]]
              )
          } else if (var == "source_vocabulary") {
            res <- res |>
              dplyr::mutate(
                variable_name = "Source vocabulary",
                variable_level = .data[[var]]
              )
          } else if (var == "type_concept") {
            res <- res |>
              dplyr::mutate(
                variable_name = "Type concept id",
                type_concept = as.integer(.data$type_concept)
              ) |>
              dplyr::left_join(conceptTypes, by = "type_concept") |>
              dplyr::mutate(type_name = dplyr::coalesce(
                .data$type_name, paste0("Unknown type concept: ", .data$type_concept)
              )) |>
              dplyr::rename(variable_level = "type_name")
          }
          res <- res |>
            dplyr::select(!dplyr::all_of(var))
          return(res)
        }) |>
          dplyr::bind_rows()
      }) |>
        dplyr::bind_rows() |>
        omopgenerics::uniteAdditional() |>
        dplyr::mutate(result_id = 1L, cdm_name = omopgenerics::cdmName(cdm))
    } else {
      resultVariables <- NULL
    }

    fullResult <- dplyr::bind_rows(resultsRecordPerPerson, resultVariables) |>
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
    dplyr::left_join(
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
        counts =  FALSE,
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

  omopgenerics::dropTable(cdm = cdm, name = dplyr::starts_with(prefix))

  return(result)
}
variablesToSummarise <- function(inObservation, standardConcept, sourceVocabulary, domainId, typeConcept) {
  c("in_observation"[inObservation], "standard_concept"[standardConcept],
    "source_vocabulary"[sourceVocabulary], "domain_id"[domainId],
    "type_concept"[typeConcept])
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
      "cohort_definition_id", "person_id" = "subject_id", "sex"
    ))) |>
    dplyr::inner_join(cdm[[nm]], by = "cohort_definition_id") |>
    dplyr::select(!"cohort_definition_id") |>
    dplyr::distinct() |>
    dplyr::compute(name = name, temporary = FALSE)

  omopgenerics::dropSourceTable(cdm = cdm, name = nm)

  return(demographics)
}
addVariables <- function(x, inObservation, standardConcept, sourceVocabulary, domainId, typeConcept) {

  name <- omopgenerics::tableName(x)

  newNames <- c(
    # here to support death table
    person_id = "person_id",
    id = omopgenerics::omopColumns(table = name, field = "unique_id"),
    start_date = omopgenerics::omopColumns(table = name, field = "start_date"),
    end_date = omopgenerics::omopColumns(table = name, field = "end_date"),
    standard = omopgenerics::omopColumns(table = name, field = "standard_concept"),
    source = omopgenerics::omopColumns(table = name, field = "source_concept"),
    type_concept = omopgenerics::omopColumns(table = name, field = "type_concept")
  )

  newNames <- newNames[!is.na(newNames)]
  cdm <- omopgenerics::cdmReference(x)

  x <- x |>
    dplyr::select(dplyr::all_of(newNames)) |>
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

  variables <- c("id", "person_id", "start_date", variablesToSummarise(
    inObservation, standardConcept, sourceVocabulary, domainId, typeConcept
  ))

  x |>
    dplyr::select(dplyr::all_of(variables))
}
reduceDemicals <- function(x, n) {
  id <- grepl(pattern = ".", x = x, fixed = TRUE) & !is.na(suppressWarnings(as.numeric(x)))
  x[id] <- sprintf(paste0("%.", n, "f"), as.numeric(x[id]))
  return(x)
}
