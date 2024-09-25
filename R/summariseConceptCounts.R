
#' Summarise code use in patient-level data
#'
#' @param cdm A cdm object
#' @param conceptId List of concept IDs to summarise.
#' @param countBy Either "record" for record-level counts or "person" for
#' person-level counts
#' @param concept TRUE or FALSE. If TRUE code use will be summarised by concept.
#' @param year TRUE or FALSE. If TRUE code use will be summarised by year.
#' @param sex TRUE or FALSE. If TRUE code use will be summarised by sex.
#' @param ageGroup A list of ageGroup vectors of length two. Code use will be
#' thus summarised by age groups.
#' @return A summarised_result object with results overall and, if specified, by
#' strata.
#' @export
#' @examples
#' \donttest{
#'
#' cdm <- mockOmopSketch()
#'
#' cs <- list(sumatriptan = c(35604883, 35604879, 35604880, 35604884))
#'
#' results <- summariseConceptCounts(cdm, conceptId = cs)
#'
#' results
#'
#' PatientProfiles::mockDisconnect(cdm)
#' }
summariseConceptCounts <- function(cdm,
                                   conceptId,
                                   countBy = c("record", "person"),
                                   concept = TRUE,
                                   year = FALSE,
                                   sex = FALSE,
                                   ageGroup = NULL){

  omopgenerics::validateCdmArgument(cdm)
  omopgenerics::assertList(conceptId, named = TRUE)
  checkCountBy(countBy)

  if(!is.null(conceptId) && length(names(conceptId)) != length(conceptId)){
    cli::cli_abort("conceptId must be a named list")
  }

  # Get all concepts in concept table if conceptId is NULL
  # if(is.null(conceptId)) {
  #   conceptId <- cdm$concept |>
  #     dplyr::select("concept_name", "concept_id") |>
  #     dplyr::collect() |>
  #     dplyr::group_by(.data$concept_name)  |>
  #     dplyr::summarise(named_vec = list(.data$concept_id)) |>
  #     tibble::deframe()
  # }

  getAllCodeUse <- function() {
    codeUse <- list()
    cli::cli_progress_bar("Getting use of codes", total = length(conceptId))
    for(i in 1:length(conceptId)) {
      cli::cli_alert_info("Getting use of codes from {names(conceptId)[i]}")
      codeUse[[i]] <- getCodeUse(conceptId[i],
                                 cdm = cdm,
                                 cohortTable = NULL,
                                 cohortId = NULL,
                                 timing = "any",
                                 countBy = countBy,
                                 concept = concept,
                                 year = year,
                                 sex = sex,
                                 ageGroup = ageGroup)
      Sys.sleep(i/length(conceptId))
      cli::cli_progress_update()
    }
    codeUse <- codeUse |>
      dplyr::bind_rows()
    cli::cli_progress_done()
    return(codeUse)
  }
  codeUse <- getAllCodeUse()

  if(nrow(codeUse) > 0) {
    codeUse <- codeUse %>%
      dplyr::mutate(
        result_id = as.integer(1),
        cdm_name = omopgenerics::cdmName(cdm)
      ) %>%
      omopgenerics::newSummarisedResult(
        settings = dplyr::tibble(
          result_id = as.integer(1),
          result_type = "summarise_concept_counts",
          package_name = "OmopSketch",
          package_version = as.character(utils::packageVersion("OmopSketch"))
        )
      )
  } else {
    codeUse <- omopgenerics::emptySummarisedResult()
  }

  return(codeUse)
}

