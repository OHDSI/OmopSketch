#' Summarise the observation period table getting some overall statistics in a
#' summarised_result object.
#'
#' @param observationPeriod observation_period omop table.
#' @param estimates Estimates to summarise the variables of interest (
#' `records per person`, `duration` and `days to next observation period`).
#'
#' @return A summarised_result object with the summarised data.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' library(OmopSketch)
#' library(dplyr)
#'
#' cdm <- mockOmopSketch()
#'
#' result <- summariseObservationPeriod(cdm$observation_period)
#'
#' result |>
#'   dplyr::glimpse()
#'
#' PatientProfiles::mockDisconnect(cdm)
#' }
#'
summariseObservationPeriod <- function(observationPeriod,
                                       estimates = c(
                                         "mean", "sd", "min", "q05", "q25",
                                         "median", "q75", "q95", "max", "density")){
  # input checks
  omopgenerics::assertClass(observationPeriod, class = "omop_table")
  omopgenerics::assertTrue(omopgenerics::tableName(observationPeriod) == "observation_period")
  cdm <- omopgenerics::cdmReference(observationPeriod)
  opts <- PatientProfiles::availableEstimates(variableType = "numeric",
                                              fullQuantiles = TRUE) |>
    dplyr::pull("estimate_name")
  omopgenerics::assertChoice(estimates, opts, unique = TRUE)

  if (omopgenerics::isTableEmpty(observationPeriod)) {
    obsSr <- observationPeriod |>
      PatientProfiles::summariseResult(
        variables = NULL, estimates = NULL, counts = TRUE)
  } else {
    # prepare
    obs <- observationPeriod |>
      filterPersonId() |>
      dplyr::select(
        "person_id",
        "obs_start" = "observation_period_start_date",
        "obs_end" = "observation_period_end_date") |>
      dplyr::group_by(.data$person_id) |>
      dplyr::arrange(.data$obs_start) |>
      dplyr::mutate("next_start" = dplyr::lead(.data$obs_start)) %>%
      dplyr::mutate(
        "duration" = as.integer(!!CDMConnector::datediff("obs_start", "obs_end")) + 1L,
        "next_obs" = as.integer(!!CDMConnector::datediff("obs_end", "next_start")),
        "id" = as.integer(dplyr::row_number())
      ) |>
      dplyr::ungroup() |>
      dplyr::select("person_id", "id", "duration", "next_obs") |>
      dplyr::collect()

    obsSr <- obs |>
      PatientProfiles::summariseResult(
        strata = "id",
        variables = c("duration", "next_obs"),
        estimates = estimates
      ) |>
      suppressMessages() |>
        dplyr::union_all(
          obs |>
            dplyr::group_by(.data$person_id) |>
            dplyr::tally(name = "n") |>
            PatientProfiles::summariseResult(
              variables = c("n"),
              estimates = estimates,
              counts = F
            ) |>
            suppressMessages()
          )|>
            dplyr::filter(
              .data$variable_name != "number records" | .data$strata_level == "overall") |>
            addOrdinalLevels() |>
            arrangeSr(estimates)
  }

  obsSr <- obsSr |>
    dplyr::mutate(
      "cdm_name" = omopgenerics::cdmName(cdm),
      "strata_name" = dplyr::if_else(
        .data$strata_name == "id", "observation_period_ordinal", "overall"
      ),
      "variable_name" = dplyr::case_when(
        .data$variable_name == "n" ~ "records per person",
        .data$variable_name == "next_obs" ~ "days to next observation period",
        .data$variable_name == "duration" ~ "duration in days",
        .default = .data$variable_name
      )
    ) |>
    omopgenerics::newSummarisedResult(settings = dplyr::tibble(
      "result_id" = 1L,
      "result_type" = "summarise_observation_period",
      "package_name" = "OmopSketch",
      "package_version" = as.character(utils::packageVersion("OmopSketch"))
    ))

  return(obsSr)
}

addOrdinalLevels <- function(x) {
  xx <- suppressWarnings(as.integer(x$strata_level))
  desena <- (floor(xx/10)) %% 10
  unitat <- xx %% 10
  val <- rep("overall", length(xx))
  id0 <- !is.na(xx)
  val[id0] <- paste0(xx[id0], "th")
  id <- id0 & desena != 1L & unitat == 1L
  val[id] <- paste0(xx[id], "st")
  id <- id0 & desena != 1L & unitat == 2L
  val[id] <- paste0(xx[id], "nd")
  id <- id0 & desena != 1L & unitat == 3L
  val[id] <- paste0(xx[id], "rd")
  x$strata_level <- val
  return(x)
}
arrangeSr <- function(x, estimates) {
  lev <- x$strata_level |> unique()
  lev <- c("overall", sort(lev[lev != "overall"]))
  order <- dplyr::tibble(
    "variable_name" = c("number records"),
    "strata_level" = "overall",
    "estimate_name" = "count"
  ) |>
    dplyr::union_all(
      tidyr::expand_grid(
        "variable_name" = c("number subjects"),
        "strata_level" = lev,
        "estimate_name" = "count"
      )
    ) |>
    dplyr::union_all(
      tidyr::expand_grid(
        "strata_level" = lev,
        "variable_name" = c("n", "duration", "next"),
        "estimate_name" = estimates
      )
    ) |>
    dplyr::left_join(
      dplyr::tibble("strata_level" = lev) |>
        dplyr::mutate("order_lev" = dplyr::row_number()),
      by = "strata_level"
    ) |>
    dplyr::left_join(
      dplyr::tibble("variable_name" = c(
        "number records", "number subjects", "n", "duration", "next"
      )) |>
        dplyr::mutate("order_var" = dplyr::row_number()),
      by = "variable_name"
    ) |>
    dplyr::arrange(.data$order_lev, .data$order_var) |>
    dplyr::select(!c("order_lev", "order_var")) |>
    dplyr::mutate("order_id" = dplyr::row_number())
  x <- x |>
    dplyr::left_join(
      order, by = c("variable_name", "strata_level", "estimate_name")) |>
    dplyr::arrange(.data$order_id) |>
    dplyr::select(-"order_id")
  return(x)
}
