#' Create a visual table from a summariseConceptIdCounts() result.
#' @param result A summarised_result object.
#' @param display A character string indicating which subset of the data to display. Options are:
#'   - `"overall"`: Show all source and standard concepts.
#'   - `"standard"`: Show only standard concepts.
#'   - `"source"`: Show only source codes.
#'   - `"missing standard"`: Show only source codes that are missing a mapped standard concept.
#' @param type Type of formatting output table, either "reactable" or "datatable".
#' @return A gt or flextable object with the summarised data.
#' @export
#' @examples
#' \donttest{
#' library(OmopSketch)
#' library(CDMConnector)
#' library(duckdb)
#'
#' requireEunomia()
#' con <- dbConnect(duckdb(), eunomiaDir())
#' cdm <- cdmFromCon(con = con, cdmSchema = "main", writeSchema = "main")
#'
#' result <- summariseConceptIdCounts(cdm, "condition_occurrence")
#' result |> tableConceptIdCounts()
#' }
tableConceptIdCounts <- function(result,
                                 display = "overall",
                                 type = "reactable") {
  # initial checks
  rlang::check_installed("visOmopResults")
  omopgenerics::validateResultArgument(result)
  omopgenerics::assertChoice(type, c("reactable", "datatable"))
  omopgenerics::assertChoice(display, c("overall", "standard", "source", "missing standard", "missing source"))
  strata_cols <- omopgenerics::strataColumns(result)
  additional_cols <- omopgenerics::additionalColumns(result)
  additional_cols <- additional_cols[!grepl("source_concept", additional_cols)]
  # subset to result_type of interest
  result <- result |>
    omopgenerics::filterSettings(
      .data$result_type == "summarise_concept_id_counts"
    ) |>
    omopgenerics::splitStrata() |>
    omopgenerics::splitAdditional() |>
    dplyr::arrange(dplyr::across(dplyr::all_of(additional_cols)), .data$variable_name, dplyr::across(dplyr::all_of(strata_cols))) |>
    dplyr::rename("standard_concept_id" = "variable_level", "standard_concept_name" = "variable_name")

  if (display == "overall") {
    cols_to_format <- c("standard_concept_name", "standard_concept_id","source_concept_name", "source_concept_id")
  } else if (display == "standard") {
    cols_to_format <- c("standard_concept_name", "standard_concept_id")
    result <- result |>
      dplyr::select(!dplyr::any_of(c("source_concept_id", "source_concept_name")))
  } else if (display == "source") {
    cols_to_format <- c("source_concept_name", "source_concept_id")
    result <- result |>
      dplyr::select(!dplyr::any_of(c("standard_concept_id", "standard_concept_name")))
  } else if (display == "missing standard") {
    result <- result |>
      dplyr::filter(as.integer(.data$standard_concept_id) == 0L) |>
      dplyr::select(!dplyr::any_of(c("standard_concept_id", "standard_concept_name")))
    cols_to_format <- c("source_concept_name", "source_concept_id")
  } else if (display == "missing source") {
    result <- result |>
      dplyr::filter(as.integer(.data$source_concept_id) == 0L | is.na(.data$source_concept_id)) |>
      dplyr::select(!dplyr::any_of(c("source_concept_id", "source_concept_name")))

    cols_to_format <- c("standard_concept_name", "standard_concept_id")
  }

  # check if it is empty
  if (nrow(result) == 0) {
    warnEmpty("summarise_concept_id_counts")
    return(emptyTable(type))
  }

  formatted_result <- result |>
    formatColumn(cols_to_format) |>
    dplyr::mutate(
      estimate_value = as.numeric(.data$estimate_value),
      estimate_name = dplyr::case_when(
        .data$estimate_name == "count_subjects" ~ "N subjects",
        .data$estimate_name == "count_records" ~ "N records",
        TRUE ~ .data$estimate_name
      )
    ) |>
    dplyr::select(
      dplyr::any_of(c(
        "cdm_name",
        "group_level",
        "standard_concept_name",
        "standard_concept_id",
        "source_concept_name",
        "source_concept_id",
        "estimate_name",
        "estimate_value"
      )),
      dplyr::everything()
    )
  if (type == "datatable") {



    rename_vec <- c(
      "Database name" = "cdm_name",
      "OMOP table" = "group_level",
      "Standard concept name" = "standard_concept_name",
      "Standard concept id" = "standard_concept_id",
      "Source concept name" = "source_concept_name",
      "Source concept id" = "source_concept_id",
      "Sex" = "sex",
      "Age group" = "age_group"
    )

    rename_vec <- rename_vec[rename_vec %in% names(formatted_result)]

    formatted_result |>
      dplyr::rename(!!!rename_vec) |>
      dplyr::select(!c("group_name", "result_id")) |>
      visOmopResults::formatHeader(
        header = c("Database name", "estimate_name"),
        includeHeaderName = FALSE
      ) |>
      dplyr::select(!"estimate_type") |>
      visOmopResults::formatTable(type = "datatable", groupColumn = list(" " = c("OMOP table", additional_cols)))

  } else if (type == "reactable") {

    rlang::check_installed("reactable")

    formatted_result |>
      tidyr::pivot_wider(
        names_from = "estimate_name",
        values_from = "estimate_value"
      ) |>
      reactable::reactable(
        columns = list(
          result_id = reactable::colDef(show = FALSE),
          group_name = reactable::colDef(show = FALSE),
          estimate_type = reactable::colDef(show = FALSE),
          time_interval = reactable::colDef(name = "Time Interval"),
          sex = reactable::colDef(name = "Sex"),
          age_group = reactable::colDef(name = "Age Group"),
          cdm_name = reactable::colDef(name = "Database name"),
          group_level = reactable::colDef(name = "OMOP table"),
          standard_concept_name = reactable::colDef(name = "Standard concept name"),
          standard_concept_id = reactable::colDef(name = "Standard concept id"),
          source_concept_name = reactable::colDef(name = "Source concept name"),
          source_concept_id = reactable::colDef(name = "Source concept id")
        ),
        defaultColDef = reactable::colDef(
          sortable = TRUE,
          filterable = TRUE,
          resizable = TRUE
        ),
        groupBy = c("cdm_name", "group_level", additional_cols, strata_cols),
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