getCodeUse <- function(x,
                       cdm,
                       cohortTable,
                       cohortId,
                       timing,
                       countBy,
                       concept,
                       year,
                       sex,
                       ageGroup,
                       call = parent.frame()) {

  omopgenerics::assertCharacter(timing, len = 1)
  omopgenerics::assertChoice(timing, choices = c("any", "entry"))
  omopgenerics::assertChoice(countBy, choices = c("record", "person"))
  omopgenerics::assertNumeric(x[[1]], integerish = TRUE)
  omopgenerics::assertList(x)
  omopgenerics::assertLogical(concept)
  omopgenerics::assertLogical(year)
  omopgenerics::assertLogical(sex)
  omopgenerics::validateAgeGroupArgument(ageGroup)

  tableCodelist <- paste0(omopgenerics::uniqueTableName(),
                          omopgenerics::uniqueId())
  cdm <- omopgenerics::insertTable(cdm = cdm,
                                   name = tableCodelist,
                                   table = dplyr::tibble(concept_id = x[[1]]),
                                   overwrite = TRUE,
                                   temporary = FALSE)
  cdm[[tableCodelist]] <- cdm[[tableCodelist]] %>%
    dplyr::left_join(
      cdm[["concept"]] %>% dplyr::select("concept_id", "domain_id"),
      by = "concept_id")

  tableDomainsData <- paste0(omopgenerics::uniqueTableName(),
                             omopgenerics::uniqueId())
  cdm <- omopgenerics::insertTable(cdm = cdm,
                                   name = tableDomainsData,
                                   table = tables,
                                   overwrite = TRUE,
                                   temporary = FALSE)

  cdm[[tableCodelist]] <- cdm[[tableCodelist]] %>%
    dplyr::mutate(domain_id = tolower(.data$domain_id)) |>
    dplyr::left_join(cdm[[tableDomainsData]],
                     by = "domain_id") |>
    dplyr::compute(name = tableCodelist,
                   temporary = FALSE,
                   overwrite = TRUE)

  CDMConnector::dropTable(cdm = cdm, name = tableDomainsData)
  cdm[[tableDomainsData]] <- NULL

  intermediateTable <- paste0(omopgenerics::uniqueTableName(),
                              omopgenerics::uniqueId())
  records <- getRelevantRecords(cdm = cdm,
                                tableCodelist = tableCodelist,
                                cohortTable = cohortTable,
                                cohortId = cohortId,
                                timing = timing,
                                intermediateTable = intermediateTable)

  if(!is.null(records) &&
     (records %>% utils::head(1) %>% dplyr::tally() %>% dplyr::pull("n") > 0)) {
    if(sex == TRUE | !is.null(ageGroup)){
      records <- records %>%
        PatientProfiles::addDemographicsQuery(age = !is.null(ageGroup),
                                              ageGroup = ageGroup,
                                              sex = sex,
                                              priorObservation = FALSE,
                                              futureObservation =  FALSE,
                                              indexDate = "date") |>
        dplyr::compute(overwrite = TRUE,
                       name = omopgenerics::tableName(records),
                       temporary = FALSE)
    }

    byAgeGroup <- !is.null(ageGroup)
    codeCounts <- getSummaryCounts(records = records,
                                   cdm = cdm,
                                   countBy = countBy,
                                   concept = concept,
                                   year = year,
                                   sex = sex,
                                   byAgeGroup = byAgeGroup)

    if (is.null(cohortTable)) {
      cohortName <- NA
    } else {
      cohortName <- omopgenerics::settings(cdm[[cohortTable]]) %>%
        dplyr::filter(.data$cohort_definition_id == cohortId) %>%
        dplyr::pull("cohort_name")
    }

    codeCounts <-  codeCounts %>%
      dplyr::mutate(
        "codelist_name" := !!names(x),
        "cohort_name" = .env$cohortName,
        "estimate_type" = "integer",
        "variable_name" = dplyr::if_else(is.na(.data$standard_concept_name), "overall", .data$standard_concept_name),
        "variable_level" = as.character(.data$standard_concept_id)
      ) %>%
      visOmopResults::uniteGroup(cols = c("cohort_name", "codelist_name")) %>%
      visOmopResults::uniteAdditional(
        cols = c("source_concept_name", "source_concept_id", "domain_id")
      ) %>%
      dplyr::select(
        "group_name", "group_level", "strata_name", "strata_level",
        "variable_name", "variable_level", "estimate_name", "estimate_type",
        "estimate_value", "additional_name", "additional_level"
      )
  } else {
    codeCounts <- dplyr::tibble()
    cli::cli_inform(c(
      "i" = "No records found in the cdm for the concepts provided."
    ))
  }

  CDMConnector::dropTable(cdm = cdm,
                          name = tableCodelist)
  cdm[[tableCodelist]] <- NULL
  CDMConnector::dropTable(
    cdm = cdm,
    name = dplyr::starts_with(intermediateTable)
  )

  return(codeCounts)
}

