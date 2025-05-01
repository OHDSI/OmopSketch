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
#'   cdm$observation_period,
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
  tablePrefix <- omopgenerics::tmpPrefix()

  # Initial checks ----
  omopgenerics::assertClass(observationPeriod, "omop_table")
  omopgenerics::assertTrue(omopgenerics::tableName(observationPeriod) == "observation_period")
  dateRange <- validateStudyPeriod(omopgenerics::cdmReference(observationPeriod), dateRange)

  if (omopgenerics::isTableEmpty(observationPeriod)) {
    cli::cli_warn("observation_period table is empty. Returning an empty summarised result.")
    return(omopgenerics::emptySummarisedResult(settings = createSettings(result_type = "summarise_in_observation")))
  }

  omopgenerics::assertChoice(output, choices = c("person-days", "record", "person", "age", "sex"), call = parent.frame())
  ageGroup <- omopgenerics::validateAgeGroupArgument(ageGroup, ageGroupName = "")[[1]]
  omopgenerics::assertLogical(sex, length = 1)
  original_interval <- interval
  x <- validateIntervals(interval)
  interval <- x$interval
  unitInterval <- x$unitInterval

  if (missing(ageGroup) | is.null(ageGroup)) {
    ageGroup <- list("overall" = c(0, Inf))
  } else {
    ageGroup <- append(ageGroup, list("overall" = c(0, Inf)))
  }


  # Create initial variables ----
  cdm <- omopgenerics::cdmReference(observationPeriod)
  observationPeriod <- addStrataToPeopleInObservation(cdm, ageGroup, sex, tablePrefix, dateRange)

  # Calculate denominator ----
  denominator <- cdm |> getDenominator(output)

  name <- "observation_period"
  start_date_name <- omopgenerics::omopColumns(table = name, field = "start_date")
  end_date_name <- omopgenerics::omopColumns(table = name, field = "end_date")

  # Observation period ----
  if (interval != "overall") {
    timeInterval <- getIntervalTibbleForObservation(observationPeriod, start_date_name, end_date_name, interval, unitInterval)

    # Insert interval table to the cdm ----
    cdm <- cdm |>
      omopgenerics::insertTable(name = paste0(tablePrefix, "interval"), table = timeInterval)
  }
  result <- list()
  # Count records ----
  if (any(output %in% c("person-days", "sex", "record", "person"))) {
    # Calculate denominator ----

    denominator <- cdm |> getDenominator(output)
    result$count <- observationPeriod |>
      countRecords(cdm, start_date_name, end_date_name, interval, output, tablePrefix)

    # Add category sex overall
    result$count <- addSexOverall(result$count, sex)

    # Create summarisedResult
    result$count <- createSummarisedResultObservationPeriod(result$count, observationPeriod, sex, name, denominator, dateRange, original_interval)
  }
  if ("age" %in% output) {
    result$age <- createSummarisedResultAge(observationPeriod, cdm, start_date_name, end_date_name, interval, tablePrefix, sex)
  }
  result <- result |> dplyr::bind_rows()
  result <- result |>
    omopgenerics::newSummarisedResult(settings = createSettings(result_type = "summarise_in_observation", study_period = dateRange) |>
      dplyr::mutate("interval" = .env$original_interval))

  CDMConnector::dropSourceTable(cdm, name = dplyr::starts_with(tablePrefix))
  return(result)
}


getDenominator <- function(cdm, output) {
  if ("record" %in% output) {
    denominator_record <- tibble::tibble(
      "denominator" = c(cdm[["person"]] |>
        dplyr::ungroup() |>
        dplyr::select("person_id") |>
        dplyr::summarise("n" = dplyr::n()) |>
        dplyr::pull("n")),
      "variable_name" = "Number records in observation"
    )
  } else {
    denominator_record <- tibble::tibble()
  }
  if ("person" %in% output) {
    denominator_person <- tibble::tibble(
      "denominator" = c(cdm[["person"]] |>
        dplyr::ungroup() |>
        dplyr::select("person_id") |>
        dplyr::summarise("n" = dplyr::n()) |>
        dplyr::pull("n")),
      "variable_name" = "Number subjects in observation"
    )
  } else {
    denominator_person <- tibble::tibble()
  }
  if ("person-days" %in% output) {
    y <- cdm[["observation_period"]] |>
      dplyr::ungroup() |>
      dplyr::inner_join(cdm[["person"]] |> dplyr::select("person_id"), by = "person_id") %>%
      dplyr::mutate(n = !!CDMConnector::datediff("observation_period_start_date", "observation_period_end_date", interval = "day") + 1) |>
      dplyr::summarise("n" = sum(.data$n, na.rm = TRUE)) |>
      dplyr::pull("n")

    denominator_pd <- tibble::tibble(
      "denominator" = y,
      "variable_name" = "Number person-days"
    )
  } else {
    denominator_pd <- tibble::tibble()
  }
  if ("sex" %in% output) {
    denominator_sex <- tibble::tibble(
      "denominator" = c(cdm[["person"]] |>
        dplyr::ungroup() |>
        dplyr::filter(.data$gender_concept_id %in% c(8507, 8532)) |>
        dplyr::select("person_id") |>
        dplyr::summarise("n" = dplyr::n()) |>
        dplyr::pull("n")),
      "variable_name" = "Number females in observation"
    )
  } else {
    denominator_sex <- tibble::tibble()
  }

  denominator <- rbind(denominator_record, denominator_person, denominator_pd, denominator_sex)
  return(denominator)
}

