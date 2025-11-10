
# summarise functions ----
summariseCompute <- function(x, strata) {
  cdm <- omopgenerics::cdmReference(x)

  strataCols <- unique(unlist(strata))

  nm <- omopgenerics::uniqueTableName()
  counts <- x |>
    dplyr::group_by(dplyr::across(dplyr::all_of(strataCols))) |>
    dplyr::summarise(n = as.integer(dplyr::n()), .groups = "drop") |>
    dplyr::compute(name = nm, temporary = FALSE)

  result <- purrr::map(strata, \(s) {
    counts |>
      dplyr::group_by(dplyr::across(dplyr::all_of(s))) |>
      dplyr::summarise(
        "estimate_value" = sum(.data$n, na.rm = TRUE),
        .groups = "drop"
      ) |>
      dplyr::collect() |>
      dplyr::mutate(
        variable_name = "number_records",
        "estimate_name" = "count",
        "estimate_type" = "integer",
        "estimate_value" = sprintf("%i", .data$estimate_value)
      ) |>
      omopgenerics::uniteStrata(cols = s)
  }) |>
    dplyr::bind_rows()

  omopgenerics::dropSourceTable(cdm = cdm, name = nm)

  return(result)
}
summariseCollect <- function(x, strata) {
  strataCols <- unique(unlist(strata))

  counts <- x |>
    dplyr::group_by(dplyr::across(dplyr::all_of(strataCols))) |>
    dplyr::summarise(n = as.integer(dplyr::n()), .groups = "drop") |>
    dplyr::collect()

  result <- purrr::map(strata, \(s) {
    counts |>
      dplyr::group_by(dplyr::across(dplyr::all_of(s))) |>
      dplyr::summarise(
        "estimate_value" = sum(.data$n, na.rm = TRUE),
        .groups = "drop"
      ) |>
      dplyr::collect() |>
      dplyr::mutate(
        variable_name = "number_records",
        "estimate_name" = "count",
        "estimate_type" = "integer",
        "estimate_value" = sprintf("%i", .data$estimate_value)
      ) |>
      omopgenerics::uniteStrata(cols = s)
  }) |>
    dplyr::bind_rows()

  return(result)
}
summariseOneByOne <- function(x, strata) {
  strataCols <- unique(unlist(strata))

  result <- purrr::map(strata, \(s) {
    x |>
      dplyr::group_by(dplyr::across(dplyr::all_of(s))) |>
      dplyr::summarise("estimate_value" = dplyr::n(), .groups = "drop") |>
      dplyr::collect() |>
      dplyr::mutate(
        variable_name = "number_records",
        "estimate_name" = "count",
        "estimate_type" = "integer",
        "estimate_value" = sprintf("%i", .data$estimate_value)
      ) |>
      omopgenerics::uniteStrata(cols = s)
  }) |>
    dplyr::bind_rows()

  return(result)
}
summariseOneByOneId <- function(x, strata) {
  strataCols <- unique(unlist(strata))

  result <- purrr::map(strata, \(s) {
    x |>
      dplyr::group_by(dplyr::across(dplyr::all_of(s))) |>
      dplyr::summarise(
        "number_records" = as.integer(dplyr::n()),
        "number_subjects" = as.integer(dplyr::n_distinct(.data$person_id)),
        .groups = "drop"
      ) |>
      dplyr::collect() |>
      tidyr::pivot_longer(
        cols = c("number_records", "number_subjects"),
        names_to = "variable_name",
        values_to = "estimate_value"
      ) |>
      dplyr::mutate(
        "estimate_name" = "count",
        "estimate_type" = "integer",
        "estimate_value" = sprintf("%i", .data$estimate_value)
      ) |>
      omopgenerics::uniteStrata(cols = s)
  }) |>
    dplyr::bind_rows()

  return(result)
}
summariseOneByOneOnlyId <- function(x, strata) {
  strataCols <- unique(unlist(strata))

  result <- purrr::map(strata, \(s) {
    x |>
      dplyr::group_by(dplyr::across(dplyr::all_of(s))) |>
      dplyr::summarise(
        "estimate_value" = as.integer(dplyr::n_distinct(.data$person_id)),
        .groups = "drop"
      ) |>
      dplyr::collect() |>
      dplyr::mutate(
        variable_name = "number_subjects",
        "estimate_name" = "count",
        "estimate_type" = "integer",
        "estimate_value" = sprintf("%i", .data$estimate_value)
      ) |>
      omopgenerics::uniteStrata(cols = s)
  }) |>
    dplyr::bind_rows()

  return(result)
}
addTask <- function(result, db, task, t0) {
  time <- round(as.numeric(Sys.time() - t0), 1)
  cli::cli_inform(c("v" = "{.pkg {format(Sys.time(), '%Y-%m-%d %H:%M:%S')}} {.strong {db}} {task}"))
  result |>
    dplyr::union_all(dplyr::tibble(db = db, task = task, time = time))
}

