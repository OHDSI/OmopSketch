test_that("summariseMissingData() works", {
  skip_on_cran()
  # Load mock database ----
  cdm <- cdmEunomia()

  # Check all tables work ----
  expect_true(inherits(summariseMissingData(cdm, "drug_exposure"),"summarised_result"))
  expect_no_error(y<-summariseMissingData(cdm, "observation_period"))
  expect_no_error(x<-summariseMissingData(cdm, "visit_occurrence"))
  expect_no_error(summariseMissingData(cdm, "condition_occurrence"))
  expect_no_error(summariseMissingData(cdm, "drug_exposure"))

  expect_no_error(summariseMissingData(cdm, "procedure_occurrence", year = TRUE))
  expect_warning(summariseMissingData(cdm, "device_exposure"))
  expect_no_error(z<-summariseMissingData(cdm, "measurement"))
  expect_no_error(s<-summariseMissingData(cdm, "observation"))

  expect_warning(summariseMissingData(cdm, "death"))


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
  expect_warning(expect_warning(z<-summariseMissingData(cdm, "drug_exposure", dateRange =  as.Date(c("2020-01-01", "2021-01-01")))))
  expect_equal(z, omopgenerics::emptySummarisedResult(), ignore_attr = TRUE)
  expect_equal(summariseMissingData(cdm, "drug_exposure",dateRange = as.Date(c("2012-01-01",NA))), y, ignore_attr = TRUE)

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
