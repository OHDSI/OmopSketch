summariseCountsInternal <- function(x, strata, counts) {
  q <- c(
    "dplyr::n()",
    "dplyr::n_distinct(.data$person_id)",
    "dplyr::n_distinct(.data$subject_id)"
  ) |>
    rlang::set_names(c("count_records", "count_subjects", "count_subjects")) |>
    purrr::keep(c("records", "person_id", "subject_id") %in% counts) |>
    rlang::parse_exprs()
  purrr::map(strata, \(stratak) {
    x |>
      dplyr::group_by(dplyr::across(dplyr::all_of(stratak))) |>
      dplyr::summarise(!!!q, .groups = "drop") |>
      dplyr::collect() |>
      dplyr::mutate(dplyr::across(
        dplyr::all_of(names(q)), printInteger
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
summariseMissingInternal <- function(x, strata, columns, cdm, table) {
  q_na <- "sum(dplyr::if_else(is.na(.data${columns}), 1, 0), na.rm = TRUE)" |>
    stringr::str_glue() |>
    rlang::set_names(columns) |>
    rlang::parse_exprs()

  columns_zero <- omopgenerics::omopTableFields(cdmVersion = omopgenerics::cdmVersion(cdm)) |>
    dplyr::filter(.data$cdm_table_name == table & .data$cdm_field_name %in% columns[grepl("_id$", columns)] & .data$cdm_datatype == "integer") |>
    dplyr::pull(.data$cdm_field_name)
  q_zero <- "sum(dplyr::if_else(.data${columns_zero} == 0, 1, 0), na.rm = TRUE)" |>
    stringr::str_glue() |>
    rlang::set_names(columns_zero) |>
    rlang::parse_exprs()


  purrr::map(strata, \(stratak) {
    na <- x |>
      dplyr::group_by(dplyr::across(dplyr::all_of(stratak))) |>
      dplyr::summarise(total_counts = dplyr::n(), !!!q_na, .groups = "drop") |>
      dplyr::collect() |>
      dplyr::mutate(dplyr::across(
        dplyr::all_of(names(q_na)),
        ~ dplyr::coalesce(.x, 0)
      )) |>
      dplyr::mutate(dplyr::across(
        dplyr::all_of(names(q_na)),
        \(x) sprintf("%.2f", 100 * as.numeric(x) / as.numeric(.data$total_counts)),
        .names = "percentage_{.col}"
      )) |>
      dplyr::mutate(dplyr::across(
        dplyr::all_of(names(q_na)), printInteger
      )) |>
      dplyr::rename_with(\(x) paste0("count_", x), .cols = dplyr::all_of(names(q_na))) |>
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
    if (length(columns_zero)) {
      zero <- x |>
        dplyr::group_by(dplyr::across(dplyr::all_of(stratak))) |>
        dplyr::summarise(total_counts = dplyr::n(), !!!q_zero, .groups = "drop") |>
        dplyr::collect() |>
        dplyr::mutate(dplyr::across(
          dplyr::all_of(names(q_zero)),
          ~ dplyr::coalesce(.x, 0L)
        )) |>
        dplyr::mutate(dplyr::across(
          dplyr::all_of(names(q_zero)),
          \(x) sprintf("%.2f", 100 * as.numeric(x) / as.numeric(.data$total_counts)),
          .names = "percentage_{.col}"
        )) |>
        dplyr::mutate(dplyr::across(
          dplyr::all_of(names(q_zero)), printInteger
        )) |>
        dplyr::rename_with(\(x) paste0("count_", x), .cols = dplyr::all_of(names(q_zero))) |>
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
          estimate_name = paste0("zero_", .data$estimate_name)
        ) |>
        dplyr::select(dplyr::all_of(c(
          stratak, "column_name", "estimate_name", "estimate_type",
          "estimate_value"
        )))
    } else {
      zero <- dplyr::tibble()
    }
    dplyr::bind_rows(na, zero)
  }) |>
    dplyr::bind_rows()
}

addStratifications <- function(x, indexDate, sex, ageGroup, interval, intervalName, name) {
  # add sex and age_group if needed
  x <- x |>
    addSexAgeGroup(sex = sex, ageGroup = ageGroup, indexDate = indexDate)

  if (interval != "overall") {
    if (interval == "years") {
      q <- "as.character(clock::get_year(.data[[indexDate]]))"
    } else if (interval == "months") {
      q <- 'paste0(as.character(clock::get_year(.data[[indexDate]])), "_", as.character(clock::get_month(.data[[indexDate]])))'
    } else if (interval == "quarters") {
      q <- 'paste0(as.character(clock::get_year(.data[[indexDate]])), "_Q", as.character(as.integer(floor((clock::get_month(.data[[indexDate]]) - 1) / 3) + 1)))'
    }
    q <- q |>
      rlang::set_names(intervalName) |>
      rlang::parse_exprs()
    x <- x |>
      dplyr::mutate(!!!q)
  }


  if (interval != "overall" | sex | !is.null(ageGroup)) {
    x <- x |>
      dplyr::compute(name = name, temporary = FALSE)
  }

  return(x)
}
addSexAgeGroup <- function(x, sex, ageGroup, indexDate) {
  age <- !is.null(ageGroup)

  person <- omopgenerics::cdmReference(x)$person
  q <- c(
    sex = ".data$gender_concept_id",
    birth_date = "as.Date(paste0(
    as.character(as.integer(.data$year_of_birth)), '-',
    as.character(as.integer(dplyr::coalesce(.data$month_of_birth, 1L))), '-',
    as.character(as.integer(dplyr::coalesce(.data$day_of_birth, 1L)))))"
  )[c(sex, age)] |>
    rlang::parse_exprs()
  person <- person |>
    dplyr::mutate(!!!q) |>
    dplyr::select(dplyr::any_of(c("person_id", "sex", "birth_date")))

  x <- x |>
    dplyr::left_join(person, by = "person_id")

  if (sex) {
    x <- x |>
      dplyr::mutate(sex = dplyr::case_when(
        .data$sex == 8532 ~ "Female",
        .data$sex == 8507 ~ "Male",
        .default = "None"
      ))
  }

  if (age) {
    qAge <- ageGroupQuery(ageGroup)
    x <- x |>
      datediffYear(start = "birth_date", end = indexDate, name = "xyz_age") |>
      dplyr::mutate(!!!qAge) |>
      dplyr::select(!c("birth_date", "xyz_age"))
  }

  return(x)
}
ageGroupQuery <- function(ageGroup) {
  x <- c(
    purrr::imap_chr(ageGroup$age_group, \(x, nm) {
      if (is.infinite(x[2])) {
        paste0(".data$xyz_age >= ", x[1], "L ~ '", nm, "'")
      } else {
        paste0(".data$xyz_age >= ", x[1], "L & .data$xyz_age <= ", x[2], "L ~ '", nm, "'")
      }
    }),
    '.default = "None"'
  ) |>
    paste0(collapse = ", ")
  paste0("dplyr::case_when(", x, ")") |>
    rlang::set_names(nm = "age_group") |>
    rlang::parse_exprs()
}
restrictStudyPeriod <- function(omopTable, dateRange) {
  if (!is.null(dateRange)) {
    table <- omopgenerics::tableName(omopTable)
    start_date_table <- omopgenerics::omopColumns(table = table, field = "start_date")
    end_date_table <- omopgenerics::omopColumns(table = table, field = "end_date")
    start_date <- dateRange[1]
    end_date <- dateRange[2]

    omopTable <- omopTable |>
      dplyr::filter(
        (.data[[start_date_table]] >= .env$start_date & .data[[start_date_table]] <= .env$end_date)
      )
  }

  warningEmptyStudyPeriod(omopTable)
}

trimStudyPeriod <- function(omopTable, dateRange) {
  if (!is.null(dateRange)) {
    table <- omopgenerics::tableName(omopTable)
    start_date_col <- omopgenerics::omopColumns(table = table, field = "start_date")
    end_date_col <- omopgenerics::omopColumns(table = table, field = "end_date")
    start_date <- dateRange[1]
    end_date <- dateRange[2]

    omopTable <- omopTable |>
      dplyr::mutate(
        !!start_date_col := dplyr::if_else(.data[[start_date_col]] < .env$start_date, .env$start_date, .data[[start_date_col]]),
        !!end_date_col := dplyr::if_else(.data[[end_date_col]] > .env$end_date, .env$end_date, .data[[end_date_col]])
      ) |>
      dplyr::filter(.data[[start_date_col]] <= .data[[end_date_col]])
  }
  warningEmptyStudyPeriod(omopTable)
}


warningEmptyStudyPeriod <- function(omopTable) {
  if (omopgenerics::isTableEmpty(omopTable)) {
    cli::cli_warn(paste0(omopgenerics::tableName(omopTable), " omop table is empty after application of date range."))
    return(invisible(NULL))
  }
  return(omopTable)
}
strataCols <- function(sex = FALSE, ageGroup = NULL, interval = "overall", inObservation = FALSE) {
  c(names(ageGroup), "sex"[sex], "interval"[interval != "overall"], "in_observation"[inObservation])
}

summariseSumInternal <- function(x, strata, variable) {
  purrr::map(strata, \(stratak) {
    x |>
      dplyr::group_by(dplyr::across(dplyr::all_of(stratak))) |>
      dplyr::summarise(estimate_value = sum(.data[[variable]], na.rm = TRUE), .groups = "drop") |>
      dplyr::collect() |>
      dplyr::mutate(estimate_value = printInteger(.data$estimate_value)) |>
      dplyr::mutate(estimate_type = "integer", estimate_name = "count") |>
      dplyr::select(dplyr::all_of(c(
        stratak, "estimate_name", "estimate_type",
        "estimate_value"
      )))
  }) |>
    dplyr::bind_rows()
}


summariseMedianAge <- function(x, index_date, strata) {
  x <- x |>
    PatientProfiles::addAgeQuery(indexDate = index_date)

  purrr::map(strata, \(stratak) {
    x |>
      dplyr::select("age", dplyr::all_of(stratak)) |>
      dplyr::collect() |>
      dplyr::group_by(dplyr::across(dplyr::all_of(stratak))) |>
      dplyr::summarise("estimate_value" = stats::median(.data$age))
  }) |>
    dplyr::bind_rows() |>
    dplyr::mutate(
      estimate_name = "median",
      estimate_type = "numeric",
      estimate_value = sprintf("%i", as.integer(.data$estimate_value))
    )
}

addInObservation <- function(x, inObservation, cdm, episode, name) {
  if (!inObservation) {
    return(x)
  }

  if (episode) {
    x <- x |>
      dplyr::left_join(cdm[["observation_period"]] |> dplyr::select("person_id", "observation_period_start_date", "observation_period_end_date"), by = "person_id") |>
      dplyr::mutate("in_observation" = dplyr::if_else(
        !is.na(.data$observation_period_start_date) &
          .data$start_date >= .data$observation_period_start_date &
          .data$start_date <= .data$observation_period_end_date &
          (
            is.na(.data$end_date) |
              (.data$end_date >= .data$observation_period_start_date &
                 .data$end_date <= .data$observation_period_end_date)
          ),
        "TRUE",
        "FALSE"
      )) |>
      dplyr::select(-"observation_period_start_date", -"observation_period_end_date") |>
      dplyr::compute(name = name)
  } else {
    x <- x |>
      dplyr::left_join(cdm[["observation_period"]] |> dplyr::select("person_id", "observation_period_start_date", "observation_period_end_date"), by = "person_id") |>
      dplyr::mutate("in_observation" = dplyr::if_else(!is.na(.data$observation_period_start_date) & .data$start_date >= .data$observation_period_start_date & .data$start_date <= .data$observation_period_end_date, "TRUE", "FALSE")) |>
      dplyr::select(-"observation_period_start_date", -"observation_period_end_date") |>
      dplyr::compute(name = name)
  }
  return(x)
}


printInteger <- function(x){
  if(inherits(x, "integer64")){
    as.character(round(x, digits = 0))
  } else {
    sprintf("%.0f", x)
  }
}
