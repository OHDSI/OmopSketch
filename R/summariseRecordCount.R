#' Create a summarise result object to summarise record counts of an omop_table using a specific time interval. Only records that fall within the observation period are counted.
#'
#' @param omopTable An omop table from a cdm object.
#' @param unit Whether to stratify by "year" or by "month".
#' @param unitInterval Number of years or months to include within the same interval.
#' @param ageGroup A list of age groups to stratify results by.
#' @param sex Boolean variable. Whether to stratify by sex (TRUE) or not (FALSE).
#'
#' @return A summarised_result object..
#'
#' @importFrom rlang :=
#' @export
#'
summariseRecordCount <- function(omopTable, unit = "year", unitInterval = 1, ageGroup = NULL, sex = FALSE) {

  # Initial checks ----
  checkOmopTable(omopTable)

  if(missing(unit)){unit <- "year"}
  if(missing(unitInterval)){unitInterval <- 1}
  if(missing(ageGroup) | is.null(ageGroup)){ageGroup <- NULL}

  checkUnit(unit)
  checkUnitInterval(unitInterval)
  checkAgeGroup(ageGroup)

  assertLogical(sex, length = 1)

  if(omopTable |> dplyr::tally() |> dplyr::pull("n") == 0){
    cli::cli_warn(paste0(omopgenerics::tableName(omopTable), " omop table is empty. Returning an empty summarised result."))

    return(omopgenerics::emptySummarisedResult())
  }

  # Create initial variables ----
  cdm <- omopgenerics::cdmReference(omopTable)
  omopTable <- omopTable |> dplyr::ungroup()

  name   <- omopgenerics::tableName(omopTable)
  result <- omopgenerics::emptySummarisedResult()
  date   <- startDate(name)

  # Create strata variable ----
  strata <- c("age_group","sex")

  # Incidence counts ----
  omopTable <- omopTable |>
    dplyr::select(dplyr::all_of(date), "person_id")

  # Use add demographic query -> when both are true (age = FALSE)
  omopTable <- addDemographicsToOmopTable(omopTable, date, ageGroup, sex)

  if(name != "observation_period") {
    omopTable <- omopTable |>
      filterInObservation(indexDate = date)
  }

  # interval sequence ----
  interval <- getIntervalTibble(omopTable = omopTable,
                                start_date_name = date,
                                end_date_name   = date,
                                unit = unit,
                                unitInterval = unitInterval)

  # Insert interval table to the cdm ----
  cdm <- cdm |>
    omopgenerics::insertTable(name = "interval", table = interval)

  # Obtain record counts for each interval ----
  result <- splitIncidenceBetweenIntervals(cdm, omopTable, date, strata)

  # Create overall group ----
  result <- createOverallGroup(result, ageGroup, sex, strata)

  # Create summarised result ----
  result <- createSummarisedResultRecordCount(result, omopTable, name, unit, unitInterval)
  omopgenerics::dropTable(cdm = cdm, name = "interval")

  return(result)
}

addDemographicsToOmopTable <- function(omopTable, date, ageGroup, sex){
  suppressWarnings(omopTable |>
                     dplyr::mutate(sex = "overall") |>
                     dplyr::mutate(age_group = "overall") |>
                     PatientProfiles::addDemographicsQuery(indexDate = date,
                                                           age = FALSE,
                                                           ageGroup = ageGroup,
                                                           missingAgeGroupValue = "unknown",
                                                           sex = sex,
                                                           missingSexValue = "unknown",
                                                           priorObservation = FALSE,
                                                           futureObservation = FALSE,
                                                           dateOfBirth = FALSE) |>
                     dplyr::mutate(age_group = dplyr::if_else(is.na(.data$age_group), "unknown", .data$age_group)) |> # To remove: https://github.com/darwin-eu-dev/PatientProfiles/issues/677
                     dplyr::mutate(sex = dplyr::if_else(is.na(.data$sex), "unknown", .data$sex))) # To remove: https://github.com/darwin-eu-dev/PatientProfiles/issues/677

}

filterInObservation <- function(x, indexDate){
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
    ) |>
    dplyr::select(-c("start","end"))
}

getOmopTableStartDate <- function(omopTable, date){
  omopTable |>
    dplyr::summarise("startDate" = min(.data[[date]], na.rm = TRUE)) |>
    dplyr::collect() |>
    dplyr::mutate("startDate" = as.Date(paste0(clock::get_year(startDate),"-01-01"))) |>
    dplyr::pull("startDate")
}

getOmopTableEndDate   <- function(omopTable, date){
  omopTable |>
    dplyr::summarise("endDate" = max(.data[[date]], na.rm = TRUE)) |>
    dplyr::collect() |>
    dplyr::mutate("endDate" = as.Date(paste0(clock::get_year(endDate),"-12-31"))) |>
    dplyr::pull("endDate")
}

