datediffYear <- function(x, start, end, name) {

  q <- c(
    stringr::str_glue("(
      (clock::get_year(.data[['{end}']])  * 10000 +
       clock::get_month(.data[['{end}']]) * 100 +
       clock::get_day(.data[['{end}']])) -
      (clock::get_year(.data[['{start}']])  * 10000 +
       clock::get_month(.data[['{start}']]) * 100 +
       clock::get_day(.data[['{start}']]))
    ) / 10000"),
    "as.integer(sign(.data[[\"val\"]]) * floor(abs(.data[[\"val\"]])))"
  ) |>
    rlang::parse_exprs() |>
    rlang::set_names(c("val", name))

  x |>
    dplyr::mutate(!!!q) |>
    dplyr::select(-"val")
}
datediffDays <- function(x, start, end, name, offset = 0) {

  q <- "as.integer(clock::date_count_between(start = .data[[start]], end = .data[[end]], precision = 'day'))"
  if (offset > 0) {
    q <- paste0(q, " + ", offset, "L")
  } else if (offset < 0) {
    q <- paste0(q, " - ", abs(offset), "L")
  }
  q <- q |>
    rlang::set_names(nm = name) |>
    rlang::parse_exprs()

  x |>
    dplyr::mutate(!!!q)
}
getYear <- function(x, date, name) {
  q <- "as.integer(clock::get_year(.data[[date]]))" |>
    rlang::set_names(nm = name) |>
    rlang::parse_exprs()

  x |>
    dplyr::mutate(!!!q)
}


