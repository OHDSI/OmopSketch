startDate <- function(name) {
  tables$start_date[tables$table_name == name]
}

endDate <- function(name) {
  tables$end_date[tables$table_name == name]
}

standardConcept <- function(name) {
  tables$standard_concept[tables$table_name == name]
}

sourceConcept <- function(name) {
  tables$source_concept[tables$table_name == name]
}

typeConcept <- function(name) {
  tables$type_concept[tables$table_name == name]
}

tableId <- function(name) {
  tables$id[tables$table_name == name]
}

warnFacetColour <- function(result, cols) {
  colsToWarn <- result |>
    dplyr::select(
      "cdm_name", "group_name", "group_level", "strata_name", "strata_level",
      "variable_name", "variable_level"
    ) |>
    dplyr::distinct() |>
    visOmopResults::splitAll() |>
    dplyr::select(!dplyr::any_of(unique(unlist(cols)))) |>
    as.list() |>
    purrr::map(unique)
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
  if (length(x) == 1) return(x)
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


createSettings <- function(result_type, result_id = 1L, package_name = "OmopSketch", study_period = NULL) {
  # Create the initial settings tibble
  settings <- dplyr::tibble(
    "result_id" = result_id,
    "result_type" = result_type,
    "package_name" = package_name,
    "package_version" = as.character(utils::packageVersion(package_name))
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


