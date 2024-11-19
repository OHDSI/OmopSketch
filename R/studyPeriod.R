studyPeriod <- function(omopTable, dateRange){


  if(is.null(dateRange)){

    return(omopTable)
  }

  start_date_table <- startDate(omopgenerics::tableName(omopTable))
  end_date_table <- endDate(omopgenerics::tableName(omopTable))
  start_date <- dateRange[1]
  end_date <-dateRange[2]

  omopTable <- omopTable |>
    dplyr::filter(
      !!rlang::sym(start_date_table) >= start_date & !!rlang::sym(start_date_table) <= end_date
    ) |>
    dplyr::filter(
      !!rlang::sym(end_date_table) >= start_date & !!rlang::sym(end_date_table) <= end_date
    )  # maybe the end date check is not needed

  warningEmptyStudyPeriod(omopTable)


  return(omopTable)
}

warningEmptyStudyPeriod <- function (omopTable) {
  if (omopgenerics::isTableEmpty(omopTable)){
    cli::cli_warn(paste0(omopgenerics::tableName(omopTable), " omop table is empty after application of date range."))
    return(NULL)
  }
  return(TRUE)
}
