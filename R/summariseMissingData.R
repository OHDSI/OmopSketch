
#' Summarise missing data in omop tables
#'
#' @inheritParams consistent-doc
#' @param col A character vector of column names to check for missing values.
#' If `NULL`, all columns in the specified tables are checked. Default is
#' `NULL`.
#' @inheritParams dateRange-startDate
#' @param year deprecated
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
#' result <- summariseMissingData(
#'   cdm = cdm,
#'   omopTableName = c("condition_occurrence", "visit_occurrence"),
#'   sample = 10000
#' )
#'
#' tableMissingData(result = result)
#'
#' cdmDisconnect(cdm = cdm)
#' }
#'
summariseMissingData <- function(cdm,
                                 omopTableName,
                                 col = NULL,
                                 sex = FALSE,
                                 interval = "overall",
                                 ageGroup = NULL,
                                 sample = 100000,
                                 dateRange = NULL,
                                 year = lifecycle::deprecated()) {
  if (lifecycle::is_present(year)) {
    lifecycle::deprecate_warn("0.2.3", "summariseMissingData(year)", "summariseMissingData(interval = 'years')")

    if (isTRUE(year) & missing(interval)) {
      interval <- "years"
      cli::cli_inform("interval argument set to 'years'")
    } else if (isTRUE(year) & !missing(interval)) {
      cli::cli_inform("year argument will be ignored")
    }
  }

  cdm <- omopgenerics::validateCdmArgument(cdm)
  omopgenerics::assertCharacter(col, null = TRUE)
  omopgenerics::assertLogical(sex, length = 1)
  # should i still check the year argument
  omopgenerics::assertChoice(interval, c("overall", "years", "quarters", "months"), length = 1)
  omopgenerics::assertChoice(omopTableName, choices = omopgenerics::omopTables(), unique = TRUE)
  sample <- validateSample(sample = sample)
  dateRange <- validateStudyPeriod(cdm, dateRange)
  ageGroup <- omopgenerics::validateAgeGroupArgument(ageGroup, multipleAgeGroup = FALSE, null = TRUE, ageGroupName = "age_group")

  cdm <- sampleCdm(cdm = cdm, tables = omopTableName, sample = sample)

  if ("person" %in% omopTableName) {
    if (!is.null(ageGroup)) cli::cli_warn("ageGroup stratification is not applied for person table")
    if (interval != "overall") cli::cli_warn("time interval stratification is not applied for person table")
    if (!is.null(dateRange)) cli::cli_warn("dateRange restriction is not applied for person table")

    omopTableName <- omopTableName[omopTableName != "person"]
    strata <- list(c(character(),"sex"[sex]))
    result_person <- summariseMissingDataFromTable(omopTable = cdm[["person"]], table = "person", cdm = cdm, col = col, dateRange = NULL, sex = sex, ageGroup = NULL, interval = "overall", strata = strata)
  } else {
    result_person <- dplyr::tibble()
  }

  if (!rlang::is_empty(omopTableName)) {
    strata <- c(
      list(character()),
      omopgenerics::combineStrata(c(strataCols(sex = sex, ageGroup = ageGroup, interval = interval)))
    )
    result <- purrr::map(omopTableName, function(table) {
      summariseMissingDataFromTable(omopTable = cdm[[table]], table = table, cdm = cdm, col = col, dateRange = dateRange, sex = sex, ageGroup = ageGroup, interval = interval, strata = strata)
    }) |>
      purrr::compact()
  } else {
    result <- dplyr::tibble()
  }

  result <- purrr::compact(list(result, result_person))

  if (rlang::is_empty(result)) {
    return(omopgenerics::emptySummarisedResult(settings = createSettings(result_type = "summarise_missing_data", study_period = dateRange)))
  }

  result |>
    dplyr::bind_rows() |>
    dplyr::mutate(dplyr::across(
      dplyr::all_of(unique(unlist(strata))), \(x) dplyr::coalesce(x, "overall")
    )) |>
    dplyr::mutate(
      result_id = 1L,
      cdm_name = omopgenerics::cdmName(cdm),
    ) |>
    omopgenerics::uniteGroup(cols = "omop_table") |>
    omopgenerics::uniteStrata(cols = setdiff(unique(unlist(strata)), "interval")) |>
    addTimeInterval() |>
    omopgenerics::uniteAdditional(cols = "time_interval") |>
    dplyr::mutate(variable_name = "Column name") |>
    dplyr::rename("variable_level" = "column_name") |>
    omopgenerics::newSummarisedResult(settings = createSettings(
      result_type = "summarise_missing_data", study_period = dateRange
    ))
}

warningDataRequire <- function(cdm, table, res) {
  required_cols <- omopgenerics::omopTableFields(omopgenerics::cdmVersion(cdm)) |>
    dplyr::filter(
      .data$cdm_table_name == .env$table, .data$is_required == TRUE
    ) |>
    dplyr::pull(.data$cdm_field_name)
  warning_columns <- res |>
    dplyr::filter(
      .data$column_name %in% .env$required_cols,
      .data$estimate_name == "na_count",
      as.integer(.data$estimate_value) > 0
    ) |>
    dplyr::pull("column_name") |>
    unique()

  if (length(warning_columns) > 0) {
    cli::cli_warn(c(
      "These columns contain missing values, which are not permitted:",
      "{.val {warning_columns}}"
    ))
  }
  invisible()
}
columnsToSummarise <- function(col, cols, table, version) {
  possibleColumns <- omopgenerics::omopColumns(table = table, version = version)
  col_table <- intersect(col, possibleColumns)
  if (rlang::is_empty(col_table)) col_table <- possibleColumns
  discarded_cols <- setdiff(col_table, cols)
  if (length(discarded_cols)) {
    cli::cli_inform(c("i" = "The columns {discarded_cols} are not present in {table} table"))
    col_table <- setdiff(col_table, discarded_cols)
  }
  return(col_table)
}


summariseMissingDataFromTable <- function(omopTable, table, cdm, col, dateRange, sex, ageGroup, interval, strata) {
  prefix <- omopgenerics::tmpPrefix()

  # check if table is empty

  if (omopgenerics::isTableEmpty(omopTable)) {
    cli::cli_warn(paste0(table, " omop table is empty."))
    return(NULL)
  }
  col_table <- columnsToSummarise(
    col, colnames(omopTable), table, omopgenerics::cdmVersion(cdm)
  )

  # restrict study period
  omopTable <- omopTable |>
    restrictStudyPeriod(dateRange = dateRange)
  if (is.null(omopTable)) {
    return(NULL)
  }

  resultsOmopTable <- omopTable |>
    # add stratifications
    addStratifications(
      indexDate = omopgenerics::omopColumns(table, "start_date"),
      sex = sex,
      ageGroup = ageGroup,
      interval = interval,
      intervalName = "interval",
      name = omopgenerics::uniqueTableName(prefix)
    ) |>
    # summarise missing data
    summariseMissingInternal(
      strata = strata,
      columns = col_table,
      cdm = cdm,
      table = table
    ) |>
    dplyr::mutate(omop_table = table) |>
    # order columns
    dplyr::inner_join(
      dplyr::tibble(column_name = col_table, order = seq_along(col_table)),
      by = "column_name"
    ) |>
    dplyr::arrange(.data$order, .data$estimate_name) |>
    dplyr::select(!"order")

  # drop tables
  omopgenerics::dropSourceTable(cdm = cdm, name = dplyr::starts_with(prefix))

  warningDataRequire(cdm = cdm, res = resultsOmopTable, table = table)

  return(resultsOmopTable)
}
