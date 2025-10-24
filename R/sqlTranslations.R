datediffYear <- function(x, start, end, name) {
  if (inherits(x, "data.frame")) {
    q <- "as.integer(clock::date_count_between(start = .data[[start]], end = .data[[end]], precision = 'year'))"
  } else {
    q <- "as.integer(local(CDMConnector::datediff(start = start, end = end, interval = 'year')))"
  }
  q <- q |>
    rlang::set_names(nm = name) |>
    rlang::parse_exprs()
  x %>%
    dplyr::mutate(!!!q)
}
datediffDays <- function(x, start, end, name, offset = 0) {
  if (inherits(x, "data.frame")) {
    q <- "as.integer(clock::date_count_between(start = .data[[start]], end = .data[[end]], precision = 'day'))"
  } else {
    q <- "as.integer(local(CDMConnector::datediff(start = start, end = end, interval = 'day')))"
  }
  if (offset > 0) {
    q <- paste0(q, " + ", offset, "L")
  } else if (offset < 0) {
    q <- paste0(q, " - ", abs(offset), "L")
  }
  q <- q |>
    rlang::set_names(nm = name) |>
    rlang::parse_exprs()
  x %>%
    dplyr::mutate(!!!q)
}
getYear <- function(x, date, name) {
  if (inherits(x, "data.frame")) {
    q <- "as.integer(clock::get_year(.data[[date]]))"
  } else {
    q <- "as.integer(local(CDMConnector::datepart(date = date, interval = 'year')))"
  }
  q <- q |>
    rlang::set_names(nm = name) |>
    rlang::parse_exprs()
  x %>%
    dplyr::mutate(!!!q)
}
