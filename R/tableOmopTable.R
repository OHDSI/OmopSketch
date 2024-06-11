#' Summarise an omop_table from a cdm_reference object. You will obtain
#' information related to the number of records, number of subjects, whether the
#' records are in observation, number of present domains and number of present
#' concepts.
#'
#' @param summarisedOmopTable A summarised_result object with the output from summariseOmopTable().
#'
#' @return A gt object with the summarised data.
#'
#' @export
#'
tableOmopTable <- function(summarisedOmopTable) {

  # Initial checks ----
  assertClass(summarisedOmopTable, "summarised_result")

  t <- summarisedOmopTable |>
    dplyr::mutate(order = dplyr::case_when(
      variable_name == "number_records"  ~ 1,
      variable_name == "number_subjects" ~ 2,
      variable_name == "records_per_person" ~ 3,
      variable_name == "In observation" ~ 4,
      variable_name == "Standard concept" ~ 5,
      variable_name == "Source vocabulary" ~ 6,
      variable_name == "Domain" ~ 7,
      variable_name == "Type concept id" ~ 8
    )) |>
    dplyr::arrange(order) |>
    visOmopResults::splitGroup() |>
    visOmopResults::formatEstimateValue() |>
    visOmopResults::formatEstimateName(
      estimateNameFormat = c(
        "N (%)" = "<count> (<percentage>%)",
        "N"     = "<count>",
        "median [IQR]" = "<median> [<q25> - <q75>]",
        "mean (sd)" = "<mean> (<sd>)"
      ),
      keepNotFormatted = FALSE
    ) |>
    suppressMessages() |>
    visOmopResults::formatHeader(header = "cdm_name") |>
    dplyr::select(-c("estimate_type", "order","result_id",
                     "additional_name", "additional_level",
                     "strata_name", "strata_level")) |>
    dplyr::rename(
      "Variable" = "variable_name", "Level" = "variable_level",
      "Estimate" = "estimate_name"
    )

  names <- t |> colnames()

  t |>
    visOmopResults::gtTable(
      groupColumn = "omop_table",
      colsToMergeRows = c("Variable", "Level")
    ) |>
    gt::tab_style(
      style = gt::cell_borders(
        sides = c("left"),
        color = NULL,
        style = "solid",
        weight = gt::px(2)
      ),
      locations = list(
        gt::cells_body(
          columns = .data$Variable,
          rows = gt::everything()
        )
      )
    ) |>
    gt::tab_style(
      style = gt::cell_borders(
        sides = c("right"),
        color = NULL,
        style = "solid",
        weight = gt::px(2)
      ),
      locations = list(
        gt::cells_body(
          columns = names[length(names)],
          rows = gt::everything()
        )
      )
    )

}
