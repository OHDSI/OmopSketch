
restrictStudyPeriod <- function(omopTable, dateRange) {
  if (is.null(dateRange)) {
    return(omopTable)
  }
  start_date_table <- startDate(omopgenerics::tableName(omopTable))
  end_date_table <- endDate(omopgenerics::tableName(omopTable))
  start_date <- dateRange[1]
  end_date <-dateRange[2]

  omopTable <- omopTable |>
    dplyr::filter(
      (.data[[start_date_table]]>= .env$start_date & .data[[start_date_table]] <= .env$end_date) &
        (.data[[end_date_table]] >= .env$start_date & .data[[end_date_table]] <= .env$end_date)
    )
  # maybe the end date check is not needed

  warningEmptyStudyPeriod(omopTable)

  return(omopTable)
}

warningEmptyStudyPeriod <- function (omopTable) {
  if (omopgenerics::isTableEmpty(omopTable)){
    cli::cli_warn(paste0(omopgenerics::tableName(omopTable), " omop table is empty after application of date range."))
    return(invisible(NULL))
  }
  return(invisible(TRUE))
}
