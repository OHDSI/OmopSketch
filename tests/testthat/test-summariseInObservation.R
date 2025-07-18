test_that("check summariseInObservation works", {
  skip_on_cran()
  # Load mock database ----
  cdm <- cdmEunomia()

  # Check all tables work ----
  expect_true(inherits(summariseInObservation(cdm$observation_period), "summarised_result"))
  expect_true(inherits(summariseInObservation(cdm$observation_period, interval = "months"), "summarised_result"))
  expect_true(inherits(summariseInObservation(cdm$observation_period, interval = "years"), "summarised_result"))

  expect_error(summariseInObservation(cdm$death))

  # Check inputs ----
  x <- summariseInObservation(cdm$observation_period, interval = "years") |>
    dplyr::filter(additional_level == "1909-01-01 to 1909-12-31", estimate_name == "count") |>
    dplyr::pull("estimate_value") |>
    as.numeric()
  y <- cdm$observation_period %>%
    dplyr::inner_join(cdm[["person"]] |> dplyr::select("person_id"), by = "person_id") %>%
    dplyr::mutate(start_year = !!CDMConnector::datepart("observation_period_start_date", "year")) %>%
    dplyr::mutate(end_year = !!CDMConnector::datepart("observation_period_end_date", "year")) %>%
    dplyr::filter(start_year <= 1909, end_year >= 1909) |>
    dplyr::tally() |>
    dplyr::pull("n") |>
    as.numeric()
  expect_equal(x, y)

  x <- summariseInObservation(cdm$observation_period, interval = "years")
  expect_equal(x |> dplyr::filter(additional_level != "overall") |> dplyr::pull("additional_name") |> unique(), "time_interval")
  x <- summariseInObservation(cdm$observation_period, interval = "overall")
  expect_equal(x |> dplyr::filter(additional_level == "overall") |> dplyr::pull("additional_name") |> unique(), "overall")

  x <- summariseInObservation(cdm$observation_period, interval = "years") |>
    dplyr::filter(additional_level == c("1936-01-01 to 1936-12-31"), estimate_name == "count") |>
    dplyr::pull("estimate_value") |>
    as.numeric()
  y <- cdm$observation_period %>%
    dplyr::inner_join(cdm[["person"]] |> dplyr::select("person_id"), by = "person_id") %>%
    dplyr::mutate(start = !!CDMConnector::datepart("observation_period_start_date", "year")) %>%
    dplyr::mutate(end = !!CDMConnector::datepart("observation_period_end_date", "year")) %>%
    dplyr::filter((.data$start < 1936 & .data$end >= 1936) |
      (.data$start >= 1936 & .data$start <= 1936)) |>
    dplyr::tally() |>
    dplyr::pull("n") |>
    as.numeric()
  expect_equal(x, y)

  x <- summariseInObservation(cdm$observation_period, output = "person", interval = "years") |>
    dplyr::filter(additional_level == c("1996-01-01 to 1996-12-31"), estimate_name == "count") |>
    dplyr::pull("estimate_value") |>
    as.numeric()
  y <- cdm$observation_period %>%
    dplyr::inner_join(cdm[["person"]] |> dplyr::select("person_id"), by = "person_id") %>%
    dplyr::mutate(start = !!CDMConnector::datepart("observation_period_start_date", "year")) %>%
    dplyr::mutate(end = !!CDMConnector::datepart("observation_period_end_date", "year")) %>%
    dplyr::filter((.data$start < 1996 & .data$end >= 1996) |
      (.data$start >= 1996 & .data$start <= 1996)) |>
    dplyr::distinct(.data$person_id) |>
    dplyr::tally() |>
    dplyr::pull("n") |>
    as.numeric()
  expect_equal(x, y)




  x <- summariseInObservation(cdm$observation_period, interval = "years") |>
    dplyr::filter(additional_level == c("1998-01-01 to 1998-12-31"), estimate_name == "count") |>
    dplyr::pull("estimate_value") |>
    as.numeric()
  y <- cdm$observation_period %>%
    dplyr::inner_join(cdm[["person"]] |> dplyr::select("person_id"), by = "person_id") %>%
    dplyr::mutate(start = !!CDMConnector::datepart("observation_period_start_date", "year")) %>%
    dplyr::mutate(end = !!CDMConnector::datepart("observation_period_end_date", "year")) %>%
    dplyr::filter((.data$start < 1998 & .data$end >= 1998) |
      (.data$start >= 1998 & .data$start <= 1998)) |>
    dplyr::tally() |>
    dplyr::pull("n") |>
    as.numeric()
  expect_equal(x, y)

  # Check inputs ----
  x <- summariseInObservation(cdm$observation_period, interval = "months") |>
    dplyr::filter(additional_level == "1942-03-01 to 1942-03-31", estimate_name == "count") |>
    dplyr::pull("estimate_value") |>
    as.numeric()
  y <- cdm$observation_period %>%
    dplyr::inner_join(cdm[["person"]] |> dplyr::select("person_id"), by = "person_id") %>%
    dplyr::filter(
      (observation_period_start_date < as.Date("1942-03-01") & observation_period_end_date >= as.Date("1942-03-01")) |
        (observation_period_start_date >= as.Date("1942-03-01") & observation_period_start_date <= as.Date("1942-03-31"))
    ) |>
    dplyr::tally() |>
    dplyr::pull("n") |>
    as.numeric()
  expect_equal(x, y)


  x <- summariseInObservation(cdm$observation_period, interval = "months") |>
    dplyr::filter(additional_level == "2015-09-01 to 2015-09-30", estimate_name == "count") |>
    dplyr::pull("estimate_value") |>
    as.numeric()
  y <- cdm$observation_period %>%
    dplyr::inner_join(cdm[["person"]] |> dplyr::select("person_id"), by = "person_id") %>%
    dplyr::filter(
      (observation_period_start_date < as.Date("2015-09-01") & observation_period_end_date >= as.Date("2015-09-01")) |
        (observation_period_start_date >= as.Date("2015-09-01") & observation_period_start_date <= as.Date("2015-09-30"))
    ) |>
    dplyr::tally() |>
    dplyr::pull("n") |>
    as.numeric()
  expect_equal(x, y)

  x <- summariseInObservation(cdm$observation_period, interval = "months") |>
    dplyr::filter(additional_level == "1982-03-01 to 1982-03-31", estimate_name == "count") |>
    dplyr::pull("estimate_value") |>
    as.numeric()
  y <- cdm$observation_period %>%
    dplyr::inner_join(cdm[["person"]] |> dplyr::select("person_id"), by = "person_id") %>%
    dplyr::filter(observation_period_start_date < as.Date("1982-03-01") & observation_period_end_date >= as.Date("1982-03-01") |
      (observation_period_start_date >= as.Date("1982-03-01") & observation_period_start_date <= as.Date("1982-03-31"))) |>
    dplyr::tally() |>
    dplyr::pull("n") |>
    as.numeric()
  expect_equal(x, y)
  PatientProfiles::mockDisconnect(cdm = cdm)
})

