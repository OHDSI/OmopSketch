test_that("summariseTrend - episode works", {
  skip_on_cran()
  # Load mock database ----
  cdm <- cdmEunomia()

  # Check all tables work ----
  expect_true(inherits(summariseTrend(cdm), "summarised_result"))
  expect_equal(summariseTrend(cdm), omopgenerics::emptySummarisedResult(), ignore_attr = TRUE)
  expect_no_error(x <- summariseTrend(cdm, episode = "drug_exposure", event = "condition_occurrence", interval = "months"))
  expect_true(inherits(x, "summarised_result"))

  # Check inputs ----
  x <- summariseTrend(cdm, episode = "observation_period", interval = "years") |>
    dplyr::filter(additional_level == "1909-01-01 to 1909-12-31", estimate_name == "count") |>
    dplyr::pull("estimate_value") |>
    as.numeric()
  y <- cdm$observation_period |>
    getYear(date = "observation_period_start_date", name = "start_year") |>
    getYear(date = "observation_period_end_date", name = "end_year") |>
    dplyr::filter(start_year <= 1909, end_year >= 1909) |>
    dplyr::tally() |>
    dplyr::pull("n") |>
    as.numeric()
  expect_equal(x, y)

  x <- summariseTrend(cdm, episode = "observation_period", interval = "years")
  expect_equal(x |> dplyr::filter(additional_level != "overall") |> dplyr::pull("additional_name") |> unique(), "time_interval")
  x <- summariseTrend(cdm, episode = "drug_exposure", interval = "overall")
  expect_equal(x |> dplyr::filter(additional_level == "overall") |> dplyr::pull("additional_name") |> unique(), "overall")

  x <- summariseTrend(cdm, episode = "drug_exposure", interval = "years") |>
    dplyr::filter(additional_level == c("1936-01-01 to 1936-12-31"), estimate_name == "count") |>
    dplyr::pull("estimate_value") |>
    as.numeric()
  y <- cdm$drug_exposure |>
    getYear(date = "drug_exposure_start_date", name = "start") |>
    getYear(date = "drug_exposure_end_date", name = "end") |>
    dplyr::filter((.data$start < 1936 & .data$end >= 1936) |
      (.data$start >= 1936 & .data$start <= 1936)) |>
    dplyr::tally() |>
    dplyr::pull("n") |>
    as.numeric()
  expect_equal(x, y)

  x <- summariseTrend(cdm, episode = "observation_period", interval = "years") |>
    dplyr::filter(additional_level == c("1936-01-01 to 1936-12-31"), estimate_name == "count") |>
    dplyr::pull("estimate_value") |>
    as.numeric()
  y <- cdm$observation_period |>
    getYear(date = "observation_period_start_date", name = "start") |>
    getYear(date = "observation_period_end_date", name = "end") |>
    dplyr::filter((.data$start < 1936 & .data$end >= 1936) |
      (.data$start >= 1936 & .data$start <= 1936)) |>
    dplyr::tally() |>
    dplyr::pull("n") |>
    as.numeric()
  expect_equal(x, y)

  x <- summariseTrend(cdm, episode = "observation_period", output = "person", interval = "years") |>
    dplyr::filter(additional_level == c("1996-01-01 to 1996-12-31"), estimate_name == "count") |>
    dplyr::pull("estimate_value") |>
    as.numeric()
  y <- cdm$observation_period |>
    getYear(date = "observation_period_start_date", name = "start") |>
    getYear(date = "observation_period_end_date", name = "end") |>
    dplyr::filter((.data$start < 1996 & .data$end >= 1996) |
      (.data$start >= 1996 & .data$start <= 1996)) |>
    dplyr::distinct(.data$person_id) |>
    dplyr::tally() |>
    dplyr::pull("n") |>
    as.numeric()
  expect_equal(x, y)

  x <- summariseTrend(cdm, episode = "condition_occurrence", interval = "years") |>
    dplyr::filter(additional_level == c("1998-01-01 to 1998-12-31"), estimate_name == "count") |>
    dplyr::pull("estimate_value") |>
    as.numeric()
  y <- cdm$condition_occurrence |>
    getYear(date = "condition_start_date", name = "start") |>
    getYear(date = "condition_end_date", name = "end") |>
    dplyr::filter((.data$start < 1998 & .data$end >= 1998) |
          (.data$start == 1998)) |>

    dplyr::tally() |>
    dplyr::pull("n") |>
    as.numeric()
  expect_equal(x, y)

  x <- summariseTrend(cdm, episode = "observation_period", interval = "months") |>
    dplyr::filter(additional_level == "1942-03-01 to 1942-03-31", estimate_name == "count") |>
    dplyr::pull("estimate_value") |>
    as.numeric()
  y <- cdm$observation_period |>
    dplyr::filter(
      (observation_period_start_date < as.Date("1942-03-01") & observation_period_end_date >= as.Date("1942-03-01")) |
        (observation_period_start_date >= as.Date("1942-03-01") & observation_period_start_date <= as.Date("1942-03-31"))
    ) |>
    dplyr::tally() |>
    dplyr::pull("n") |>
    as.numeric()
  expect_equal(x, y)

  dropCreatedTables(cdm = cdm)
})

