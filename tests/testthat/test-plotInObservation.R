test_that("plotInObservation works", {
  skip_on_cran()
  # Load mock database ----
  cdm <- cdmEunomia()

  # summariseInObservationPlot plot ----
  x <- summariseInObservation(cdm$observation_period, interval = "years")
  expect_no_error(inherits(plotInObservation(x), "ggplot"))
  x <-  x |> dplyr::filter(result_id == -1)
  expect_error(plotInObservation(x))

  expect_error(plotInObservation(summariseInObservation(cdm$observation_period, interval = "years", output = c("person-days", "records"), ageGroup = NULL, sex = FALSE)))

  x <- summariseInObservation(cdm$observation_period, interval = "years", output = "person-days", ageGroup = NULL, sex = FALSE)
  expect_true(inherits(plotInObservation(x), "ggplot"))

  x <- summariseInObservation(cdm$observation_period, interval = "years", output = "records", ageGroup = NULL, sex = FALSE)
  expect_true(inherits(plotInObservation(x), "ggplot"))

  result <- cdm$observation_period |>
    summariseInObservation(
      output = c("person-days", "records"),
      sex = TRUE,
      ageGroup = list(
        "0-19" = c(0, 19), "20-39" = c(20, 39), "40-59" = c(40, 59),
        "60-79" = c(60, 79), "80 or above" = c(80, Inf))
    )

  expect_error(plotInObservation(result))

  resultpd <- result |>
    dplyr::filter(variable_name == "Number person-days")

  expect_warning(plotInObservation(resultpd))
  expect_no_error(
    resultpd |>
      visOmopResults::filterStrata(sex != "overall", age_group != "overall") |>
      plotInObservation(facet = "sex", colour = "age_group")
  )
  expect_no_error(
    resultpd |>
      visOmopResults::filterStrata(sex != "overall", age_group != "overall") |>
      plotInObservation(
        facet = sex ~ age_group,
        colour = c("age_group", "cdm_name")
      )
  )

  resultr <- result |>
    dplyr::filter(variable_name == "Number records in observation")

  expect_warning(plotInObservation(resultr))
  expect_no_error(
    resultr |>
      visOmopResults::filterStrata(sex != "overall", age_group != "overall") |>
      plotInObservation(facet = "sex", colour = "age_group")
  )
  expect_no_error(
    resultr |>
      visOmopResults::filterStrata(sex != "overall", age_group != "overall") |>
      plotInObservation(
        facet = sex ~ age_group,
        colour = "age_group"
      )
  )

  PatientProfiles::mockDisconnect(cdm = cdm)
})
