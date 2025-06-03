test_that("summariseRecordCount() works", {
  skip_on_cran()
  # Load mock database ----
  cdm <- cdmEunomia()

  # Check inputs ----
  expect_no_error(inherits(summariseRecordCount(cdm, "observation_period", interval = "months"), "summarised_result"))
  expect_no_error(inherits(summariseRecordCount(cdm, "observation_period"), "summarised_result"))

  expect_no_error(summariseRecordCount(cdm, "observation_period"))
  expect_no_error(summariseRecordCount(cdm, "visit_occurrence"))
  expect_no_error(summariseRecordCount(cdm, "drug_exposure"))
  expect_no_error(summariseRecordCount(cdm, "procedure_occurrence"))
  expect_no_error(summariseRecordCount(cdm, "measurement"))
  expect_warning(de <- summariseRecordCount(cdm, "death"))
  checkResultType(de, "summarise_record_count")

  expect_no_error(co <- summariseRecordCount(cdm, "condition_occurrence"))
  expect_warning(de <- summariseRecordCount(cdm, "device_exposure"))
  expect_no_error(o <- summariseRecordCount(cdm, "observation"))

  expect_warning(all <- summariseRecordCount(cdm, c(
    "condition_occurrence",
    "device_exposure", "observation"
  )))
  expect_equal(all, dplyr::bind_rows(co, de, o))

  # Check inputs ----
  expect_true(
    (summariseRecordCount(cdm, "observation_period", interval = "years") |>
      dplyr::filter(additional_level == "1963-01-01 to 1963-12-31") |>
      dplyr::pull("estimate_value") |>
      as.numeric()) ==
      (cdm$observation_period |>
        dplyr::inner_join(cdm[["person"]] |> dplyr::select("person_id"), by = "person_id") |>
        dplyr::ungroup() |>
        dplyr::mutate(year = clock::get_year(observation_period_start_date)) |>
        dplyr::filter(year == 1963) |>
        dplyr::tally() |>
        dplyr::pull("n"))
  )

  expect_true(
    summariseRecordCount(cdm, "condition_occurrence", interval = "months") |>
      dplyr::filter(additional_level == "1961-02-01 to 1961-02-28") |>
      dplyr::pull("estimate_value") |>
      as.numeric() ==
      (cdm$condition_occurrence |>
        dplyr::ungroup() |>
        dplyr::inner_join(cdm[["person"]] |> dplyr::select("person_id"), by = "person_id") |>
        dplyr::mutate(year = clock::get_year(condition_start_date)) |>
        dplyr::mutate(month = clock::get_month(condition_start_date)) |>
        dplyr::filter(year == 1961, month == 2) |>
        dplyr::tally() |>
        dplyr::pull("n"))
  )

  expect_true(
    (summariseRecordCount(cdm, "condition_occurrence", interval = "months") |>
      dplyr::filter(additional_level %in% c("1984-01-01 to 1984-01-31", "1984-02-01 to 1984-02-29", "1984-03-01 to 1984-03-31")) |>
      dplyr::summarise("estimate_value" = sum(as.numeric(estimate_value), na.rm = TRUE)) |>
      dplyr::pull("estimate_value") |>
      as.numeric()) ==
      (cdm$condition_occurrence |>
        dplyr::ungroup() |>
        dplyr::inner_join(cdm[["person"]] |> dplyr::select("person_id"), by = "person_id") |>
        dplyr::mutate(year = clock::get_year(condition_start_date)) |>
        dplyr::mutate(month = clock::get_month(condition_start_date)) |>
        dplyr::filter(year == 1984, month %in% c(1:3)) |>
        dplyr::tally() |>
        dplyr::pull("n"))
  )

  expect_true(
    (summariseRecordCount(cdm, "drug_exposure", interval = "years") |>
      dplyr::filter(additional_level %in% c(
        "1981-01-01 to 1981-12-31", "1982-01-01 to 1982-12-31", "1983-01-01 to 1983-12-31",
        "1984-01-01 to 1984-12-31", "1985-01-01 to 1985-12-31", "1986-01-01 to 1986-12-31",
        "1987-01-01 to 1987-12-31", "1988-01-01 to 1988-12-31"
      )) |>
      dplyr::summarise("estimate_value" = sum(as.numeric(.data$estimate_value), na.rm = TRUE)) |>
      dplyr::pull("estimate_value") |>
      as.numeric()) ==
      (cdm$drug_exposure |>
        dplyr::ungroup() |>
        dplyr::inner_join(cdm[["person"]] |> dplyr::select("person_id"), by = "person_id") |>
        dplyr::mutate(year = clock::get_year(drug_exposure_start_date)) |>
        dplyr::filter(year %in% c(1981:1988)) |>
        dplyr::tally() |>
        dplyr::pull("n"))
  )

  # Check result type
  result <- summariseRecordCount(cdm, "observation_period", interval = "months")
  checkResultType(result, "summarise_record_count")

  PatientProfiles::mockDisconnect(cdm = cdm)
})

