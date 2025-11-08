# Summarise an omop table from a cdm object. You will obtain information related to the number of records, number of subjects, whether the records are in observation, number of present domains, number of present concepts, missing data and inconsistencies in start date and end date

Summarise an omop table from a cdm object. You will obtain information
related to the number of records, number of subjects, whether the
records are in observation, number of present domains, number of present
concepts, missing data and inconsistencies in start date and end date

## Usage

``` r
summariseClinicalRecords(
  cdm,
  omopTableName,
  recordsPerPerson = c("mean", "sd", "median", "q25", "q75", "min", "max"),
  conceptSummary = TRUE,
  missingData = TRUE,
  quality = TRUE,
  sex = FALSE,
  ageGroup = NULL,
  dateRange = NULL,
  inObservation = lifecycle::deprecated(),
  standardConcept = lifecycle::deprecated(),
  sourceVocabulary = lifecycle::deprecated(),
  domainId = lifecycle::deprecated(),
  typeConcept = lifecycle::deprecated()
)
```

## Arguments

- cdm:

  A cdm_reference object.

- omopTableName:

  A character vector of the names of the tables to summarise in the cdm
  object. Run
  [`OmopSketch::clinicalTables()`](https://OHDSI.github.io/OmopSketch/reference/clinicalTables.md)
  to check the available options.

- recordsPerPerson:

  Generates summary statistics for the number of records per person. Set
  to NULL if no summary statistics are required.

- conceptSummary:

  Logical. If `TRUE`, includes summaries of concept-level information,
  including:

  - Domain ID of standard concepts

  - Type concept ID

  - Standard vs non-standard concepts

  - Source vocabulary usage

- missingData:

  Logical. If `TRUE`, includes a summary of missing data for relevant
  fields.

- quality:

  Logical. If `TRUE`, performs basic data quality checks, including:

  - Percentage of records within the observation period

  - Number of records with end date before start date

  - Number of records with start date before the person's birth date

- sex:

  Boolean variable. Whether to stratify by sex (TRUE) or not (FALSE).

- ageGroup:

  A list of age groups to stratify results by.

- dateRange:

  A vector of two dates defining the desired study period. Only the
  `start_date` column of the OMOP table is checked to ensure it falls
  within this range. If `dateRange` is `NULL`, no restriction is
  applied.

- inObservation:

  Deprecated. Use `quality = TRUE` instead.

- standardConcept:

  Deprecated. Use `conceptSummary = TRUE` instead.

- sourceVocabulary:

  Deprecated. Use `conceptSummary = TRUE` instead.

- domainId:

  Deprecated. Use `conceptSummary = TRUE` instead.

- typeConcept:

  Deprecated. Use `conceptSummary = TRUE` instead.

## Value

A summarised_result object.

## Examples

``` r
# \donttest{
library(OmopSketch)

cdm <- mockOmopSketch()
#> ℹ Reading GiBleed tables.

summarisedResult <- summariseClinicalRecords(
  cdm = cdm,
  omopTableName = "condition_occurrence",
  recordsPerPerson = c("mean", "sd"),
  quality = TRUE,
  conceptSummary = TRUE,
  missingData = TRUE
)
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

summarisedResult
#> # A tibble: 71 × 13
#>    result_id cdm_name       group_name group_level      strata_name strata_level
#>        <int> <chr>          <chr>      <chr>            <chr>       <chr>       
#>  1         1 mockOmopSketch omop_table condition_occur… overall     overall     
#>  2         1 mockOmopSketch omop_table condition_occur… overall     overall     
#>  3         1 mockOmopSketch omop_table condition_occur… overall     overall     
#>  4         1 mockOmopSketch omop_table condition_occur… overall     overall     
#>  5         1 mockOmopSketch omop_table condition_occur… overall     overall     
#>  6         1 mockOmopSketch omop_table condition_occur… overall     overall     
#>  7         1 mockOmopSketch omop_table condition_occur… overall     overall     
#>  8         1 mockOmopSketch omop_table condition_occur… overall     overall     
#>  9         1 mockOmopSketch omop_table condition_occur… overall     overall     
#> 10         1 mockOmopSketch omop_table condition_occur… overall     overall     
#> # ℹ 61 more rows
#> # ℹ 7 more variables: variable_name <chr>, variable_level <chr>,
#> #   estimate_name <chr>, estimate_type <chr>, estimate_value <chr>,
#> #   additional_name <chr>, additional_level <chr>

CDMConnector::cdmDisconnect(cdm = cdm)
# }
```