# connections ----
cdms <- c("duckdb")#, "postgres 100k"), "postgres", "sql server")
createCdm <- function(nm) {
  pref <- "mc_test_"
  if (nm == "local") {
    cdm <- omock::mockCdmReference() |>
      omock::mockPerson(nPerson = 100) |>
      omock::mockObservationPeriod() |>
      omock::mockConditionOccurrence(recordPerson = 28)
  } else if (nm == "duckdb") {
    cdm <- CDMConnector::cdmFromCon(
      con = duckdb::dbConnect(duckdb::duckdb(), CDMConnector::eunomiaDir()),
      cdmSchema = "main", writeSchema = "main", writePrefix = pref
    )
  } else if (grepl("postgres", nm)) {
    cdm <- CDMConnector::cdmFromCon(
      con = DBI::dbConnect(
        drv = RPostgres::Postgres(), dbname = "cdm_gold_202407",
        host = Sys.getenv("DB_HOST"), port = Sys.getenv("DB_PORT"),
        user = Sys.getenv("DB_USER"), password = Sys.getenv("DB_PASSWORD")
      ),
      cdmSchema = ifelse(nm == "postgres", "public", "public_100k"),
      writeSchema = "results",
      writePrefix = pref
    )
  } else if (nm == "sql server") {
    cdm <- CDMConnector::cdmFromCon(
      con = DBI::dbConnect(
        odbc::odbc(),
        Driver = "ODBC Driver 18 for SQL Server",
        Server = Sys.getenv("CDM5_SQL_SERVER_SERVER"),
        Database = Sys.getenv("CDM5_SQL_SERVER_CDM_DATABASE"),
        UID = Sys.getenv("CDM5_SQL_SERVER_USER"),
        PWD = Sys.getenv("CDM5_SQL_SERVER_PASSWORD"),
        TrustServerCertificate = "yes",
        Port = 1433
      ),
      cdmSchema = c("CDMV5", "dbo"),
      writeSchema = c("ohdsi", "dbo"),
      writePrefix = pref
    )
  } else {
    cli::cli_abort("wrong name")
  }
  return(cdm)
}

# create dummy data ----
numberIndividuals <- 1e5
numberRecords <- 1e6
x <- list(
  person_id = seq_len(numberIndividuals),
  sex = c("Male", "Female"),
  age_group = c("0 to 19", "20 to 39", "40 to 59", "60 to 79", "80 or above"),
  year = 1950:2000L,
  condition_concept_id = 1:1e4L
) |>
  purrr::map(\(x) sample(x = x, size = numberRecords, replace = TRUE)) |>
  dplyr::as_tibble()
strata <- c(list(character()), omopgenerics::combineStrata(c("sex", "age_group", "year", "condition_concept_id")))

