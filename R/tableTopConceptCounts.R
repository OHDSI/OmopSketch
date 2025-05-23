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


  res <- result |>
    omopgenerics::splitAll() |>
    dplyr::mutate(estimate_value = as.numeric(.data$estimate_value)) |>
    tidyr::pivot_wider(
      names_from = "estimate_name",
      values_from = "estimate_value"
    )
    estimateForm <- "Standard: %s (%s); Source: %s (%s); %i"
    if (type == "gt") {
      estimateForm <- stringr::str_replace_all(estimateForm, ";", " <br>")
    }

  if ("count_records" %in% colnames(res)) {
    records <- res |>
      dplyr::group_by(dplyr::across(dplyr::any_of(c("time_interval", "sex", "age_group")))) |>
      dplyr::arrange(dplyr::desc(.data$count_records)) |>
      dplyr::slice_head(n = top) |>
      dplyr::mutate("top" = dplyr::row_number()) |>
      dplyr::ungroup() |>
      dplyr::mutate(estimate_value = sprintf(
        .env$estimateForm, .data$variable_name, .data$variable_level,
        .data$source_concept_name, .data$source_concept_id, .data$count_records
      ),
      estimate_name = "N records")

  } else {
    records <- tibble::tibble()
  }
  if ("count_subjects" %in% colnames(res)) {
    subjects <- res |>
      dplyr::group_by(dplyr::across(dplyr::any_of(c("time_interval", "sex", "age_group", "estimate_name")))) |>
      dplyr::arrange(dplyr::desc(.data$count_subjects)) |>
      dplyr::slice_head(n = top) |>
      dplyr::mutate("top" = dplyr::row_number()) |>
      dplyr::ungroup() |>
      dplyr::mutate(estimate_value = sprintf(
        .env$estimateForm, .data$variable_name, .data$variable_level,
        .data$source_concept_name, .data$source_concept_id, .data$count_subjects
      ),
      estimate_name = "N subjects" )
  } else {
    subjects <- tibble::tibble()
  }
  res <- dplyr::bind_rows(records, subjects) |>
    dplyr::mutate(estimate_type = "character") |>
    dplyr::select(dplyr::any_of(c("estimate_name","cdm_name", "omop_table", additional_cols, strata_cols, "estimate_value", "estimate_type", "top")))

  header <- c("cdm_name", additional_cols)
  group <- c("omop_table", strata_cols)

  tab <- visOmopResults::visTable(res,
                           header = header,
                           hide = "estimate_type",
                           group = group,
                           .options = list(merge = "all_columns"),
                           type = type)
  if (type == "gt") {
    tab <- gt::fmt_markdown(tab)
  }

  return(tab |> suppressMessages())


}
