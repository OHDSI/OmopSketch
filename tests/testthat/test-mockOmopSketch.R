test_that("check mockOmopSketch", {
  skip_on_cran()

  expect_error(mockOmopSketch(con = "aasa"))

  # By default
  expect_no_error(cdm <- mockOmopSketch())
  expect_true(inherits(cdm, "cdm_reference"))
  expect_true(omopgenerics::sourceType(cdm) == "duckdb")

  # Set connexion to duckdb
  expect_no_error(cdm <- mockOmopSketch(
    con = connection("duckdb"),
    writeSchema = "main"
  ))
  expect_true(omopgenerics::sourceType(cdm) == "duckdb")

  PatientProfiles::mockDisconnect(cdm = cdm)
})
