#' Creates a mock database to test OmopSketch package.
#'
#' @param con A DBI connection to create the cdm mock object. By default, the
#' connection would be a 'duckdb' one.
#' @param writeSchema Name of an schema of the DBI connection with writing
#' permissions.
#' @param numberIndividuals Number of individuals to create in the cdm
#' reference object.
#'
#' @return A mock cdm_reference object.
#' @export
#'
#' @examples
#' mockOmopSketch(numberIndividuals = 1000)
#'
mockOmopSketch <- function(con = NULL,
                           writeSchema = NULL,
                           numberIndividuals = 100){

  omopgenerics::assertNumeric(numberIndividuals, min = 1, length = 1)

  if (is.null(con)) {
    # TO BE REMOVED WHEN WE SUPPORT LOCAL CDMs
    rlang::check_installed("duckdb")
    con <- duckdb::dbConnect(duckdb::duckdb(), ":memory:")
  }

  if (!inherits(con, "DBIConnection")) {
    cli::cli_abort(c("!" = "`con` must be a DBI connection"))
  }
  if (is.null(writeSchema) & inherits(con, "duckdb_connection")) {
    # TO BE REMOVED WHEN WE SUPPORT LOCAL CDMs
    writeSchema <- "main"
  }

  cdm <- omock::emptyCdmReference(cdmName = "mockOmopSketch") |>
    omock::mockPerson(nPerson = numberIndividuals) |>
    omock::mockObservationPeriod() |>
    omock::mockVocabularyTables() |>
    omock::mockConditionOccurrence() |>
    omock::mockDeath() |>
    omock::mockDrugExposure() |>
    omock::mockMeasurement() |>
    omock::mockObservation() |>
    omock::mockProcedureOccurrence() |>
    omock::mockVisitOccurrence() |>
    # Create device exposure table - empty (Eunomia also has it empty)
    omopgenerics::emptyOmopTable("device_exposure")

  # WHEN WE SUPORT LOCAL CDMs WE WILL HAVE TO ACCOUNT FOR THAT HERE
  cdm <- CDMConnector::copy_cdm_to(con = con, cdm = cdm, schema = writeSchema)

  return(cdm)
}
