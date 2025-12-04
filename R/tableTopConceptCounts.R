
#' Create a visual table of the most common concepts from
#' `summariseConceptIdCounts()` output
#'
#' This function takes a `summarised_result` object and generates a formatted
#' table highlighting the most frequent concepts.
#'
#' @param result A summarised_result object (output of
#' `summariseConceptIdCounts()`).
#' @param top Integer. The number of top concepts to display. Defaults to `10`.
#' @param countBy Either 'person' or 'record'. If NULL whatever is in the data
#' is used.
#' @inheritParams style-table
#'
#' @return A formatted table visualisation.
#' @export
#'
#' @examples
#' \donttest{
#' library(OmopSketch)
#' library(omock)
#'
#' cdm <- mockCdmFromDataset(datasetName = "GiBleed", source = "duckdb")
#'
#' result <- summariseConceptIdCounts(cdm = cdm, omopTableName = "condition_occurrence")
#'
#' tableTopConceptCounts(result = result, top = 5)
#'
#' cdmDisconnect(cdm = cdm)
#' }
#'
tableTopConceptCounts <- function(result,
                                  top = 10,
                                  countBy = NULL,
                                  type = NULL,
                                  style = NULL) {
  # initial checks
  rlang::check_installed("visOmopResults")
  omopgenerics::validateResultArgument(result)
  omopgenerics::assertNumeric(top, integerish = TRUE, min = 1, length = 1)

  style <- validateStyle(style = style, obj = "table")
  type <- validateType(type)

  result <- result |>
    omopgenerics::filterSettings(
      .data$result_type == "summarise_concept_id_counts"
    )
  if (nrow(result) == 0) {
    warnEmpty("summarise_concept_id_counts")
    return(visOmopResults::emptyTable(type = type, style = style))
  }

  strata_cols <- omopgenerics::strataColumns(result)
  additional_cols <- omopgenerics::additionalColumns(result)
  additional_cols <- additional_cols[!grepl("source_concept", additional_cols)]
  # subset to result_type of interest
  setting_cols <- omopgenerics::settingsColumns(result)
  setting_cols <- setting_cols[!setting_cols %in% c("study_period_end", "study_period_start")]


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
    omopgenerics::addSettings(settingsColumn = setting_cols) |>
    omopgenerics::splitAll() |>
    omopgenerics::pivotEstimates() |>
    dplyr::select(!c("result_id", opts[opts != countBy])) |>
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
  tables <- result$omop_table |> unique()
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
  if (type != "reactable") {
    header <- c(header, setting_cols)
  } else {
    group <- c(group, setting_cols)
  }

  tab <- result |>
    visOmopResults::visTable(
      header = header,
      estimateName = NULL,
      hide = c("estimate_name", "estimate_type"),
      group = group,
      .options = list(merge = "all_columns",
                      caption = paste0("Top ", as.character(top), " concepts in ", paste(tables, collapse = ", "), ifelse(length(tables) > 1, " tables", " table"), " ranked by ", countBy, " count")
                      ),
      type = type,
      style = style
    )

  # add line breaks if gt table
  if (type == "gt") {
    tab <- gt::fmt_markdown(tab)
  }

  return(tab)
}
