# Summarise temporal trends in OMOP tables

This function summarises temporal trends from OMOP CDM tables,
considering only data within the observation period. It supports both
event and episode tables and can report trends such as number of
records, number of subjects, person-days, median age, and number of
females.

## Usage

``` r
summariseTrend(
  cdm,
  event = NULL,
  episode = NULL,
  output = "record",
  interval = "overall",
  ageGroup = NULL,
  sex = FALSE,
  inObservation = FALSE,
  dateRange = NULL
)
```

## Arguments

- cdm:

  A `cdm_reference` object.

- event:

  A character vector of OMOP table names to treat as event tables (uses
  only start date).

- episode:

  A character vector of OMOP table names to treat as episode tables
  (uses start and end date).

- output:

  A character vector indicating what to summarise. Options include
  `"record"` (default), `"person"`, `"person-days"`, `"age"`, `"sex"`.
  If included, the number of person-days is computed only for episode
  tables.

- interval:

  Time granularity for trends. One of `"overall"` (default), `"years"`,
  `"quarters"`, or `"months"`.

- ageGroup:

  A list of age groups to stratify results by.

- sex:

  Logical. If `TRUE`, stratify results by sex.

- inObservation:

  Logical. If `TRUE`, the results are stratified to indicate whether
  each record occurs within an observation period.

- dateRange:

  A vector of two dates defining the desired study period. If
  `dateRange` is `NULL`, no restriction is applied.

## Value

A summarised_result object.

## Details

- **Event tables**: Records are included if their **start date** falls
  within the study period. Each record contributes to the time interval
  containing the start date.

- **Episode tables**: Records are included if their **start or end
  date** overlaps with the study period. Records are **trimmed** to the
  date range, and contribute to **all** overlapping time intervals
  between start and end dates.

## Examples

``` r
# \donttest{
library(OmopSketch)

cdm <- mockOmopSketch()
#> ℹ Reading GiBleed tables.

summarisedResult <- summariseTrend(
  cdm = cdm,
  event = c("condition_occurrence", "drug_exposure"),
  episode = "observation_period",
  interval = "years",
  ageGroup = list("<=20" = c(0, 20), ">20" = c(21, Inf)),
  sex = TRUE,
  dateRange = as.Date(c("1950-01-01", "2010-12-31"))
)
#> → The observation period in the cdm starts in 1957-06-25

summarisedResult |>
  dplyr::glimpse()
#> Rows: 2,614
#> Columns: 13
#> $ result_id        <int> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2,…
#> $ cdm_name         <chr> "mockOmopSketch", "mockOmopSketch", "mockOmopSketch",…
#> $ group_name       <chr> "omop_table", "omop_table", "omop_table", "omop_table…
#> $ group_level      <chr> "condition_occurrence", "condition_occurrence", "cond…
#> $ strata_name      <chr> "overall", "age_group", "sex", "sex &&& age_group", "…
#> $ strata_level     <chr> "overall", "<=20", "Male", "Male &&& <=20", "overall"…
#> $ variable_name    <chr> "Number of records", "Number of records", "Number of …
#> $ variable_level   <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
#> $ estimate_name    <chr> "count", "count", "count", "count", "percentage", "pe…
#> $ estimate_type    <chr> "integer", "integer", "integer", "integer", "percenta…
#> $ estimate_value   <chr> "1", "1", "1", "1", "0.02", "0.02", "0.02", "0.02", "…
#> $ additional_name  <chr> "time_interval", "time_interval", "time_interval", "t…
#> $ additional_level <chr> "1957-01-01 to 1957-12-31", "1957-01-01 to 1957-12-31…

CDMConnector::cdmDisconnect(cdm = cdm)
# }
```
