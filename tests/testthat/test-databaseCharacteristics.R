

test_that("databaseCharacteristics works", {
  skip_on_cran()
  cdm <- mockOmopSketch()

  expect_no_error(databaseCharacteristics(cdm ))
  expect_no_error(databaseCharacteristics(cdm, sex = TRUE ))
  expect_no_error(databaseCharacteristics(cdm, sex = TRUE, ageGroup = list(c(0,50), c(51,Inf)) ))
  expect_no_error(databaseCharacteristics(cdm, sex = TRUE, ageGroup = list(c(0,50), c(51,Inf)), dateRange = as.Date(c("1970-01-01", NA)) ))
  expect_no_error(databaseCharacteristics(cdm, sex = TRUE, ageGroup = list(c(0,50), c(51,Inf)), dateRange = as.Date(c("1970-01-01", NA)), conceptIdCount = TRUE))
  expect_no_error(databaseCharacteristics(cdm, sex = TRUE, ageGroup = list(c(0,50), c(51,Inf)), dateRange = as.Date(c("1970-01-01", NA)), conceptIdCount = TRUE, interval = "years"))
  x<-databaseCharacteristics(cdm, omopTableName = "drug_exposure",  sample = 1)

  expect_equal(x |> omopgenerics::filterSettings(result_type == "summarise_missing_data")|>
                 dplyr::filter(estimate_name == "na_count") |>
                 dplyr::distinct(estimate_value) |>
                 dplyr::pull() |>
                 as.integer() |>
                 sort(),
               c(0L, 1L))




})