test_that("plotRecordCount() works", {
  skip_on_cran()
  # Load mock database ----
  cdm <- cdmEunomia()

  p <- summariseRecordCount(cdm, "drug_exposure", interval = "years") |>
    plotRecordCount()

  expect_true(inherits(p, "ggplot"))

  p2 <- summariseRecordCount(cdm, c("condition_occurrence", "drug_exposure"), interval = "years") |>
    plotRecordCount(facet = "omop_table")

  expect_true(inherits(p2, "ggplot"))

  expect_error(inherits(plotRecordCount(summariseRecordCount(cdm, "death", unitInterval = 8)), "ggplot"))

  PatientProfiles::mockDisconnect(cdm = cdm)
})

test_that("summariseRecordCount() ageGroup argument works", {
  skip_on_cran()
  # Load mock database ----
  cdm <- cdmEunomia()

  # Check that works ----
  expect_no_error(summariseRecordCount(cdm, "condition_occurrence", ageGroup = list(c(65, Inf), c(0, 64))))

  expect_no_error(t <- summariseRecordCount(cdm, "condition_occurrence",
    ageGroup = list(">=65" = c(65, Inf), "<65" = c(0, 64))
  ))
  x <- t |>
    dplyr::select("strata_level", "additional_level", "estimate_value") |>
    dplyr::filter(strata_level != "overall") |>
    dplyr::group_by(additional_level) |>
    dplyr::summarise(estimate_value = sum(as.numeric(estimate_value))) |>
    dplyr::arrange(additional_level) |>
    dplyr::pull("estimate_value")
  y <- t |>
    dplyr::select("strata_level", "additional_level", "estimate_value") |>
    dplyr::filter(strata_level == "overall") |>
    dplyr::arrange(additional_level) |>
    dplyr::mutate(estimate_value = as.numeric(estimate_value)) |>
    dplyr::pull("estimate_value")
  expect_equal(x, y)

  expect_no_error(t <- summariseRecordCount(cdm, "condition_occurrence",
    ageGroup = list("<=20" = c(0, 20), "21 to 40" = c(21, 40), "41 to 60" = c(41, 60), ">60" = c(61, Inf))
  ))
  x <- t |>
    dplyr::select("strata_level", "additional_level", "estimate_value") |>
    dplyr::filter(strata_level != "overall") |>
    dplyr::group_by(additional_level) |>
    dplyr::summarise(estimate_value = sum(as.numeric(estimate_value))) |>
    dplyr::arrange(additional_level) |>
    dplyr::pull("estimate_value")
  y <- t |>
    dplyr::select("strata_level", "additional_level", "estimate_value") |>
    dplyr::filter(strata_level == "overall") |>
    dplyr::arrange(additional_level) |>
    dplyr::mutate(estimate_value = as.numeric(estimate_value)) |>
    dplyr::pull("estimate_value")
  expect_equal(x, y)

  expect_no_error(t <- summariseRecordCount(cdm, "condition_occurrence",
    interval = "years",
    ageGroup = list("<=20" = c(0, 20), "21 to 40" = c(21, 40), "41 to 60" = c(41, 60), ">60" = c(61, Inf))
  ))
  x <- t |>
    dplyr::select("strata_level", "additional_level", "estimate_value") |>
    dplyr::filter(strata_level == "<=20" & additional_level == "1920-01-01 to 1920-12-31") |>
    dplyr::summarise(n = sum(as.numeric(estimate_value))) |>
    dplyr::pull("n")
  y <- cdm$condition_occurrence |>
    dplyr::inner_join(cdm[["person"]] |> dplyr::select("person_id"), by = "person_id") |>
    PatientProfiles::addAgeQuery(indexDate = "condition_start_date", ageGroup = list("<=20" = c(0, 20))) |>
    dplyr::filter(age_group == "<=20") |>
    dplyr::filter(clock::get_year(condition_start_date) == "1920") |>
    dplyr::summarise(n = dplyr::n()) |>
    dplyr::pull("n") |>
    as.numeric()
  expect_equal(x, y)


  expect_no_error(t <- summariseRecordCount(cdm, "condition_occurrence",
    interval = "years",
    ageGroup = list("<=20" = c(0, 20), "21 to 40" = c(21, 40), "41 to 60" = c(41, 60))
  ))
  x <- t |>
    dplyr::select("strata_level", "additional_level", "estimate_value") |>
    dplyr::filter(strata_level == "<=20" & additional_level == "1920-01-01 to 1920-12-31") |>
    dplyr::summarise(n = sum(as.numeric(estimate_value))) |>
    dplyr::pull("n") |>
    as.numeric()
  y <- cdm$condition_occurrence |>
    dplyr::inner_join(cdm[["person"]] |> dplyr::select("person_id"), by = "person_id") |>
    PatientProfiles::addAgeQuery(indexDate = "condition_start_date", ageGroup = list("<=20" = c(0, 20))) |>
    dplyr::filter(age_group == "<=20") |>
    dplyr::filter(clock::get_year(condition_start_date) == "1920") |>
    dplyr::summarise(n = dplyr::n()) |>
    dplyr::pull("n") |>
    as.numeric()
  expect_equal(x, y)

  PatientProfiles::mockDisconnect(cdm = cdm)
})

