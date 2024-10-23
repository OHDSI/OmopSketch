#' Summarise missing data in omop tables
#'
#' @param cdm A cdm object
#' @param omopTableName A character vector of the names of the tables to
#' summarise in the cdm object.
#' @param col A character vector of column names to check for missing values.
#' If `NULL`, all columns in the specified tables are checked. Default is `NULL`.
#' @param sex TRUE or FALSE. If TRUE code use will be summarised by sex.
#' @param ageGroup A list of ageGroup vectors of length two. Code use will be
#' thus summarised by age groups.
#' @return A summarised_result object with results overall and, if specified, by
#' strata.
#' @export

summariseMissingData <- function(cdm,
                           omopTableName,
                           col = NULL,
                           sex = FALSE,
                           ageGroup = NULL){


  omopgenerics::validateCdmArgument(cdm)

  omopgenerics::assertLogical(sex, length = 1)
  omopgenerics::assertChoice(omopTableName,choices = omopgenerics::omopTables(), unique = TRUE)


  ageGroup <- omopgenerics::validateAgeGroupArgument(ageGroup, ageGroupName = "")[[1]]

  strata <- my_getStrataList(sex = sex, ageGroup = ageGroup)
  stratification <- c(list(character()),omopgenerics::combineStrata(strata))

  result_tables <-  purrr::map(omopTableName, function(table) {

  omopTable <- cdm[[table]]
  col_table <- intersect(col, colnames(omopTable))
  if (is.null(col_table) | rlang::is_empty(col_table)){
  col_table<-colnames(omopTable)
  }

  indexDate <- startDate(omopgenerics::tableName(omopTable))
  x <- omopTable |> PatientProfiles::addDemographicsQuery(age = FALSE, ageGroup = ageGroup, sex = sex, indexDate = indexDate)


  result_columns <- purrr::map(col_table, function(c) {

    stratified_result <- x |>
      dplyr::group_by(dplyr::across(dplyr::all_of(strata))) |>
      dplyr::summarise(
        na_count = sum(as.integer(is.na(.data[[c]]))), #try is.numeric
        total_count = dplyr::n(),
        .groups = "drop"
      ) |>
      dplyr::collect()

    # Group results for each level of stratification
    grouped_results <- purrr::map(stratification, function(g) {
      stratified_result |>
        dplyr::group_by(dplyr::across(dplyr::all_of(g))) |>
        dplyr::summarise(
          na_count = sum(.data$na_count, na.rm = TRUE),
          total_count = sum(.data$total_count, na.rm = TRUE),
          colName = c,
          .groups = "drop"
        ) |>
        dplyr::mutate(na_percentage = dplyr::if_else(.data$total_count > 0, (.data$na_count / .data$total_count) * 100, 0))
    })

    return(purrr::reduce(grouped_results, dplyr::bind_rows))

  })

  res <- purrr::reduce(result_columns, dplyr::union)|>
    dplyr::mutate(omop_table = table)



  required_cols <- omopgenerics::omopTableFields(CDMConnector::cdmVersion(cdm))|>
    dplyr::filter(.data$cdm_table_name==table)|>
    dplyr::filter(.data$is_required==TRUE)|>
    dplyr::pull(.data$cdm_field_name)
  warning_columns <- res |>
    dplyr::filter(.data$colName %in% required_cols)|>
    dplyr::filter(.data$na_count>0)|>
    dplyr::distinct(.data$colName)|>
    dplyr::pull()

  if (length(warning_columns) > 0) {
    cli::cli_warn(c(
      "These columns contain missing values, which are not permitted:",
      "{.val {warning_columns}}"
    ))
  }
  return(res)
  })


  result<-purrr::reduce(result_tables, dplyr::union)|>
    dplyr::mutate(dplyr::across(dplyr::all_of(strata), ~ dplyr::coalesce(., "overall")))|>
    tidyr::pivot_longer(
      cols = c(.data$na_count, .data$na_percentage),
      names_to = "estimate_name",
      values_to = "estimate_value"
    )


  sr <- result |>
    dplyr::mutate(
      result_id = 1L,
      cdm_name = omopgenerics::cdmName(cdm),
    ) |>
    visOmopResults::uniteGroup(cols = "omop_table") |>
    visOmopResults::uniteStrata(cols = strata) |>
    visOmopResults::uniteAdditional() |>
    dplyr::mutate(
      "estimate_value" = as.character(.data$estimate_value),
      "estimate_type" = "integer",
      "variable_level" = NA
      ) |>
    dplyr::rename("variable_name" = "colName") |>
    dplyr::select(!c(.data$total_count))

  settings <- dplyr::tibble(
    result_id = unique(sr$result_id),
    package_name = "omopSketch",
    package_version = as.character(utils::packageVersion("OmopSketch")),
    result_type = "summarise_missing_data"
  )
  sr <- sr |>
    omopgenerics::newSummarisedResult(settings = settings)


  return(sr)

}

