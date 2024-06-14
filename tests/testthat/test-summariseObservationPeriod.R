test_that("check summariseObservationPeriod works", {

  # Load mock database ----
  con <- DBI::dbConnect(duckdb::duckdb(), CDMConnector::eunomia_dir())
  cdm <- CDMConnector::cdmFromCon(
    con = con, cdmSchema = "main", writeSchema = "main"
  )

  # Check all tables work ----
  expect_true(inherits(summariseObservationPeriod(cdm$observation_period),"summarised_result"))
  expect_true(inherits(summariseObservationPeriod(cdm$observation_period, unit = "month", unitInterval = 10),"summarised_result"))
  expect_true(inherits(summariseObservationPeriod(cdm$observation_period, unit = "year", unitInterval = 10),"summarised_result"))

  expect_error(summariseObservationPeriod(cdm$death))

  # Check inputs ----
  x <- summariseObservationPeriod(cdm$observation_period, unit = "year", unitInterval = 1) |>
    dplyr::filter(strata_level == "1909-01-01 to 1909-12-31", estimate_name == "count") |>
    dplyr::pull("estimate_value") |>
    as.numeric()
  y <- cdm$observation_period %>%
    dplyr::mutate(start_year = !!CDMConnector::datepart("observation_period_start_date", "year")) %>%
    dplyr::mutate(end_year = !!CDMConnector::datepart("observation_period_end_date", "year")) %>%
    dplyr::filter(start_year <= 1909,  end_year >= 1909) |>
    dplyr::tally() |>
    dplyr::pull("n")
  expect_equal(x,y)

  x <- summariseObservationPeriod(cdm$observation_period, unit = "year", unitInterval = 2) |>
    dplyr::filter(strata_level == c("1936-01-01 to 1937-12-31"), estimate_name == "count") |>
    dplyr::pull("estimate_value") |>
    as.numeric()
  y <- cdm$observation_period %>%
    dplyr::mutate(start = !!CDMConnector::datepart("observation_period_start_date", "year")) %>%
    dplyr::mutate(end = !!CDMConnector::datepart("observation_period_end_date", "year")) %>%
    dplyr::filter((.data$start < 1936 & .data$end >= 1936) |
                    (.data$start >= 1936 & .data$start <= 1937))  |>
    dplyr::tally() |>
    dplyr::pull("n")
  expect_equal(x,y)

  x <- summariseObservationPeriod(cdm$observation_period, unit = "year", unitInterval = 10) |>
    dplyr::filter(strata_level == c("1998-01-01 to 2007-12-31"), estimate_name == "count") |>
    dplyr::pull("estimate_value") |>
    as.numeric()
  y <- cdm$observation_period %>%
    dplyr::mutate(start = !!CDMConnector::datepart("observation_period_start_date", "year")) %>%
    dplyr::mutate(end = !!CDMConnector::datepart("observation_period_end_date", "year")) %>%
    dplyr::filter((.data$start < 1998 & .data$end >= 1998) |
                    (.data$start >= 1998 & .data$start <= 2007))  |>
    dplyr::tally() |>
    dplyr::pull("n")
  expect_equal(x,y)

  # Check inputs ----
  x <- summariseObservationPeriod(cdm$observation_period, unit = "month", unitInterval = 1) |>
    dplyr::filter(strata_level == "1942-03-01 to 1942-03-31", estimate_name == "count") |>
    dplyr::pull("estimate_value") |>
    as.numeric()
  y <- cdm$observation_period %>%
    dplyr::filter(
      (observation_period_start_date < as.Date("1942-03-01") & observation_period_end_date >= as.Date("1942-03-01")) |
        (observation_period_start_date >= as.Date("1942-03-01") & observation_period_start_date <= as.Date("1942-03-31"))
    ) |> dplyr::tally() |> dplyr::pull("n")
  expect_equal(x,y)


  x <- summariseObservationPeriod(cdm$observation_period, unit = "month", unitInterval = 2) |>
    dplyr::filter(strata_level == "2015-09-01 to 2015-10-31", estimate_name == "count") |>
    dplyr::pull("estimate_value") |>
    as.numeric()
  y <- cdm$observation_period %>%
    dplyr::filter(
      (observation_period_start_date < as.Date("2015-09-01") & observation_period_end_date >= as.Date("2015-09-01")) |
        (observation_period_start_date >= as.Date("2015-09-01") & observation_period_start_date <= as.Date("2015-10-31"))
    ) |> dplyr::tally() |> dplyr::pull("n")
  expect_equal(x,y)

  x <- summariseObservationPeriod(cdm$observation_period, unit = "month", unitInterval = 10) |>
    dplyr::filter(strata_level == "1982-03-01 to 1982-12-31", estimate_name == "count") |>
    dplyr::pull("estimate_value") |>
    as.numeric()

  y <- cdm$observation_period %>%
    dplyr::filter(observation_period_start_date < as.Date("1982-03-01") & observation_period_end_date >= as.Date("1982-03-01") |
                    (observation_period_start_date >= as.Date("1982-03-01") & observation_period_start_date <= as.Date("1982-12-31"))) |>
    dplyr::tally() |>
    dplyr::pull("n")
  expect_equal(x,y)

})
