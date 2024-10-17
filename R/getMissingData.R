getMissingData <- function(cdm,
                           omopTableName,
                           col = NULL,
                           sex = FALSE,
                           ageGroup = NULL){


  omopgenerics::validateCdmArgument(cdm)

  omopgenerics::assertLogical(sex, length = 1)
  omopgenerics::assertChoice(omopTableName,choices = omopgenerics::omopTables(), unique = TRUE)


  ageGroup <- omopgenerics::validateAgeGroupArgument(ageGroup, ageGroupName = "")[[1]]

  if (is.null(col)){
  col<-colnames(omopTable)
  }
  else{
  omopgenerics::assertChoice(col, choices = colnames(omopTable))
    }

  omopTable <- cdm[[omopTableName]]
  indexDate <- startDate(omopgenerics::tableName(cdm[[omopTableName]]))
  x <- omopTable |> PatientProfiles::addDemographicsQuery(age = FALSE, ageGroup = ageGroup, sex = sex, indexDate = indexDate)

  strata <- my_getStrataList(sex = sex, ageGroup = ageGroup)
  stratification <- omopgenerics::combineStrata(strata)


  results_list <- purrr::map(col, function(colname) {

    # Overall NA count and percentage (no stratification)
    overall_result <- x |>
        dplyr::select(dplyr::any_of(colname)) |>
        dplyr::summarise(
        na_count = sum(dplyr::if_else(is.na(.data[[colname]]),1,0)),
        total_count = n(),
        .groups = "drop",
        colname = colname
      ) |>
      dplyr::mutate(na_percentage = dplyr::if_else(total_count > 0, (na_count / total_count) * 100, 0)) |>
      dplyr::collect()

    # Summarize missing values and totals by strata
    stratified_result <- x |>
      dplyr::group_by(across(dplyr::all_of(strata))) |>
      dplyr::summarise(
        na_count = sum(dplyr::if_else(is.na(.data[[colname]]),1,0)),
        total_count = n(),
        .groups = "drop",
        colname = colname
      ) |>
      dplyr::mutate(na_percentage = if_else(total_count > 0, (na_count / total_count) * 100, 0)) |>
      dplyr::collect()

    # Group results for each level of stratification
    grouped_results <- purrr::map_dfr(stratification, function(g) {
      stratified_result |>
        dplyr::group_by(across(dplyr::all_of(g))) |>
        dplyr::reframe(
          na_count = sum(na_count),
          total_count = sum(total_count),
          na_percentage = dplyr::if_else(total_count > 0, (na_count / total_count) * 100, 0),
          colname = colname,

        )
    })
    return(dplyr::bind_rows(overall_result, grouped_results))
  })

  final_results <- dplyr::bind_rows(results_list)

  result<-final_results|>
    dplyr::mutate(dplyr::across(dplyr::all_of(strata), ~ tidyr::replace_na(., "overall")))|> #ACROSS STRATA COLUMNS
    tidyr::pivot_longer(
      cols = c(na_count, na_percentage),
      names_to = "estimate_name",
      values_to = "estimate_value"
    )

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

