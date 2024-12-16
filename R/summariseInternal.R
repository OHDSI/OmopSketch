
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
summariseMissingInternal <- function(x, strata, columns) {
  q <- 'sum(as.integer(is.na(.data${columns})), na.rm = TRUE)' |>
    glue::glue() |>
    rlang::set_names(columns) |>
    rlang::parse_exprs()
  purrr::map(strata, \(stratak) {
    x |>
      dplyr::group_by(dplyr::across(dplyr::all_of(stratak))) |>
      dplyr::summarise(total_counts = dplyr::n(), !!!q, .groups = "drop") |>
      dplyr::collect() |>
      dplyr::mutate(dplyr::across(
        dplyr::all_of(names(q)),
        \(x) sprintf("%.2f", 100 * as.numeric(x) / as.numeric(.data$total_counts)),
        .names = 'percentage_{.col}'
      )) |>
      dplyr::mutate(dplyr::across(
        dplyr::all_of(names(q)), \(x) sprintf("%i", as.integer(x))
      )) |>
      dplyr::rename_with(\(x) paste0("count_", x), .cols = dplyr::all_of(names(q))) |>
      dplyr::select(!"total_counts") |>
      tidyr::pivot_longer(
        cols = !dplyr::all_of(stratak),
        names_to = "estimate_name",
        values_to = "estimate_value"
      ) |>
      tidyr::separate(
        col = "estimate_name",
        into = c("estimate_name", "column_name"),
        sep = "_",
        extra = "merge"
      ) |>
      dplyr::mutate(
        estimate_type = dplyr::if_else(
          .data$estimate_name == "count", "integer", "percentage"
        ),
        estimate_name = paste0("na_", .data$estimate_name)
      ) |>
      dplyr::select(dplyr::all_of(c(
        stratak, "column_name", "estimate_name", "estimate_type",
        "estimate_value"
      )))
  }) |>
    dplyr::bind_rows()
}
sampleTable <- function(x, sample, name) {
  if (is.null(sample)) return(x)
  if (x |> dplyr::tally() |> dplyr::pull() <= sample) return(x)

  cdm <- omopgenerics::cdmReference(x)
  id <- omopgenerics::omopColumns(table = omopgenerics::tableName(x), field = "unique_id")
  idTibble <- x |>
    dplyr::pull(dplyr::all_of(id)) |>
    base::sample(size = sample) |>
    list() |>
    rlang::set_names(id) |>
    dplyr::as_tibble()
  idName <- "ids_sample"
  cdm <- omopgenerics::insertTable(cdm = cdm, name = idName, table = idTibble)
  x <- x |>
    dplyr::inner_join(cdm[[idName]], by = id) |>
    dplyr::compute(name = name, temporary = FALSE)
  omopgenerics::dropSourceTable(cdm = cdm, name = idName)
  return(x)
}
addStratifications <- function(x, indexDate, sex, ageGroup, interval, name) {
  # add sex and age_group if needed
  if (sex | !is.null(ageGroup)) {
    x <- x |>
      PatientProfiles::addDemographicsQuery(
        age = FALSE,
        ageGroup = ageGroup,
        sex = sex,
        indexDate = indexDate,
        priorObservation = FALSE,
        futureObservation = FALSE,
        dateOfBirth = FALSE
      )
  }

  if (interval == "years") {
    x <- x |>
      dplyr::mutate(year = as.character(clock::get_year(.data[[indexDate]])))
  } else if (interval == "months") {
    x <- x |>
      dplyr::mutate(month = paste0(
        as.character(clock::get_year(.data[[indexDate]])),
        "_",
        as.character(clock::get_month(.data[[indexDate]]))
      ))
  } else if (interval == "quarters") {
    x <- x |>
      dplyr::mutate(quarter = paste0(
        as.character(clock::get_year(.data[[indexDate]])),
        "_Q",
        as.character(as.integer(((clock::get_month(.data[[indexDate]]) - 1) %/% 3) + 1))
      ))
  }

  if (interval != "overall" | sex | !is.null(ageGroup)) {
    x <- x |>
      dplyr::compute(name = name, temporary = FALSE)
  }

  return(x)
}
