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

usethis::use_data(domainsTibble, overwrite = TRUE, internal = TRUE)
