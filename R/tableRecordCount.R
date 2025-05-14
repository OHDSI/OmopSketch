#' Create a visual table from a summariseRecordCount() result.
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
#' summarisedResult <- summariseRecordCount(
#'   cdm = cdm,
#'   omopTableName = c("condition_occurrence", "drug_exposure"),
#'   interval = "years",
#'   ageGroup = list("<=20" = c(0, 20), ">20" = c(21, Inf)),
#'   sex = TRUE
#' )
#'
#' summarisedResult |>
#'   tableRecordCount()
#'
#' PatientProfiles::mockDisconnect(cdm = cdm)
#' }
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
    dplyr::arrange(.data$additional_level) |>
    omopgenerics::splitAll() |>
    dplyr::select(
      dplyr::any_of(c(
        "cdm_name",
        "omop_table",
        "estimate_value",
        "variable_name",
        additional_cols,
        strata_cols
      ))
    ) |>
    dplyr::mutate(estimate_value = as.numeric(.data$estimate_value))


  # check if it is empty
  if (nrow(result) == 0) {
    warnEmpty("summarise_record_count")
    return(emptyTable(type))
  }

  if (type %in% c("gt","datatable")) {

    rename_vec <- c(
      "Database name" = "cdm_name",
      "OMOP table" = "omop_table",
      "Sex" = "sex",
      "Age group" = "age_group",
      "Time interval" = "time_interval"
    )

    rename_vec <- rename_vec[rename_vec %in% names(result)]

    result |>
      dplyr::rename(!!!rename_vec) |>
      visOmopResults::formatHeader(
        header = c("Database name", "variable_name"),
        includeHeaderName = FALSE
      ) |>
      visOmopResults::formatTable(type = type, groupColumn = list(" " = c("OMOP table")), groupAsColumn = TRUE, merge = "all_columns")|>
      suppressMessages()

  } else if (type == "reactable") {

    rlang::check_installed("reactable")

    result |>
      tidyr::pivot_wider(
        names_from = "variable_name",
        values_from = "estimate_value"
      ) |>
      reactable::reactable(
        columns = list(
          time_interval = reactable::colDef(name = "Time Interval"),
          sex = reactable::colDef(name = "Sex"),
          age_group = reactable::colDef(name = "Age Group"),
          cdm_name = reactable::colDef(name = "Database name"),
          omop_table = reactable::colDef(name = "OMOP table")
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
