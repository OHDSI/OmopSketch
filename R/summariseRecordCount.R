
#' Summarise record counts of an omop_table using a specific time interval. Only
#' records that fall within the observation period are considered.
#'
#' @param cdm A cdm_reference object.
#' @param omopTableName A character vector of omop tables from the cdm.
#' @param interval Time interval to stratify by. It can either be "year" or "month".
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
#'   interval = "year",
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
                                 interval = "year",
                                 unitInterval = 1,
                                 ageGroup = NULL,
                                 sex = FALSE) {

  # Initial checks ----
  omopgenerics::validateCdmArgument(cdm)
  omopgenerics::assertCharacter(omopTableName)
  checkInterval(interval)
  omopgenerics::assertNumeric(unitInterval, length = 1, min = 1)

  ageGroup <- omopgenerics::validateAgeGroupArgument(ageGroup, ageGroupName = "")[[1]]
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
                                                      interval = interval,
                                                      unitInterval = unitInterval,
                                                      ageGroup = ageGroup,
                                                      sex = sex)
                       }
  ) |>
    dplyr::bind_rows()

  return(result)
}

#' @noRd
summariseRecordCountInternal <- function(omopTableName, cdm, interval, unitInterval,
                                         ageGroup, sex) {

  prefix <- omopgenerics::tmpPrefix()
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
  timeInterval <- getIntervalTibble(omopTable = omopTable,
                                start_date_name = date,
                                end_date_name   = date,
                                interval = interval,
                                unitInterval = unitInterval)

  # Insert interval table to the cdm ----
  cdm <- cdm |> omopgenerics::insertTable(name = paste0(prefix, "interval"), table = timeInterval)

  # Obtain record counts for each interval ----
  result <- splitIncidenceBetweenIntervals(cdm, omopTable, date, prefix)

  # Create summarised result ----
  result <- createSummarisedResultRecordCount(result, sex, ageGroup, omopTable, omopTableName, interval, unitInterval)
  omopgenerics::dropTable(cdm = cdm, name = dplyr::starts_with(prefix))

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

getIntervalTibble <- function(omopTable, start_date_name, end_date_name, interval, unitInterval){
  startDate <- getOmopTableStartDate(omopTable, start_date_name)
  endDate   <- getOmopTableEndDate(omopTable, end_date_name)

  tibble::tibble(
    "group" = seq.Date(as.Date(startDate), as.Date(endDate), "month")
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
    dplyr::mutate("my" = paste0(clock::get_month(.data$group),"-",clock::get_year(.data$group))) |>
    dplyr::select("interval_group", "my", "interval_start_date","interval_end_date") |>
    dplyr::distinct()
}

splitIncidenceBetweenIntervals <- function(cdm, omopTable, date, prefix){
  cdm[[paste0(prefix, "interval")]] |>
    dplyr::inner_join(
      omopTable |>
        dplyr::rename("incidence_date" = dplyr::all_of(.env$date)) |>
        dplyr::mutate("my" = paste0(clock::get_month(.data$incidence_date),"-",clock::get_year(.data$incidence_date))),
      by = "my"
    ) |>
    dplyr::select(-c("my")) |>
    dplyr::relocate("person_id") |>
    dplyr::select(-c("interval_start_date", "interval_end_date", "incidence_date"))
}

createSummarisedResultRecordCount <- function(result, sex, ageGroup, omopTable, omopTableName, interval, unitInterval){

  result |>
    dplyr::select(-"person_id") |>
    dplyr::collect() |> # https://github.com/darwin-eu-dev/PatientProfiles/issues/706
    PatientProfiles::summariseResult(
      strata = getStrataList(sex, ageGroup),
      includeOverallStrata = TRUE,
      estimates = "count",
      counts = FALSE
    ) |>
    dplyr::filter(!.data$variable_name %in% c("sex", "age_group")) |>
    dplyr::mutate("variable_name" = "incidence_records") |>
    dplyr::mutate(
      "result_id" = as.integer(1),
      "cdm_name" = omopgenerics::cdmName(omopgenerics::cdmReference(omopTable)),
      "group_name"  = "omop_table",
      "group_level" = omopTableName,
      "additional_name" = "overall",
      "additional_level" = "overall"
    ) |>
    omopgenerics::newSummarisedResult(
      settings = dplyr::tibble(
        "result_id" = 1L,
        "result_type" = "summarise_record_count",
        "package_name" = "OmopSketch",
        "package_version" = as.character(utils::packageVersion("OmopSketch")),
        "interval" = .env$interval,
        "unitInterval" = .env$unitInterval
      )
    )
}
