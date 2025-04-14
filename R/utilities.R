warnFacetColour <- function(result, cols) {
  colsToWarn <- result |>
    dplyr::select(
      "cdm_name", "group_name", "group_level", "strata_name", "strata_level",
      "variable_name", "variable_level"
    ) |>
    dplyr::distinct() |>
    omopgenerics::splitAll() |>
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
