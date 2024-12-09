
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
#' @param dateRange A list containing the minimum and the maximum dates
#' defining the time range within which the analysis is performed.
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
                                     sourceVocabulary = FALSE,
                                     domainId = TRUE,
                                     typeConcept = TRUE,
                                     sex = FALSE,
                                     ageGroup = NULL,
                                     dateRange = NULL) {
  # Initial checks ----
  omopgenerics::validateCdmArgument(cdm)
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
  ageGroup <- omopgenerics::validateAgeGroupArgument(ageGroup, multipleAgeGroup = FALSE)[[1]]

  result <- purrr::map(omopTableName, \(x) {
    if(omopgenerics::isTableEmpty(cdm[[x]])) {
      cli::cli_warn(paste0(x, " omop table is empty. Returning an empty summarised omop table."))
      return(omopgenerics::emptySummarisedResult())
    }
    summariseClinicalRecord(
      x,
      cdm = cdm,
      recordsPerPerson = recordsPerPerson,
      inObservation = inObservation,
      standardConcept = standardConcept,
      sourceVocabulary = sourceVocabulary,
      domainId = domainId,
      typeConcept = typeConcept,
      sex = sex,
      ageGroup = ageGroup,
      dateRange = dateRange
    )
  }) |>
    omopgenerics::bind()

  return(result)
}

#' @noRd
summariseClinicalRecord <- function(omopTableName,
                                    cdm,
                                    recordsPerPerson,
                                    inObservation,
                                    standardConcept,
                                    sourceVocabulary,
                                    domainId,
                                    typeConcept,
                                    sex,
                                    ageGroup,
                                    dateRange,
                                    call = parent.frame(3)) {

  tablePrefix <-  omopgenerics::tmpPrefix()

  # Initial checks
  omopgenerics::assertClass(cdm[[omopTableName]], "omop_table", call = call)

  date <- startDate(omopTableName)

  omopTable <- cdm[[omopTableName]] |>
    dplyr::ungroup()

  omopTable <- restrictStudyPeriod(omopTable, dateRange)
  if(omopgenerics::isTableEmpty(omopTable)) {
    return(omopgenerics::emptySummarisedResult())
  }

  omopTable <- filterPersonId(omopTable) |>
    addStrataToOmopTable(date, ageGroup, sex)

  if ("observation_period" == omopTableName) {
    if (standardConcept) {
      if (!missing(standardConcept)) {
        cli::cli_inform("standardConcept turned to FALSE for observation_period OMOP table", call = call)
      }
      standardConcept <- FALSE
    }
    if (sourceVocabulary) {
      if (!missing(sourceVocabulary)) {
        cli::cli_inform("sourceVocabulary turned to FALSE for observation_period OMOP table", call = call)
      }
      sourceVocabulary <- FALSE
    }
    if (domainId) {
      if (!missing(domainId)) {
        cli::cli_inform("domainId turned to FALSE for observation_period OMOP table", call = call)
      }
      domainId <- FALSE
    }
  }

  strata <- getStrataList(sex, ageGroup)
  strata <- c(list(character()), strata)

  # Counts summary ----
  cli::cli_inform(c("i" = "Summarising {.pkg {omopTableName}} counts and records per person"))
  result <- summariseRecordsPerPerson(
    omopTable, date, sex, ageGroup, recordsPerPerson)

  # Summary concepts ----
  if (inObservation | standardConcept | sourceVocabulary | domainId | typeConcept) {

    denominator <- result |>
      dplyr::filter(.data$variable_name == "number records") |>
      dplyr::select("strata_name", "strata_level", "estimate_value")

    variables <- columnsVariables(
      inObservation, standardConcept, sourceVocabulary, domainId, typeConcept
    )

    cli::cli_inform(c("i" = "Summarising {.pkg {omopTableName}}: {.var {variables}}."))

    result <- result |>
      dplyr::bind_rows(
        omopTable |>
          addVariables(variables) |>
          dplyr::group_by(dplyr::across(dplyr::everything())) |>
          dplyr::summarise(n = as.integer(dplyr::n()), .groups = "drop") |>
          dplyr::collect() |>
          summaryData(denominator, strata, cdm)
      )
  }


  # Format output as a summarised result
  result <- result |>
    dplyr::mutate(
      "result_id" = 1L,
      "cdm_name" = omopgenerics::cdmName(cdm),
      "group_name" = "omop_table",
      "group_level" = omopTableName,
      "additional_name" = "overall",
      "additional_level" = "overall"
    ) |>
    omopgenerics::newSummarisedResult(settings = createSettings(result_type = "summarise_clinical_records", study_period = dateRange)
    )

  CDMConnector::dropTable(cdm, name = dplyr::starts_with(tablePrefix))

  return(result)
}

