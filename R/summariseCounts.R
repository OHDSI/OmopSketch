
summariseCountsInternal <- function(x, strata, counts) {
  q <- c(
    'dplyr::n()',
    'dplyr::n_distinct(.data$person_id)',
    'dplyr::n_distinct(.data$subject_id)'
  ) |>
    rlang::set_names(c("count_records", "count_subjecst", "count_subjects")) |>
    purrr::keep(c("records", "person_id", "subject_id") %in% counts) |>
    rlang::parse_exprs()
  purrr::map(strata, \(stratak) {
    x |>
      dplyr::group_by(dplyr::across(dplyr::all_of(stratak))) |>
      dplyr::summarise(!!!q, .groups = "drop") |>
      dplyr::collect() |>
      dplyr::mutate(dplyr::across(
        dplyr::all_of(names(q)), \(x) sprintf("%i", as.integer(x))
      )) |>
      tidyr::pivot_longer(
        cols = dplyr::all_of(names(q)),
        names_to = "estimate_name",
        values_to = "estimate_value"
      ) |>
      dplyr::mutate(estimate_type = "integer") |>
      dplyr::select(dplyr::all_of(c(
        stratak, "estimate_name", "estimate_type",
        "estimate_value"
      )))
  }) |>
    dplyr::bind_rows()
}
