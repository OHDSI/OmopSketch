
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

summariseAllConceptCounts <- function(cdm,
                            omopTableName,
                            countBy = "record",
                            year = FALSE,
                            sex = FALSE,
                            ageGroup = NULL){

  omopgenerics::validateCdmArgument(cdm)
  checkCountBy(countBy)
  omopgenerics::assertLogical(year, length = 1)
  omopgenerics::assertLogical(sex, length = 1)
  omopgenerics::assertChoice(omopTableName,choices = omopgenerics::omopTables(), unique = TRUE)

  ageGroup <- omopgenerics::validateAgeGroupArgument(ageGroup, ageGroupName = "")[[1]]


  omopTable <- cdm[[omopTableName]] |>
    dplyr::ungroup()
  # check if table is empty

  conceptId <- standardConcept(omopgenerics::tableName(cdm[[omopTableName]]))


  indexDate <- startDate(omopgenerics::tableName(cdm[[omopTableName]]))

  x <- omopTable |>
    dplyr::left_join(
      cdm$concept |> dplyr::select("concept_id", "concept_name"),
      by = setNames("concept_id", conceptId)) |>
    PatientProfiles::addDemographicsQuery(age = FALSE,
                                          ageGroup = ageGroup,
                                          sex = sex,
                                          indexDate = indexDate, priorObservation = FALSE, futureObservation = FALSE)
  if (year){
    x <- x|> dplyr::mutate(year = as.character(clock::get_year(.data[[indexDate]])))
  }

  strata <- my_getStrataList(sex = sex, year = year, ageGroup = ageGroup)

  stratification <- omopgenerics::combineStrata(strata)

  level <- c(dplyr::all_of(conceptId), "concept_name")

  groupings <- c(list(level), purrr::map(stratification, ~ c(level, .x)))

  result <- list()


  if ("record" %in% countBy){

    stratified_result <- x |>
      dplyr::group_by(across(dplyr::all_of(c(level,strata)))) |>
      dplyr::summarise(estimate_value = dplyr::n(), .groups = "drop") |>
      dplyr::collect()

    grouped_results <- purrr::map(groupings, \(g) {
      stratified_result |>
        dplyr::group_by(dplyr::across(dplyr::all_of(g))) |>
        dplyr::summarise(estimate_value = sum(.data$estimate_value, na.rm = TRUE), .groups = "drop")
    })

    result_record <- dplyr::bind_rows(grouped_results)|>
      dplyr::mutate(dplyr::across(dplyr::all_of(strata), ~ tidyr::replace_na(., "overall"))) |>
      dplyr::mutate(estimate_name = "record_count")
    result <- dplyr::bind_rows(result, result_record)

  }

  if ("person" %in% countBy){

    grouped_results <- purrr::map(groupings, \(g) {
      x |>
        dplyr::group_by(dplyr::across(dplyr::all_of(g))) |>
        dplyr::summarise(estimate_value = dplyr::n(), .groups = "drop")|>
        dplyr::collect()
    })

    result_person <- dplyr::bind_rows(grouped_results) |>
      dplyr::mutate(across(dplyr::all_of(strata), ~ tidyr::replace_na(., "overall"))) |>
      dplyr::mutate(estimate_name = "person_count")
    result <- dplyr::bind_rows(result, result_person)

  }


  sr <- result |>
    dplyr::mutate(
      result_id = 1L,
      cdm_name = omopgenerics::cdmName(cdm),
      omop_table = omopTableName
    ) |>
    visOmopResults::uniteGroup(cols = "omop_table") |>
    visOmopResults::uniteStrata(cols = strata) |>
    visOmopResults::uniteAdditional() |>
    dplyr::mutate(
      "variable_level" = as.character(.data[[conceptId]]),
      "estimate_value" = as.character(.data$estimate_value),
      "estimate_type" = "integer"
    ) |>
    dplyr::rename("variable_name" = "concept_name") |>
    dplyr::select(!c(conceptId))


  settings <- dplyr::tibble(
    result_id = unique(sr$result_id),
    package_name = "omopSketch",
    package_version = as.character(utils::packageVersion("OmopSketch")),
    result_type = "summarise_counts"
  )
  sr <- sr |>
    omopgenerics::newSummarisedResult(settings = settings)

  return(sr)

}

