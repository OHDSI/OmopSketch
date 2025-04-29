#' Create a visual table from a summariseConceptIdCounts() result.
#' @param result A summarised_result object.
#' @param filter A character string indicating which subset of the data to display. Options are:
#'   - `"overall"`: Show all source and standard concepts.
#'   - `"standard"`: Show only standard concepts.
#'   - `"source"`: Show only source codes.
#'   - `"missing standard"`: Show only source codes that are missing a mapped standard concept.
#' @param type Type of formatting output table, either "reactable" or "datatable".
#' @return A gt or flextable object with the summarised data.
#' @export
#'
#'
tableConceptIdCounts <- function(result,
                                 filter = "overall",
                                 type = "reactable") {
  # initial checks
  rlang::check_installed("visOmopResults")
  omopgenerics::validateResultArgument(result)
  omopgenerics::assertChoice(type, c("reactable", "datatable"))
  omopgenerics::assertChoice(filter, c("overall", "standard", "source", "missing standard", "missing source"))
  strata_cols <- omopgenerics::strataColumns(result)
  additional_cols <- omopgenerics::additionalColumns(result)
  additional_cols <- additional_cols[additional_cols != "source_concept"]
  # subset to result_type of interest
  result <- result |>
    omopgenerics::filterSettings(
      .data$result_type == "summarise_concept_id_counts"
    ) |>
    omopgenerics::splitStrata() |>
    omopgenerics::splitAdditional() |>
    dplyr::arrange(dplyr::across(dplyr::all_of(additional_cols)), .data$variable_name, dplyr::across(dplyr::all_of(strata_cols))) |>
    dplyr::rename("standard_concept" = "variable_level", "concept_name" = "variable_name")

  if (filter == "overall") {
    cols_to_format <- c("concept_name", "standard_concept", "source_concept")
    variableLevel <- "standard_concept"
  } else if (filter == "standard") {
    cols_to_format <- c("concept_name", "standard_concept")
    result <- result |>
      dplyr::select(!"source_concept")
  } else if (filter == "source") {
    cols_to_format <- c("concept_name", "source_concept")
    result <- result |>
      dplyr::select(!"standard_concept")
  } else if (filter == "missing standard") {
    result <- result |>
      dplyr::filter(as.integer(.data$standard_concept) == 0L) |>
      dplyr::select(!"standard_concept")
    cols_to_format <- c("concept_name", "source_concept")
  } else if (filter == "missing source") {
    result <- result |>
      dplyr::filter(as.integer(.data$source_concept) == 0L | is.na(.data$source_concept)) |>
      dplyr::select(!"source_concept")

    cols_to_format <- c("concept_name", "standard_concept")
  }

  # check if it is empty
  if (nrow(result) == 0) {
    warnEmpty("summarise_concept_id_counts")
    return(emptyTable(type))
  }

  formatted_result <- result |>
    formatColumn(cols_to_format) |>
    dplyr::select(
      dplyr::any_of(c(
        "cdm_name",
        "group_level",
        "concept_name",
        "standard_concept",
        "source_concept",
        "estimate_name",
        "estimate_value"
      )),
      dplyr::everything()
    )

  if (type == "datatable") {

    estimateNames <- formatted_result |>
      dplyr::distinct(.data$estimate_name) |>
      dplyr::pull()

    estimateName <- c()
    if ("count_records" %in% estimateNames) {
      estimateName <- c(estimateName, "N records" = "<count_records>")
    }

    if ("count_subjects" %in% estimateNames) {
      estimateName <- c(estimateName, "N persons" = "<count_subjects>")
    }


    rename_vec <- c(
      "Database name" = "cdm_name",
      "OMOP Table" = "group_level",
      "Concept Name" = "concept_name",
      "Standard Concept ID" = "standard_concept",
      "Source Concept ID" = "source_concept",
      "Sex" = "sex",
      "Age group" = "age_group"
    )

    rename_vec <- rename_vec[rename_vec %in% names(formatted_result)]

    formatted_result |>
      dplyr::rename(!!!rename_vec) |>
      dplyr::select(!c("group_name", "result_id")) |>
      visOmopResults::formatEstimateName(estimateName = estimateName) |>
      visOmopResults::formatHeader(
        header = c("Database name", "estimate_name"),
        includeHeaderName = FALSE
      ) |>
      dplyr::select(!"estimate_type") |>
      visOmopResults::formatTable(type = "datatable", groupColumn = list(" " = c("OMOP Table", additional_cols)))

  } else if (type == "reactable") {

    rlang::check_installed("reactable")

    formatted_result |>
      tidyr::pivot_wider(
        names_from = .data$estimate_name,
        values_from = .data$estimate_value
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
          concept_name = reactable::colDef(name = "Concept name"),
          standard_concept = reactable::colDef(name = "Standard concept id"),
          source_concept = reactable::colDef(name = "Source concept id"),
          count_records = reactable::colDef(name = "N records"),
          count_subjects = reactable::colDef(name = "N subjects")
        ),
        defaultColDef = reactable::colDef(
          sortable = TRUE,
          filterable = TRUE,
          resizable = TRUE
        ),
        groupBy = c("group_level", additional_cols, strata_cols),
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
