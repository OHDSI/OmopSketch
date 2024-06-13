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
    dplyr::filter(strata_level == 1909, estimate_name == "count") |>
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
    dplyr::filter(strata_level == c("1936 to 1937"), estimate_name == "count") |>
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
    dplyr::filter(strata_level == c("1998 to 2007"), estimate_name == "count") |>
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
    dplyr::filter(strata_level == "1942-03", estimate_name == "count") |>
    dplyr::pull("estimate_value") |>
    as.numeric()

  y <- cdm$observation_period %>%
    dplyr::mutate(start_year = !!CDMConnector::datepart("observation_period_start_date", "year")) %>%
    dplyr::mutate(start_month = !!CDMConnector::datepart("observation_period_start_date", "month")) %>%
    dplyr::mutate(end_year = !!CDMConnector::datepart("observation_period_end_date", "year")) %>%
    dplyr::mutate(end_month = !!CDMConnector::datepart("observation_period_end_date", "month")) %>%
    dplyr::filter((start_year < 1942 & start_month < 3 & end_year >= 1942 & end_month >= 3) |
                    (start_year >= 1942 & start_month >= 3 & start_year <= 1942 & start_month <= 3)) |>
    dplyr::tally() |>
    dplyr::pull("n")
  expect_equal(x,y)


  x <- summariseObservationPeriod(cdm$observation_period, unit = "month", unitInterval = 2) |>
    dplyr::filter(strata_level == "2015-09 to 2015-10", estimate_name == "count") |>
    dplyr::pull("estimate_value") |>
    as.numeric()
  y <- cdm$observation_period %>%
    dplyr::mutate(start_year = !!CDMConnector::datepart("observation_period_start_date", "year")) %>%
    dplyr::mutate(start_month = !!CDMConnector::datepart("observation_period_start_date", "month")) %>%
    dplyr::mutate(end_year = !!CDMConnector::datepart("observation_period_end_date", "year")) %>%
    dplyr::mutate(end_month = !!CDMConnector::datepart("observation_period_end_date", "month")) %>%
    dplyr::filter((start_year < 2015 & start_month < 9 & end_year >= 2015 & end_month >= 9) |
                    (start_year >= 2015 & start_month >= 9 & start_year <= 2015 & start_month <= 10)) |>
    dplyr::tally() |>
    dplyr::pull("n")
  expect_equal(x,y)

  x <- summariseObservationPeriod(cdm$observation_period, unit = "month", unitInterval = 10) |>
    dplyr::filter(strata_level == "1982-03 to 1982-12", estimate_name == "count") |>
    dplyr::pull("estimate_value") |>
    as.numeric()
  y <- cdm$observation_period %>%
    dplyr::mutate(start_year = !!CDMConnector::datepart("observation_period_start_date", "year")) %>%
    dplyr::mutate(start_month = !!CDMConnector::datepart("observation_period_start_date", "month")) %>%
    dplyr::mutate(end_year = !!CDMConnector::datepart("observation_period_end_date", "year")) %>%
    dplyr::mutate(end_month = !!CDMConnector::datepart("observation_period_end_date", "month")) %>%
    dplyr::filter((start_year < 1982 & start_month < 3 & end_year >= 1982 & end_month >= 3) |
                    (start_year >= 1982 & start_month >= 3 & start_year <= 1982 & start_month <= 12)) |>
    dplyr::tally() |>
    dplyr::pull("n")
  expect_equal(x,y)

})