# Functions -----
getStrataList <- function(sex, ageGroup){
  omopgenerics::combineStrata(c("age_group"[!is.null(ageGroup)], "sex"[sex]))
}

summariseRecordsPerPerson <- function(omopTable, date, sex, ageGroup, recordsPerPerson) {
  # get strata
  strataCols <- c("sex"[sex], "age_group"[!is.null(ageGroup)])

  cdm <- omopgenerics::cdmReference(omopTable)
  tablePrefix <- omopgenerics::tmpPrefix()
  nm <- omopgenerics::uniqueTableName(tablePrefix)

  # denominator
  demographics <- CohortConstructor::demographicsCohort(
    cdm = cdm, name = nm, ageRange = ageGroup
  ) |>
    suppressMessages()
  set <- omopgenerics::settings(demographics)
  if (sex) demographics <- PatientProfiles::addSexQuery(demographics)
  if (is.null(ageGroup)) {
    set <- set |> dplyr::select("cohort_definition_id")
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

  # records per person
  x <- demographics |>
    dplyr::select(dplyr::any_of(c(
      "cohort_definition_id", "person_id" = "subject_id", "sex"
    ))) |>
    dplyr::distinct() |>
    dplyr::collect() |>
    dplyr::left_join(set, by = "cohort_definition_id") |>
    dplyr::select(!"cohort_definition_id") |>
    dplyr::left_join(
      omopTable |>
        dplyr::group_by(dplyr::across(dplyr::all_of(c("person_id", strataCols)))) |>
        dplyr::summarise(n = as.integer(dplyr::n()), .groups = "drop") |>
        dplyr::collect(),
      by = c("person_id", strataCols)
    ) |>
    dplyr::mutate(n = dplyr::coalesce(.data$n, 0L))

  omopgenerics::dropTable(cdm = cdm, name = dplyr::starts_with(tablePrefix))

  result <- list()

  result[["overall"]] <- summariseCounts(x, character(), recordsPerPerson)

  if (!is.null(ageGroup)) {
    result[["age_group"]] <- x |>
      summariseCounts(c("age_group"), recordsPerPerson)
  }

  if (sex) {
    result[["sex"]] <- x |>
      summariseCounts(c("sex"), recordsPerPerson)
  }

  if (!is.null(ageGroup) & sex) {
    result[["age_group_sex"]] <- x |>
      summariseCounts(c("age_group", "sex"), recordsPerPerson)
  }

  result <- result |>
    dplyr::bind_rows() |>
    dplyr::mutate(
      variable_name = dplyr::if_else(
        .data$variable_name == "n",
        dplyr::if_else(.data$estimate_name == "sum", "number records", "records_per_person"),
        .data$variable_name
      ),
      estimate_name = dplyr::if_else(
        .data$variable_name == "number records", "count", .data$estimate_name
      )
    )

  return(result)
}
summariseCounts <- function(x, strata, recordsPerPerson) {
  x |>
    dplyr::group_by(dplyr::across(dplyr::all_of(c("person_id", strata)))) |>
    dplyr::summarise(n = sum(.data$n), .groups = "drop") |>
    dplyr::mutate(number_subjects = dplyr::if_else(.data$n == 0, 0L, 1L)) |>
    dplyr::select(!"person_id") |>
    PatientProfiles::summariseResult(
      group = character(),
      includeOverallGroup = FALSE,
      strata = strata,
      includeOverallStrata = FALSE,
      counts =  FALSE,
      variables = list("number_subjects", "n"),
      estimates = list(c("count", "percentage"), c(recordsPerPerson, "sum"))
    ) |>
    suppressMessages()
}

getNumberPeopleInCdm <- function(cdm, ageGroup, sex, strata) {
  tablePrefix <- omopgenerics::tmpPrefix()

  x <- cdm |>
    addStrataToPeopleInObservation(ageGroup, sex, tablePrefix) |>
    dplyr::collect() |> # https://github.com/darwin-eu-dev/PatientProfiles/issues/706
    PatientProfiles::summariseResult(
      strata = strata,
      includeOverallStrata = TRUE,
      counts = TRUE,
      estimates = character()
    ) |>
    suppressMessages() |>
    dplyr::filter(.data$variable_name != "number records")

  omopgenerics::dropSourceTable(cdm = cdm, name = dplyr::starts_with(tablePrefix))

  return(x)
}

addCounts <- function(result, strata, omopTable){

  date <- startDate(omopgenerics::tableName(omopTable))

  result |>
    rbind(
      omopTable |>
        dplyr::select("person_id", dplyr::any_of(c("age_group","sex"))) |>
        # dplyr::collect() |> # https://github.com/darwin-eu-dev/PatientProfiles/issues/706
        PatientProfiles::summariseResult(strata = strata,
                                         includeOverallStrata = TRUE,
                                         counts = TRUE,
                                         estimates = c("max"))
    )

}

addSubjectsPercentage <- function(result, omopTable, people, strata){

  result |>
    rbind(
      result |>
        dplyr::filter(.data$variable_name == "number subjects") |>
        dplyr::rename("omop_table" = "estimate_value") |>
        dplyr::inner_join(
          people |> dplyr::rename("people" = "estimate_value"),
          by = c("result_id","cdm_name","group_name","group_level","strata_name",
                 "strata_level","variable_name","variable_level","estimate_name",
                 "estimate_type","additional_name","additional_level")
        ) |>
        dplyr::mutate("estimate_value" = as.numeric(.data$omop_table)/as.numeric(.data$people)*100) |>
        dplyr::select(-c("omop_table", "people")) |>
        dplyr::mutate("estimate_name" = "percentage",
                      "estimate_type" = "percentage")
    )

}

addRecordsPerPerson <- function(result, omopTable, recordsPerPerson, cdm, peopleStrata, strata){

  result |>
    rbind(
      peopleStrata |>
        dplyr::select("person_id", dplyr::any_of(c("sex", "age_group"))) |>
        dplyr::left_join(
          omopTable |>
            dplyr::group_by(.data$person_id, dplyr::across(dplyr::any_of(c("age_group","sex")))) |>
            dplyr::summarise(
              "records_per_person" = as.integer(dplyr::n()),
              .groups = "drop"
            ),
          by = c("person_id", "age_group", "sex")
        ) |>
        dplyr::mutate("records_per_person" = dplyr::if_else(
          is.na(.data$records_per_person),
          0L,
          .data$records_per_person
        )) |>
        dplyr::distinct() |>
        # dplyr::collect() |> # https://github.com/darwin-eu-dev/PatientProfiles/issues/706
        PatientProfiles::summariseResult(
          strata = strata,
          includeOverallStrata = TRUE,
          variables = "records_per_person",
          estimates = recordsPerPerson,
          counts = FALSE
        )
    )
}

addVariables <- function(x, variables) {

  name <- omopgenerics::tableName(x)

  newNames <- c(
    "person_id" = "person_id",
    "id" = tableId(name),
    "start_date" = startDate(name),
    "end_date"   = endDate(name),
    "standard" = standardConcept(name),
    "source" = sourceConcept(name),
    "type" = typeConcept(name)
  )

  newNames <- newNames[!is.na(newNames)]
  cdm <- omopgenerics::cdmReference(x)

  x <- x |>
    dplyr::select(dplyr::all_of(newNames), dplyr::any_of(c("age_group", "sex")))

  # Domain and standard ----
  if (any(c("domain_id", "standard") %in% variables)) {
    x <- x |>
      dplyr::left_join(
        cdm$concept |>
          dplyr::select(
            "standard" = "concept_id", "domain_id", "standard_concept"
          ),
        by = "standard"
      )
    if ("standard" %in% variables) {
      x <- x |>
        dplyr::mutate("standard" = dplyr::case_when(
          .data$standard == 0 ~ "No matching concept",
          .data$standard_concept == "S" ~ "Standard",
          .data$standard_concept == "C" ~ "Classification",
          .default = "Source"
        ))
    }
  }
  # Source ----
  if ("source" %in% variables) {
    x <- x |>
      dplyr::left_join(
        cdm$concept |>
          dplyr::select(
            "source" = "concept_id", "vocabulary" = "vocabulary_id"
          ),
        by = "source"
      ) |>
      dplyr::mutate(
        vocabulary = dplyr::if_else(is.na(.data$vocabulary), "No matching concept", .data$vocabulary)
      ) |>
      dplyr::rename("source_concept" = "source", "source" = "vocabulary")
  }
  # In observation ----
  if ("in_observation" %in% variables) {
    x <- x |>
      dplyr::left_join(
        x |>
          dplyr::left_join(
            cdm[["observation_period"]] |>
              dplyr::select("person_id",
                            "obs_start" = "observation_period_start_date",
                            "obs_end" = "observation_period_end_date"),
            by = "person_id"
          ) |>
          dplyr::filter(
            .data$start_date >= .data$obs_start &
              .data$end_date <= .data$obs_end
          ) |>
          dplyr::mutate("in_observation" = 1L) |>
          dplyr::select(c("in_observation", "id", "person_id")),
        by = c("person_id", "id")
      ) |>
      dplyr::distinct()
  }

  x <- x |>
    dplyr::select(dplyr::all_of(variables), dplyr::any_of(c("age_group", "sex"))) |>
    dplyr::mutate(dplyr::across(dplyr::everything(), ~as.character(.)))

  return(x)
}

columnsVariables <- function(inObservation, standardConcept, sourceVocabulary, domainId, typeConcept) {
  c("in_observation", "standard", "domain_id", "source", "type" )[c(
    inObservation, standardConcept, domainId, sourceVocabulary, typeConcept
  )]
}

summaryData <- function(x, denominator, strata, cdm) {

  cols <- colnames(x)

  results <- list()

  # in observation ----
  if ("in_observation" %in% cols) {
    results[["obs"]] <- x |>
      dplyr::mutate("in_observation" = dplyr::if_else(
        .data$in_observation == "1", "Yes", "No"
      )) |>
      formatResults("In observation", "in_observation", denominator, strata)
  }

  # standard -----
  if ("standard" %in% cols) {
    results[["standard"]] <- x |>
      formatResults("Standard concept", "standard", denominator, strata)
  }

  # source ----
  if ("source" %in% cols) {
    results[["source"]] <- x |>
      formatResults("Source vocabulary", "source", denominator, strata)
  }

  # domain ----
  if ("domain_id" %in% cols) {
    results[["domain"]] <- x |>
      formatResults("Domain", "domain_id", denominator, strata)
  }

  # type ----
  if ("type" %in% cols) {
    xx <- x |>
      formatResults("Type concept id", "type", denominator, strata) |>
      dplyr::left_join(
        conceptTypes |>
          dplyr::select(
            "variable_level" = "type_concept_id",
            "new_variable_level" = "type_name"
          ),
        by = "variable_level"
      ) |>
      dplyr::mutate("variable_level" = dplyr::if_else(
        is.na(.data$new_variable_level),
        .data$variable_level,
        paste0(.data$new_variable_level, " (", .data$variable_level, ")")
      ))
    if (xx |>
        dplyr::filter(is.na(.data$new_variable_level)) |>
        dplyr::tally() |>
        dplyr::pull() > 0) {
      namesTypes <- cdm[["concept"]] |>
        dplyr::filter(.data$domain_id == "Type Concept") |>
        dplyr::select(
          "variable_level" = "concept_id", "new_variable_level" = "concept_name"
        ) |>
        dplyr::collect() |>
        dplyr::mutate(dplyr::across(dplyr::everything(), as.character))
      xx <- xx |>
        dplyr::select(-"new_variable_level") |>
        dplyr::left_join(
          namesTypes,
          by = "variable_level"
        ) |>
        dplyr::mutate("variable_level" = dplyr::if_else(
          is.na(.data$new_variable_level),
          .data$variable_level,
          paste0(.data$new_variable_level, " (", .data$variable_level, ")")
        ))
    }
    results[["type"]] <- xx |>
      dplyr::select(-"new_variable_level")
  }

  results <- dplyr::bind_rows(results)

  return(results)
}

formatResults <- function(x, variableName, variableLevel, denominator, strata) {
  attr(denominator, "settings")$strata <- paste(unique(unlist(strata)), collapse = " &&& ")
  denominator <- denominator |>
    dplyr::select("strata_name", "strata_level", "denominator" = "estimate_value") |>
    dplyr::filter(.data$strata_name != "overall") |>
    omopgenerics::splitStrata()

  strataCols <- unique(unlist(strata))

  result <- list()
  for (strat in strata) {
    res <- x |>
      dplyr::group_by(dplyr::across(dplyr::all_of(c(variableLevel, strat)))) |>
      dplyr::summarise("count" = sum(.data$n), .groups = "drop")
    for (col in strataCols) {
      if (!col %in% colnames(res)) {
        res <- res |> dplyr::mutate(!!col := "overall")
      }
    }
    result[[paste0(strat, collapse = "_")]] <- res |>
      dplyr::inner_join(denominator, by = strataCols) |>
      dplyr::mutate("percentage" = 100 * .data$count / as.numeric(.data$denominator)) |>
      dplyr::mutate(dplyr::across(dplyr::everything(), as.character)) |>
      tidyr::pivot_longer(
        cols = c("count", "percentage"),
        names_to = "estimate_name",
        values_to = "estimate_value"
      ) |>
      dplyr::mutate(
        "variable_name" = .env$variableName,
        "variable_level" = as.character(.data[[variableLevel]]),
        "estimate_type" = dplyr::if_else(
          .data$estimate_name == "count", "integer", "percentage"
        )
      ) |>
      visOmopResults::uniteStrata(cols = strataCols) |>
      dplyr::select(
        "strata_name", "strata_level", "variable_name", "variable_level",
        "estimate_name", "estimate_type", "estimate_value"
      ) |>
      dplyr::ungroup()
  }

  dplyr::bind_rows(result)
}