getIntervalTibble <- function(omopTable, start_date_name, end_date_name, unit, unitInterval){
  startDate <- getOmopTableStartDate(omopTable, start_date_name)
  endDate   <- getOmopTableEndDate(omopTable, end_date_name)

  tibble::tibble(
    "group" = seq.Date(as.Date(startDate), as.Date(endDate), "month")
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
    dplyr::mutate("my" = paste0(clock::get_month(.data$group),"-",clock::get_year(.data$group))) |>
    dplyr::select("interval_group", "my", "interval_start_date","interval_end_date") |>
    dplyr::distinct()
}

splitIncidenceBetweenIntervals <- function(cdm, omopTable, date, strata){

  cdm$interval |>
    dplyr::inner_join(
      omopTable |>
        dplyr::rename("incidence_date" = dplyr::all_of(.env$date)) |>
        dplyr::mutate("my" = paste0(clock::get_month(.data$incidence_date),"-",clock::get_year(.data$incidence_date))) |>
        dplyr::group_by(.data$age_group,.data$sex,.data$my) |>
        dplyr::summarise(n = dplyr::n()) |>
        dplyr::ungroup(),
      by = "my"
    ) |>
    dplyr::select(-c("my")) |>
    dplyr::group_by(.data$interval_group, dplyr::across(dplyr::any_of(strata))) |>
    dplyr::summarise("estimate_value" = sum(.data$n, na.rm = TRUE), .groups = "drop") |>
    dplyr::collect() |>
    dplyr::arrange(.data$interval_group)
}

createOverallGroup <- function(result, ageGroup, sex, strata){
  ageStrata <- FALSE %in% c(names(ageGroup) == "overall")

  if(ageStrata & sex){ # If we stratified by age and sex
    # sex = overall, ageGroup = overall
    result <- result |>
      rbind(
        result |>
          dplyr::group_by(.data$interval_group) |>
          dplyr::summarise(estimate_value = sum(.data$estimate_value, na.rm = TRUE), .groups = "drop") |>
          dplyr::mutate(age_group = "overall", sex = "overall")
      ) |>
    # Create ageGroup = overall for each sex group
      rbind(
        result |>
          dplyr::group_by(.data$interval_group, .data$sex) |>
          dplyr::summarise(estimate_value = sum(.data$estimate_value, na.rm = TRUE), .groups = "drop") |>
          dplyr::mutate(age_group = "overall")
      ) |>
    # Create sex group = overall for each ageGroup
      rbind(
        result |>
          dplyr::group_by(.data$interval_group, .data$age_group) |>
          dplyr::summarise(estimate_value = sum(.data$estimate_value, na.rm = TRUE), .groups = "drop") |>
          dplyr::mutate(sex = "overall")
      )
  }else if(!sex & !ageStrata){ # If no stratification
    result <- result |> dplyr::mutate(age_group = "overall", sex = "overall")
  }else if(!sex & ageStrata){ # If only age stratification
    result <- result |>
      rbind(
        result |>
          dplyr::group_by(.data$interval_group, .data$sex) |>
          dplyr::summarise(estimate_value = sum(.data$estimate_value, na.rm = TRUE), .groups = "drop") |>
          dplyr::mutate(age_group = "overall")
      )
  }else if(sex & !ageStrata){ # If only sex stratification
    result <- result |>
      rbind(
        result |>
          dplyr::group_by(.data$interval_group, .data$age_group) |>
          dplyr::summarise(estimate_value = sum(.data$estimate_value, na.rm = TRUE), .groups = "drop") |>
          dplyr::mutate(sex = "overall")
      )
  }

  return(result)
}

createSummarisedResultRecordCount <- function(result, omopTable, name, unit, unitInterval){
  result <- result |>
    dplyr::mutate(
      "estimate_value" = as.character(.data$estimate_value),
      "variable_name" = "incidence_records",
    ) |>
    dplyr::rename("variable_level" = "interval_group") |>
    visOmopResults::uniteStrata(cols = c("age_group","sex")) |>
    dplyr::mutate(
      "result_id" = as.integer(1),
      "cdm_name" = omopgenerics::cdmName(omopgenerics::cdmReference(omopTable)),
      "group_name"  = "omop_table",
      "group_level" = name,
      "estimate_name" = "count",
      "estimate_type" = "integer",
      "additional_name" = "time_interval",
      "additional_level" = gsub(" to.*","",.data$variable_level)
    ) |>
    omopgenerics::newSummarisedResult(settings = dplyr::tibble(
      "result_id" = 1L,
      "result_type" = "summarised_table_counts",
      "package_name" = "OmopSketch",
      "package_version" = as.character(utils::packageVersion("OmopSketch")),
      "unit" = .env$unit,
      "unitInterval" = .env$unitInterval
    ))
}
