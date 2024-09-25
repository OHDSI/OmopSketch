
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
                                     ageGroup = NULL) {
  # Initial checks ----
  omopgenerics::validateCdmArgument(cdm)
  omopTableName |>
    omopgenerics::assertChoice(choices = omopgenerics::omopTables())

  estimates <- PatientProfiles::availableEstimates(
    variableType = "numeric", fullQuantiles = TRUE) |>
    dplyr::pull("estimate_name")
  omopgenerics::assertChoice(recordsPerPerson, choices = estimates, null = TRUE)

  recordsPerPerson <- unique(recordsPerPerson)

  omopgenerics::assertLogical(inObservation, length = 1)
  omopgenerics::assertLogical(standardConcept, length = 1)
  omopgenerics::assertLogical(sourceVocabulary, length = 1)
  omopgenerics::assertLogical(domainId, length = 1)
  omopgenerics::assertLogical(typeConcept, length = 1)
  omopgenerics::assertLogical(sex, length = 1)
  omopgenerics::validateAgeGroupArgument(ageGroup)

  result <- purrr::map(omopTableName,
                       function(x) {
                         if(omopgenerics::isTableEmpty(cdm[[x]])) {
                           cli::cli_warn(paste0(x, " omop table is empty. Returning an empty summarised omop table."))
                           return(omopgenerics::emptySummarisedResult())
                         }
                         summariseClinicalRecord(x,
                                                 cdm = cdm,
                                                 recordsPerPerson = recordsPerPerson,
                                                 inObservation = inObservation,
                                                 standardConcept = standardConcept,
                                                 sourceVocabulary = sourceVocabulary,
                                                 domainId = domainId,
                                                 typeConcept = typeConcept,
                                                 sex = sex,
                                                 ageGroup = ageGroup)
                       }
  ) |>
    dplyr::bind_rows()

  return(result)
}

#' @noRd
summariseClinicalRecord <- function(omopTableName, cdm, recordsPerPerson,
                                    inObservation, standardConcept,
                                    sourceVocabulary, domainId, typeConcept,
                                    sex, ageGroup, call = parent.frame(3)) {

  tablePrefix <-  omopgenerics::tmpPrefix()

  # Initial checks
  omopgenerics::assertClass(cdm[[omopTableName]], "omop_table", call = call)

  date <- startDate(omopgenerics::tableName(cdm[[omopTableName]]))

  omopTable <- cdm[[omopTableName]] |>
    dplyr::ungroup()

  omopTable <- filterPersonId(omopTable) |>
    addStrataToOmopTable(date, ageGroup, sex)

  if ("observation_period" == omopTableName) {
    if(standardConcept){
      if(!missing(standardConcept)){
        cli::cli_inform("standardConcept turned to FALSE for observation_period OMOP table", call = call)
      }
      standardConcept <- FALSE
    }
    if(sourceVocabulary){
      if(!missing(sourceVocabulary)){
        cli::cli_inform("sourceVocabulary turned to FALSE for observation_period OMOP table", call = call)
      }
      sourceVocabulary <- FALSE
    }
    if(domainId){
      if(!missing(domainId)){
        cli::cli_inform("domainId turned to FALSE for observation_period OMOP table", call = call)
      }
      domainId <- FALSE
    }
  }

  strata <- getStrataList(sex, ageGroup)

  peopleStrata <- suppressWarnings(addStrataToPeopleInObservation(cdm, ageGroup, sex, tablePrefix))

  people <- getNumberPeopleInCdm(cdm, strata, peopleStrata)
  result <- omopgenerics::emptySummarisedResult()

  # Counts summary ----
  cli::cli_inform(c("i" = "Summarising table counts"))
  result <- result |>
    addCounts(strata, omopTable) |>
    addSubjectsPercentage(omopTable, people, strata)

  # Records per person summary ----
  if(!is.null(recordsPerPerson)){
    cli::cli_inform(c("i" = "Summarising records per person"))
    result <- result |>
      addRecordsPerPerson(omopTable, recordsPerPerson, cdm, peopleStrata, strata)
  }

  denominator <- result |>
    dplyr::filter(.data$variable_name == "number records") |>
    dplyr::collect("strata_name", "strata_level", "estimate_value")

  # Summary concepts ----
  if (inObservation | standardConcept | sourceVocabulary | domainId | typeConcept) {

    variables <- columnsVariables(
      inObservation, standardConcept, sourceVocabulary, domainId, typeConcept
    )

    cli::cli_inform(c("i" = "Summarising {variables} information"))

    result <- result |>
      dplyr::bind_rows(
        omopTable |>
          addVariables(variables, strata) |>
          dplyr::group_by(dplyr::across(dplyr::all_of(variables)), .data$age_group, .data$sex) |>
          dplyr::tally() |>
          dplyr::collect() |>
          dplyr::mutate("n" = as.integer(.data$n)) |>
          summaryData(variables, cdm, denominator, result)
      )
  }

  # Format output as a summarised result
  result <- result |>
    tidyr::fill("result_id", "cdm_name", "group_name", "group_level",
                "additional_name", "additional_level", .direction = "downup") |>
    dplyr::mutate(
      "group_name" = "omop_table",
      "group_level" = omopgenerics::tableName(omopTable)
    ) |>
    omopgenerics::newSummarisedResult(settings = dplyr::tibble(
      "result_id" = 1L,
      "result_type" = "summarise_clinical_records",
      "package_name" = "OmopSketch",
      "package_version" = as.character(utils::packageVersion("OmopSketch"))
    ))

  CDMConnector::dropTable(cdm, name = dplyr::starts_with(tablePrefix))

  return(result)
}

