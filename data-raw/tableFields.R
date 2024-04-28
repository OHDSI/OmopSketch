
tables <- dplyr::tribble(
  ~"table_name", ~"start_date", ~"end_date", ~"standard_concept", ~"source_concept", ~"type_concept", ~"id",
  "observation_period", "observation_period_start_date", "observation_period_end_date", NA, NA, "period_type_concept_id", "observation_period_id",
  "visit_occurrence", "visit_start_date", "visit_end_date", "visit_concept_id", "visit_source_concept_id", "visit_type_concept_id", "visit_occurrence_id",
  "condition_occurrence", "condition_start_date", "condition_end_date", "condition_concept_id", "condition_source_concept_id", "condition_type_concept_id", "condition_occurrence_id",
  "drug_exposure", "drug_exposure_start_date", "drug_exposure_end_date", "drug_concept_id", "drug_source_concept_id", "drug_type_concept_id", "drug_exposure_id",
  "procedure_occurrence", "procedure_date", "procedure_date", "procedure_concept_id", "procedure_source_concept_id", "procedure_type_concept_id", "procedure_occurrence_id",
  "device_exposure", "device_exposure_start_date", "device_exposure_end_date", "device_concept_id", "device_source_concept_id", "device_type_concept_id", "device_exposure_id",
  "measurement", "measurement_date", "measurement_date", "measurement_concept_id", "measurement_source_concept_id", "measurement_type_concept_id", "measurement_id",
  "observation", "observation_date", "observation_date", "observation_concept_id", "observation_source_concept_id", "observation_type_concept_id", "observation_id",
  "death", "death_date", "death_date", "cause_concept_id", "cause_source_concept_id", "death_type_concept_id", "person_id"
)

conceptTypes <- read.csv(here::here("data-raw", "conceptTypes.csv")) |>
  dplyr::as_tibble() |>
  dplyr::mutate(dplyr::across(dplyr::everything(), as.character))

usethis::use_data(tables, conceptTypes, overwrite = TRUE, internal = TRUE)