getIntervalTibbleForObservation <- function(omopTable, start_date_name, end_date_name, interval, unitInterval) {
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
      "interval_end_date" = dplyr::if_else(.env$interval == "year",
        clock::add_years(min(.data$group), .env$unitInterval) - 1,
        clock::add_months(min(.data$group), .env$unitInterval) - 1
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


countRecords <- function(observationPeriod, cdm, start_date_name, end_date_name, interval, output, tablePrefix) {
  if ("person-days" %in% output) {
    if (interval != "overall") {
      x <- cdm[[paste0(tablePrefix, "interval")]] |>
        dplyr::cross_join(
          observationPeriod |>
            dplyr::select(
              "start_date" = "observation_period_start_date",
              "end_date" = "observation_period_end_date",
              "age_group", "sex", "person_id"
            )
        ) |>
        dplyr::filter((.data$start_date < .data$interval_start_date & .data$end_date >= .data$interval_start_date) |
          (.data$start_date >= .data$interval_start_date & .data$start_date <= .data$interval_end_date)) %>%
        dplyr::mutate(start_date = dplyr::if_else(!is.na(.data$start_date) & .data$start_date >= .data$interval_start_date, .data$start_date, .data$interval_start_date)) |>
        dplyr::mutate(end_date = dplyr::if_else(!is.na(.data$end_date) & .data$end_date <= .data$interval_end_date, .data$end_date, .data$interval_end_date)) |>
        dplyr::compute(temporary = FALSE, name = tablePrefix)
      additional_column <- "time_interval"
    } else {
      x <- observationPeriod |>
        dplyr::rename(
          "start_date" = "observation_period_start_date",
          "end_date" = "observation_period_end_date"
        )
      additional_column <- character()
    }

    personDays <- x %>%
      dplyr::mutate(estimate_value = !!CDMConnector::datediff("start_date", "end_date", interval = "day") + 1) |>
      dplyr::group_by(dplyr::across(dplyr::any_of(c("sex", "age_group", "time_interval")))) |>
      dplyr::summarise(estimate_value = sum(.data$estimate_value, na.rm = TRUE), .groups = "drop") |>
      dplyr::mutate("variable_name" = "Number person-days") |>
      dplyr::collect()
  } else {
    personDays <- createEmptyIntervalTable(interval)
  }

  if ("record" %in% output) {
    if (interval != "overall") {
      x <- observationPeriod |>
        dplyr::mutate("start_date" = as.Date(paste0(as.character(as.integer(clock::get_year(.data[[start_date_name]]))), "-", as.character(as.integer(clock::get_month(.data[[start_date_name]]))), "-01"))) |>
        dplyr::mutate("end_date" = as.Date(paste0(as.character(as.integer(clock::get_year(.data[[end_date_name]]))), "-", as.character(as.integer(clock::get_month(.data[[end_date_name]]))), "-01"))) |>
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
    } else {
      records <- observationPeriod |>
        dplyr::group_by(.data$age_group, .data$sex) |>
        dplyr::summarise(estimate_value = dplyr::n(), .groups = "drop") |>
        dplyr::mutate("variable_name" = "Number records in observation") |>
        dplyr::collect()
      additional_column <- character()
    }
  } else {
    records <- createEmptyIntervalTable(interval)
  }

  if ("person" %in% output) {
    if (interval != "overall") {
      x <- observationPeriod |>
        dplyr::mutate("start_date" = as.Date(paste0(as.character(as.integer(clock::get_year(.data[[start_date_name]]))), "-", as.character(as.integer(clock::get_month(.data[[start_date_name]]))), "-01"))) |>
        dplyr::mutate("end_date" = as.Date(paste0(as.character(as.integer(clock::get_year(.data[[end_date_name]]))), "-", as.character(as.integer(clock::get_month(.data[[end_date_name]]))), "-01"))) |>
        dplyr::group_by(.data$start_date, .data$end_date, .data$age_group, .data$sex) |>
        dplyr::summarise(estimate_value = dplyr::n_distinct("person_id"), .groups = "drop") |>
        dplyr::compute(temporary = FALSE, name = tablePrefix)

      subjects <- cdm[[paste0(tablePrefix, "interval")]] |>
        dplyr::cross_join(x) |>
        dplyr::filter((.data$start_date < .data$interval_start_date & .data$end_date >= .data$interval_start_date) |
          (.data$start_date >= .data$interval_start_date & .data$start_date <= .data$interval_end_date)) |>
        dplyr::group_by(.data$time_interval, .data$age_group, .data$sex) |>
        dplyr::summarise(estimate_value = sum(.data$estimate_value, na.rm = TRUE), .groups = "drop") |>
        dplyr::mutate("variable_name" = "Number subjects in observation") |>
        dplyr::collect()
      additional_column <- "time_interval"
    } else {
      subjects <- observationPeriod |>
        dplyr::group_by(.data$age_group, .data$sex) |>
        dplyr::summarise(estimate_value = dplyr::n_distinct("person_id"), .groups = "drop") |>
        dplyr::mutate("variable_name" = "Number subjects in observation") |>
        dplyr::collect()
      additional_column <- character()
    }
  } else {
    subjects <- createEmptyIntervalTable(interval)
  }

  if ("sex" %in% output) {
    if (interval != "overall") {
      x <- observationPeriod |>
        dplyr::mutate("start_date" = as.Date(paste0(as.character(as.integer(clock::get_year(.data[[start_date_name]]))), "-", as.character(as.integer(clock::get_month(.data[[start_date_name]]))), "-01"))) |>
        dplyr::mutate("end_date" = as.Date(paste0(as.character(as.integer(clock::get_year(.data[[end_date_name]]))), "-", as.character(as.integer(clock::get_month(.data[[end_date_name]]))), "-01"))) |>
        dplyr::cross_join(cdm[[paste0(tablePrefix, "interval")]]) |>
        dplyr::filter((.data$start_date < .data$interval_start_date & .data$end_date >= .data$interval_start_date) |
          (.data$start_date >= .data$interval_start_date & .data$start_date <= .data$interval_end_date)) |>
        PatientProfiles::addSexQuery() |>
        suppressWarnings() |>
        dplyr::compute(temporary = FALSE, name = tablePrefix)

      strata <- c("time_interval", "age_group")
      additional_column <- "time_interval"
    } else {
      x <- observationPeriod |>
        PatientProfiles::addSexQuery() |>
        suppressWarnings() |>
        dplyr::compute(temporary = FALSE, name = tablePrefix)
      strata <- "age_group"
      additional_column <- character()
    }

    sex <- x |>
      dplyr::group_by(dplyr::across(dplyr::all_of(strata))) |>
      dplyr::filter(.data$sex == "Female") |>
      dplyr::summarise("estimate_value" = dplyr::n(), .groups = "drop") |>
      dplyr::collect() |>
      dplyr::bind_rows() |>
      dplyr::mutate(
        "variable_name" = "Number females in observation",
        "sex" = "overall"
      )
  } else {
    sex <- createEmptyIntervalTable(interval)
  }

  x <- personDays |>
    dplyr::mutate(estimate_value = as.numeric(.data$estimate_value)) |>
    rbind(
      records |>
        dplyr::mutate(estimate_value = as.numeric(.data$estimate_value)),
      subjects |>
        dplyr::mutate(estimate_value = as.numeric(.data$estimate_value)),
      sex |>
        dplyr::mutate(estimate_value = as.numeric(.data$estimate_value))
    ) |>
    omopgenerics::uniteAdditional(additional_column) |>
    dplyr::arrange(dplyr::across(dplyr::any_of("additional_level"))) |>
    dplyr::mutate(
      "estimate_name" = "count",
      "estimate_type" = "integer"
    )

  return(x)
}

createSummarisedResultObservationPeriod <- function(result, observationPeriod, sex, name, denominator, dateRange, original_interval) {
  if (dim(result)[1] == 0) {
    result <- omopgenerics::emptySummarisedResult()
  } else {
    result <- result |>
      dplyr::mutate("estimate_value" = sprintf("%.0f", .data$estimate_value)) |>
      omopgenerics::uniteStrata(cols = c("sex", "age_group")) |>
      dplyr::mutate(
        "result_id" = as.integer(1),
        "cdm_name" = omopgenerics::cdmName(omopgenerics::cdmReference(observationPeriod)),
        "group_name" = "omop_table",
        "group_level" = name,
        "variable_level" = as.character(NA)
      )

    result <- result |>
      rbind(result) |>
      dplyr::group_by(.data$additional_level, .data$strata_level, .data$variable_name) |>
      dplyr::mutate(estimate_type = dplyr::if_else(dplyr::row_number() == 2, "percentage", .data$estimate_type)) |>
      dplyr::inner_join(denominator, by = "variable_name") |>
      dplyr::mutate(estimate_value = dplyr::if_else(.data$estimate_type == "percentage", sprintf("%.2f", as.numeric(.data$estimate_value) / denominator * 100), .data$estimate_value)) |>
      dplyr::select(-c("denominator")) |>
      dplyr::mutate(estimate_name = dplyr::if_else(.data$estimate_type == "percentage", "percentage", .data$estimate_name))
  }
  return(result)
}
createSummarisedResultAge <- function(observationPeriod, cdm, start_date_name, end_date_name, interval, tablePrefix, sex) {
  strata <- list(character(), "sex")[c(TRUE, sex)]
  if (interval != "overall") {
    x <- observationPeriod |>
      dplyr::mutate("start_date" = as.Date(paste0(as.character(as.integer(clock::get_year(.data[[start_date_name]]))), "-", as.character(as.integer(clock::get_month(.data[[start_date_name]]))), "-01"))) |>
      dplyr::mutate("end_date" = as.Date(paste0(as.character(as.integer(clock::get_year(.data[[end_date_name]]))), "-", as.character(as.integer(clock::get_month(.data[[end_date_name]]))), "-01"))) |>
      dplyr::cross_join(cdm[[paste0(tablePrefix, "interval")]]) |>
      dplyr::filter((.data$start_date < .data$interval_start_date & .data$end_date >= .data$interval_start_date) |
        (.data$start_date >= .data$interval_start_date & .data$start_date <= .data$interval_end_date)) |>
      dplyr::mutate(index_date = dplyr::if_else(
        .data[[start_date_name]] >= .data$interval_start_date,
        .data[[start_date_name]],
        .data$interval_start_date
      )) |>
      PatientProfiles::addAgeQuery(indexDate = "index_date") |>
      dplyr::compute(temporary = FALSE, name = tablePrefix)

    additional_column <- "time_interval"
  } else {
    x <- observationPeriod |>
      PatientProfiles::addAgeQuery(indexDate = start_date_name) |>
      dplyr::compute(temporary = FALSE, name = tablePrefix)

    additional_column <- character()
  }

  res <- purrr::map(strata, \(stratax) {
    x |>
      dplyr::group_by(dplyr::across(dplyr::all_of(c("age_group", stratax, additional_column)))) |>
      dplyr::summarise(estimate_value = stats::median(.data$age), .groups = "drop") |>
      dplyr::collect()
  }) |>
    dplyr::bind_rows() |>
    dplyr::mutate(
      "variable_name" = "Median age in observation",
      "estimate_name" = "median",
      "estimate_type" = "numeric",
      "estimate_value" = sprintf("%.0f", as.numeric(.data$estimate_value))
    ) |>
    omopgenerics::uniteAdditional(additional_column) |>
    dplyr::arrange(dplyr::across(dplyr::any_of("additional_level"))) |>
    omopgenerics::uniteStrata(cols = c("sex"[sex], "age_group")) |>
    dplyr::mutate(
      "result_id" = as.integer(1),
      "cdm_name" = omopgenerics::cdmName(omopgenerics::cdmReference(observationPeriod)),
      "group_name" = "omop_table",
      "group_level" = "observation_period",
      "variable_level" = as.character(NA)
    )
  return(res)
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
      CohortConstructor::trimToDateRange(dateRange = dateRange)
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

addSexOverall <- function(result, sex) {
  if (sex) {
    result <- result |> rbind(
      result |>
        dplyr::filter(.data$sex != "overall") |>
        dplyr::group_by(.data$age_group, .data$additional_level, .data$variable_name, .data$additional_name, .data$estimate_name, .data$estimate_type) |>
        dplyr::summarise(estimate_value = sum(.data$estimate_value, na.rm = TRUE), .groups = "drop") |>
        dplyr::mutate(sex = "overall")
    )
  }
  return(result)
}

createEmptyIntervalTable <- function(interval) {
  if (interval == "overall") {
    tibble::tibble(
      "sex" = as.character(),
      "age_group" = as.character(),
      "estimate_value" = as.double()
    )
  } else {
    tibble::tibble(
      "time_interval" = as.character(),
      "sex" = as.character(),
      "age_group" = as.character(),
      "estimate_value" = as.double()
    )
  }
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
