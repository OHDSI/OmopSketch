test_that("summariseConceptIdCount works", {
  skip_on_cran()

  cdm <- cdmEunomia()

  expect_true(inherits(summariseConceptIdCounts(cdm, "drug_exposure"), "summarised_result"))
  expect_warning(summariseConceptIdCounts(cdm, "observation_period"))
  expect_no_error(x <- summariseConceptIdCounts(cdm, "visit_occurrence"))
  checkResultType(x, "summarise_concept_id_counts")
  expect_no_error(summariseConceptIdCounts(cdm, "condition_occurrence", countBy = c("record", "person")))
  expect_no_error(summariseConceptIdCounts(cdm, "drug_exposure"))
  expect_no_error(summariseConceptIdCounts(cdm, "procedure_occurrence", countBy = "person"))
  expect_warning(summariseConceptIdCounts(cdm, "device_exposure"))
  expect_no_error(y <- summariseConceptIdCounts(cdm, "measurement"))
  expect_no_error(summariseConceptIdCounts(cdm, "observation", interval = "quarters"))
  expect_warning(p<-summariseConceptIdCounts(cdm, "death"))

  expect_no_error(all <- summariseConceptIdCounts(cdm, c("visit_occurrence", "measurement")))
  expect_equal(all |> sortTibble(), x |> dplyr::bind_rows(y) |> sortTibble())
  expect_equal(
    summariseConceptIdCounts(cdm, "procedure_occurrence", countBy = "record") |>
      sortTibble(),
    summariseConceptIdCounts(cdm, "procedure_occurrence") |>
      sortTibble()
  )

  expect_equal(summariseConceptIdCounts(cdm, "procedure_occurrence", countBy = "record", interval = "overall") |>
    sortTibble(),
    summariseConceptIdCounts(cdm, "procedure_occurrence", countBy = "record", interval = "months") |>
      dplyr::filter(additional_name == "overall") |>
      sortTibble(), ignore_attr = TRUE)



  expect_warning(summariseConceptIdCounts(cdm, "observation_period"))
  expect_error(summariseConceptIdCounts(cdm, omopTableName = ""))
  expect_error(summariseConceptIdCounts(cdm, omopTableName = "visit_occurrence", countBy = "dd"))
  expect_equal(settings(y)$result_type, settings(p)$result_type)
  expect_true(summariseConceptIdCounts(cdm, "procedure_occurrence", sex = TRUE, ageGroup = list(c(0, 50), c(51, Inf))) |>
                dplyr::distinct(.data$strata_level) |>
                dplyr::tally() |>
                dplyr::pull() == 9)

  expect_true(summariseConceptIdCounts(cdm, "procedure_occurrence", ageGroup = list(c(0, 50))) |>
                dplyr::distinct(.data$strata_level) |>
                dplyr::tally() |>
                dplyr::pull() == 3)

  s <- summariseConceptIdCounts(cdm, "procedure_occurrence") |>
    sortTibble()
  z <- summariseConceptIdCounts(cdm, "procedure_occurrence", sex = TRUE, interval = "years", ageGroup = list(c(0, 50), c(51, Inf))) |>
    sortTibble()

  x <- z |>
    dplyr::filter(strata_level == "overall" & additional_name == "overall") |>
    dplyr::select(variable_level, estimate_value)
  s <- s |>
    dplyr::select(variable_level, estimate_value)
  expect_equal(x, s, ignore_attr = TRUE)

  x <- z |>
    dplyr::filter(strata_name == "age_group" & additional_name == "overall") |>
    dplyr::group_by(variable_level) |>
    dplyr::summarise(estimate_value = sum(as.numeric(estimate_value), na.rm = TRUE), .groups = "drop") |>
    dplyr::mutate(estimate_value = as.character(estimate_value))

  p <- s |>
    dplyr::select(variable_level, estimate_value)

  expect_true(all.equal(
    as.data.frame(x) |> dplyr::arrange(variable_level),
    as.data.frame(p) |> dplyr::arrange(variable_level),
    check.attributes = FALSE
  ))

})

