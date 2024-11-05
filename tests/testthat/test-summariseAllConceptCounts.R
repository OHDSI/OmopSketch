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
  expect_warning(summariseAllConceptCounts(cdm, "death"))

  expect_no_error(all <- summariseAllConceptCounts(cdm, c("visit_occurrence", "measurement")))
  expect_equal(all, dplyr::bind_rows(x, y))
  expect_equal(summariseAllConceptCounts(cdm, "procedure_occurrence", countBy = "record"), summariseAllConceptCounts(cdm, "procedure_occurrence"))

  expect_error(summariseAllConceptCounts(cdm, omopTableName = ""))
  expect_error(summariseAllConceptCounts(cdm, omopTableName = "visit_occurrence", countBy = "dd"))

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
  expect_equal(x, s)

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
