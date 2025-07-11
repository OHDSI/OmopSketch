summariseTrend <- function(cdm,
                           event = NULL,
                           episode = NULL,
                           output = "record",
                           interval = "overall",
                           ageGroup = NULL,
                           sex = FALSE,
                           dateRange = NULL) {

  cdm <- omopgenerics::validateCdmArgument(cdm)
  omopgenerics::assertCharacter(omopTableName)
  omopgenerics::assertChoice(event, omopgenerics::omopTables(version = omopgenerics::cdmVersion(cdm)), null = TRUE)
  omopgenerics::assertChoice(episode, omopgenerics::omopTables(version = omopgenerics::cdmVersion(cdm)), null = TRUE)
  omopgenerics::assertChoice(interval, c("overall", "years", "quarters", "months"), length = 1)
  ageGroup <- omopgenerics::validateAgeGroupArgument(ageGroup, ageGroupName = "age_group")
  omopgenerics::assertLogical(sex, length = 1)
  dateRange <- validateStudyPeriod(cdm, dateRange)
  omopgenerics::assertChoice(output, choices = c("person-days", "record", "person", "age", "sex"))

  denominator <- getDenominator(cdm, output)
  result <- list()
  set <- list()
  result_id <- 1L
  if (!is.null(event)) {
    result$event <- summariseEventTrend(cdm = cdm, omopTableName = event, output = output, sex = sex, ageGroup = ageGroup, interval = interval, dateRange = dateRange) |>
      dplyr::mutate(result_id = .env$result_id)

    set$event <- createSettings(result_type = "summarise_trend", result_id = result_id, study_period = dateRange) |>
      dplyr::mutate(
        "interval" = .env$interval,
        "type" = "event"
      )

    result_id <- result_id + 1L
  }
  if (!is.null(episode)) {
    result$episode <- summariseEpisodeTrend(cdm = cdm, omopTableName = episode, output = output, sex = sex, ageGroup = ageGroup, interval = interval, dateRange = dateRange) |>
      dplyr::bind_rows(summariseEventTrend(cdm = cdm, omopTableName = episode, output = output, sex = sex, ageGroup = ageGroup, interval = "overall", dateRange = dateRange)) |>
      dplyr::mutate(result_id = .env$result_id)

    set$episode <- createSettings(result_type = "summarise_trend", result_id = result_id, study_period = dateRange) |>
      dplyr::mutate(
        "interval" = .env$interval,
        "type" = "episode"
      )
  }

  result <- result |> dplyr::bind_rows()
  if (nrow(result) == 0) {
    return(omopgenerics::emptySummarisedResult(settings = createSettings(result_type = "summarise_trend", study_period = dateRange)))
  }
  set <- set |> dplyr::bind_rows()
  summarisedResult <- result |>
    dplyr::bind_rows(result |>
      dplyr::left_join(denominator, by = "variable_name") |>
      dplyr::mutate(
        estimate_value = sprintf("%.2f", as.numeric(.data$estimate_value) / denominator * 100),
        estimate_name = "percentage",
        estimate_type = "percentage"
      ) |>
      dplyr::select(-c("denominator"))) |>
    omopgenerics::uniteStrata(strataCols(sex = sex, ageGroup = ageGroup)) |>
    omopgenerics::uniteAdditional(cols = intersect("time_interval", colnames(result))) |>
    omopgenerics::uniteGroup(cols = "omop_table") |>
    dplyr::mutate(
      cdm_name = omopgenerics::cdmName(cdm),
      variable_level = NA_character_
    ) |>
    omopgenerics::newSummarisedResult(settings = set)

  return(summerisedResult)
}