getRelevantRecords <- function(cdm,
                               tableCodelist,
                               cohortTable,
                               cohortId,
                               timing,
                               intermediateTable){

  codes <- cdm[[tableCodelist]] |> dplyr::collect()

  tableName <- purrr::discard(unique(codes$table_name), is.na)
  standardConceptIdName <- purrr::discard(unique(codes$standard_concept), is.na)
  sourceConceptIdName <- purrr::discard(unique(codes$source_concept), is.na)
  dateName <- purrr::discard(unique(codes$start_date), is.na)

  if(!is.null(cohortTable)){
    if(is.null(cohortId)){
      cohortSubjects <- cdm[[cohortTable]] %>%
        dplyr::select("subject_id", "cohort_start_date") %>%
        dplyr::rename("person_id" = "subject_id") %>%
        dplyr::distinct()
    } else {
      cohortSubjects <- cdm[[cohortTable]] %>%
        dplyr::filter(.data$cohort_definition_id %in% cohortId) %>%
        dplyr::select("subject_id", "cohort_start_date") %>%
        dplyr::rename("person_id" = "subject_id") %>%
        dplyr::distinct()
    }
  }

  if(length(tableName)>0){
    codeRecords <- cdm[[tableName[[1]]]]
    if(!is.null(cohortTable)){
      # keep only records of those in the cohorts of interest
      codeRecords <- codeRecords %>%
        dplyr::inner_join(cohortSubjects,
                          by = "person_id")
      if(timing == "entry"){
        codeRecords <- codeRecords %>%
          dplyr::filter(.data$cohort_start_date == !!dplyr::sym(dateName[[1]]))
      }
    }

    if(is.null(codeRecords)){
      return(NULL)
    }

    tableCodes <- paste0(omopgenerics::uniqueTableName(),
                         omopgenerics::uniqueId())
    cdm <- omopgenerics::insertTable(cdm = cdm,
                                     name = tableCodes,
                                     table = codes %>%
                                       dplyr::filter(.data$table_name == !!tableName[[1]]) %>%
                                       dplyr::select("concept_id", "domain_id"),
                                     overwrite = TRUE,
                                     temporary = FALSE)

    codeRecords <- codeRecords %>%
      dplyr::mutate(date = !!dplyr::sym(dateName[[1]])) %>%
      dplyr::mutate(year = clock::get_year(date)) %>%
      dplyr::select(dplyr::all_of(c("person_id",
                                    standardConceptIdName[[1]],
                                    sourceConceptIdName[[1]],
                                    "date", "year"))) %>%
      dplyr::rename("standard_concept_id" = .env$standardConceptIdName[[1]],
                    "source_concept_id" = .env$sourceConceptIdName[[1]]) %>%
      dplyr::inner_join(cdm[[tableCodes]],
                        by = c("standard_concept_id"="concept_id")) %>%
      dplyr::compute(
        name = paste0(intermediateTable,"_grr"),
        temporary = FALSE,
        schema = attr(cdm, "write_schema"),
        overwrite = TRUE
      )

    CDMConnector::dropTable(cdm = cdm, name = tableCodes)
    cdm[[tableCodes]] <- NULL

  } else {
    return(NULL)
  }

  # get for any additional domains and union
  if(length(tableName) > 1) {
    for(i in 1:(length(tableName)-1)) {
      workingRecords <-  cdm[[tableName[[i+1]]]]
      if(!is.null(cohortTable)){
        # keep only records of those in the cohorts of interest
        workingRecords <- workingRecords %>%
          dplyr::inner_join(cohortSubjects,
                            by = "person_id")
        if(timing == "entry"){
          workingRecords <- workingRecords %>%
            dplyr::filter(.data$cohort_start_date == !!dplyr::sym(dateName[[i+1]]))
        }
      }
      workingRecords <-  workingRecords %>%
        dplyr::mutate(date = !!dplyr::sym(dateName[[i+1]])) %>%
        dplyr::mutate(year = clock::get_year(date)) %>%
        dplyr::select(dplyr::all_of(c("person_id",
                                      standardConceptIdName[[i+1]],
                                      sourceConceptIdName[[i+1]],
                                      "date", "year"))) %>%
        dplyr::rename("standard_concept_id" = .env$standardConceptIdName[[i+1]],
                      "source_concept_id" = .env$sourceConceptIdName[[i+1]]) %>%
        dplyr::inner_join(codes %>%
                            dplyr::filter(.data$table_name == tableName[[i+1]]) %>%
                            dplyr::select("concept_id", "domain_id"),
                          by = c("standard_concept_id"="concept_id"),
                          copy = TRUE)

      if(workingRecords %>% utils::head(1) %>% dplyr::tally() %>% dplyr::pull("n") >0){
        codeRecords <- codeRecords %>%
          dplyr::union_all(workingRecords)  %>%
          dplyr::compute(
            name = paste0(intermediateTable,"_grr_i"),
            temporary = FALSE,
            schema = attr(cdm, "write_schema"),
            overwrite = TRUE
          )
      }
    }
  }

  if(codeRecords %>% utils::head(1) %>% dplyr::tally() %>% dplyr::pull("n") >0){
    codeRecords <- codeRecords %>%
      dplyr::left_join(cdm[["concept"]] %>%
                         dplyr::select("concept_id", "concept_name"),
                       by = c("standard_concept_id"="concept_id")) %>%
      dplyr::rename("standard_concept_name"="concept_name") %>%
      dplyr::left_join(cdm[["concept"]] %>%
                         dplyr::select("concept_id", "concept_name"),
                       by = c("source_concept_id"="concept_id")) %>%
      dplyr::rename("source_concept_name"="concept_name")  %>%
      dplyr::mutate(source_concept_name = dplyr::if_else(is.na(.data$source_concept_name),
                                                         "NA", .data$source_concept_name)) %>%
      dplyr::compute(
        name = paste0(intermediateTable,"_grr_cr"),
        temporary = FALSE,
        schema = attr(cdm, "write_schema"),
        overwrite = TRUE
      )
  }

  return(codeRecords)
}

