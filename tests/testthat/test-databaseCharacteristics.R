test_that("databaseCharacteristics works", {
  skip_on_cran()
  cdm <- cdmEunomia()

  expect_no_error(databaseCharacteristics(cdm) |> suppressWarnings())
  expect_no_error(databaseCharacteristics(cdm, sex = TRUE) |> suppressWarnings())

  skip_if(dbToTest == "redshift-CDMConnector")

  expect_no_error(databaseCharacteristics(cdm, sex = TRUE, ageGroup = list(c(0, 50), c(51, Inf))) |> suppressWarnings())
  expect_no_error(databaseCharacteristics(cdm, sex = TRUE, ageGroup = list(c(0, 50), c(51, Inf)), dateRange = as.Date(c("1970-01-01", NA))) |> suppressWarnings())
  expect_no_error(databaseCharacteristics(cdm, sex = TRUE, ageGroup = list(c(0, 50), c(51, Inf)), dateRange = as.Date(c("1970-01-01", NA)), conceptIdCounts = TRUE) |> suppressWarnings())
  expect_no_error(databaseCharacteristics(cdm, sex = TRUE, ageGroup = list(c(0, 50), c(51, Inf)), dateRange = as.Date(c("1970-01-01", NA)), conceptIdCounts = TRUE, interval = "years") |> suppressWarnings())
  x <- databaseCharacteristics(cdm, omopTableName = "drug_exposure", missingData = FALSE) |> suppressWarnings()
  expect_equal(
    x |> omopgenerics::filterSettings(result_type == "summarise_clinical_records") |>
      dplyr::filter(estimate_name == "na_count") |>
      nrow(),
    0
  )

  dropCreatedTables(cdm = cdm)
})

test_that("shinyCharacteristics works", {
  skip_on_cran()
  cdm <- cdmEunomia()
  dir <- tempdir()
  expect_no_error(
    result <- databaseCharacteristics(
      cdm = cdm,
      sex = TRUE,
      conceptIdCounts = TRUE
    ) |>
      suppressWarnings()
  )
  expect_false("OmopSketchShiny" %in% list.files(dir))
  expect_no_error(shinyCharacteristics(
    result = omopgenerics::emptySummarisedResult(),
    directory = dir,
  ))
  expect_true("OmopSketchShiny" %in% list.files(dir))
  expect_no_error(shinyCharacteristics(
    result = result,
    directory = dir
  ))
  expect_true("OmopSketchShiny" %in% list.files(dir))

  unlink(file.path(dir, "OmopSketchShiny"), recursive = TRUE)
  dropCreatedTables(cdm = cdm)
})

test_that("sample works", {

 cdm <- cdmEunomia()
 expect_no_error(x <- databaseCharacteristics(cdm = cdm, sample = 20L, conceptIdCounts = TRUE))
 expect_equal(x |> omopgenerics::filterSettings(grepl("snapshot",result_type)) |> dplyr::filter(.data$estimate_name == "person_count") |> dplyr::pull(.data$estimate_value), "20")
 expect_equal(x |> omopgenerics::filterSettings(grepl("characteristics",result_type)) |> dplyr::filter(.data$variable_name ==  "Number subjects") |> dplyr::pull(.data$estimate_value), "20")
 expect_true(all(x |> omopgenerics::filterSettings(grepl("clinical",result_type)) |> dplyr::filter(.data$variable_name ==  "Number subjects" & .data$estimate_name == "count") |> dplyr::pull(.data$estimate_value) |> as.numeric() <= 20 ))
 expect_true(all(x |> omopgenerics::filterSettings(grepl("observation_period",result_type)) |> dplyr::filter(.data$variable_name ==  "Number subjects") |> dplyr::pull(.data$estimate_value) |> as.numeric() <= 20))

 cdm[["adult_males"]] <- CohortConstructor::demographicsCohort(cdm = cdm, name = "adult_males", sex = "Male")
 n_subjects <-  cdm[["adult_males"]] |> dplyr::summarise(n_subjects  = dplyr::n_distinct(.data$subject_id)) |> dplyr::pull(.data$n_subjects) |> as.numeric()
 expect_no_error(x <- databaseCharacteristics(cdm = cdm, sample = "adult_males", conceptIdCounts = TRUE))
 expect_equal(x |> omopgenerics::filterSettings(grepl("snapshot",result_type)) |> dplyr::filter(.data$estimate_name == "person_count") |> dplyr::pull(.data$estimate_value), as.character(n_subjects))

 expect_equal(x |> omopgenerics::filterSettings(grepl("characteristics",result_type)) |> dplyr::filter(.data$variable_name ==  "Sex" & .data$estimate_name == "percentage") |> dplyr::pull(.data$estimate_value), "100")
 expect_true(all(x |> omopgenerics::filterSettings(grepl("clinical",result_type)) |> dplyr::filter(.data$variable_name ==  "Number subjects" & .data$estimate_name == "count") |> dplyr::pull(.data$estimate_value) |> as.numeric() <= n_subjects ))
 expect_true(all(x |> omopgenerics::filterSettings(grepl("observation_period",result_type)) |> dplyr::filter(.data$variable_name ==  "Number subjects") |> dplyr::pull(.data$estimate_value) |> as.numeric() <= n_subjects))

 dropCreatedTables(cdm = cdm)
})
