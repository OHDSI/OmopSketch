#' Summarise the number of people in observation during a specific interval of
#' time.
#'
#' @param observationPeriod An observation_period omop table. It must be part of
#' a cdm_reference object.
#' @inheritParams interval
#' @param output Output format. It can be either the number of records
#' ("record") that are in observation in the specific interval of time, the
#' number of person-days ("person-days"), the number of subjects ("person"),
#' the number of females ("sex") or the median age of population in observation ("age").
#' @param ageGroup A list of age groups to stratify results by.
#' @param sex Boolean variable. Whether to stratify by sex (TRUE) or not
#' (FALSE). For output = "sex" this stratification is not applied.
#' @inheritParams dateRange-startDate
#' @return A summarised_result object.
#' @export
#' @examples
#' \donttest{
#' library(dplyr, warn.conflicts = FALSE)
#'
#' cdm <- mockOmopSketch()
#'
#' result <- summariseInObservation(
#'   observationPeriod = cdm$observation_period,
#'   interval = "months",
#'   output = c("person-days", "record"),
#'   ageGroup = list("<=60" = c(0, 60), ">60" = c(61, Inf)),
#'   sex = TRUE
#' )
#'
#' result |>
#'   glimpse()
#'
#' PatientProfiles::mockDisconnect(cdm)
#' }
summariseInObservation <- function(observationPeriod,
                                   interval = "overall",
                                   output = "record",
                                   ageGroup = NULL,
                                   sex = FALSE, dateRange = NULL) {

  omopgenerics::validateCdmTable(observationPeriod)
  cdm <- omopgenerics::cdmReference(observationPeriod)
  omopgenerics::assertTable(observationPeriod, class = "cdm_table",
                            columns = omopgenerics::omopColumns(table = "observation_period", version = omopgenerics::cdmVersion(cdm)))
  omopgenerics::assertChoice(interval, c("overall", "years", "quarters", "months"), length = 1)
  dateRange <- validateStudyPeriod(cdm, dateRange)
  omopgenerics::assertChoice(output, choices = c("person-days", "record", "person", "age", "sex"), call = parent.frame())
  ageGroup <- omopgenerics::validateAgeGroupArgument(ageGroup, multipleAgeGroup = FALSE)
  omopgenerics::assertLogical(sex, length = 1)

  set <- createSettings(result_type = "summarise_in_observation", study_period = dateRange) |>
    dplyr::mutate("interval" = .env$interval)

  if (omopgenerics::isTableEmpty(observationPeriod)) {
    cli::cli_warn("observation_period table is empty. Returning an empty summarised result.")
    return(omopgenerics::emptySummarisedResult(settings = set))
  }

  cdm <- omopgenerics::cdmReference(observationPeriod)

  start_date_name <- omopgenerics::omopColumns(table = "observation_period", field = "start_date")

  end_date_name <- omopgenerics::omopColumns(table = "observation_period", field = "end_date")

  tablePrefix <- omopgenerics::tmpPrefix()

   observationPeriod <- observationPeriod |>
     trimStudyPeriod(dateRange = dateRange)

  if (is.null(observationPeriod)) {
    return(omopgenerics::emptySummarisedResult(settings = set))
  }
  denominator <- cdm |> getDenominator(output)

  observationPeriodOverall <- observationPeriod |>
    addSexAgeGroup(sex = sex, ageGroup = ageGroup, indexDate = start_date_name) |>
    dplyr::compute(name = omopgenerics::uniqueTableName(prefix = tablePrefix), temporary = FALSE)

  strata <- c(list(character()), omopgenerics::combineStrata(c("sex"[sex], "age_group"[!is.null(ageGroup)])))

  result <- list()

  result$overall <- summariseInObservationInternal(observationPeriodOverall,
    start_date_name = start_date_name,
    end_date_name = end_date_name,
    index_date = start_date_name,
    tablePrefix = tablePrefix,
    strata = strata,
    denominator = denominator,
    output = output
  )
  if (interval != "overall") {
    timeInterval <- getIntervalTibbleForObservation(observationPeriod, start_date_name, end_date_name, interval)

    # Insert interval table to the cdm ----
    cdm <- cdm |>
      omopgenerics::insertTable(name = paste0(tablePrefix, "interval"), table = timeInterval)


    observationPeriodInterval <- cdm[[paste0(tablePrefix, "interval")]] |>
      dplyr::cross_join(observationPeriod |>
        dplyr::mutate("start_date" = as.Date(paste0(as.character(as.integer(clock::get_year(.data[[start_date_name]]))), "-", as.character(as.integer(clock::get_month(.data[[start_date_name]]))), "-01"))) |>
        dplyr::mutate("end_date" = as.Date(paste0(as.character(as.integer(clock::get_year(.data[[end_date_name]]))), "-", as.character(as.integer(clock::get_month(.data[[end_date_name]]))), "-01")))) |>
      dplyr::filter((.data$start_date < .data$interval_start_date & .data$end_date >= .data$interval_start_date) |
        (.data$start_date >= .data$interval_start_date & .data$start_date <= .data$interval_end_date)) |>
      dplyr::mutate(
        start_date = dplyr::if_else(
          .data[[start_date_name]] > .data$interval_start_date,
          .data[[start_date_name]],
          .data$interval_start_date
        ),
        end_date = dplyr::if_else(
          .data[[end_date_name]] < .data$interval_end_date,
          .data[[end_date_name]],
          .data$interval_end_date
        )
      ) |>
      dplyr::compute(name = omopgenerics::uniqueTableName(prefix = tablePrefix))

    observationPeriodInterval <- observationPeriodInterval |>
      addSexAgeGroup(sex = sex, ageGroup = ageGroup, indexDate = "start_date") |>
      dplyr::compute(name = omopgenerics::uniqueTableName(prefix = tablePrefix), temporary = FALSE)

    strata <- purrr::map(strata, \(x) c("time_interval", x))

    result$interval <- summariseInObservationInternal(observationPeriodInterval,
      start_date_name = "start_date",
      end_date_name = "end_date",
      index_date = "start_date",
      tablePrefix = tablePrefix,
      strata = strata,
      denominator = denominator,
      output = output
    )
  }

  result <- result |>
    dplyr::bind_rows() |>
    dplyr::mutate(
      "result_id" = as.integer(1),
      "cdm_name" = omopgenerics::cdmName(omopgenerics::cdmReference(observationPeriod))
    ) |>
    omopgenerics::newSummarisedResult(set = createSettings(result_type = "summarise_in_observation", study_period = dateRange) |>
      dplyr::mutate("interval" = .env$interval))

  omopgenerics::dropSourceTable(cdm = cdm, name = dplyr::starts_with(tablePrefix))

  return(result)
}


