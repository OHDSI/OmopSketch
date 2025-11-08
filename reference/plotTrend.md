# Create a ggplot2 plot from the output of summariseTrend().

Create a ggplot2 plot from the output of summariseTrend().

## Usage

``` r
plotTrend(
  result,
  output = NULL,
  facet = "type",
  colour = NULL,
  style = "default"
)
```

## Arguments

- result:

  A summarised_result object (output of summariseTrend).

- output:

  The output to plot. Accepted values are: `"record"`, `"person"`,
  `"person-days"`, `"age"`, and `"sex"`. If not specified, the function
  will default to:

  - the only available output if there is just one in the results, or

  - `"record"` if multiple outputs are present.

- facet:

  Columns to face by. Formula format can be provided. See possible
  columns to face by with:
  [`visOmopResults::tidyColumns()`](https://darwin-eu.github.io/omopgenerics/reference/tidyColumns.html).

- colour:

  Columns to colour by. See possible columns to colour by with:
  [`visOmopResults::tidyColumns()`](https://darwin-eu.github.io/omopgenerics/reference/tidyColumns.html).

- style:

  Which style to apply to the plot, options are: "default", "darwin" and
  NULL (default ggplot style). Customised styles can be achieved by
  modifying the returned ggplot object.

## Value

A ggplot showing the table counts

## Examples

``` r
# \donttest{
library(dplyr)
library(OmopSketch)

cdm <- mockOmopSketch()
#> ℹ Reading GiBleed tables.

result <- summariseTrend(cdm,
  episode = "observation_period",
  output = c("person-days", "record"),
  interval = "years",
  ageGroup = list("<=40" = c(0, 40), ">40" = c(41, Inf)),
  sex = TRUE
)

plotTrend(result, output = "record", colour = "sex", facet = "age_group")



PatientProfiles::mockDisconnect(cdm)
# }
```
