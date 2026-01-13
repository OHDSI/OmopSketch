
validateIntervals <- function(interval, call = parent.frame()) {
  omopgenerics::assertCharacter(interval, length = 1, na = FALSE, null = FALSE, call = call)

  if (!interval %in% c("overall", "years", "months", "quarters")) {
    cli::cli_abort("Interval argument {interval} is not valid. Valid options are either `overall`, `years`, `quarters` or `months`.", call = call)
  }

  unitInterval <- dplyr::case_when(
    interval == "overall" ~ NA,
    interval == "quarters" ~ 3,
    interval == "months" ~ 1,
    interval == "years" ~ 1
  )

  if (interval == "quarters") {
    quarters <- "month"
  } else {
    interval <- gsub("s$", "", interval)
  }

  return(list("interval" = interval, "unitInterval" = unitInterval))
}

#' @noRd
validateStudyPeriod <- function(cdm, studyPeriod, call = parent.frame()) {
  if (is.null(studyPeriod)) {
    return(NULL)
  }
  # First date checks
  if (!is.na(studyPeriod[1]) & !is.na(studyPeriod[2]) & studyPeriod[1] > studyPeriod[2]) {
    cli::cli_abort("The studyPeriod ends at a date earlier than the start provided.", call = call)
  }
  if (!is.na(studyPeriod[1]) & is.na(as.Date(studyPeriod[1], format = "%d/%m/%Y")) && is.na(as.Date(studyPeriod[1], format = "%Y-%m-%d"))) {
    cli::cli_abort("Please ensure that dates provided are in the correct format.", call = call)
  }
  if (!is.na(studyPeriod[2]) & is.na(as.Date(studyPeriod[2], format = "%d/%m/%Y")) && is.na(as.Date(studyPeriod[2], format = "%Y-%m-%d"))) {
    cli::cli_abort("Please ensure that dates provided are in the correct format.", call = call)
  }

  studyPeriod <- as.character(studyPeriod)
  omopgenerics::assertCharacter(studyPeriod, length = 2, na = TRUE)
  observationRange <- cdm$observation_period |>
    dplyr::summarise(
      minobs = min(.data$observation_period_start_date, na.rm = TRUE),
      maxobs = max(.data$observation_period_end_date, na.rm = TRUE)
    ) |>
    dplyr::collect()

  if (is.na(studyPeriod[1])) {
    studyPeriod[1] <- observationRange |>
      dplyr::pull("minobs") |>
      as.character()
  } else {
    if (observationRange |>
      dplyr::pull("minobs") > studyPeriod[1]) {
      cli::cli_alert(paste0("The observation period in the cdm starts in ", observationRange |>
        dplyr::pull("minobs")))
    }
    if (studyPeriod[1] < "1800-01-01") {
      cli::cli_alert(paste0("The observation period in the cdm starts at a very early date."))
    }
  }

  if (is.na(studyPeriod[2])) {
    studyPeriod[2] <- observationRange |>
      dplyr::pull("maxobs") |>
      as.character()
  } else {
    if (observationRange |>
      dplyr::pull("maxobs") < studyPeriod[2]) {
      cli::cli_alert(paste0("The observation period in the cdm ends in ", observationRange |>
        dplyr::pull("maxobs")))
    }
    if (studyPeriod[2] > clock::date_today(zone = "GMT")) {
      cli::cli_alert(paste0("The given date range ends after current date."))
    }
  }

  return(studyPeriod |> as.Date())
}

#' @noRd
validateFacet <- function(facet, result, call = parent.frame()) {
  if (rlang::is_formula(facet)) {
    facet <- as.character(facet)
    facet <- unlist(strsplit(facet, " \\+ "))
    facet <- facet[facet != "~" & facet != "+" & facet != "."]
  }

  facet <- as.character(facet)
  omopgenerics::assertChoice(facet, visOmopResults::tidyColumns(result), null = TRUE, call = call)

  return(invisible(NULL))
}

#' @noRd
validateBackground <- function(background, call = parent.frame()) {
  msg <- "'background' must be either TRUE/FALSE or a path to an existing `.md` file."
  if (is.logical(background)) {
    omopgenerics::assertLogical(background, length = 1, call = call, msg = msg)
  } else if (is.character(background)) {
    omopgenerics::assertCharacter(background, length = 1, call = call, msg = msg)
    if (!file.exists(background)) {
      cli::cli_abort(message = msg, call = call)
    }
  } else {
    cli::cli_abort(message = msg, call = call)
  }
  return(invisible(background))
}

#' @noRd
validateSample <- function( sample, cdm, call = parent.frame()) {
  if(!is.null(sample)) {
  msg <- "'sample' must be either an integer or the name of an existing cohort in the cdm"
  if (is.numeric(sample)) {
    omopgenerics::assertNumeric(sample,integerish = TRUE, min = 1, length = 1, null = TRUE, call = call, msg = msg)
    if (sample >= omopgenerics::numberSubjects(cdm[["person"]])) {
      cli::cli_inform("The {.field person} table has \u2264 {.val {sample}} subjects; skipping sampling of the CDM.", call = call)
      sample = NULL
    }
  } else if (is.character(sample)) {
    omopgenerics::assertCharacter(sample, length = 1, call = call, msg = msg)
  } else {
    cli::cli_abort(message = msg, call = call)
  }
  }
  return(invisible(sample))
}

