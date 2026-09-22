test_that("check mockOmopSketch", {
  skip_on_cran()
  skip_if(simpleTest, "GitHub simplified tests")
  expect_warning(expect_no_error(cdm <- mockOmopSketch()))
  expect_true(inherits(cdm, "cdm_reference"))
  expect_true(omopgenerics::sourceType(cdm) == "duckdb")
})
