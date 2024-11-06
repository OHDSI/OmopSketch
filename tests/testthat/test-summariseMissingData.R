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

  PatientProfiles::mockDisconnect(cdm = cdm)
})