test_that("check sex argument works", {
  skip_on_cran()
  # Load mock database ----
  cdm <- cdmEunomia()

  # Check overall
  x <- summariseInObservation(cdm$observation_period, interval = "years", sex = TRUE)
  expect_equal(x |> dplyr::filter(additional_level != "overall") |> dplyr::pull("additional_name") |> unique(), "time_interval")
  x <- summariseInObservation(cdm$observation_period, interval = "overall")
  expect_equal(x |> dplyr::filter(additional_level == "overall") |> dplyr::pull("additional_name") |> unique(), "overall")

  x <- summariseInObservation(cdm$observation_period, interval = "years", sex = TRUE) |>
    dplyr::filter(strata_level %in% c("Male", "Female"), additional_level == "1908-01-01 to 1908-12-31", estimate_name == "count") |>
    dplyr::pull(estimate_value) |>
    as.numeric() |>
    sum()
  y <- summariseInObservation(cdm$observation_period, interval = "years", sex = TRUE) |>
    dplyr::filter(strata_level %in% c("overall"), additional_level == "1908-01-01 to 1908-12-31", estimate_name == "count") |>
    dplyr::pull(estimate_value) |>
    as.numeric()
  expect_equal(x, y)

  y <- cdm$observation_period |>
    dplyr::inner_join(cdm[["person"]] |> dplyr::select("person_id"), by = "person_id") %>%
    dplyr::filter(observation_period_start_date < as.Date("1908-01-01") & observation_period_end_date >= as.Date("1908-01-01") |
      (observation_period_start_date >= as.Date("1908-01-01") & observation_period_start_date <= as.Date("1908-12-31"))) |>
    dplyr::tally() |>
    dplyr::pull() |>
    as.numeric()
  expect_equal(x, y)

  # Check a random group
  x <- summariseInObservation(cdm$observation_period, interval = "years", sex = TRUE) |>
    dplyr::filter(strata_level == "Male", additional_level == "1915-01-01 to 1915-12-31", estimate_name == "count") |>
    dplyr::pull(estimate_value) |>
    as.numeric()
  y <- cdm$observation_period |>
    dplyr::inner_join(cdm[["person"]] |> dplyr::select("person_id"), by = "person_id") %>%
    PatientProfiles::addSexQuery() |>
    dplyr::filter(sex == "Male") |>
    dplyr::filter(observation_period_start_date < as.Date("1915-01-01") & observation_period_end_date >= as.Date("1915-01-01") |
      (observation_period_start_date >= as.Date("1915-01-01") & observation_period_start_date <= as.Date("1915-12-31"))) |>
    dplyr::tally() |>
    dplyr::pull() |>
    as.numeric()
  expect_equal(x, y)

  x <- summariseInObservation(cdm$observation_period, interval = "years", sex = TRUE) |>
    dplyr::filter(strata_level == "Male", additional_level == "1915-01-01 to 1915-12-31", estimate_name == "percentage") |>
    dplyr::pull(estimate_value)
  y <- (cdm$observation_period |>
    dplyr::inner_join(cdm[["person"]] |> dplyr::select("person_id"), by = "person_id") %>%
    PatientProfiles::addSexQuery() |>
    dplyr::filter(sex == "Male") |>
    dplyr::filter(observation_period_start_date < as.Date("1915-01-01") & observation_period_end_date >= as.Date("1915-01-01") |
      (observation_period_start_date >= as.Date("1915-01-01") & observation_period_start_date <= as.Date("1915-12-31"))) |>
    dplyr::tally() |>
    dplyr::pull()) / (cdm[["person"]] |> dplyr::tally() |> dplyr::pull() |> as.numeric()) * 100
  expect_equal(x, sprintf("%.2f", y))

  expect_no_error(x <- summariseInObservation(cdm$observation_period, output = "person", interval = "years", sex = TRUE))
  x <- x |>
    dplyr::filter(strata_level == "Male", additional_level == "1915-01-01 to 1915-12-31", estimate_name == "percentage") |>
    dplyr::pull(estimate_value)
  y <- cdm$observation_period |>
    dplyr::inner_join(cdm[["person"]] |> dplyr::select("person_id"), by = "person_id") %>%
    PatientProfiles::addSexQuery() |>
    dplyr::filter(sex == "Male") |>
    dplyr::filter(observation_period_start_date < as.Date("1915-01-01") & observation_period_end_date >= as.Date("1915-01-01") |
      (observation_period_start_date >= as.Date("1915-01-01") & observation_period_start_date <= as.Date("1915-12-31"))) |>
    dplyr::summarise(p = dplyr::n_distinct(.data$person_id)) |>
    dplyr::pull()
  y <- y / (cdm[["person"]] |> dplyr::tally() |> dplyr::pull()) * 100

  expect_equal(x, sprintf("%.2f", y))


  PatientProfiles::mockDisconnect(cdm = cdm)
})

