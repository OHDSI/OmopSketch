
#' Visualise the output of `summarisePerson()`
#'
#' @param result A summarised_result object.
#' @param style A character string or custom R code to define the visual
#' formatting of the table.
#' @param type The desired format of the output table. See
#' `visOmopResults::tableType()` for allowed options.
#'
#' @return A visualisation of the data summarising the person table.
#' @export
#'
#' @examples
#' \donttest{
#' library(OmopSketch)
#'
#' cdm <- mockOmopSketch(numberIndividuals = 100)
#'
#' result <- summarisePerson(cdm = cdm)
#'
#' tablePerson(result = result)
#' }
#'
tablePerson <- function(result,
                        style = "default",
                        type = "gt") {
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
    type = type
  )
}
