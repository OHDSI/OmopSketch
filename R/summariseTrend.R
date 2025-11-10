
#' Summarise temporal trends in OMOP tables
#'
#' This function summarises temporal trends from OMOP CDM tables, considering
#' only data within the observation period.
#' It supports both event and episode tables and can report trends such as
#' number of records, number of subjects, person-days, median age, and number of
#' females.
#'
#' - **Event tables**:
#'   Records are included if their **start date** falls within the study period.
#'   Each record contributes to the time interval containing the start date.
#'
#' - **Episode tables**:
#'   Records are included if their **start or end date** overlaps with the study
#'   period. Records are **trimmed** to the date range, and contribute to
#'   **all** overlapping time intervals between start and end dates.
#'
#' @inheritParams consistent-doc
#' @param event A character vector of OMOP table names to treat as event tables
#' (uses only start date).
#' @param episode A character vector of OMOP table names to treat as episode
#' tables (uses start and end date).
#' @param output A character vector indicating what to summarise.
#' Options include `"record"` (default), `"person"`, `"person-days"`, `"age"`,
#' `"sex"`.
#' If included, the number of person-days is computed only for episode tables.
#' @param inObservation Logical. If `TRUE`, the results are stratified to
#' indicate whether each record occurs within an observation period.
#' @param dateRange A vector of two dates defining the desired study period.
#' If `dateRange` is `NULL`, no restriction is applied.
#'
#' @return A `summarised_result` object with the results.
#' @export
#'
#' @examples
#' \donttest{
#' library(OmopSketch)
#' library(omock)
#' library(dplyr)
#'
#' cdm <- mockCdmFromDataset(datasetName = "GiBleed", source = "duckdb")
#'
#' result <- summariseTrend(
#'   cdm = cdm,
#'   event = c("condition_occurrence", "drug_exposure"),
#'   episode = "observation_period",
#'   interval = "years",
#'   ageGroup = list("<=20" = c(0, 20), ">20" = c(21, Inf)),
#'   sex = TRUE,
#'   dateRange = as.Date(c("1950-01-01", "2010-12-31"))
#' )
#'
#' plotTrend(result = result, facet = sex ~ omop_table, colour = c("age_group"))
#'
#' cdmDisconnect(cdm = cdm)
#' }
#'
summariseTrend <- function(cdm,
                           event = NULL,
                           episode = NULL,
                           output = "record",
                           interval = "overall",
                           ageGroup = NULL,
                           sex = FALSE,
                           inObservation = FALSE,
                           dateRange = NULL) {
  cdm <- omopgenerics::validateCdmArgument(cdm)
  omopgenerics::assertChoice(event, omopgenerics::omopTables(version = omopgenerics::cdmVersion(cdm)), null = TRUE)
  omopgenerics::assertChoice(episode, omopgenerics::omopTables(version = omopgenerics::cdmVersion(cdm)), null = TRUE)
  omopgenerics::assertChoice(interval, c("overall", "years", "quarters", "months"), length = 1)
  ageGroup <- omopgenerics::validateAgeGroupArgument(ageGroup, ageGroupName = "age_group")
  omopgenerics::assertLogical(sex, length = 1)
  dateRange <- validateStudyPeriod(cdm, dateRange)
  omopgenerics::assertChoice(output, choices = c("person-days", "record", "person", "age", "sex"))
  omopgenerics::assertLogical(inObservation, length = 1)


  result <- list()
  set <- list()
  result_id <- 1L
  if (!is.null(event)) {
    result$event <- summariseEventTrend(cdm = cdm, omopTableName = event, output = output, sex = sex, ageGroup = ageGroup, interval = interval, dateRange = dateRange, inObservation = inObservation) |>
      dplyr::mutate(result_id = .env$result_id)

    set$event <- createSettings(result_type = "summarise_trend", result_id = result_id, study_period = dateRange) |>
      dplyr::mutate(
        "interval" = .env$interval,
        "type" = "event"
      )

    result_id <- result_id + 1L
  }
  if (!is.null(episode)) {
    result$episode <- summariseEpisodeTrend(cdm = cdm, omopTableName = episode, output = output, sex = sex, ageGroup = ageGroup, interval = interval, dateRange = dateRange, inObservation = inObservation) |>
      dplyr::mutate(result_id = .env$result_id)

    set$episode <- createSettings(result_type = "summarise_trend", result_id = result_id, study_period = dateRange) |>
      dplyr::mutate(
        "interval" = .env$interval,
        "type" = "episode"
      )
  }
  result <- result |>
    dplyr::bind_rows()
  if (rlang::is_empty(result) | nrow(result) == 0) {
    return(omopgenerics::emptySummarisedResult(settings = createSettings(result_type = "summarise_trend", study_period = dateRange)))
  }
  set <- set |> dplyr::bind_rows()

  summarisedResult <- result |>
    omopgenerics::uniteStrata(cols = c(character(), intersect(c("sex", "age_group", "in_observation"), colnames(result)))) |>
    omopgenerics::uniteAdditional(cols = c(character(), intersect("time_interval", colnames(result)))) |>
    omopgenerics::uniteGroup(cols = "omop_table") |>
    dplyr::mutate(
      cdm_name = omopgenerics::cdmName(cdm),
      variable_level = NA_character_
    ) |>
    omopgenerics::newSummarisedResult(settings = set) |>
    dplyr::arrange(.data$additional_level)

  return(summarisedResult)
}

