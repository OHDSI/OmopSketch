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
      "variable_name", "variable_level", "additional_name", "additional_level"
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
  if (length(x) == 1) return(x)
  len <- length(x)
  paste0(paste0(x[-len], collapse = ", "), " ", sep, " ", x[len])
}
