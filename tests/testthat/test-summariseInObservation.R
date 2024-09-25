test_that("check summariseInObservation works", {
  skip_on_cran()
  # Load mock database ----
  cdm <- cdmEunomia()

  # Check all tables work ----
  expect_true(inherits(summariseInObservation(cdm$observation_period),"summarised_result"))
  expect_true(inherits(summariseInObservation(cdm$observation_period, unit = "month", unitInterval = 10),"summarised_result"))
  expect_true(inherits(summariseInObservation(cdm$observation_period, unit = "year", unitInterval = 10),"summarised_result"))

  expect_error(summariseInObservation(cdm$death))

  # Check inputs ----
  x <- summariseInObservation(cdm$observation_period, unit = "year", unitInterval = 1) |>
    dplyr::filter(variable_level == "1909-01-01 to 1909-12-31", estimate_name == "count") |>
    dplyr::pull("estimate_value") |>
    as.numeric()
  y <- cdm$observation_period %>%
    dplyr::inner_join(cdm[["person"]] |> dplyr::select("person_id"), by = "person_id") %>%
    dplyr::mutate(start_year = !!CDMConnector::datepart("observation_period_start_date", "year")) %>%
    dplyr::mutate(end_year = !!CDMConnector::datepart("observation_period_end_date", "year")) %>%
    dplyr::filter(start_year <= 1909,  end_year >= 1909) |>
    dplyr::tally() |>
    dplyr::pull("n") |> as.numeric()
  expect_equal(x,y)

  x <- summariseInObservation(cdm$observation_period, unit = "year", unitInterval = 2) |>
    dplyr::filter(variable_level == c("1936-01-01 to 1937-12-31"), estimate_name == "count") |>
    dplyr::pull("estimate_value") |>
    as.numeric()
  y <- cdm$observation_period %>%
    dplyr::inner_join(cdm[["person"]] |> dplyr::select("person_id"), by = "person_id") %>%
    dplyr::mutate(start = !!CDMConnector::datepart("observation_period_start_date", "year")) %>%
    dplyr::mutate(end = !!CDMConnector::datepart("observation_period_end_date", "year")) %>%
    dplyr::filter((.data$start < 1936 & .data$end >= 1936) |
                    (.data$start >= 1936 & .data$start <= 1937))  |>
    dplyr::tally() |>
    dplyr::pull("n") |> as.numeric()
  expect_equal(x,y)

  x <- summariseInObservation(cdm$observation_period, unit = "year", unitInterval = 10) |>
    dplyr::filter(variable_level == c("1998-01-01 to 2007-12-31"), estimate_name == "count") |>
    dplyr::pull("estimate_value") |>
    as.numeric()
  y <- cdm$observation_period %>%
    dplyr::inner_join(cdm[["person"]] |> dplyr::select("person_id"), by = "person_id") %>%
    dplyr::mutate(start = !!CDMConnector::datepart("observation_period_start_date", "year")) %>%
    dplyr::mutate(end = !!CDMConnector::datepart("observation_period_end_date", "year")) %>%
    dplyr::filter((.data$start < 1998 & .data$end >= 1998) |
                    (.data$start >= 1998 & .data$start <= 2007))  |>
    dplyr::tally() |>
    dplyr::pull("n") |> as.numeric()
  expect_equal(x,y)

  # Check inputs ----
  x <- summariseInObservation(cdm$observation_period, unit = "month", unitInterval = 1) |>
    dplyr::filter(variable_level == "1942-03-01 to 1942-03-31", estimate_name == "count") |>
    dplyr::pull("estimate_value") |>
    as.numeric()
  y <- cdm$observation_period %>%
    dplyr::inner_join(cdm[["person"]] |> dplyr::select("person_id"), by = "person_id") %>%
    dplyr::filter(
      (observation_period_start_date < as.Date("1942-03-01") & observation_period_end_date >= as.Date("1942-03-01")) |
        (observation_period_start_date >= as.Date("1942-03-01") & observation_period_start_date <= as.Date("1942-03-31"))
    ) |> dplyr::tally() |> dplyr::pull("n") |> as.numeric()
  expect_equal(x,y)


  x <- summariseInObservation(cdm$observation_period, unit = "month", unitInterval = 2) |>
    dplyr::filter(variable_level == "2015-09-01 to 2015-10-31", estimate_name == "count") |>
    dplyr::pull("estimate_value") |>
    as.numeric()
  y <- cdm$observation_period %>%
    dplyr::inner_join(cdm[["person"]] |> dplyr::select("person_id"), by = "person_id") %>%
    dplyr::filter(
      (observation_period_start_date < as.Date("2015-09-01") & observation_period_end_date >= as.Date("2015-09-01")) |
        (observation_period_start_date >= as.Date("2015-09-01") & observation_period_start_date <= as.Date("2015-10-31"))
    ) |> dplyr::tally() |> dplyr::pull("n") |> as.numeric()
  expect_equal(x,y)

  x <- summariseInObservation(cdm$observation_period, unit = "month", unitInterval = 10) |>
    dplyr::filter(variable_level == "1982-03-01 to 1982-12-31", estimate_name == "count") |>
    dplyr::pull("estimate_value") |>
    as.numeric()
  y <- cdm$observation_period %>%
    dplyr::inner_join(cdm[["person"]] |> dplyr::select("person_id"), by = "person_id") %>%
    dplyr::filter(observation_period_start_date < as.Date("1982-03-01") & observation_period_end_date >= as.Date("1982-03-01") |
                    (observation_period_start_date >= as.Date("1982-03-01") & observation_period_start_date <= as.Date("1982-12-31"))) |>
    dplyr::tally() |>
    dplyr::pull("n") |> as.numeric()
  expect_equal(x,y)
  PatientProfiles::mockDisconnect(cdm = cdm)
})

