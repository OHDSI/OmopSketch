# Summarise missing data in omop tables

Summarise missing data in omop tables

## Usage

``` r
summariseMissingData(
  cdm,
  omopTableName,
  col = NULL,
  sex = FALSE,
  year = lifecycle::deprecated(),
  interval = "overall",
  ageGroup = NULL,
  sample = 1e+05,
  dateRange = NULL
)
```

## Arguments

- cdm:

  A cdm object

- omopTableName:

  A character vector of the names of the tables to summarise in the cdm
  object.

- col:

  A character vector of column names to check for missing values. If
  `NULL`, all columns in the specified tables are checked. Default is
  `NULL`.

- sex:

  TRUE or FALSE. If TRUE code use will be summarised by sex.

- year:

  deprecated

- interval:

  Time interval to stratify by. It can either be "years", "quarters",
  "months" or "overall".

- ageGroup:

  A list of ageGroup vectors of length two. Code use will be thus
  summarised by age groups.

- sample:

  Either an integer or a character string. If an integer (n \> 0), the
  function will first sample `n` distinct `person_id`s from the `person`
  table and then subset the input tables to those subjects. If a
  character string, it must be the name of a cohort in the `cdm`; in
  this case, the input tables are subset to subjects (`subject_id`)
  belonging to that cohort. Use `NULL` to disable subsetting. By default
  `sample = 100000`

- dateRange:

  A vector of two dates defining the desired study period. Only the
  `start_date` column of the OMOP table is checked to ensure it falls
  within this range. If `dateRange` is `NULL`, no restriction is
  applied.

## Value

A summarised_result object with results overall and, if specified, by
strata.

## Examples

``` r
# \donttest{
library(OmopSketch)

cdm <- mockOmopSketch(numberIndividuals = 100)
#> ℹ Reading GiBleed tables.

result <- summariseMissingData(
  cdm = cdm,
  omopTableName = c("condition_occurrence", "visit_occurrence"),
  sample = 10000
)
#> The person table has ≤ 10000 subjects; skipping sampling of the CDM.
#> The person table has ≤ 10000 subjects; skipping sampling of the CDM.

PatientProfiles::mockDisconnect(cdm)
# }
```
