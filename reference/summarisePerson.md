# Summarise the person table

Summarise the person table

## Usage

``` r
summarisePerson(cdm)
```

## Arguments

- cdm:

  A cdm_reference object.

## Value

A summarised_result object with the summary of the person table.

## Examples

``` r
# \donttest{
library(OmopSketch)
library(dplyr, warn.conflicts = FALSE)

cdm <- mockOmopSketch(numberIndividuals = 100)
#> ℹ Reading GiBleed tables.

result <- summarisePerson(cdm = cdm)

result |>
  glimpse()
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
#> $ estimate_value   <chr> "100", "0", "0", "46", "46", "54", "54", "0", "0", "1…
#> $ additional_name  <chr> "overall", "overall", "overall", "overall", "overall"…
#> $ additional_level <chr> "overall", "overall", "overall", "overall", "overall"…

PatientProfiles::mockDisconnect(cdm)
# }
```