test_that("check sex argument works", {
  skip_on_cran()
  # Load mock database ----
  cdm <- cdmEunomia()

  # Check overall
  x <- summariseInObservation(cdm$observation_period, unit = "year", unitInterval = 8, sex = TRUE) |>
    dplyr::filter(strata_level %in% c("Male","Female"), variable_level == "1908-01-01 to 1915-12-31", estimate_name == "count") |>
    dplyr::pull(estimate_value) |> as.numeric() |> sum()
  y <- summariseInObservation(cdm$observation_period, unit = "year", unitInterval = 8, sex = TRUE) |>
    dplyr::filter(strata_level %in% c("overall"), variable_level == "1908-01-01 to 1915-12-31", estimate_name == "count") |>
    dplyr::pull(estimate_value) |> as.numeric()
  expect_equal(x,y)

  y <- cdm$observation_period |>
    dplyr::inner_join(cdm[["person"]] |> dplyr::select("person_id"), by = "person_id") %>%
    dplyr::filter(observation_period_start_date < as.Date("1908-01-01") & observation_period_end_date >= as.Date("1908-01-01") |
                    (observation_period_start_date >= as.Date("1908-01-01") & observation_period_start_date <= as.Date("1915-12-31"))) |>
    dplyr::tally() |>
    dplyr::pull() |> as.numeric()
  expect_equal(x,y)

  # Check a random group
  x <- summariseInObservation(cdm$observation_period, unit = "year", unitInterval = 8, sex = TRUE) |>
    dplyr::filter(strata_level == "Male", variable_level == "1908-01-01 to 1915-12-31", estimate_name == "count") |>
    dplyr::pull(estimate_value) |> as.numeric()
  y <- cdm$observation_period |>
    dplyr::inner_join(cdm[["person"]] |> dplyr::select("person_id"), by = "person_id") %>%
    PatientProfiles::addSexQuery() |>
    dplyr::filter(sex == "Male") |>
    dplyr::filter(observation_period_start_date < as.Date("1908-01-01") & observation_period_end_date >= as.Date("1908-01-01") |
                    (observation_period_start_date >= as.Date("1908-01-01") & observation_period_start_date <= as.Date("1915-12-31"))) |>
    dplyr::tally() |>
    dplyr::pull() |> as.numeric()
  expect_equal(x,y)

  x <- summariseInObservation(cdm$observation_period, unit = "year", unitInterval = 8, sex = TRUE) |>
    dplyr::filter(strata_level == "Male", variable_level == "1908-01-01 to 1915-12-31", estimate_name == "percentage") |>
    dplyr::pull(estimate_value) |> as.numeric()
  y <- (cdm$observation_period |>
          dplyr::inner_join(cdm[["person"]] |> dplyr::select("person_id"), by = "person_id") %>%
          PatientProfiles::addSexQuery() |>
          dplyr::filter(sex == "Male") |>
          dplyr::filter(observation_period_start_date < as.Date("1908-01-01") & observation_period_end_date >= as.Date("1908-01-01") |
                          (observation_period_start_date >= as.Date("1908-01-01") & observation_period_start_date <= as.Date("1915-12-31"))) |>
          dplyr::tally() |>
          dplyr::pull())/(cdm[["person"]] |> dplyr::tally() |> dplyr::pull() |> as.numeric())*100
  expect_equal(x,y)
  PatientProfiles::mockDisconnect(cdm = cdm)

})