summariseInObservationInternal <- function(x,
                                           start_date_name,
                                           end_date_name,
                                           index_date,
                                           tablePrefix,
                                           strata,
                                           denominator,
                                           output) {
  result <- list()
  if (any(output %in% c("person-days", "sex", "record", "person"))) {
    result$count <- x |>
      countRecords(start_date_name = start_date_name, end_date_name = end_date_name, output = output, tablePrefix = tablePrefix, strata = strata) |>
      createSummarisedResultObservationPeriod(denominator = denominator)
  }

  if ("age" %in% output) {
    result$age <- createSummarisedResultAge(x, index_date = index_date, tablePrefix = tablePrefix)
  }

  result <- result |> dplyr::bind_rows()
  return(result)
}
countRecords <- function(x, start_date_name, end_date_name, output, tablePrefix, strata) {
  if (length(strata) == 0) {
    return(tibble::tibble())
  }
  result <- list()
  if ("person-days" %in% output) {
    result$personDays <- x %>%
      dplyr::mutate(person_days = as.integer(!!CDMConnector::datediff(start_date_name, end_date_name, interval = "day") + 1)) |>
      summariseSumInternal(strata = strata, variable = "person_days") |>
      dplyr::mutate("variable_name" = "Number person-days")
  }
  if ("record" %in% output) {
    result$records <- x |>
      summariseCountsInternal(strata = strata, counts = "records") |>
      dplyr::mutate(
        "variable_name" = "Number records in observation",
        "estimate_name" = "count"
      )
  }
  if ("person" %in% output) {
    result$subjects <- x |>
      summariseCountsInternal(strata = strata, counts = "person_id") |>
      dplyr::mutate(
        "variable_name" = "Number subjects in observation",
        "estimate_name" = "count"
      )
  }

  if ("sex" %in% output) {
    strata_sex <- strata[!vapply(strata, function(x) "sex" %in% x, logical(1))]

    x <- x |>
      PatientProfiles::addSexQuery() |>
      suppressWarnings() |>
      dplyr::compute(temporary = FALSE, name = tablePrefix)

    result$sex <- x |>
      dplyr::filter(.data$sex == "Female") |>
      summariseCountsInternal(strata = strata_sex, counts = "person_id") |>
      dplyr::mutate(
        "variable_name" = "Number females in observation",
        "estimate_name" = "count"
      )
  }

  result <- result |>
    dplyr::bind_rows() |>
    dplyr::mutate(estimate_value = as.numeric(.data$estimate_value))
  return(result)
}

