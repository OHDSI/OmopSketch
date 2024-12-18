
domainsTibble <- dplyr::tribble(
  ~"domain_id", ~"table",
  "visit", "visit_occurrence",
  "specimen", "specimen",
  "condition", "condition_occurrence",
  "drug", "drug_exposure",
  "procedure", "procedure_occurrence",
  "device", "device_exposure",
  "measurement", "measurement",
  "observation", "observation"
)

conceptTypes <- read.csv(here::here("data-raw", "conceptTypes.csv")) |>
  dplyr::as_tibble() |>
  dplyr::mutate(
    type_concept = as.integer(.data$type_concept),
    type_name = as.character(.data$type_name)
  )

usethis::use_data(domainsTibble, conceptTypes, overwrite = TRUE, internal = TRUE)
