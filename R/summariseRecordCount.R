
#' Summarise record counts of an omop_table using a specific time interval. Only
#' records that fall within the observation period are considered.
#'
#' @param cdm A cdm_reference object.
#' @param omopTableName A character vector of omop tables from the cdm.
#' @param interval Time interval to stratify by. It can either be "years", "quarters", "months" or "overall".
#' @param ageGroup A list of age groups to stratify results by.
#' @param sex Whether to stratify by sex (TRUE) or not (FALSE).
#' @param dateRange A list containing the minimum and the maximum dates
#' defining the time range within which the analysis is performed.
#' @param sample An integer to sample the tables to only that number of records.
#' If NULL no sample is done.
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
#'   interval = "years",
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
                                 interval = "overall",
                                 ageGroup = NULL,
                                 sex = FALSE,
                                 sample = 1000000,
                                 dateRange = NULL) {
  # Initial checks ----
  omopgenerics::validateCdmArgument(cdm)
  omopgenerics::assertCharacter(omopTableName)
  omopgenerics::assertChoice(interval, c("overall", "years", "quarters", "months"), length = 1)
  ageGroup <- omopgenerics::validateAgeGroupArgument(ageGroup, ageGroupName = "age_group")
  omopgenerics::assertLogical(sex, length = 1)
  dateRange <- validateStudyPeriod(cdm, dateRange)

  # get strata
  strata <- c(
    list(character()),
    omopgenerics::combineStrata(c("sex"[sex], names(ageGroup), "interval"[interval != "overall"]))
  )

  # settings for the result object
  set <- createSettings(
    result_type = "summarise_record_count", study_period = dateRange
  ) |>
    dplyr::mutate(interval = .env$interval)

  purrr::map(omopTableName, \(table) {
    # get table
    omopTable <- dplyr::ungroup(cdm[[table]])

    # restrict study period
    omopTable <- restrictStudyPeriod(omopTable, dateRange)
    if (is.null(omopTable)) return(omopgenerics::emptySummarisedResult())

    # prefix for temp tables
    prefix <- omopgenerics::tmpPrefix()

    startDate <- omopgenerics::omopColumns(table = table, field = "start_date")

    # Incidence counts
    counts <- omopTable |>
      # get date of interest
      dplyr::select("index_date" = dplyr::all_of(startDate), "person_id") |>
      # restrct to counts in observation
      dplyr::inner_join(
        cdm[["observation_period"]] |>
          dplyr::select(
            "person_id",
            obs_start = "observation_period_start_date",
            obs_end = "observation_period_end_date"
          ),
        by = "person_id"
      ) |>
      dplyr::filter(
        .data$index_date >= .data$obs_start & .data$index_date <= .data$obs_end
      ) |>
      dplyr::select(!c("obs_start", "obs_end")) |>
      # add stratifications
      addStratifications(
        indexDate = "index_date",
        sex = sex,
        ageGroup = ageGroup,
        interval = interval,
        intervalName = "interval",
        name = omopgenerics::uniqueTableName(prefix = prefix)
      ) |>
      # summarise counts
      summariseCountsInternal(strata = strata, counts = "records")

    # format result
    strataCols <- unique(unlist(strata)) |>
      purrr::keep(\(x) x %in% c("sex", "age_group"))
    counts <- counts |>
      omopgenerics::uniteStrata(cols = strataCols) |>
      addAdditionalLevel() |>
      dplyr::mutate(
        omop_table = .env$table,
        estimate_name = "count",
        variable_name = "incident_counts",
        variable_level = getVariableLevel(.data$additional_level),
        result_id = 1L,
        cdm_name = omopgenerics::cdmName(cdm)
      ) |>
      omopgenerics::uniteGroup(cols = "omop_table")

    omopgenerics::dropTable(cdm = cdm, name = dplyr::starts_with(prefix))

    return(counts)
  }) |>
    dplyr::bind_rows() |>
    omopgenerics::newSummarisedResult(settings = set)
}

addAdditionalLevel <- function(x) {
  if (!"interval" %in% colnames(x)) return(omopgenerics::uniteAdditional(x))
  x |>
    dplyr::mutate(
      type = dplyr::case_when(
        nchar(.data$interval) == 4 ~ "years",
        substr(.data$interval, 6, 6) == "Q" ~ "quarters",
        substr(.data$interval, 5, 5) == "_" ~ "months",
        .default = "overall"
      ),
      start = dplyr::case_when(
        .data$type == "years" ~ paste0(.data$interval, "-01-01"),
        .data$type == "quarters" ~ paste0(substr(.data$interval, 1, 4), "-", sprintf("%02i", as.integer(as.numeric(substr(.data$interval, 7, 7)) * 3 - 2)), "-01"),
        .data$type == "months" ~ paste0(substr(.data$interval, 1, 4), "-", sprintf("%02i", as.integer(substr(.data$interval, 6, 7))), "-01"),
        .data$type == "overall" ~ NA_character_
      ) |>
        suppressWarnings(),
      end = dplyr::case_when(
        .data$type == "years" ~ clock::add_years(as.Date(.data$start), 1),
        .data$type == "quarters" ~ clock::add_months(as.Date(.data$start), 3),
        .data$type == "months" ~ clock::add_months(as.Date(.data$start), 1),
        .data$type == "overall" ~ as.Date(NA)
      ) |>
        clock::add_days(-1) |>
        format("%Y-%m-%d"),
      time_interval = dplyr::if_else(
        .data$type == "overall", NA_character_, paste(.data$start, "to", .data$end)
      )
    ) |>
    dplyr::select(!c("start", "end", "type", "interval")) |>
    omopgenerics::uniteAdditional(cols = "time_interval")
}
getVariableLevel <- function(x) {
  stringr::str_split(x, pattern = " to ") |>
    purrr::map(dplyr::first) |>
    purrr::flatten_chr()
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

addStrataToOmopTable <- function(omopTable, date, ageGroup, sex) {
  omopTable |>
    PatientProfiles::addDemographicsQuery(
      indexDate = date,
      age = FALSE,
      ageGroup = ageGroup,
      missingAgeGroupValue = "unknown",
      sex = sex,
      missingSexValue = "unknown",
      priorObservation = FALSE,
      futureObservation = FALSE,
      dateOfBirth = FALSE
    )
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
    endDate <- getOmopTableEndDate(omopTable, end_date_name)

  tibble::tibble(
    "group" = seq.Date(as.Date(startDate), as.Date(endDate), "month")
  ) |>
    dplyr::rowwise() |>
    dplyr::mutate("interval" = max(which(
      .data$group >= seq.Date(from = startDate, to = endDate, by = paste(.env$interval))
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
