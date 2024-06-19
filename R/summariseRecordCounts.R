#' Create a gt table from a summarised omop_table.
#'
#' @param omopTable A summarised_result object with the output from summariseOmopTable().
#' @param unit Whether to stratify by "year" or by "month"
#' @param unitInterval Number of years or months to stratify with
#'
#' @return A summarised_result object with the summarised data.
#'
#' @importFrom rlang :=
#' @export
#'
summariseRecordCounts <- function(omopTable, unit = "year", unitInterval = 1) {

  # Initial checks ----
  omopTableChecks(omopTable)

  if(missing(unit)){unit <- "year"}
  if(missing(unitInterval)){unitInterval <- 1}

  unitChecks(unit)
  unitIntervalChecks(unitInterval)

  cdm <- omopgenerics::cdmReference(omopTable)
  omopTable <- omopTable |> dplyr::ungroup()

  name   <- omopgenerics::tableName(omopTable)
  result <- omopgenerics::emptySummarisedResult()
  date   <- startDate(name)

  if(omopTable |> dplyr::tally() |> dplyr::pull("n") == 0){
    cli::cli_warn(paste0(omopgenerics::tableName(omopTable), " omop table is empty. Returning an empty summarised result."))
    return(result)
  }

  # Incidence counts ----
  omopTable <- omopTable |>
    dplyr::select(dplyr::all_of(date), "person_id")

  if (name != "observation_period") {
    omopTable <- omopTable |>
      filterInObservation(indexDate = date)
  }

  # interval sequence ----
  interval <- getIntervalTibble(omopTable, date, date, unit, unitInterval)

  # Insert interval table to the cdm ----
  cdm <- cdm |>
    omopgenerics::insertTable(name = "interval", table = interval)

  # Create summarised result
  result <- cdm$interval |>
    dplyr::cross_join(
      omopTable |>
        dplyr::rename("incidence_date" = dplyr::all_of(date))) |>
    dplyr::filter(.data$incidence_date >= .data$interval_start_date &
                    .data$incidence_date <= .data$interval_end_date) |>
    dplyr::group_by(.data$interval_group)  |>
    dplyr::summarise("estimate_value" = dplyr::n(), .groups = "drop") |>
    dplyr::collect() |>
    dplyr::ungroup()

  result <- result |>
    dplyr::mutate(
      "estimate_value" = as.character(.data$estimate_value),
      "variable_name" = "incidence_records",
    ) |>
    dplyr::rename("time_interval" = "interval_group") |>
    visOmopResults::uniteStrata(cols = "time_interval") |>
    dplyr::mutate(
      "result_id" = as.integer(1),
      "cdm_name" = omopgenerics::cdmName(omopgenerics::cdmReference(omopTable)),
      "group_name"  = "omop_table",
      "group_level" = name,
      "variable_level" = gsub(" to.*","",strata_level),
      "estimate_name" = "count",
      "estimate_type" = "integer",
      "additional_name" = "overall",
      "additional_level" = "overall"
    ) |>
    omopgenerics::newSummarisedResult(settings = dplyr::tibble(
      "result_id" = 1L,
      "result_type" = "summarised_table_counts",
      "package_name" = "OmopSketch",
      "package_version" = as.character(utils::packageVersion("OmopSketch")),
      "unit" = .env$unit,
      "unitInterval" = .env$unitInterval
    ))

  omopgenerics::dropTable(cdm = cdm, name = "interval")

  return(result)
}

omopTableChecks <- function(omopTable){
  assertClass(omopTable, "omop_table")
  omopTable |>
    omopgenerics::tableName() |>
    assertChoice(choices = tables$table_name)
}

unitChecks <- function(unit){
  inherits(unit, "character")
  assertLength(unit, 1)
  if(!unit %in% c("year","month")){
    cli::cli_abort("units value is not valid. Valid options are year or month.")
  }
}

unitIntervalChecks <- function(unitInterval){
  inherits(unitInterval, c("numeric", "integer"))
  assertLength(unitInterval, 1)
  if(unitInterval < 1){
    cli::cli_abort("unitInterval input has to be equal or greater than 1.")
  }
  if(!(unitInterval%%1 == 0)){
    cli::cli_abort("unitInterval has to be an integer.")
  }
}

filterInObservation <- function(x, indexDate) {
  cdm <- omopgenerics::cdmReference(x)
  id <- c("person_id", "subject_id")
  id <- id[id %in% colnames(x)]

  x |>
    dplyr::inner_join(
      cdm$observation_period |>
        dplyr::select(
          !!id := "person_id",
          "start" = "observation_period_start_date",
          "end" = "observation_period_end_date"
        ),
      by = id
    ) |>
    dplyr::filter(
      .data[[indexDate]] >= .data$start & .data[[indexDate]] <= .data$end
    )
}

getOmopTableStartDate <- function(omopTable, date){
  omopTable |>
    dplyr::summarise("startDate" = min(.data[[date]], na.rm = TRUE)) |>
    dplyr::collect() |>
    dplyr::mutate("startDate" = as.Date(paste0(lubridate::year(startDate),"-01-01"))) |>
    dplyr::pull("startDate")
}

getOmopTableEndDate   <- function(omopTable, date){
  omopTable |>
    dplyr::summarise("endDate" = max(.data[[date]], na.rm = TRUE)) |>
    dplyr::collect() |>
    dplyr::mutate("endDate" = as.Date(paste0(lubridate::year(endDate),"-12-31"))) |>
    dplyr::pull("endDate")
}

getIntervalTibble <- function(omopTable, start_date_name, end_date_name, unit, unitInterval){
  startDate <- getOmopTableStartDate(omopTable, start_date_name)
  endDate   <- getOmopTableEndDate(omopTable, end_date_name)

  tibble::tibble(
    "group" = seq.Date(as.Date(startDate), as.Date(endDate), .env$unit)
  ) |>
    dplyr::rowwise() |>
    dplyr::mutate("interval" = max(which(
      .data$group >= seq.Date(from = startDate, to = endDate, by = paste(.env$unitInterval, .env$unit))
    ),
    na.rm = TRUE)) |>
    dplyr::ungroup() |>
    dplyr::group_by(.data$interval) |>
    dplyr::mutate(
      "interval_start_date" = min(.data$group),
      "interval_end_date"   = dplyr::if_else(.env$unit == "year",
                                             min(.data$group)+lubridate::years(.env$unitInterval)-1,
                                             min(.data$group)+months(.env$unitInterval)-1)
    ) |>
    dplyr::mutate(
      "interval_start_date" = as.Date(.data$interval_start_date),
      "interval_end_date" = as.Date(.data$interval_end_date)
    ) |>
    dplyr::mutate(
      "interval_group" = paste(.data$interval_start_date,"to",.data$interval_end_date)
    ) |>
    dplyr::ungroup() |>
    dplyr::select("interval_start_date", "interval_end_date", "interval_group") |>
    dplyr::distinct()
}
