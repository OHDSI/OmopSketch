
#' Summarise an omop table from a cdm object. You will obtain
#' information related to the number of records, number of subjects, whether the
#' records are in observation, number of present domains and number of present
#' concepts.
#'
#' @param omopTable An omop_table object derived from a cdm object.
#' @param recordsPerPerson Generates summary statistics for the number of records per person. Set to NULL if no summary statistics are required.
#' @param inObservation Boolean variable. Whether to include the percentage of records in
#' observation.
#' @param standardConcept Boolean variable. Whether to summarise standard concept information.
#' @param sourceVocabulary Boolean variable.  Whether to summarise source vocabulary information.
#' @param domainId  Boolean variable. Whether to summarise domain id of standard concept id information.
#' @param typeConcept  Boolean variable. Whether to summarise type concept id field information.
#' @param sex Boolean variable. Whether to stratify by sex (TRUE) or not (FALSE)
#'
#' @return A summarised_result object.
#'
#' @export
#' @examples
#' \donttest{
#'library(dplyr)
#'library(CDMConnector)
#'library(DBI)
#'library(duckdb)
#'library(OmopSketch)
#'
#'# Connect to Eunomia database
#'if (Sys.getenv("EUNOMIA_DATA_FOLDER") == "") Sys.setenv("EUNOMIA_DATA_FOLDER" = tempdir())
#'if (!dir.exists(Sys.getenv("EUNOMIA_DATA_FOLDER"))) dir.create(Sys.getenv("EUNOMIA_DATA_FOLDER"))
#'if (!eunomia_is_available()) downloadEunomiaData()
#'con <- DBI::dbConnect(duckdb::duckdb(), CDMConnector::eunomia_dir())
#'cdm <- CDMConnector::cdmFromCon(
#' con = con, cdmSchema = "main", writeSchema = "main"
#')
#'
#'# Run summarise clinical tables
#'summarisedResult <- summariseClinicalRecords(omopTable = cdm$condition_occurrence,
#'                                             recordsPerPerson = c("mean", "sd"),
#'                                             inObservation = TRUE,
#'                                             standardConcept = TRUE,
#'                                             sourceVocabulary = TRUE,
#'                                             domainId = TRUE,
#'                                             typeConcept = TRUE)
#'summarisedResult |> print()
#'PatientProfiles::mockDisconnect(cdm = cdm)
#'}
summariseClinicalRecords <- function(omopTable,
                               recordsPerPerson = c("mean", "sd", "median", "q25", "q75", "min", "max"),
                               inObservation = TRUE,
                               standardConcept = TRUE,
                               sourceVocabulary = FALSE,
                               domainId = TRUE,
                               typeConcept = TRUE,
                               sex = FALSE) {

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

  omopTable <- addStrataVariable(omopTable, sex)

  people <- getNumberPeopleInCdm(cdm, sex)
  result <- omopgenerics::emptySummarisedResult()

  if(omopTable |> dplyr::tally() |> dplyr::pull("n") == 0){
    cli::cli_warn(paste0(omopgenerics::tableName(omopTable), " omop table is empty. Returning an empty summarised omop table."))
    return(result)
  }

  # Counts summary ----
  cli::cli_inform(c("i" = "Summarising table counts"))
  result <- result |>
    addCounts(omopTable, type = "subjects") |>
    addCounts(omopTable, type = "records") |>
    addSubjectsPercentage(omopTable, people)

  # Records per person summary ----
  if(!is.null(recordsPerPerson)){
    cli::cli_inform(c("i" = "Summarising records per person information"))
    result <- result |>
      addRecordsPerPerson(omopTable, recordsPerPerson, cdm)
  }

  denominator <- getPercentageDenominator(result)

  # Summary concepts ----
  if (inObservation | standardConcept | sourceVocabulary | domainId | typeConcept) {

    variables <- columnsVariables(
      inObservation, standardConcept, sourceVocabulary, domainId, typeConcept
    )

    x <- sub(", ([^,]+)$", ", and \\1", gsub('_',' ', paste(variables, collapse = ", ")))
    cli::cli_inform(c("i" = "Summarising {x} information"))

    x <- omopTable |>
      addVariables(variables) |>
      addVariablesInfo(variables)

    result <- result |>
      dplyr::bind_rows(
       x |>
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
addStrataVariable <- function(omopTable, sex){
  if(sex){
    omopTable <- omopTable |>
      PatientProfiles::addSexQuery(sexName = "strata_level",
                                   missingSexValue = "unknown") |>
      dplyr::mutate("strata_name" = "sex")
  }else{
    omopTable <- omopTable |>
      dplyr::mutate(strata_level = "overall") |>
      dplyr::mutate(strata_name  = "overall")
  }

  return(omopTable)
}

getNumberPeopleInCdm <- function(cdm, sex){
  if(sex){
  p <- cdm[["person"]] |>
      dplyr::ungroup() |>
      dplyr::summarise(n = dplyr::n_distinct(.data$person_id), .by = "gender_concept_id") |>
      dplyr::collect() |>
      dplyr::mutate(sex = dplyr::case_when(
        gender_concept_id == 8532 ~ "Female",
        gender_concept_id == 8507 ~ "Male",
        .default = "Unknown")
      ) |>
      dplyr::select("strata_level" = "sex", "n")

   p <- rbind(p, c("overall", sum(p$n, na.rm = TRUE)))
  }else{
   p <- cdm[["person"]] |>
      dplyr::ungroup() |>
      dplyr::summarise("n" = dplyr::n_distinct(.data$person_id)) |>
      dplyr::collect() |>
      dplyr::mutate(strata_level = "overall")
  }

  return(p)
}

addCounts <- function(result, omopTable, type){
  if(type == "subjects"){
    x <- omopTable |>
      dplyr::summarise("estimate_value" = as.character(dplyr::n_distinct(.data$person_id)), .by = c("strata_name", "strata_level")) |>
      dplyr::collect()
  }else if(type == "records"){
    x <- omopTable |>
      dplyr::summarise("estimate_value" = as.character(dplyr::n()), .by = c("strata_name", "strata_level")) |>
      dplyr::collect()
  }

  if(!"overall" %in% x$strata_level){
    x <- rbind(x, c("overall", "overall", as.character(sum(as.numeric(x$estimate_value), na.rm = TRUE))))
  }

  result |>
    dplyr::add_row(
      x |>
        dplyr::mutate(
          "variable_name" = paste0("number_", .env$type),
          "estimate_name" = "count",
          "estimate_type" = "integer"
        )
    )
}

addSubjectsPercentage <- function(result, omopTable, people){
  result |>
    dplyr::add_row(
      result |>
        dplyr::filter(.data$variable_name == "number_subjects") |>
        dplyr::inner_join(
          people,
          by = "strata_level"
        ) |>
        dplyr::mutate(estimate_value = as.character(100*as.numeric(.data$estimate_value)/as.numeric(.data$n))) |>
        dplyr::select(-"n") |>
        dplyr::mutate("estimate_name" = "percentage", "estimate_type" = "percentage")
    )
}

addRecordsPerPerson <- function(result, omopTable, recordsPerPerson, cdm){

  strataName <- result$strata_name |> unique()
  if(length(strataName) > 1){strataName <- strataName[strataName != "overall"]}

  suppressMessages(
    result |>
      dplyr::bind_rows(
        cdm[["person"]] |>
          dplyr::select("person_id") |>
          dplyr::left_join(
            omopTable |>
              dplyr::group_by(.data$person_id, .data$strata_level, .data$strata_name) |>
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
          tidyr::pivot_wider(names_from = "strata_name", values_from = "strata_level") |>
          PatientProfiles::summariseResult(
            variables = "records_per_person",
            estimates = recordsPerPerson,
            counts = FALSE,
            strata = strataName
          )
      )
  )
}

getPercentageDenominator <- function(result){
  result |>
    dplyr::filter(.data$variable_name == "number_records") |>
    dplyr::select("strata_name", "strata_level", "estimate_value")
}

addVariables <- function(omopTable, variables) {

  name <- omopgenerics::tableName(omopTable)

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
  cdm <- omopgenerics::cdmReference(omopTable)

  x <- omopTable |>
    dplyr::select(dplyr::all_of(newNames), "strata_name", "strata_level")

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
    dplyr::select(dplyr::all_of(variables), "strata_level", "strata_name") |>
    dplyr::mutate(dplyr::across(dplyr::everything(), ~as.character(.)))

  return(x)
}

columnsVariables <- function(inObservation, standardConcept, sourceVocabulary, domainId, typeConcept) {
  c("in_observation", "standard", "domain_id", "source", "type" )[c(
    inObservation, standardConcept, domainId, sourceVocabulary, typeConcept
  )]
}

addVariablesInfo <- function(omopTable, variables){
  x <- omopTable |>
    dplyr::group_by(dplyr::across(c(dplyr::all_of(variables), "strata_name", "strata_level"))) |>
    dplyr::tally() |>
    dplyr::collect() |>
    dplyr::mutate("n" = as.integer(.data$n))

  if(!"overall" %in% x$strata_name){
    x <- x |>
      rbind(
        x |>
          dplyr::summarise(n = sum(.data$n, na.rm = TRUE), .by = dplyr::all_of(variables)) |>
          dplyr::collect() |>
          dplyr::mutate(strata_level = "overall", strata_name = "overall")
      )

  }

  return(x)
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
    dplyr::group_by(dplyr::across(c(dplyr::all_of(variableLevel), "strata_name", "strata_level"))) |>
    dplyr::summarise("count" = sum(.data$n), .groups = "drop") |>
    dplyr::inner_join(
      denominator,
      by = c("strata_name", "strata_level")
    ) |>
    dplyr::mutate("estimate_value" = as.character(100* .data$count/ as.numeric(.data$estimate_value))) |>
    dplyr::mutate("estimate_name"  = "percentage",
                  "estimate_type"  = "percentage") |>
    dplyr::select(-"count") |>
    dplyr::mutate(
      "variable_name" = .env$variableName,
      "variable_level" = as.character(.data[[variableLevel]]),
      "estimate_type" = dplyr::if_else(
        .data$estimate_name == "count", "integer", "percentage"
      )
    ) |>
    dplyr::select(
      "variable_name", "variable_level", "estimate_name", "estimate_type",
      "estimate_value", "strata_name", "strata_level"
    ) |>
    dplyr::ungroup()
}
