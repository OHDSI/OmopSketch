#' Summarise the number of people in observation during a specific interval of
#' time.
#'
#' @param observationPeriod An observation_period omop table. It must be part of
#' a cdm_reference object.
#' @param interval Time interval to stratify by. It can either be "years", "quarters", "months" or "overall".
#' @param output Output format. It can be either the number of records
#' ("records") that are in observation in the specific interval of time, the
#' number of person-days ("person-days"), or both c("records","person-days").
#' @param ageGroup A list of age groups to stratify results by.
#' @param sex Boolean variable. Whether to stratify by sex (TRUE) or not
#' (FALSE).
#' @param dateRange A list containing the minimum and the maximum dates
#' defining the time range within which the analysis is performed.
#' @return A summarised_result object.
#' @export
#' @examples
#' \donttest{
#' library(dplyr, warn.conflicts = FALSE)
#'
#' cdm <- mockOmopSketch()
#'
#' result <- summariseInObservation(
#'   cdm$observation_period,
#'   interval = "months",
#'   output = c("person-days","records"),
#'   ageGroup = list("<=60" = c(0,60), ">60" = c(61, Inf)),
#'   sex = TRUE
#' )
#'
#' result |>
#'   glimpse()
#'
#' PatientProfiles::mockDisconnect(cdm)
#'
#' }
summariseInObservation <- function(observationPeriod,
                                   interval = "overall",
                                   output = "records",
                                   ageGroup = NULL,
                                   sex = FALSE, dateRange = NULL){

  tablePrefix <-  omopgenerics::tmpPrefix()

  # Initial checks ----
  omopgenerics::assertClass(observationPeriod, "omop_table")
  omopgenerics::assertTrue(omopgenerics::tableName(observationPeriod) == "observation_period")
  dateRange <- validateStudyPeriod(omopgenerics::cdmReference(observationPeriod), dateRange)

  if(omopgenerics::isTableEmpty(observationPeriod)){
    cli::cli_warn("observation_period table is empty. Returning an empty summarised result.")
    return(omopgenerics::emptySummarisedResult(settings = createSettings(result_type = "summarise_in_observation")))
  }

  checkOutput(output)
  ageGroup <- omopgenerics::validateAgeGroupArgument(ageGroup, ageGroupName = "")[[1]]
  omopgenerics::assertLogical(sex, length = 1)
  original_interval <- interval
  x <- validateIntervals(interval)
  interval <- x$interval
  unitInterval <- x$unitInterval

  if(length(output) > 1){output <- "all"}
  if(missing(ageGroup) | is.null(ageGroup)){ageGroup <- list("overall" = c(0,Inf))}else{ageGroup <- append(ageGroup, list("overall" = c(0, Inf)))}

  # Create initial variables ----
  cdm <- omopgenerics::cdmReference(observationPeriod)
  observationPeriod <- addStrataToPeopleInObservation(cdm, ageGroup, sex, tablePrefix, dateRange)

  # Calculate denominator ----
  denominator <- cdm |> getDenominator(output)

  name <- "observation_period"
  start_date_name <- omopgenerics::omopColumns(table = name, field = "start_date")
  end_date_name   <- omopgenerics::omopColumns(table = name, field = "end_date")

  # Observation period ----
  if(interval != "overall"){
    timeInterval <- getIntervalTibbleForObservation(observationPeriod, start_date_name, end_date_name, interval, unitInterval)

    # Insert interval table to the cdm ----
    cdm <- cdm |>
      omopgenerics::insertTable(name = paste0(tablePrefix,"interval"), table = timeInterval)
  }

  # Count records ----
  result <- observationPeriod |>
    countRecords(cdm, start_date_name, end_date_name, interval, output, tablePrefix)

  # Add category sex overall
  result <- addSexOverall(result, sex)

  # Create summarisedResult
  result <- createSummarisedResultObservationPeriod(result, observationPeriod, name, denominator,dateRange, original_interval)

  CDMConnector::dropTable(cdm, name = dplyr::starts_with(tablePrefix))
  return(result)
}