createSummarisedResultObservationPeriod <- function(result, denominator) {
  if (dim(result)[1] == 0) {
    result <- omopgenerics::emptySummarisedResult()
  } else {
    result <- result |>
      dplyr::mutate("estimate_value" = sprintf("%.0f", .data$estimate_value)) |>
      omopgenerics::uniteStrata(cols = intersect(c("sex", "age_group"), colnames(result))) |>
      omopgenerics::uniteAdditional(cols = intersect("time_interval", colnames(result))) |>
      dplyr::mutate(
        "group_name" = "omop_table",
        "group_level" = "observation_period",
        "variable_level" = as.character(NA)
      )

    result <- result |>
      dplyr::bind_rows(result |>
        dplyr::group_by(.data$additional_level, .data$strata_level, .data$variable_name) |>
        dplyr::inner_join(denominator, by = "variable_name") |>
        dplyr::mutate(
          estimate_value = sprintf("%.2f", as.numeric(.data$estimate_value) / denominator * 100),
          estimate_name = "percentage",
          estimate_type = "percentage"
        ) |>
        dplyr::select(-c("denominator")) |>
        dplyr::ungroup()) |>
      dplyr::arrange(dplyr::across(dplyr::any_of("additional_level")))
  }
  return(result)
}
createSummarisedResultAge <- function(x, index_date, tablePrefix) {
  strata <- omopgenerics::combineStrata(intersect(c("sex", "age_group"), colnames(x)))
  additional_col <- "time_interval"["time_interval" %in% colnames(x)]
  x <- x |>
    PatientProfiles::addAgeQuery(indexDate = index_date) |>
    dplyr::compute(temporary = FALSE, name = omopgenerics::uniqueTableName(prefix = tablePrefix))

  res <- x |>
    dplyr::collect() |> # to remove after computation of median in sql servers is solved in PatientProfiles
    PatientProfiles::summariseResult(group = additional_col, includeOverallGroup = FALSE, strata = strata, includeOverallStrata = TRUE, variables = "age", estimates = "median", counts = FALSE) |>
    # dplyr::collect() |>
    dplyr::mutate(
      "variable_name" = "Median age in observation",
      "additional_name" = .data$group_name,
      "additional_level" = .data$group_level,
      "group_name" = "omop_table",
      "group_level" = "observation_period"
    ) |>
    dplyr::arrange(dplyr::across(dplyr::any_of("additional_level")))
  return(res)
}

