
#' Summarise concept counts in patient-level data. Only concepts recorded during observation period are counted.
#'
#' @param cdm A cdm object
#' @param conceptId List of concept IDs to summarise.
#' @param countBy Either "record" for record-level counts or "person" for
#' person-level counts
#' @param concept TRUE or FALSE. If TRUE code use will be summarised by concept.
#' @param interval Time interval to stratify by. It can either be "years", "quarters", "months" or "overall".
#' @param sex TRUE or FALSE. If TRUE code use will be summarised by sex.
#' @param ageGroup A list of ageGroup vectors of length two. Code use will be
#' thus summarised by age groups.
#' @return A summarised_result object with results overall and, if specified, by
#' strata.
#' @export
#' @examples
#' \donttest{
#' library(OmopSketch)
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
                                   interval = "overall",
                                   sex = FALSE,
                                   ageGroup = NULL){

  omopgenerics::validateCdmArgument(cdm)
  omopgenerics::assertList(conceptId, named = TRUE)
  checkCountBy(countBy)
  omopgenerics::assertChoice(countBy, choices = c("record", "person"))
  countBy <- gsub("persons","subjects",paste0("number ",countBy,"s"))
  x <- validateIntervals(interval)
  interval <- x$interval
  unitInterval <- x$unitInterval
  omopgenerics::assertNumeric(unitInterval, length = 1, min = 1, na = TRUE)
  omopgenerics::assertLogical(concept, length = 1)
  omopgenerics::assertLogical(sex, length = 1)
  ageGroup <- omopgenerics::validateAgeGroupArgument(ageGroup, ageGroupName = "")[[1]]

  # Get all concepts in concept table if conceptId is NULL
  # if(is.null(conceptId)) {
  #   conceptId <- cdm$concept |>
  #     dplyr::select("concept_name", "concept_id") |>
  #     dplyr::collect() |>
  #     dplyr::group_by(.data$concept_name)  |>
  #     dplyr::summarise(named_vec = list(.data$concept_id)) |>
  #     tibble::deframe()
  # }

  codeUse <- list()
  cli::cli_progress_bar("Getting use of codes", total = length(conceptId))
  for(i in 1:length(conceptId)) {
    cli::cli_alert_info("Getting concept counts of {names(conceptId)[i]}")
    codeUse[[i]] <- getCodeUse(conceptId[i],
                               cdm = cdm,
                               countBy = countBy,
                               concept = concept,
                               interval = interval,
                               unitInterval = unitInterval,
                               sex = sex,
                               ageGroup = ageGroup)
    Sys.sleep(i/length(conceptId))
    cli::cli_progress_update()
  }
  codeUse <- codeUse |>
    dplyr::bind_rows()
  cli::cli_progress_done()

  if(nrow(codeUse) > 0) {
    codeUse <- codeUse %>%
      dplyr::mutate(
        result_id = as.integer(1),
        cdm_name = omopgenerics::cdmName(cdm)
      )
  } else {
    codeUse <- omopgenerics::emptySummarisedResult()
  }

  codeUse <- codeUse %>%
    omopgenerics::newSummarisedResult(
      settings = dplyr::tibble(
        result_id = 1L,
        result_type = "summarise_concept_counts",
        package_name = "OmopSketch",
        package_version = as.character(utils::packageVersion("OmopSketch"))
      )
    )
  return(codeUse)
}

