
#' Creates a mock database to test OmopSketch package
#'
#' `r lifecycle::badge('deprecated')`
#'
#' @param numberIndividuals Number of individuals to create in the cdm
#' reference object.
#' @param con deprecated.
#' @param writeSchema deprecated.
#' @param seed deprecated.
#'
#' @return A mock cdm_reference object.
#' @export
#'
mockOmopSketch <- function(numberIndividuals = 100,
                           con = lifecycle::deprecated(),
                           writeSchema = lifecycle::deprecated(),
                           seed = lifecycle::deprecated()) {
  rlang::check_installed("CDMConnector")

  lifecycle::deprecate_soft(
    when = "1.0.0",
    what = "OmopSketch::mockOmopSketch()",
    with = "omock::mockCdmFromDataset()"
  )
  if (lifecycle::is_present(seed)) {
    lifecycle::deprecate_soft(
      when = "1.0.0",
      what = "mockOmopSketch(seed)",
      with = "set.seed()"
    )
    set.seed(seed = seed)
  }
  if (lifecycle::is_present(con)) {
    lifecycle::deprecate_soft(
      when = "1.0.0",
      what = "mockOmopSketch(con)",
      with = "omopgenerics::insertCdmTo()"
    )
  }
  if (lifecycle::is_present(writeSchema)) {
    lifecycle::deprecate_soft(
      when = "1.0.0",
      what = "mockOmopSketch(writeSchema)",
      with = "omopgenerics::insertCdmTo()"
    )
  }

  # input check
  omopgenerics::assertNumeric(numberIndividuals, min = 1, length = 1)

  cdm <- omock::mockCdmReference(cdmName = "mockOmopSketch", vocabularySet = "GiBleed") |>
    omock::mockPerson(nPerson = numberIndividuals) |>
    omock::mockObservationPeriod() |>
    omock::mockConditionOccurrence() |>
    omock::mockDeath() |>
    omock::mockDrugExposure() |>
    omock::mockMeasurement() |>
    omock::mockObservation() |>
    omock::mockProcedureOccurrence() |>
    omock::mockVisitOccurrence() |>
    # TODO replace with omock::mockDeviceExposure
    omopgenerics::emptyOmopTable("device_exposure")

  # TODO remove when local datasets are supported
  to <- CDMConnector::dbSource(
    con = duckdb::dbConnect(drv = duckdb::duckdb()),
    writeSchema = "main"
  )
  cdm <- omopgenerics::insertCdmTo(cdm = cdm, to = to)

  return(cdm)
}


