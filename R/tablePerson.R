
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
                        type = NULL,
                        style = NULL) {
  # check input
  result <- omopgenerics::validateResultArgument(result = result)
  style <- validateStyle(style = style, obj = "table")

  result <- result |>
    omopgenerics::filterSettings(
      .data$result_type == "summarise_person"
    )

  # check if it is empty
  if (nrow(result) == 0) {
    warnEmpty("summarise_person")
    return(emptyTable(type))
  }

  setting_cols <- omopgenerics::settingsColumns(result)
  setting_cols <- setting_cols[!setting_cols %in% c("study_period_end", "study_period_start")]

  visOmopResults::visOmopTable(
    result = result,
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
    header = c("cdm_name", setting_cols),
    style = style,
    type = type,
    settingsColumn = setting_cols,

    .options = list(caption = "Summary of person table")

  )
}