test_that("check ageGroup argument works", {
  skip_on_cran()
  # Load mock database ----
  cdm <- cdmEunomia()

  x <- summariseInObservation(cdm$observation_period, unit = "year", unitInterval = 10, ageGroup = list("<=20" = c(0,20), ">20" = c(21,Inf))) |>
    dplyr::filter(variable_level == "1928-01-01 to 1937-12-31", estimate_name == "count", strata_level == "<=20") |>
    dplyr::pull(estimate_value) |> as.numeric()
  y <- cdm$observation_period |>
    dplyr::inner_join(cdm[["person"]] |> dplyr::select("person_id"), by = "person_id") %>%
    dplyr::filter(observation_period_start_date < as.Date("1928-01-01") & observation_period_end_date >= as.Date("1928-01-01") |
                    (observation_period_start_date >= as.Date("1928-01-01") & observation_period_start_date <= as.Date("1937-12-31"))) |>
    dplyr::mutate("start" = as.Date("1928-01-01"), "end" = as.Date("1937-12-31")) |>
    PatientProfiles::addAgeQuery(indexDate = "start", ageName = "age_start") %>%
    dplyr::mutate(age_end = age_start+10) |>
    dplyr::filter((age_end <= 20 & age_end >= 0) | (age_start >= 0 & age_start <= 20)) |>
    dplyr::tally() |>
    dplyr::pull() |> as.numeric()
  expect_equal(x,y)

  x <- summariseInObservation(cdm$observation_period, unit = "year", unitInterval = 8, sex = TRUE) |>
    dplyr::filter(strata_level == "Male", variable_level == "1908-01-01 to 1915-12-31", estimate_name == "percentage") |>
    dplyr::pull(estimate_value) |> as.numeric()
  y <- (cdm$observation_period |>
          dplyr::inner_join(cdm[["person"]] |> dplyr::select("person_id"), by = "person_id") %>%
          PatientProfiles::addSexQuery() |>
          dplyr::filter(sex == "Male") |>
          dplyr::filter(observation_period_start_date < as.Date("1908-01-01") & observation_period_end_date >= as.Date("1908-01-01") |
                          (observation_period_start_date >= as.Date("1908-01-01") & observation_period_start_date <= as.Date("1915-12-31"))) |>
          dplyr::tally() |>
          dplyr::pull())/(cdm[["person"]] |> dplyr::tally() |> dplyr::pull() |> as.numeric())*100
  expect_equal(x,y)

  PatientProfiles::mockDisconnect(cdm = cdm)
})