test_that("check ageGroup argument works", {
  skip_on_cran()
  # Load mock database ----
  cdm <- cdmEunomia()

  expect_no_error(summariseInObservation(cdm$observation_period, ageGroup = list(c(0, 20), c(21, Inf))))

  x <- summariseInObservation(cdm$observation_period, interval = "years", ageGroup = list("<=20" = c(0, 20), ">20" = c(21, Inf))) |>
    dplyr::filter(additional_level == "1928-01-01 to 1928-12-31", estimate_name == "count", strata_level == "<=20") |>
    dplyr::pull(estimate_value) |>
    as.numeric()
  y <- cdm$observation_period |>
    dplyr::inner_join(cdm[["person"]] |> dplyr::select("person_id"), by = "person_id") %>%
    dplyr::filter(observation_period_start_date < as.Date("1928-01-01") & observation_period_end_date >= as.Date("1928-01-01") |
      (observation_period_start_date >= as.Date("1928-01-01") & observation_period_start_date <= as.Date("1928-12-31"))) |>
    dplyr::mutate("start" = as.Date("1928-01-01"), "end" = as.Date("1928-12-31")) |>
    PatientProfiles::addAgeQuery(indexDate = "start", ageName = "age_start") %>%
    dplyr::mutate(age_end = age_start + 10) |>
    dplyr::filter((age_end <= 20 & age_end >= 0) | (age_start >= 0 & age_start <= 20)) |>
    dplyr::tally() |>
    dplyr::pull() |>
    as.numeric()
  expect_equal(x, y)

  x <- summariseInObservation(cdm$observation_period, interval = "years", sex = TRUE) |>
    dplyr::filter(strata_level == "Male", additional_level == "1918-01-01 to 1918-12-31", estimate_name == "percentage") |>
    dplyr::pull(estimate_value)
  y <- (cdm$observation_period |>
    dplyr::inner_join(cdm[["person"]] |> dplyr::select("person_id"), by = "person_id") %>%
    PatientProfiles::addSexQuery() |>
    dplyr::filter(sex == "Male") |>
    dplyr::filter(observation_period_start_date < as.Date("1918-01-01") & observation_period_end_date >= as.Date("1918-01-01") |
      (observation_period_start_date >= as.Date("1918-01-01") & observation_period_start_date <= as.Date("1918-12-31"))) |>
    dplyr::tally() |>
    dplyr::pull()) / (cdm[["person"]] |> dplyr::tally() |> dplyr::pull() |> as.numeric()) * 100
  expect_equal(x, sprintf("%.2f", y))

  expect_no_error(x <- summariseInObservation(cdm$observation_period, output = "person", ageGroup = list(c(0, 20), c(21, Inf)), interval = "years"))

  x <- x |>
    dplyr::filter(additional_level == "1928-01-01 to 1928-12-31", estimate_name == "count", strata_level == "0 to 20") |>
    dplyr::pull(estimate_value) |>
    as.numeric()
  y <- cdm$observation_period |>
    dplyr::inner_join(cdm[["person"]] |> dplyr::select("person_id"), by = "person_id") %>%
    dplyr::filter(observation_period_start_date < as.Date("1928-01-01") & observation_period_end_date >= as.Date("1928-01-01") |
      (observation_period_start_date >= as.Date("1928-01-01") & observation_period_start_date <= as.Date("1928-12-31"))) |>
    dplyr::mutate("start" = as.Date("1928-01-01"), "end" = as.Date("1928-12-31")) |>
    PatientProfiles::addAgeQuery(indexDate = "start", ageName = "age_start") %>%
    dplyr::mutate(age_end = age_start + 10) |>
    dplyr::filter((age_end <= 20 & age_end >= 0) | (age_start >= 0 & age_start <= 20)) |>
    dplyr::summarise(dplyr::n_distinct(person_id)) |>
    dplyr::pull()
  expect_equal(x, y)

  PatientProfiles::mockDisconnect(cdm = cdm)
})

