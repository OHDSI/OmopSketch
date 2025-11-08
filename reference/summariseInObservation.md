# Summarise the number of people in observation during a specific interval of time. **\[deprecated\]**

Summarise the number of people in observation during a specific interval
of time. **\[deprecated\]**

## Usage

``` r
summariseInObservation(
  observationPeriod,
  interval = "overall",
  output = "record",
  ageGroup = NULL,
  sex = FALSE,
  dateRange = NULL
)
```

## Arguments

- observationPeriod:

  An observation_period omop table. It must be part of a cdm_reference
  object.

- interval:

  Time interval to stratify by. It can either be "years", "quarters",
  "months" or "overall".

- output:

  Output format. It can be either the number of records ("record") that
  are in observation in the specific interval of time, the number of
  person-days ("person-days"), the number of subjects ("person"), the
  number of females ("sex") or the median age of population in
  observation ("age").

- ageGroup:

  A list of age groups to stratify results by.

- sex:

  Boolean variable. Whether to stratify by sex (TRUE) or not (FALSE).
  For output = "sex" this stratification is not applied.

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
library(dplyr, warn.conflicts = FALSE)
library(OmopSketch)

cdm <- mockOmopSketch()
#> ℹ Reading GiBleed tables.

result <- summariseInObservation(
  observationPeriod = cdm$observation_period,
  interval = "months",
  output = c("person-days", "record"),
  ageGroup = list("<=60" = c(0, 60), ">60" = c(61, Inf)),
  sex = TRUE
)

result |>
  glimpse()
#> Rows: 17,464
#> Columns: 13
#> $ result_id        <int> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,…
#> $ cdm_name         <chr> "mockOmopSketch", "mockOmopSketch", "mockOmopSketch",…
#> $ group_name       <chr> "omop_table", "omop_table", "omop_table", "omop_table…
#> $ group_level      <chr> "observation_period", "observation_period", "observat…
#> $ strata_name      <chr> "overall", "age_group", "sex", "sex &&& age_group", "…
#> $ strata_level     <chr> "overall", "<=60", "Female", "Female &&& <=60", "over…
#> $ variable_name    <chr> "Number of records", "Number of records", "Number of …
#> $ variable_level   <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
#> $ estimate_name    <chr> "count", "count", "count", "count", "count", "count",…
#> $ estimate_type    <chr> "integer", "integer", "integer", "integer", "integer"…
#> $ estimate_value   <chr> "1", "1", "1", "1", "25", "25", "25", "25", "1.00", "…
#> $ additional_name  <chr> "time_interval", "time_interval", "time_interval", "t…
#> $ additional_level <chr> "1956-03-01 to 1956-03-31", "1956-03-01 to 1956-03-31…

PatientProfiles::mockDisconnect(cdm)
# }
```
