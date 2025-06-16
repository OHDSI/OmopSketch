#' Summarise concept counts in patient-level data. Only concepts recorded during observation period are counted.
#'
#' @param cdm A cdm object
#' @param conceptSet List of concept IDs to summarise.
#' @param countBy Either "record" for record-level counts or "person" for
#' person-level counts
#' @param concept TRUE or FALSE. If TRUE code use will be summarised by concept.
#' @inheritParams interval
#' @param sex TRUE or FALSE. If TRUE code use will be summarised by sex.
#' @param ageGroup A list of ageGroup vectors of length two. Code use will be
#' thus summarised by age groups.
#' @inheritParams dateRange-startDate
#' @return A summarised_result object with results overall and, if specified, by
#' strata.
#' @export
#' @examples
#' \donttest{
#' library(OmopSketch)
#'
#' cdm <- mockOmopSketch()
#'
#' cs <- list(sinusitis = c(4283893, 257012, 40481087, 4294548))
#'
#' results <- summariseConceptSetCounts(cdm, conceptSet = cs)
#'
#' results
#'
#' PatientProfiles::mockDisconnect(cdm)
#' }
summariseConceptSetCounts <- function(cdm,
                                      conceptSet,
                                      countBy = c("record", "person"),
                                      concept = TRUE,
                                      interval = "overall",
                                      sex = FALSE,
                                      ageGroup = NULL,
                                      dateRange = NULL) {
  lifecycle::deprecate_warn(
    when = "0.5.0",
    what = "summariseConceptSetCounts()",
    with = NULL
  )
  # initial check
  cdm <- omopgenerics::validateCdmArgument(cdm)
  omopgenerics::assertChoice(countBy, choices = c("record", "person"))
  omopgenerics::assertChoice(interval, c("overall", "years", "quarters", "months"), length = 1)
  omopgenerics::assertLogical(concept, length = 1)
  omopgenerics::assertLogical(sex, length = 1)
  ageGroup <- omopgenerics::validateAgeGroupArgument(ageGroup)
  dateRange <- validateStudyPeriod(cdm, dateRange)
  conceptSet <- omopgenerics::validateConceptSetArgument(conceptSet = conceptSet)

  countBy[countBy == "record"] <- "records"
  countBy[countBy == "person"] <- "person_id"

  prefix <- omopgenerics::tmpPrefix()

  # settings
  set <- createSettings(
    result_type = "summarise_concept_set_counts", study_period = dateRange
  )

  # conceptTibble
  nm <- omopgenerics::uniqueTableName(prefix)
  conceptTibble <- conceptSet |>
    purrr::imap(\(x, nm) dplyr::tibble(standard_concept_id = x, codelist_name = nm)) |>
    dplyr::bind_rows()
  cdm <- omopgenerics::insertTable(cdm = cdm, name = nm, table = conceptTibble)

  # strata
  strata <- c(
    list(character()),
    omopgenerics::combineStrata(strataCols(sex = sex, ageGroup = ageGroup, interval = interval))
  ) |>
    purrr::map(\(x) c("codelist_name", x))
  if (concept) {
    colsConcept <- c(
      "standard_concept_name", "standard_concept_id", "source_concept_name",
      "source_concept_id", "domain_id"
    )
    strata <- c(strata, purrr::map(strata, \(x) c(colsConcept, x)))
    additional <- c(colsConcept, "time_interval")
  } else {
    additional <- "time_interval"
  }

  # assert domains
  cdm[[nm]] <- cdm[[nm]] |>
    dplyr::left_join(
      cdm[["concept"]] |>
        dplyr::select(
          standard_concept_id = "concept_id",
          standard_concept_name = "concept_name",
          "domain_id"
        ),
      by = "standard_concept_id"
    ) |>
    dplyr::mutate(domain_id = stringr::str_to_lower(.data$domain_id)) |>
    dplyr::compute(name = nm, temporary = FALSE)
  domains <- cdm[[nm]] |>
    dplyr::group_by(.data$domain_id) |>
    dplyr::tally() |>
    dplyr::collect() |>
    warnUnsupported()

  # if empty
  if (nrow(domains) == 0) {
    return(omopgenerics::emptySummarisedResult(settings = set))
  }

  # merge tables
  result <- purrr::map(domains$domain_id, \(x) {
    table <- domainsTibble$table[domainsTibble$domain_id == x]
    c("i" = "Searching concepts from domain {.pkg {x}} in {.pkg {table}}.") |>
      cli::cli_inform()
    columns <- c(
      "person_id",
      index_date = omopgenerics::omopColumns(table = table, field = "start_date"),
      standard_concept_id = omopgenerics::omopColumns(table = table, field = "standard_concept"),
      source_concept_id = omopgenerics::omopColumns(table = table, field = "source_concept")
    )
    omopTable <- dplyr::ungroup(cdm[[table]])

    # restrict study period
    omopTable <- restrictStudyPeriod(omopTable, dateRange)
    if (is.null(omopTable)) {
      return(NULL)
    }

    res <- omopTable |>
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
      dplyr::select(!!columns) |>
      dplyr::inner_join(
        cdm[[nm]] |>
          dplyr::filter(.data$domain_id == .env$x) |>
          dplyr::select(
            "standard_concept_id", "codelist_name", "standard_concept_name",
            "domain_id"
          ),
        by = "standard_concept_id"
      )
    if (concept) {
      res <- res |>
        dplyr::left_join(
          cdm[["concept"]] |>
            dplyr::select(
              source_concept_id = "concept_id",
              source_concept_name = "concept_name"
            ),
          by = "source_concept_id"
        )
    }
    res |>
      addStratifications(
        indexDate = "index_date",
        sex = sex,
        ageGroup = ageGroup,
        interval = interval,
        intervalName = "interval",
        name = omopgenerics::uniqueTableName(prefix)
      )
  }) |>
    purrr::compact()

  if (length(result) == 0) {
    return(omopgenerics::emptySummarisedResult(settings = set))
  }

  result <- result |>
    purrr::reduce(dplyr::union_all) |>
    dplyr::compute(name = omopgenerics::uniqueTableName(prefix), temporary = FALSE)

  # counts
  cli::cli_inform(c("i" = "Counting concepts"))
  result <- summariseCountsInternal(result, strata = strata, counts = countBy)

  omopgenerics::dropSourceTable(cdm = cdm, name = dplyr::starts_with(prefix))

  # format output
  result |>
    omopgenerics::uniteGroup(cols = "codelist_name") |>
    omopgenerics::uniteStrata(cols = c(names(ageGroup), "sex"[sex])) |>
    addTimeInterval() |>
    omopgenerics::uniteAdditional(cols = additional) |>
    dplyr::mutate(
      result_id = 1L,
      cdm_name = omopgenerics::cdmName(cdm),
      variable_name = dplyr::if_else(
        .data$estimate_name == "count_records", "Number records", "Number subjects"
      ),
      variable_level = NA_character_,
      estimate_name = "count"
    ) |>
    omopgenerics::newSummarisedResult(settings = set)
}

warnUnsupported <- function(domains) {
  unsupported <- domains |>
    dplyr::filter(!.data$domain_id %in% .env$domainsTibble$domain_id)
  if (nrow(unsupported) > 0) {
    c("Not supported domain: {.pkg [unsupported$domain_id]} [unsupported$n] concepts.") |>
      glue::glue(.open = "[", .close = "]") |>
      rlang::set_names("x") |>
      cli::cli_warn()
  }
  domains |>
    dplyr::filter(.data$domain_id %in% .env$domainsTibble$domain_id)
}
