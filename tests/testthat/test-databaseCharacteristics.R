

test_that("databaseCharacteristics works", {
  skip_on_cran()
  cdm <- mockOmopSketch()

  expect_no_error(databaseCharacteristics(cdm) |> suppressWarnings())
  expect_no_error(databaseCharacteristics(cdm, sex = TRUE ) |> suppressWarnings())
  expect_no_error(databaseCharacteristics(cdm, sex = TRUE, ageGroup = list(c(0,50), c(51,Inf)) ) |> suppressWarnings())
  expect_no_error(databaseCharacteristics(cdm, sex = TRUE, ageGroup = list(c(0,50), c(51,Inf)), dateRange = as.Date(c("1970-01-01", NA)) ) |> suppressWarnings())
  expect_no_error(databaseCharacteristics(cdm, sex = TRUE, ageGroup = list(c(0,50), c(51,Inf)), dateRange = as.Date(c("1970-01-01", NA)), conceptIdCounts = TRUE) |> suppressWarnings())
  expect_no_error(databaseCharacteristics(cdm, sex = TRUE, ageGroup = list(c(0,50), c(51,Inf)), dateRange = as.Date(c("1970-01-01", NA)), conceptIdCounts = TRUE, interval = "years") |> suppressWarnings())
  x <- databaseCharacteristics(cdm, omopTableName = "drug_exposure",  sample = 1) |> suppressWarnings()

  expect_equal(x |> omopgenerics::filterSettings(result_type == "summarise_missing_data")|>
                 dplyr::filter(estimate_name == "na_count") |>
                 dplyr::distinct(estimate_value) |>
                 dplyr::pull() |>
                 as.integer() |>
                 sort(),
               c(0L, 1L))

})

test_that("shinyCharacteristics works", {

  skip_on_cran()
  cdm <- mockOmopSketch()
  dir <- tempdir()
  expect_no_error(result <- databaseCharacteristics(cdm, sex = TRUE, conceptIdCounts = TRUE ) |> suppressWarnings())
  expect_warning(shinyCharacteristics(
    result = omopgenerics::emptySummarisedResult(),
    directory = dir,
  ))
  expect_false("shiny" %in% list.files(dir))
  expect_no_error(shinyCharacteristics(
    result = result,
    directory = dir
  ))
  expect_true("shiny" %in% list.files(dir))

  unlink(file.path(dir, "shiny"), recursive = TRUE)
})