summariseEventTrend <- function(cdm, omopTableName, output, interval, sex, ageGroup, dateRange) {
  prefix <- omopgenerics::tmpPrefix()
  strata <- strata <- c(list(character()), omopgenerics::combineStrata(strataCols(sex = sex, ageGroup = ageGroup, interval = interval)))

  purrr::map(omopTableName, \(table) {
    omopTable <- dplyr::ungroup(cdm[[table]])

    omopTable <- omopTable |>
      restrictStudyPeriod(dateRange = dateRange)

    if (is.null(omopTable)) {
      return(tibble::tibble())
    }

    start_date_name <- omopgenerics::omopColumns(table = table, field = "start_date")

    x <- omopTable |>
      dplyr::select("index_date" = dplyr::all_of(start_date_name), "person_id") |>
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
      )
    res <- list()
    if ("record" %in% output) {
      res$record <- summariseCountsInternal(x = x, strata = strata, counts = "records") |>
        dplyr::mutate(
          estimate_name = "count",
          variable_name = "Records in observation"
        )
    }
    if ("person" %in% output) {
      res$person <- summariseCountsInternal(x = x, strata = strata, counts = "person_id") |>
        dplyr::mutate(
          estimate_name = "count",
          variable_name = "Subjects in observation"
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
          variable_name = "Females in observation"
        )
    }

    if ("age" %in% output) {
      res$age <- summariseMedianAge(x = x, index_date = "index_date", strata = strata) |>
        dplyr::mutate(variable_name = "Age in observation")
    }
    res |>
      dplyr::bind_rows() |>
      dplyr::mutate(omop_table = .env$table) |>
      dplyr::select(dplyr::any_of(c("time_interval" = "interval")), dplyr::everything())
  }) |>
    dplyr::bind_rows()
}


summariseEpisodeTrend <- function(cdm, omopTableName, output, interval, sex, ageGroup, dateRange) {
  prefix <- omopgenerics::tmpPrefix()
  strata <- c(list(character()), omopgenerics::combineStrata(c("sex"[sex], "age_group"[!is.null(ageGroup)])))

  purrr::map(omopTableName, \(table) {
    omopTable <- dplyr::ungroup(cdm[[table]])

    omopTable <- omopTable |>
      trimStudyPeriod(dateRange = dateRange)

    if (is.null(omopTable)) {
      return(tibble::tibble())
    }

    start_date_name <- omopgenerics::omopColumns(table = table, field = "start_date")
    end_date_name <- omopgenerics::omopColumns(table = table, field = "end_date")

    omopTable <- omopTable |>
      dplyr::select(dplyr::all_of(c(start_date_name, end_date_name, "person_id"))) |>
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
        .data[[start_date_name]] >= .data$obs_start & .data[[start_date_name]] <= .data$obs_end &
          .data[[end_date_name]] >= .data$obs_start & .data[[end_date_name]] <= .data$obs_end
      ) |>
      dplyr::select(!c("obs_start", "obs_end"))

    omopTable <- omopTable |>
      addSexAgeGroup(sex = sex, ageGroup = ageGroup, indexDate = "start_date") |>
      dplyr::compute(name = omopgenerics::uniqueTableName(prefix = prefix), temporary = FALSE)

    res <- list()

    if ("person-days" %in% output) {
      res$personDaysOverall <- omopTable %>%
        dplyr::mutate(person_days = as.integer(!!CDMConnector::datediff(start_date_name, end_date_name, interval = "day") + 1)) |>
        summariseSumInternal(strata = strata, variable = "person_days") |>
        dplyr::mutate(variable_name = "Person-days")
    }


    if (interval != "overall") {
      timeInterval <- getIntervalTibbleForObservation(omopTable, start_date_name, end_date_name, interval)

      cdm <- cdm |>
        omopgenerics::insertTable(name = paste0(prefix, "interval"), table = timeInterval)


      x <- cdm[[paste0(prefix, "interval")]] |>
        dplyr::cross_join(omopTable |>
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
        dplyr::compute(name = omopgenerics::uniqueTableName(prefix = prefix))

      strata <- purrr::map(strata, \(x) c("time_interval", x))

      if ("record" %in% output) {
        res$record <- summariseCountsInternal(x = x, strata = strata, counts = "records") |>
          dplyr::mutate(
            estimate_name = "count",
            variable_name = "Records in observation"
          )
      }
      if ("person" %in% output) {
        res$person <- summariseCountsInternal(x = x, strata = strata, counts = "person_id") |>
          dplyr::mutate(
            estimate_name = "count",
            variable_name = "Subjects in observation"
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
            variable_name = "Females in observation"
          )
      }

      if ("age" %in% output) {
        res$age <- summariseMedianAge(x = x, index_date = "start_date", strata = strata) |>
          dplyr::mutate(variable_name = "Age in observation")
      }

      if ("person-days" %in% output) {
        res$personDays <- x %>%
          dplyr::mutate(person_days = as.integer(!!CDMConnector::datediff("start_date", "end_date", interval = "day") + 1)) |>
          summariseSumInternal(strata = strata, variable = "person_days") |>
          dplyr::mutate(variable_name = "Person-days")
      }
    }

    res |>
      dplyr::bind_rows() |>
      dplyr::mutate(omop_table = .env$table)
  }) |>
    dplyr::bind_rows()
}
