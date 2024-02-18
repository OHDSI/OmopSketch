
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
summarisePersonYears  <- function(cdm,
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

  if (bySex == TRUE) {
    cdm[[tmp1]] <- cdm[[tmp1]] |>
      PatientProfiles::addSex()
  }

  strata <- c("age_group", "sex")[c(TRUE, bySex)]
  result <- cdm[[tmp1]] %>%
    dplyr::mutate("person_days" = as.numeric(!!CDMConnector::datediff(
      start = "cohort_start_date", end = "cohort_end_date", interval = "day"
    )) + 1) %>%
    dplyr::select(dplyr::any_of(c(strata, "subject_id", "person_days"))) |>
    dplyr::collect() |>
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
    ) |>
    tidyr::pivot_longer(
      cols = !dplyr::any_of(strata), values_to = "estimate_value"
    )

  if (byYear == TRUE) {
    cdm[[tmp1]] <- strataByYear(cdm[[tmp1]])
    strata <- c(strata, "year")
  }

  tidyr::separate_wider_delim(
    cols = "name", delim = "_", too_many = "merge",
    names = c("estimate_name", "variable_name")
  )


  # number individuals
  # observatio periods

  # counts
}

strataByYear <- function(cohort) {
  cdm <- omopgenerics::cdmReference(cohort)
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
  prefix <- omopgenerics::tmpPrefix()
  myCohorts <- list()
  for (k in seq_along(years)) {
    startDate <- as.Date(paste0("01/01/", years[[k]]))
    endDate <- as.Date(paste0("31/12/", years[[k]]))
    myCohorts[[k]] <- cohort |>
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
        ),
        "year" = .env$year
      ) |>
      dplyr::filter(.data$cohort_start_date <= .data$cohort_end_date) |>
      dplyr::compute(
        name = omopgenerics::uniqueTableName(prefix = prefix), temporary = FALSE
      )
  }
  cdm <- omopgenerics::dropTable(cdm = cdm, name = dplyr::starts_with(prefix))
}