getDenominator <- function(cdm, output){
  if(output == "records"){
    tibble::tibble(
      "denominator" = c(cdm[["person"]] |>
                          dplyr::ungroup() |>
                          dplyr::select("person_id") |>
                          dplyr::summarise("n" = dplyr::n()) |>
                          dplyr::pull("n")),
      "variable_name" = "Number records in observation")
  }else if(output == "person-days"){
    y <- cdm[["observation_period"]] |>
      dplyr::ungroup() |>
      dplyr::inner_join(cdm[["person"]] |> dplyr::select("person_id"), by = "person_id") %>%
      dplyr::mutate(n = !!CDMConnector::datediff("observation_period_start_date", "observation_period_end_date",interval = "day")+1) |>
      dplyr::summarise("n" = sum(.data$n, na.rm = TRUE)) |>
      dplyr::pull("n")

    tibble::tibble(
      "denominator" = y,
      "variable_name" = "Number person-days")

  }else if(output == "all"){
    y <- cdm[["observation_period"]] |>
      dplyr::ungroup() |>
      dplyr::inner_join(cdm[["person"]] |> dplyr::select("person_id"), by = "person_id") %>%
      dplyr::mutate(n = !!CDMConnector::datediff("observation_period_start_date", "observation_period_end_date",interval = "day")+1) |>
      dplyr::summarise("n" = sum(.data$n, na.rm = TRUE)) |>
      dplyr::pull("n")

    tibble::tibble(
      "denominator" = c(cdm[["person"]] |>
                          dplyr::ungroup() |>
                          dplyr::select("person_id") |>
                          dplyr::summarise("n" = dplyr::n()) |>
                          dplyr::pull("n"),
                        y
      ),
      "variable_name" = c("Number records in observation","Number person-days"))
  }
}

getIntervalTibbleForObservation <- function(omopTable, start_date_name, end_date_name, interval, unitInterval){
  startDate <- getOmopTableStartDate(omopTable, start_date_name)
  endDate   <- getOmopTableEndDate(omopTable, end_date_name)

  tibble::tibble(
    "group" = seq.Date(startDate, endDate, .env$interval)
  ) |>
    dplyr::rowwise() |>
    dplyr::mutate("interval" = max(which(
      .data$group >= seq.Date(from = startDate, to = endDate, by = paste(.env$unitInterval, .env$interval))
    ),
    na.rm = TRUE)) |>
    dplyr::ungroup() |>
    dplyr::group_by(.data$interval) |>
    dplyr::mutate(
      "interval_start_date" = min(.data$group),
      "interval_end_date"   = dplyr::if_else(.env$interval == "year",
                                             clock::add_years(min(.data$group),.env$unitInterval)-1,
                                             clock::add_months(min(.data$group),.env$unitInterval)-1)
    ) |>
    dplyr::mutate(
      "interval_start_date" = as.Date(.data$interval_start_date),
      "interval_end_date" = as.Date(.data$interval_end_date)
    ) |>
    dplyr::mutate(
      "time_interval" = paste(.data$interval_start_date,"to",.data$interval_end_date)
    ) |>
    dplyr::ungroup() |>
    dplyr::select("interval_start_date", "interval_end_date", "time_interval") |>
    dplyr::distinct()
}

