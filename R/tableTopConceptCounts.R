#' Create a visual table of the most common concepts from `summariseConceptIdCounts()` output.
#' This function takes a `summarised_result` object and generates a formatted table highlighting the most frequent concepts.
#'
#' @param result A `summarised_result` object, typically returned by `summariseConceptIdCounts()`.
#' @param top Integer. The number of top concepts to display. Defaults to `10`.
#' @param countBy Either 'person' or 'record'. If NULL whatever is in the data
#' is used.
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
#' con <- dbConnect(drv = duckdb(dbdir = eunomiaDir()))
#' cdm <- cdmFromCon(con = con, cdmSchema = "main", writeSchema = "main")
#'
#' result <- summariseConceptIdCounts(cdm = cdm, omopTableName = "condition_occurrence")
#'
#' tableTopConceptCounts(result = result, top = 5)
#' }
tableTopConceptCounts <- function(result,
                                  top = 10,
                                  countBy = NULL,
                                  type = "gt") {

  # initial checks
  rlang::check_installed("visOmopResults")
  omopgenerics::validateResultArgument(result)
  omopgenerics::assertNumeric(top, integerish = TRUE, min = 1, length = 1)
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

  # check countBy
  result <- result |>
    dplyr::mutate(estimate_name = dplyr::case_when(
      .data$estimate_name == "count_records" ~ "record",
      .data$estimate_name == "count_subjects" ~ "person",
      .default = .data$estimate_name
    ))
  opts <- unique(result$estimate_name)
  if (length(opts) == 1 & is.null(countBy)) {
    countBy <- opts
  }
  omopgenerics::assertChoice(countBy, opts, length = 1)

  # tidy version
  result <- result |>
    omopgenerics::splitAll() |>
    omopgenerics::pivotEstimates() |>
    dplyr::select(!c("result_id", opts[opts!=countBy])) |>
    dplyr::rename(
      count = dplyr::all_of(countBy),
      standard_concept_name = "variable_name",
      standard_concept_id = "variable_level"
    )

  # estimate name
  estimateForm <- "Standard: %s (%s); Source: %s (%s); %i"
  if (type == "gt") {
    estimateForm <- stringr::str_replace_all(estimateForm, ";", " <br>")
  }

  # format data
  colsGroup <- c(
    "standard_concept_name", "standard_concept_id", "source_concept_name",
    "source_concept_id", "count"
  )
  result <- result |>
    dplyr::group_by(dplyr::across(!dplyr::all_of(colsGroup))) |>
    dplyr::arrange(dplyr::desc(.data$count)) |>
    dplyr::slice_head(n = top) |>
    dplyr::mutate("top" = dplyr::row_number()) |>
    dplyr::ungroup() |>
    dplyr::mutate(
      estimate_value = sprintf(
        .env$estimateForm, .data$standard_concept_name,
        .data$standard_concept_id, .data$source_concept_name,
        .data$source_concept_id, .data$count
      ),
      estimate_name = "counts",
      estimate_type = "character"
    ) |>
    dplyr::select(!dplyr::all_of(colsGroup))

  # create visual table with visOmopResults
  header <- c("cdm_name", additional_cols)
  group <- c("omop_table", strata_cols)
  tab <- result |>
    visOmopResults::visTable(
      header = header,
      estimateName = NULL,
      hide = c("estimate_name", "estimate_type"),
      group = group,
      .options = list(merge = "all_columns"),
      type = type
    )

  # add line breaks if gt table
  if (type == "gt") {
    tab <- gt::fmt_markdown(tab)
  }

  return(tab)
}
