
test_that("test deprecated functions", {
  skip_on_cran()
  skip_if(dbToTest != "duckdb-CDMConnector")

  cdm <- cdmEunomia()

  expect_warning(result <- summariseRecordCount(cdm = cdm, omopTableName = "observation_period"))
  expect_warning(tableRecordCount(result = result))
  expect_warning(plotRecordCount(result = result))

  expect_warning(result <- summariseInObservation(observationPeriod = cdm$observation_period))
  expect_warning(tableInObservation(result = result))
  expect_warning(plotInObservation(result = result))

  expect_warning(result <- summariseConceptSetCounts(cdm = cdm, conceptSet = list(my_concept = 4112343L)))
  expect_warning(
    result |>
      dplyr::filter(variable_name == 'Number records') |>
      plotConceptSetCounts()
  )
  expect_warning(result <- summariseConceptCounts(cdm = cdm, conceptId = list(my_concept = 4112343L)))

  dropCreatedTables(cdm = cdm)
})
