#' Create a summarised result with the number of people in observation during a specific interval of time
#'
#' @param observationPeriod observation_period omop table.
#' @param unit Whether to stratify by "year" or by "month".
#' @param unitInterval Number of years or months to stratify with.
#' @param sex Whether to stratify by sex (TRUE) or not (FALSE).
#'
#' @return A summarised_result object with the summarised data.
#'
#' @export
#'
summariseInObservation <- function(observationPeriod, unit = "year", unitInterval = 1, sex = FALSE){

  # Initial checks ----
  assertClass(observationPeriod, "omop_table")

  x <- omopgenerics::tableName(observationPeriod)
  if (x != "observation_period") {
    cli::cli_abort(
      "Table name ({x}) is not observation_period, please provide a valid
      observation_period table"
    )
  }

  if(observationPeriod |> dplyr::tally() |> dplyr::pull("n") == 0){
    cli::cli_warn("observation_period table is empty. Returning an empty summarised result.")
    return(omopgenerics::emptySummarisedResult())
  }

  if(missing(unit)){unit <- "year"}
  if(missing(unitInterval)){unitInterval <- 1}

  checkUnit(unit)
  checkUnitInterval(unitInterval)
  assertLogical(sex, length = 1)

  # Create initial variables ----
  observationPeriod <- observationPeriod |>
    dplyr::ungroup()

  cdm <- omopgenerics::cdmReference(observationPeriod)

  # Add strata variables ----
  strata <- c("age_group", "sex")
  observationPeriod <- addDemographicsToOmopTable(observationPeriod, date = "observation_period_start_date", ageGroup = NULL, sex)

  # Observation period ----
  name <- "observation_period"
  start_date_name <- startDate(name)
  end_date_name   <- endDate(name)

  interval <- getIntervalTibbleForObservation(observationPeriod, start_date_name, end_date_name, unit, unitInterval)

  # Insert interval table to the cdm ----
  cdm <- cdm |>
    omopgenerics::insertTable(name = "interval", table = interval)

  # Calculate denominator ----
  denominator <- cdm |> getDenominator()

  # Count records ----
  result <- observationPeriod |> countRecords(cdm, start_date_name, end_date_name, unit)

  # Create summarisedResult
  result <- createSummarisedResultObservationPeriod(result, observationPeriod, name, denominator, unit, unitInterval)

  omopgenerics::dropTable(cdm = cdm, name = "interval")
  return(result)
}

getDenominator <- function(cdm){
  cdm[["person"]] |>
    dplyr::ungroup() |>
    dplyr::select("person_id") |>
    dplyr::summarise("n" = dplyr::n()) |>
    dplyr::pull("n")
}

getIntervalTibbleForObservation <- function(omopTable, start_date_name, end_date_name, unit, unitInterval){
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

countRecords <- function(observationPeriod, cdm, start_date_name, end_date_name, unit){
  tablePrefix <- omopgenerics::tmpPrefix()

  x <- observationPeriod %>%
    dplyr::mutate("start" = as.Date(paste0(clock::get_year(.data[[start_date_name]]),"/",clock::get_month(.data[[start_date_name]]),"/01"))) |>
    dplyr::mutate("end"   = as.Date(paste0(clock::get_year(.data[[end_date_name]]),"/",clock::get_month(.data[[end_date_name]]),"/01"))) |>
    dplyr::group_by(.data$start, .data$end, .data$sex) |>
    dplyr::summarise(n = dplyr::n()) |>
    dplyr::compute(
      name = omopgenerics::uniqueTableName(tablePrefix), temporary = FALSE
    )

  x <- cdm[["interval"]] |>
    dplyr::cross_join(x) |>
    dplyr::filter((.data$start < .data$interval_start_date & .data$end >= .data$interval_start_date) |
                    (.data$start >= .data$interval_start_date & .data$start <= .data$interval_end_date)) |>
    dplyr::group_by(.data$interval_group, .data$sex) |>
    dplyr::summarise(n = sum(.data$n, na.rm = TRUE), .groups = "drop") |>
    dplyr::select("estimate_value" = "n", "sex", "time_interval" = "interval_group") |>
    dplyr::collect() |>
    dplyr::arrange(.data$time_interval)

  omopgenerics::dropTable(cdm = cdm, name = c(dplyr::starts_with(tablePrefix)))

  return(x)
}

createSummarisedResultObservationPeriod <- function(result, observationPeriod, name, denominator, unit, unitInterval){
  result <- result |>
    dplyr::mutate(
      "estimate_value" = as.character(.data$estimate_value),
      "variable_name" = "overlap_records"
    ) |>
    dplyr::rename("variable_level" = "time_interval") |>
    visOmopResults::uniteStrata(cols = c("sex")) |>
    dplyr::mutate(
      "result_id" = as.integer(1),
      "cdm_name" = omopgenerics::cdmName(omopgenerics::cdmReference(observationPeriod)),
      "group_name"  = "omop_table",
      "group_level" = name,
      "estimate_name" = "count",
      "estimate_type" = "integer",
      "additional_name" = "overall",
      "additional_level" = "overall"
    )

  result <- result |>
    rbind(result) |>
    dplyr::group_by(.data$variable_level, .data$strata_level) |>
    dplyr::mutate(estimate_type = dplyr::if_else(dplyr::row_number() == 2, "percentage", .data$estimate_type)) |>
    dplyr::mutate(estimate_value = dplyr::if_else(.data$estimate_type == "percentage", as.character(as.numeric(.data$estimate_value)/denominator*100), .data$estimate_value)) |>
    dplyr::mutate(estimate_name = dplyr::if_else(.data$estimate_type == "percentage", "percentage", .data$estimate_name)) |>
    omopgenerics::newSummarisedResult(settings = dplyr::tibble(
      "result_id" = 1L,
      "result_type" = "summarised_observation_period",
      "package_name" = "OmopSketch",
      "package_version" = as.character(utils::packageVersion("OmopSketch")),
      "unit" = .env$unit,
      "unitInterval" = .env$unitInterval
    ))

  return(result)
}
