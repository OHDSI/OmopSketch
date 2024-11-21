
my_getStrataList <- function(sex = FALSE, ageGroup = NULL, year = FALSE){

  strata <- as.character()

  if(!is.null(ageGroup)){
    strata <- append(strata, "age_group")
  }

  if(sex){
    strata <- append(strata, "sex")
  }
  if(year){
    strata <- append(strata, "year")
  }
  return(strata)
}


checkFeasibility <- function(omopTable, tableName, conceptId){

  if (omopgenerics::isTableEmpty(omopTable)){
    cli::cli_warn(paste0(tableName, " omop table is empty."))
    return(NULL)
  }

  if (is.na(conceptId)){
    cli::cli_warn(paste0(tableName, " omop table doesn't contain standard concepts."))
    return(NULL)
  }

  y <- omopTable |>
    dplyr::filter(!is.na(.data[[conceptId]]))

  if (omopgenerics::isTableEmpty(y)){
    cli::cli_warn(paste0(tableName, " omop table doesn't contain standard concepts."))
    return(NULL)
  }
  return(TRUE)
}



#' Summarise concept use in patient-level data
#'
#' @param cdm A cdm object
#' @param omopTableName A character vector of the names of the tables to
#' summarise in the cdm object.
#' @param countBy Either "record" for record-level counts or "person" for
#' person-level counts
#' @param year TRUE or FALSE. If TRUE code use will be summarised by year.
#' @param sex TRUE or FALSE. If TRUE code use will be summarised by sex.
#' @param ageGroup A list of ageGroup vectors of length two. Code use will be
#' thus summarised by age groups.
#' @param dateRange A list containing the minimum and the maximum dates
#' defining the time range within which the analysis is performed.
#' @return A summarised_result object with results overall and, if specified, by
#' strata.
#' @export
summariseAllConceptCounts <- function(cdm,
                            omopTableName,
                            countBy = "record",
                            year = FALSE,
                            sex = FALSE,
                            ageGroup = NULL,
                            dateRange = NULL){

  omopgenerics::validateCdmArgument(cdm)
  checkCountBy(countBy)
  omopgenerics::assertLogical(year, length = 1)
  omopgenerics::assertLogical(sex, length = 1)
  omopgenerics::assertChoice(omopTableName,choices = omopgenerics::omopTables(), unique = TRUE)

  ageGroup <- omopgenerics::validateAgeGroupArgument(ageGroup, ageGroupName = "")[[1]]
  dateRange <- validateStudyPeriod(cdm, dateRange)
  strata <- my_getStrataList(sex = sex, year = year, ageGroup = ageGroup)

  stratification <- omopgenerics::combineStrata(strata)

  result_tables <- purrr::map(omopTableName, function(table){




  omopTable <- cdm[[table]] |>
    dplyr::ungroup()


  conceptId <- standardConcept(omopgenerics::tableName(omopTable))

  if (is.null(checkFeasibility(omopTable, table, conceptId))){
    return(NULL)
  }

  omopTable <- restrictStudyPeriod(omopTable, dateRange)


  indexDate <- startDate(omopgenerics::tableName(omopTable))

  x <- omopTable |>
    dplyr::filter(!is.na(.data[[conceptId]])) |>
    dplyr::left_join(
      cdm$concept |> dplyr::select("concept_id", "concept_name"),
      by = stats::setNames("concept_id", conceptId)) |>
    PatientProfiles::addDemographicsQuery(age = FALSE,
                                          ageGroup = ageGroup,
                                          sex = sex,
                                          indexDate = indexDate, priorObservation = FALSE, futureObservation = FALSE)
  if (year){
    x <- x|> dplyr::mutate(year = as.character(clock::get_year(.data[[indexDate]])))
  }


  level <- c(conceptId, "concept_name")

  groupings <- c(list(level), purrr::map(stratification, ~ c(level, .x)))

  result <- list()
  if ("record" %in% countBy){

    stratified_result <- x |>
      dplyr::group_by(dplyr::across(dplyr::all_of(c(level,strata)))) |>
      dplyr::summarise("estimate_value" = as.integer(dplyr::n()), .groups = "drop")|>
      dplyr::collect()


    grouped_results <- purrr::map(groupings, \(g) {
      stratified_result |>
        dplyr::group_by(dplyr::across(dplyr::all_of(g))) |>
        dplyr::summarise("estimate_value" = as.integer(sum(.data$estimate_value, na.rm = TRUE)), .groups = "drop")

    })

    result_record <- purrr::reduce(grouped_results, dplyr::bind_rows)|>
      dplyr::mutate(dplyr::across(dplyr::all_of(strata), ~ dplyr::coalesce(., "overall")))|>
      dplyr::mutate("estimate_name" = "record_count")
    result<-dplyr::bind_rows(result,result_record)
  }

  if ("person" %in% countBy){

    grouped_results <- purrr::map(groupings, \(g) {
      x |>
        dplyr::group_by(dplyr::across(dplyr::all_of(g))) |>
        dplyr::summarise("estimate_value" = as.integer(dplyr::n()), .groups = "drop")|>
        dplyr::collect()
    })

    result_person <- purrr::reduce(grouped_results, dplyr::bind_rows) |>
      dplyr::mutate(dplyr::across(dplyr::all_of(strata), ~ dplyr::coalesce(., "overall"))) |>
      dplyr::mutate("estimate_name" = "person_count")
    result<-dplyr::bind_rows(result,result_person)
  }
  result<- result |>
    dplyr::mutate("omop_table" = table,
                  "variable_level" = as.character(.data[[conceptId]])) |>

    dplyr::select(-dplyr::all_of(conceptId))
    return(result)
  })
  if (rlang::is_empty(purrr::compact(result_tables))){
    return(omopgenerics::emptySummarisedResult())
  }

  sr <-purrr::compact(result_tables) |>
    purrr::reduce(dplyr::union)|>
    dplyr::mutate(
      result_id = 1L,
      cdm_name = omopgenerics::cdmName(cdm)
    ) |>
    visOmopResults::uniteGroup(cols = "omop_table") |>
    visOmopResults::uniteStrata(cols = strata) |>
    visOmopResults::uniteAdditional() |>
    dplyr::mutate(
      "estimate_value" = as.character(.data$estimate_value),
      "estimate_type" = "integer"
    ) |>
    dplyr::rename("variable_name" = "concept_name")
  # |>
  #   dplyr::select(!c())


  sr <- sr |>
    omopgenerics::newSummarisedResult(settings = createSettings(result_type = "summarise_all_concept_counts", study_period = dateRange))

  return(sr)

}

