#' Create a visual table from a summariseInObservation() result.
#' @param result A summarised_result object.
#' @param type Type of formatting output table, either "gt", "reactable" or "datatable".
#' @return A gt or flextable object with the summarised data.
#' @export
#' @examples
#' \donttest{
#' library(dplyr, warn.conflicts = FALSE)
#'
#' cdm <- mockOmopSketch()
#'
#' result <- summariseInObservation(
#'   cdm$observation_period,
#'   interval = "months",
#'   output = c("person-days", "record"),
#'   ageGroup = list("<=60" = c(0, 60), ">60" = c(61, Inf)),
#'   sex = TRUE
#' )
#'
#' result |>
#'   tableInObservation()
#'
#' PatientProfiles::mockDisconnect(cdm)
#' }
tableInObservation <- function(result,
                               type = "gt") {
  # initial checks
  rlang::check_installed("visOmopResults")
  omopgenerics::validateResultArgument(result)
  omopgenerics::assertChoice(type, c("gt", "reactable", "datatable"))
  strata_cols <- omopgenerics::strataColumns(result)
  additional_cols <- omopgenerics::additionalColumns(result)

  # subset to result_type of interest
  formatted_result <- result |>
    omopgenerics::filterSettings(
      .data$result_type == "summarise_in_observation"
    ) |>
    omopgenerics::splitAll() |>
    dplyr::arrange(!!!rlang::syms(additional_cols), !!!rlang::syms(strata_cols), .data$variable_name)

  # check if it is empty
  if (nrow(formatted_result) == 0) {
    warnEmpty("summarise_in_observation")
    return(emptyTable(type))
  }


  rename_vec <- c(
    "Database name" = "cdm_name",
    "Sex" = "sex",
    "Age group" = "age_group",
    "Variable name" = "variable_name",
    "Time interval" = "time_interval"
  )

  rename_vec <- rename_vec[rename_vec %in% names(formatted_result)]
  group <- if ("time_interval" %in% additional_cols) "Time interval" else NULL
  if (type == "gt") {
    formatEstimates <- c(
      "N (%)" = "<count> (<percentage>%)",
      "Median" = "<median>"
    )
    formatted_result |>
      dplyr::rename(!!!rename_vec) |>
      visOmopResults::formatEstimateName(estimateName = formatEstimates) |>
      dplyr::rename("Estimate name" = .data$estimate_name) |>
      dplyr::select(dplyr::any_of(c(
        "Database name",
        "Variable name",
        "Estimate name",
        "estimate_value",
        "Sex",
        "Age group",
        "Time interval"
      ))) |>
      visOmopResults::formatHeader(
        header = c("Database name"),
        includeHeaderName = TRUE
      ) |>
      visOmopResults::formatTable(type = "gt", groupColumn = group, groupAsColumn = TRUE, merge = "all_columns") |>
      suppressMessages()
  } else if (type == "datatable") {

    formatted_result |>
      dplyr::rename(!!!rename_vec) |>
      dplyr::rename("Estimate name" = .data$estimate_name) |>
      dplyr::mutate(estimate_value = as.numeric(.data$estimate_value)) |>
      dplyr::select(dplyr::any_of(c(
        "Database name",
        "Variable name",
        "Estimate name",
        "estimate_value",
        "Sex",
        "Age group",
        additional_cols
      ))) |>
      visOmopResults::formatHeader(
        header = c("Database name"),
        includeHeaderName = TRUE
      ) |>
      visOmopResults::formatTable(type = "datatable", groupColumn = group)
  } else if (type == "reactable") {
    rlang::check_installed("reactable")

    formatted_result |>
      dplyr::mutate(estimate_value = as.numeric(.data$estimate_value)) |>
      dplyr::select(dplyr::any_of(c(
        "cdm_name",
        "variable_name",
        "estimate_name",
        "estimate_value",
        strata_cols,
        additional_cols
      ))) |>
      reactable::reactable(
        columns = list(
          time_interval = reactable::colDef(name = "Time interval"),
          sex = reactable::colDef(name = "Sex"),
          age_group = reactable::colDef(name = "Age group"),
          cdm_name = reactable::colDef(name = "Database name"),
          variable_name = reactable::colDef(name = "Variable name"),
          estimate_name = reactable::colDef(name = "Estimate name"),
          estimate_value = reactable::colDef(name = "Estimate value")
        ),
        defaultColDef = reactable::colDef(
          sortable = TRUE,
          filterable = TRUE,
          resizable = TRUE
        ),
        groupBy = c("cdm_name", additional_cols, strata_cols, "variable_name"),
        defaultExpanded = TRUE,
        searchable = TRUE,
        highlight = TRUE,
        bordered = TRUE,
        striped = TRUE,
        defaultPageSize = 20,
        paginationType = "simple"
      ) |>
      suppressMessages()
  }
}
