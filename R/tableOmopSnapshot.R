#' Create a gt table from a summarised omop snapshot
#'
#' @param omopSnapshot  Output from summariseOmopSnapshot()
#'
#' @return A gt object with the summarised data.
#' @export
#'
#' @examples
#' \donttest{
#'library(dplyr)
#'library(OmopSketch)
#'
#' cdm <- mockOmopSketch(numberIndividuals = 1000)
#'
#' cdm |>
#' summariseOmopSnapshot() |>
#' tableOmopSnapshot()
#'}
tableOmopSnapshot <- function(summarisedOmopSnapshot){
  # Initial checks ----
  omopgenerics::assertClass(summarisedOmopSnapshot, "summarised_result")

  if(summarisedOmopSnapshot |> dplyr::tally() |> dplyr::pull("n") == 0){
    cli::cli_warn("summarisedOmopSnapshot is empty.")

    return(
      summarisedOmopSnapshot |>
        visOmopResults::splitGroup() |>
        dplyr::select("Estimate" = "variable_name", "cdm_name") |>
        gt::gt()
    )
  }

  t <- dplyr::tibble(
    "variable_name" = c("person_count", "snapshot_date", "vocabulary",
                        "cdm", "cdm", "cdm", "cdm", "cdm", "cdm", "cdm",
                        "observation_period_count", "observation_period_start_date", "observation_period_end_date"),
    "estimate_name" = c("count", "value", "version",
                        "description", "documentation_reference", "holder_name", "release_date", "source_name","source_type","version",
                        "count", "min","max"),
    "var" = c("General", "General", "General",
              "CDM", "CDM", "CDM", "CDM", "CDM", "CDM", "CDM",
              "Observation period", "Observation period", "Observation period"),
    "Estimate" = c("Person count", "Snapshot date", "Vocabulary version",
           "Description", "Documentation reference", "Holder_name", "Release date", "Source name","Source type","Version",
           "Count", "Start date", "End date")
  ) |>
    dplyr::full_join(
      summarisedOmopSnapshot |>
        visOmopResults::splitAll(),
      by = c("variable_name", "estimate_name")
    )

  options(warn=-1)
  t <- t |>
      dplyr::mutate(estimate_value = dplyr::if_else(.data$estimate_name == "count",
                                                  format(as.numeric(.data$estimate_value), big.mark = ",", digits = 1),
                                                  .data$estimate_value)
    )
  options(warn=0)

  t <- t |>
    dplyr::select(-c("result_id", "variable_name", "variable_level", "estimate_name", "estimate_type")) |>
    visOmopResults::formatHeader(header = "cdm_name") |>
    visOmopResults::gtTable(groupColumn = "var", groupOrder = c("General", "CDM", "Observation period"))

  return(t)
}
