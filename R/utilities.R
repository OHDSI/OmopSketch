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

#' Get a Synapse-compatible concept table reference
#'
#' Azure Synapse cannot create temp tables with VARCHAR(MAX) columns in
#' columnstore indexes. This helper casts the problematic columns to
#' VARCHAR(255) for compatibility.
#'
#' @param cdm A CDM reference object
#' @return A dplyr lazy table reference with casted columns
#' @noRd
getConceptTable <- function(cdm) {
  con <- CDMConnector::cdmCon(cdm)
  isSynapse <- isSynapseConnection(con)

  if (isSynapse) {
    # Cast VARCHAR(MAX) columns to VARCHAR(255) for Synapse compatibility
    cdm[["concept"]] |>
      dplyr::mutate(
        concept_name = dplyr::sql("CAST(concept_name AS VARCHAR(255))"),
        domain_id = dplyr::sql("CAST(domain_id AS VARCHAR(255))"),
        vocabulary_id = dplyr::sql("CAST(vocabulary_id AS VARCHAR(255))"),
        concept_class_id = dplyr::sql("CAST(concept_class_id AS VARCHAR(255))"),
        standard_concept = dplyr::sql("CAST(standard_concept AS VARCHAR(20))"),
        concept_code = dplyr::sql("CAST(concept_code AS VARCHAR(255))")
      )
  } else {
    cdm[["concept"]]
  }
}

#' Check if connection is to Azure Synapse or SQL Server
#'
#' @param con A DBI connection object
#' @return Logical indicating if this is a Synapse/SQL Server connection that needs VARCHAR casting
#' @noRd
isSynapseConnection <- function(con) {
  if (is.null(con)) return(FALSE)

  # Check connection class for SQL Server/ODBC indicators
  conClass <- class(con)
  isMssql <- any(grepl("SQL Server|Microsoft|odbc", conClass, ignore.case = TRUE))

  # For any MSSQL connection, use the safe casting approach by default
  # This avoids VARCHAR(MAX) issues in columnstore indexes
  if (isMssql) {
    return(getOption("OmopSketch.useSynapseCompatibility", default = TRUE))
  }

  return(FALSE)
}

#' Add birth_date column to a person table
#'
#' Creates birth_date from year_of_birth, month_of_birth, day_of_birth in a
#' cross-database compatible way.
#'
#' @param person A dplyr lazy table reference to the person table
#' @param cdm The CDM reference (used to detect connection type)
#' @return The person table with birth_date column added
#' @noRd
addBirthDate <- function(person, cdm) {
  con <- CDMConnector::cdmCon(cdm)
  isMssql <- isSynapseConnection(con)

 if (isMssql) {
    # SQL Server/Synapse: use DATEFROMPARTS
    person |>
      dplyr::mutate(
        birth_date = dplyr::sql("DATEFROMPARTS(\"year_of_birth\", COALESCE(\"month_of_birth\", 1), COALESCE(\"day_of_birth\", 1))")
      )
  } else {
    # Other databases (DuckDB, PostgreSQL, etc.): use make_date
    person |>
      dplyr::mutate(
        birth_date = dplyr::sql("make_date(\"year_of_birth\", COALESCE(\"month_of_birth\", 1), COALESCE(\"day_of_birth\", 1))")
      )
  }
}

#' Add birthdate column to person table (with birth_datetime fallback)
#'
#' Creates birthdate from birth_datetime (if available) or year_of_birth,
#' month_of_birth, day_of_birth in a cross-database compatible way.
#'
#' @param person A dplyr lazy table reference to the person table
#' @param cdm The CDM reference (used to detect connection type)
#' @return The person table with birthdate column added
#' @noRd
addBirthDateWithDatetime <- function(person, cdm) {
  con <- CDMConnector::cdmCon(cdm)
  isMssql <- isSynapseConnection(con)

  if (!("birth_datetime" %in% colnames(person))) {
    return(addBirthDate(person, cdm) |>
             dplyr::rename(birthdate = "birth_date"))
  }

  if (isMssql) {
    # SQL Server/Synapse: use DATEFROMPARTS
    person |>
      dplyr::mutate(
        birthdate = dplyr::sql("CASE WHEN \"birth_datetime\" IS NOT NULL THEN CAST(\"birth_datetime\" AS DATE) ELSE DATEFROMPARTS(\"year_of_birth\", COALESCE(\"month_of_birth\", 1), COALESCE(\"day_of_birth\", 1)) END")
      )
  } else {
    # Other databases: use make_date
    person |>
      dplyr::mutate(
        birthdate = dplyr::sql("CASE WHEN \"birth_datetime\" IS NOT NULL THEN CAST(\"birth_datetime\" AS DATE) ELSE make_date(\"year_of_birth\", COALESCE(\"month_of_birth\", 1), COALESCE(\"day_of_birth\", 1)) END")
      )
  }
}

#' Truncate dates to first of month (database-specific)
#'
#' @param tbl A dplyr lazy table
#' @param cdm The CDM reference
#' @param start_col Name of the start date column
#' @param end_col Name of the end date column
#' @return Table with start_date and end_date truncated to first of month
#' @noRd
truncateDatesToMonth <- function(tbl, cdm, start_col, end_col) {
  con <- CDMConnector::cdmCon(cdm)
  isMssql <- isSynapseConnection(con)

  if (isMssql) {
    # SQL Server: use DATEFROMPARTS and DATEPART
    start_sql <- paste0("DATEFROMPARTS(DATEPART(YEAR, \"", start_col, "\"), DATEPART(MONTH, \"", start_col, "\"), 1)")
    end_sql <- paste0("CASE WHEN \"", end_col, "\" IS NULL THEN NULL ELSE DATEFROMPARTS(DATEPART(YEAR, \"", end_col, "\"), DATEPART(MONTH, \"", end_col, "\"), 1) END")
  } else {
    # Other databases: use make_date and extract
    start_sql <- paste0("make_date(EXTRACT(YEAR FROM \"", start_col, "\")::INTEGER, EXTRACT(MONTH FROM \"", start_col, "\")::INTEGER, 1)")
    end_sql <- paste0("CASE WHEN \"", end_col, "\" IS NULL THEN NULL ELSE make_date(EXTRACT(YEAR FROM \"", end_col, "\")::INTEGER, EXTRACT(MONTH FROM \"", end_col, "\")::INTEGER, 1) END")
  }

  tbl |>
    dplyr::mutate(
      start_date = dplyr::sql(start_sql),
      end_date = dplyr::sql(end_sql)
    )
}
