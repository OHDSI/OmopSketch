test_that("summariseAllConceptCount works", {
  skip_on_cran()

  cdm <- cdmEunomia()

  expect_true(inherits(summariseAllConceptCounts(cdm, "drug_exposure"), "summarised_result"))
  expect_warning(summariseAllConceptCounts(cdm, "observation_period"))
  expect_no_error(x <- summariseAllConceptCounts(cdm, "visit_occurrence"))
  expect_no_error(summariseAllConceptCounts(cdm, "condition_occurrence", countBy = c("record", "person")))
  expect_no_error(summariseAllConceptCounts(cdm, "drug_exposure"))
  expect_no_error(summariseAllConceptCounts(cdm, "procedure_occurrence", countBy = "person"))
  expect_warning(summariseAllConceptCounts(cdm, "device_exposure"))
  expect_no_error(y <- summariseAllConceptCounts(cdm, "measurement"))
  expect_no_error(summariseAllConceptCounts(cdm, "observation", year = TRUE))
  expect_warning(p<-summariseAllConceptCounts(cdm, "death"))

  expect_no_error(all <- summariseAllConceptCounts(cdm, c("visit_occurrence", "measurement")))
  expect_equal(all, dplyr::bind_rows(x, y))
  expect_equal(summariseAllConceptCounts(cdm, "procedure_occurrence", countBy = "record"), summariseAllConceptCounts(cdm, "procedure_occurrence"))
  expect_warning(summariseAllConceptCounts(cdm, "observation_period"))
  expect_error(summariseAllConceptCounts(cdm, omopTableName = ""))
  expect_error(summariseAllConceptCounts(cdm, omopTableName = "visit_occurrence", countBy = "dd"))
  expect_equal(settings(y)$result_type, settings(p)$result_type)
  expect_true(summariseAllConceptCounts(cdm, "procedure_occurrence", sex = TRUE, ageGroup = list(c(0, 50), c(51, Inf))) |>
                dplyr::distinct(.data$strata_level) |>
                dplyr::tally() |>
                dplyr::pull() == 9)

  expect_true(summariseAllConceptCounts(cdm, "procedure_occurrence", ageGroup = list(c(0, 50))) |>
                dplyr::distinct(.data$strata_level) |>
                dplyr::tally() |>
                dplyr::pull() == 3)

  s <- summariseAllConceptCounts(cdm, "procedure_occurrence")
  z <- summariseAllConceptCounts(cdm, "procedure_occurrence", sex = TRUE, year = TRUE, ageGroup = list(c(0, 50), c(51, Inf)))

  x <- z |>
    dplyr::filter(strata_level == "overall") |>
    dplyr::select(variable_level, estimate_value)
  s <- s |>
    dplyr::select(variable_level, estimate_value)
  expect_equal(x, s, ignore_attr = TRUE)

  x <- z |>
    dplyr::filter(strata_name == "age_group") |>
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
  expect_no_error(summariseAllConceptCounts(cdm, "condition_occurrence", dateRange =  as.Date(c("2012-01-01", "2018-01-01"))))
  expect_message(x<-summariseAllConceptCounts(cdm, "drug_exposure", dateRange =  as.Date(c("2012-01-01", "2025-01-01"))))
  observationRange <- cdm$observation_period |>
    dplyr::summarise(minobs = min(.data$observation_period_start_date, na.rm = TRUE),
                     maxobs = max(.data$observation_period_end_date, na.rm = TRUE))
  expect_no_error(y<- summariseAllConceptCounts(cdm, "drug_exposure", dateRange = as.Date(c("2012-01-01", observationRange |>dplyr::pull("maxobs")))))
  expect_equal(x,y, ignore_attr = TRUE)
  expect_false(settings(x)$study_period_end==settings(y)$study_period_end)
  expect_error(summariseAllConceptCounts(cdm, "drug_exposure", dateRange =  as.Date(c("2015-01-01", "2014-01-01"))))
  expect_warning(y<-summariseAllConceptCounts(cdm, "drug_exposure", dateRange =  as.Date(c("2020-01-01", "2021-01-01"))))
  expect_equal(y, omopgenerics::emptySummarisedResult(), ignore_attr = TRUE)
  expect_equal(settings(y)$result_type, settings(x)$result_type)
  expect_equal(colnames(settings(y)), colnames(settings(x)))
  PatientProfiles::mockDisconnect(cdm = cdm)
})

test_that("tableAllConceptCounts() works", {
  skip_on_cran()
  # Load mock database ----
  cdm <- cdmEunomia()

  # Check that works ----
  expect_no_error(x <- tableAllConceptCounts(summariseAllConceptCounts(cdm, "condition_occurrence")))
  expect_true(inherits(x,"gt_tbl"))
  expect_no_error(y <- tableAllConceptCounts(summariseAllConceptCounts(cdm, c("drug_exposure",
                                                                    "measurement"))))
  expect_true(inherits(y,"gt_tbl"))
  expect_warning(t <- summariseAllConceptCounts(cdm, "death"))
  expect_warning(inherits(tableAllConceptCounts(t),"gt_tbl"))

  PatientProfiles::mockDisconnect(cdm = cdm)
})
