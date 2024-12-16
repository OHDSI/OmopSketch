
my_getStrataList <- function(sex = FALSE, ageGroup = NULL, year = FALSE){
  c(names(ageGroup), "sex"[sex], "year"[year])
}
checkFeasibility <- function(omopTable, tableName, conceptId) {

  if (omopgenerics::isTableEmpty(omopTable)){
    cli::cli_warn(paste0(tableName, " omop table is empty."))
    return(NULL)
  }

  if (is.na(conceptId)){
    cli::cli_warn(paste0(tableName, " omop table doesn't contain standard concepts."))
    return(NULL)
  }

  return(TRUE)
}

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
#' summariseAllConceptCounts(cdm, "condition_occurrence")
#' }
#'
summariseAllConceptCounts <- function(cdm,
                                      omopTableName,
                                      countBy = "record",
                                      year = FALSE,
                                      sex = FALSE,
                                      ageGroup = NULL,
                                      dateRange = NULL) {
  # initial checks
  cdm <- omopgenerics::validateCdmArgument(cdm)
  checkCountBy(countBy)
  omopgenerics::assertLogical(year, length = 1)
  omopgenerics::assertLogical(sex, length = 1)
  omopgenerics::assertChoice(omopTableName, choices = omopgenerics::omopTables(), unique = TRUE)
  ageGroup <- omopgenerics::validateAgeGroupArgument(ageGroup)
  dateRange <- validateStudyPeriod(cdm, dateRange)

  # settings for the created results
  set <- createSettings(result_type = "summarise_all_concept_counts", study_period = dateRange)

  # get strata
  strata <- my_getStrataList(sex = sex, year = year, ageGroup = ageGroup) |>
    omopgenerics::combineStrata()

  # how to count
  counts <- c("records", "person_id")[c("record", "person") %in% countBy]

  # summarise counts
  resultTables <- purrr::map(omopTableName, function(table) {
    # check that table is not empty
    omopTable <- dplyr::ungroup(cdm[[table]])
    conceptId <- standardConcept(table)
    if (is.null(checkFeasibility(omopTable, table, conceptId))){
      return(NULL)
    }

    # restrict study period
    omopTable <- restrictStudyPeriod(omopTable, dateRange)

    # add demographics
    indexDate <- startDate(omopgenerics::tableName(omopTable))
    x <- omopTable |>
      dplyr::rename(concept_id = dplyr::all_of(conceptId)) |>
      dplyr::left_join(
        cdm$concept |>
          dplyr::select("concept_id", "concept_name"),
        by = "concept_id"
      ) |>
      PatientProfiles::addDemographicsQuery(
        age = FALSE,
        ageGroup = ageGroup,
        sex = sex,
        indexDate = indexDate,
        priorObservation = FALSE,
        futureObservation = FALSE,
        dateOfBirth = FALSE
      )

    # add year strata if needed
    if (year) {
      x <- x |>
        dplyr::mutate(year = as.character(clock::get_year(.data[[indexDate]])))
    }

    # add concept id to stratification
    concepts <- c("concept_id", "concept_name")
    stratax <- c(list(concepts), purrr::map(strata, \(x) c(concepts, x)))

    # create table
    if (sex | !is.null(ageGroup) | year) {
      tempName <- omopgenerics::uniqueTableName()
      x <- x |>
        dplyr::select("person_id", dplyr::all_of(unique(unlist(stratax)))) |>
        dplyr::compute(name = tempName, temporary = FALSE)
      intermediate <- TRUE
    } else {
      intermediate <- FALSE
    }

    # summarise results
    result <- summariseCountsInternal(x, stratax, counts) |>
      dplyr::mutate(
        omop_table = .env$table,

      )

    if (intermediate) {
      omopgenerics::dropSourceTable(cdm = cdm, name = tempName)
    }

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
