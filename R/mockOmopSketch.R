
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
    omopgenerics::emptyOmopTable("device_exposure") |>
    checkColumns()

  # TODO remove when local datasets are supported
  to <- CDMConnector::dbSource(
    con = duckdb::dbConnect(drv = duckdb::duckdb()),
    writeSchema = "main"
  )
  cdm <- omopgenerics::insertCdmTo(cdm = cdm, to = to)

  return(cdm)
}

checkColumns <- function(cdm_local) {
  info <- omopgenerics::omopTableFields() |>
    dplyr::filter(.data$type == "cdm_table") |>
    dplyr::mutate(cdm_datatype = dplyr::case_when(
      .data$cdm_datatype == "integer" ~ "NA_integer_",
      grepl("varchar", .data$cdm_datatype) ~ "NA_character_",
      .default = "NA"
    ))
  for (table in names(cdm_local)) {
    cols <- info |>
      dplyr::filter(.data$cdm_table_name == .env$table) |>
      dplyr::select("cdm_field_name", "cdm_datatype")

    missing_cols <- cols |>
      dplyr::filter(!(.data$cdm_field_name %in% colnames(cdm_local[[table]])))

    if (nrow(missing_cols) > 0) {
      missing_tbl <- dplyr::tibble(
        !!!rlang::set_names(
          lapply(missing_cols$cdm_datatype, function(datatype) {
            eval(parse(text = datatype))
          }),
          missing_cols$cdm_field_name
        )
      )

      cdm_local[[table]] <- dplyr::bind_cols(cdm_local[[table]], missing_tbl)
    }
  }
  return(cdm_local)
}