# Functions -----
getStrataList <- function(sex, ageGroup){

  strata <- as.character()

  if(!is.null(ageGroup)){
    strata <- append(strata, "age_group")
  }

  if(sex){
    strata <- append(strata, "sex")
  }

  strata <- omopgenerics::combineStrata(levels = strata)
  return(strata)
}

getNumberPeopleInCdm <- function(cdm, strata, peopleStrata){

  peopleStrata |>
    dplyr::select(-c("observation_period_start_date","observation_period_end_date")) |>
    PatientProfiles::summariseResult(strata = strata,
                                     includeOverallStrata = TRUE,
                                     counts = TRUE,
                                     estimates = c("max")) |>
    suppressMessages()
}

addCounts <- function(result, strata, omopTable){

  date <- startDate(omopgenerics::tableName(omopTable))

  result |>
    rbind(
      omopTable |>
        dplyr::select("person_id", dplyr::any_of(c("age_group","sex"))) |>
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
        PatientProfiles::summariseResult(
          strata = strata,
          includeOverallStrata = TRUE,
          variables = "records_per_person",
          estimates = recordsPerPerson,
          counts = FALSE
        )
    )
}

addVariables <- function(x, variables, strata) {

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
    dplyr::select(dplyr::all_of(newNames), "age_group", "sex")

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
    dplyr::select(dplyr::all_of(variables), "age_group", "sex") |>
    dplyr::mutate(dplyr::across(dplyr::everything(), ~as.character(.)))

  # Create overall groups - This chunk will need efficiency improvement
  if(length(strata) == 3){
    x <- x |>
      dplyr::union_all(
        x |>
          dplyr::mutate(age_group = "overall")
      ) |>
      dplyr::union_all(
        x |>
          dplyr::mutate(sex = "overall")
      ) |>
      dplyr::union_all(
        x |>
          dplyr::mutate(sex = "overall") |>
          dplyr::mutate(age_group = "overall")
      )

  }
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

  results <- results |>
    dplyr::bind_rows()

  return(results)
}

formatResults <- function(x, variableName, variableLevel, denominator, result) {

  denominator <- denominator |>
    dplyr::select("strata_name", "strata_level", "denominator" = "estimate_value") |>
    visOmopResults::splitStrata()

  if(!"age_group" %in% colnames(denominator)){
    denominator <- denominator |>
      dplyr::mutate("age_group" = "overall")
  }

  if(!"sex" %in% colnames(denominator)){
    denominator <- denominator |>
      dplyr::mutate("sex" = "overall")
  }

  x |>
    dplyr::group_by(dplyr::across(dplyr::all_of(c(variableLevel,"age_group","sex")))) |>
    dplyr::summarise("count" = sum(.data$n), .groups = "drop") |>
    dplyr::inner_join(
      denominator,
      by = c("age_group","sex")
    ) |>
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
    visOmopResults::uniteStrata(cols = c("age_group","sex")) |>
    dplyr::select(
      "strata_name", "strata_level", "variable_name", "variable_level",
      "estimate_name", "estimate_type", "estimate_value"
    ) |>
    dplyr::ungroup()
}
