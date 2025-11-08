# Summarise Database Characteristics for OMOP CDM

Summarise Database Characteristics for OMOP CDM

## Usage

``` r
databaseCharacteristics(
  cdm,
  omopTableName = c("visit_occurrence", "visit_detail", "condition_occurrence",
    "drug_exposure", "procedure_occurrence", "device_exposure", "measurement",
    "observation", "death"),
  sample = NULL,
  sex = FALSE,
  ageGroup = NULL,
  dateRange = NULL,
  interval = "overall",
  conceptIdCounts = FALSE,
  ...
)
```

## Arguments

- cdm:

  A `cdm_reference` object representing the Common Data Model (CDM)
  reference.

- omopTableName:

  A character vector of the names of the tables to summarise in the cdm
  object. Run
  [`OmopSketch::clinicalTables()`](https://OHDSI.github.io/OmopSketch/reference/clinicalTables.md)
  to check the available options.

- sample:

  Either an integer or a character string. If an integer (n \> 0), the
  function will first sample `n` distinct `person_id`s from the `person`
  table and then subset the input tables to those subjects. If a
  character string, it must be the name of a cohort in the `cdm`; in
  this case, the input tables are subset to subjects (`subject_id`)
  belonging to that cohort. Use `NULL` to disable subsetting (default
  value).

- sex:

  Logical; whether to stratify results by sex (`TRUE`) or not (`FALSE`).

- ageGroup:

  A list of age groups to stratify the results by. Each element
  represents a specific age range.

- dateRange:

  A vector of two dates defining the desired study period. Only the
  `start_date` column of the OMOP table is checked to ensure it falls
  within this range. If `dateRange` is `NULL`, no restriction is
  applied.

- interval:

  Time interval to stratify by. It can either be "years", "quarters",
  "months" or "overall".

- conceptIdCounts:

  Logical; whether to summarise concept ID counts (`TRUE`) or not
  (`FALSE`).

- ...:

  additional arguments passed to the OmopSketch functions that are used
  internally.

## Value

A `summarised_result` object containing the results of the
characterisation.

## Examples

``` r
# \donttest{
library(OmopSketch)

cdm <- mockOmopSketch(numberIndividuals = 100)
#> ℹ Reading GiBleed tables.

result <- databaseCharacteristics(
  cdm = cdm,
  omopTableName = c("drug_exposure", "condition_occurrence"),
  sex = TRUE, ageGroup = list(c(0, 50), c(51, 100)), interval = "years", conceptIdCounts = FALSE
)
#> The characterisation will focus on the following OMOP tables: drug_exposure and
#> condition_occurrence
#> → Getting cdm snapshot
#> → Getting population characteristics
#> ℹ Building new trimmed cohort
#> Adding demographics information
#> Creating initial cohort
#> Trim sex
#> ✔ Cohort trimmed
#> ℹ Building new trimmed cohort
#> Adding demographics information
#> Creating initial cohort
#> Trim sex
#> Trim age
#> ✔ Cohort trimmed
#> ℹ adding demographics columns
#> ℹ summarising data
#> ℹ summarising cohort general_population
#> ℹ summarising cohort age_group_0_50
#> ℹ summarising cohort age_group_51_100
#> ✔ summariseCharacteristics finished!
#> → Summarising person table
#> → Summarising clinical records
#> ℹ Adding variables of interest to drug_exposure.
#> ℹ Summarising records per person in drug_exposure.
#> ℹ Summarising subjects not in person table in drug_exposure.
#> ℹ Summarising records in observation in drug_exposure.
#> ℹ Summarising records with start before birth date in drug_exposure.
#> ℹ Summarising records with end date before start date in drug_exposure.
#> ℹ Summarising domains in drug_exposure.
#> ℹ Summarising standard concepts in drug_exposure.
#> ℹ Summarising source vocabularies in drug_exposure.
#> ℹ Summarising concept types in drug_exposure.
#> ℹ Summarising concept class in drug_exposure.
#> ℹ Summarising missing data in drug_exposure.
#> ℹ Adding variables of interest to condition_occurrence.
#> ℹ Summarising records per person in condition_occurrence.
#> ℹ Summarising subjects not in person table in condition_occurrence.
#> ℹ Summarising records in observation in condition_occurrence.
#> ℹ Summarising records with start before birth date in condition_occurrence.
#> ℹ Summarising records with end date before start date in condition_occurrence.
#> ℹ Summarising domains in condition_occurrence.
#> ℹ Summarising standard concepts in condition_occurrence.
#> ℹ Summarising source vocabularies in condition_occurrence.
#> ℹ Summarising concept types in condition_occurrence.
#> ℹ Summarising missing data in condition_occurrence.
#> → Summarising observation period
#> → Summarising trends: records, subjects, person-days, age and sex
#> → The number of person-days is not computed for event tables
#> ☺ Database characterisation finished. Code ran in 1 min and 4 sec
#> ℹ 1 table created: "og_011_1762635280".

PatientProfiles::mockDisconnect(cdm)
#> Warning: `mockDisconnect()` was deprecated in PatientProfiles 1.4.3.
# }
```