getSummaryCounts <- function(records,
                             cdm,
                             countBy,
                             concept,
                             year,
                             sex,
                             byAgeGroup) {

  if ("record" %in% countBy) {
    recordSummary <- records %>%
      dplyr::tally(name = "estimate_value") %>%
      dplyr::mutate(estimate_value = as.character(.data$estimate_value)) %>%
      dplyr::collect()
    if(isTRUE(concept)) {
      recordSummary <- dplyr::bind_rows(
        recordSummary,
        records %>%
          dplyr::group_by(
            .data$standard_concept_id, .data$standard_concept_name,
            .data$source_concept_id, .data$source_concept_name, .data$domain_id
          ) %>%
          dplyr::tally(name = "estimate_value") %>%
          dplyr::mutate(estimate_value = as.character(.data$estimate_value)) %>%
          dplyr::collect()
      )
    }
    recordSummary <- recordSummary %>%
      dplyr::mutate(
        strata_name = "overall",
        strata_level = "overall",
        estimate_name = "record_count"
      )
  } else {
    recordSummary <- dplyr::tibble()
  }

  if ("person" %in% countBy) {
    personSummary <- records %>%
      dplyr::select("person_id") %>%
      dplyr::distinct() %>%
      dplyr::tally(name = "estimate_value") %>%
      dplyr::mutate(estimate_value = as.character(.data$estimate_value)) %>%
      dplyr::collect()

    if (isTRUE(concept)) {
      personSummary <- dplyr::bind_rows(
        personSummary,
        records %>%
          dplyr::select(
            "person_id", "standard_concept_id", "standard_concept_name",
            "source_concept_id", "source_concept_name", "domain_id"
          ) %>%
          dplyr::distinct() %>%
          dplyr::group_by(
            .data$standard_concept_id, .data$standard_concept_name,
            .data$source_concept_id, .data$source_concept_name, .data$domain_id
          ) %>%
          dplyr::tally(name = "estimate_value") %>%
          dplyr::mutate(estimate_value = as.character(.data$estimate_value)) %>%
          dplyr::collect()
      )
    }
    personSummary <- personSummary %>%
      dplyr::mutate(
        strata_name = "overall",
        strata_level = "overall",
        estimate_name = "person_count")
  } else {
    personSummary <- dplyr::tibble()
  }

  if ("record" %in% countBy & year == TRUE) {
    recordSummary <- dplyr::bind_rows(
      recordSummary,
      getGroupedRecordCount(records = records, cdm = cdm, groupBy = "year")
    )
  }
  if ("person" %in% countBy & year == TRUE) {
    personSummary <- dplyr::bind_rows(
      personSummary,
      getGroupedPersonCount(records = records, cdm = cdm, groupBy = "year")
    )
  }
  if ("record" %in% countBy & sex == TRUE) {
    recordSummary <- dplyr::bind_rows(
      recordSummary,
      getGroupedRecordCount(records = records, cdm = cdm, groupBy = "sex")
    )
  }
  if ("person" %in% countBy & sex == TRUE) {
    personSummary <- dplyr::bind_rows(
      personSummary,
      getGroupedPersonCount(records = records, cdm = cdm, groupBy = "sex")
    )
  }
  if ("record" %in% countBy & byAgeGroup == TRUE) {
    recordSummary <- dplyr::bind_rows(
      recordSummary,
      getGroupedRecordCount(records = records, cdm = cdm, groupBy = "age_group")
    )
  }
  if ("person" %in% countBy & byAgeGroup == TRUE) {
    personSummary <- dplyr::bind_rows(
      personSummary,
      getGroupedPersonCount(records = records, cdm = cdm, groupBy = "age_group")
    )
  }
  if ("record" %in% countBy && byAgeGroup == TRUE && sex == TRUE) {
    recordSummary <- dplyr::bind_rows(
      recordSummary,
      getGroupedRecordCount(records = records, cdm = cdm, groupBy = c("age_group", "sex"))
    )
  }
  if ("person" %in% countBy && byAgeGroup == TRUE && sex == TRUE) {
    personSummary <- dplyr::bind_rows(
      personSummary,
      getGroupedPersonCount(records = records, cdm = cdm, groupBy = c("age_group", "sex"))
    )
  }
  summary <- dplyr::bind_rows(recordSummary, personSummary)
  return(summary)
}