test_that("check output argument works", {
  skip_on_cran()
  # Load mock database ----
  cdm <- cdmEunomia()

  # check value

  x <- summariseInObservation(cdm$observation_period, interval = "years", output = c("record", "person-days"), ageGroup = NULL, sex = FALSE) |>
    dplyr::filter(variable_name == "Number person-days", additional_level == "1970-01-01 to 1970-12-31", estimate_type == "integer") |>
    dplyr::pull("estimate_value") |>
    as.numeric()
  y <- cdm$observation_period |>
    dplyr::inner_join(cdm[["person"]] |> dplyr::select("person_id"), by = "person_id") %>%
    dplyr::filter(observation_period_start_date < as.Date("1970-01-01") & observation_period_end_date >= as.Date("1970-01-01") |
      (observation_period_start_date >= as.Date("1970-01-01") & observation_period_start_date <= as.Date("1970-12-31"))) |>
    dplyr::mutate("start_date" = as.Date("1970-01-01"), "end_date" = as.Date("1970-12-31")) %>%
    dplyr::mutate(
      "start_date" = pmax(start_date, observation_period_start_date, na.rm = TRUE),
      "end_date" = pmin(end_date, observation_period_end_date, na.rm = TRUE)
    ) %>%
    dplyr::mutate(days = !!CDMConnector::datediff("start_date", "end_date", interval = "day") + 1) |>
    dplyr::summarise(n = sum(days, na.rm = TRUE)) |>
    dplyr::pull("n") |>
    as.numeric()
  expect_equal(x, y)

  # Check percentage
  den <- cdm$observation_period |>
    dplyr::inner_join(cdm[["person"]] |> dplyr::select("person_id"), by = "person_id") %>%
    dplyr::mutate(days = !!CDMConnector::datediff("observation_period_start_date", "observation_period_end_date", interval = "day") + 1) |>
    dplyr::summarise(n = sum(days, na.rm = TRUE)) |>
    dplyr::pull("n")
  x <- summariseInObservation(cdm$observation_period, interval = "years", output = c("record", "person-days"), ageGroup = NULL, sex = FALSE) |>
    dplyr::filter(variable_name == "Number person-days", additional_level == "1964-01-01 to 1964-12-31", estimate_type == "percentage") |>
    dplyr::pull("estimate_value")
  y <- cdm$observation_period |>
    dplyr::inner_join(cdm[["person"]] |> dplyr::select("person_id"), by = "person_id") %>%
    dplyr::filter(observation_period_start_date < as.Date("1964-01-01") & observation_period_end_date >= as.Date("1964-01-01") |
      (observation_period_start_date >= as.Date("1964-01-01") & observation_period_start_date <= as.Date("1964-12-31"))) |>
    dplyr::mutate("start_date" = as.Date("1964-01-01"), "end_date" = as.Date("1964-12-31")) %>%
    dplyr::mutate(
      "start_date" = pmax(start_date, observation_period_start_date, na.rm = TRUE),
      "end_date" = pmin(end_date, observation_period_end_date, na.rm = TRUE)
    ) %>%
    dplyr::mutate(days = !!CDMConnector::datediff("start_date", "end_date", interval = "day") + 1) |>
    dplyr::summarise(n = sum(days, na.rm = TRUE)) |>
    dplyr::pull("n") |>
    as.numeric() / den * 100
  expect_equal(x, sprintf("%.2f", y))

  # Check sex stratified
  x <- summariseInObservation(cdm$observation_period, interval = "years", output = "person-days", sex = TRUE) |>
    dplyr::filter(variable_name == "Number person-days", additional_level == "1964-01-01 to 1964-12-31", estimate_type == "integer") |>
    dplyr::filter(strata_level == "overall") |>
    dplyr::pull("estimate_value") |>
    as.numeric()
  y <- summariseInObservation(cdm$observation_period, interval = "years", output = "person-days", sex = TRUE) |>
    dplyr::filter(variable_name == "Number person-days", additional_level == "1964-01-01 to 1964-12-31", estimate_type == "integer") |>
    dplyr::filter(strata_level != "overall") |>
    dplyr::pull("estimate_value") |>
    as.numeric() |>
    sum()
  expect_equal(x, y)

  # Check age stratified
  x <- summariseInObservation(cdm$observation_period, interval = "years", output = "person-days", ageGroup = list("<=20" = c(0, 20), ">20" = c(21, Inf))) |>
    dplyr::filter(variable_name == "Number person-days", additional_level == "2000-01-01 to 2000-12-31", estimate_type == "integer") |>
    dplyr::filter(strata_level == "overall") |>
    dplyr::pull("estimate_value") |>
    as.numeric()
  y <- summariseInObservation(cdm$observation_period, interval = "years", output = "person-days", sex = TRUE) |>
    dplyr::filter(variable_name == "Number person-days", additional_level == "2000-01-01 to 2000-12-31", estimate_type == "integer") |>
    dplyr::filter(strata_level != "overall") |>
    dplyr::pull("estimate_value") |>
    as.numeric() |>
    sum()
  expect_equal(x, y)

  PatientProfiles::mockDisconnect(cdm = cdm)
})

