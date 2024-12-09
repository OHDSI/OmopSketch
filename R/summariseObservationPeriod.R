#' Summarise the observation period table getting some overall statistics in a
#' summarised_result object.
#'
#' @param observationPeriod observation_period omop table.
#' @param estimates Estimates to summarise the variables of interest (
#' `records per person`, `duration in days` and
#' `days to next observation period`).
#' @param ageGroup A list of age groups to stratify results by.
#' @param sex Boolean variable. Whether to stratify by sex (TRUE) or not
#' (FALSE).
#' @param dateRange A list containing the minimum and the maximum dates
#' defining the time range within which the analysis is performed.
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
#' result <- summariseObservationPeriod(cdm$observation_period)
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
                                         "density"),
                                       ageGroup = NULL,
                                       sex = FALSE,
                                       dateRange = NULL) {
  # input checks
  omopgenerics::assertClass(observationPeriod, class = "omop_table")
  omopgenerics::assertTrue(omopgenerics::tableName(observationPeriod) == "observation_period")
  omopgenerics::assertLogical(sex)
  ageGroup <- omopgenerics::validateAgeGroupArgument(ageGroup, ageGroupName = "")[[1]]
  cdm <- omopgenerics::cdmReference(observationPeriod)
  dateRange <- validateStudyPeriod(cdm, dateRange)
  opts <- PatientProfiles::availableEstimates(variableType = "numeric",
                                              fullQuantiles = TRUE) |>
    dplyr::pull("estimate_name")
  omopgenerics::assertChoice(estimates, opts, unique = TRUE)
  tablePrefix <-  omopgenerics::tmpPrefix()
  strata   <- getStrataList(sex, ageGroup)
  strataId <- c(list("id"),  strata |> purrr::map(\(x) c("id", x)))

  if (omopgenerics::isTableEmpty(observationPeriod)) {
    obsSr <- observationPeriod |>
      # dplyr::collect() |> # https://github.com/darwin-eu-dev/PatientProfiles/issues/706
      PatientProfiles::summariseResult(
        variables = NULL, estimates = NULL, counts = TRUE)
  } else {

    # prepare

    obs <- addStrataToPeopleInObservation(cdm, ageGroup, sex, tablePrefix, dateRange) |>
      filterPersonId() |>
      dplyr::select(
        "person_id", dplyr::any_of(c("sex","age_group")),
        "obs_start" = "observation_period_start_date",
        "obs_end" = "observation_period_end_date") |>
      dplyr::group_by(.data$person_id, dplyr::across(dplyr::any_of(c("sex","age_group")))) |>
      dplyr::arrange(.data$obs_start) |>
      dplyr::mutate("next_start" = dplyr::lead(.data$obs_start)) %>%
      dplyr::mutate(
        "duration" = as.integer(!!CDMConnector::datediff("obs_start", "obs_end")) + 1L,
        "next_obs" = as.integer(!!CDMConnector::datediff("obs_end", "next_start")),
        "id" = as.integer(dplyr::row_number())
      ) |>
      dplyr::ungroup() |>
      dplyr::select("person_id", "id", "duration", "next_obs", dplyr::any_of(c("sex","age_group"))) |>
      dplyr::collect()
   if (dim(obs)[1]==0){
     return(omopgenerics::emptySummarisedResult()|>omopgenerics::newSummarisedResult(
       settings = createSettings(result_type = "summarise_observation_period", study_period = dateRange)))
   }
    obsSr <- obs |>
      # dplyr::collect() |> # https://github.com/darwin-eu-dev/PatientProfiles/issues/706
      PatientProfiles::summariseResult(
        strata = strataId,
        variables = c("duration", "next_obs"),
        estimates = estimates
      ) |>
      suppressMessages() |>
        dplyr::union_all(
          obs |>
            dplyr::group_by(.data$person_id, dplyr::across(dplyr::any_of(c("sex","age_group")))) |>
            dplyr::tally(name = "n") |>
            dplyr::ungroup() |>
            # dplyr::collect() |> # https://github.com/darwin-eu-dev/PatientProfiles/issues/706
            PatientProfiles::summariseResult(
              variables = c("n"),
              estimates = estimates,
              counts = F,
              strata = strata
            ) |>
            suppressMessages()
          ) |>
            dplyr::filter(.data$variable_name != "number records" | .data$strata_level == "overall") |>
            addOrdinalLevels() |>
            arrangeSr(estimates)
  }

  obsSr <- obsSr |>
    dplyr::mutate(
      "cdm_name" = omopgenerics::cdmName(cdm),
      "variable_name" = dplyr::case_when(
        .data$variable_name == "n" ~ "records per person",
        .data$variable_name == "next_obs" ~ "days to next observation period",
        .data$variable_name == "duration" ~ "duration in days",
        .default = .data$variable_name
      )
    ) |>
    omopgenerics::newSummarisedResult(
      settings = createSettings(result_type = "summarise_observation_period", study_period = dateRange))


  return(obsSr)
}

addOrdinalLevels <- function(x) {
  strata_cols <- omopgenerics::strataColumns(x)
  strata_cols <- strata_cols[strata_cols != "id"]

  x <- x |>
    omopgenerics::splitStrata()
  xx <- suppressWarnings(as.integer(x$id))
  desena <- (floor(xx/10)) %% 10
  unitat <- xx %% 10
  val <- rep("overall_", length(xx))
  id0 <- !is.na(xx)
  val[id0] <- paste0(xx[id0], "th")
  id <- id0 & desena != 1L & unitat == 1L
  val[id] <- paste0(xx[id], "st")
  id <- id0 & desena != 1L & unitat == 2L
  val[id] <- paste0(xx[id], "nd")
  id <- id0 & desena != 1L & unitat == 3L
  val[id] <- paste0(xx[id], "rd")

  x <- x |>
    dplyr::mutate("group_level" = .env$val) |>
    dplyr::select(-c("id")) |>
    dplyr::mutate("group_name" = "observation_period_ordinal") |>
    omopgenerics::uniteStrata(cols = strata_cols)

  return(x)
}

arrangeSr <- function(x, estimates) {
  lev <- x$strata_level |> unique()
  lev <- c("overall", sort(lev[lev != "overall"]))

  group <- x$group_level |> unique()
  group <- c("overall", sort(group[group != "overall"]))

  order <- dplyr::tibble(
    "variable_name" = c("number records"),
    "group_level"   = "overall_",
    "strata_level"  = "overall",
    "estimate_name" = "count"
  ) |>
    dplyr::union_all(
      tidyr::expand_grid(
        "variable_name" = c("number subjects"),
        "group_level"   = group,
        "strata_level"  = lev,
        "estimate_name" = "count"
      )
    ) |>
    dplyr::union_all(
      tidyr::expand_grid(
        "variable_name" = c("n", "duration", "next_obs"),
        "group_level"   = group,
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
        "number records", "number subjects", "n", "duration", "next_obs"
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