# benchmark ----
result <- dplyr::tibble(
  db = character(), task = character(), time = integer()
)
results <- list()
for (nm in cdms) {
  # create cdm object
  t0 <- Sys.time()
  cdm <- createCdm(nm)
  result <- addTask(result, nm, "create cdm object", t0)

  if (nm != "postgres 100k") {
    # insert mock data
    tempName <- omopgenerics::uniqueTableName()
    t0 <- Sys.time()
    cdm <- omopgenerics::insertTable(cdm = cdm, name = tempName, table = x)
    result <- addTask(result, nm, "insert toy data", t0)

    # summarise mock data
    res <- cdm[[tempName]]
    for (fun in c("summariseCompute", "summariseCollect", "summariseOneByOne", "summariseOneByOneId", "summariseOneByOneOnlyId")) {
      t0 <- Sys.time()
      results[[paste0("mock_", nm, "_", fun)]] <- "{fun}(x = res, strata = strata)" |>
        stringr::str_glue() |>
        rlang::parse_expr() |>
        rlang::eval_tidy()
      result <- addTask(result, nm, paste(fun, "mock"), t0)
    }

    # drop toy data
    t0 <- Sys.time()
    cdm <- omopgenerics::dropSourceTable(cdm = cdm, name = tempName)
    result <- addTask(result, nm, "drop toy data", t0)
  }

  # summarise condition_occurrence
  res <- cdm$condition_occurrence |>
    PatientProfiles::addDemographicsQuery(
      indexDate = "condition_start_date",
      age = FALSE,
      ageGroup = list(c(0, 19), c(20, 39), c(40, 59), c(60, 79), c(80, Inf)),
      sex = TRUE,
      priorObservation = FALSE,
      futureObservation = FALSE
    ) |>
    dplyr::mutate(year = clock::get_year(.data$condition_start_date))
  for (fun in c("summariseCompute", "summariseCollect", "summariseOneByOne", "summariseOneByOneId", "summariseOneByOneOnlyId")) {
    t0 <- Sys.time()
    results[[paste0("cond_", nm, "_", fun)]] <- "{fun}(x = res, strata = strata)" |>
      stringr::str_glue() |>
      rlang::parse_expr() |>
      rlang::eval_tidy()
    result <- addTask(result, nm, paste(fun, "condition_occurrence"), t0)
  }

  if (nm != "local") {
    tempName <- omopgenerics::uniqueTableName()
    # summarise condition_occurrence computed
    t0 <- Sys.time()
    res <- cdm$condition_occurrence |>
      PatientProfiles::addDemographicsQuery(
        indexDate = "condition_start_date",
        age = FALSE,
        ageGroup = list(c(0, 19), c(20, 39), c(40, 59), c(60, 79), c(80, Inf)),
        sex = TRUE,
        priorObservation = FALSE,
        futureObservation = FALSE
      ) |>
      dplyr::mutate(year = clock::get_year(.data$condition_start_date)) |>
      dplyr::compute(name = tempName, temporray = FALSE)
    result <- addTask(result, nm, "compute query", t0)
    for (fun in c("summariseCompute", "summariseCollect", "summariseOneByOne", "summariseOneByOneId", "summariseOneByOneOnlyId")) {
      t0 <- Sys.time()
      results[[paste0("condcomp_", nm, "_", fun)]] <- "{fun}(x = res, strata = strata)" |>
        stringr::str_glue() |>
        rlang::parse_expr() |>
        rlang::eval_tidy()
      result <- addTask(result, nm, paste(fun, "condition_occurrence computed"), t0)
    }

    # drop computed data
    t0 <- Sys.time()
    cdm <- omopgenerics::dropSourceTable(cdm = cdm, name = tempName)
    result <- addTask(result, nm, "drop computed data", t0)
  }
}

# check results consistency ----
comp <- dplyr::tibble(
  x = c("summariseCompute", "summariseCompute", "summariseCompute+summariseOneByOneOnlyId"),
  y = c("summariseCollect", "summariseOneByOne", "summariseOneByOneId")
)
purrr::map(c("mock", "cond", "condcomp"), \(type) {
  purrr::map(cdms, \(nm) {
    purrr::map2(comp$x, comp$y, \(x, y) {
      xres <- results[paste0(type, "_", nm, "_", stringr::str_split_1(x, "\\+"))] |>
        dplyr::bind_rows() |>
        dplyr::select(
          "variable_name", "strata_name", "strata_level", "estimate_name",
          "estimate_type", "estimate_value"
        ) |>
        dplyr::arrange(dplyr::across(dplyr::everything()))
      yres <- results[paste0(type, "_", nm, "_", stringr::str_split_1(y, "\\+"))] |>
        dplyr::bind_rows() |>
        dplyr::select(
          "variable_name", "strata_name", "strata_level", "estimate_name",
          "estimate_type", "estimate_value"
        ) |>
        dplyr::arrange(dplyr::across(dplyr::everything()))
      symb <- ifelse(identical(xres, yres), "v", "x")
      "{.pkg {type}} {.strong {nm}} {x} vs {y}" |>
        rlang::set_names(symb) |>
        cli::cli_inform()
    })
  })
}) |>
  invisible()

# check consistency across dbms ----
nms <- c("summariseCompute", "summariseCollect", "summariseOneByOne", "summariseOneByOneId", "summariseOneByOneOnlyId")
comp <- tidyr::expand_grid(x = seq_along(cdms), y = seq_along(cdms)) |>
  dplyr::filter(.data$x < .data$y) |>
  purrr::map(\(x) cdms[x])
purrr::map(nms, \(nm) {
  purrr::map2(comp$x, comp$y, \(x, y) {
    xres <- results[[paste0("mock_", x, "_", nm)]] |>
      dplyr::arrange(dplyr::across(dplyr::everything()))
    yres <- results[[paste0("mock_", y, "_", nm)]] |>
      dplyr::arrange(dplyr::across(dplyr::everything()))
    symb <- ifelse(identical(xres, yres), "v", "x")
    "{.pkg {nm}} {x} vs {y}" |>
      cli::cli_inform()
  })
}) |>
  invisible()