countRecords <- function(observationPeriod, cdm, start_date_name, end_date_name, interval, output, tablePrefix){

  if(output == "person-days" | output == "all"){
    if(interval != "overall"){
      x <- cdm[[paste0(tablePrefix, "interval")]] |>
        dplyr::cross_join(
          observationPeriod |>
            dplyr::select("start_date" = "observation_period_start_date",
                          "end_date"   = "observation_period_end_date",
                          "age_group", "sex","person_id")
        ) |>
        dplyr::filter((.data$start_date < .data$interval_start_date & .data$end_date >= .data$interval_start_date) |
                        (.data$start_date >= .data$interval_start_date & .data$start_date <= .data$interval_end_date)) %>%
        dplyr::mutate(start_date = pmax(.data$interval_start_date, .data$start_date, na.rm = TRUE)) |>
        dplyr::mutate(end_date   = pmin(.data$interval_end_date, .data$end_date, na.rm = TRUE)) |>
        dplyr::compute(temporary = FALSE, name = tablePrefix)
      additional_column <- "time_interval"
    }else{
      x <- observationPeriod |>
        dplyr::rename("start_date" = "observation_period_start_date",
                      "end_date"   = "observation_period_end_date")
      additional_column <- character()
    }

    personDays <- x %>%
      dplyr::mutate(estimate_value = !!CDMConnector::datediff("start_date","end_date", interval = "day")+1) |>
      dplyr::group_by(dplyr::across(dplyr::any_of(c( "sex", "age_group","time_interval")))) |>
      dplyr::summarise(estimate_value = sum(.data$estimate_value, na.rm = TRUE), .groups = "drop") |>
      dplyr::mutate("variable_name" = "Number person-days")|>
      dplyr::collect()
  }else{
    personDays <- createEmptyIntervalTable(interval)
  }

  if(output == "records" | output == "all"){

    if(interval != "overall"){
      x <- observationPeriod |>
        dplyr::mutate("start_date" = as.Date(paste0(clock::get_year(.data[[start_date_name]]),"/",clock::get_month(.data[[start_date_name]]),"/01"))) |>
        dplyr::mutate("end_date"   = as.Date(paste0(clock::get_year(.data[[end_date_name]]),"/",clock::get_month(.data[[end_date_name]]),"/01"))) |>
        dplyr::group_by(.data$start_date, .data$end_date, .data$age_group, .data$sex) |>
        dplyr::summarise(estimate_value = dplyr::n(), .groups = "drop") |>
        dplyr::compute(temporary = FALSE, name = tablePrefix)

      records <- cdm[[paste0(tablePrefix, "interval")]] |>
        dplyr::cross_join(x) |>
        dplyr::filter((.data$start_date < .data$interval_start_date & .data$end_date >= .data$interval_start_date) |
                        (.data$start_date >= .data$interval_start_date & .data$start_date <= .data$interval_end_date)) |>
        dplyr::group_by(.data$time_interval, .data$age_group, .data$sex) |>
        dplyr::summarise(estimate_value = sum(.data$estimate_value, na.rm = TRUE), .groups = "drop") |>
        dplyr::mutate("variable_name" = "Number records in observation") |>
        dplyr::collect()
      additional_column <- "time_interval"
    }else{
      records <- observationPeriod |>
        dplyr::group_by(.data$age_group, .data$sex) |>
        dplyr::summarise(estimate_value = dplyr::n(), .groups = "drop") |>
        dplyr::mutate("variable_name" = "Number records in observation") |>
        dplyr::collect()
      additional_column <- character()
    }
  }else{
    records <- createEmptyIntervalTable(interval)
  }

  x <- personDays |>
    rbind(records) |>
    omopgenerics::uniteAdditional(additional_column)|>
    dplyr::arrange(dplyr::across(dplyr::any_of("additional_level")))

  return(x)
}

createSummarisedResultObservationPeriod <- function(result, observationPeriod, name, denominator, dateRange,original_interval){
  if (dim(result)[1] == 0) {
    result<-omopgenerics::emptySummarisedResult() |>
      omopgenerics::newSummarisedResult(settings = createSettings(result_type = "summarise_in_observation", study_period = dateRange)|>
                                          dplyr::mutate("interval" = .env$original_interval))
  }else{
    result <- result |>
      dplyr::mutate("estimate_value" = as.character(.data$estimate_value)) |>
      omopgenerics::uniteStrata(cols = c("sex", "age_group")) |>
      dplyr::mutate(
        "result_id" = as.integer(1),
        "cdm_name" = omopgenerics::cdmName(omopgenerics::cdmReference(observationPeriod)),
        "group_name"  = "omop_table",
        "group_level" = name,
        "variable_level" = as.character(NA),
        "estimate_name" = "count",
        "estimate_type" = "integer"
      )

    result <- result |>
      rbind(result) |>
      dplyr::group_by(.data$additional_level, .data$strata_level, .data$variable_name) |>
      dplyr::mutate(estimate_type = dplyr::if_else(dplyr::row_number() == 2, "percentage", .data$estimate_type)) |>
      dplyr::inner_join(denominator, by = "variable_name") |>
      dplyr::mutate(estimate_value = dplyr::if_else(.data$estimate_type == "percentage", as.character(as.numeric(.data$estimate_value)/denominator*100), .data$estimate_value)) |>
      dplyr::select(-c("denominator")) |>
      dplyr::mutate(estimate_name = dplyr::if_else(.data$estimate_type == "percentage", "percentage", .data$estimate_name)) |>
      omopgenerics::newSummarisedResult(settings = createSettings(result_type = "summarise_in_observation", study_period = dateRange)|>
                                          dplyr::mutate("interval" = .env$original_interval)
      )
  }
  return(result)
}

