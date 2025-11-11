#' Summarise concept use in patient-level data
#'
#' Only concepts recorded during observation period are counted.
#'
#' @inheritParams consistent-doc
#' @param countBy Either "record" for record-level counts or "person" for
#' person-level counts.
#' @param inObservation Logical. If `TRUE`, the results are stratified to
#' indicate whether each record occurs within an observation period.
#' @inheritParams dateRange-startDate
#' @param year deprecated.
#'
#' @return A `summarised_result` object with the results.
#' @export
#'
#' @examples
#' \donttest{
#' library(OmopSketch)
#' library(omock)
#'
#' cdm <- mockCdmFromDataset(datasetName = "GiBleed", source = "duckdb")
#'
#' result <- summariseConceptIdCounts(
#'   cdm = cdm,
#'   omopTableName = "condition_occurrence",
#'   countBy = c("record", "person"),
#'   sex = TRUE
#' )
#'
#' tableConceptIdCounts(result = result)
#'
#' cdmDisconnect(cdm = cdm)
#' }
#'
summariseConceptIdCounts <- function(cdm,
                                     omopTableName,
                                     countBy = "record",
                                     interval = "overall",
                                     sex = FALSE,
                                     ageGroup = NULL,
                                     inObservation = FALSE,
                                     sample = NULL,
                                     dateRange = NULL,
                                     year = lifecycle::deprecated()) {
  if (lifecycle::is_present(year)) {
    lifecycle::deprecate_warn("0.2.3", "summariseConceptIdCounts(year)", "summariseConceptIdCounts(interval = 'years')")

    if (isTRUE(year) & missing(interval)) {
      interval <- "years"
      cli::cli_inform(c(i = "interval argument set to 'years'"))
    } else if (isTRUE(year) & !missing(interval)) {
      cli::cli_inform(c(i = "year argument will be ignored"))
    }
  }

  # initial checks
  cdm <- omopgenerics::validateCdmArgument(cdm)
  omopgenerics::assertChoice(countBy, choices = c("record", "person"))
  omopgenerics::assertChoice(interval, c("overall", "years", "quarters", "months"), length = 1)
  omopgenerics::assertLogical(sex, length = 1)
  omopgenerics::assertChoice(omopTableName, choices = clinicalTables(), unique = TRUE)
  ageGroup <- omopgenerics::validateAgeGroupArgument(ageGroup = ageGroup)
  dateRange <- validateStudyPeriod(cdm = cdm, studyPeriod = dateRange)

  sample <- validateSample(sample = sample)

  omopgenerics::assertLogical(inObservation, length = 1)

  # settings for the created results
  set <- createSettings(result_type = "summarise_concept_id_counts", study_period = dateRange)
  cdm <- sampleCdm(cdm = cdm, tables = omopTableName, sample = sample)
  # get strata
  strata <- omopgenerics::combineStrata(strataCols(sex = sex, ageGroup = ageGroup, interval = interval, inObservation = inObservation))
  concepts <- c("concept_id", "concept_name", "source_concept_id", "source_concept_name")
  stratax <- c(list(concepts), purrr::map(strata, \(x) c(concepts, x)))
  additional <- c("time_interval", "source_concept_id", "source_concept_name")
  # how to count
  counts <- c("records", "person_id")[c("record", "person") %in% countBy]


  # summarise counts
  resultTables <- purrr::map(omopTableName, \(table) {
    # initial table
    omopTable <- dplyr::ungroup(cdm[[table]])
    conceptId <- omopgenerics::omopColumns(table = table, field = "standard_concept")
    sourceConceptId <- omopgenerics::omopColumns(table = table, field = "source_concept")

    if(omopgenerics::isTableEmpty(omopTable)) {
      cli::cli_warn(c("!" = "{table} omop table is empty."))
      return(NULL)
    }
    if (is.na(conceptId)) {
      cli::cli_warn(c("!" = "No standard concept identified for {table}."))
      return(NULL)
    }

    prefix <- omopgenerics::tmpPrefix()

    # restrict study period
    omopTable <- omopTable |>
      restrictStudyPeriod(dateRange = dateRange)

    if (is.null(omopTable)) {
      return(NULL)
    }

    startDate <- omopgenerics::omopColumns(table = table, field = "start_date")

    result <- omopTable |>
      dplyr::rename(
        concept_id = dplyr::all_of(conceptId),
        source_concept_id = dplyr::all_of(sourceConceptId),
        start_date = dplyr::all_of(startDate)
      ) |>
      dplyr::mutate(source_concept_id = dplyr::coalesce(.data$source_concept_id, 0L)) |>
      dplyr::left_join(
        cdm$concept |>
          dplyr::select("concept_id", "concept_name"),
        by = "concept_id"
      ) |>
      dplyr::left_join(
        cdm$concept |>
          dplyr::select(
            source_concept_id = "concept_id",
            source_concept_name = "concept_name"
          ),
        by = "source_concept_id"
      ) |>
      dplyr::mutate(source_concept_name = dplyr::coalesce(.data$source_concept_name, "No matching concept"),
                    concept_name = dplyr::coalesce(.data$concept_name, "No matching concept")) |>
      # add demographics and year
      addStratifications(
        indexDate = "start_date",
        sex = sex,
        ageGroup = ageGroup,
        interval = interval,
        intervalName = "interval",
        name = omopgenerics::uniqueTableName(prefix)
      ) |>
      addInObservation(inObservation = inObservation, cdm = cdm, episode = FALSE, name = omopgenerics::uniqueTableName(prefix)) |>
      # summarise results
      summariseCountsInternal(stratax, counts) |>
      dplyr::mutate(omop_table = .env$table)


    omopgenerics::dropSourceTable(cdm = cdm, name = dplyr::starts_with(prefix))

    return(result)
  }) |>
    purrr::compact()

  if (length(resultTables) == 0) {
    return(omopgenerics::emptySummarisedResult(settings = set))
  }

  resultTables |>
    dplyr::bind_rows() |>
    dplyr::mutate(
      result_id = 1L,
      cdm_name = omopgenerics::cdmName(cdm)
    ) |>
    omopgenerics::uniteGroup(cols = "omop_table") |>
    omopgenerics::uniteStrata(cols = c(names(ageGroup), "sex"[sex], "in_observation"[inObservation], character())) |>
    addTimeInterval() |>
    dplyr::mutate(
      estimate_value = as.character(.data$estimate_value),
      estimate_type = "integer",
      variable_level = as.character(.data$concept_id)
    ) |>
    omopgenerics::uniteAdditional(cols = additional) |>
    dplyr::rename("variable_name" = "concept_name") |>
    dplyr::select(!"concept_id") |>
    omopgenerics::newSummarisedResult(settings = set)
}
