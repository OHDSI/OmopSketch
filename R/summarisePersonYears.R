
#' Summarise the person years that a cdm contains. You can stratify by ageGroup,
#' year and sex.
#'
#' @param cdm A cdm_reference object.
#' @param ageGroup A list of age groups to be considered.
#' @param byYear Whether to stratify the counts by year.
#' @param bySex Whether to stratify the counts by sex.
#'
#' @return A summarised_result object that contains the number of person year
#' for each of the desired stratifications.
#'
#' @export
#'
summarisePersonDays  <- function(cdm,
                                  ageGroup = NULL,
                                  byYear = FALSE,
                                  bySex = FALSE) {
  # check input
  checkmate::assertClass(cdm, "cdm_reference")
  checkmate::assertLogical(byYear, any.missing = FALSE, len = 1)
  checkmate::assertLogical(bySex, any.missing = FALSE, len = 1)

  prefix <- omopgenerics::tmpPrefix()
  tmp1 <- omopgenerics::uniqueTableName(prefix = prefix)
  if (is.null(ageGroup)) ageGroup <- list(c(0, 150))

  # create denominator cohort
  cdm <- IncidencePrevalence::generateDenominatorCohortSet(
    cdm = cdm, name = tmp1, ageGroup = ageGroup, sex = "Both",
    daysPriorObservation = 0, requirementInteractions = TRUE
  )

  set <- omopgenerics::settings(cdm[[tmp1]]) |>
    dplyr::select("cohort_definition_id", "age_group")
  tmp2 <- omopgenerics::uniqueTableName(prefix = prefix)
  cdm <- omopgenerics::insertTable(cdm = cdm, name = tmp2, table = set)
  cdm[[tmp1]] <- cdm[[tmp1]] |>
    dplyr::inner_join(cdm[[tmp2]], by = "cohort_definition_id") |>
    dplyr::compute(name = tmp1, temporary = FALSE)

  # results by age group
  result <- cdm[[tmp1]] |> summaryFollowUp(strata = c("age_group"))

  # results by sex
  if (bySex == TRUE) {
    cdm[[tmp1]] <- cdm[[tmp1]] |>
      PatientProfiles::addSex()
    result <- result |>
      dplyr::bind_rows(
        cdm[[tmp1]] |> summaryFollowUp(strata = c("age_group", "sex"))
      )
  }

  if (byYear == TRUE) {
    result <- result |> dplyr::bind_rows(strataByYear(cdm[[tmp1]], bySex))
  }

  # tidy result
  if (byYear) {
    result <- result |> dplyr::mutate("year" = dplyr::if_else(
      is.na(.data$year), "overall", as.character(.data$year)
    ))
  } else {
    result <- result |> dplyr::mutate("year" = "overall")
  }
  if (bySex) {
    result <- result |> dplyr::mutate("sex" = dplyr::if_else(
      is.na(.data$sex), "overall", as.character(.data$sex)
    ))
  } else {
    result <- result |> dplyr::mutate("sex" = "overall")
  }

  result <- result |>
    tidyr::pivot_longer(
      cols = !dplyr::any_of(c("age_group", "sex", "year")),
      values_to = "estimate_value"
    ) |>
    tidyr::separate_wider_delim(
      cols = "name", delim = "_", too_many = "merge",
      names = c("estimate_name", "variable_name")
    ) |>
    dplyr::mutate("age_group" = dplyr::if_else(
      .data$age_group == "0 to 150", "overall", .data$age_group
    ))

  result <- result |>
    visOmopResults::uniteStrata(cols = c("age_group", "sex", "year"))|>
    dplyr::mutate(
      "cdm_name" = omopgenerics::cdmName(cdm),
      "result_type" = "summarised_person_days",
      "package_name" = "OmopSketch",
      "package_version" = as.character(utils::packageVersion("OmopSketch")),
      "group_name" = "population",
      "group_level" = "overall",
      "variable_level" = NA_character_,
      "estimate_type" = dplyr::if_else(
        .data$estimate_name %in% c("count", "min", "max", "total"), "integer",
        "numeric"
      ),
      "estimate_value" = as.character(.data$estimate_value),
      "additional_name" = "overall",
      "additional_level" = "overall"
    ) |>
    omopgenerics::newSummarisedResult()

  return(result)
}

strataByYear <- function(cohort, bySex) {
  years <- cohort |>
    dplyr::summarise(
      min = min(.data$cohort_start_date, na.rm = TRUE),
      max = max(.data$cohort_end_date, na.rm = TRUE)
    ) |>
    dplyr::collect() |>
    dplyr::mutate(
      min = lubridate::year(.data$min), max = lubridate::year(.data$max)
    )
  years <- seq(years$min, years$max, by = 1)
  result <- list()
  for (k in seq_along(years)) {
    x <- cohort |> correctCohort(years[[k]])
    res <- x |> summaryFollowUp(strata = "age_group")
    if (bySex) {
      res <- res |>
        dplyr::bind_rows(
          x |> summaryFollowUp(strata = c("age_group", "sex"))
        )
    }
    result[[k]] <- res |> dplyr::mutate("year" = .env$years[[k]])
  }
  result <- dplyr::bind_rows(result)
  return(result)
}
correctCohort <- function(cohort, year) {
  startDate <- as.Date(paste0(year, "/01/01"))
  endDate <- as.Date(paste0(year, "/12/31"))
  cohort |>
    dplyr::mutate(
      "cohort_start_date" = dplyr::if_else(
        .data$cohort_start_date <= .env$startDate,
        .env$startDate,
        .data$cohort_start_date
      ),
      "cohort_end_date" = dplyr::if_else(
        .data$cohort_end_date >= .env$endDate,
        .env$endDate,
        .data$cohort_end_date
      )
    ) |>
    dplyr::filter(.data$cohort_start_date <= .data$cohort_end_date)
}
summaryFollowUp <- function(cohort, strata) {
  x <- cohort %>%
    dplyr::mutate("person_days" = as.numeric(!!CDMConnector::datediff(
      start = "cohort_start_date", end = "cohort_end_date", interval = "day"
    )) + 1) %>%
    dplyr::select(dplyr::any_of(c(
      "age_group", "sex", "year", "subject_id", "person_days"
    ))) |>
    dplyr::collect()
  if (nrow(x) > 0) {
    res <- x |>
      dplyr::group_by(dplyr::across(dplyr::all_of(strata))) |>
      dplyr::summarise(
        "count_number_subjects" = dplyr::n_distinct(.data$subject_id),
        "count_number_records" = dplyr::n(),
        "min_person_days" = min(.data$person_days, na.rm = TRUE),
        "q25_person_days" = quantile(.data$person_days, probs = 0.25, na.rm = TRUE),
        "median_person_days" = median(.data$person_days, na.rm = TRUE),
        "q75_person_days" = quantile(.data$person_days, probs = 0.75, na.rm = TRUE),
        "max_person_days" = max(.data$person_days, na.rm = TRUE),
        "total_person_days" = sum(.data$person_days, na.rm = TRUE),
        .groups = "drop"
      )
  } else {
    res <- dplyr::tibble()
  }
  return(res)
}
