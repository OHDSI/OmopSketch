#' Creates a mock database to test OmopSketch package.
#'
#' @param con A DBI connection to create the cdm mock object. By default, the
#' connection would be a 'duckdb' one.
#' @param writeSchema Name of an schema of the DBI connection with writing
#' permissions.
#' @param numberIndividuals Number of individuals to create in the cdm
#' reference object.
#' @param seed An optional integer used to set the seed for random number
#' generation, ensuring reproducibility of the generated data. If provided, this
#' seed allows the function to produce consistent results each time it is run
#' with the same inputs. If 'NULL', the seed is not set, which can lead to
#' different outputs on each run.
#' @return A mock cdm_reference object.
#' @export
#' @examples
#' mockOmopSketch(numberIndividuals = 100)
mockOmopSketch <- function(con = NULL,
                           writeSchema = NULL,
                           numberIndividuals = 100,
                           seed = NULL) {

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
    omock::mockPerson(nPerson = numberIndividuals, seed = seed) |>
    omock::mockObservationPeriod(seed = seed) |>
    omock::mockVocabularyTables() |>
    omock::mockConditionOccurrence(seed = seed) |>
    omock::mockDeath(seed = seed) |>
    omock::mockDrugExposure(seed = seed) |>
    omock::mockMeasurement(seed = seed) |>
    omock::mockObservation(seed = seed) |>
    omock::mockProcedureOccurrence(seed = seed) |>
    omock::mockVisitOccurrence(seed = seed) |>
    # Create device exposure table - empty (Eunomia also has it empty)
    omopgenerics::emptyOmopTable("device_exposure")

  # WHEN WE SUPORT LOCAL CDMs WE WILL HAVE TO ACCOUNT FOR THAT HERE
  cdm <- CDMConnector::copy_cdm_to(con = con, cdm = cdm, schema = writeSchema)

  return(cdm)
}
