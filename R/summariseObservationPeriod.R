
#' Summarise the observation period table getting some overall statistics in a
#' summarised_result object
#'
#' @inheritParams consistent-doc
#' @param estimates Estimates to summarise the variables of interest (
#' `Records per person`, `Duration in days` and
#' `Days to next observation period`).
#' @param missingData Logical. If `TRUE`, includes a summary of missing data for
#' relevant fields.
#' @param quality Logical. If `TRUE`, performs basic data quality checks,
#' including:
#' - Number of subjects not included in person table.
#' - Number of records with end date before start date.
#' - Number of records with start date before the person's birth date.
#' @param byOrdinal Boolean variable. Whether to stratify by the ordinal
#' observation period (e.g., 1st, 2nd, etc.) (TRUE) or simply analyze overall
#' data (FALSE)
#' @inheritParams dateRange-startDate
#' @param observationPeriod deprecated.
#'
#' @return A `summarised_result` object with the results.
#' @export
#'
#' @examples
#' \donttest{
#' library(OmopSketch)
#' library(dplyr, warn.conflicts = FALSE)
#' library(omock)
#'
#' cdm <- mockCdmFromDataset(datasetName = "GiBleed", source = "duckdb")
#'
#' result <- summariseObservationPeriod(cdm = cdm)
#'
#' tableObservationPeriod(result = result)
#'
#' plotObservationPeriod(
#'   result = result,
#'   variableName = "Duration in days",
#'   plotType = "boxplot"
#' )
#'
#' cdmDisconnect(cdm = cdm)
#' }
#'
summariseObservationPeriod <- function(cdm,
                                       estimates = c(
                                         "mean", "sd", "min", "q05", "q25",
                                         "median", "q75", "q95", "max",
                                         "density"
                                       ),
                                       missingData = TRUE,
                                       quality = TRUE,
                                       byOrdinal = TRUE,
                                       ageGroup = NULL,
                                       sex = FALSE,
                                       dateRange = NULL,
                                       observationPeriod = lifecycle::deprecated()) {
  # input checks
  if (lifecycle::is_present(observationPeriod)) {
    lifecycle::deprecate_warn(
      when = "0.5.1",
      what = "summariseObservationPeriod(observationPeriod)",
      with = "summariseObservationPeriod(cdm)"
    )
    if (missing(cdm)) {
      cdm <- observationPeriod
    }
  }

  # initial checks
  if (inherits(x = cdm, what = "cdm_table")) {
    cli::cli_inform(c(i = "retrieving cdm object from {.emph cdm_table}."))
    cdm <- omopgenerics::cdmReference(table = cdm)
  }
  cdm <- omopgenerics::validateCdmArgument(cdm = cdm)
  observationPeriod <- cdm[["observation_period"]]
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

  observationPeriodStrata <- observationPeriod |>
    addSexAgeGroup(sex = sex, ageGroup = ageGroup, indexDate = start_date_name) |>
    dplyr::compute(name = omopgenerics::uniqueTableName(prefix = tablePrefix), temporary = FALSE)

  obs <- observationPeriodStrata |>
    dplyr::group_by(.data$person_id, dplyr::across(dplyr::any_of(c("sex", "age_group")))) |>
    dplyr::arrange(.data$observation_period_start_date) |>
    dplyr::mutate("next_start" = dplyr::lead(.data$observation_period_start_date)) |>
    datediffDays(start = "observation_period_start_date", end = "observation_period_end_date", name = "duration", offset = 1) |>
    datediffDays(start = "observation_period_end_date", end = "next_start", name = "next_obs") |>
    dplyr::mutate("id" = as.integer(dplyr::row_number())) |>
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

  result <- list()

  summarisedResult <- obs |>
    PatientProfiles::summariseResult(
      strata = strata,
      group = "id"[byOrdinal],
      includeOverallGroup = TRUE,
      includeOverallStrata = TRUE,
      variables = c("duration", "next_obs"),
      estimates = estimates
    ) |>
    suppressMessages() |>
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
    dplyr::filter(.data$variable_name != "number records" | .data$group_level == "all") |>
    arrangeSr(estimates) |>
    dplyr::mutate(
      "variable_name" = dplyr::case_when(
        .data$variable_name == "number records" ~ "Number records",
        .data$variable_name == "number subjects" ~ "Number subjects",
        .data$variable_name == "n" ~ "Records per person",
        .data$variable_name == "next_obs" ~ "Days to next observation period",
        .data$variable_name == "duration" ~ "Duration in days",
        .default = .data$variable_name
      )
    )


  strataType <- lapply(strata, function(x) c(x, "period_type_concept_id"))

  result$typeConcept <- observationPeriodStrata |>
    summariseCountsInternal(strata = strataType, counts = "records") |>
    dplyr::mutate(
      estimate_name = "count",
      variable_name = "Type concept id",
      period_type_concept_id = as.integer(.data$period_type_concept_id)
    ) |>
    dplyr::left_join(conceptTypes, by = c("period_type_concept_id" = "type_concept")) |>
    dplyr::mutate(type_name = dplyr::coalesce(
      .data$type_name, paste0("Unknown type concept: ", .data$period_type_concept_id)
    )) |>
    dplyr::rename(variable_level = "type_name") |>
    dplyr::select(!"period_type_concept_id")

  if (quality) {
    number_subjects <- observationPeriod |> omopgenerics::numberSubjects()
    number_subjects_no_person <- observationPeriod |>
      dplyr::anti_join(cdm$person, by = "person_id") |>
      omopgenerics::numberSubjects() |>
      as.numeric()
    result$notInPerson <- dplyr::tibble(
      count = as.character(as.integer(number_subjects_no_person)),
      percentage = sprintf("%.2f", 100 * number_subjects_no_person / number_subjects)
    ) |>
      tidyr::pivot_longer(
        cols = dplyr::everything(),
        names_to = "estimate_name",
        values_to = "estimate_value"
      ) |>
      dplyr::mutate(
        variable_name = "Subjects not in person table",
        variable_level = NA_character_,
        estimate_type = dplyr::case_when(
          .data$estimate_name == "count" ~ "integer",
          .data$estimate_name == "percentage" ~ "percentage"
        )
      )
    if (number_subjects_no_person > 0) {
      cli::cli_warn(c("!" = "There {?is/are} {number_subjects_no_person} individual{?s} not included in the person table."))
    }

    x <- observationPeriodStrata |>
      addVariables(tableName = "observation_period", quality = quality, conceptSummary = FALSE) |>
      dplyr::compute(name = omopgenerics::uniqueTableName(tablePrefix))

    result$endBeforeStart <- x |>
      dplyr::filter(.data$end_before_start == 1) |>
      summariseCountsInternal(strata = strata, counts = "records") |>
      dplyr::mutate(
        estimate_name = "count",
        variable_name = "End date before start date"
      )


    result$startBeforeBirth <- x |>
      dplyr::filter(.data$start_before_birth == 1) |>
      summariseCountsInternal(strata = strata, counts = "records") |>
      dplyr::mutate(
        estimate_name = "count",
        variable_name = "Start date before birth date"
      )
  }


  if (missingData) {
    result$missingData <- summariseMissingDataFromTable(omopTable = observationPeriodStrata, table = "observation_period", cdm = cdm, strata = strata, col = NULL, sex = FALSE, ageGroup = NULL, dateRange = NULL, interval = "overall") |>
      dplyr::mutate(
        variable_name = "Column name",
        variable_level = .data$column_name
      ) |>
      dplyr::select(!c("omop_table", "column_name"))
  }

  variables_percentage <- c("Start date before birth date", "End date before start date", "Type concept id")
  denominator <- summarisedResult |>
    dplyr::filter(.data$variable_name == "Number records" & .data$group_level == "all") |>
    dplyr::select("strata_name", "strata_level", den = "estimate_value")

  summarisedResult <- summarisedResult |> dplyr::bind_rows(
    result |> dplyr::bind_rows() |>
      omopgenerics::uniteAdditional() |>
      omopgenerics::uniteStrata(cols = strataCols(sex = sex, ageGroup = ageGroup)) |>
      dplyr::mutate(
        group_name = "observation_period_ordinal",
        group_level = "all",
        result_id = 1L
      )
  )
  summarisedResult <- summarisedResult |>
    dplyr::bind_rows(summarisedResult |>
      dplyr::filter(.data$variable_name %in% variables_percentage & .data$estimate_name == "count") |>
      dplyr::left_join(denominator, by = c("strata_name", "strata_level")) |>
      dplyr::mutate(
        estimate_value = sprintf("%.2f", 100 * as.numeric(.data$estimate_value) / as.numeric(.data$den)),
        estimate_name = "percentage",
        estimate_type = "percentage"
      ) |>
      dplyr::select(!"den")) |>
    dplyr::mutate("cdm_name" = omopgenerics::cdmName(cdm)) |>
    omopgenerics::newSummarisedResult(settings = set)

  omopgenerics::dropSourceTable(cdm, name = dplyr::starts_with(tablePrefix))

  return(summarisedResult)
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
