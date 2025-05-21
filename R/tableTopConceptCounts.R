#' Create a visual table of the most common concepts from `summariseConceptIdCounts()` output.
#' This function takes a `summarised_result` object and generates a formatted table highlighting the most frequent concepts.
#'
#' @param result A `summarised_result` object, typically returned by `summariseConceptIdCounts()`.
#' @param top Integer. The number of top concepts to display. Defaults to `10`.
#' @param type Character. The output table format. Defaults to `"gt"`. Use `visOmopResults::tableType()` to see all supported formats.
#'
#' @return A formatted table object displaying the top concepts from the summarised data.

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
#' result |> tableTopConceptCounts(top = 5)
#' }
tableTopConceptCounts <- function(result, top = 10, type = "gt") {

  rlang::check_installed("visOmopResults")
  omopgenerics::validateResultArgument(result)
  omopgenerics::assertNumeric(top, unique = TRUE, integerish = TRUE, min = 1, length = 1 )
  omopgenerics::assertChoice(type, visOmopResults::tableType())

  strata_cols <- omopgenerics::strataColumns(result)
  additional_cols <- omopgenerics::additionalColumns(result)
  additional_cols <- additional_cols[!grepl("source_concept", additional_cols)]
  # subset to result_type of interest
  result <- result |>
    omopgenerics::filterSettings(
      .data$result_type == "summarise_concept_id_counts"
    )
  if (nrow(result) == 0) {
    warnEmpty("summarise_concept_id_counts")
    return(emptyTable(type))
  }


  result <- result |>
    omopgenerics::splitAll() |>
    dplyr::group_by(dplyr::across(dplyr::any_of(c("time_interval", "sex", "age_group", "estimate_name")))) |>
    dplyr::mutate(estimate_value = as.numeric(.data$estimate_value)) |>
    dplyr::arrange(dplyr::desc(.data$estimate_value)) |>
    dplyr::slice_head(n = top) |>
    dplyr::ungroup() |>
    dplyr::select(dplyr::any_of(c("estimate_name", "omop_table", strata_cols, "variable_name", "variable_level", "source_concept_name", "source_concept_id")), dplyr::everything())

  sort_cols <- intersect(c(additional_cols, strata_cols), colnames(result))

  header <- c("cdm_name",additional_cols)
  group <- c("estimate_name", strata_cols)
  hide <- c("result_id", "estimate_type")
  estimateName <- c("N records" = "<count_records>",
                    "N subjects" = "<count_subjects>")
  visOmopResults::visTable(result |> dplyr::arrange(dplyr::across(dplyr::all_of(sort_cols))),
                           hide = hide,
                           rename = c("Concept name" = "variable_name", "Concept id" = "variable_level"),
                           estimateName = estimateName,
                           header = header,
                           group = group,
                           .options = list( merge = "all_columns"),
                           type = type) |>
    suppressMessages()

}