summariseEventTrend <- function(cdm, omopTableName, output, interval, sex, ageGroup, dateRange, inObservation) {
  prefix <- omopgenerics::tmpPrefix()
  if ("person-days" %in% output) {

    cli::cli_alert("The number of person-days is not computed for event tables")
    output <- output[output != "person-days"]
  }
  if (rlang::is_empty(output)) {
    return(dplyr::tibble())
  }
  result <- purrr::map(omopTableName, \(table) {
    strata <- c(list(character()), omopgenerics::combineStrata(strataCols(
      sex = sex,
      ageGroup = ageGroup,
      interval = interval,
      inObservation = if (table == "observation_period") FALSE else inObservation
    )))

    omopTable <- dplyr::ungroup(cdm[[table]])

    omopTable <- omopTable |>
      restrictStudyPeriod(dateRange = dateRange)

    if (is.null(omopTable)) {
      return(dplyr::tibble())
    }

    denominator <- getDenominator(omopTable = omopTable, output = output)
    start_date_name <- omopgenerics::omopColumns(table = table, field = "start_date")

    x <- omopTable |>
      dplyr::select("start_date" = dplyr::all_of(start_date_name), "person_id") |>
      addStratifications(
        indexDate = "start_date",
        sex = sex,
        ageGroup = ageGroup,
        interval = interval,
        intervalName = "interval",
        name = omopgenerics::uniqueTableName(prefix = prefix)
      ) |>
      addInObservation(
        inObservation = if (table == "observation_period") FALSE else inObservation,
        episode = FALSE,
        cdm = cdm,
        name = omopgenerics::uniqueTableName(prefix = prefix)
      )

    res <- summariseTrendInternal(x = x, output = output, strata = strata)

    res <- res |>
      dplyr::bind_rows(res |>
                         dplyr::inner_join(denominator, by = "variable_name") |>
                         dplyr::mutate(
                           estimate_value = sprintf("%.2f", as.numeric(.data$estimate_value) / denominator * 100),
                           estimate_name = "percentage",
                           estimate_type = "percentage"
                         ) |>
                         dplyr::select(-c("denominator"))) |>
      dplyr::mutate(omop_table = .env$table)
  }) |>
    dplyr::bind_rows() |>
    addTimeInterval()
  omopgenerics::dropSourceTable(cdm = cdm, name = dplyr::starts_with(prefix))
  return(result)
}

