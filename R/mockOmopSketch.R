#' It creates a mock database for testing OmopSketch package
#'
#' @param con A DBI connection to create the cdm mock object. By default, the connection would be "duckdb".
#' @param writeSchema Name of an schema on the same connection with writing permissions.
#' @param numberIndividuals Number of individuals to create in the cdm reference.
#'
#' @return A mock cdm_reference object created following user's specifications.
#' @export
#'
#' @examples
#' \donttest{
#' mockOmopSketch(numberIndividuals = 1000,
#'                writeSchema = NULL,
#'                con = NULL)
#' }
mockOmopSketch <- function(con = NULL,
                           writeSchema = NULL,
                           numberIndividuals = 100){

  if (is.null(con)) {
    rlang::check_installed("duckdb")
    con <- duckdb::dbConnect(duckdb::duckdb(), ":memory:")
  }

  if (!inherits(con, "DBIConnection")) {
    cli::cli_abort(c("!" = "`con` must be a DBI connection"))
  }
  if (is.null(writeSchema) & inherits(con, "duckdb_connection")) {
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
    omock::mockProcedureOccurrence()

  # Create device exposure table - empty (Eunomia also has it empty)
  cdm <- omopgenerics::emptyOmopTable(cdm, "device_exposure")

  # Create visit_occurrence table
  cdm <- omopgenerics::emptyOmopTable(cdm, "visit_occurrence")
  cdm$visit_occurrence <- cdm$visit_occurrence |>
    dplyr::full_join(
      cdm$condition_occurrence |>
        dplyr::select(
          "person_id",
          "visit_start_date" = "condition_start_date"
        ) |>
        dplyr::union_all(
          cdm$drug_exposure |>
            dplyr::select(
              "person_id",
              "visit_start_date" = "drug_exposure_start_date"
            )
        ) |>
        dplyr::mutate(
          "visit_occurrence_id" = dplyr::row_number(),
          "visit_concept_id" = 9201,
          "visit_end_date" = .data$visit_start_date,
          "visit_type_concept_id" = 44818517
        ) |>
        dplyr::select("visit_occurrence_id", "person_id", "visit_concept_id", "visit_start_date",
                      "visit_end_date", "visit_type_concept_id"),
      by = c("person_id","visit_start_date","visit_occurrence_id","visit_concept_id",
             "visit_end_date","visit_type_concept_id")

    )

  cdm <- CDMConnector::copy_cdm_to(con = con, cdm = cdm, schema = writeSchema)

  return(cdm)
}