getCodeUse <- function(x,
                       cdm,
                       countBy,
                       concept,
                       interval,
                       unitInterval,
                       sex,
                       ageGroup,
                       call = parent.frame()){

  tablePrefix <-  omopgenerics::tmpPrefix()

  omopgenerics::assertNumeric(x[[1]], integerish = TRUE)
  omopgenerics::assertList(x)

  # Create code list table
  tableCodelist <- paste0(tablePrefix,"codelist")
  cdm <- omopgenerics::insertTable(cdm = cdm,
                                   name = tableCodelist,
                                   table = dplyr::tibble(concept_id = x[[1]]),
                                   overwrite = TRUE,
                                   temporary = FALSE)

  cdm[[tableCodelist]] <- cdm[[tableCodelist]] %>%
    dplyr::left_join(
      cdm[["concept"]] %>% dplyr::select("concept_id", "domain_id"),
      by = "concept_id"
    )

  # Create domains table
  tableDomainsData <- paste0(tablePrefix,"domains_data")
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

  # Create records table
  intermediateTable <- paste0(tablePrefix,"intermediate_table")
  records <- getRelevantRecords(cdm = cdm,
                                tableCodelist = tableCodelist,
                                intermediateTable = intermediateTable,
                                tablePrefix = tablePrefix)
  if(is.null(records)){
    cc <- dplyr::tibble()
    cli::cli_inform(c(
      "i" = "No records found in the cdm for the concepts provided."
    ))
    return(omopgenerics::emptySummarisedResult())
  }

  records <- addStrataToOmopTable(records, "date", ageGroup, sex)
  strata  <- getStrataList(sex, ageGroup)

  if(interval != "overall"){
    intervalTibble <- getIntervalTibble(omopTable = records,
                                        start_date_name = "date",
                                        end_date_name   = "date",
                                        interval = interval,
                                        unitInterval = unitInterval)

    cdm <- cdm |> omopgenerics::insertTable(name = paste0(tablePrefix,"interval"), table = intervalTibble)

    records <- splitIncidenceBetweenIntervals(cdm, records, "date", tablePrefix)

    strata <- omopgenerics::combineStrata(c(unique(unlist(getStrataList(sex,ageGroup))), "interval_group"))
  }

  if(!"number subjects" %in% c(countBy)){records <- records |> dplyr::select(-"person_id")}

  cc <- records |>
    # dplyr::collect() |> # https://github.com/darwin-eu-dev/PatientProfiles/issues/706
    PatientProfiles::summariseResult(strata = strata,
                                     variable = "standard_concept_name",
                                     group = "standard_concept_id",
                                     includeOverallGroup = TRUE,
                                     includeOverallStrata = TRUE,
                                     counts = TRUE,
                                     estimates = as.character()) |>
    suppressMessages() |>
    dplyr::filter(.data$variable_name %in% .env$countBy) |>
    dplyr::mutate("variable_name" = stringr::str_to_sentence(.data$variable_name)) |>
    dplyr::mutate(standard_concept_id = .data$group_level) |>
    dplyr::mutate(group_name = "codelist_name") |>
    dplyr::mutate(group_level = names(x)) |>
    dplyr::mutate(cdm_name = omopgenerics::cdmName(cdm)) |>
    dplyr::select(-c("additional_name", "additional_level")) |>
    dplyr::left_join(
      getConceptsInfo(records),
      by = "standard_concept_id"
    ) |>
    dplyr::select(-"standard_concept_id")

  if(interval != "overall"){
    cc <- cc |>
      visOmopResults::splitStrata() |>
      dplyr::mutate(variable_level = .data$interval_group) |>
      visOmopResults::uniteStrata(unique(unlist(strata))[unique(unlist(strata)) != "interval_group"]) |>
      dplyr::select(-"interval_group")
  }
  CDMConnector::dropTable(cdm = cdm, name = dplyr::starts_with(tablePrefix))

  return(cc)
}

getRelevantRecords <- function(cdm,
                               tableCodelist,
                               intermediateTable,
                               tablePrefix){

  codes <- cdm[[tableCodelist]] |> dplyr::collect()

  tableName <- purrr::discard(unique(codes$table_name), is.na)
  standardConceptIdName <- purrr::discard(unique(codes$standard_concept), is.na)
  sourceConceptIdName   <- purrr::discard(unique(codes$source_concept), is.na)
  dateName <- purrr::discard(unique(codes$start_date), is.na)

  if(length(tableName)>0){
    codeRecords <- cdm[[tableName[[1]]]]

    if(is.null(codeRecords)){return(NULL)}

    tableCodes <- paste0(tablePrefix, "table_codes")

    cdm <- omopgenerics::insertTable(cdm = cdm,
                                     name = tableCodes,
                                     table = codes %>%
                                       dplyr::filter(.data$table_name == !!tableName[[1]]) %>%
                                       dplyr::select("concept_id", "domain_id"),
                                     overwrite = TRUE,
                                     temporary = FALSE)

    codeRecords <- codeRecords %>%
      dplyr::mutate(date = !!dplyr::sym(dateName[[1]])) %>%
      dplyr::select(dplyr::all_of(c("person_id",
                                    standardConceptIdName[[1]],
                                    sourceConceptIdName[[1]],
                                    "date"))) %>%
      dplyr::rename("standard_concept_id" = .env$standardConceptIdName[[1]],
                    "source_concept_id" = .env$sourceConceptIdName[[1]]) %>%
      dplyr::inner_join(cdm[[tableCodes]],
                        by = c("standard_concept_id"="concept_id")) %>%
      filterInObservation(indexDate = "date") |>
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

getConceptsInfo <- function(records){
  records |>
    dplyr::select("standard_concept_name", "standard_concept_id", "source_concept_name", "source_concept_id", "domain_id") |>
    dplyr::distinct() |>
    dplyr::collect() |>
    dplyr::mutate("additional_name"  = "standard_concept_name &&& standard_concept_id &&& source_concept_name &&& source_concept_id &&& domain_id") |>
    dplyr::mutate("additional_level" = paste0(.data$standard_concept_name, " &&& ",.data$standard_concept_id, " &&& ", .data$source_concept_name, " &&& ", .data$source_concept_id, " &&& ", .data$domain_id)) |>
    dplyr::select("standard_concept_id","additional_name", "additional_level") |>
    dplyr::mutate(dplyr::across(dplyr::everything(), as.character)) |>
    dplyr::add_row(
      "standard_concept_id" = "overall",
      "additional_name"  = "overall",
      "additional_level" = "overall"
    )
}
