warnFacetColour <- function(result, cols) {
  colsToWarn <- result |>
    dplyr::select(
      dplyr::any_of(c(
        "cdm_name", "group_name", "group_level", "strata_name", "strata_level",
        "variable_name", "variable_level", "type"
      ))
    ) |>
    dplyr::distinct() |>
    omopgenerics::splitAll() |>
    dplyr::select(!dplyr::any_of(unique(unlist(cols)))) |>
    as.list() |>
    purrr::map(unique) |>
    suppressMessages()
  colsToWarn <- colsToWarn[lengths(colsToWarn) > 1]
  if (length(colsToWarn) > 0) {
    cli::cli_warn(message = c(
      "{.var {names(colsToWarn)}} not included in {collapseStr(names(cols), 'or')}, but have multiple values."
    ))
  }
  invisible(NULL)
}

collapseStr <- function(x, sep) {
  x <- x[x != ""]
  if (length(x) == 1) {
    return(x)
  }
  len <- length(x)
  paste0(paste0(x[-len], collapse = ", "), " ", sep, " ", x[len])
}

asCharacterFacet <- function(facet) {
  if (rlang::is_formula(facet)) {
    facet <- as.character(facet)
    facet <- facet[-1]
    facet <- facet |>
      stringr::str_split(pattern = stringr::fixed(" + ")) |>
      unlist()
    facet <- facet[facet != "."]
  }
  return(facet)
}

addTimeInterval <- function(x) {
  if (!"interval" %in% colnames(x)) {
    return(dplyr::mutate(x, time_interval = NA_character_))
  }
  x |>
    dplyr::mutate(
      type = dplyr::case_when(
        nchar(.data$interval) == 4 ~ "years",
        substr(.data$interval, 6, 6) == "Q" ~ "quarters",
        substr(.data$interval, 5, 5) == "_" ~ "months",
        .default = "overall"
      ),
      start = dplyr::case_when(
        .data$type == "years" ~ paste0(.data$interval, "-01-01"),
        .data$type == "quarters" ~ paste0(substr(.data$interval, 1, 4), "-", sprintf("%02i", as.integer(as.numeric(substr(.data$interval, 7, 7)) * 3 - 2)), "-01"),
        .data$type == "months" ~ paste0(substr(.data$interval, 1, 4), "-", sprintf("%02i", as.integer(substr(.data$interval, 6, 7))), "-01"),
        .data$type == "overall" ~ NA_character_
      ) |>
        suppressWarnings(),
      end = dplyr::case_when(
        .data$type == "years" ~ clock::add_years(as.Date(.data$start), 1),
        .data$type == "quarters" ~ clock::add_months(as.Date(.data$start), 3),
        .data$type == "months" ~ clock::add_months(as.Date(.data$start), 1),
        .data$type == "overall" ~ as.Date(NA)
      ) |>
        clock::add_days(-1) |>
        format("%Y-%m-%d"),
      time_interval = dplyr::if_else(
        .data$type == "overall", NA_character_, paste(.data$start, "to", .data$end)
      )
    ) |>
    dplyr::select(!c("start", "end", "type", "interval"))
}


createSettings <- function(result_type, result_id = 1L, study_period = NULL) {
  # Create the initial settings tibble
  settings <- dplyr::tibble(
    "result_id" = result_id,
    "result_type" = result_type,
    "package_name" = "OmopSketch",
    "package_version" = as.character(utils::packageVersion("OmopSketch"))
  )

  # Conditionally add study period columns
  if (!is.null(study_period)) {
    settings <- settings |>
      dplyr::mutate(
        "study_period_start" = as.character(study_period[1]),
        "study_period_end" = as.character(study_period[2])
      )
  }
  # Return the settings tibble
  return(settings)
}

#' Tables in the cdm_reference that contain clinical information
#'
#' @description
#' This function provides a list of allowed inputs for the `omopTableName`
#' argument in `summariseClinicalRecords()`.
#'
#' @return A character vector with table names.
#' @export
#'
#' @examples
#' library(OmopSketch)
#'
#' clinicalTables()
#'
clinicalTables <- function(){
 c("visit_occurrence", "visit_detail", "condition_occurrence",
   "drug_exposure", "procedure_occurrence", "device_exposure", "measurement",
   "observation","death", "note", "specimen", "payer_plan_period", "drug_era",
   "dose_era", "condition_era")
}


sampleCdm <- function(cdm, tables, sample, call = parent.frame()){

  if(is.numeric(sample)){
    if (sample >= omopgenerics::numberSubjects(cdm[["person"]])) {
      cli::cli_inform("The {.field person} table has \u2264 {.val {sample}} subjects; skipping sampling of the CDM.", call = call)
      return(cdm)
    }
    ids <- cdm[["person"]] |>
      dplyr::select("person_id") |>
      dplyr::slice_sample(n = as.integer(sample)) |>
      dplyr::pull("person_id")

  } else if(is.character(sample)) {
    if (!(sample %in% names(cdm))) {
      cli::cli_inform("The CDM doesn't contain the {.val {sample}} cohort; skipping sampling of the CDM.", call = call)
      return(cdm)
    }
    ids <- cdm[[sample]] |>
      dplyr::pull("subject_id")
  } else {
    return(cdm)
  }
  cdm <- omopgenerics::insertTable(cdm = cdm, name = "person_sample",
                                   table = dplyr::tibble("person_id" = sort(unique(ids))))

  for (table in tables) {
    cdm[[table]] <- cdm[[table]] |>
      dplyr::inner_join(cdm[["person_sample"]], by = "person_id")
  }
  return(cdm)
}

sampleOmopTable <- function(omopTable, sample) {
  if (is.null(sample)){
    return(omopTable)
  }
  cdm <- omopgenerics::cdmReference(omopTable)
  tableName <- omopgenerics::tableName(omopTable)
  cdm <- sampleCdm(cdm = cdm, tables = tableName, sample = sample)
  return(cdm[[tableName]])
}




validateStyle <- function(style, obj) {
  # check if style is NULL
  if (is.null(style)) {
    key <- paste0("visOmopResults.", obj, "Style")
    style <- getOption(x = key, default = "")
    if (style == "") {
      if (file.exists("_brand.yml")) {
        style <- "_brand.yml"
      } else {
        style <- list.files(system.file("brand", package = "OmopSketch"), full.names = TRUE, pattern = "^scarlet\\.yml$")
      }
    }
  }
  return(style)
}


validateType <- function(type, call = parent.frame()) {
  if (is.null(type)) {
    type <- getOption(x = "visOmopResults.tableType", default = "gt")
  }

  # assert choice
  choices <- visOmopResults::tableType()
  omopgenerics::assertChoice(type, choices = choices, length = 1, call = call)

  return(type)
}
