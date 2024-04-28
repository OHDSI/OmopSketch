
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
#' @param sourceConcept Whether to summarise source concept.
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
                               sourceConcept = FALSE,
                               domainId = TRUE,
                               typeConcept = TRUE) {
  # initial checks
  assertClass(omopTable, "omop_table")
  omopTable |>
    omopgenerics::tableName() |>
    assertChoice(choices = tables$table_name)
  estimates <- PatientProfiles::availableEstimates(
    variableType = "numeric", fullQuantiles = TRUE
  ) |>
    dplyr::pull("estimate_name")
  assertChoice(recordsPerPerson, choices = estimates, null = TRUE)
  recordsPerPerson <- unique(recordsPerPerson)
  assertLogical(inObservation, length = 1)
  assertLogical(standardConcept, length = 1)
  assertLogical(sourceConcept, length = 1)
  assertLogical(domainId, length = 1)
  assertLogical(typeConcept, length = 1)

  if ("observation_period" == omopgenerics::tableName(omopTable)) {
    standardConcept <- FALSE
    sourceConcept <- FALSE
    domainId <- FALSE
  }

  cdm <- omopgenerics::cdmReference(omopTable)
  omopTable <- omopTable |> dplyr::ungroup()

  # counts summary
  persons <- cdm[["person"]] |>
    dplyr::ungroup() |>
    dplyr::summarise("n" = as.integer(dplyr::n())) |>
    dplyr::pull("n")
  result <- omopTable |>
    dplyr::summarise(
      "number_records" = dplyr::n(),
      "number_subjects" = dplyr::n_distinct(.data$person_id)
    ) |>
    dplyr::collect() |>
    dplyr::mutate(dplyr::across(dplyr::everything(), as.integer)) |>
    dplyr::mutate(
      "subjects_percentage" = 100 * .data$number_subjects / .env$persons
    ) |>
    dplyr::mutate(dplyr::across(dplyr::everything(), as.character)) |>
    tidyr::pivot_longer(
      cols = dplyr::everything(),
      names_to = "variable_name",
      values_to = "estimate_value"
    ) |>
    dplyr::mutate(
      "variable_level" = NA_character_,
      "estimate_name" = dplyr::if_else(
        grepl("number", .data$variable_name), "count", "percentage"
      ),
      "estimate_type" = dplyr::if_else(
        grepl("number", .data$variable_name), "integer", "percentage"
      )
    )
  den <- result |>
    dplyr::filter(.data$variable_name == "number_records") |>
    dplyr::pull("estimate_value") |>
    as.integer()

  # records per person
  if (length(recordsPerPerson) > 0) {
    cli::cli_inform("Summarising records per person")
    suppressMessages(
      result <- result |>
        dplyr::union_all(
          cdm[["person"]] |>
            dplyr::left_join(
              omopTable |>
                dplyr::group_by(.data$person_id) |>
                dplyr::summarise(
                  "records_per_person" = as.integer(dplyr::n()),
                  .groups = "drop"
                ),
              by = "person_id",
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
            ) |>
            dplyr::select(
              "variable_name", "variable_level", "estimate_name",
              "estimate_type", "estimate_value"
            )
        )
    )
  }

  # concept
  if (inObservation | standardConcept | sourceConcept | domainId | typeConcept) {
    cli::cli_inform("Summarising concepts")
    # add variables
    variables <- columnsVariables(
      inObservation, standardConcept, sourceConcept, domainId, typeConcept
    )
    result <- result |>
      dplyr::union_all(
        omopTable |>
          addVariables(variables) |>
          dplyr::group_by(dplyr::across(dplyr::all_of(variables))) |>
          dplyr::tally() |>
          dplyr::collect() |>
          dplyr::mutate("n" = as.integer(.data$n)) |>
          summaryData(variables, cdm, den)
      )
  }

  result <- result |>
    dplyr::mutate(
      "result_id" = 1L,
      "cdm_name" = omopgenerics::cdmName(cdm),
      "table_name" = omopgenerics::tableName(omopTable)
    ) |>
    visOmopResults::uniteGroup("table_name") |>
    visOmopResults::uniteStrata() |>
    visOmopResults::uniteAdditional() |>
    omopgenerics::newSummarisedResult(settings = dplyr::tibble(
      "result_id" = 1L,
      "result_type" = "summarised_omop_table",
      "package_name" = "OmopSketch",
      "package_version" = as.character(utils::packageVersion("OmopSketch"))
    ))

  return(result)
}