getGroupedRecordCount <- function(records,
                                  cdm,
                                  groupBy){

  groupedCounts <- dplyr::bind_rows(
    records %>%
      dplyr::group_by(dplyr::pick(.env$groupBy)) %>%
      dplyr::tally(name = "estimate_value") %>%
      dplyr::mutate(estimate_value = as.character(.data$estimate_value)) %>%
      dplyr::collect(),
    records %>%
      dplyr::group_by(dplyr::pick(.env$groupBy,
                                  "standard_concept_id", "standard_concept_name",
                                  "source_concept_id", "source_concept_name",
                                  "domain_id")) %>%
      dplyr::tally(name = "estimate_value") %>%
      dplyr::mutate(estimate_value = as.character(.data$estimate_value)) %>%
      dplyr::collect()
  )  %>%
    visOmopResults::uniteStrata(cols = groupBy) %>%
    dplyr::mutate(estimate_name = "record_count")

  return(groupedCounts)
}

getGroupedPersonCount <- function(records,
                                  cdm,
                                  groupBy){

  groupedCounts <- dplyr::bind_rows(
    records %>%
      dplyr::select(dplyr::all_of(c("person_id", .env$groupBy))) %>%
      dplyr::distinct() %>%
      dplyr::group_by(dplyr::pick(.env$groupBy)) %>%
      dplyr::tally(name = "estimate_value") %>%
      dplyr::mutate(estimate_value = as.character(.data$estimate_value)) %>%
      dplyr::collect(),
    records %>%
      dplyr::select(dplyr::all_of(c(
        "person_id", "standard_concept_id", "standard_concept_name",
        "source_concept_id", "source_concept_name", "domain_id", .env$groupBy
      ))) %>%
      dplyr::distinct() %>%
      dplyr::group_by(dplyr::pick(
        .env$groupBy, "standard_concept_id", "standard_concept_name",
        "source_concept_id", "source_concept_name", "domain_id"
      )) %>%
      dplyr::tally(name = "estimate_value") %>%
      dplyr::mutate(estimate_value = as.character(.data$estimate_value)) %>%
      dplyr::collect()) %>%
    visOmopResults::uniteStrata(cols = groupBy) %>%
    dplyr::mutate(estimate_name = "person_count")

  return(groupedCounts)
}
