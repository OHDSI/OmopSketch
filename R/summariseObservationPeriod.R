#' Create a gt table from a summarised omop_table.
#'
#' @param observationPeriod observation_period omop table
#' @param unit Whether to stratify by "year" or by "month"
#' @param unitInterval Number of years or months to stratify with
#'
#' @return A summarised_result object with the summarised data.
#'
#' @export
#'
summariseObservationPeriod <- function(observationPeriod, unit = "year", unitInterval = 1){
#
#   # Check input ----
#   assertClass(observationPeriod, "omop_table")
#
#   x <- omopgenerics::tableName(observationPeriod)
#   if (x != "observation_period") {
#     cli::cli_abort(
#       "Table name ({x}) is not observation_period, please provide a valid
#       observation_period table"
#     )
#   }
#
#   if(observationPeriod |> dplyr::tally() |> dplyr::pull("n") == 0){
#     cli::cli_warn("observation_period table is empty. Returning an empty summarised result.")
#     return(omopgenerics::emptySummarisedResult())
#   }
#
#   observationPeriod <- observationPeriod |>
#     dplyr::ungroup()
#
#   if(missing(unit)){unit <- "year"}
#   if(missing(unitInterval)){unitInterval <- 1}
#
#   checkUnit(unit)
#   checkUnitInterval(unitInterval)
#
#   cdm <- omopgenerics::cdmReference(observationPeriod)
#
#   # Observation period ----
#   name <- "observation_period"
#   start_date_name <- startDate(name)
#   end_date_name   <- endDate(name)
#
#   interval <- getIntervalTibble(observationPeriod, start_date_name, end_date_name, unit, unitInterval)
#
#   # Insert interval table to the cdm ----
#   cdm <- cdm |>
#     omopgenerics::insertTable(name = "interval", table = interval)
#
#   # Calculate denominator ----
#   denominator <- cdm[["person"]] |>
#     dplyr::ungroup() |>
#     dplyr::select("person_id") |>
#     dplyr::summarise("n" = dplyr::n()) |>
#     dplyr::pull("n")
#
#   # Create summarised result ----
#   result <- observationPeriod |>
#     countRecords(cdm, start_date_name, end_date_name, unit)
#
#   result <- result |>
#     dplyr::mutate(
#       "estimate_value" = as.character(.data$estimate_value),
#       "variable_name" = "overlap_records"
#     ) |>
#     visOmopResults::uniteStrata(cols = "time_interval") |>
#     dplyr::mutate(
#       "result_id" = as.integer(1),
#       "cdm_name" = omopgenerics::cdmName(omopgenerics::cdmReference(observationPeriod)),
#       "group_name"  = "omop_table",
#       "group_level" = name,
#       "variable_level" = gsub(" to.*","",.data$strata_level),
#       "estimate_name" = "count",
#       "estimate_type" = "integer",
#       "additional_name" = "overall",
#       "additional_level" = "overall"
#     )
#
#   result <- result |>
#     rbind(result) |>
#     dplyr::group_by(.data$strata_level) |>
#     dplyr::mutate(estimate_type = dplyr::if_else(
#       dplyr::row_number() == 2, "percentage", .data$estimate_type
#     )) |>
#     dplyr::mutate(estimate_value = dplyr::if_else(
#       .data$estimate_type == "percentage", as.character(as.numeric(.data$estimate_value)/denominator*100), .data$estimate_value
#     )) |>
#     dplyr::mutate(estimate_name = dplyr::if_else(
#       .data$estimate_type == "percentage", "percentage", .data$estimate_name)) |>
#     omopgenerics::newSummarisedResult(settings = dplyr::tibble(
#       "result_id" = 1L,
#       "result_type" = "summarised_observation_period",
#       "package_name" = "OmopSketch",
#       "package_version" = as.character(utils::packageVersion("OmopSketch")),
#       "unit" = .env$unit,
#       "unitInterval" = .env$unitInterval
#     ))
#
#   omopgenerics::dropTable(cdm = cdm, name = "interval")
#   return(result)
}

countRecords <- function(observationPeriod, cdm, start_date_name, end_date_name, unit){
  tablePrefix <- omopgenerics::tmpPrefix()

  x <- observationPeriod %>%
    dplyr::mutate("start" = lubridate::floor_date(.data[[start_date_name]], unit = "month")) |>
    dplyr::mutate("end"   = lubridate::floor_date(.data[[end_date_name]], unit = "month")) |>
    dplyr::group_by(.data$start, .data$end) |>
    dplyr::summarise(n = dplyr::n()) |>
    dplyr::compute(
      name = omopgenerics::uniqueTableName(tablePrefix), temporary = FALSE
    )

  x <- cdm[["interval"]] |>
    dplyr::cross_join(x) |>
    dplyr::filter((.data$start < .data$interval_start_date & .data$end >= .data$interval_start_date) |
                    (.data$start >= .data$interval_start_date & .data$start <= .data$interval_end_date)) |>
    dplyr::group_by(.data$interval_group) |>
    dplyr::summarise(n = sum(.data$n, na.rm = TRUE)) |>
    dplyr::select("estimate_value" = "n", "time_interval" = "interval_group") |>
    dplyr::collect()

  omopgenerics::dropTable(cdm = cdm, name = c(dplyr::starts_with(tablePrefix)))

  return(x)
}