addVariables <- function(x,
                         variables) {
  name <- omopgenerics::tableName(x)
  newNames <- c(
    "person_id",
    "id" = tableId(name),
    "date" = startDate(name),
    "standard" = standardConcept(name),
    "source" = sourceConcept(name),
    "type" = typeConcept(name)
  )
  newNames <- newNames[!is.na(newNames)]
  cdm <- omopgenerics::cdmReference(x)

  x <- x |>
    dplyr::select(dplyr::all_of(newNames))

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

  if ("source" %in% variables) {
    x <- x |>
      dplyr::left_join(
        cdm$concept |>
          dplyr::select(
            "source" = "concept_id", "source_concept" = "standard_concept"
          ),
        by = "source"
      ) |>
        dplyr::mutate("source" = dplyr::case_when(
          .data$source == 0 ~ "No matching concept",
          .data$source_concept == "S" ~ "Standard",
          .data$source_concept == "C" ~ "Classification",
          .default = "Source"
        ))
  }

  if ("in_observation" %in% variables) {
    x <- x |>
      dplyr::left_join(
        x |>
          dplyr::select("id", "person_id", "date") |>
          dplyr::inner_join(
            cdm[["observation_period"]] |>
              dplyr::select(
                "person_id",
                "obs_start" = "observation_period_start_date",
                "obs_end" = "observation_period_end_date"
              ),
            by = "person_id"
          ) |>
          dplyr::filter(
            .data$date >= .data$obs_start & .data$date <= .data$obs_end
          ) |>
          dplyr::mutate("in_observation" = 1L) |>
          dplyr::select("id", "in_observation"),
        by = "id"
      )
  }

  x <- x |> dplyr::select(dplyr::all_of(variables))

  return(x)
}
columnsVariables <- function(inObservation,
                             standardConcept,
                             sourceConcept,
                             domainId,
                             typeConcept) {
  c("in_observation", "standard", "domain_id", "source", "type" )[c(
    inObservation, standardConcept, domainId, sourceConcept, typeConcept
  )]
}
summaryData <- function(x, variables, cdm, den) {
  results <- list()

  # in observation
  if ("in_observation" %in% variables) {
    results[["obs"]] <- x |>
      dplyr::mutate("in_observation" = dplyr::if_else(
        !is.na(.data$in_observation), "Yes", "No"
      )) |>
      formatResults("In observation", "in_observation", den)
  }

  # standard
  if ("standard" %in% variables) {
    results[["standard"]] <- x |>
      formatResults("Standard concept", "standard", den)
  }

  # source
  if ("source" %in% variables) {
    results[["source"]] <- x |> formatResults("Source concept", "source", den)
  }

  # domain
  if ("domain_id" %in% variables) {
    results[["domain"]] <- x |> formatResults("Domain", "domain_id", den)
  }

  # type
  if ("type" %in% variables) {
    results[["type"]] <- x |>
      formatResults("Type concept id", "type", den) |>
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
      )) |>
      dplyr::select(-"new_variable_level")

  }

  results <- results |> dplyr::bind_rows()

  return(results)
}
formatResults <- function(x, variableName, variableLevel, den) {
  x |>
    dplyr::group_by(dplyr::across(dplyr::all_of(variableLevel))) |>
    dplyr::summarise("count" = sum(.data$n), .groups = "drop") |>
    dplyr::mutate("percentage" = 100 * .data$count / .env$den) |>
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
    )
}

