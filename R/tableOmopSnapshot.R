
#' Create a visual table from a summarise_omop_snapshot result.
#' @param result  Output from summariseOmopSnapshot().
#' @param type Type of formatting output table, either "gt" or "flextable".
#' @return A gt or flextable object with the summarised data.
#' @export
#' @examples
#' \donttest{
#' cdm <- mockOmopSketch(numberIndividuals = 10)
#'
#' result <- summariseOmopSnapshot(cdm)
#'
#' result |>
#'   tableOmopSnapshot()
#'
#' PatientProfiles::mockDisconnect(cdm)
#' }
tableOmopSnapshot <- function(result,
                              type = "gt") {
  # initial checks
  rlang::check_installed("visOmopResults")
  omopgenerics::validateResultArgument(result)
  omopgenerics::assertChoice(type, choicesTables())

  # subset to result_type of interest
  result <- result |>
    omopgenerics::filterSettings(
      .data$result_type == "summarise_omop_snapshot")

  # check if it is empty
  if (nrow(result) == 0) {
    warnEmpty("summarise_omop_snapshot")
    return(emptyTable(type))
  }

  result <- result |>
    formatColumn(c("variable_name", "estimate_name")) |>
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
formatColumn <- function(result, col) {
  for (x in col) {
    result <- result |>
      dplyr::mutate(!!x := gsub("_", " ", stringr::str_to_sentence(.data[[x]])))
  }
  return(result)
}
emptyPlot <- function(type = "ggplot2", title = NULL, subtitle = NULL) {
  if (type == "ggplot2") {
    ggplot2::ggplot() +
      ggplot2::labs(title = title, subtitle = subtitle)
  }
}
