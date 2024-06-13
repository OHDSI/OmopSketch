#' Create a gt table from a summarised omop_table.
#'
#' @param summarisedOmopTable A summarised_result object with the output from summariseOmopTable().
#'
#' @return A gt object with the summarised data.
#'
#' @export
#'
summariseObservationPeriod <- function(observationPeriod, unit = "year", unitInterval = 1){

  observationPeriod <- cdm$observation_period
  unit <- "month"
  unitInterval <- 1

  # Check input ----
  omopTableChecks(observationPeriod)

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

  observationPeriod <- observationPeriod |>
    dplyr::ungroup()

  unitChecks(unit)
  unitIntervalChecks(unitInterval)

  if(missing(unit)){
    unit <- "year"
  }

  if(missing(unitInterval)){
    unitInterval <- 1
  }

  cdm <- omopgenerics::cdmReference(observationPeriod)

  # Observation period ----
  name <- "observation_period"
  start_date_name <- startDate(name)
  end_date_name   <- endDate(name)

  interval <- getIntervalTibble(observationPeriod, start_date_name, end_date_name, unit, unitInterval) |>
    dplyr::mutate("start_interval" = gsub(" to.*","",.data$incidence_group)) |>
    dplyr::mutate("end_interval"   = gsub(".* to ","",.data$incidence_group))

  # Insert interval table to the cdm ----
  cdm <- cdm |>
    omopgenerics::insertTable(name = "interval", table = interval)

  # Calculate denominator ----
  denominator <- cdm[["person"]] |>
    dplyr::ungroup() |>
    dplyr::select("person_id") |>
    dplyr::summarise("n" = dplyr::n()) |>
    dplyr::pull("n")

  # Create summarised result ----
  result <- observationPeriod |>
    countRecords(cdm, start_date_name, end_date_name, unit)

  result <- result |>
    dplyr::mutate(group = dplyr::if_else(rep(unitInterval, nrow(result)) == 1,
                                         gsub(" to.*", "", .data$group),
                                         .data$group)) |>
    dplyr::mutate(
      "estimate_value" = as.character(.data$estimate_value),
      "variable_name" = "overlap_records"
    ) |>
    visOmopResults::uniteStrata(cols = "group") |>
    dplyr::mutate("strata_name" = dplyr::if_else(.data$strata_name == "group",
                                                 glue::glue("{unitInterval}_{unit}{if (unitInterval > 1) 's' else ''}"),
                                                 .data$strata_name)) |>
    dplyr::mutate(
      "result_id" = as.integer(1),
      "cdm_name" = omopgenerics::cdmName(omopgenerics::cdmReference(omopTable)),
      "group_name"  = "omop_table",
      "group_level" = name,
      "variable_level" = NA_character_,
      "estimate_name" = "count",
      "estimate_type" = "integer",
      "additional_name" = "overall",
      "additional_level" = "overall"
    )

  result <- result |>
    rbind(result) |>
    dplyr::group_by(.data$strata_level) |>
    dplyr::mutate(estimate_type = dplyr::if_else(
      dplyr::row_number() == 2, "percentage", .data$estimate_type
    )) |>
    dplyr::mutate(estimate_value = dplyr::if_else(
      estimate_type == "percentage", as.character(as.numeric(.data$estimate_value)/denominator*100), .data$estimate_value
    )) |>
    dplyr::mutate(estimate_name = dplyr::if_else(
      estimate_type == "percentage", "percentage", .data$estimate_name)) |>
    omopgenerics::newSummarisedResult()
}


countRecords <- function(observationPeriod, cdm, start_date_name, end_date_name, unit){
  tablePrefix <- omopgenerics::tmpPrefix()

  if(unit == "year"){
    x <- observationPeriod %>%
      dplyr::mutate("start" = !!CDMConnector::datepart(start_date_name,"year")) %>%
      dplyr::mutate("end"   = !!CDMConnector::datepart(end_date_name,"year")) |>
      dplyr::group_by(.data$start, .data$end) |>
      dplyr::summarise(n = dplyr::n(), .groups = "drop") |>
      dplyr::mutate(dplyr::across(dplyr::everything(), as.integer)) |>
      dplyr::compute(
        name = omopgenerics::uniqueTableName(tablePrefix), temporary = FALSE
      )

    x <- x |>
      dplyr::cross_join(cdm[["interval"]]) |>
      dplyr::filter(.data$start <= .data$start_interval & .data$end >= .data$end_interval) |>
      dplyr::group_by(.data$interval) |>
      dplyr::summarise(n = sum(.data$n, na.rm = TRUE)) |>
      dplyr::right_join(
        cdm$interval |>
          dplyr::select(-c("group", "unit", "start_interval","end_interval")) |>
          dplyr::distinct(), by = "interval"
      ) |>
      dplyr::select("estimate_value" = "n", "group" = "incidence_group") |>
      dplyr::collect()

  }else if(unit == "month"){
    x <- observationPeriod %>%
      dplyr::mutate("start_year" = !!CDMConnector::datepart(start_date_name,"year")) %>%
      dplyr::mutate("end_year"   = !!CDMConnector::datepart(end_date_name,"year")) %>%
      dplyr::mutate("start_month" = !!CDMConnector::datepart(start_date_name,"month")) %>%
      dplyr::mutate("end_month"   = !!CDMConnector::datepart(end_date_name,"month")) |>
      dplyr::group_by(.data$start_year, .data$start_month, .data$end_year, .data$end_month) |>
      dplyr::summarise(n = dplyr::n(), .groups = "drop") |>
      dplyr::mutate(dplyr::across(dplyr::everything(), as.integer)) |>
      dplyr::compute(
        name = omopgenerics::uniqueTableName(tablePrefix), temporary = FALSE
      )

    cdm[["interval"]] <- cdm[["interval"]] |>
      dplyr::mutate(start_interval = as.Date(paste0(start_interval,"-01"))) |>
      dplyr::mutate(end_interval   = as.Date(paste0(end_interval,"-01"))) %>%
      dplyr::mutate("start_year_interval" = !!CDMConnector::datepart("start_interval","year")) %>%
      dplyr::mutate("end_year_interval"   = !!CDMConnector::datepart("end_interval","year")) %>%
      dplyr::mutate("start_month_interval" = !!CDMConnector::datepart("start_interval","month")) %>%
      dplyr::mutate("end_month_interval"   = !!CDMConnector::datepart("end_interval","month"))


    x <- x |>
      dplyr::cross_join(cdm[["interval"]]) |>
      dplyr::filter(.data$start_year <= .data$start_year_interval,
                    .data$start_month <= .data$start_month_interval,
                    .data$end_year >= .data$end_year_interval,
                    .data$end_year >= .data$end_month_interval) |>
      dplyr::group_by(.data$interval) |>
      dplyr::summarise(n = sum(.data$n, na.rm = TRUE)) |>
      dplyr::right_join(
        cdm$interval |>
          dplyr::select(-c("group", "unit", "start_interval","end_interval")) |>
          dplyr::distinct(), by = "interval"
      ) |>
      dplyr::select("estimate_value" = "n", "group" = "incidence_group") |>
      dplyr::collect()
  }




  omopgenerics::dropTable(cdm = cdm, name = c(dplyr::starts_with(tablePrefix)))

  return(x)
}
