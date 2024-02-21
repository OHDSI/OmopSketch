
# individuals in observation by year,
# new observation periods by year

summariseObservationPeriod <- function(observationPeriod) {
  checkmate::assertClass(observationPeriod, "omop_table")
  x <- omopgenerics::tableName(observationPeriod)
  if (x != "observation_period") {
    cli::cli_abort(
      "Table name ({x}) is not observation_period, please provide a valid
      observation_period table"
    )
  }

  observationPeriod |>
    dplyr::summarise(
      "number_records" = dplyr::n(),
      "number_subjects" = dplyr::n_distinct(.data$subject_id)
    )

  observationPeriod %>%
    dplyr::select("year" = !!CDMConnector::datepart("observation_period_start_date")) |>
    dplyr::group_by(.data$year) |>
    dplyr::tally()

  observationPeriod %>%
    dplyr::select("year" = !!CDMConnector::datepart("observation_period_end_date")) |>
    dplyr::group_by(.data$year) |>
    dplyr::tally()

}
