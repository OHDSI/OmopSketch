#' Summarise an omop table from a cdm object
#'
#' You will obtain information related to the number of records, number of
#' subjects, whether the records are in observation, number of present domains,
#' number of present concepts, missing data and inconsistencies in start date
#' and end date.
#'
#' @inheritParams consistent-doc
#' @param recordsPerPerson Generates summary statistics for the number of
#' records per person. Set to NULL if no summary statistics are required.
#' @param missingData Logical. If `TRUE`, includes a summary of missing data for
#' relevant fields.
#' @param quality Logical. If `TRUE`, performs basic data quality checks,
#' including:
#' - Percentage of records within the observation period.
#' - Number of records with end date before start date.
#' - Number of records with start date before the person's birth date.
#' @param conceptSummary Logical. If `TRUE`, includes summaries of concept-level
#' information, including:
#' - Domain ID of standard concepts.
#' - Type concept ID.
#' - Standard vs non-standard concepts.
#' - Source vocabulary usage.
#' @inheritParams dateRange-startDate
#' @param inObservation Deprecated. Use `quality = TRUE` instead.
#' @param standardConcept Deprecated. Use `conceptSummary = TRUE` instead.
#' @param sourceVocabulary Deprecated. Use `conceptSummary = TRUE` instead.
#' @param domainId Deprecated. Use `conceptSummary = TRUE` instead.
#' @param typeConcept Deprecated. Use `conceptSummary = TRUE` instead.
#'
#' @return A `summarised_result` object with the results.
#' @export
#'
#' @examples
#' \donttest{
#' library(OmopSketch)
#' library(omock)
#'
#' cdm <- mockCdmFromDataset(datasetName = "GiBleed", source = "duckdb")
#'
#' result <- summariseClinicalRecords(
#'   cdm = cdm,
#'   omopTableName = "condition_occurrence",
#'   recordsPerPerson = c("mean", "sd"),
#'   quality = TRUE,
#'   conceptSummary = TRUE,
#'   missingData = TRUE
#' )
#'
#' tableClinicalRecords(result = result)
#'
#' cdmDisconnect(cdm = cdm)
#' }
#'
summariseClinicalRecords <- function(cdm,
                                     omopTableName,
                                     recordsPerPerson = c("mean", "sd", "median", "q25", "q75", "min", "max"),
                                     conceptSummary = TRUE,
                                     missingData = TRUE,
                                     quality = TRUE,
                                     sex = FALSE,
                                     ageGroup = NULL,
                                     dateRange = NULL,
                                     # Deprecated arguments
                                     inObservation = lifecycle::deprecated(),
                                     standardConcept = lifecycle::deprecated(),
                                     sourceVocabulary = lifecycle::deprecated(),
                                     domainId = lifecycle::deprecated(),
                                     typeConcept = lifecycle::deprecated()) {
  # Check for deprecated arguments
  if (lifecycle::is_present(inObservation)) {
    lifecycle::deprecate_warn("1.0.0", "summariseClinicalRecords(inObservation)", "summariseClinicalRecords(quality)")
  }

  if (lifecycle::is_present(standardConcept)) {
    lifecycle::deprecate_warn("1.0.0", "summariseClinicalRecords(standardConcept)", "summariseClinicalRecords(conceptSummary)")
  }
  if (lifecycle::is_present(sourceVocabulary)) {
    lifecycle::deprecate_warn("1.0.0", "summariseClinicalRecords(sourceVocabulary)", "summariseClinicalRecords(conceptSummary)")
  }
  if (lifecycle::is_present(domainId)) {
    lifecycle::deprecate_warn("1.0.0", "summariseClinicalRecords(domainId)", "summariseClinicalRecords(conceptSummary)")
  }
  if (lifecycle::is_present(typeConcept)) {
    lifecycle::deprecate_warn("1.0.0", "summariseClinicalRecords(typeConcept)", "summariseClinicalRecords(conceptSummary)")
  }
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
  omopgenerics::assertLogical(conceptSummary, length = 1)
  omopgenerics::assertLogical(missingData, length = 1)
  omopgenerics::assertLogical(quality, length = 1)
  omopgenerics::assertLogical(sex, length = 1)

  ageGroup <- omopgenerics::validateAgeGroupArgument(ageGroup, multipleAgeGroup = FALSE)

  # prefix
  prefix <- omopgenerics::tmpPrefix()

  # get strata
  strata <- c(
    list(character()),
    omopgenerics::combineStrata(strataCols(sex = sex, ageGroup = ageGroup))
  )

  set <- createSettings(
    result_type = "summarise_clinical_records", study_period = dateRange
  )

  result <- purrr::map(omopTableName, \(table) {
    # check that table is not empty
    omopTable <- dplyr::ungroup(cdm[[table]])
    if (omopgenerics::isTableEmpty(omopTable)) {
      cli::cli_warn("{table} is empty.")
      return(dplyr::tibble())
    }

    # restrict study period
    omopTable <- restrictStudyPeriod(omopTable, dateRange)
    if (is.null(omopTable)) {
      return(dplyr::tibble())
    }
    cli::cli_inform(c("i" = "Adding variables of interest to {.pkg {table}}."))
    start_date_name <- omopgenerics::omopColumns(table, field = "start_date")
    omopTable <- omopTable |>
      addStratifications(
        indexDate = start_date_name,
        sex = sex,
        ageGroup = ageGroup,
        interval = "overall",
        intervalName = "",
        name = omopgenerics::uniqueTableName(prefix)
      )
    x <- omopTable |>
      addVariables(
        tableName = table,
        quality = quality,
        conceptSummary = conceptSummary
      ) |>
      dplyr::compute(name = omopgenerics::uniqueTableName(prefix))
    result <- list()
    cli::cli_inform(c("i" = "Summarising records per person in {.pkg {table}}."))
    result$recordPerPerson <- summariseRecordsPerPerson(
      x = x, strata = strata, estimates = recordsPerPerson
    ) |>
      dplyr::select(!dplyr::starts_with("group_"))

    variables <- variablesToSummarise(quality = quality, conceptSummary = conceptSummary)

    if (length(variables)) {
      res <- list()
      if (quality) {
        cli::cli_inform(c("i" = "Summarising subjects not in person table in {.pkg {table}}."))
        number_subjects <- result$recordPerPerson |>
          dplyr::filter(.data$variable_name == "Number subjects" & .data$strata_level == "overall" & .data$estimate_name == "count") |>
          dplyr::pull(.data$estimate_value) |>
          as.numeric()
        number_subjects_no_person <- x |>
          dplyr::anti_join(cdm[["person"]], by = "person_id") |>
          omopgenerics::numberSubjects() |>
          as.numeric()
        res$notInPerson <- dplyr::tibble(
          count = as.character(as.integer(number_subjects_no_person)),
          percentage = sprintf("%.2f", 100 * number_subjects_no_person / number_subjects)
        ) |>
          tidyr::pivot_longer(
            cols = dplyr::everything(),
            names_to = "estimate_name",
            values_to = "estimate_value"
          ) |>
          dplyr::mutate(
            variable_name = "Subjects not in person table",
            variable_level = NA_character_,
            estimate_type = dplyr::case_when(
              .data$estimate_name == "count" ~ "integer",
              .data$estimate_name == "percentage" ~ "percentage"
            )
          )

        if (number_subjects_no_person > 0) {
          cli::cli_warn(c("!" = "There {?is/are} {number_subjects_no_person} individual{?s} not included in the person table."))
        }

        cli::cli_inform(c("i" = "Summarising records in observation in {.pkg {table}}."))
        strataInObs <- lapply(strata, function(x) c(x, "in_observation"))
        res$inObs <- x |>
          summariseCountsInternal(strata = strataInObs, counts = "records") |>
          dplyr::mutate(
            estimate_name = "count",
            variable_name = "In observation",
            variable_level = dplyr::if_else(.data$in_observation == 1, "Yes", "No")
          )

        cli::cli_inform(c("i" = "Summarising records with start before birth date in {.pkg {table}}."))
        res$sbb <- x |>
          dplyr::filter(.data$start_before_birth == 1) |>
          summariseCountsInternal(strata = strata, counts = "records") |>
          dplyr::mutate(
            estimate_name = "count",
            variable_name = "Start date before birth date",
            variable_level = NA_character_
          )


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
      if (conceptSummary) {
        if ("domain_id" %in% colnames(x)) {
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
        if ("standard" %in% colnames(x)) {
          cli::cli_inform(c("i" = "Summarising standard concepts in {.pkg {table}}."))
          strataStandard <- lapply(strata, function(x) c(x, "standard"))
          res$standardConcept <- x |>
            summariseCountsInternal(strata = strataStandard, counts = "records") |>
            dplyr::mutate(
              estimate_name = "count",
              variable_name = "Standard concept",
              variable_level = .data$standard
            )
        }

        if ("source_vocabulary" %in% colnames(x)) {
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
        if ("type_concept" %in% colnames(x)) {
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
        if ("concept_class_id" %in% colnames(x)) {
          cli::cli_inform(c("i" = "Summarising concept class in {.pkg {table}}."))
          strataClass <- lapply(strata, function(x) c(x, "concept_class_id"))
          res$conceptClass <- x |>
            summariseCountsInternal(strata = strataClass, counts = "records") |>
            dplyr::mutate(
              estimate_name = "count",
              variable_name = "Concept class",
              variable_level = .data$concept_class_id
            )
        }
      }


      denominator <- result$recordPerPerson |>
        dplyr::filter(.data$variable_name == "Number records") |>
        dplyr::select("strata_name", "strata_level", den = "estimate_value")

      res <- res |>
        dplyr::bind_rows() |>
        dplyr::select(!dplyr::any_of(variables)) |>
        omopgenerics::uniteStrata(cols = strataCols(sex = sex, ageGroup = ageGroup))

      result$variables <- res |>
        dplyr::bind_rows(
          res |>
            dplyr::filter(.data$variable_name != "Subjects not in person table") |>
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
      result$missing <- summariseMissingDataFromTable(
        omopTable = omopTable,
        table = table,
        cdm = cdm,
        col = NULL,
        dateRange = NULL,
        sex = FALSE,
        ageGroup = NULL,
        interval = "overall",
        strata = strata
      ) |>
        omopgenerics::uniteStrata(cols = strataCols(sex = sex, ageGroup = ageGroup)) |>
        dplyr::mutate(variable_name = "Column name") |>
        dplyr::rename("variable_level" = "column_name") |>
        addTimeInterval() |>
        omopgenerics::uniteAdditional(cols = "time_interval")
    }

    fullResult <- dplyr::bind_rows(result) |>
      dplyr::mutate(omop_table = .env$table)
  }) |>
    dplyr::bind_rows()

  if (rlang::is_empty(result)) {
    return(omopgenerics::emptySummarisedResult(settings = set))
  }

  result <- result |>
    dplyr::mutate(
      result_id = 1L,
      cdm_name = omopgenerics::cdmName(cdm)
    ) |>
    omopgenerics::uniteGroup(cols = "omop_table") |>
    omopgenerics::newSummarisedResult(settings = set)

  # drop temp tables
  omopgenerics::dropSourceTable(cdm = cdm, name = dplyr::starts_with(prefix))

  return(result)
}

summariseRecordsPerPerson <- function(x, strata, estimates) {
  # strata
  strataCols <- unique(unlist(strata))

  cdm <- omopgenerics::cdmReference(x)
  prefix <- omopgenerics::tmpPrefix()
  nm <- omopgenerics::uniqueTableName(prefix = prefix)

  res <- x |>
    dplyr::group_by(dplyr::across(dplyr::all_of(c("person_id", strataCols)))) |>
    dplyr::summarise(n = as.integer(dplyr::n()), .groups = "drop") |>
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
        dplyr::if_else(.data$estimate_name == "sum", "Number records", "Records per person"),
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
variablesToSummarise <- function(quality, conceptSummary) {
  c(c(
    "standard",
    "source_vocabulary", "domain_id",
    "type_concept", "concept_class_id"
  )[conceptSummary], c("in_observation", "start_before_birth", "end_before_start")[quality])
}

addVariables <- function(x, tableName, quality, conceptSummary) {
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

  if (quality) {
    # Add in_observation flag
    obs_tbl <- cdm[["observation_period"]] |>
      dplyr::select(
        "person_id",
        obs_start = "observation_period_start_date",
        obs_end = "observation_period_end_date"
      )

    x <- x |>
      dplyr::left_join(
        x |>
          dplyr::inner_join(obs_tbl, by = "person_id") |>
          dplyr::filter(.data$start_date >= .data$obs_start & .data$end_date <= .data$obs_end) |>
          dplyr::mutate(in_observation = 1L) |>
          dplyr::select("id", "person_id", "in_observation"),
        by = c("person_id", "id")
      ) |>
      dplyr::mutate(in_observation = dplyr::coalesce(.data$in_observation, 0L))

    # Add end_before_start flag
    x <- x |>
      dplyr::mutate(
        end_before_start = dplyr::if_else(.data$end_date < .data$start_date, 1L, 0L)
      )
    birth_expr <- rlang::parse_expr(
      "as.Date(paste0(
    as.character(as.integer(.data$year_of_birth)), '-',
    as.character(as.integer(dplyr::coalesce(.data$month_of_birth, 1L))), '-',
    as.character(as.integer(dplyr::coalesce(.data$day_of_birth, 1L)))
  ))"
    )


    person_tbl <- if (!("birth_datetime" %in% colnames(cdm$person))) {
      cdm$person |>
        dplyr::mutate(birthdate = !!birth_expr) |>
        dplyr::select("person_id", "birthdate")
    } else {
      cdm$person |>
        dplyr::mutate(
          birthdate = dplyr::case_when(
            !is.na(.data$birth_datetime) ~ as.Date(.data$birth_datetime),
            TRUE ~ !!birth_expr
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

  if (conceptSummary) {
    if ("standard" %in% colnames(x)) {
      x <- x |>
        dplyr::left_join(
          cdm$concept |>
            dplyr::select(
              standard = "concept_id",
              "standard_concept",
              "domain_id",
              "concept_class_id"[tableName == "drug_exposure"]
            ),
          by = c("standard")
        ) |>
        dplyr::mutate(standard = dplyr::case_when(
          .data$standard == 0 ~ "No matching concept",
          .data$standard_concept == "S" ~ "Standard",
          .data$standard_concept == "C" ~ "Classification",
          .default = "Source"
        ))
    }
    if ("source" %in% colnames(x)) {
      x <- x |>
        dplyr::left_join(
          cdm$concept |>
            dplyr::select(
              source = "concept_id",
              source_vocabulary = "vocabulary_id"
            ),
          by = "source"
        ) |>
        dplyr::mutate(source_vocabulary = dplyr::coalesce(
          .data$source_vocabulary, "No matching concept"
        ))
    }
  }
  variables <- c("id", "person_id", "start_date", "sex", "age_group", variablesToSummarise(quality = quality, conceptSummary = conceptSummary))

  x |>
    dplyr::select(dplyr::any_of(variables))
}
reduceDemicals <- function(x, n) {
  id <- grepl(pattern = ".", x = x, fixed = TRUE) & !is.na(suppressWarnings(as.numeric(x)))
  x[id] <- sprintf(paste0("%.", n, "f"), as.numeric(x[id]))
  return(x)
}
