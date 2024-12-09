#' Summarise missing data in omop tables
#'
#' @param cdm A cdm object
#' @param omopTableName A character vector of the names of the tables to
#' summarise in the cdm object.
#' @param col A character vector of column names to check for missing values.
#' If `NULL`, all columns in the specified tables are checked. Default is `NULL`.
#' @param sex TRUE or FALSE. If TRUE code use will be summarised by sex.
#' @param year TRUE or FALSE. If TRUE code use will be summarised by year.
#' @param ageGroup A list of ageGroup vectors of length two. Code use will be
#' thus summarised by age groups.
#' @param sample An integer to sample the table to only that number of records.
#' If NULL no sample is done.
#' @param dateRange A list containing the minimum and the maximum dates
#' defining the time range within which the analysis is performed.
#'
#' @return A summarised_result object with results overall and, if specified, by
#' strata.
#' @export
summariseMissingData <- function(cdm,
                                 omopTableName,
                                 col = NULL,
                                 sex = FALSE,
                                 year = FALSE,
                                 ageGroup = NULL,
                                 sample = 1000000,
                                 dateRange = NULL){
  # initial checks
  omopgenerics::validateCdmArgument(cdm)
  omopgenerics::assertCharacter(col, null = TRUE)
  omopgenerics::assertLogical(sex, length = 1)
  omopgenerics::assertLogical(year, length = 1)
  omopgenerics::assertChoice(omopTableName, choices = omopgenerics::omopTables(), unique = TRUE)
  omopgenerics::assertNumeric(sample, null = TRUE, integerish = TRUE, length = 1, min = 1)
  dateRange <- validateStudyPeriod(cdm, dateRange)
  ageGroup <- omopgenerics::validateAgeGroupArgument(ageGroup, multipleAgeGroup = FALSE, null = TRUE, ageGroupName = "age_group")$age_group

  strata <- my_getStrataList(sex = sex, ageGroup = ageGroup, year = year)
  stratification <- c(list(character()), omopgenerics::combineStrata(strata))

  result <- purrr::map(omopTableName, function(table) {

    sampling <- !is.null(sample) & !is.infinite(sample)
    omopTable <- cdm[[table]]
    omopTable <- restrictStudyPeriod(omopTable, dateRange)
    if (omopgenerics::isTableEmpty(omopTable)){
      cli::cli_warn(paste0(table, " omop table is empty."))
      return(NULL)
    }

    possibleColumns <- omopgenerics::omopColumns(
      table = table, version = omopgenerics::cdmVersion(cdm)
    )
    col_table <- intersect(col, possibleColumns)
    if (rlang::is_empty(col_table)) col_table <- possibleColumns
    discarded_cols <- setdiff(col_table,colnames(omopTable))

    if (length(discarded_cols)) {
      cli::cli_inform(c("i"="The columns {discarded_cols} are not present in {table} table"))
      col_table <-setdiff(col_table, discarded_cols)
    }

    if (sampling & omopTable |> dplyr::tally() |> dplyr::pull() <= sample) {
      sampling <- FALSE
    }

    if (sampling) {
      id <- paste0(table, "_id")
      nm <- omopgenerics::uniqueTableName()
      idTibble <- omopTable |>
        dplyr::pull(dplyr::all_of(id)) |>
        base::sample(size = sample) |>
        list() |>
        rlang::set_names(id) |>
        dplyr::as_tibble()
      idName <- "ids_sample"
      cdm <- omopgenerics::insertTable(
        cdm = cdm, name = idName, table = idTibble
      )
      omopTable <- omopTable |>
        dplyr::inner_join(cdm[[idName]], by = id) |>
        dplyr::compute(name = nm, temporary = FALSE)
      omopgenerics::dropSourceTable(cdm = cdm, name = idName)
    }


    indexDate <- startDate(name = table)

    if (sex | !is.null(ageGroup)) {
      omopTable <- omopTable |>
        PatientProfiles::addDemographicsQuery(
          age = FALSE, ageGroup = ageGroup, sex = sex, indexDate = indexDate
        )
    }
    if (year) {
      omopTable <- omopTable |>
        dplyr::mutate(year = as.character(clock::get_year(.data[[indexDate]])))
    }

    stratified_result <- omopTable |>
      dplyr::group_by(dplyr::across(dplyr::all_of(strata))) |>
      dplyr::summarise(
        dplyr::across(
            .cols = dplyr::any_of(col_table),
          ~ sum(as.integer(is.na(.x)), na.rm = TRUE)
        ),
        total_count = dplyr::n(),
        .groups = "drop"
      ) |>
      dplyr::collect()

    # Group results for each level of stratification
    grouped_results <- purrr::map(stratification, function(g) {
      stratified_result |>
        dplyr::group_by(dplyr::across(dplyr::all_of(g))) |>
        dplyr::summarise(
          dplyr::across(
            .cols = dplyr::all_of(c(col_table, "total_count")),
            .fns = sum
          ),
          .groups = "drop"
        ) |>
        tidyr::pivot_longer(
          cols = col_table, names_to = "column_name", values_to = "na_count"
        ) |>
        dplyr::mutate(na_percentage = dplyr::if_else(
          .data$total_count > 0, (.data$na_count / .data$total_count) * 100, 0
        ))
    }) |>
      dplyr::bind_rows() |>
      dplyr::mutate(omop_table = table) |>
      dplyr::select(!"total_count")

    if (sampling) omopgenerics::dropSourceTable(cdm = cdm, name = nm)

    warningDataRequire(cdm = cdm, res = grouped_results, table = table)

    return(grouped_results)
  }) |>
    purrr::compact()

  if (rlang::is_empty(result)){
    return(omopgenerics::emptySummarisedResult())
  }

  result <- result |>
    dplyr::bind_rows() |>
    dplyr::mutate(dplyr::across(dplyr::all_of(strata), ~ dplyr::coalesce(., "overall")))|>
    dplyr::mutate(
      na_count = as.character(.data$na_count),
      na_percentage = as.character(.data$na_percentage)
    )|>
    tidyr::pivot_longer(
      cols = c("na_count", "na_percentage"),
      names_to = "estimate_name",
      values_to = "estimate_value"
    ) |>
    dplyr::mutate(
      result_id = 1L,
      cdm_name = omopgenerics::cdmName(cdm),
    ) |>
    omopgenerics::uniteGroup(cols = "omop_table") |>
    omopgenerics::uniteStrata(cols = strata) |>
    omopgenerics::uniteAdditional() |>
    dplyr::mutate(
      "estimate_type" = "integer",
      "variable_level" = NA_character_
    ) |>
    dplyr::rename("variable_name" = "column_name")


 result <- result |>
    omopgenerics::newSummarisedResult(settings = createSettings(result_type = "summarise_missing_data", study_period = dateRange))

  return(result)
}

warningDataRequire <- function(cdm, table, res){
  required_cols <- omopgenerics::omopTableFields(CDMConnector::cdmVersion(cdm))|>
    dplyr::filter(.data$cdm_table_name==table)|>
    dplyr::filter(.data$is_required==TRUE)|>
    dplyr::pull(.data$cdm_field_name)
  warning_columns <- res |>
    dplyr::filter(.data$column_name %in% required_cols) |>
    dplyr::filter(.data$na_count>0)|>
    dplyr::pull("column_name") |>
    unique()

  if (length(warning_columns) > 0) {
    cli::cli_warn(c(
      "These columns contain missing values, which are not permitted:",
      "{.val {warning_columns}}"
    ))
  }
}