test_that("summariseTrend - event works", {
  skip_on_cran()
  # Load mock database ----
  cdm <- cdmEunomia()

  # Check inputs ----
  expect_no_error(inherits(summariseTrend(cdm, event = "observation_period", interval = "months"), "summarised_result"))

  expect_no_error(summariseTrend(cdm, event = "observation_period"))
  expect_no_error(summariseTrend(cdm, event = "visit_occurrence"))
  expect_no_error(summariseTrend(cdm, event = "drug_exposure"))
  expect_no_error(summariseTrend(cdm, event = "procedure_occurrence"))
  expect_no_error(summariseTrend(cdm, event = "measurement"))
  expect_warning(de <- summariseTrend(cdm, event = "death"))
  checkResultType(de, "summarise_trend")

  expect_no_error(co <- summariseTrend(cdm, event = "condition_occurrence"))
  expect_warning(de <- summariseTrend(cdm, event = "device_exposure"))
  expect_no_error(o <- summariseTrend(cdm, event = "observation"))

  expect_warning(all <- summariseTrend(cdm, event = c(
    "condition_occurrence",
    "device_exposure", "observation"
  )))
  expect_equal(all, dplyr::bind_rows(co, de, o))

  # Check inputs ----
  expect_true(
    (summariseTrend(cdm, event = "observation_period", interval = "years") |>
      dplyr::filter(additional_level == "1963-01-01 to 1963-12-31", estimate_name == "count") |>
      dplyr::pull("estimate_value") |>
      as.numeric()) ==
      (cdm$observation_period |>
        dplyr::ungroup() |>
        dplyr::mutate(year = clock::get_year(observation_period_start_date)) |>
        dplyr::filter(year == 1963) |>
        dplyr::tally() |>
        dplyr::pull("n"))

  )

  expect_true(
    summariseTrend(cdm, event = "condition_occurrence", interval = "months") |>
      dplyr::filter(additional_level == "1961-02-01 to 1961-02-28", estimate_name == "count") |>
      dplyr::pull("estimate_value") |>
      as.numeric() ==
      (cdm$condition_occurrence |>
        dplyr::ungroup() |>
        dplyr::mutate(year = clock::get_year(condition_start_date)) |>
        dplyr::mutate(month = clock::get_month(condition_start_date)) |>
        dplyr::filter(year == 1961, month == 2) |>
        dplyr::tally() |>
        dplyr::pull("n"))
  )

  expect_true(
    (summariseTrend(cdm, event = "condition_occurrence", interval = "months") |>
      dplyr::filter(additional_level %in% c("1984-01-01 to 1984-01-31", "1984-02-01 to 1984-02-29", "1984-03-01 to 1984-03-31"), estimate_name == "count") |>
      dplyr::summarise("estimate_value" = sum(as.numeric(estimate_value), na.rm = TRUE)) |>
      dplyr::pull("estimate_value") |>
      as.numeric()) ==
      (cdm$condition_occurrence |>
        dplyr::ungroup() |>
        dplyr::mutate(year = clock::get_year(condition_start_date)) |>
        dplyr::mutate(month = clock::get_month(condition_start_date)) |>
        dplyr::filter(year == 1984, month %in% c(1:3)) |>
        dplyr::tally() |>
        dplyr::pull("n"))
  )

  expect_true(
    (summariseTrend(cdm, event = "drug_exposure", interval = "years") |>
      dplyr::filter(additional_level %in% c(
        "1981-01-01 to 1981-12-31", "1982-01-01 to 1982-12-31", "1983-01-01 to 1983-12-31",
        "1984-01-01 to 1984-12-31", "1985-01-01 to 1985-12-31", "1986-01-01 to 1986-12-31",
        "1987-01-01 to 1987-12-31", "1988-01-01 to 1988-12-31"
      ), estimate_name == "count") |>
      dplyr::summarise("estimate_value" = sum(as.numeric(.data$estimate_value), na.rm = TRUE)) |>
      dplyr::pull("estimate_value") |>
      as.numeric()) ==
      (cdm$drug_exposure |>
        dplyr::ungroup() |>
        dplyr::mutate(year = clock::get_year(drug_exposure_start_date)) |>
        dplyr::filter(year %in% c(1981:1988)) |>
        dplyr::tally() |>
        dplyr::pull("n")) )

  # Check result type
  result <- summariseTrend(cdm, event = "observation_period", interval = "months")
  checkResultType(result, "summarise_trend")

  dropCreatedTables(cdm = cdm)
})

