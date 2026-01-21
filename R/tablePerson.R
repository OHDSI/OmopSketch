#' Visualise the output of `summarisePerson()`
#'
#' @param result A summarised_result object (output of `summarisePerson()`).
#' @inheritParams style-table
#'
#' @return A formatted table visualisation.
#' @export
#'
#' @examples
#' \donttest{
#' library(OmopSketch)
#' library(omock)
#'
#' cdm <- mockCdmFromDataset(datasetName = "GiBleed", source = "duckdb")
#'
#' result <- summarisePerson(cdm = cdm)
#'
#' tablePerson(result = result)
#'
#' cdmDisconnect(cdm = cdm)
#' }
#'
tablePerson <- function(result,
                        header = "cdm_name",
                        hide = omopgenerics::settingsColumns(result),
                        groupColumn = character(),
                        type = NULL,
                        style = NULL) {
  # check input
  result <- omopgenerics::validateResultArgument(result = result)
  style <- validateStyle(style = style, obj = "table")
  type <- validateType(type)

  result <- result |>
    omopgenerics::filterSettings(
      .data$result_type == "summarise_person"
    )

  # check if it is empty
  if (nrow(result) == 0) {
    warnEmpty("summarise_person")
    return(visOmopResults::emptyTable(type = type, style = style))
  }

  setting_cols <- omopgenerics::settingsColumns(result)

  custom_order <- c("Number subjects", "Number subjects not in observation", "Sex", "Sex source", "Race", "Race source", "Ethnicity", "Ethnicity source", "Year of birth", "Month of birth", "Day of birth", "Location", "Provider", "Care site")

  result |>
    dplyr::mutate(variable_name = factor(.data$variable_name, levels = custom_order)) |>
    dplyr::arrange(.data$variable_name, .data$variable_level, .data$estimate_name) |>
    visOmopResults::visOmopTable(
      estimateName = c(
        "N (%)" = "<count> (<percentage>%)",
        "N" = "<count>",
        "Missing (%)" = "<count_missing> (<percentage_missing>%)",
        "Median [Q25 - Q75]" = "<median> [<q25> - <q75>]",
        "90% Range [Q05 to Q95]" = "<q05> to <q95>",
        "Range [min to max]" = "<min> to <max>",
        "Zero count (%)" = "<count_0> (<percentage_0>%)",
        "Distinct values" = "<distinct_values>"
      ),
      header = header,
      hide = hide,
      style = style,
      type = type,
      groupColumn = groupColumn,
      settingsColumn = setting_cols,
      .options = list(caption = "Summary of person table")
    )
}