summariseEpisodeTrend <- function(cdm, omopTableName, output, interval, sex, ageGroup, dateRange, inObservation) {

  result <- purrr::map(omopTableName, \(table) {
    prefix <- omopgenerics::tmpPrefix()

    omopTable <- dplyr::ungroup(cdm[[table]])

    omopTable <- omopTable |>
      trimStudyPeriod(dateRange = dateRange)

    if (is.null(omopTable)) {
      return(dplyr::tibble())
    }


    start_date_name <- omopgenerics::omopColumns(table = table, field = "start_date")
    end_date_name <- omopgenerics::omopColumns(table = table, field = "end_date")

    denominator <- getDenominator(omopTable = omopTable, output = output)

    res <- list()


    x <- omopTable |>
      dplyr::select(dplyr::all_of(c(start_date_name, end_date_name, "person_id"))) |>
      addSexAgeGroup(sex = sex, ageGroup = ageGroup, indexDate = start_date_name) |>
      dplyr::rename("start_date" = dplyr::any_of(start_date_name), "end_date" = dplyr::any_of(end_date_name)) |>
      addInObservation(
        inObservation = if (table == "observation_period") FALSE else inObservation,
        cdm = cdm,
        episode = TRUE,
        name = omopgenerics::uniqueTableName(prefix = prefix)
      )

    strata <- c(list(character()), omopgenerics::combineStrata(strataCols(
      sex = sex,
      ageGroup = ageGroup,
      interval = "overall",
      inObservation = if (table == "observation_period") FALSE else inObservation
    )))

    res$timeOverall <- summariseTrendInternal(x = x, output = output, strata = strata)

    if (interval != "overall" & nrow(res$timeOverall) > 0) {
      # add time_interval column

      # calculate timeInterval
      timeInterval <- getIntervalTibbleForObservation(omopTable, start_date_name, end_date_name, interval)
      n <- nrow(timeInterval)

      # split into 10 row chucks
      rows <- split(seq_len(n), ceiling(seq_along(seq_len(n)) / 10))

      for (i in seq_along(rows)) {
        # insert time interval
        nm <- omopgenerics::uniqueTableName(prefix = prefix)
        cdm <- omopgenerics::insertTable(cdm = cdm, name = nm, table = timeInterval[rows[[i]],])

        # do the cross_join and filter
        xi <- cdm[[nm]] |>
          dplyr::cross_join(
            omopTable |>
              dplyr::mutate(
                start_date = as.Date(paste0(
                  as.character(as.integer(clock::get_year(.data[[start_date_name]]))), "-",
                  as.character(as.integer(clock::get_month(.data[[start_date_name]]))), "-01"
                )),
                end_date = dplyr::if_else(
                  is.na(.data[[end_date_name]]),
                  as.Date(NA),
                  as.Date(paste0(
                    as.character(as.integer(clock::get_year(.data[[end_date_name]]))), "-",
                    as.character(as.integer(clock::get_month(.data[[end_date_name]]))), "-01"
                  ))
                )
              )
          ) |>
          dplyr::filter(
            (.data$start_date < .data$interval_start_date &
               (!is.na(.data$end_date) & .data$end_date >= .data$interval_start_date)) |
              (.data$start_date >= .data$interval_start_date &
                 .data$start_date <= .data$interval_end_date)
          ) |>
          dplyr::compute(name = omopgenerics::uniqueTableName(prefix = prefix))

        if (i == 1) {
          x <- xi
        } else {
          x <- x |>
            dplyr::union_all(xi) |>
            dplyr::compute(name = omopgenerics::uniqueTableName(prefix = prefix))
        }
      }

      x <- x |>
        dplyr::mutate(
          start_date = dplyr::if_else(
            .data[[start_date_name]] > .data$interval_start_date,
            .data[[start_date_name]],
            .data$interval_start_date
          ),
          end_date = dplyr::if_else(
            !is.na(.data[[end_date_name]]) & .data[[end_date_name]] < .data$interval_end_date,
            .data[[end_date_name]],
            .data$interval_end_date
          )
        ) |>
        addSexAgeGroup(sex = sex, ageGroup = ageGroup, indexDate = "start_date") |>
        dplyr::compute(name = omopgenerics::uniqueTableName(prefix = prefix)) |>
        addInObservation(
          inObservation = if (table == "observation_period") FALSE else inObservation,
          cdm = cdm,
          episode = TRUE,
          name = omopgenerics::uniqueTableName(prefix = prefix)
        )

      strata <- purrr::map(strata, \(x) c("time_interval", x))

      res$interval <- summariseTrendInternal(x = x, output = output, strata = strata)

      omopgenerics::dropSourceTable(cdm = cdm, name = dplyr::starts_with(prefix))
    }

    if (rlang::is_empty(res)) {
      return(dplyr::tibble())
    }

    res <- res |>
      dplyr::bind_rows()

    res <- res |>
      dplyr::bind_rows(res |>
                         dplyr::inner_join(denominator, by = "variable_name") |>
                         dplyr::mutate(
                           estimate_value = sprintf("%.2f", as.numeric(.data$estimate_value) / denominator * 100),
                           estimate_name = "percentage",
                           estimate_type = "percentage"
                         ) |>
                         dplyr::select(-c("denominator"))) |>
      dplyr::mutate(omop_table = .env$table)
  }) |>
    dplyr::bind_rows()

  return(result)
}