test_that("dateRange argument works", {
  skip_on_cran()
  # Load mock database ----
  cdm <- cdmEunomia()
  expect_no_error(summariseConceptIdCounts(cdm, "condition_occurrence", dateRange =  as.Date(c("2012-01-01", "2018-01-01"))))
  expect_message(x<-summariseConceptIdCounts(cdm, "drug_exposure", dateRange =  as.Date(c("2012-01-01", "2025-01-01"))))
  observationRange <- cdm$observation_period |>
    dplyr::summarise(minobs = min(.data$observation_period_start_date, na.rm = TRUE),
                     maxobs = max(.data$observation_period_end_date, na.rm = TRUE))
  expect_no_error(y<- summariseConceptIdCounts(cdm, "drug_exposure", dateRange = as.Date(c("2012-01-01", observationRange |>dplyr::pull("maxobs")))))
  expect_equal(x |> sortTibble(), y |> sortTibble(), ignore_attr = TRUE)
  expect_false(settings(x)$study_period_end==settings(y)$study_period_end)
  expect_error(summariseConceptIdCounts(cdm, "drug_exposure", dateRange =  as.Date(c("2015-01-01", "2014-01-01"))))
  expect_warning(y<-summariseConceptIdCounts(cdm, "drug_exposure", dateRange =  as.Date(c("2020-01-01", "2021-01-01"))))
  expect_equal(y, omopgenerics::emptySummarisedResult(), ignore_attr = TRUE)
  expect_equal(settings(y)$result_type, settings(x)$result_type)
  expect_equal(colnames(settings(y)), colnames(settings(x)))
  PatientProfiles::mockDisconnect(cdm = cdm)
})
test_that("sample argument works", {
  skip_on_cran()
  # Load mock database ----
  cdm <- cdmEunomia()

  expect_no_error(x<-summariseConceptIdCounts(cdm,"drug_exposure", sample = 50))
  expect_no_error(y<-summariseConceptIdCounts(cdm,"drug_exposure"))
  n <- cdm$drug_exposure |>
    dplyr::tally()|>
    dplyr::pull(n)
  expect_no_error(z<-summariseConceptIdCounts(cdm,"drug_exposure",sample = n))
  expect_equal(y |> sortTibble(), z |> sortTibble())
  expect_equal(summariseConceptIdCounts(cdm,"drug_exposure", sample = 1) |>
                 dplyr::filter(.data$estimate_name == "count_records") |>
                 dplyr::pull(.data$estimate_value) |>
                 as.integer(), 1L)

  PatientProfiles::mockDisconnect(cdm = cdm)
})

test_that("tableConceptIdCounts() works", {
  skip_on_cran()
  # Load mock database ----
  cdm <- cdmEunomia()

  # Check that works ----
  expect_no_error(x <- tableConceptIdCounts(summariseConceptIdCounts(cdm, "condition_occurrence")))
  expect_true(inherits(x,"gt_tbl"))
  expect_no_error(y <- tableConceptIdCounts(summariseConceptIdCounts(cdm, c("drug_exposure",
                                                                    "measurement"))))
  expect_true(inherits(y,"gt_tbl"))
  expect_warning(t <- summariseConceptIdCounts(cdm, "death"))
  expect_warning(inherits(tableConceptIdCounts(t),"gt_tbl"))

  PatientProfiles::mockDisconnect(cdm = cdm)
})

