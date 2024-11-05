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
                                   sex = FALSE){

  tablePrefix <-  omopgenerics::tmpPrefix()

  # Initial checks ----
  omopgenerics::assertClass(observationPeriod, "omop_table")
  omopgenerics::assertTrue(omopgenerics::tableName(observationPeriod) == "observation_period")

  if(omopgenerics::isTableEmpty(observationPeriod)){
    cli::cli_warn("observation_period table is empty. Returning an empty summarised result.")
    return(omopgenerics::emptySummarisedResult())
  }

  checkOutput(output)
  ageGroup <- omopgenerics::validateAgeGroupArgument(ageGroup, ageGroupName = "")[[1]]
  omopgenerics::assertLogical(sex, length = 1)
  x <- validateIntervals(interval)
  interval <- x$interval
  unitInterval <- x$unitInterval

  if(length(output) > 1){output <- "all"}
  if(missing(ageGroup) | is.null(ageGroup)){ageGroup <- list("overall" = c(0,Inf))}else{ageGroup <- append(ageGroup, list("overall" = c(0, Inf)))}

  # Create initial variables ----
  cdm <- omopgenerics::cdmReference(observationPeriod)
  observationPeriod <- addStrataToPeopleInObservation(cdm, ageGroup, sex, tablePrefix)
  strata <- getStrataList(sex, ageGroup)

  # Calculate denominator ----
  denominator <- cdm |> getDenominator(output)

  name <- "observation_period"
  start_date_name <- startDate(name)
  end_date_name   <- endDate(name)

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
  result <- createSummarisedResultObservationPeriod(result, observationPeriod, name, denominator, interval, unitInterval)

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
      "interval_group" = paste(.data$interval_start_date,"to",.data$interval_end_date)
    ) |>
    dplyr::ungroup() |>
    dplyr::select("interval_start_date", "interval_end_date", "interval_group") |>
    dplyr::distinct()
}

countRecords <- function(observationPeriod, cdm, start_date_name, end_date_name, interval, output, tablePrefix){

  if(output == "person-days" | output == "all"){
    if(interval != "overall"){
      x <- cdm[[paste0(tablePrefix, "interval")]] |>
        dplyr::rename("variable_level" = "interval_group") |>
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
    }else{
      x <- observationPeriod |>
        dplyr::rename("start_date" = "observation_period_start_date",
                      "end_date"   = "observation_period_end_date") |>
        dplyr::mutate("variable_level" = NA)
    }

    personDays <- x %>%
      dplyr::mutate(estimate_value = !!CDMConnector::datediff("start_date","end_date", interval = "day")+1) |>
      dplyr::group_by(dplyr::across(dplyr::any_of(c("variable_level", "sex", "age_group")))) |>
      dplyr::summarise(estimate_value = sum(.data$estimate_value, na.rm = TRUE), .groups = "drop") |>
      dplyr::mutate(variable_name = "Number person-days") |>
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
        dplyr::rename("variable_level" = "interval_group") |>
        dplyr::cross_join(x) |>
        dplyr::filter((.data$start_date < .data$interval_start_date & .data$end_date >= .data$interval_start_date) |
                        (.data$start_date >= .data$interval_start_date & .data$start_date <= .data$interval_end_date)) |>
        dplyr::group_by(.data$variable_level, .data$age_group, .data$sex) |>
        dplyr::summarise(estimate_value = sum(.data$estimate_value, na.rm = TRUE), .groups = "drop") |>
        dplyr::mutate(variable_name = "Number records in observation") |>
        dplyr::collect()
    }else{
      records <- observationPeriod |>
        dplyr::group_by(.data$age_group, .data$sex) |>
        dplyr::summarise(estimate_value = dplyr::n(), .groups = "drop") |>
        dplyr::mutate("variable_name" = "Number records in observation",
                      "variable_level" = NA) |>
        dplyr::collect()
    }
  }else{
    records <- createEmptyIntervalTable(interval)
  }

  x <- personDays |>
    rbind(records) |>
    dplyr::arrange(dplyr::across(dplyr::any_of("variable_level")))

  return(x)
}

createSummarisedResultObservationPeriod <- function(result, observationPeriod, name, denominator, interval, unitInterval){
  result <- result |>
    dplyr::mutate("estimate_value" = as.character(.data$estimate_value)) |>
    visOmopResults::uniteStrata(cols = c("sex", "age_group")) |>
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
    dplyr::group_by(.data$variable_level, .data$strata_level, .data$variable_name) |>
    dplyr::mutate(estimate_type = dplyr::if_else(dplyr::row_number() == 2, "percentage", .data$estimate_type)) |>
    dplyr::inner_join(denominator, by = "variable_name") |>
    dplyr::mutate(estimate_value = dplyr::if_else(.data$estimate_type == "percentage", as.character(as.numeric(.data$estimate_value)/denominator*100), .data$estimate_value)) |>
    dplyr::select(-c("denominator")) |>
    dplyr::mutate(estimate_name = dplyr::if_else(.data$estimate_type == "percentage", "percentage", .data$estimate_name)) |>
    omopgenerics::newSummarisedResult(settings = dplyr::tibble(
      "result_id" = 1L,
      "result_type" = "summarise_in_observation",
      "package_name" = "OmopSketch",
      "package_version" = as.character(utils::packageVersion("OmopSketch")),
      "interval" = .env$interval,
      "unitInterval" = .env$unitInterval
    ))

  return(result)
}

addStrataToPeopleInObservation <- function(cdm, ageGroup, sex, tablePrefix) {
  demographics <- cdm |>
    CohortConstructor::demographicsCohort(
      name = paste0(tablePrefix, "demographics_table"),
      sex = NULL,
      ageRange = ageGroup,
      minPriorObservation = NULL
    ) |>
    suppressMessages()

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
        dplyr::group_by(.data$age_group, .data$variable_level, .data$variable_name) |>
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
      "interval_group" = as.character(),
      "sex" = as.character(),
      "age_group" = as.character(),
      "estimate_value" = as.double()
    )
  }

}