test_that("check sex argument works", {
  skip_on_cran()
  # Load mock database ----
  cdm <- cdmEunomia()

  # Check overall
  x <- summariseTrend(cdm, episode = "observation_period", interval = "years", sex = TRUE)
  expect_equal(x |> dplyr::filter(additional_level != "overall") |> dplyr::pull("additional_name") |> unique(), "time_interval")
  x <- summariseTrend(cdm, episode = "observation_period", interval = "overall")
  expect_equal(x |> dplyr::filter(additional_level == "overall") |> dplyr::pull("additional_name") |> unique(), "overall")

  x <- summariseTrend(cdm, event = "visit_occurrence", interval = "years", sex = TRUE) |>
    dplyr::filter(strata_level %in% c("Male", "Female"), additional_level == "1923-01-01 to 1923-12-31", estimate_name == "count") |>
    dplyr::pull(estimate_value) |>
    as.numeric() |>
    sum()
  y <- summariseTrend(cdm, event = "visit_occurrence", interval = "years", sex = TRUE) |>
    dplyr::filter(strata_level %in% c("overall"), additional_level == "1923-01-01 to 1923-12-31", estimate_name == "count") |>
    dplyr::pull(estimate_value) |>
    as.numeric()
  expect_equal(x, y)

  y <- cdm$visit_occurrence |>
    dplyr::filter(visit_start_date < as.Date("1923-01-01") & visit_end_date >= as.Date("1923-01-01") |
      (visit_start_date >= as.Date("1923-01-01") & visit_start_date <= as.Date("1923-12-31"))) |>
    dplyr::tally() |>
    dplyr::pull() |>
    as.numeric()
  expect_equal(x, y)

  # Check a random group
  x <- summariseTrend(cdm, episode = "observation_period", interval = "years", sex = TRUE) |>
    dplyr::filter(strata_level == "Male", additional_level == "1915-01-01 to 1915-12-31", estimate_name == "count") |>
    dplyr::pull(estimate_value) |>
    as.numeric()
  y <- cdm$observation_period |>
    PatientProfiles::addSexQuery() |>
    dplyr::filter(sex == "Male") |>
    dplyr::filter(observation_period_start_date < as.Date("1915-01-01") & observation_period_end_date >= as.Date("1915-01-01") |
      (observation_period_start_date >= as.Date("1915-01-01") & observation_period_start_date <= as.Date("1915-12-31"))) |>
    dplyr::tally() |>
    dplyr::pull() |>
    as.numeric()
  expect_equal(x, y)

  x <- summariseTrend(cdm, event = "observation_period", interval = "years", sex = TRUE) |>
    dplyr::filter(strata_level == "Male", additional_level == "1918-01-01 to 1918-12-31", estimate_name == "percentage") |>
    dplyr::pull(estimate_value)
  y <- (cdm$observation_period |>
    PatientProfiles::addSexQuery() |>
    dplyr::filter(sex == "Male") |>
    dplyr::filter(observation_period_start_date >= as.Date("1918-01-01") & observation_period_start_date <= as.Date("1918-12-31")) |>
    dplyr::tally() |>
    dplyr::pull()) / (cdm[["observation_period"]] |> dplyr::tally() |> dplyr::pull() |> as.numeric()) * 100
  expect_equal(x, sprintf("%.2f", y))

  expect_no_error(x <- summariseTrend(cdm, event = "observation_period", output = "person", interval = "years", sex = TRUE))
  x <- x |>
    dplyr::filter(strata_level == "Male", additional_level == "1918-01-01 to 1918-12-31", estimate_name == "percentage") |>
    dplyr::pull(estimate_value)
  y <- cdm$observation_period |>
    dplyr::inner_join(cdm[["person"]] |> dplyr::select("person_id"), by = "person_id") |>
    PatientProfiles::addSexQuery() |>
    dplyr::filter(sex == "Male") |>
    dplyr::filter(observation_period_start_date >= as.Date("1918-01-01") & observation_period_start_date <= as.Date("1918-12-31")) |>
    dplyr::summarise(p = dplyr::n_distinct(.data$person_id)) |>
    dplyr::pull()
  y <- y / (cdm[["person"]] |> dplyr::tally() |> dplyr::pull()) * 100

  expect_equal(x, sprintf("%.2f", y))

  dropCreatedTables(cdm = cdm)
})

test_that("check ageGroup argument works", {
  skip_on_cran()
  # Load mock database ----
  cdm <- cdmEunomia()

  expect_no_error(summariseTrend(cdm, episode = "observation_period", event = "drug_exposure", ageGroup = list(c(0, 20), c(21, Inf))))

  x <- summariseTrend(cdm, episode = "observation_period", interval = "years", ageGroup = list("<=20" = c(0, 20), ">20" = c(21, Inf))) |>
    dplyr::filter(additional_level == "1928-01-01 to 1928-12-31", estimate_name == "count", strata_level == "<=20") |>
    dplyr::pull(estimate_value) |>
    as.numeric()
  y <- cdm$observation_period |>
    dplyr::filter(observation_period_start_date < as.Date("1928-01-01") & observation_period_end_date >= as.Date("1928-01-01") |
      (observation_period_start_date >= as.Date("1928-01-01") & observation_period_start_date <= as.Date("1928-12-31"))) |>
    dplyr::mutate("start" = as.Date("1928-01-01"), "end" = as.Date("1928-12-31")) |>
    PatientProfiles::addAgeQuery(indexDate = "start", ageName = "age_start") |>
    dplyr::mutate(age_end = age_start + 10) |>
    dplyr::filter((age_end <= 20 & age_end >= 0) | (age_start >= 0 & age_start <= 20)) |>
    dplyr::tally() |>
    dplyr::pull() |>
    as.numeric()
  expect_equal(x, y)

  x <- summariseTrend(cdm, event = "observation_period", interval = "years", ageGroup = list("<=20" = c(0, 20), ">20" = c(21, Inf))) |>
    dplyr::filter(additional_level == "1928-01-01 to 1928-12-31", estimate_name == "count", strata_level == "<=20") |>
    dplyr::pull(estimate_value) |>
    as.numeric()
  y <- cdm$observation_period |>
    dplyr::filter(observation_period_start_date >= as.Date("1928-01-01") & observation_period_start_date <= as.Date("1928-12-31")) |>
    dplyr::mutate("start" = as.Date("1928-01-01"), "end" = as.Date("1928-12-31")) |>
    PatientProfiles::addAgeQuery(indexDate = "start", ageName = "age_start") |>
    dplyr::mutate(age_end = age_start + 10) |>
    dplyr::filter((age_end <= 20 & age_end >= 0) | (age_start >= 0 & age_start <= 20)) |>
    dplyr::tally() |>
    dplyr::pull() |>
    as.numeric()
  expect_equal(x, y)

  expect_no_error(x <- summariseTrend(cdm, episode = "observation_period", output = "person", ageGroup = list(c(0, 20), c(21, Inf)), interval = "years"))

  x <- x |>
    dplyr::filter(additional_level == "1928-01-01 to 1928-12-31", estimate_name == "count", strata_level == "0 to 20") |>
    dplyr::pull(estimate_value) |>
    as.numeric()
  y <- cdm$observation_period |>
    dplyr::filter(observation_period_start_date < as.Date("1928-01-01") & observation_period_end_date >= as.Date("1928-01-01") |
      (observation_period_start_date >= as.Date("1928-01-01") & observation_period_start_date <= as.Date("1928-12-31"))) |>
    dplyr::mutate("start" = as.Date("1928-01-01"), "end" = as.Date("1928-12-31")) |>
    PatientProfiles::addAgeQuery(indexDate = "start", ageName = "age_start") |>
    dplyr::mutate(age_end = age_start + 10) |>
    dplyr::filter((age_end <= 20 & age_end >= 0) | (age_start >= 0 & age_start <= 20)) |>
    dplyr::summarise(dplyr::n_distinct(person_id)) |>
    dplyr::pull()
  expect_equal(x, y)

  expect_no_error(x <- summariseTrend(cdm, event = "observation_period", output = "person", ageGroup = list(c(0, 20), c(21, Inf)), interval = "years"))

  x <- x |>
    dplyr::filter(additional_level == "1928-01-01 to 1928-12-31", estimate_name == "count", strata_level == "0 to 20") |>
    dplyr::pull("estimate_value") |>
    as.numeric()
  y <- cdm$observation_period |>
    dplyr::filter(observation_period_start_date >= as.Date("1928-01-01") & observation_period_start_date <= as.Date("1928-12-31")) |>
    dplyr::mutate("start" = as.Date("1928-01-01"), "end" = as.Date("1928-12-31")) |>
    PatientProfiles::addAgeQuery(indexDate = "start", ageName = "age_start") |>
    dplyr::mutate(age_end = age_start + 10) |>
    dplyr::filter((age_end <= 20 & age_end >= 0) | (age_start >= 0 & age_start <= 20)) |>
    dplyr::summarise(dplyr::n_distinct(person_id)) |>
    dplyr::pull() |>
    as.numeric()
  expect_equal(x, y)

  dropCreatedTables(cdm = cdm)
})

