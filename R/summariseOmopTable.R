
#' Summarise an omop_table from a cdm_reference object. You will obtain
#' information related to the number of records, number of subjects, whether the
#' records are in observation, number of present domains and number of present
#' concepts.
#'
#' @param omopTable An omop_table object.
#' @param recordsPerPerson Estimates to summarise the number of records per
#' person.
#' @param inObservation Whether to include the percentage of records in
#' observation.
#' @param standardConcept Whether to summarise standard concept.
#' @param sourceVocabulary Whether to summarise source vocabulary.
#' @param domainId Whether to summarise domain id of standard concept id.
#' @param typeConcept Whether to summarise type concept id field.
#'
#' @return A summarised_result object with the summarised data.
#'
#' @export
#'
summariseOmopTable <- function(omopTable,
                               recordsPerPerson = c("mean", "sd", "median", "q25", "q75", "min", "max"),
                               inObservation = TRUE,
                               standardConcept = TRUE,
                               sourceVocabulary = FALSE,
                               domainId = TRUE,
                               typeConcept = TRUE) {

  # Initial checks ----
  assertClass(omopTable, "omop_table")

  omopTable |>
    omopgenerics::tableName() |>
    assertChoice(choices = tables$table_name)

  estimates <- PatientProfiles::availableEstimates(
    variableType = "numeric", fullQuantiles = TRUE) |>
    dplyr::pull("estimate_name")
  assertChoice(recordsPerPerson, choices = estimates, null = TRUE)

  recordsPerPerson <- unique(recordsPerPerson)

  assertLogical(inObservation, length = 1)
  assertLogical(standardConcept, length = 1)
  assertLogical(sourceVocabulary, length = 1)
  assertLogical(domainId, length = 1)
  assertLogical(typeConcept, length = 1)

  if ("observation_period" == omopgenerics::tableName(omopTable)) {
    if(standardConcept){
      if(!missing(standardConcept)){
        cli::cli_warn("standardConcept turned to FALSE, as omopTable provided is observation_period")
      }
      standardConcept <- FALSE
    }
    if(sourceVocabulary){
      if(!missing(sourceVocabulary)){
        cli::cli_warn("sourceVocabulary turned to FALSE, as omopTable provided is observation_period")
      }
      sourceVocabulary <- FALSE
    }
    if(domainId){
      if(!missing(domainId)){
        cli::cli_warn("domainId turned to FALSE, as omopTable provided is observation_period")
      }
      domainId <- FALSE
    }
  }

  cdm <- omopgenerics::cdmReference(omopTable)
  omopTable <- omopTable |> dplyr::ungroup()

  people <- getNumberPeopleInCdm(cdm)
  result <- omopgenerics::emptySummarisedResult()

  if(omopTable |> dplyr::tally() |> dplyr::pull("n") == 0){
    cli::cli_warn(paste0(omopgenerics::tableName(omopTable), " omop table is empty. Returning an empty summarised omop table."))
    return(result)
  }

  # Counts summary ----
  cli::cli_inform(c("i" = "Summarising counts"))
  result <- result |>
    addNumberSubjects(omopTable) |>
    addNumberRecords(omopTable) |>
    addSubjectsPercentage(omopTable, people)

  # Records per person summary ----
  if(!is.null(recordsPerPerson)){
    cli::cli_inform(c("i" = "Summarising records per person"))
    result <- result |>
      addRecordsPerPerson(omopTable, recordsPerPerson, cdm)
  }

  denominator <- result |>
    dplyr::filter(.data$variable_name == "number_records") |>
    dplyr::pull("estimate_value") |>
    as.integer()

  # Summary concepts ----
  if (inObservation | standardConcept | sourceVocabulary | domainId | typeConcept) {
    cli::cli_inform(c("i" = "Summarising concepts"))

    variables <- columnsVariables(
      inObservation, standardConcept, sourceVocabulary, domainId, typeConcept
    )

    result <- result |>
      dplyr::bind_rows(
        omopTable |>
          addVariables(variables) |>
          dplyr::group_by(dplyr::across(dplyr::all_of(variables))) |>
          dplyr::tally() |>
          dplyr::collect() |>
          dplyr::mutate("n" = as.integer(.data$n)) |>
          summaryData(variables, cdm, denominator, result)
      )
  }

  # Format output as a summarised result
  result <- result |>
    dplyr::mutate(variable_name = dplyr::if_else(.data$variable_name == "number_records", "Number of records", .data$variable_name),
                  variable_name = dplyr::if_else(.data$variable_name == "number_subjects", "Number of subjects", .data$variable_name),
                  variable_name = dplyr::if_else(.data$variable_name == "records_per_person", "Records per person", .data$variable_name)) |>
    dplyr::mutate(
      "result_id" = 1L,
      "cdm_name" = omopgenerics::cdmName(cdm),
      "group_name" = "omop_table",
      "group_level" = omopgenerics::tableName(omopTable),
      "strata_name" = "overall",
      "strata_level" = "overall",
      "additional_name" = "overall",
      "additional_level" = "overall"
    ) |>
    omopgenerics::newSummarisedResult(settings = dplyr::tibble(
      "result_id" = 1L,
      "result_type" = "summarised_omop_table",
      "package_name" = "OmopSketch",
      "package_version" = as.character(utils::packageVersion("OmopSketch"))
    ))

return(result)
}

