# Summarise the person table

## Introduction

In this vignette we will explore the *OmopSketch* functions designed to
provide a concise overview of the OMOP **person** table. Specifically
there are two small utilities that make this easy:

- [`summarisePerson()`](https://OHDSI.github.io/OmopSketch/reference/summarisePerson.md):
  computes a set of summary statistics and data-quality checks for the
  person table (total subjects, missing observation-period checks,
  sex/race/ethnicity distributions, birth-date components, and simple
  summaries for id-columns such as location_id, provider_id, and
  care_site_id).
- [`tablePerson()`](https://OHDSI.github.io/OmopSketch/reference/tablePerson.md):
  helps visualising the results in a formatted table.

### Create a mock cdm

Let’s load the required packages and create a mock CDM using
[`mockOmopSketch()`](https://OHDSI.github.io/OmopSketch/reference/mockOmopSketch.md)
so we can run the functions on a small example.

``` r
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union
library(OmopSketch)

# Connect to mock database
cdm <- mockOmopSketch()
#> ℹ Reading GiBleed tables.
```

## Summarise the person table

Run summarisePerson() to compute basic summaries for the person table.
The function will return a
[summarised_result](https://darwin-eu.github.io/omopgenerics/articles/summarised_result.html).

``` r
result <- summarisePerson(cdm = cdm)

result |> glimpse()
#> Rows: 61
#> Columns: 13
#> $ result_id        <int> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,…
#> $ cdm_name         <chr> "mockOmopSketch", "mockOmopSketch", "mockOmopSketch",…
#> $ group_name       <chr> "overall", "overall", "overall", "overall", "overall"…
#> $ group_level      <chr> "overall", "overall", "overall", "overall", "overall"…
#> $ strata_name      <chr> "overall", "overall", "overall", "overall", "overall"…
#> $ strata_level     <chr> "overall", "overall", "overall", "overall", "overall"…
#> $ variable_name    <chr> "Number subjects", "Number subjects not in observatio…
#> $ variable_level   <chr> NA, NA, NA, "Female", "Female", "Male", "Male", "None…
#> $ estimate_name    <chr> "count", "count", "percentage", "count", "percentage"…
#> $ estimate_type    <chr> "integer", "integer", "numeric", "integer", "numeric"…
#> $ estimate_value   <chr> "100", "0", "0", "57", "57", "43", "43", "0", "0", "1…
#> $ additional_name  <chr> "overall", "overall", "overall", "overall", "overall"…
#> $ additional_level <chr> "overall", "overall", "overall", "overall", "overall"…
```

### What the function reports

[`summarisePerson()`](https://OHDSI.github.io/OmopSketch/reference/summarisePerson.md)
builds a set of common summaries:

- Number subjects: total number of rows in person.

- Number subjects not in observation: number (and percentage) of persons
  that do not appear in *observation_period* (useful to detect missing
  observation periods). A warning is emitted if any are found.

- Sex: counts and percentages for the sex categories (Female, Male,
  Missing).

- A separate Sex source table shows the raw gender_source_value
  distribution.

- Race / Race source: distribution of race_concept_id and
  race_source_value

- Ethnicity / Ethnicity source: distribution of ethnicity_concept_id and
  ethnicity_source_value.

- Year / Month / Day of birth: numeric summaries (missingness,
  quantiles, min/max) of birth date components.

- Location, Provider, Care site: number of missing, zeros, distinct
  values.

## Tidy the summarised object

[`tablePerson()`](https://OHDSI.github.io/OmopSketch/reference/tablePerson.md)
will help you to tidy the previous results and create a formatted table
of type [gt](https://gt.rstudio.com/),
[reactable](https://glin.github.io/reactable/) or
[datatable](https://rstudio.github.io/DT/). By default it creates a
[gt](https://gt.rstudio.com/) table.

``` r
tablePerson(result = result, type = "gt")
```

[TABLE]

Summary of person table

Finally, we can disconnect from the cdm.

``` r
CDMConnector::cdmDisconnect(cdm = cdm)
```