test_that("check person-days output works", {
  skip_on_cran()
  # Load mock database ----
  cdm <- cdmEunomia()

  # check value
  x <- summariseTrend(cdm, episode = "observation_period", interval = "years", output = c("record", "person-days"), ageGroup = NULL, sex = FALSE) |>
    dplyr::filter(variable_name == "Person-days", additional_level == "1970-01-01 to 1970-12-31", estimate_type == "integer") |>
    dplyr::pull("estimate_value") |>
    as.numeric()
  y <- cdm$observation_period |>
    dplyr::collect() |>
    dplyr::filter(observation_period_start_date < as.Date("1970-01-01") & observation_period_end_date >= as.Date("1970-01-01") |
      (observation_period_start_date >= as.Date("1970-01-01") & observation_period_start_date <= as.Date("1970-12-31"))) |>
    dplyr::mutate("start_date" = as.Date("1970-01-01"), "end_date" = as.Date("1970-12-31")) |>
    dplyr::mutate(
      "start_date" = pmax(start_date, observation_period_start_date, na.rm = TRUE),
      "end_date" = pmin(end_date, observation_period_end_date, na.rm = TRUE)
    ) |>
    datediffDays(start = "start_date", end = "end_date", name = "days", offset = 1) |>
    dplyr::summarise(n = sum(days, na.rm = TRUE)) |>
    dplyr::pull("n") |>
    as.numeric()
  expect_equal(x, y)

  # Check percentage
  den <- cdm$observation_period |>
    datediffDays(start = "observation_period_start_date", end = "observation_period_end_date", name = "days", offset = 1) |>
    dplyr::summarise(n = sum(days, na.rm = TRUE)) |>
    dplyr::pull("n") |>
    as.numeric()
  x <- summariseTrend(cdm, episode = "observation_period", interval = "years", output = c("record", "person-days")) |>
    dplyr::filter(variable_name == "Person-days", additional_level == "1964-01-01 to 1964-12-31", estimate_type == "percentage") |>
    dplyr::pull("estimate_value")
  y <- cdm$observation_period |>
    dplyr::collect() |>
    dplyr::filter(observation_period_start_date < as.Date("1964-01-01") & observation_period_end_date >= as.Date("1964-01-01") |
      (observation_period_start_date >= as.Date("1964-01-01") & observation_period_start_date <= as.Date("1964-12-31"))) |>
    dplyr::mutate("start_date" = as.Date("1964-01-01"), "end_date" = as.Date("1964-12-31")) |>
    dplyr::mutate(
      "start_date" = pmax(start_date, observation_period_start_date, na.rm = TRUE),
      "end_date" = pmin(end_date, observation_period_end_date, na.rm = TRUE)
    ) |>
    datediffDays(start = "start_date", end = "end_date", name = "days", offset = 1) |>
    dplyr::summarise(n = sum(days, na.rm = TRUE)) |>
    dplyr::pull("n") |>
    as.numeric() / den * 100
  expect_equal(x, sprintf("%.2f", y))

  # Check sex stratified
  x <- summariseTrend(cdm, episode = "observation_period", interval = "years", output = "person-days", sex = TRUE) |>
    dplyr::filter(variable_name == "Person-days", additional_level == "1964-01-01 to 1964-12-31", estimate_type == "integer") |>
    dplyr::filter(strata_level == "overall") |>
    dplyr::pull("estimate_value") |>
    as.numeric()
  y <- summariseTrend(cdm, episode = "observation_period", interval = "years", output = "person-days", sex = TRUE) |>
    dplyr::filter(variable_name == "Person-days", additional_level == "1964-01-01 to 1964-12-31", estimate_type == "integer") |>
    dplyr::filter(strata_level != "overall") |>
    dplyr::pull("estimate_value") |>
    as.numeric() |>
    sum()
  expect_equal(x, y)

  # Check age stratified
  x <- summariseTrend(cdm, episode = "drug_exposure", interval = "years", output = "person-days", ageGroup = list("<=20" = c(0, 20), ">20" = c(21, Inf))) |>
    dplyr::filter(variable_name == "Person-days", additional_level == "2000-01-01 to 2000-12-31", estimate_type == "integer") |>
    dplyr::filter(strata_level == "overall") |>
    dplyr::pull("estimate_value") |>
    as.numeric()
  y <- summariseTrend(cdm, episode = "drug_exposure", interval = "years", output = "person-days", sex = TRUE) |>
    dplyr::filter(variable_name == "Person-days", additional_level == "2000-01-01 to 2000-12-31", estimate_type == "integer") |>
    dplyr::filter(strata_level != "overall") |>
    dplyr::pull("estimate_value") |>
    as.numeric() |>
    sum()
  expect_equal(x, y)

  expect_message(x <- summariseTrend(cdm, event = "observation_period", output = "person-days"))
  expect_equal(x, omopgenerics::emptySummarisedResult(), ignore_attr = TRUE)
  expect_equal(summariseTrend(cdm, event = "observation_period", output = c("record", "person-days")), summariseTrend(cdm, event = "observation_period", output = c("record")))

  dropCreatedTables(cdm = cdm)
})

