# Summarise concept use in patient-level data. Only concepts recorded during observation period are counted.

Summarise concept use in patient-level data. Only concepts recorded
during observation period are counted.

## Usage

``` r
summariseConceptIdCounts(
  cdm,
  omopTableName,
  countBy = "record",
  year = lifecycle::deprecated(),
  interval = "overall",
  sex = FALSE,
  ageGroup = NULL,
  inObservation = FALSE,
  sample = NULL,
  dateRange = NULL
)
```

## Arguments

- cdm:

  A cdm object

- omopTableName:

  A character vector of the names of the tables to summarise in the cdm
  object.

- countBy:

  Either "record" for record-level counts or "person" for person-level
  counts

- year:

  deprecated

- interval:

  Time interval to stratify by. It can either be "years", "quarters",
  "months" or "overall".

- sex:

  TRUE or FALSE. If TRUE code use will be summarised by sex.

- ageGroup:

  A list of ageGroup vectors of length two. Code use will be thus
  summarised by age groups.

- inObservation:

  Logical. If `TRUE`, the results are stratified to indicate whether
  each record occurs within an observation period.

- sample:

  Either an integer or a character string. If an integer (n \> 0), the
  function will first sample `n` distinct `person_id`s from the `person`
  table and then subset the input tables to those subjects. If a
  character string, it must be the name of a cohort in the `cdm`; in
  this case, the input tables are subset to subjects (`subject_id`)
  belonging to that cohort. Use `NULL` to disable subsetting (default
  value).

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
library(CDMConnector)
library(duckdb)

requireEunomia()
#> ℹ `EUNOMIA_DATA_FOLDER` set to: /tmp/Rtmpt3C1Ob.
#> 
#> Download completed!
con <- dbConnect(duckdb(), eunomiaDir())
#> Creating CDM database /tmp/Rtmpt3C1Ob/GiBleed_5.3.zip
cdm <- cdmFromCon(con = con, cdmSchema = "main", writeSchema = "main")

summariseConceptIdCounts(
  cdm = cdm,
  omopTableName = "condition_occurrence",
  countBy = c("record", "person"),
  sex = TRUE
)
#> # A tibble: 476 × 13
#>    result_id cdm_name group_name group_level          strata_name strata_level
#>        <int> <chr>    <chr>      <chr>                <chr>       <chr>       
#>  1         1 Synthea  omop_table condition_occurrence overall     overall     
#>  2         1 Synthea  omop_table condition_occurrence overall     overall     
#>  3         1 Synthea  omop_table condition_occurrence overall     overall     
#>  4         1 Synthea  omop_table condition_occurrence overall     overall     
#>  5         1 Synthea  omop_table condition_occurrence overall     overall     
#>  6         1 Synthea  omop_table condition_occurrence overall     overall     
#>  7         1 Synthea  omop_table condition_occurrence overall     overall     
#>  8         1 Synthea  omop_table condition_occurrence overall     overall     
#>  9         1 Synthea  omop_table condition_occurrence overall     overall     
#> 10         1 Synthea  omop_table condition_occurrence overall     overall     
#> # ℹ 466 more rows
#> # ℹ 7 more variables: variable_name <chr>, variable_level <chr>,
#> #   estimate_name <chr>, estimate_type <chr>, estimate_value <chr>,
#> #   additional_name <chr>, additional_level <chr>
# }
```