test_that("interval argument works", {
  skip_on_cran()
  # Load mock database ----
  cdm <- cdmEunomia()
  expect_no_error(y<-summariseConceptIdCounts(cdm = cdm,
                                               omopTableName = "drug_exposure",
                                               interval = "years"))

  expect_no_error(o<-summariseConceptIdCounts(omopTableName = "drug_exposure",
                                               cdm = cdm,
                                               interval = "overall"))
  expect_no_error(q<-summariseConceptIdCounts(omopTableName = "drug_exposure",
                                               cdm = cdm,
                                               interval = "quarters"))
  expect_no_error(m<-summariseConceptIdCounts(omopTableName = "drug_exposure",
                                               cdm = cdm,
                                               interval = "months"))



  m_quarters <- m|>omopgenerics::splitAdditional()|>
    omopgenerics::pivotEstimates() |>
    dplyr::filter(time_interval != "overall") |>
    dplyr::mutate(
      start_date = as.Date(sub(" to .*", "", time_interval)),
      quarter_start = lubridate::quarter(start_date, type = "date_first"),
      quarter_end = lubridate::quarter(start_date, type = "date_last"),
      quarter = paste(quarter_start, "to", quarter_end)
    ) |>
    dplyr::select(!c("time_interval", "start_date", "quarter_start", "quarter_end")) |>
    dplyr::group_by(quarter, variable_level)|>
    dplyr::summarise(count_records = sum(count_records), .groups = "drop") |>
    dplyr::rename("time_interval" = quarter) |>
    dplyr::arrange(time_interval)

  q_quarters <- q|>omopgenerics::splitAdditional()|>
    omopgenerics::pivotEstimates()|>
    dplyr::filter(time_interval != "overall")|>
    dplyr::select(time_interval, variable_level, count_records)|>
    dplyr::arrange(time_interval)

  expect_equal(m_quarters |>
                 sortTibble(), q_quarters |> sortTibble())

  m_year <- m|>
    omopgenerics::splitAdditional()|>
    dplyr::filter(time_interval != "overall")|>
    dplyr::mutate(
      # Extract the start date
      start_date = clock::date_parse(stringr::str_extract(time_interval, "^\\d{4}-\\d{2}-\\d{2}")),
      # Convert start_date to a year-month-day object and extract the year
      year = clock::get_year(clock::as_year_month_day(start_date))
    )|>
    omopgenerics::pivotEstimates()|>
    dplyr::group_by(year, variable_level) |>
    dplyr::summarise(
      count_records = sum(count_records),
      .groups = "drop"
    )|>
    dplyr::arrange(year)
  y_year <- y|>
    omopgenerics::splitAdditional()|>
    dplyr::filter(time_interval != "overall")|>
    dplyr::mutate(
      # Extract the start date
      start_date = clock::date_parse(stringr::str_extract(time_interval, "^\\d{4}-\\d{2}-\\d{2}")),
      # Convert start_date to a year-month-day object and extract the year
      year = clock::get_year(clock::as_year_month_day(start_date))
    )|>
    omopgenerics::pivotEstimates()|>
    dplyr::select(year, variable_level, count_records)|>
    dplyr::arrange(year)

  expect_equal(m_year |> sortTibble(), y_year |> sortTibble())

  o <- o |> omopgenerics::splitAdditional() |>
    omopgenerics::pivotEstimates() |>
    dplyr::select(variable_level, count_records)

  expect_equal(y_year|> dplyr::group_by(variable_level) |> dplyr::summarise(count_records = sum(count_records), .groups = "drop") |> sortTibble(), o |> sortTibble())


  q_year <- q|>
    omopgenerics::splitAdditional()|>
    dplyr::filter(time_interval != "overall")|>
    dplyr::mutate(
      # Extract the start date
      start_date = clock::date_parse(stringr::str_extract(time_interval, "^\\d{4}-\\d{2}-\\d{2}")),
      # Convert start_date to a year-month-day object and extract the year
      year = clock::get_year(clock::as_year_month_day(start_date))
    )|>
    omopgenerics::pivotEstimates()|>
    dplyr::group_by(year, variable_level) |>
    dplyr::summarise(
      count_records = sum(count_records),
      .groups = "drop"
    )|>
    dplyr::arrange(year)

  expect_equal(q_year |> sortTibble(), y_year |> sortTibble())
  PatientProfiles::mockDisconnect(cdm = cdm)
})
