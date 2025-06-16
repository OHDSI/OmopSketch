#' Summarise the observation period table getting some overall statistics in a
#' summarised_result object.
#'
#' @param observationPeriod observation_period omop table.
#' @param estimates Estimates to summarise the variables of interest (
#' `records per person`, `duration in days` and
#' `days to next observation period`).
#' @param byOrdinal Boolean variable. Whether to stratify by the ordinal observation period (e.g., 1st, 2nd, etc.) (TRUE) or simply analyze overall data (FALSE)
#' @param ageGroup A list of age groups to stratify results by.
#' @param sex Boolean variable. Whether to stratify by sex (TRUE) or not
#' (FALSE).
#' @inheritParams dateRange-startDate
#'
#' @return A summarised_result object with the summarised data.
#'
#' @export
#'
#' @examples
#' \donttest{
#' library(dplyr, warn.conflicts = FALSE)
#'
#' cdm <- mockOmopSketch(numberIndividuals = 100)
#'
#' result <- summariseObservationPeriod(observationPeriod = cdm$observation_period)
#'
#' result |>
#'   glimpse()
#'
#' PatientProfiles::mockDisconnect(cdm)
#' }
summariseObservationPeriod <- function(observationPeriod,
                                       estimates = c(
                                         "mean", "sd", "min", "q05", "q25",
                                         "median", "q75", "q95", "max",
                                         "density"
                                       ),
                                       byOrdinal = TRUE,
                                       ageGroup = NULL,
                                       sex = FALSE,
                                       dateRange = NULL) {
  # input checks

  omopgenerics::validateCdmTable(observationPeriod)
  cdm <- omopgenerics::cdmReference(observationPeriod)
  omopgenerics::assertTable(observationPeriod, class = "cdm_table",
                            columns = omopgenerics::omopColumns(table = "observation_period", version = omopgenerics::cdmVersion(cdm)))
  omopgenerics::assertLogical(sex)
  ageGroup <- omopgenerics::validateAgeGroupArgument(ageGroup)
  dateRange <- validateStudyPeriod(cdm, dateRange)
  opts <- PatientProfiles::availableEstimates(
    variableType = "numeric", fullQuantiles = TRUE
  ) |>
    dplyr::pull("estimate_name")
  omopgenerics::assertChoice(estimates, opts, unique = TRUE)
  omopgenerics::assertLogical(byOrdinal)


  tablePrefix <- omopgenerics::tmpPrefix()

  strata <- c(list(character()), omopgenerics::combineStrata(strataCols(sex = sex, ageGroup = ageGroup)))

  set <- createSettings(result_type = "summarise_observation_period", study_period = dateRange)

  if (omopgenerics::isTableEmpty(observationPeriod)) {
    return(omopgenerics::emptySummarisedResult(settings = set))
  }


  start_date_name <- omopgenerics::omopColumns(table = "observation_period", field = "start_date")

  observationPeriod <- observationPeriod |>
    trimStudyPeriod(dateRange = dateRange)

  if (is.null(observationPeriod)) {
    return(omopgenerics::emptySummarisedResult(settings = set))
  }

  obs <- observationPeriod |>
    addSexAgeGroup(sex = sex, ageGroup = ageGroup, indexDate = start_date_name) |>
    dplyr::compute(name = omopgenerics::uniqueTableName(prefix = tablePrefix), temporary = FALSE) |>
    dplyr::select(
      "person_id", dplyr::any_of(c("sex", "age_group")),
      "obs_start" = "observation_period_start_date",
      "obs_end" = "observation_period_end_date"
    ) |>
    dplyr::group_by(.data$person_id, dplyr::across(dplyr::any_of(c("sex", "age_group")))) |>
    dplyr::arrange(.data$obs_start) |>
    dplyr::mutate("next_start" = dplyr::lead(.data$obs_start)) %>%
    dplyr::mutate(
      "duration" = as.integer(!!CDMConnector::datediff("obs_start", "obs_end")) + 1L,
      "next_obs" = as.integer(!!CDMConnector::datediff("obs_end", "next_start")),
      "id" = as.integer(dplyr::row_number())
    ) |>
    dplyr::ungroup() |>
    dplyr::select("person_id", "id", "duration", "next_obs", dplyr::any_of(c("sex", "age_group"))) |>
    dplyr::collect()
  if (all(is.na(obs$next_obs))) {
    obs <- obs |>
      dplyr::select(!"next_obs")
  }

  if (dim(obs)[1] == 0) {
    return(omopgenerics::emptySummarisedResult(settings = set))
  }

  obsSr <- obs |>
    PatientProfiles::summariseResult(
      strata = strata,
      group = "id"[byOrdinal],
      includeOverallGroup = TRUE,
      includeOverallStrata = TRUE,
      variables = c("duration", "next_obs"),
      estimates = estimates
    ) |>
    suppressMessages() |>
    dplyr::mutate(variable_name = dplyr::if_else(.data$variable_name == "number records", "Number records",
      dplyr::if_else(.data$variable_name == "number subjects", "Number subjects", .data$variable_name)
    )) |>
    dplyr::union_all(
      obs |>
        dplyr::group_by(.data$person_id, dplyr::across(dplyr::any_of(c("sex", "age_group")))) |>
        dplyr::tally(name = "n") |>
        dplyr::ungroup() |>
        PatientProfiles::summariseResult(
          variables = c("n"),
          estimates = estimates,
          counts = F,
          strata = strata
        ) |>
        suppressMessages()
    ) |>
    addOrdinalLevels(byOrdinal = byOrdinal) |>
    dplyr::filter(.data$variable_name != "Number records" | .data$group_level == "all") |>
    arrangeSr(estimates)

  obsSr <- obsSr |>
    dplyr::mutate(
      "cdm_name" = omopgenerics::cdmName(cdm),
      "variable_name" = dplyr::case_when(
        .data$variable_name == "n" ~ "Records per person",
        .data$variable_name == "next_obs" ~ "Days to next observation period",
        .data$variable_name == "duration" ~ "Duration in days",
        .default = .data$variable_name
      )
    ) |>
    omopgenerics::newSummarisedResult(settings = set)

  omopgenerics::dropSourceTable(cdm, name = dplyr::starts_with(tablePrefix))

  return(obsSr)
}