getDenominator <- function(cdm, output) {
  denominator <- list()
  if ("record" %in% output) {
    denominator$record <- tibble::tibble(
      "denominator" = c(cdm[["person"]] |>
        dplyr::ungroup() |>
        dplyr::select("person_id") |>
        dplyr::summarise("n" = dplyr::n()) |>
        dplyr::pull("n")),
      "variable_name" = "Number records in observation"
    )
  }
  if ("person" %in% output) {
    denominator$person <- tibble::tibble(
      "denominator" = c(cdm[["person"]] |>
        dplyr::ungroup() |>
        dplyr::select("person_id") |>
        dplyr::summarise("n" = dplyr::n()) |>
        dplyr::pull("n")),
      "variable_name" = "Number subjects in observation"
    )
  }
  if ("person-days" %in% output) {
    y <- cdm[["observation_period"]] |>
      dplyr::ungroup() |>
      dplyr::inner_join(cdm[["person"]] |> dplyr::select("person_id"), by = "person_id") %>%
      dplyr::mutate(n = !!CDMConnector::datediff("observation_period_start_date", "observation_period_end_date", interval = "day") + 1) |>
      dplyr::summarise("n" = sum(.data$n, na.rm = TRUE)) |>
      dplyr::pull("n")

    denominator$person_days <- tibble::tibble(
      "denominator" = y,
      "variable_name" = "Number person-days"
    )
  }

  if ("sex" %in% output) {
    denominator$sex <- tibble::tibble(
      "denominator" = c(cdm[["person"]] |>
        dplyr::ungroup() |>
        dplyr::filter(.data$gender_concept_id %in% c(8507, 8532)) |>
        dplyr::select("person_id") |>
        dplyr::summarise("n" = dplyr::n()) |>
        dplyr::pull("n")),
      "variable_name" = "Number females in observation"
    )
  }

  denominator <- dplyr::bind_rows(denominator)
  return(denominator)
}

getIntervalTibbleForObservation <- function(omopTable, start_date_name, end_date_name, interval) {
  x <- validateIntervals(interval)
  interval <- x$interval
  unitInterval <- x$unitInterval

  startDate <- getOmopTableStartDate(omopTable, start_date_name)
  endDate <- getOmopTableEndDate(omopTable, end_date_name)

  tibble::tibble(
    "group" = seq.Date(startDate, endDate, .env$interval)
  ) |>
    dplyr::rowwise() |>
    dplyr::mutate("interval" = max(
      which(
        .data$group >= seq.Date(from = startDate, to = endDate, by = paste(.env$unitInterval, .env$interval))
      ),
      na.rm = TRUE
    )) |>
    dplyr::ungroup() |>
    dplyr::group_by(.data$interval) |>
    dplyr::mutate(
      "interval_start_date" = min(.data$group),
      "interval_end_date" = dplyr::if_else(
        .env$interval == "year",
        clock::add_years(min(.data$group), .env$unitInterval, invalid = "previous") - 1,
        clock::add_months(min(.data$group), .env$unitInterval, invalid = "previous") - 1
      )
    ) |>
    dplyr::mutate(
      "interval_start_date" = as.Date(.data$interval_start_date),
      "interval_end_date" = as.Date(.data$interval_end_date)
    ) |>
    dplyr::mutate(
      "time_interval" = paste(.data$interval_start_date, "to", .data$interval_end_date)
    ) |>
    dplyr::ungroup() |>
    dplyr::select("interval_start_date", "interval_end_date", "time_interval") |>
    dplyr::distinct()
}

getOmopTableStartDate <- function(omopTable, date) {
  omopTable |>
    dplyr::summarise("start_date" = min(.data[[date]], na.rm = TRUE)) |>
    dplyr::collect() |>
    dplyr::mutate("start_date" = as.Date(paste0(as.character(as.integer(clock::get_year(.data$start_date))), "-01-01"))) |>
    dplyr::pull("start_date")
}

getOmopTableEndDate <- function(omopTable, date) {
  omopTable |>
    dplyr::summarise("end_date" = max(.data[[date]], na.rm = TRUE)) |>
    dplyr::collect() |>
    dplyr::mutate("end_date" = as.Date(paste0(as.character(as.integer(clock::get_year(.data$end_date))), "-12-31"))) |>
    dplyr::pull("end_date")
}
