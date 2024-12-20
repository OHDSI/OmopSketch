
#' Summarise concept use in patient-level data
#'
#' @param cdm A cdm object
#' @param omopTableName A character vector of the names of the tables to
#' summarise in the cdm object.
#' @param countBy Either "record" for record-level counts or "person" for
#' person-level counts
#' @param year TRUE or FALSE. If TRUE code use will be summarised by year.
#' @param sex TRUE or FALSE. If TRUE code use will be summarised by sex.
#' @param ageGroup A list of ageGroup vectors of length two. Code use will be
#' thus summarised by age groups.
#' @param sample An integer to sample the tables to only that number of records.
#' If NULL no sample is done.
#' @param dateRange A list containing the minimum and the maximum dates
#' defining the time range within which the analysis is performed.
#'
#' @return A summarised_result object with results overall and, if specified, by
#' strata.
#'
#' @export
#'
#' @examples
#' \donttest{
#' library(OmopSketch)
#' library(CDMConnector)
#' library(duckdb)
#'
#' requireEunomia()
#' con <- dbConnect(duckdb(), eunomiaDir())
#' cdm <- cdmFromCon(con = con, cdmSchema = "main", writeSchema = "main")
#'
#' summariseConceptIdCounts(cdm, "condition_occurrence")
#' }
#'
summariseConceptIdCounts <- function(cdm,
                                      omopTableName,
                                      countBy = "record",
                                      year = FALSE,
                                      sex = FALSE,
                                      ageGroup = NULL,
                                      sample = NULL,
                                      dateRange = NULL) {
  # initial checks
  cdm <- omopgenerics::validateCdmArgument(cdm)
  checkCountBy(countBy)
  omopgenerics::assertLogical(year, length = 1)
  omopgenerics::assertLogical(sex, length = 1)
  omopgenerics::assertChoice(omopTableName, choices = omopgenerics::omopTables(), unique = TRUE)
  ageGroup <- omopgenerics::validateAgeGroupArgument(ageGroup)
  dateRange <- validateStudyPeriod(cdm, dateRange)
  omopgenerics::assertNumeric(sample, integerish = TRUE, min = 1, null = TRUE, length = 1)

  # settings for the created results
  set <- createSettings(result_type = "summarise_all_concept_counts", study_period = dateRange)

  # get strata
  strata <- omopgenerics::combineStrata(c(strataCols(sex = sex, ageGroup = ageGroup), "year"[year]))
  concepts <- c("concept_id", "concept_name")
  stratax <- c(list(concepts), purrr::map(strata, \(x) c(concepts, x)))

  # how to count
  counts <- c("records", "person_id")[c("record", "person") %in% countBy]

  # summarise counts
  resultTables <- purrr::map(omopTableName, \(table) {
    # initial table
    omopTable <- dplyr::ungroup(cdm[[table]])
    conceptId <- omopgenerics::omopColumns(table = table, field = "standard_concept")
    if (is.na(conceptId)) {
      cli::cli_warn(c("!" = "No standard concept identified for {table}."))
      return(NULL)
    }

    prefix <- omopgenerics::tmpPrefix()

    # restrict study period
    omopTable <- restrictStudyPeriod(omopTable, dateRange)
    if (is.null(omopTable)) return(NULL)

    # sample table
    omopTable <- omopTable |>
      sampleOmopTable(sample = sample, name = omopgenerics::uniqueTableName(prefix))

    result <- omopTable |>
      # add concept names
      dplyr::rename(concept_id = dplyr::all_of(conceptId)) |>
      dplyr::left_join(
        cdm$concept |>
          dplyr::select("concept_id", "concept_name"),
        by = "concept_id"
      ) |>
      # add demographics and year
      addStratifications(
        indexDate = omopgenerics::omopColumns(table = table, field = "start_date"),
        sex = sex,
        ageGroup = ageGroup,
        interval = dplyr::if_else(year, "years", "overall"),
        intervalName = "year",
        name = omopgenerics::uniqueTableName(prefix)
      ) |>
      # summarise results
      summariseCountsInternal(stratax, counts) |>
      dplyr::mutate(omop_table = .env$table,
                    estimate_name = dplyr::if_else(.data$estimate_name == "count_records", "Number records",
                                                   dplyr::if_else(.data$estimate_name == "count_subjects", "Number subjects", .data$estimate_name)
                    ))

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
    omopgenerics::uniteStrata(cols = unique(unlist(strata)) %||% character()) |>
    omopgenerics::uniteAdditional() |>
    dplyr::mutate(
      estimate_value = as.character(.data$estimate_value),
      estimate_type = "integer",
      variable_level = as.character(.data$concept_id)
    ) |>
    dplyr::rename("variable_name" = "concept_name") |>
    dplyr::select(!"concept_id") |>
    omopgenerics::newSummarisedResult(settings = set)
}