# Functions -----
getNumberPeopleInCdm <- function(cdm){
  cdm[["person"]] |>
    dplyr::ungroup() |>
    dplyr::summarise(x = dplyr::n_distinct(.data$person_id)) |>
    dplyr::pull("x") |>
    as.integer()
}

addNumberSubjects <- function(result, omopTable){
  result |>
    dplyr::add_row(
      "variable_name"  = "number_subjects",
      "estimate_name"  = "count",
      "estimate_type"  = "integer",
      "estimate_value" = as.character(
        omopTable |>
          dplyr::summarise(x = dplyr::n_distinct(.data$person_id)) |>
          dplyr::pull("x") |>
          as.integer()
      )
    )
}
addNumberRecords  <- function(result, omopTable){
  result |>
    dplyr::add_row(
      "variable_name"  = "number_records",
      "estimate_name"  = "count",
      "estimate_type"  = "integer",
      "estimate_value" = as.character(omopTable |> dplyr::tally() |> dplyr::pull("n"))
    )
}

addSubjectsPercentage <- function(result, omopTable, people){
  result |>
    dplyr::add_row(
      "variable_name"  = "number_subjects",
      "estimate_name"  = "percentage",
      "estimate_type"  = "percentage",
      "estimate_value" = as.character(
        100* (omopTable |>
                dplyr::summarise(x = dplyr::n_distinct(.data$person_id)) |>
                dplyr::pull("x") |>
                as.integer()) / .env$people
      )
    )
}

addRecordsPerPerson <- function(result, omopTable, recordsPerPerson, cdm){
  suppressMessages(
    result |>
      dplyr::bind_rows(
        cdm[["person"]] |>
          dplyr::select("person_id") |>
          dplyr::left_join(
            omopTable |>
              dplyr::group_by(.data$person_id) |>
              dplyr::summarise(
                "records_per_person" = as.integer(dplyr::n()),
                .groups = "drop"
              ),
            by = "person_id"
          ) |>
          dplyr::mutate("records_per_person" = dplyr::if_else(
            is.na(.data$records_per_person),
            0L,
            .data$records_per_person
          )) |>
          PatientProfiles::summariseResult(
            variables = "records_per_person",
            estimates = recordsPerPerson,
            counts = FALSE
          )
      )
  )
}

addVariables <- function(x, variables) {

  name <- omopgenerics::tableName(x)

  newNames <- c(
    "person_id",
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
    dplyr::select(dplyr::all_of(newNames))

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
          dplyr::select("in_observation", "id", "person_id"),
        by = c("id", "person_id")
      ) |>
      dplyr::distinct()
  }

  x <- x |>
    dplyr::select(dplyr::all_of(variables)) |>
    dplyr::mutate(dplyr::across(dplyr::everything(), ~as.character(.)))

  return(x)
}
columnsVariables <- function(inObservation, standardConcept, sourceVocabulary, domainId, typeConcept) {
  c("in_observation", "standard", "domain_id", "source", "type" )[c(
    inObservation, standardConcept, domainId, sourceVocabulary, typeConcept
  )]
}
summaryData <- function(x, variables, cdm, denominator, result) {
  results <- list()

  # in observation ----
  if ("in_observation" %in% variables) {
    results[["obs"]] <- x |>
      dplyr::mutate("in_observation" = dplyr::if_else(
        !is.na(.data$in_observation), "Yes", "No"
      )) |>
      formatResults("In observation", "in_observation", denominator, result)
  }

  # standard -----
  if ("standard" %in% variables) {
    results[["standard"]] <- x |>
      formatResults("Standard concept", "standard", denominator, result)
  }

  # source ----
  if ("source" %in% variables) {
    results[["source"]] <- x |> formatResults("Source vocabulary", "source", denominator, result)
  }

  # domain ----
  if ("domain_id" %in% variables) {
    results[["domain"]] <- x |> formatResults("Domain", "domain_id", denominator, result)
  }

  # type ----
  if ("type" %in% variables) {
    xx <- x |>
      formatResults("Type concept id", "type", denominator, result) |>
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
    results[["type"]] <- xx |> dplyr::select(-"new_variable_level")
  }

  results <- results |> dplyr::bind_rows()

  return(results)
}
formatResults <- function(x, variableName, variableLevel, denominator, result) {
  x |>
    dplyr::group_by(dplyr::across(dplyr::all_of(variableLevel))) |>
    dplyr::summarise("count" = sum(.data$n), .groups = "drop") |>
    dplyr::mutate("percentage" = 100 * .data$count / .env$denominator) |>
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
    dplyr::select(
      "variable_name", "variable_level", "estimate_name", "estimate_type",
      "estimate_value"
    ) |>
    dplyr::ungroup()
}
