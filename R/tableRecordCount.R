#' Create a visual table from a summariseRecordCount() result.
#' @param result A summarised_result object.
#' @param type Type of formatting output table, either "gt", "reactable" or "datatable".
#' @return A gt or flextable object with the summarised data.
#' @export
#'
#'
tableRecordCount <- function(result,
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
      .data$result_type == "summarise_record_count"
    ) |>
    dplyr::arrange(.data$additional_level)


  # check if it is empty
  if (nrow(result) == 0) {
    warnEmpty("summarise_record_count")
    return(emptyTable(type))
  }

  if (type %in% c("gt","datatable")) {

    result |>
      visOmopResults::visOmopTable(
        type = type,
        estimateName = c("Number of records in observation" = "<count>"),
        header = c("cdm_name", "estimate_name"),
        hide = c("interval",	"study_period_end",	"study_period_start", "variable_level", "variable_name"),
        rename = c("Database name" = "cdm_name"),
        columnOrder = c(additional_cols, strata_cols),
        groupColumn = c("omop_table"),
        .options = list(groupAsColumn = TRUE, merge = "all_columns", includeHeaderName = FALSE
        )
      )|>
      suppressMessages()

  } else if (type == "reactable") {

    rlang::check_installed("reactable")

    result |>
      omopgenerics::splitAll() |>
      dplyr::select(
        dplyr::any_of(c(
          "cdm_name",
          "omop_table",
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
          omop_table = reactable::colDef(name = "OMOP table"),
          estimate_value = reactable::colDef(name = "N records in observation")
        ),
        defaultColDef = reactable::colDef(
          sortable = TRUE,
          filterable = TRUE,
          resizable = TRUE
        ),
        groupBy = c("cdm_name", "omop_table", additional_cols, strata_cols),
        defaultExpanded = TRUE,
        searchable = TRUE,
        highlight = TRUE,
        bordered = TRUE,
        striped = TRUE,
        defaultPageSize = 20,
        paginationType = "simple"
      )
  }


}
