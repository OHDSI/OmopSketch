test_that("restrictStudyPeriod works", {
  cdm <- omopgenerics::cdmFromTables(
    tables = list(
      person = dplyr::tibble(
        person_id = as.integer(1:5),
        gender_concept_id = c(8507L, 8532L, 8532L, 8507L, 8507L),
        year_of_birth = c(2000L, 2000L, 2011L, 2012L, 2013L),
        month_of_birth = 1L,
        day_of_birth = 1L,
        race_concept_id = 0L,
        ethnicity_concept_id = 0L
      ),
      observation_period = dplyr::tibble(
        observation_period_id = as.integer(1:9),
        person_id = c(1, 1, 1, 2, 2, 3, 3, 4, 5) |> as.integer(),
        observation_period_start_date = as.Date(c(
          "1999-01-01", "2001-01-01", "2008-01-01", "2008-01-01",
          "2022-01-01", "2005-01-01", "2011-01-01", "2007-01-01",
          "2004-01-01"
        )),
        observation_period_end_date = as.Date(c(
          "2000-01-01", "2003-01-01", "2020-01-01", "2021-01-01",
          "2024-01-01", "2010-01-01", "2020-01-01", "2009-01-01",
          "2005-01-01"
        )),
        period_type_concept_id = 0L
      )
    ),
    cdmName = "mock data"
  )
  dateRange <- as.Date(c("1999-01-01", "2004-12-31"))

  expect_no_error(
    x <- restrictStudyPeriod(cdm$observation_period, dateRange = dateRange)
  )

  y <- tibble::tibble(
    observation_period_id = c(1,2, 9) |> as.integer(),
    person_id = c(1, 1, 5) |> as.integer(),
    observation_period_start_date = as.Date(c(
      "1999-01-01", "2001-01-01", "2004-01-01"
    )),
    observation_period_end_date = as.Date(c(
      "2000-01-01", "2003-01-01", "2005-01-01"
    )),
    period_type_concept_id = 0L
  )

  expect_equal(x, y, ignore_attr = TRUE)
  expect_true(nrow(x) == 3)

  dateRange <- as.Date(c("1999-01-01", "2025-12-31"))
  expect_no_error(x <- restrictStudyPeriod(cdm$observation_period, dateRange = dateRange))
  expect_equal(x, cdm$observation_period, ignore_attr = TRUE)

  dateRange <- as.Date(c("2000-01-01", "2000-12-31"))
  expect_warning(x <- restrictStudyPeriod(cdm$observation_period, dateRange = dateRange))
  expect_true(is.null(x))

  dateRange <- as.Date(c("1999-01-01", "2000-12-31"))
  expect_equal(restrictStudyPeriod(cdm$observation_period, dateRange = dateRange)$person_id, 1)

})