addStrataToPeopleInObservation <- function(cdm, ageGroup, sex, tablePrefix, dateRange) {
  demographics <- cdm |>
    CohortConstructor::demographicsCohort(
      name = paste0(tablePrefix, "demographics_table"),
      sex = NULL,
      ageRange = ageGroup,
      minPriorObservation = NULL
    ) |>
    suppressMessages()

  if (!is.null(dateRange)) {
    demographics <- demographics |>
      CohortConstructor::requireInDateRange(dateRange = dateRange)
    warningEmptyStudyPeriod(demographics)
  }
  if (sex) {
    demographics <- demographics |>
      PatientProfiles::addSexQuery()
  } else {
    demographics <- demographics |>
      dplyr::mutate("sex" = "overall")
  }

  if (!is.null(ageGroup)) {
    set <- omopgenerics::settings(demographics) |>
      dplyr::select("cohort_definition_id", dplyr::any_of("age_range"))
    set <- set |>
      dplyr::left_join(
        dplyr::tibble(
          "age_range" = purrr::map_chr(ageGroup, \(x) paste0(x[1], "_", x[2])),
          "age_group" = names(ageGroup)
        ),
        by = "age_range"
      ) |>
      dplyr::mutate("age_group" = dplyr::if_else(
        is.na(.data$age_group), .data$age_range, .data$age_group
      )) |>
      dplyr::select(!"age_range")
    nm <- paste0(tablePrefix, "_settings")
    cdm <- omopgenerics::insertTable(cdm = cdm, name = nm, table = set)
    demographics <- demographics |>
      dplyr::left_join(cdm[[nm]], by = "cohort_definition_id")
  } else {
    demographics <- demographics |>
      dplyr::mutate("age_group" = "overall")
  }

  nm <- paste0(tablePrefix, "_demographics")
  demographics <- demographics |>
    dplyr::select(
      "observation_period_start_date" = "cohort_start_date",
      "observation_period_end_date" = "cohort_end_date",
      "person_id" = "subject_id", "age_group", "sex"
    ) |>
    dplyr::compute(name = nm, temporary = FALSE)

  return(demographics)
}

addSexOverall <- function(result, sex){
  if(sex){
    result <- result |> rbind(
      result |>
        dplyr::group_by(.data$age_group, .data$additional_level, .data$variable_name, .data$additional_name) |>
        dplyr::summarise(estimate_value = sum(.data$estimate_value, na.rm = TRUE), .groups = "drop") |>
        dplyr::mutate(sex = "overall")
    )
  }
  return(result)
}

createEmptyIntervalTable <- function(interval){
  if(interval == "overall"){
    tibble::tibble(
      "sex" = as.character(),
      "age_group" = as.character(),
      "estimate_value" = as.double()
    )

  }else{
    tibble::tibble(
      "time_interval" = as.character(),
      "sex" = as.character(),
      "age_group" = as.character(),
      "estimate_value" = as.double()
    )
  }

}

getOmopTableStartDate <- function(omopTable, date){
  omopTable |>
    dplyr::summarise("start_date" = min(.data[[date]], na.rm = TRUE)) |>
    dplyr::collect() |>
    dplyr::mutate("start_date" = as.Date(paste0(clock::get_year(.data$start_date),"-01-01"))) |>
    dplyr::pull("start_date")
}

getOmopTableEndDate   <- function(omopTable, date){
  omopTable |>
    dplyr::summarise("end_date" = max(.data[[date]], na.rm = TRUE)) |>
    dplyr::collect() |>
    dplyr::mutate("end_date" = as.Date(paste0(clock::get_year(.data$end_date),"-12-31"))) |>
    dplyr::pull("end_date")
}
