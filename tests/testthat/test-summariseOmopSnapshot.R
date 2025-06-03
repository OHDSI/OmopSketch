test_that("summarise omop snapshot works", {
  skip_on_cran()
  cdm <- cdmEunomia()
  expect_no_error(result <- summariseOmopSnapshot(cdm))
  expect_true(inherits(summariseOmopSnapshot(cdm), "summarised_result"))
  PatientProfiles::mockDisconnect(cdm = cdm)
})

test_that("table omop snapshot works", {
  skip_on_cran()
  cdm <- cdmEunomia()

  # Check that works ----
  expect_no_error(x <- tableOmopSnapshot(summariseOmopSnapshot(cdm)))
  expect_true(inherits(x, "gt_tbl"))

  x <- summariseOmopSnapshot(cdm) |> dplyr::filter(result_id == 0.1)
  expect_warning(inherits(tableOmopSnapshot(x), "gt_tbl"))

  # Check result type
  checkResultType(x, "summarise_omop_snapshot")

  PatientProfiles::mockDisconnect(cdm = cdm)
})

test_that("works with mockOmopSketch", {
  skip_on_cran()
  cdm <- mockOmopSketch()
  expect_no_error(x <- tableOmopSnapshot(summariseOmopSnapshot(cdm)) |> suppressWarnings())
  expect_true(inherits(x, "gt_tbl"))
  expect_warning(x <- summariseOmopSnapshot(cdm))
  x <- x |> dplyr::filter(result_id == 0.1)
  expect_warning(inherits(tableOmopSnapshot(x), "gt_tbl"))

  # Check result type
  checkResultType(x, "summarise_omop_snapshot")

  PatientProfiles::mockDisconnect(cdm = cdm)
})
