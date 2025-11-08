# Create a plot from the output of summariseObservationPeriod().

Create a plot from the output of summariseObservationPeriod().

## Usage

``` r
plotObservationPeriod(
  result,
  variableName = "Number subjects",
  plotType = "barplot",
  facet = NULL,
  colour = NULL,
  style = "default"
)
```

## Arguments

- result:

  A summarised_result object.

- variableName:

  The variable to plot it can be: "Number subjects", "Records per
  person", "Duration in days" or "Days to next observation period".

- plotType:

  The plot type, it can be: "barplot", "boxplot" or "densityplot".

- facet:

  Columns to colour by. See possible columns to colour by with:
  [`visOmopResults::tidyColumns()`](https://darwin-eu.github.io/omopgenerics/reference/tidyColumns.html).

- colour:

  Columns to colour by. See possible columns to colour by with:
  [`visOmopResults::tidyColumns()`](https://darwin-eu.github.io/omopgenerics/reference/tidyColumns.html).

- style:

  Which style to apply to the plot, options are: "default", "darwin" and
  NULL (default ggplot style). Customised styles can be achieved by
  modifying the returned ggplot object.

## Value

A ggplot2 object.

## Examples

``` r
# \donttest{
library(OmopSketch)

cdm <- mockOmopSketch(numberIndividuals = 100)
#> ℹ Reading GiBleed tables.

result <- summariseObservationPeriod(observationPeriod = cdm$observation_period)
#> Warning: The `observationPeriod` argument of `summariseObservationPeriod()` is
#> deprecated as of OmopSketch 0.5.1.
#> ℹ Please use the `cdm` argument instead.
#> ℹ retrieving cdm object from cdm_table.

plotObservationPeriod(
  result = result,
  variableName = "Duration in days",
  plotType = "boxplot"
)


PatientProfiles::mockDisconnect(cdm)
# }
```