test_that("dateRange argument works", {
  skip_on_cran()
  # Load mock database ----
  cdm <- cdmEunomia()

  # tables created
  startNames <- omopgenerics::listSourceTables(cdm)

  expect_no_error(summariseTrend(cdm, episode = "observation_period", dateRange = as.Date(c("1940-01-01", "2018-01-01"))))
  expect_message(x <- summariseTrend(cdm, episode = "observation_period", dateRange = as.Date(c("1940-01-01", "2024-01-01"))))
  observationRange <- cdm$observation_period |>
    dplyr::summarise(
      minobs = min(.data$observation_period_start_date, na.rm = TRUE),
      maxobs = max(.data$observation_period_end_date, na.rm = TRUE)
    )
  expect_no_error(y <- summariseTrend(cdm, episode = "observation_period", dateRange = as.Date(c("1940-01-01", observationRange |> dplyr::pull("maxobs")))))
  expect_equal(x, y, ignore_attr = TRUE)
  expect_false(settings(x)$study_period_end == settings(y)$study_period_end)
  expect_error(summariseTrend(cdm, episode = "observation_period", dateRange = as.Date(c("2015-01-01", "2014-01-01"))))
  expect_warning(z <- summariseTrend(cdm, episode = "observation_period", dateRange = as.Date(c("2020-01-01", "2021-01-01"))))
  expect_equal(z, omopgenerics::emptySummarisedResult(), ignore_attr = TRUE)
  expect_equal(summariseTrend(cdm, episode = "observation_period", dateRange = as.Date(c("1940-01-01", NA))), y, ignore_attr = TRUE)
  checkResultType(z, "summarise_trend")

  x <- summariseTrend(cdm, episode = "observation_period", dateRange = as.Date(c("1940-01-01", "1940-12-31"))) |>
    dplyr::filter(estimate_name == "count") |>
    dplyr::pull(estimate_value)
  y <- summariseTrend(cdm, event = "observation_period", dateRange = as.Date(c("1940-01-01", "1940-12-31"))) |>
    dplyr::filter(estimate_name == "count") |>
    dplyr::pull(estimate_value)
  expect_false(x == y)

  expect_no_error(summariseTrend(cdm, event = "condition_occurrence", dateRange = as.Date(c("2012-01-01", "2018-01-01"))))
  expect_message(x <- summariseTrend(cdm, event = "drug_exposure", dateRange = as.Date(c("2012-01-01", "2025-01-01"))))
  observationRange <- cdm$observation_period |>
    dplyr::summarise(
      minobs = min(.data$observation_period_start_date, na.rm = TRUE),
      maxobs = max(.data$observation_period_end_date, na.rm = TRUE)
    )
  expect_no_error(y <- summariseTrend(cdm, event = "drug_exposure", dateRange = as.Date(c("2012-01-01", observationRange |> dplyr::pull("maxobs")))))
  expect_equal(x, y, ignore_attr = TRUE)
  expect_false(settings(x)$study_period_end == settings(y)$study_period_end)
  expect_error(summariseTrend(cdm, event = "drug_exposure", dateRange = as.Date(c("2015-01-01", "2014-01-01"))))
  expect_message(expect_warning(z <- summariseTrend(cdm, event = "drug_exposure", dateRange = as.Date(c("2020-01-01", "2021-01-01")))))
  expect_equal(z, omopgenerics::emptySummarisedResult(), ignore_attr = TRUE)
  expect_equal(summariseTrend(cdm, event = "drug_exposure", dateRange = as.Date(c("2012-01-01", NA))), y, ignore_attr = TRUE)

  expect_no_error(summariseTrend(cdm, "observation_period",
    interval = "years",
    dateRange = as.Date(c("1950-01-01", NA))
  ))

  results <- summariseTrend(cdm,
    episode = "observation_period",
    event = "drug_exposure",
    output = c("age", "sex", "record", "person-days", "person"),
    interval = "years",
    sex = TRUE,
    ageGroup = list(
      c(0, 17),
      c(18, 65),
      c(66, 100)
    ),
    dateRange = as.Date(c("2012-01-01", "2018-01-01"))
  )

  endNames <- omopgenerics::listSourceTables(cdm)

  expect_true(length(setdiff(endNames, startNames)) == 0)

  dropCreatedTables(cdm = cdm)
})