test_that("dateRange argument works", {
  skip_on_cran()
  # Load mock database ----
  cdm <- cdmEunomia()

  expect_no_error(summariseInObservation(cdm$observation_period, dateRange = as.Date(c("1940-01-01", "2018-01-01"))))
  expect_message(x <- summariseInObservation(cdm$observation_period, dateRange = as.Date(c("1940-01-01", "2024-01-01"))))
  observationRange <- cdm$observation_period |>
    dplyr::summarise(
      minobs = min(.data$observation_period_start_date, na.rm = TRUE),
      maxobs = max(.data$observation_period_end_date, na.rm = TRUE)
    )
  expect_no_error(y <- summariseInObservation(cdm$observation_period, dateRange = as.Date(c("1940-01-01", observationRange |> dplyr::pull("maxobs")))))
  expect_equal(x, y, ignore_attr = TRUE)
  expect_false(settings(x)$study_period_end == settings(y)$study_period_end)
  expect_error(summariseInObservation(cdm$observation_period, dateRange = as.Date(c("2015-01-01", "2014-01-01"))))
  expect_warning(z <- summariseInObservation(cdm$observation_period, dateRange = as.Date(c("2020-01-01", "2021-01-01"))))
  expect_equal(z, omopgenerics::emptySummarisedResult(), ignore_attr = TRUE)
  expect_equal(summariseInObservation(cdm$observation_period, dateRange = as.Date(c("1940-01-01", NA))), y, ignore_attr = TRUE)
  checkResultType(z, "summarise_in_observation")
  expect_equal(colnames(settings(z)), colnames(settings(x)))
  PatientProfiles::mockDisconnect(cdm = cdm)
})

