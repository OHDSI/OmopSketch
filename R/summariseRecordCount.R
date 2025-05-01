#' Summarise record counts of an omop_table using a specific time interval. Only
#' records that fall within the observation period are considered.
#'
#' @param cdm A cdm_reference object.
#' @param omopTableName A character vector of omop tables from the cdm.
#' @inheritParams interval
#' @param ageGroup A list of age groups to stratify results by.
#' @param sex Whether to stratify by sex (TRUE) or not (FALSE).
#' @inheritParams dateRange-startDate
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
#'   ageGroup = list("<=20" = c(0, 20), ">20" = c(21, Inf)),
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
                                 sample = NULL,
                                 dateRange = NULL) {
  # Initial checks
  cdm <- omopgenerics::validateCdmArgument(cdm)
  omopgenerics::assertCharacter(omopTableName)
  omopgenerics::assertChoice(interval, c("overall", "years", "quarters", "months"), length = 1)
  ageGroup <- omopgenerics::validateAgeGroupArgument(ageGroup, ageGroupName = "age_group")
  omopgenerics::assertLogical(sex, length = 1)
  dateRange <- validateStudyPeriod(cdm, dateRange)

  # get strata
  strata <- c(
    list(character()),
    omopgenerics::combineStrata(strataCols(sex = sex, ageGroup = ageGroup, interval = interval))
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
    if (is.null(omopTable)) {
      return(omopgenerics::emptySummarisedResult())
    }

    # prefix for temp tables
    prefix <- omopgenerics::tmpPrefix()

    # sample table
    omopTable <- omopTable |>
      sampleOmopTable(sample = sample, name = omopgenerics::uniqueTableName(prefix))

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
      addTimeInterval() |>
      omopgenerics::uniteAdditional(cols = "time_interval") |>
      dplyr::mutate(
        omop_table = .env$table,
        estimate_name = "count",
        variable_name = "Number records",
        variable_level = getVariableLevel(.data$additional_level),
        result_id = 1L,
        cdm_name = omopgenerics::cdmName(cdm)
      ) |>
      omopgenerics::uniteGroup(cols = "omop_table")

    omopgenerics::dropSourceTable(cdm = cdm, name = dplyr::starts_with(prefix))

    return(counts)
  }) |>
    dplyr::bind_rows() |>
    omopgenerics::newSummarisedResult(settings = set)
}

addTimeInterval <- function(x) {
  if (!"interval" %in% colnames(x)) {
    return(dplyr::mutate(x, time_interval = NA_character_))
  }
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
    dplyr::select(!c("start", "end", "type", "interval"))
}
getVariableLevel <- function(x) {
  stringr::str_split(x, pattern = " to ") |>
    purrr::map(dplyr::first) |>
    purrr::flatten_chr()
}
