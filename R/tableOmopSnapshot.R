#' Create a gt table from a summarised omop snapshot
#'
#' @param result  Output from summariseOmopSnapshot().
#' @param type Type of table.
#'
#' @return A gt object with the summarised data.
#' @export
#'
#' @examples
#' \donttest{
#' cdm <- mockOmopSketch(numberIndividuals = 1000)
#'
#' cdm |>
#'   summariseOmopSnapshot() |>
#'   tableOmopSnapshot()
#'
#' PatientProfiles::mockDisconnect(cdm)
#'}
tableOmopSnapshot <- function(result,
                              type = "gt") {
  # initial checks
  omopgenerics::validateResultArgument(result)
  omopgenerics::assertChoice(type, choicesTables())

  # subset to result_type of interest
  result <- result |>
    visOmopResults::filterSettings(
      .data$result_type == "summarise_omop_snapshot")

  # check if it is empty
  if (nrow(result) == 0) {
    warnEmpty("summarise_omop_snapshot")
    return(emptyTable(type))
  }

  result <- result |>
    dplyr::mutate(variable_name = gsub("_", " ", stringr::str_to_sentence(.data$variable_name)),
                  estimate_name = gsub("_", " ", stringr::str_to_sentence(.data$estimate_name))) |>
    visOmopResults::visOmopTable(
      type = type,
      hide = c("variable_level"),
      estimateName = c("N" = "<Count>"),
      header = c("cdm_name"),
      rename = c(
        "Database name" = "cdm_name",
        "Estimate" = "estimate_name",
        "Variable" = "variable_name"),
      groupColumn = "variable_name"
    )

  return(result)
}

warnEmpty <- function(resultType) {
  cli::cli_warn("`result` does not contain any `{resultType}` data.")
}
emptyTable <- function(type) {
  pkg <- type
  pkg[pkg == "tibble"] <- "dplyr"
  rlang::check_installed(pkg = pkg)
  x <- dplyr::tibble(`Table has no data` = character())
  switch (type,
    "tibble" = x,
    "gt" = gt::gt(x),
    "flextable" = flextable::flextable(x)
  )
}
choicesTables <- function() {
  c("tibble", "flextable", "gt")
}