test_that("no tables created", {
  skip_on_cran()
  # Load mock database ----
  cdm <- cdmEunomia()

  startNames <- CDMConnector::listSourceTables(cdm)

  results <- summariseInObservation(cdm$observation_period,
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



  endNames <- CDMConnector::listSourceTables(cdm)

  expect_true(length(setdiff(endNames, startNames)) == 0)

  PatientProfiles::mockDisconnect(cdm = cdm)
})
test_that("age and sex output work", {
  skip_on_cran()
  # Load mock database ----
  cdm <- cdmEunomia()
  expect_no_error(x <- summariseInObservation(cdm$observation_period, output = "age"))
  expect_equal(cdm$observation_period |>
    PatientProfiles::addAgeQuery(indexDate = "observation_period_start_date") |>
    dplyr::pull("age") |>
    stats::median(), as.numeric(x$estimate_value))
  expect_no_error(y <- summariseInObservation(cdm$observation_period, output = "age", sex = TRUE, ageGroup = list(c(0, 50))))
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

  expect_no_error(y <- summariseInObservation(cdm$observation_period, output = "age", sex = TRUE, ageGroup = list(c(0, 50)), interval = "years"))
  y <- y |>
    omopgenerics::splitAll() |>
    dplyr::filter(.data$time_interval == "2019-01-01 to 2019-12-31" & .data$sex == "Female" & .data$age_group == "0 to 50") |>
    dplyr::pull("estimate_value") |>
    as.numeric()
  z <- cdm$observation_period |>
    dplyr::filter(observation_period_start_date < as.Date("2019-01-01") & observation_period_end_date >= as.Date("2019-01-01") |
      (observation_period_start_date >= as.Date("2019-01-01") & observation_period_start_date <= as.Date("2019-12-31"))) |>
    dplyr::mutate("start_date" = as.Date("2019-01-01")) |>
    dplyr::mutate(
      "index_date" = pmax(start_date, observation_period_start_date, na.rm = TRUE)
    ) |>
    PatientProfiles::addDemographicsQuery(indexDate = "index_date", age = TRUE, ageGroup = list(c(0, 50)), sex = TRUE, priorObservation = FALSE, futureObservation = TRUE) |>
    dplyr::filter(.data$sex == "Female" & .data$age_group == "0 to 50") |>
    dplyr::pull("age") |>
    stats::median()

  expect_equal(y, z)


  expect_no_error(x <- summariseInObservation(cdm$observation_period, output = "sex"))
  y <- cdm$observation_period |>
    PatientProfiles::addSexQuery() |>
    dplyr::mutate("n_tot" = dplyr::n_distinct("person_id")) |>
    dplyr::filter(.data$sex == "Female") |>
    dplyr::summarise("n_females" = dplyr::n_distinct("person_id"), n_tot = dplyr::first(.data$n_tot)) |>
    dplyr::collect()
  expect_equal(sprintf("%.2f", 100 * y$n_females / y$n_tot), x |> dplyr::filter(estimate_type == "percentage") |> dplyr::pull(estimate_value))
  expect_equal(x, summariseInObservation(cdm$observation_period, sex = TRUE, output = "sex"))

  expect_no_error(y <- summariseInObservation(cdm$observation_period, output = "sex", ageGroup = list(c(0, 50)), interval = "years"))
  y <- y |>
    omopgenerics::splitAll() |>
    dplyr::filter(.data$time_interval == "2019-01-01 to 2019-12-31" & .data$age_group == "0 to 50" & .data$estimate_type == "percentage") |>
    dplyr::pull("estimate_value")

  z <- cdm$observation_period |>
    dplyr::inner_join(
      cdm$person |>
        dplyr::filter(.data$gender_concept_id %in% c(8507, 8532)),
      by = "person_id"
    ) |>
    dplyr::mutate("n_tot" = dplyr::n_distinct("person_id")) |>
    dplyr::mutate("start_date" = as.Date("2019-01-01")) |>
    dplyr::filter(observation_period_start_date < as.Date("2019-01-01") & observation_period_end_date >= as.Date("2019-01-01") |
      (observation_period_start_date >= as.Date("2019-01-01") & observation_period_start_date <= as.Date("2019-12-31"))) |>
    dplyr::mutate(
      "index_date" = pmax(start_date, observation_period_start_date, na.rm = TRUE)
    ) |>
    PatientProfiles::addDemographicsQuery(indexDate = "index_date", age = TRUE, ageGroup = list(c(0, 50)), sex = TRUE, priorObservation = FALSE, futureObservation = TRUE) |>
    dplyr::filter(.data$age_group == "0 to 50" & .data$sex == "Female") |>
    dplyr::summarise("n_females" = dplyr::n_distinct("person_id"), n_tot = dplyr::first(.data$n_tot)) |>
    dplyr::collect()

  expect_equal(sprintf("%.2f", 100 * z$n_females / z$n_tot), y)

  PatientProfiles::mockDisconnect(cdm = cdm)
})

test_that("overall time interval work", {
  skip_on_cran()
  # Load mock database ----
  cdm <- cdmEunomia()

  expect_no_error(x <- summariseInObservation(cdm$observation_period, output = c("record", "person", "sex", "age"), interval = "years"))
  x <- x |>
    dplyr::filter(.data$additional_level == "overall" & estimate_type != "percentage")

  records <- cdm$observation_period |>
    dplyr::tally() |>
    dplyr::pull(.data$n)

  person <- cdm$observation_period %>%
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
    dplyr::summarise(median = stats::median(.data$age)) |>
    dplyr::pull(.data$median)

  expect_equal(x |> dplyr::filter(variable_name == "Number records in observation") |> dplyr::pull(.data$estimate_value), as.character(records))
  expect_equal(x |> dplyr::filter(variable_name == "Number subjects in observation") |> dplyr::pull(.data$estimate_value), as.character(person))
  expect_equal(x |> dplyr::filter(variable_name == "Number females in observation") |> dplyr::pull(.data$estimate_value), as.character(sex))
  expect_equal(x |> dplyr::filter(variable_name == "Median age in observation") |> dplyr::pull(.data$estimate_value), as.character(age))



  PatientProfiles::mockDisconnect(cdm = cdm)
})


test_that("tableInObservation works", {
  skip_on_cran()
  # Load mock database ----
  cdm <- cdmEunomia()
  expect_no_error(x <- tableInObservation(summariseInObservation(cdm$observation_period)))
  expect_true(inherits(x, "gt_tbl"))


  expect_no_error(tableInObservation(summariseInObservation(cdm$observation_period), type = "datatable"))
  expect_no_error(tableInObservation(summariseInObservation(cdm$observation_period), type = "reactable"))



  PatientProfiles::mockDisconnect(cdm = cdm)
})
