test_that("summariseMissingData() works", {
  skip_on_cran()
  # Load mock database ----
  cdm <- cdmEunomia()

  # Check all tables work ----
  expect_true(inherits(summariseMissingData(cdm, "drug_exposure"),"summarised_result"))
  expect_no_error(y<-summariseMissingData(cdm, "observation_period"))
  checkResultType(y, "summarise_missing_data")
  expect_no_error(x<-summariseMissingData(cdm, "visit_occurrence"))
  expect_no_error(summariseMissingData(cdm, "condition_occurrence"))
  expect_no_error(summariseMissingData(cdm, "drug_exposure"))

  expect_no_error(summariseMissingData(cdm, "procedure_occurrence", year = TRUE))
  expect_warning(summariseMissingData(cdm, "device_exposure"))
  expect_no_error(z<-summariseMissingData(cdm, "measurement"))
  expect_no_error(s<-summariseMissingData(cdm, "observation"))

  expect_warning(de <-summariseMissingData(cdm, "death"))
  checkResultType(de, "summarise_missing_data")

  expect_no_error(all <- summariseMissingData(cdm, c("observation_period", "visit_occurrence", "measurement")))
  expect_equal(all, dplyr::bind_rows(y, x, z))
  expect_equal(summariseMissingData(cdm, "observation"), summariseMissingData(cdm, "observation", col = colnames(cdm[['observation']])))
  x<-summariseMissingData(cdm, "procedure_occurrence", col = "procedure_date")

  expect_equal(summariseMissingData(cdm, c("procedure_occurrence","observation" ), col = "procedure_date"), dplyr::bind_rows(x,s))
  y<-summariseMissingData(cdm, "observation",col = "observation_date")
  expect_equal(summariseMissingData(cdm, c("procedure_occurrence","observation" ), col = c("procedure_date", "observation_date")), dplyr::bind_rows(x,y))

  # Check inputs ----
  expect_true(summariseMissingData(cdm, "procedure_occurrence", col="person_id")|>
                dplyr::select(estimate_value)|>
                dplyr::mutate(estimate_value = as.numeric(estimate_value)) |>
                dplyr::summarise(sum = sum(estimate_value)) |>
                dplyr::pull() == 0)

  expect_true(summariseMissingData(cdm, "procedure_occurrence", col="person_id", sex = TRUE, ageGroup = list(c(0,50), c(51,Inf)))|>
    dplyr::distinct(.data$strata_level)|>
    dplyr::tally()|>
    dplyr::pull()==9)

  expect_true(summariseMissingData(cdm, "procedure_occurrence", col="person_id", ageGroup = list(c(0,50)))|>
    dplyr::distinct(.data$strata_level)|>
    dplyr::tally()|>
    dplyr::pull()==3)

  cdm$procedure_occurrence <- cdm$procedure_occurrence |>
    dplyr::mutate(procedure_concept_id = NA_integer_) |>
    dplyr::compute(name = "procedure_occurrence", temporary = FALSE)

  expect_warning(summariseMissingData(cdm, "procedure_occurrence", col="procedure_concept_id", ageGroup = list(c(0,50))))
  expect_no_error(summariseMissingData(cdm, "procedure_occurrence", col="procedure_concept_id", ageGroup = list(c(0,50)), sample=100))
})

