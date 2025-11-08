# Plot the concept counts of a summariseConceptSetCounts output. **\[deprecated\]**

Plot the concept counts of a summariseConceptSetCounts output.
**\[deprecated\]**

## Usage

``` r
plotConceptSetCounts(result, facet = NULL, colour = NULL)
```

## Arguments

- result:

  A summarised_result object (output of summariseConceptSetCounts).

- facet:

  Columns to face by. Formula format can be provided. See possible
  columns to face by with:
  [`visOmopResults::tidyColumns()`](https://darwin-eu.github.io/omopgenerics/reference/tidyColumns.html).

- colour:

  Columns to colour by. See possible columns to colour by with:
  [`visOmopResults::tidyColumns()`](https://darwin-eu.github.io/omopgenerics/reference/tidyColumns.html).

## Value

A ggplot2 object showing the concept counts.

## Examples

``` r
# \donttest{
library(dplyr)
#> 
#> Attaching package: ‘dplyr’
#> The following objects are masked from ‘package:stats’:
#> 
#>     filter, lag
#> The following objects are masked from ‘package:base’:
#> 
#>     intersect, setdiff, setequal, union
library(OmopSketch)

cdm <- mockOmopSketch()
#> ℹ Reading GiBleed tables.

result <- summariseConceptSetCounts(
  cdm = cdm,
  conceptSet = list(
    "asthma" = c(4051466, 317009),
    "rhinitis" = c(4280726, 4048171, 40486433)
  )
)
#> Warning: `summariseConceptSetCounts()` was deprecated in OmopSketch 0.5.0.
#> Warning: ! `codelist` casted to integers.
#> ℹ Searching concepts from domain condition in condition_occurrence.
#> ℹ Counting concepts

result |>
  filter(variable_name == "Number subjects") |>
  plotConceptSetCounts(facet = "codelist_name", colour = "standard_concept_name")
#> Warning: `plotConceptSetCounts()` was deprecated in OmopSketch 0.5.0.
#> Warning: Ignoring empty aesthetic: `width`.


PatientProfiles::mockDisconnect(cdm)
# }
```
