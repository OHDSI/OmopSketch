getMissingData <- function(cdm,
                           omopTableName,
                           col = NULL,
                           sex = FALSE,
                           ageGroup = NULL){


  omopgenerics::validateCdmArgument(cdm)

  omopgenerics::assertLogical(sex, length = 1)
  omopgenerics::assertChoice(omopTableName,choices = omopgenerics::omopTables(), unique = TRUE)


  ageGroup <- omopgenerics::validateAgeGroupArgument(ageGroup, ageGroupName = "")[[1]]

  omopTable <- cdm[[omopTableName]]

  if (is.null(col)){
  col<-colnames(omopTable)
  } else{
  omopgenerics::assertChoice(col, choices = colnames(omopTable))
    }

  indexDate <- startDate(omopgenerics::tableName(cdm[[omopTableName]]))
  x <- omopTable |> PatientProfiles::addDemographicsQuery(age = FALSE, ageGroup = ageGroup, sex = sex, indexDate = indexDate)

  strata <- my_getStrataList(sex = sex, ageGroup = ageGroup)
  stratification <- omopgenerics::combineStrata(strata)



  results_list <- purrr::map(col, function(c) {


    overall_result <- x |>
        dplyr::select(dplyr::any_of(c)) |>
        dplyr::summarise(
        na_count = sum(dplyr::if_else(is.na(.data[[c]]),1,0)),
        total_count = n(),
        colname = c,
        .groups = "drop") |>
      dplyr::mutate(na_percentage = dplyr::if_else(total_count > 0, (na_count / total_count) * 100, 0))
    if (!rlang::is_empty(strata))
    {
    stratified_result <- x |>
      dplyr::group_by(across(dplyr::all_of(strata)), na.rm = TRUE) |>
      dplyr::summarise(
        na_count = sum(dplyr::if_else(is.na(.data[[c]]),1,0)),
        total_count = n(),
        colname = c,
        .groups = "drop"
      ) |>
      dplyr::mutate(na_percentage = dplyr::if_else(total_count > 0, (na_count / total_count) * 100, 0))

    # Group results for each level of stratification
    grouped_results <- purrr::map(stratification, function(g) {
      stratified_result |>
        dplyr::group_by(across(dplyr::all_of(g))) |>
        dplyr::summarise(
          na_count = sum(.data$na_count, na.rm = TRUE),
          total_count = sum(.data$total_count, na.rm = TRUE),
          colname = c,
          .groups = "drop"
        ) |>
        dplyr::mutate(na_percentage = dplyr::if_else(total_count > 0, (na_count / total_count) * 100, 0))
    })
    grouped_results <- purrr::reduce(grouped_results, dplyr::union)
    return(dplyr::union(overall_result, grouped_results))
     } else {
       return(overall_result)
    }

  })

  final_results <- purrr::reduce(results_list, dplyr::union)

  result<-final_results|>
    dplyr::mutate(dplyr::across(dplyr::all_of(strata), ~ dplyr::coalesce(., "overall")))|>
    tidyr::pivot_longer(
      cols = c(na_count, na_percentage),
      names_to = "estimate_name",
      values_to = "estimate_value"
    ) |>
    dplyr::collect()

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
      "estimate_value" = as.character(.data$estimate_value),
      "estimate_type" = "integer",
      "variable_level" = NA
    ) |>
    dplyr::rename("variable_name" = "colname") |>
    dplyr::select(!c(total_count))


  return(sr)

}

