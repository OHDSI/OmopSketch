
summariseCount <- function(x,
                           strata) {
  strataCols <- unique(unlist(strata))
  res <- x |>
    dplyr::group_by(dplyr::across(dplyr::all_of(strataCols))) |>
    dplyr::tally(name = "count") |>
    dplyr::collect()
  purrr::map(strata, \(x) {
    res |>
      dplyr::group_by(dplyr::across(dplyr::all_of(x))) |>
      dplyr::summarise(count = sum(.data$count), .groups = "drop") |>
      omopgenerics::uniteStrata(cols = x)
  }) |>
    dplyr::bind_rows() |>
    dplyr::mutate(
      result_id = 1L,
      cdm_name = omopgenerics::cdmName(x),
      variable_name = "number records",
      variable_level = NA_character_,
      estimate_name = "count",
      estimate_type = "integer",
      estimate_value = as.character(.data$count)
    )
}

summariseColumnCounts <- function(x,
                                  columns,
                                  strata,
                                  percentage) {
  strataCols <- unique(unlist(strata))
  res <- x |>
    dplyr::group_by(dplyr::across(dplyr::all_of(c(strataCols, columns)))) |>
    dplyr::tally(name = "count") |>
    dplyr::collect()
  purrr::map(strata, \(s) {
    resStrata <- res |>
      dplyr::group_by(dplyr::across(dplyr::all_of(c(s, columns)))) |>
      dplyr::summarise(count = sum(.data$count), .groups = "drop")
    purrr::map(columns, \(x) {
      resCount <- resStrata |>
        dplyr::group_by(dplyr::across(dplyr::all_of(c(s, x)))) |>
        dplyr::summarise(count = sum(.data$count), .groups = "drop")
      if (percentage) {
        resCount <- resCount |>
          dplyr::mutate(
            percentage = .data$count/sum(.data$count), .by = dplyr::all_of(s)
          )
      }
      resCount <- resCount |>
        omopgenerics::uniteStrata(cols = s) |>
        dplyr::rename(variable_name = dplyr::all_of(x)) |>
        dplyr::mutate(count = sprintf("%i", .data$count))
      if (percentage) {
        resCount <- resCount |>
          dplyr::mutate(percentage = sprintf("%.2f", .data$percentage)) |>
          tidyr::pivot_longer(
            cols = dplyr::any_of(c("count", "percentage")),
            names_to = "estimate_name",
            values_to = "estimate_value"
          ) |>
          dplyr::mutate(estimate_type = dplyr::if_else(
            .data$estimate_name == "count", "integer", "percentage"
          ))
      } else {
        resCount <- resCount |>
          dplyr::rename(estimate_value = "count") |>
          dplyr::mutate(
            estimate_type = "integer",
            estimate_name = "count"
          )
      }
      return(resCount)
    }) |>
      dplyr::bind_rows()
  }) |>
    dplyr::bind_rows() |>
    dplyr::mutate(
      result_id = 1L,
      cdm_name = omopgenerics::cdmName(x)
    )
}
