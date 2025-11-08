# Summarise record counts of an omop_table using a specific time interval. Only records that fall within the observation period are considered.

**\[deprecated\]**

## Usage

``` r
summariseRecordCount(
  cdm,
  omopTableName,
  interval = "overall",
  ageGroup = NULL,
  sex = FALSE,
  sample = NULL,
  dateRange = NULL
)
```

## Arguments

- cdm:

  A cdm_reference object.

- omopTableName:

  A character vector of omop tables from the cdm.

- interval:

  Time interval to stratify by. It can either be "years", "quarters",
  "months" or "overall".

- ageGroup:

  A list of age groups to stratify results by.

- sex:

  Whether to stratify by sex (TRUE) or not (FALSE).

- sample:

  An integer to sample the tables to only that number of records. If
  NULL no sample is done.

- dateRange:

  A vector of two dates defining the desired study period. Only the
  `start_date` column of the OMOP table is checked to ensure it falls
  within this range. If `dateRange` is `NULL`, no restriction is
  applied.

## Value

A summarised_result object.

## Examples

``` r
# \donttest{
library(OmopSketch)
library(dplyr, warn.conflicts = FALSE)

cdm <- mockOmopSketch()
#> ℹ Reading GiBleed tables.

summarisedResult <- summariseRecordCount(
  cdm = cdm,
  omopTableName = c("condition_occurrence", "drug_exposure"),
  interval = "years",
  ageGroup = list("<=20" = c(0, 20), ">20" = c(21, Inf)),
  sex = TRUE
)

summarisedResult |>
  glimpse()
#> Rows: 1,952
#> Columns: 13
#> $ result_id        <int> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,…
#> $ cdm_name         <chr> "mockOmopSketch", "mockOmopSketch", "mockOmopSketch",…
#> $ group_name       <chr> "omop_table", "omop_table", "omop_table", "omop_table…
#> $ group_level      <chr> "drug_exposure", "drug_exposure", "drug_exposure", "d…
#> $ strata_name      <chr> "overall", "age_group", "sex", "sex &&& age_group", "…
#> $ strata_level     <chr> "overall", "<=20", "Male", "Male &&& <=20", "overall"…
#> $ variable_name    <chr> "Number of records", "Number of records", "Number of …
#> $ variable_level   <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
#> $ estimate_name    <chr> "count", "count", "count", "count", "percentage", "pe…
#> $ estimate_type    <chr> "integer", "integer", "integer", "integer", "percenta…
#> $ estimate_value   <chr> "2", "2", "2", "2", "0.01", "0.01", "0.01", "0.01", "…
#> $ additional_name  <chr> "time_interval", "time_interval", "time_interval", "t…
#> $ additional_level <chr> "1961-01-01 to 1961-12-31", "1961-01-01 to 1961-12-31…

CDMConnector::cdmDisconnect(cdm = cdm)
# }
```
