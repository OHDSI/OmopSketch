
#' Summarise record counts of an omop_table using a specific time interval. Only
#' records that fall within the observation period are considered.
#'
#' @param cdm A cdm_reference object.
#' @param omopTableName A character vector of omop tables from the cdm.
#' @param unit Time unit it can either be "year" or "month".
#' @param unitInterval Number of years or months to include within the same
#' interval.
#' @param ageGroup A list of age groups to stratify results by.
#' @param sex Whether to stratify by sex (TRUE) or not (FALSE).
#' @return A summarised_result object.
#' @export
#' @examples
#' \donttest{
#' library(dplyr, warn.conflicts = FALSE)
#'
#' cdm <- mockOmopSketch()
#'
#' summarisedResult <- summariseRecordCount(
#'   cdm = cdm,
#'   omopTableName = c("condition_occurrence", "drug_exposure"),
#'   unit = "year",
#'   unitInterval = 10,
#'   ageGroup = list("<=20" = c(0,20), ">20" = c(21, Inf)),
#'   sex = TRUE
#' )
#'
#' summarisedResult |>
#'   glimpse()
#'
#' PatientProfiles::mockDisconnect(cdm = cdm)
#' }
summariseRecordCount <- function(cdm,
                                 omopTableName,
                                 unit = "year",
                                 unitInterval = 1,
                                 ageGroup = NULL,
                                 sex = FALSE) {

  # Initial checks ----
  omopgenerics::validateCdmArgument(cdm)
  omopgenerics::assertCharacter(omopTableName)
  checkUnit(unit)
  omopgenerics::assertNumeric(unitInterval, length = 1, min = 1)
  omopgenerics::validateAgeGroupArgument(ageGroup)
  omopgenerics::assertLogical(sex, length = 1)

  result <- purrr::map(omopTableName,
                       function(x) {
                         omopgenerics::assertClass(cdm[[x]], "omop_table", call = parent.frame())
                         if(omopgenerics::isTableEmpty(cdm[[x]])) {
                           cli::cli_warn(paste0(x, " omop table is empty. Returning an empty summarised omop table."))
                           return(omopgenerics::emptySummarisedResult())
                         }
                         summariseRecordCountInternal(x,
                                                      cdm = cdm,
                                                      unit = unit,
                                                      unitInterval = unitInterval,
                                                      ageGroup = ageGroup,
                                                      sex = sex)
                       }
  ) |>
    dplyr::bind_rows()

  return(result)
}

#' @noRd
summariseRecordCountInternal <- function(omopTableName, cdm, unit, unitInterval,
                                         ageGroup, sex) {

  omopTable <- cdm[[omopTableName]] |> dplyr::ungroup()

  # Create initial variables ----
  omopTable <- filterPersonId(omopTable)

  result <- omopgenerics::emptySummarisedResult()
  date   <- startDate(omopTableName)

  # Create strata variable ----
  strata <- c("age_group","sex")

  # Incidence counts ----
  omopTable <- omopTable |>
    dplyr::select(dplyr::all_of(date), "person_id")

  omopTable <- addStrataToOmopTable(omopTable, date, ageGroup, sex)

  if(omopTableName != "observation_period") {
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
  result <- createSummarisedResultRecordCount(result, omopTable, omopTableName, unit, unitInterval)
  omopgenerics::dropTable(cdm = cdm, name = "interval")

  return(result)
}

filterPersonId <- function(omopTable){

  cdm <- omopgenerics::cdmReference(omopTable)
  omopTableName <- omopgenerics::tableName(omopTable)
  id <- omopgenerics::getPersonIdentifier(omopTable)

  if((omopTable |> dplyr::select("person_id") |> dplyr::anti_join(cdm[["person"]], by = "person_id") |> utils::head(1) |> dplyr::tally() |> dplyr::pull("n")) != 0){
    cli::cli_warn("There are person_id in the {omopTableName} that are not found in the person table. These person_id are removed from the analysis.")

    omopTable <- omopTable |>
      dplyr::inner_join(
        cdm[["person"]] |>
          dplyr::select(!!id := "person_id"),
        by = "person_id")
  }

  return(omopTable)
}

addStrataToOmopTable <- function(omopTable, date, ageGroup, sex){
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
                                                           dateOfBirth = FALSE))

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
      "result_type" = "summarise_record_count",
      "package_name" = "OmopSketch",
      "package_version" = as.character(utils::packageVersion("OmopSketch")),
      "unit" = .env$unit,
      "unitInterval" = .env$unitInterval
    ))
}
