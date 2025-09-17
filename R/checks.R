#' @noRd
checkInterval <- function(interval, call = parent.frame()) {
  omopgenerics::assertCharacter(interval, length = 1, na = FALSE, null = FALSE, call = call)

  if (!interval %in% c("year", "month")) {
    cli::cli_abort("Interval argument {interval} is not valid. Valid options are either `year` or `month`.", call = call)
  }
}

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
checkCategory <- function(category, overlap = FALSE, type = "numeric", call = parent.frame()) {
  omopgenerics::assertList(
    category,
    types = type, any.missing = FALSE, unique = TRUE,
    min.len = 1
  )

  if (is.null(names(category))) {
    names(category) <- rep("", length(category))
  }

  # check length
  category <- lapply(category, function(x) {
    if (length(x) == 1) {
      x <- c(x, x)
    } else if (length(x) > 2) {
      cli::cli_abort(
        paste0(
          "Categories should be formed by a lower bound and an upper bound, ",
          "no more than two elements should be provided."
        ),
        call. = FALSE
      )
    }
    invisible(x)
  })

  # check lower bound is smaller than upper bound
  checkLower <- unlist(lapply(category, function(x) {
    x[1] <= x[2]
  }))
  if (!(all(checkLower))) {
    cli::cli_abort("Lower bound should be equal or smaller than upper bound", call = call)
  }

  # built tibble
  result <- lapply(category, function(x, call = parent.frame()) {
    dplyr::tibble(lower_bound = x[1], upper_bound = x[2])
  }) |>
    dplyr::bind_rows() |>
    dplyr::mutate(category_label = names(.env$category)) |>
    dplyr::mutate(category_label = dplyr::if_else(
      .data$category_label == "",
      dplyr::case_when(
        is.infinite(.data$lower_bound) & is.infinite(.data$upper_bound) ~ "any",
        is.infinite(.data$lower_bound) ~ paste(.data$upper_bound, "or below"),
        is.infinite(.data$upper_bound) ~ paste(.data$lower_bound, "or above"),
        TRUE ~ paste(.data$lower_bound, "to", .data$upper_bound)
      ),
      .data$category_label
    )) |>
    dplyr::arrange(.data$lower_bound)

  # check overlap
  if (!overlap) {
    if (nrow(result) > 1) {
      lower <- result$lower_bound[2:nrow(result)]
      upper <- result$upper_bound[1:(nrow(result) - 1)]
      if (!all(lower > upper)) {
        cli::cli_abort("There can not be overlap between categories", call = call)
      }
    }
  }

  invisible(result)
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
validateSample <- function( sample, call = parent.frame()) {
  if(!is.null(sample)) {
  msg <- "'sample' must be either an integer or the name of an existing cohort in the cdm"
  if (is.numeric(sample)) {
    omopgenerics::assertNumeric(sample,integerish = TRUE, min = 1, length = 1, null = TRUE, call = call, msg = msg)
  } else if (is.character(sample)) {
    omopgenerics::assertCharacter(sample, length = 1, call = call, msg = msg)
  } else {
    cli::cli_abort(message = msg, call = call)
  }
  }
  return(invisible(sample))
}