test_that("dateRange argument works", {
  skip_on_cran()
  # Load mock database ----
  cdm <- cdmEunomia()

  expect_no_error(summariseMissingData(cdm, "condition_occurrence", dateRange =  as.Date(c("2012-01-01", "2018-01-01"))))
  expect_message(x<-summariseMissingData(cdm, "drug_exposure", dateRange =  as.Date(c("2012-01-01", "2025-01-01"))))
  observationRange <- cdm$observation_period |>
    dplyr::summarise(minobs = min(.data$observation_period_start_date, na.rm = TRUE),
                     maxobs = max(.data$observation_period_end_date, na.rm = TRUE))
  expect_no_error(y<- summariseMissingData(cdm, "drug_exposure", dateRange = as.Date(c("2012-01-01", observationRange |>dplyr::pull("maxobs")))))
  expect_equal(x,y, ignore_attr = TRUE)
  expect_false(settings(x)$study_period_end==settings(y)$study_period_end)
  expect_error(summariseMissingData(cdm, "drug_exposure", dateRange =  as.Date(c("2015-01-01", "2014-01-01"))))
  expect_warning(z<-summariseMissingData(cdm, "drug_exposure", dateRange =  as.Date(c("2020-01-01", "2021-01-01"))))
  expect_equal(z, omopgenerics::emptySummarisedResult(), ignore_attr = TRUE)
  expect_equal(summariseMissingData(cdm, "drug_exposure",dateRange = as.Date(c("2012-01-01",NA))), y, ignore_attr = TRUE)
  checkResultType(z, "summarise_missing_data")
  expect_equal(colnames(settings(z)), colnames(settings(x)))
  PatientProfiles::mockDisconnect(cdm = cdm)
})

test_that("tableMissingData() works", {
  skip_on_cran()
  # Load mock database ----
  cdm <- cdmEunomia()

  # Check that works ----
  expect_no_error(x <- tableMissingData(summariseMissingData(cdm, "condition_occurrence")))
  expect_true(inherits(x,"gt_tbl"))
  expect_no_error(y <- tableMissingData(summariseMissingData(cdm, c("observation_period",
                                                                            "measurement"))))
  expect_true(inherits(y,"gt_tbl"))
  expect_warning(t <- summariseMissingData(cdm, "death"))
  expect_warning(inherits(tableMissingData(t),"gt_tbl"))

  PatientProfiles::mockDisconnect(cdm = cdm)
})

test_that("col not present in table", {
  skip_on_cran()
  # Load mock database ----
  # Load mock database
  cdm <- omopgenerics::cdmFromTables(
    tables = list(
      person = dplyr::tibble(
        person_id = as.integer(1:4),
        gender_concept_id = c(8507L, 8532L, 8532L, 8507L),
        year_of_birth = 2010L,
        month_of_birth = 1L,
        day_of_birth = 1L,
        race_concept_id = 0L,
        ethnicity_concept_id = 0L
      ),
      observation_period = dplyr::tibble(
        observation_period_id = as.integer(1:8),
        person_id = c(1, 1, 1, 2, 2, 3, 3, 4) |> as.integer(),
        observation_period_start_date = as.Date(c(
          "2020-03-01", "2020-03-25", "2020-04-25", "2020-08-10", "2020-03-10",
          "2020-03-01", "2020-04-10", "2020-03-10"
        )),
        observation_period_end_date = as.Date(c(
          "2020-03-20", "2020-03-30", "2020-08-15", "2020-12-31", "2020-03-27",
          "2020-03-09", "2020-05-08", "2020-12-10"
        )),
        period_type_concept_id = 0L
      )
    ),
    cdmName = "mock data"
  )
  cdm <- CDMConnector::copyCdmTo(
    con = connection(), cdm = cdm, schema = schema())

  expect_no_error(expect_message(summariseMissingData(cdm, "person", col = NULL)))

  PatientProfiles::mockDisconnect(cdm = cdm)
})

test_that("no tables created", {
  skip_on_cran()
  # Load mock database ----
  cdm <- cdmEunomia()

  startNames <- CDMConnector::listSourceTables(cdm)

  results <- summariseMissingData(cdm = cdm,
                                       omopTableName = c("drug_exposure", "condition_occurrence"),
                                       year=TRUE,
                                       sex = TRUE,
                                       ageGroup = list(c(0,17),
                                                       c(18,65),
                                                       c(66, 100)),
                                       dateRange = as.Date(c("2012-01-01", "2018-01-01")),
                                       sample = 100)

  endNames <- CDMConnector::listSourceTables(cdm)

  expect_true(length(setdiff(endNames, startNames)) == 0)


  PatientProfiles::mockDisconnect(cdm = cdm)
})

