#' Create a visual table from a summariseInObservation() result.
#' @param result A summarised_result object.
#' @param type Type of formatting output table, either "gt", "reactable" or "datatable".
#' @return A gt or flextable object with the summarised data.
#' @export
#'
#'
tableInObservation <- function(result,
                             type = "gt") {
  # initial checks
  rlang::check_installed("visOmopResults")
  omopgenerics::validateResultArgument(result)
  omopgenerics::assertChoice(type, c("gt","reactable", "datatable"))
  strata_cols <- omopgenerics::strataColumns(result)
  additional_cols <- omopgenerics::additionalColumns(result)

  # subset to result_type of interest
  result <- result |>
    omopgenerics::filterSettings(
      .data$result_type == "summarise_in_observation"
    ) |>
    omopgenerics::splitStrata() |>
    dplyr::arrange(.data$additional_level, !!!rlang::syms(strata_cols), .data$variable_name) |>
    omopgenerics::uniteStrata(cols = strata_cols)


  # check if it is empty
  if (nrow(result) == 0) {
    warnEmpty("summarise_in_observation")
    return(emptyTable(type))
  }

  if (type %in% c("gt","datatable")) {
    formatEstimates <- c(
      "N (%)" = "<count> (<percentage>%)",
      "Median" = "<median>")
    result |>
      visOmopResults::visOmopTable(
        type = type,
        estimateName = formatEstimates,
        header = c("cdm_name"),
        hide = c("interval",	"study_period_end",	"study_period_start", "variable_level", "omop_table"),
        rename = c("Database name" = "cdm_name"),
        columnOrder = c(additional_cols, strata_cols, "variable_name", "estimate_name"),
        groupColumn = c(additional_cols),
        .options = list(groupAsColumn = TRUE, merge = "all_columns", includeHeaderName = TRUE
        )
      )|>
      suppressMessages()

  } else if (type == "reactable") {

    rlang::check_installed("reactable")

    result |>
      visOmopResults::formatEstimateName(estimateName = c(
        "N (%)" = "<count> (<percentage>%)", "Median" = "<median>"
      )) |>
      omopgenerics::splitAll() |>
      dplyr::select(
        dplyr::any_of(c(
          "cdm_name",
          "variable_name",
          "estimate_name",
          "estimate_value",
          additional_cols,
          strata_cols
        ))
      ) |>
      reactable::reactable(
        columns = list(
          time_interval = reactable::colDef(name = "Time Interval"),
          sex = reactable::colDef(name = "Sex"),
          age_group = reactable::colDef(name = "Age Group"),
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
