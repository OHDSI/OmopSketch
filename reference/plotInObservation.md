# Create a ggplot2 plot from the output of summariseInObservation(). **\[deprecated\]**

Create a ggplot2 plot from the output of summariseInObservation().
**\[deprecated\]**

## Usage

``` r
plotInObservation(result, facet = NULL, colour = NULL)
```

## Arguments

- result:

  A summarised_result object (output of summariseInObservation).

- facet:

  Columns to face by. Formula format can be provided. See possible
  columns to face by with:
  [`visOmopResults::tidyColumns()`](https://darwin-eu.github.io/omopgenerics/reference/tidyColumns.html).

- colour:

  Columns to colour by. See possible columns to colour by with:
  [`visOmopResults::tidyColumns()`](https://darwin-eu.github.io/omopgenerics/reference/tidyColumns.html).

## Value

A ggplot showing the table counts

## Examples

``` r
# \donttest{
library(dplyr)
library(OmopSketch)

cdm <- mockOmopSketch()
#> ℹ Reading GiBleed tables.

result <- summariseInObservation(
  observationPeriod = cdm$observation_period,
  output = c("person-days", "record"),
  ageGroup = list("<=40" = c(0, 40), ">40" = c(41, Inf)),
  sex = TRUE
)
#> Warning: `summariseInObservation()` was deprecated in OmopSketch 1.0.0.
#> ℹ Please use `summariseTrend()` instead.

result |>
  filter(variable_name == "Person-days") |>
  plotInObservation(facet = "sex", colour = "age_group")
#> Warning: `plotInObservation()` was deprecated in OmopSketch 1.0.0.
#> ℹ Please use `plotTrend()` instead.


PatientProfiles::mockDisconnect(cdm)
# }
```