test_that("age and sex output work", {
  skip_on_cran()
  # Load mock database ----
  cdm <- cdmEunomia()

  expect_no_error(x <- summariseTrend(cdm, episode = "observation_period", output = "age"))
  expect_equal(cdm$observation_period |>
    PatientProfiles::addAgeQuery(indexDate = "observation_period_start_date") |>
    dplyr::pull("age") |>
    stats::median(), as.numeric(x$estimate_value))
  expect_no_error(y <- summariseTrend(cdm, episode = "observation_period", output = "age", sex = TRUE, ageGroup = list(c(0, 50))))
  y <- y |>
    omopgenerics::splitStrata() |>
    dplyr::filter(.data$sex == "Female" & .data$age_group == "0 to 50") |>
    dplyr::pull("estimate_value") |>
    as.numeric()
  z <- cdm$observation_period |>
    PatientProfiles::addDemographicsQuery(indexDate = "observation_period_start_date", age = TRUE, ageGroup = list(c(0, 50)), sex = TRUE, priorObservation = FALSE, futureObservation = TRUE) |>
    dplyr::filter(.data$sex == "Female" & .data$age_group == "0 to 50") |>
    dplyr::pull("age") |>
    stats::median()
  expect_equal(y, z)

  expect_no_error(y <- summariseTrend(cdm, episode = "observation_period", output = "age", sex = TRUE, ageGroup = list(c(0, 50)), interval = "years"))
  y <- y |>
    omopgenerics::splitAll() |>
    dplyr::filter(.data$time_interval == "2019-01-01 to 2019-12-31" & .data$sex == "Female" & .data$age_group == "0 to 50") |>
    dplyr::pull("estimate_value") |>
    as.numeric()
  z <- cdm$observation_period |>
    dplyr::filter(observation_period_start_date < as.Date("2019-01-01") & observation_period_end_date >= as.Date("2019-01-01") |
      (observation_period_start_date >= as.Date("2019-01-01") & observation_period_start_date <= as.Date("2019-12-31"))) |>
    dplyr::mutate("start_date" = as.Date("2019-01-01")) |>
    dplyr::mutate("index_date" = dplyr::if_else(
      .data$start_date <= .data$observation_period_start_date,
      .data$observation_period_start_date,
      .data$start_date
    )) |>
    PatientProfiles::addDemographicsQuery(indexDate = "index_date", age = TRUE, ageGroup = list(c(0, 50)), sex = TRUE, priorObservation = FALSE, futureObservation = TRUE) |>
    dplyr::filter(.data$sex == "Female" & .data$age_group == "0 to 50") |>
    dplyr::pull("age") |>
    stats::median()

  expect_equal(y, z)

  expect_no_error(x <- summariseTrend(cdm, episode = "observation_period", output = "sex"))
  y <- cdm$observation_period |>
    PatientProfiles::addSexQuery() |>
    dplyr::collect() |>
    dplyr::mutate("n_tot" = dplyr::n_distinct(.data$person_id)) |>
    dplyr::filter(.data$sex == "Female") |>
    dplyr::summarise("n_females" = dplyr::n_distinct(.data$person_id), n_tot = dplyr::first(.data$n_tot))
  expect_equal(sprintf("%.2f", 100 * y$n_females / y$n_tot), x |> dplyr::filter(estimate_type == "percentage") |> dplyr::pull(estimate_value))
  expect_equal(x, summariseTrend(cdm, episode = "observation_period", sex = TRUE, output = "sex"))

  expect_no_error(y <- summariseTrend(cdm, episode = "observation_period", output = "sex", ageGroup = list(c(0, 50)), interval = "years"))
  y <- y |>
    omopgenerics::splitAll() |>
    dplyr::filter(.data$time_interval == "2019-01-01 to 2019-12-31" & .data$age_group == "0 to 50" & .data$estimate_type == "percentage") |>
    dplyr::pull("estimate_value")

  z <- cdm$observation_period |>
    dplyr::inner_join(
      cdm$person |>
        dplyr::filter(.data$gender_concept_id %in% c(8507, 8532)),
      by = "person_id"
    )
  ntot <- z |>
    dplyr::summarise(n_tot = dplyr::n_distinct(.data$person_id)) |>
    dplyr::pull()
  z <- z |>
    dplyr::mutate("n_tot" = .env$ntot) |>
    dplyr::mutate("start_date" = as.Date("2019-01-01")) |>
    dplyr::filter(observation_period_start_date < as.Date("2019-01-01") & observation_period_end_date >= as.Date("2019-01-01") |
      (observation_period_start_date >= as.Date("2019-01-01") & observation_period_start_date <= as.Date("2019-12-31"))) |>
    dplyr::mutate("index_date" = dplyr::if_else(
      .data$start_date <= .data$observation_period_start_date,
      .data$observation_period_start_date,
      .data$start_date
    )) |>
    PatientProfiles::addDemographicsQuery(indexDate = "index_date", age = TRUE, ageGroup = list(c(0, 50)), sex = TRUE, priorObservation = FALSE, futureObservation = TRUE) |>
    dplyr::filter(.data$age_group == "0 to 50" & .data$sex == "Female") |>
    dplyr::collect() |>
    dplyr::summarise("n_females" = dplyr::n_distinct(.data$person_id), n_tot = dplyr::first(.data$n_tot))
  expect_equal(sprintf("%.2f", 100 * z$n_females / z$n_tot), y)

  ### event

  expect_no_error(x <- summariseTrend(cdm, event = "observation_period", output = "age"))
  expect_equal(cdm$observation_period |>
    PatientProfiles::addAgeQuery(indexDate = "observation_period_start_date") |>
    dplyr::pull("age") |>
    stats::median(), as.numeric(x$estimate_value))
  expect_no_error(y <- summariseTrend(cdm, event = "observation_period", output = "age", sex = TRUE, ageGroup = list(c(0, 50))))
  y <- y |>
    omopgenerics::splitStrata() |>
    dplyr::filter(.data$sex == "Female" & .data$age_group == "0 to 50") |>
    dplyr::pull("estimate_value") |>
    as.numeric()
  z <- cdm$observation_period |>
    PatientProfiles::addDemographicsQuery(indexDate = "observation_period_start_date", age = TRUE, ageGroup = list(c(0, 50)), sex = TRUE, priorObservation = FALSE, futureObservation = TRUE) |>
    dplyr::filter(.data$sex == "Female" & .data$age_group == "0 to 50") |>
    dplyr::pull("age") |>
    stats::median()
  expect_equal(y, z)

  expect_no_error(y <- summariseTrend(cdm, event = "drug_exposure", output = "age", sex = TRUE, ageGroup = list(c(0, 50)), interval = "years"))
  y <- y |>
    omopgenerics::splitAll() |>
    dplyr::filter(.data$time_interval == "1985-01-01 to 1985-12-31" & .data$sex == "Female" & .data$age_group == "0 to 50") |>
    dplyr::pull("estimate_value") |>
    as.numeric()
  z <- cdm$drug_exposure |>
    dplyr::filter(drug_exposure_start_date >= as.Date("1985-01-01") & drug_exposure_start_date <= as.Date("1985-12-31")) |>
    PatientProfiles::addDemographicsQuery(indexDate = "drug_exposure_start_date", age = TRUE, ageGroup = list(c(0, 50)), sex = TRUE, priorObservation = FALSE, futureObservation = TRUE) |>
    dplyr::filter(.data$sex == "Female" & .data$age_group == "0 to 50") |>
    dplyr::pull("age") |>
    stats::median()

  expect_equal(y, z)

  expect_no_error(x <- summariseTrend(cdm, event = "drug_exposure", output = "sex"))
  n_tot <- cdm$drug_exposure |>
    dplyr::inner_join(cdm[["person"]] |>
      dplyr::filter(.data$gender_concept_id %in% c(8507, 8532)), by = "person_id") |>
    dplyr::summarise("n" = dplyr::n_distinct(.data$person_id)) |>
    dplyr::pull("n")

  y <- cdm$drug_exposure |>
    PatientProfiles::addSexQuery() |>
    dplyr::filter(.data$sex == "Female") |>
    dplyr::summarise("n_females" = dplyr::n_distinct(.data$person_id)) |>
    dplyr::collect()
  expect_equal(sprintf("%.2f", 100 * y$n_females / n_tot), x |> dplyr::filter(estimate_type == "percentage") |> dplyr::pull(estimate_value))
  expect_equal(x, summariseTrend(cdm, event = "drug_exposure", sex = TRUE, output = "sex"))

  expect_no_error(y <- summariseTrend(cdm, event = "condition_occurrence", output = "sex", ageGroup = list(c(0, 50)), interval = "years"))
  y <- y |>
    omopgenerics::splitAll() |>
    dplyr::filter(.data$time_interval == "2019-01-01 to 2019-12-31" & .data$age_group == "0 to 50" & estimate_type == "percentage") |>
    dplyr::pull("estimate_value")

  n_tot <- cdm$condition_occurrence |>
    dplyr::inner_join(cdm[["person"]] |>
      dplyr::filter(.data$gender_concept_id %in% c(8507, 8532)), by = "person_id") |>
    dplyr::summarise("n" = dplyr::n_distinct(.data$person_id)) |>
    dplyr::pull("n")
  z <- cdm$condition_occurrence |>
    dplyr::inner_join(
      cdm$person |>
        dplyr::filter(.data$gender_concept_id %in% c(8507, 8532)),
      by = "person_id"
    ) |>
    dplyr::filter(condition_start_date >= as.Date("2019-01-01") & condition_start_date <= as.Date("2019-12-31")) |>
    PatientProfiles::addDemographicsQuery(indexDate = "condition_start_date", age = TRUE, ageGroup = list(c(0, 50)), sex = TRUE, priorObservation = FALSE, futureObservation = FALSE) |>
    dplyr::filter(.data$age_group == "0 to 50" & .data$sex == "Female") |>
    dplyr::summarise("n_females" = dplyr::n_distinct(.data$person_id)) |>
    dplyr::collect()

  expect_equal(sprintf("%.2f", 100 * z$n_females / n_tot), y)

  dropCreatedTables(cdm = cdm)
})

