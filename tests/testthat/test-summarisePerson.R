test_that("multiplication works", {
  skip_on_cran()
  cdm <- cdmEunomia()

  expect_no_error(res <- summarisePerson(cdm = cdm))

  expect_no_error(tablePerson(result = res))

  vars <- plotPersonOpts()$variable_name
  for (var in vars) {
    expect_no_error(plotPerson(result = res, variableName = var))
    expect_no_error(
      res |>
        dplyr::filter(.data$variable_name == .env$var) |>
        plotPerson()
    )
  }
  expect_warning(tablePerson(omopgenerics::emptySummarisedResult()))
  dropCreatedTables(cdm = cdm)
})