test_that("summariseRecordCount() sex argument works", {
  skip_on_cran()
  # Load mock database ----
  cdm <- cdmEunomia()

  # Check that works ----
  expect_no_error(t <- summariseRecordCount(cdm, "condition_occurrence", sex = TRUE))
  x <- t |>
    dplyr::select("strata_level", "additional_level", "estimate_value") |>
    dplyr::filter(strata_level != "overall") |>
    dplyr::group_by(additional_level) |>
    dplyr::summarise(estimate_value = sum(as.numeric(estimate_value))) |>
    dplyr::arrange(additional_level) |>
    dplyr::pull("estimate_value")
  y <- t |>
    dplyr::select("strata_level", "additional_level", "estimate_value") |>
    dplyr::filter(strata_level == "overall") |>
    dplyr::arrange(additional_level) |>
    dplyr::mutate(estimate_value = as.numeric(estimate_value)) |>
    dplyr::pull("estimate_value")
  expect_equal(x, y)

  expect_no_error(t <- summariseRecordCount(cdm, "observation_period", sex = TRUE))
  x <- t |>
    dplyr::select("strata_level", "additional_level", "estimate_value") |>
    dplyr::filter(strata_level != "overall") |>
    dplyr::group_by(additional_level) |>
    dplyr::summarise(estimate_value = sum(as.numeric(estimate_value))) |>
    dplyr::arrange(additional_level) |>
    dplyr::pull("estimate_value")
  y <- t |>
    dplyr::select("strata_level", "additional_level", "estimate_value") |>
    dplyr::filter(strata_level == "overall") |>
    dplyr::arrange(additional_level) |>
    dplyr::mutate(estimate_value = as.numeric(estimate_value)) |>
    dplyr::pull("estimate_value")
  expect_equal(x, y)

  expect_no_error(t <- summariseRecordCount(cdm, "condition_occurrence", sex = TRUE, interval = "years"))
  x <- t |>
    dplyr::select("strata_level", "additional_level", "estimate_value") |>
    dplyr::filter(strata_level == "Male", additional_level == "1937-01-01 to 1937-12-31") |>
    dplyr::pull(estimate_value)

  y <- cdm$condition_occurrence |>
    dplyr::inner_join(cdm[["person"]] |> dplyr::select("person_id"), by = "person_id") |>
    PatientProfiles::addSexQuery() |>
    dplyr::filter(sex == "Male") |>
    dplyr::mutate(year = clock::get_year(condition_start_date)) |>
    dplyr::filter(year == 1937) |>
    dplyr::summarise(n = n()) |>
    dplyr::pull(n) |>
    as.character()
  expect_equal(x, y)

  PatientProfiles::mockDisconnect(cdm = cdm)
})

test_that("summariseRecordCount() works with mockOmopSketch", {
  skip_on_cran()
  cdm <- mockOmopSketch(numberIndividuals = 3, seed = 1)
  conditionpp <- cdm$condition_occurrence |>
    PatientProfiles::addDemographics(indexDate = "condition_start_date", ageGroup = list(c(0, 20), c(21, 150))) |>
    dplyr::mutate(year = clock::get_year(condition_start_date)) |>
    dplyr::group_by(year, age_group, sex) |>
    dplyr::summarise(n = n())

  expect_no_error(co <- summariseRecordCount(cdm, "condition_occurrence", interval = "years", sex = TRUE, ageGroup = list(c(0, 20), c(21, 150))))

  expect_true(co |> dplyr::filter(grepl("Male", strata_level)) |>
    dplyr::tally() |> dplyr::pull() == 0)
  expect_true(all(co |> dplyr::filter(grepl("&&&", strata_level), additional_level != "overall") |>
    dplyr::pull("estimate_value") |> sort() ==
    conditionpp |>
      dplyr::pull("n") |>
      as.character() |>
      sort()))

  # Check result type
  checkResultType(co, "summarise_record_count")

  PatientProfiles::mockDisconnect(cdm = cdm)
})