test_that("overall time interval work", {
  skip_on_cran()
  # Load mock database ----
  cdm <- cdmEunomia()

  expect_no_error(x <- summariseTrend(cdm, episode = "observation_period", output = c("record", "person", "sex", "age"), interval = "years"))
  x <- x |>
    dplyr::filter(.data$additional_level == "overall" & estimate_type != "percentage")

  expect_no_error(y <- summariseTrend(cdm, event = "observation_period", output = c("record", "person", "sex", "age"), interval = "years"))
  y <- y |>
    dplyr::filter(.data$additional_level == "overall" & estimate_type != "percentage")
  expect_equal(x, y, ignore_attr = TRUE)
  records <- cdm$observation_period |>
    dplyr::tally() |>
    dplyr::pull(.data$n)

  person <- cdm$observation_period |>
    dplyr::distinct(.data$person_id) |>
    dplyr::tally() |>
    dplyr::pull(.data$n)

  sex <- cdm$observation_period |>
    PatientProfiles::addSexQuery() |>
    dplyr::filter(.data$sex == "Female") |>
    dplyr::distinct(.data$person_id) |>
    dplyr::tally() |>
    dplyr::pull(.data$n)

  age <- cdm$observation_period |>
    PatientProfiles::addAgeQuery(indexDate = "observation_period_start_date") |>
    dplyr::collect() |>
    dplyr::summarise(median = stats::median(.data$age, na.rm = TRUE), na.rm = TRUE) |>
    dplyr::pull("median")

  expect_equal(x |> dplyr::filter(variable_name == "Number of records") |> dplyr::pull(.data$estimate_value), as.character(records))
  expect_equal(x |> dplyr::filter(variable_name == "Number of subjects") |> dplyr::pull(.data$estimate_value), as.character(person))
  expect_equal(x |> dplyr::filter(variable_name == "Number of females") |> dplyr::pull(.data$estimate_value), as.character(sex))
  expect_equal(x |> dplyr::filter(variable_name == "Age") |> dplyr::pull(.data$estimate_value), as.character(age))

  expect_equal(y |> dplyr::filter(variable_name == "Number of records") |> dplyr::pull(.data$estimate_value), as.character(records))
  expect_equal(y |> dplyr::filter(variable_name == "Number of subjects") |> dplyr::pull(.data$estimate_value), as.character(person))
  expect_equal(y |> dplyr::filter(variable_name == "Number of females") |> dplyr::pull(.data$estimate_value), as.character(sex))
  expect_equal(y |> dplyr::filter(variable_name == "Age") |> dplyr::pull(.data$estimate_value), as.character(age))

  dropCreatedTables(cdm = cdm)
})