addOrdinalLevels <- function(x, byOrdinal) {
  if (byOrdinal) {
    group_cols <- omopgenerics::groupColumns(x)
    x <- x |> omopgenerics::splitGroup()

    xx <- suppressWarnings(as.integer(x$id))
    desena <- (floor(xx / 10)) %% 10
    unitat <- xx %% 10
    val <- rep("all", length(xx))
    id0 <- !is.na(xx)
    val[id0] <- paste0(xx[id0], "th")
    id <- id0 & desena != 1L & unitat == 1L
    val[id] <- paste0(xx[id], "st")
    id <- id0 & desena != 1L & unitat == 2L
    val[id] <- paste0(xx[id], "nd")
    id <- id0 & desena != 1L & unitat == 3L
    val[id] <- paste0(xx[id], "rd")

    x <- x |>
      dplyr::mutate(
        "group_level" = .env$val,
        "group_name" = "observation_period_ordinal"
      ) |>
      dplyr::select(-c("id"))
  } else {
    x <- x |>
      dplyr::mutate(
        "group_level" = "all",
        "group_name" = "observation_period_ordinal"
      )
  }
  return(x)
}
arrangeSr <- function(x, estimates) {
  lev <- x$strata_level |> unique()
  lev <- c("overall", sort(lev[lev != "overall"]))

  group <- x$group_level |> unique()
  group <- c("all", sort(group[group != "all"]))

  order <- dplyr::tibble(
    "variable_name" = c("Number records"),
    "group_level"   = "all",
    "strata_level"  = lev,
    "estimate_name" = "count"
  ) |>
    dplyr::union_all(
      tidyr::expand_grid(
        "variable_name" = c("Number subjects"),
        "group_level"   = group,
        "strata_level"  = lev,
        "estimate_name" = "count"
      )
    ) |>
    dplyr::union_all(
      tidyr::expand_grid(
        "variable_name" = c("n", "duration", "next_obs"),
        "group_level" = group,
        "strata_level" = lev,
        "estimate_name" = estimates
      )
    ) |>
    dplyr::left_join(
      dplyr::tibble("group_level" = group) |>
        dplyr::mutate("order_group" = dplyr::row_number()),
      by = "group_level"
    ) |>
    dplyr::left_join(
      dplyr::tibble("strata_level" = lev) |>
        dplyr::mutate("order_lev" = dplyr::row_number()),
      by = "strata_level"
    ) |>
    dplyr::left_join(
      dplyr::tibble("variable_name" = c(
        "Number records", "Number subjects", "n", "duration", "next_obs"
      )) |>
        dplyr::mutate("order_var" = dplyr::row_number()),
      by = "variable_name"
    ) |>
    dplyr::arrange(.data$order_group, .data$order_lev, .data$order_var) |>
    dplyr::select(!c("order_group", "order_lev", "order_var")) |>
    dplyr::mutate("order_id" = dplyr::row_number())

  x <- x |>
    dplyr::left_join(order, by = c("variable_name", "group_level", "strata_level", "estimate_name")) |>
    dplyr::arrange(.data$order_id) |>
    dplyr::select(-"order_id")

  return(x)
}