test_that("check output argument works", {
  skip_on_cran()
  # Load mock database ----
  cdm <- cdmEunomia()

  # check value
  x <- summariseInObservation(cdm$observation_period, unit = "year", unitInterval = 7, output = c("records","person-days"), ageGroup = NULL, sex = FALSE) |>
    dplyr::filter(variable_name == "Number person-days", variable_level == "1964-01-01 to 1970-12-31", estimate_type == "integer") |>
    dplyr::pull("estimate_value") |> as.numeric()
  y <- cdm$observation_period |>
    dplyr::inner_join(cdm[["person"]] |> dplyr::select("person_id"), by = "person_id") %>%
    dplyr::filter(observation_period_start_date < as.Date("1964-01-01") & observation_period_end_date >= as.Date("1964-01-01") |
                    (observation_period_start_date >= as.Date("1964-01-01") & observation_period_start_date <= as.Date("1970-12-31"))) |>
    dplyr::mutate("start_date" = as.Date("1964-01-01"), "end_date" = as.Date("1970-12-31")) %>%
    dplyr::mutate("start_date" = pmax(start_date, observation_period_start_date, na.rm = TRUE),
                  "end_date"   = pmin(end_date, observation_period_end_date, na.rm = TRUE)) %>%
    dplyr::mutate(days = !!CDMConnector::datediff("start_date","end_date", interval = "day")+1) |>
    dplyr::summarise(n = sum(days, na.rm = TRUE)) |> dplyr::pull("n") |> as.numeric()
  expect_equal(x,y)

  # Check percentage
  den <- cdm$observation_period |>
    dplyr::inner_join(cdm[["person"]] |> dplyr::select("person_id"), by = "person_id") %>%
    dplyr::mutate(days = !!CDMConnector::datediff("observation_period_start_date","observation_period_end_date", interval = "day")+1) |>
    dplyr::summarise(n = sum(days, na.rm = TRUE)) |> dplyr::pull("n")
  x <- summariseInObservation(cdm$observation_period, unit = "year", unitInterval = 7, output = c("records","person-days"), ageGroup = NULL, sex = FALSE) |>
    dplyr::filter(variable_name == "Number person-days", variable_level == "1964-01-01 to 1970-12-31", estimate_type == "percentage") |>
    dplyr::pull("estimate_value") |> as.numeric()
  y <- cdm$observation_period |>
    dplyr::inner_join(cdm[["person"]] |> dplyr::select("person_id"), by = "person_id") %>%
    dplyr::filter(observation_period_start_date < as.Date("1964-01-01") & observation_period_end_date >= as.Date("1964-01-01") |
                    (observation_period_start_date >= as.Date("1964-01-01") & observation_period_start_date <= as.Date("1970-12-31"))) |>
    dplyr::mutate("start_date" = as.Date("1964-01-01"), "end_date" = as.Date("1970-12-31")) %>%
    dplyr::mutate("start_date" = pmax(start_date, observation_period_start_date, na.rm = TRUE),
                  "end_date"   = pmin(end_date, observation_period_end_date, na.rm = TRUE)) %>%
    dplyr::mutate(days = !!CDMConnector::datediff("start_date","end_date", interval = "day")+1) |>
    dplyr::summarise(n = sum(days, na.rm = TRUE)) |> dplyr::pull("n") |> as.numeric()/den*100
  expect_equal(x,y)

  # Check sex stratified
  x <- summariseInObservation(cdm$observation_period, unit = "year", unitInterval = 7, output = "person-days", sex = TRUE) |>
    dplyr::filter(variable_name == "Number person-days", variable_level == "1964-01-01 to 1970-12-31", estimate_type == "integer") |>
    dplyr::filter(strata_level == "overall") |> dplyr::pull("estimate_value") |> as.numeric()
  y <- summariseInObservation(cdm$observation_period, unit = "year", unitInterval = 7, output = "person-days", sex = TRUE) |>
    dplyr::filter(variable_name == "Number person-days", variable_level == "1964-01-01 to 1970-12-31", estimate_type == "integer") |>
    dplyr::filter(strata_level != "overall") |> dplyr::pull("estimate_value") |> as.numeric() |> sum()
  expect_equal(x,y)

  # Check age stratified
  x <- summariseInObservation(cdm$observation_period, unit = "year", unitInterval = 7, output = "person-days", ageGroup = list("<=20" = c(0,20), ">20" = c(21,Inf))) |>
    dplyr::filter(variable_name == "Number person-days", variable_level == "1964-01-01 to 1970-12-31", estimate_type == "integer") |>
    dplyr::filter(strata_level == "overall") |> dplyr::pull("estimate_value") |> as.numeric()
  y <- summariseInObservation(cdm$observation_period, unit = "year", unitInterval = 7, output = "person-days", sex = TRUE) |>
    dplyr::filter(variable_name == "Number person-days", variable_level == "1964-01-01 to 1970-12-31", estimate_type == "integer") |>
    dplyr::filter(strata_level != "overall") |> dplyr::pull("estimate_value") |> as.numeric() |> sum()
  expect_equal(x,y)

  PatientProfiles::mockDisconnect(cdm = cdm)
})