test_that("tableTrend() works", {
  skip_on_cran()
  # Load mock database ----
  cdm <- cdmEunomia()

  # Check that works ----
  expect_no_error(x <- tableTrend(summariseTrend(cdm, event = "condition_occurrence")))
  expect_true(inherits(x, "gt_tbl"))
  x <- summariseTrend(cdm, event = "condition_occurrence")
  set <- omopgenerics::settings(x) |>
    dplyr:::mutate(test = "test")
  x <- omopgenerics::newSummarisedResult(x, settings = set)
  expect_no_error(tableTrend(x, type = "reactable"))

  expect_no_error(y <- tableTrend(summariseTrend(cdm, episode = "observation_period", event = c(
    "observation_period",
    "measurement"
  ))))
  expect_true(inherits(y, "gt_tbl"))
  expect_warning(t <- summariseTrend(cdm, event = "death"))
  expect_warning(inherits(tableTrend(t), "gt_tbl"))
  expect_no_error(x <- tableTrend(summariseTrend(cdm, episode = "condition_occurrence"), type = "datatable"))
  expect_no_error(x <- tableTrend(summariseTrend(cdm, event = "condition_occurrence"), type = "reactable"))
  expect_no_error(tableTrend(summariseTrend(cdm, event = "condition_occurrence", output = "age")))
  expect_no_error(tableTrend(summariseTrend(cdm, episode = "drug_exposure", event = "condition_occurrence", interval = "years", output = c("age", "record"), sex = TRUE)))
  expect_warning(tableTrend(omopgenerics::emptySummarisedResult()))
  dropCreatedTables(cdm = cdm)
})

test_that("plotTrend() works", {
  skip_on_cran()
  # Load mock database ----
  cdm <- cdmEunomia()

  # Check that works ----
  expect_no_error(x <- plotTrend(summariseTrend(cdm, event = "condition_occurrence")))
  expect_true(inherits(x, "ggplot"))
  expect_no_error(x <- plotTrend(summariseTrend(cdm, event = "condition_occurrence"), type = "plotly"))
  expect_true(inherits(x, "plotly"))
  expect_warning(plotTrend(omopgenerics::emptySummarisedResult()))
  expect_no_error(plotTrend(summariseTrend(cdm, episode = "observation_period")))
  expect_no_error(plotTrend(summariseTrend(cdm, episode = "observation_period", output = "age", interval = "years")))
  expect_no_error(plotTrend(summariseTrend(cdm, episode = "observation_period", output = c("age", "record"), interval = "months")))
  expect_no_error(plotTrend(summariseTrend(cdm, episode = "observation_period", output = c("person", "person-days"), interval = "quarters"), output = "person-days"))

  expect_warning(plotTrend(summariseTrend(cdm, episode = "condition_occurrence", event = "drug_exposure"), colour = NULL, facet = NULL))

  dropCreatedTables(cdm = cdm)
})

test_that("argument inObservation works", {
  skip_on_cran()
  # Load mock database ----
  cdm <- cdmEunomia()

  expect_equal(summariseTrend(cdm, event = "observation_period", inObservation = TRUE), summariseTrend(cdm, event = "observation_period", inObservation = FALSE))
  expect_equal(summariseTrend(cdm, episode = "observation_period", inObservation = TRUE), summariseTrend(cdm, episode = "observation_period", inObservation = FALSE))
  expect_equal(summariseTrend(cdm, episode = "observation_period", inObservation = TRUE, interval = "years"), summariseTrend(cdm, episode = "observation_period", inObservation = FALSE, interval = "years"))

  expect_no_error(result <- summariseTrend(cdm, event = "condition_occurrence", episode = "drug_exposure", inObservation = TRUE, sex = TRUE, output = c("record", "person", "age", "sex", "person-days")))

  result <- result |>
    omopgenerics::splitStrata() |>
    dplyr::filter(.data$in_observation == TRUE) |>
    dplyr::select(!"in_observation") |>
    omopgenerics::uniteStrata(cols = "sex")

  cdm$condition_occurrence <- cdm$condition_occurrence |>
    dplyr::inner_join(
      cdm$observation_period |> dplyr::select("person_id",
        "obs_start" = "observation_period_start_date",
        "obs_end" = "observation_period_end_date"
      ),
      by = "person_id"
    ) |>

    dplyr::filter(.data$condition_start_date >= .data$obs_start & .data$condition_start_date <= .data$obs_end) |>
    dplyr::select(!c("obs_start", "obs_end"))

  cdm$drug_exposure <- cdm$drug_exposure |>
    dplyr::inner_join(
      cdm$observation_period |> dplyr::select("person_id",
        "obs_start" = "observation_period_start_date",
        "obs_end" = "observation_period_end_date"
      ),
      by = "person_id"
    ) |>
    dplyr::filter(.data$drug_exposure_start_date >= .data$obs_start & .data$drug_exposure_start_date <= .data$obs_end &
      .data$drug_exposure_end_date >= .data$obs_start & .data$drug_exposure_end_date <= .data$obs_end) |>
    dplyr::select(!c("obs_start", "obs_end"))

  expect_no_error(resultInObs <- summariseTrend(cdm, event = "condition_occurrence", episode = "drug_exposure", inObservation = FALSE, sex = TRUE, output = c("record", "person", "age", "sex", "person-days")))

  expect_equal(result |> dplyr::filter(.data$estimate_name != "percentage") |> dplyr::arrange(dplyr::across(dplyr::everything())), resultInObs |> dplyr::filter(.data$estimate_name != "percentage") |> dplyr::arrange(dplyr::across(dplyr::everything())), ignore_attr = TRUE)

  dropCreatedTables(cdm = cdm)
})