summariseTrendInternal <- function(x, output, strata) {
  res <- list()

  if ("record" %in% output) {
    res$record <- summariseCountsInternal(x = x, strata = strata, counts = "records") |>
      dplyr::mutate(
        estimate_name = "count",
        variable_name = "Number of records"
      )
  }
  if ("person" %in% output) {
    res$person <- summariseCountsInternal(x = x, strata = strata, counts = "person_id") |>
      dplyr::mutate(
        estimate_name = "count",
        variable_name = "Number of subjects"
      )
  }
  if ("sex" %in% output) {
    strata_sex <- strata[!vapply(strata, function(x) "sex" %in% x, logical(1))]
    if (!"sex" %in% colnames(x)) {
      x <- x |> PatientProfiles::addSexQuery()
    }
    res$sex <- x |>
      dplyr::filter(.data$sex == "Female") |>
      summariseCountsInternal(strata = strata_sex, counts = "person_id") |>
      dplyr::mutate(
        estimate_name = "count",
        variable_name = "Number of females"
      )
  }

  if ("age" %in% output) {
    res$age <- summariseMedianAge(x = x, index_date = "start_date", strata = strata) |>
      dplyr::mutate(variable_name = "Age")
  }

  if ("person-days" %in% output) {
    res$personDays <- x |>
      datediffDays(start = "start_date", end = "end_date", name = "person_days", offset = 1) |>
      summariseSumInternal(strata = strata, variable = "person_days") |>
      dplyr::mutate(variable_name = "Person-days")
  }

  if (rlang::is_empty(res)) {
    return(dplyr::tibble())
  }

  res <- res |>
    dplyr::bind_rows()
  return(res)
}

getIntervalTibbleForObservation <- function(omopTable, start_date_name, end_date_name, interval) {
  x <- validateIntervals(interval)
  interval <- x$interval
  unitInterval <- x$unitInterval

  startDate <- getOmopTableStartDate(omopTable, start_date_name)
  endDate <- getOmopTableEndDate(omopTable, end_date_name)

  dplyr::tibble(
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

getDenominator <- function(omopTable, output) {
  cdm <- omopgenerics::cdmReference(omopTable)

  denominator <- dplyr::tibble(
    "denominator" = c(numeric()),
    "variable_name" = c(character())
  )
  if ("record" %in% output) {
    denominator <- denominator |>
      dplyr::bind_rows(dplyr::tibble(
        "denominator" = c(omopTable |>
                            dplyr::ungroup() |>
                            dplyr::summarise("n" = dplyr::n()) |>
                            dplyr::pull("n") |>
                            as.numeric()),
        "variable_name" = "Number of records"
      ))
  }
  if ("person" %in% output) {
    denominator <- denominator |>
      dplyr::bind_rows(dplyr::tibble(
        "denominator" = c(cdm[["person"]] |>
                            dplyr::ungroup() |>
                            dplyr::select("person_id") |>
                            dplyr::summarise("n" = dplyr::n()) |>
                            dplyr::pull("n") |>
                            as.numeric()),
        "variable_name" = "Number of subjects"
      ))
  }
  if ("person-days" %in% output) {
    tableName <- omopgenerics::tableName(table = omopTable)
    start_date_name <- omopgenerics::omopColumns(table = tableName, field = "start_date")
    end_date_name <- omopgenerics::omopColumns(table = tableName, field = "end_date")
    y <- omopTable |>
      dplyr::ungroup() |>
      datediffDays(start = start_date_name, end = end_date_name, name = "n", offset = 1) |>
      dplyr::summarise("n" = sum(.data$n, na.rm = TRUE)) |>
      dplyr::pull("n") |>
      as.numeric()

    denominator <- denominator |>
      dplyr::bind_rows(dplyr::tibble(
        "denominator" = y,
        "variable_name" = "Person-days"
      ))
  }

  if ("sex" %in% output) {
    denominator <- denominator |>
      dplyr::bind_rows(dplyr::tibble(
        "denominator" = c(omopTable |>
                            dplyr::ungroup() |>
                            dplyr::inner_join(cdm[["person"]] |>
                                                dplyr::filter(.data$gender_concept_id %in% c(8507, 8532)), by = "person_id") |>
                            dplyr::summarise("n" = dplyr::n_distinct(.data$person_id)) |>
                            dplyr::pull("n") |>
                            as.numeric()),
        "variable_name" = "Number of females"
      ))
  }

  return(denominator)
}