# plots ----
# compare insert mock data
result |>
  dplyr::filter(.data$task == "insert toy data") |>
  ggplot2::ggplot(mapping = ggplot2::aes(x = .data$db, y = .data$time, colour = .data$db, fill = .data$db)) +
  ggplot2::geom_col()

# compare summarise mock data
res <- result |>
  dplyr::filter(stringr::str_detect(.data$task, "mock")) |>
  dplyr::mutate(task = stringr::str_replace(.data$task, " mock", "")) |>
  tidyr::pivot_wider(names_from = "task", values_from = "time") |>
  dplyr::mutate(
    `summariseOneByOneOnlyId+summariseCompute` = .data$summariseOneByOneOnlyId + .data$summariseCompute,
    `summariseOneByOneOnlyId+summariseCollect` = .data$summariseOneByOneOnlyId + .data$summariseCollect,
    `summariseOneByOneOnlyId+summariseOneByOne` = .data$summariseOneByOneOnlyId + .data$summariseOneByOne
  ) |>
  dplyr::select(!"summariseOneByOneOnlyId") |>
  tidyr::pivot_longer(cols = !"db") |>
  dplyr::mutate(type = dplyr::if_else(stringr::str_detect(.data$name, "Id"), "records and subjects", "only records")) |>
  dplyr::rename(method = "name")

res |>
  dplyr::filter(.data$type == "records and subjects") |>
  ggplot2::ggplot(mapping = ggplot2::aes(x = .data$method, y = .data$value, colour = .data$value,  fill = .data$value)) +
  ggplot2::geom_col() +
  ggplot2::facet_grid(. ~ .data$db) +
  ggplot2::coord_flip() +
  ggplot2::labs(title = "Records and subjects")

res |>
  dplyr::filter(.data$type == "only records") |>
  ggplot2::ggplot(mapping = ggplot2::aes(x = .data$method, y = .data$value, colour = .data$value,  fill = .data$value)) +
  ggplot2::geom_col() +
  ggplot2::facet_grid(. ~ .data$db) +
  ggplot2::coord_flip() +
  ggplot2::labs(title = "Only records")

# compare condition_occurrence
res <- result |>
  dplyr::filter(stringr::str_detect(.data$task, "condition_occurrence")) |>
  dplyr::mutate(
    compute = dplyr::if_else(
      stringr::str_detect(.data$task, "computed"), "Yes", "No"
    )
  ) |>
  tidyr::separate_wider_delim(cols = "task", delim = " ", names = "task", too_many = "drop") |>
  tidyr::pivot_wider(names_from = "task", values_from = "time") |>
  dplyr::mutate(
    `summariseOneByOneOnlyId+summariseCompute` = .data$summariseOneByOneOnlyId + .data$summariseCompute,
    `summariseOneByOneOnlyId+summariseCollect` = .data$summariseOneByOneOnlyId + .data$summariseCollect,
    `summariseOneByOneOnlyId+summariseOneByOne` = .data$summariseOneByOneOnlyId + .data$summariseOneByOne,
  ) |>
  dplyr::select(!"summariseOneByOneOnlyId") |>
  tidyr::pivot_longer(cols = !c("db", "compute")) |>
  dplyr::mutate(type = dplyr::if_else(stringr::str_detect(.data$name, "Id"), "records and subjects", "only records")) |>
  dplyr::rename(method = "name") |>
  dplyr::left_join(
    result |>
      dplyr::filter(.data$task == "compute query") |>
      dplyr::select("db", compute_time = "time"),
    by = "db"
  ) |>
  dplyr::mutate(
    value = dplyr::if_else(.data$compute == "Yes", .data$value + .data$compute_time, .data$value),
    method = dplyr::if_else(.data$compute == "Yes", paste0("compute+", .data$method), .data$method)
  ) |>
  dplyr::select(!c("compute", "compute_time"))

res |>
  dplyr::filter(.data$type == "records and subjects") |>
  ggplot2::ggplot(mapping = ggplot2::aes(x = .data$method, y = .data$value, colour = .data$value,  fill = .data$value)) +
  ggplot2::geom_col() +
  ggplot2::facet_grid(. ~ .data$db) +
  ggplot2::coord_flip() +
  ggplot2::labs(title = "Records and subjects")

res |>
  dplyr::filter(.data$type == "only records") |>
  ggplot2::ggplot(mapping = ggplot2::aes(x = .data$method, y = .data$value, colour = .data$value,  fill = .data$value)) +
  ggplot2::geom_col() +
  ggplot2::facet_grid(. ~ .data$db) +
  ggplot2::coord_flip() +
  ggplot2::labs(title = "Only records")