# getFunctions <- function(date, concept) {
#   functions <- c(
#     rlang::parse_exprs("dplyr::n()") |>
#       rlang::set_names("count_number_records"),
#     rlang::parse_exprs("dplyr::n_distinct(.data$person_id)") |>
#       rlang::set_names("count_number_subjects"),
#     rlang::parse_exprs("dplyr::n_distinct(.data$concept_id)") |>
#       rlang::set_names("count_distinct_concept_id"),
#     rlang::parse_exprs("sum(.data$in_observation, na.rm = TRUE)") |>
#       rlang::set_names("count_records_in_observation")
#   )
#   functions <- functions[c(
#     TRUE, TRUE, date != "cohort_start_date", concept != "cohort_definition_id"
#   )]
#   return(functions)
# }
# prepareTable <- function(omopTable, date, concept) {
#   cdm <- omopgenerics::cdmReference(omopTable)
#
#   # domain_id
#   if (concept != "cohort_definition_id") {
#     omopTable <- omopTable |>
#       dplyr::rename("concept_id" = dplyr::all_of(concept)) |>
#       dplyr::left_join(
#         cdm$concept |> dplyr::select("concept_id", "domain_id"),
#         by = "concept_id"
#       )
#   }
#
#   # year and in_observation
#   if (date != "cohort_start_date") {
#     omopTable <- omopTable |>
#       PatientProfiles::addInObservation(indexDate = date) %>%
#       dplyr::mutate(
#         "year" = !!CDMConnector::datepart(date = date, interval = "year")
#       )
#   }
#
#   return(omopTable)
# }
# summaryData <- function(omopTable, functions, byYear){
#   result <- omopTable |>
#     dplyr::summarise(!!!functions) |>
#     dplyr::collect()
#   if ("domain_id" %in% colnames(omopTable)) {
#     result <- result |>
#       dplyr::bind_rows(
#         omopTable |>
#           dplyr::group_by(.data$domain_id) |>
#           dplyr::summarise(!!!functions, .groups = "drop") |>
#           dplyr::collect()
#       )
#   } else {
#     result <- result |> dplyr::mutate("domain_id" = NA_character_)
#   }
#
#   if (byYear & "year" %in% colnames(omopTable)) {
#     result <- result |>
#       dplyr::bind_rows(
#         omopTable |>
#           dplyr::group_by(.data$year) |>
#           dplyr::summarise(!!!functions, .groups = "drop") |>
#           dplyr::collect()
#       )
#     if ("domain_id" %in% colnames(omopTable)) {
#       result <- result |>
#         dplyr::bind_rows(
#           omopTable |>
#             dplyr::group_by(.data$domain_id, .data$year) |>
#             dplyr::summarise(!!!functions, .groups = "drop") |>
#             dplyr::collect()
#         )
#     }
#   } else {
#     result <- result |> dplyr::mutate("year" = NA_character_)
#   }
#   return(result)
# }
# formatResult <- function(result, cdm, name) {
#   result |>
#     tidyr::pivot_longer(
#       cols = !c("year", "domain_id"),
#       names_to = "name",
#       values_to = "estimate_value"
#     ) |>
#     tidyr::separate_wider_delim(
#       cols = "name",
#       delim = "_",
#       names = c("estimate_name", "variable_name"),
#       too_many = "merge"
#     ) |>
#     dplyr::mutate(
#       "estimate_value" = as.character(.data$estimate_value),
#       "cdm_name" = omopgenerics::cdmName(cdm = cdm),
#       "estimate_type" = "integer",
#       "variable_level" = NA_character_,
#       "package_name" = "OmopSketch",
#       "package_version" = as.character(utils::packageVersion("OmopSketch")),
#       "group_name" = "omop_table",
#       "group_level" = name,
#       "result_type" = "summarised_omop_table",
#       "additional_name" = "overall",
#       "additional_level" = "overlal"
#     ) |>
#     dplyr::rename("domain" = "domain_id") |>
#     visOmopResults::uniteStrata(cols = c("year", "domain")) |>
#     omopgenerics::newSummarisedResult()
# }