test_that("dateRnge argument works", {
  skip_on_cran()
  # Load mock database ----
  cdm <- cdmEunomia()

  expect_no_error(summariseRecordCount(cdm, "condition_occurrence", dateRange = as.Date(c("2012-01-01", "2018-01-01"))))
  expect_message(x <- summariseRecordCount(cdm, "drug_exposure", dateRange = as.Date(c("2012-01-01", "2025-01-01"))))
  observationRange <- cdm$observation_period |>
    dplyr::summarise(
      minobs = min(.data$observation_period_start_date, na.rm = TRUE),
      maxobs = max(.data$observation_period_end_date, na.rm = TRUE)
    )
  expect_no_error(y <- summariseRecordCount(cdm, "drug_exposure", dateRange = as.Date(c("2012-01-01", observationRange |> dplyr::pull("maxobs")))))
  expect_equal(x, y, ignore_attr = TRUE)
  expect_false(settings(x)$study_period_end == settings(y)$study_period_end)
  expect_error(summariseRecordCount(cdm, "drug_exposure", dateRange = as.Date(c("2015-01-01", "2014-01-01"))))
  expect_message(expect_warning(z <- summariseRecordCount(cdm, "drug_exposure", dateRange = as.Date(c("2020-01-01", "2021-01-01")))))
  expect_equal(z, omopgenerics::emptySummarisedResult(), ignore_attr = TRUE)
  expect_equal(summariseRecordCount(cdm, "drug_exposure", dateRange = as.Date(c("2012-01-01", NA))), y, ignore_attr = TRUE)
  checkResultType(z, "summarise_record_count")

  PatientProfiles::mockDisconnect(cdm = cdm)

  db <- DBI::dbConnect(duckdb::duckdb(), dbdir = CDMConnector::eunomiaDir())
  cdm <- CDMConnector::cdmFromCon(con = db, cdmSchema = "main", writeSchema = "main")


  expect_no_error(summariseRecordCount(cdm, "observation_period",
    interval = "years",
    dateRange = as.Date(c("2012-01-01", NA))
  ))
  PatientProfiles::mockDisconnect(cdm = cdm)
})


test_that("sample argument works", {
  skip_on_cran()
  # Load mock database ----
  cdm <- cdmEunomia()

  expect_no_error(x <- summariseRecordCount(cdm, "drug_exposure", sample = 50))
  expect_no_error(y <- summariseRecordCount(cdm, "drug_exposure"))
  n <- cdm$drug_exposure |>
    dplyr::tally() |>
    dplyr::pull(n)
  expect_no_error(z <- summariseRecordCount(cdm, "drug_exposure", sample = n))
  expect_equal(y, z)
  expect_equal(summariseRecordCount(cdm, "drug_exposure", sample = 1) |>
    dplyr::filter(.data$variable_name == "Number records") |>
    dplyr::pull(.data$estimate_value) |>
    as.integer(), 1L)
  PatientProfiles::mockDisconnect(cdm = cdm)
})

test_that("no tables created", {
  skip_on_cran()
  # Load mock database ----
  cdm <- cdmEunomia()

  startNames <- CDMConnector::listSourceTables(cdm)

  results <- summariseRecordCount(
    cdm = cdm,
    omopTableName = c("drug_exposure", "condition_occurrence"),
    interval = "years",
    sex = TRUE,
    ageGroup = list(
      c(0, 17),
      c(18, 65),
      c(66, 100)
    ),
    dateRange = as.Date(c("2012-01-01", "2018-01-01")),
    sample = 100
  )

  endNames <- CDMConnector::listSourceTables(cdm)

  expect_true(length(setdiff(endNames, startNames)) == 0)


  PatientProfiles::mockDisconnect(cdm = cdm)
})
test_that("tableRecordCount works", {
  skip_on_cran()
  # Load mock database ----
  cdm <- cdmEunomia()
  expect_no_error(x <- tableRecordCount(summariseRecordCount(cdm, "drug_exposure")))
  expect_true(inherits(x, "gt_tbl"))


  expect_no_error(tableRecordCount(summariseRecordCount(cdm, "drug_exposure"), type = "datatable"))
  expect_no_error(tableRecordCount(summariseRecordCount(cdm, "drug_exposure"), type = "reactable"))



  PatientProfiles::mockDisconnect(cdm = cdm)
})
