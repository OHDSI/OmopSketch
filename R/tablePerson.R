
#' Visualise the output of `summarisePerson()`
#'
#' @param result A summarised_result object.
#' @inheritParams style-table
#'
#' @return A visualisation of the data summarising the person table.
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
#' }
#'
tablePerson <- function(result,
                        type = NULL,
                        style = NULL) {
  # check input
  result <- omopgenerics::validateResultArgument(result = result)

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
    header = "cdm_name",
    style = style,
    type = type,
    .options = list(caption = "Summary of person table")

  )
}
