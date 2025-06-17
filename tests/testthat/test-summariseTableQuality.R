test_that("summariseTableQuality works", {

  cdm <- cdmEunomia()
  ids <- cdm$drug_exposure |> dplyr::distinct(drug_exposure_id) |> dplyr::pull()
  set.seed(123)
  shuffled <- sample(ids)
  vec1 <- shuffled[1:10]
  vec2 <- shuffled[11:20]
  cdm$drug_exposure <- cdm$drug_exposure |>
    dplyr::mutate(drug_exposure_start_date = dplyr::if_else(.data$drug_exposure_id %in% vec1,
                                                            as.Date("3000-01-01"),
                                                            dplyr::if_else(.data$drug_exposure_id %in% vec2,
                                                                           as.Date("1900-01-01"),
                                                                           .data$drug_exposure_start_date)))



  expect_no_error(x <- summariseTableQuality(cdm, "drug_exposure"))
  y <- cdm$drug_exposure |>
    dplyr::filter(.data$drug_exposure_end_date < .data$drug_exposure_start_date)
  z <- cdm$drug_exposure |>
    dplyr::inner_join(cdm$person |> dplyr::select(person_id, birth_datetime), by = "person_id") |>
    dplyr::filter(.data$drug_exposure_start_date < .data$birth_datetime)

  expect_equal(y |> dplyr::tally() |> dplyr::pull(n),
               x |> dplyr::filter(variable_name == "Records with end date before start date", estimate_name == "count") |> dplyr::pull(estimate_value) |> as.numeric()
  )

  expect_equal(z |> dplyr::tally() |> dplyr::pull(n),
               x |> dplyr::filter(variable_name == "Records with start date before birthdate", estimate_name == "count") |> dplyr::pull(estimate_value) |> as.numeric()
  )

  expect_no_error(x <- summariseTableQuality(cdm, "drug_exposure", sex = TRUE))
  x <- x |> omopgenerics::splitStrata()


  expect_equal(y |>
                 PatientProfiles::addSexQuery() |>
                 dplyr::filter(sex == "Female") |>
                 dplyr::tally() |> dplyr::pull(n),
               x |>
                dplyr::filter(sex == "Female" & variable_name == "Records with end date before start date" & estimate_name == "count") |>
                dplyr::pull(estimate_value) |>
                as.numeric() )

  expect_equal(z |>
                 PatientProfiles::addSexQuery() |>
                 dplyr::filter(sex == "Female") |>
                 dplyr::tally() |> dplyr::pull(n),
               x |>
                 dplyr::filter(sex == "Female" & variable_name == "Records with start date before birthdate" & estimate_name == "count") |>
                 dplyr::pull(estimate_value) |>
                 as.numeric() )

  expect_no_error(x <- summariseTableQuality(cdm, "drug_exposure", dateRange = as.Date(c("1910-01-01", NA))))
  expect_no_error(x <- summariseTableQuality(cdm, "drug_exposure", sample = 5))
  expect_no_error(x <- summariseTableQuality(cdm, "drug_exposure", interval = "years"))
  xx <- x |>
    omopgenerics::splitAdditional() |>
    dplyr::filter(variable_name == "Records with start date before birthdate" & estimate_name == "count" & time_interval == "1970-01-01 to 1970-12-31") |>
    dplyr::pull(estimate_value) |> as.numeric()
  zz <- z |> dplyr::filter(.data$drug_exposure_start_date >= as.Date("1970-01-01") & .data$drug_exposure_start_date <= as.Date("1970-12-31")) |> dplyr::tally() |> dplyr::pull(n)
  expect_equal(zz,xx)


  ids <- cdm$condition_occurrence |> dplyr::distinct(condition_occurrence_id) |> dplyr::pull()
  set.seed(123)
  shuffled <- sample(ids)
  vec <- shuffled[1:10]

  cdm$condition_occurrence <- cdm$condition_occurrence |>
    dplyr::mutate(condition_start_date = dplyr::if_else(.data$condition_occurrence_id %in% vec,
                                                        as.Date("3000-01-01"),
                                                        .data$condition_start_date))
  y <- cdm$condition_occurrence |>
    dplyr::filter(.data$condition_end_date < .data$condition_start_date)


  expect_no_error(x <- summariseTableQuality(cdm, "condition_occurrence"))
  expect_equal(y |> dplyr::tally() |> dplyr::pull(n), x |> dplyr::filter(estimate_name == "count", variable_name == "Records with end date before start date") |> dplyr::pull(estimate_value)|> as.numeric())
  expect_equal(0L, x |> dplyr::filter(estimate_name == "count", variable_name == "Records with start date before birthdate") |> dplyr::pull(estimate_value)|> as.numeric())


  ids <- cdm$observation_period |> dplyr::distinct(observation_period_id) |> dplyr::pull()
  set.seed(123)
  shuffled <- sample(ids)
  vec <- shuffled[1:10]

  cdm$observation_period <- cdm$observation_period |>
    dplyr::mutate(observation_period_start_date = dplyr::if_else(.data$observation_period_id %in% vec,
                                                                 as.Date("1900-01-01"),
                                                                 .data$observation_period_start_date))

  z <- cdm$observation_period |>
    dplyr::inner_join(cdm$person |> dplyr::select(person_id, birth_datetime), by = "person_id") |>
    dplyr::filter(.data$observation_period_start_date < .data$birth_datetime)

  expect_no_error(x <- summariseTableQuality(cdm, "observation_period"))
  expect_equal(z|>dplyr::tally() |> dplyr::pull(n), x |> dplyr::filter(variable_name == "Records with start date before birthdate" & estimate_name == "count") |> dplyr::pull(estimate_value) |> as.numeric())

  expect_equal(0L, x |> dplyr::filter(estimate_name == "count", variable_name == "Records with end date before start date") |> dplyr::pull(estimate_value)|> as.numeric())


  expect_no_error(summariseTableQuality(cdm, "procedure_occurrence"))
  expect_no_error(summariseTableQuality(cdm, "measurement"))
  expect_warning(summariseTableQuality(cdm, "death"))




  CDMConnector::cdmDisconnect(cdm)


})




test_that("tableQuality works", {

  cdm <- mockOmopSketch()
  expect_no_error(result <- summariseTableQuality(cdm, "drug_exposure", sex = TRUE))
  expect_no_error(tableQuality(result, type = "gt"))
  expect_no_error(tableQuality(result, type = "reactable"))
  expect_no_error(tableQuality(result, type = "flextable"))

  CDMConnector::cdmDisconnect(cdm)


})

