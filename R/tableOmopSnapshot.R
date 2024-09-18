#' Create a gt table from a summarised omop snapshot
#'
#' @param result  Output from summariseOmopSnapshot()
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
#'   summariseOmopSnapshot() |>
#'   tableOmopSnapshot()
#'
#' PatientProfiles::mockDisconnect(cdm)
#'}
tableOmopSnapshot <- function(result){

  # Initial checks ----
  omopgenerics::validateResultArgument(result)

  if(result |> dplyr::tally() |> dplyr::pull("n") == 0){
    cli::cli_warn("result is empty.")

    return(
      result |>
        visOmopResults::splitGroup() |>
        dplyr::select("Estimate" = "estimate_name", "cdm_name") |>
        gt::gt()
    )
  }

  result <- result |>
    visOmopResults::filterSettings(.data$result_type == "summarise_omop_snapshot") |>
    dplyr::mutate(variable_name = gsub("_", " ", stringr::str_to_sentence(.data$variable_name)),
                  estimate_name = gsub("_", " ", stringr::str_to_sentence(.data$estimate_name))) |>
    visOmopResults::visOmopTable(
      hide = c("variable_level"),
      formatEstimateName = c("N" = "<Count>"),
      header = c("cdm_name"),
      renameColumns = c("Database name" = "cdm_name", "Estimate" = "estimate_name"),
      groupColumn = "variable_name"
    )

  return(result)
}
