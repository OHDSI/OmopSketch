
#' Summarise an omop_table from a cdm_reference object. You will obtain
#' information related to the number of records, number of subjects, whether the
#' records are in observation, number of present domains and number of present
#' concepts.
#'
#' @param omopTable An omop_table object.
#' @param byYear Whether to stratify the analysis by year.
#'
#' @export
#'
summariseOmopTable <- function(omopTable, byYear = FALSE) {
  # initial checks
  checkmate::assertClass(omopTable, "omop_table")

  cdm <- omopgenerics::cdmReference(omopTable)
  name <- omopgenerics::tableName(omopTable)

  date <- PatientProfiles::startDateColumn(name)
  concept <- PatientProfiles::standardConceptIdColumn(name)

  # get functions
  functions <- getFunctions(date = date, concept = concept)

  # prepare data
  omopTable <- prepareTable(
    omopTable = omopTable, date = date, concept = concept
  )

  # summary
  result <- summaryData(
    omopTable = omopTable, functions = functions, byYear = byYear
  )

  # format result
  result <- formatResult(result = result, cdm = cdm, name = name)

  return(result)
}

getFunctions <- function(date, concept) {
  functions <- c(
    rlang::parse_exprs("dplyr::n()") |>
      rlang::set_names("count_number_records"),
    rlang::parse_exprs("dplyr::n_distinct(.data$person_id)") |>
      rlang::set_names("count_number_subjects"),
    rlang::parse_exprs("dplyr::n_distinct(.data$concept_id)") |>
      rlang::set_names("count_distinct_concept_id"),
    rlang::parse_exprs("sum(.data$in_observation, na.rm = TRUE)") |>
      rlang::set_names("count_records_in_observation")
  )
  functions <- functions[c(
    TRUE, TRUE, date != "cohort_start_date", concept != "cohort_definition_id"
  )]
  return(functions)
}
prepareTable <- function(omopTable, date, concept) {
  cdm <- omopgenerics::cdmReference(omopTable)

  # domain_id
  if (concept != "cohort_definition_id") {
    omopTable <- omopTable |>
      dplyr::rename("concept_id" = dplyr::all_of(concept)) |>
      dplyr::left_join(
        cdm$concept |> dplyr::select("concept_id", "domain_id"),
        by = "concept_id"
      )
  }

  # year and in_observation
  if (date != "cohort_start_date") {
    omopTable <- omopTable |>
      PatientProfiles::addInObservation(indexDate = date) %>%
      dplyr::mutate(
        "year" = !!CDMConnector::datepart(date = date, interval = "year")
      )
  }

  return(omopTable)
}
summaryData <- function(omopTable, functions, byYear){
  result <- omopTable |>
    dplyr::summarise(!!!functions) |>
    dplyr::collect()
  if ("domain_id" %in% colnames(omopTable)) {
    result <- result |>
      dplyr::bind_rows(
        omopTable |>
          dplyr::group_by(.data$domain_id) |>
          dplyr::summarise(!!!functions, .groups = "drop") |>
          dplyr::collect()
      )
  } else {
    result <- result |> dplyr::mutate("domain_id" = NA_character_)
  }

  if (byYear & "year" %in% colnames(omopTable)) {
    result <- result |>
      dplyr::bind_rows(
        omopTable |>
          dplyr::group_by(.data$year) |>
          dplyr::summarise(!!!functions, .groups = "drop") |>
          dplyr::collect()
      )
    if ("domain_id" %in% colnames(omopTable)) {
      result <- result |>
        dplyr::bind_rows(
          omopTable |>
            dplyr::group_by(.data$domain_id, .data$year) |>
            dplyr::summarise(!!!functions, .groups = "drop") |>
            dplyr::collect()
        )
    }
  } else {
    result <- result |> dplyr::mutate("year" = NA_character_)
  }
  return(result)
}
formatResult <- function(result, cdm, name) {
  result |>
    tidyr::pivot_longer(
      cols = !c("year", "domain_id"),
      names_to = "name",
      values_to = "estimate_value"
    ) |>
    tidyr::separate_wider_delim(
      cols = "name",
      delim = "_",
      names = c("estimate_name", "variable_name"),
      too_many = "merge"
    ) |>
    dplyr::mutate(
      "estimate_value" = as.character(.data$estimate_value),
      "cdm_name" = omopgenerics::cdmName(cdm = cdm),
      "estimate_type" = "integer",
      "variable_level" = NA_character_,
      "package_name" = "OmopSketch",
      "package_version" = as.character(utils::packageVersion("OmopSketch")),
      "group_name" = "omop_table",
      "group_level" = name,
      "result_type" = "summarised_omop_table",
      "additional_name" = "overall",
      "additional_level" = "overlal"
    ) |>
    dplyr::rename("domain" = "domain_id") |>
    visOmopResults::uniteStrata(cols = c("year", "domain")) |>
    omopgenerics::newSummarisedResult()
}
