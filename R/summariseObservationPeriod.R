
#' Summarise the observation period table getting some overall statistics in a
#' summarised_result object.
#'
#' @param observationPeriod observation_period omop table
#' @param density Whether to export density data for time between observation
#' periods.
#'
#' @return A summarised_result object with the summarised data.
#'
#' @export
#'
summariseObservationPeriod <- function(observationPeriod,
                                       density = FALSE){
  # input checks
  omopgenerics::assertClass(observationPeriod, class = "omop_table")
  omopgenerics::assertTrue(
    omopgenerics::tableName(observationPeriod) == "observation_period")
  cdm <- omopgenerics::cdmReference(observationPeriod)
  omopgenerics::assertLogical(density, length = 1)

  # prepare
  obs <- observationPeriod |>
    dplyr::select(
      "person_id",
      "obs_start" = "observation_period_start_date",
      "obs_end" = "observation_period_end_date") |>
    dplyr::group_by(.data$person_id) |>
    dplyr::arrange(.data$obs_start) |>
    dplyr::mutate("next_start" = dplyr::lead(.data$obs_start)) %>%
    dplyr::mutate(
      "duration" = as.integer(!!CDMConnector::datediff("obs_start", "obs_end")) + 1L,
      "next" = as.integer(!!CDMConnector::datediff("obs_end", "next_start")),
      "id" = as.integer(dplyr::row_number())
    ) |>
    dplyr::ungroup() |>
    dplyr::select("person_id", "id", "duration", "next") |>
    dplyr::collect()

  obsSr <- obs |>
    PatientProfiles::summariseResult(
      strata = "id",
      variables = c("duration", "next"),
      estimates = estimatesObs()
    ) |>
    suppressMessages() |>
    dplyr::union_all(
      obs |>
        dplyr::group_by(.data$person_id) |>
        dplyr::tally(name = "n") |>
        PatientProfiles::summariseResult(
          variables = c("n"),
          estimates = estimatesObs(),
          counts = F
        ) |>
        suppressMessages()
    ) |>
    dplyr::filter(
      .data$variable_name != "number records" | .data$strata_level == "overall") |>
    addOrdinalLevels() |>
    dplyr::mutate("cdm_name" = omopgenerics::cdmName(cdm)) |>
    arrangeSr() |>
    dplyr::mutate(
      "strata_name" = dplyr::if_else(
        .data$strata_name == "id", "observation_period_ordinal", "overall"
      ),
      "variable_name" = dplyr::case_when(
        .data$variable_name == "n" ~ "records per person",
        .data$variable_name == "next" ~ "days to next observation period",
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
arrangeSr <- function(x) {
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
        "estimate_name" = c(estimatesObs())
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
estimatesObs <- function() {
  c("mean", "sd", "min", "q05", "q25", "median", "q75", "q95", "max")
}
