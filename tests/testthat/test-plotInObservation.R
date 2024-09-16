test_that("check plotInObservation", {
  cdm <- cdmEunomia()

  result <- cdm$observation_period |>
    summariseInObservation(
      output = "all",
      sex = TRUE,
      ageGroup = list(
        "0-19" = c(0, 19), "20-39" = c(20, 39), "40-59" = c(40, 59),
        "60-79" = c(60, 79), ">80" = c(80, Inf))
    )

  expect_snapshot(plotInObservation(result), error = TRUE)

  resultpd <- result |>
    dplyr::filter(variable_name == "person-days")

  expect_no_error(plotInObservation(resultpd))
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
    dplyr::filter(variable_name == "records")

  expect_no_error(plotInObservation(resultr))
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
