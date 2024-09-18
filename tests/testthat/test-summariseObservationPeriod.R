test_that("check summariseObservationPeriod works", {
  # helper function
  removeSettings <- function(x) {
    attr(x, "settings") <- NULL
    return(x)
  }
  nPoints <- 512

  # Load mock database
  cdm <- omopgenerics::cdmFromTables(
    tables = list(
      person = dplyr::tibble(
        person_id = as.integer(1:4),
        gender_concept_id = c(8507L, 8532L, 8532L, 8507L),
        year_of_birth = 2010L,
        month_of_birth = 1L,
        day_of_birth = 1L,
        race_concept_id = 0L,
        ethnicity_concept_id = 0L
      ),
      observation_period = dplyr::tibble(
        observation_period_id = as.integer(1:8),
        person_id = c(1, 1, 1, 2, 2, 3, 3, 4) |> as.integer(),
        observation_period_start_date = as.Date(c(
          "2020-03-01", "2020-03-25", "2020-04-25", "2020-08-10", "2020-03-10",
          "2020-03-01", "2020-04-10", "2020-03-10"
        )),
        observation_period_end_date = as.Date(c(
          "2020-03-20", "2020-03-30", "2020-08-15", "2020-12-31", "2020-03-27",
          "2020-03-09", "2020-05-08", "2020-12-10"
        )),
        period_type_concept_id = 0L
      )
    ),
    cdmName = "mock data"
  )
  cdm <- CDMConnector::copyCdmTo(
    con = connection(), cdm = cdm, schema = schema())

  # simple run
  expect_no_error(resAll <- summariseObservationPeriod(cdm$observation_period))
  expect_no_error(
    resAllD <- summariseObservationPeriod(cdm$observation_period, density = TRUE))
  expect_no_error(
    resAllN <- summariseObservationPeriod(cdm$observation_period, density = FALSE))

  expect_identical(resAll, resAllN)
  expect_identical(
    resAll |> removeSettings(),
    resAllD |> dplyr::filter(is.na(variable_level)) |> removeSettings()
  )
  expect_identical(settings(resAll)$density, FALSE)
  expect_identical(settings(resAllN)$density, FALSE)
  expect_identical(settings(resAllD)$density, TRUE)

  # test estimates
  expect_no_error(
    resEst <- cdm$observation_period |>
      summariseObservationPeriod(estimates = c("mean", "median")))
  expect_true(all(
    resEst |>
      dplyr::filter(!.data$variable_name %in% c("number records", "number subjects")) |>
      dplyr::pull("estimate_name") |>
      unique() %in% c("mean", "median")
  ))

  # counts
  expect_identical(resAll$estimate_value[resAll$variable_name == "number records"], "8")
  x <- dplyr::tibble(
    strata_level = c("overall", "1st", "2nd", "3rd"),
    variable_name = "number subjects",
    estimate_value = c("4", "4", "3", "1"))
  expect_identical(nrow(x), resAll |> dplyr::inner_join(x, by = colnames(x)) |> nrow())

  # records per person
  expect_identical(
    resAll |>
      dplyr::filter(
        variable_name == "records per person", estimate_name == "mean") |>
      dplyr::pull("estimate_value"),
    "2"
  )

  # duration
  expect_identical(
    resAll |>
      dplyr::filter(variable_name == "duration", estimate_name == "mean") |>
      dplyr::pull("estimate_value"),
    as.character(c(
      mean(c(20, 6, 113, 144, 18, 9, 29, 276)), mean(c(20, 18, 9, 276)),
      mean(c(6, 29, 144)), 113
    ))
  )

  # days to next observation period
  expect_identical(
    resAll |>
      dplyr::filter(variable_name == "days to next observation period", estimate_name == "mean") |>
      dplyr::pull("estimate_value"),
    as.character(c(
      mean(c(5, 32, 136, 26)), mean(c(5, 32, 136)), 26, NA
    ))
  )

  # duration - density
  xx <- resAllD |>
    dplyr::filter(variable_name == "duration", !is.na(variable_level)) |>
    dplyr::group_by(strata_level) |>
    dplyr::summarise(
      n = dplyr::n(),
      area = sum(as.numeric(estimate_value[estimate_name == "y"])) * (
        max(as.numeric(estimate_value[estimate_name == "x"])) -
          min(as.numeric(estimate_value[estimate_name == "x"]))
        )/(nPoints - 1)
    )
  expect_identical(xx$n |> unique(), as.integer(nPoints*2))
  expect_identical(xx$area |> round(2) |> unique(), 1)

  # days to next observation period - density
  xx <- resAllD |>
    dplyr::filter(variable_name == "days to next observation period",
                  !is.na(variable_level)) |>
    dplyr::group_by(strata_level) |>
    dplyr::summarise(
      n = dplyr::n(),
      area = sum(as.numeric(estimate_value[estimate_name == "y"])) * (
        max(as.numeric(estimate_value[estimate_name == "x"])) -
          min(as.numeric(estimate_value[estimate_name == "x"]))
      )/(nPoints - 1)
    )
  expect_identical(xx$n |> unique() , as.integer(nPoints*2))
  expect_identical(xx$area[xx$strata_level != "3"] |> round(2) |> unique(), 1)

  # only one exposure per individual
  cdm$observation_period <- cdm$observation_period |>
    dplyr::group_by(person_id) |>
    dplyr::filter(observation_period_id == min(observation_period_id, na.rm = TRUE)) |>
    dplyr::ungroup() |>
    dplyr::compute(name = "observation_period", temporary = FALSE)

  expect_no_error(resOne <- summariseObservationPeriod(cdm$observation_period))
  expect_no_error(
    resOneD <- summariseObservationPeriod(cdm$observation_period, density = TRUE))

  # counts
  expect_identical(resOne$estimate_value[resOne$variable_name == "number records"], "4")
  x <- dplyr::tibble(
    strata_level = c("overall", "1st"),
    variable_name = "number subjects",
    estimate_value = c("4", "4"))
  expect_identical(nrow(x), resOne |> dplyr::inner_join(x, by = colnames(x)) |> nrow())

  # Check result type
  checkResultType(resOneD, "summarise_observation_period")

  # empty observation period
  cdm$observation_period <- cdm$observation_period |>
    dplyr::filter(person_id == 0) |>
    dplyr::compute(name = "observation_period", temporary = FALSE)

  expect_no_error(resEmpty <- summariseObservationPeriod(cdm$observation_period))
  expect_no_error(
    resEmptyD <- summariseObservationPeriod(cdm$observation_period, density = TRUE))
  expect_true(nrow(resEmpty) == 2)
  expect_identical(unique(resEmpty$estimate_value), "0")

  expect_false(identical(resEmpty, resEmptyD))
  expect_identical(removeSettings(resEmpty), removeSettings(resEmptyD))

  # table works
  expect_no_error(tableObservationPeriod(resAll))
  expect_no_error(tableObservationPeriod(resOne))
  expect_no_error(tableObservationPeriod(resEmpty))

  # plot works
  expect_no_error(plotObservationPeriod(resAll))
  expect_no_error(plotObservationPeriod(resOne))
  expect_no_error(plotObservationPeriod(resEmpty))

  # check all plots combinations
  expect_no_error(
    resAll |>
      plotObservationPeriod(
        variableName = "number subjects", plotType = "barplot")
  )
  expect_error(
    resAll |>
      plotObservationPeriod(
        variableName = "number subjects", plotType = "boxplot")
  )
  expect_error(
    resAll |>
      plotObservationPeriod(
        variableName = "number subjects", plotType = "densityplot")
  )
  expect_error(
    resAll |>
      plotObservationPeriod(
        variableName = "number subjects", plotType = "random")
  )
  expect_error(
    resAll |>
      plotObservationPeriod(
        variableName = "duration", plotType = "barplot")
  )
  expect_no_error(
    resAll |>
      plotObservationPeriod(
        variableName = "duration", plotType = "boxplot")
  )
  expect_error(
    resAll |>
      plotObservationPeriod(
        variableName = "duration", plotType = "densityplot")
  )
  expect_no_error(
    resAllD |>
      plotObservationPeriod(
        variableName = "duration", plotType = "densityplot")
  )
  expect_error(
    resAll |>
      plotObservationPeriod(
        variableName = "duration", plotType = "random")
  )
  expect_error(
    resAll |>
      plotObservationPeriod(
        variableName = "records per person", plotType = "barplot")
  )
  expect_no_error(
    resAll |>
      plotObservationPeriod(
        variableName = "records per person", plotType = "boxplot")
  )
  expect_error(
    resAll |>
      plotObservationPeriod(
        variableName = "records per person", plotType = "densityplot")
  )
  expect_no_error(
    resAllD |>
      plotObservationPeriod(
        variableName = "records per person", plotType = "densityplot")
  )
  expect_error(
    resAll |>
      plotObservationPeriod(
        variableName = "records per person", plotType = "random")
  )
  expect_error(
    resAll |>
      plotObservationPeriod(
        variableName = "days to next observation period", plotType = "barplot")
  )
  expect_no_error(
    resAll |>
      plotObservationPeriod(
        variableName = "days to next observation period", plotType = "boxplot")
  )
  expect_error(
    resAll |>
      plotObservationPeriod(
        variableName = "days to next observation period", plotType = "densityplot")
  )
  expect_no_error(
    resAllD |>
      plotObservationPeriod(
        variableName = "days to next observation period", plotType = "densityplot")
  )
  expect_error(
    resAll |>
      plotObservationPeriod(
        variableName = "days to next observation period", plotType = "random")
  )

  PatientProfiles::mockDisconnect(cdm = cdm)
})
