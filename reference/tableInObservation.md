# Create a visual table from a summariseInObservation() result. **\[deprecated\]**

Create a visual table from a summariseInObservation() result.
**\[deprecated\]**

## Usage

``` r
tableInObservation(result, type = "gt")
```

## Arguments

- result:

  A summarised_result object.

- type:

  Type of formatting output table. See
  [`visOmopResults::tableType()`](https://darwin-eu.github.io/visOmopResults/reference/tableType.html)
  for allowed options. Default is `"gt"`

## Value

A formatted table object with the summarised data.

## Examples

``` r
# \donttest{
library(OmopSketch)
library(dplyr, warn.conflicts = FALSE)

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
  tableInObservation()
#> Warning: `tableInObservation()` was deprecated in OmopSketch 1.0.0.
#> ℹ Please use `tableTrend()` instead.


  
Summary of Number of records, Person-days by months in observation_period table

  

Variable name
```

Time interval

Age group

Sex

Estimate name

Database name

mockOmopSketch

episode; observation_period

Number of records

1954-08-01 to 1954-08-31

overall

overall

N (%)

1 (1.00%)

\<=60

overall

N (%)

1 (1.00%)

overall

Male

N (%)

1 (1.00%)

\<=60

Male

N (%)

1 (1.00%)

1954-09-01 to 1954-09-30

overall

overall

N (%)

1 (1.00%)

\<=60

overall

N (%)

1 (1.00%)

overall

Male

N (%)

1 (1.00%)

\<=60

Male

N (%)

1 (1.00%)

1954-10-01 to 1954-10-31

overall

overall

N (%)

1 (1.00%)

\<=60

overall

N (%)

1 (1.00%)

overall

Male

N (%)

1 (1.00%)

\<=60

Male

N (%)

1 (1.00%)

1954-11-01 to 1954-11-30

overall

overall

N (%)

1 (1.00%)

\<=60

overall

N (%)

1 (1.00%)

overall

Male

N (%)

1 (1.00%)

\<=60

Male

N (%)

1 (1.00%)

1954-12-01 to 1954-12-31

overall

overall

N (%)

1 (1.00%)

\<=60

overall

N (%)

1 (1.00%)

overall

Male

N (%)

1 (1.00%)

\<=60

Male

N (%)

1 (1.00%)

1955-01-01 to 1955-01-31

overall

overall

N (%)

1 (1.00%)

\<=60

overall

N (%)

1 (1.00%)

overall

Male

N (%)

1 (1.00%)

\<=60

Male

N (%)

1 (1.00%)

1955-02-01 to 1955-02-28

overall

overall

N (%)

1 (1.00%)

\<=60

overall

N (%)

1 (1.00%)

overall

Male

N (%)

1 (1.00%)

\<=60

Male

N (%)

1 (1.00%)

1955-03-01 to 1955-03-31

overall

overall

N (%)

1 (1.00%)

\<=60

overall

N (%)

1 (1.00%)

overall

Male

N (%)

1 (1.00%)

\<=60

Male

N (%)

1 (1.00%)

1955-04-01 to 1955-04-30

overall

overall

N (%)

1 (1.00%)

\<=60

overall

N (%)

1 (1.00%)

overall

Male

N (%)

1 (1.00%)

\<=60

Male

N (%)

1 (1.00%)

1955-05-01 to 1955-05-31

overall

overall

N (%)

1 (1.00%)

\<=60

overall

N (%)

1 (1.00%)

overall

Male

N (%)

1 (1.00%)

\<=60

Male

N (%)

1 (1.00%)

1955-06-01 to 1955-06-30

overall

overall

N (%)

1 (1.00%)

\<=60

overall

N (%)

1 (1.00%)

overall

Male

N (%)

1 (1.00%)

\<=60

Male

N (%)

1 (1.00%)

1955-07-01 to 1955-07-31

overall

overall

N (%)

1 (1.00%)

\<=60

overall

N (%)

1 (1.00%)

overall

Male

N (%)

1 (1.00%)

\<=60

Male

N (%)

1 (1.00%)

1955-08-01 to 1955-08-31

overall

overall

N (%)

1 (1.00%)

\<=60

overall

N (%)

1 (1.00%)

overall

Male

N (%)

1 (1.00%)

\<=60

Male

N (%)

1 (1.00%)

1955-09-01 to 1955-09-30

overall

overall

N (%)

1 (1.00%)

\<=60

overall

N (%)

1 (1.00%)

overall

Male

N (%)

1 (1.00%)

\<=60

Male

N (%)

1 (1.00%)

1955-10-01 to 1955-10-31

overall

overall

N (%)

1 (1.00%)

\<=60

overall

N (%)

1 (1.00%)

overall

Male

N (%)

1 (1.00%)

\<=60

Male

N (%)

1 (1.00%)

1955-11-01 to 1955-11-30

overall

overall

N (%)

1 (1.00%)

\<=60

overall

N (%)

1 (1.00%)

overall

Male

N (%)

1 (1.00%)

\<=60

Male

N (%)

1 (1.00%)

1955-12-01 to 1955-12-31

overall

overall

N (%)

1 (1.00%)

\<=60

overall

N (%)

1 (1.00%)

overall

Male

N (%)

1 (1.00%)

\<=60

Male

N (%)

1 (1.00%)

1956-01-01 to 1956-01-31

overall

overall

N (%)

1 (1.00%)

\<=60

overall

N (%)

1 (1.00%)

overall

Male

N (%)

1 (1.00%)

\<=60

Male

N (%)

1 (1.00%)

1956-02-01 to 1956-02-29

overall

overall

N (%)

1 (1.00%)

\<=60

overall

N (%)

1 (1.00%)

overall

Male

N (%)

1 (1.00%)

\<=60

Male

N (%)

1 (1.00%)

1956-03-01 to 1956-03-31

overall

overall

N (%)

1 (1.00%)

\<=60

overall

N (%)

1 (1.00%)

overall

Male

N (%)

1 (1.00%)

\<=60

Male

N (%)

1 (1.00%)

1956-04-01 to 1956-04-30

overall

overall

N (%)

1 (1.00%)

\<=60

overall

N (%)

1 (1.00%)

overall

Male

N (%)

1 (1.00%)

\<=60

Male

N (%)

1 (1.00%)

1956-05-01 to 1956-05-31

overall

overall

N (%)

1 (1.00%)

\<=60

overall

N (%)

1 (1.00%)

overall

Male

N (%)

1 (1.00%)

\<=60

Male

N (%)

1 (1.00%)

1956-06-01 to 1956-06-30

overall

overall

N (%)

1 (1.00%)

\<=60

overall

N (%)

1 (1.00%)

overall

Male

N (%)

1 (1.00%)

\<=60

Male

N (%)

1 (1.00%)

1956-07-01 to 1956-07-31

overall

overall

N (%)

1 (1.00%)

\<=60

overall

N (%)

1 (1.00%)

overall

Male

N (%)

1 (1.00%)

\<=60

Male

N (%)

1 (1.00%)

1956-08-01 to 1956-08-31

overall

overall

N (%)

1 (1.00%)

\<=60

overall

N (%)

1 (1.00%)

overall

Male

N (%)

1 (1.00%)

\<=60

Male

N (%)

1 (1.00%)

1956-09-01 to 1956-09-30

overall

overall

N (%)

2 (2.00%)

\<=60

overall

N (%)

2 (2.00%)

overall

Male

N (%)

2 (2.00%)

\<=60

Male

N (%)

2 (2.00%)

1956-10-01 to 1956-10-31

overall

overall

N (%)

2 (2.00%)

\<=60

overall

N (%)

2 (2.00%)

overall

Male

N (%)

2 (2.00%)

\<=60

Male

N (%)

2 (2.00%)

1956-11-01 to 1956-11-30

overall

overall

N (%)

2 (2.00%)

\<=60

overall

N (%)

2 (2.00%)

overall

Male

N (%)

2 (2.00%)

\<=60

Male

N (%)

2 (2.00%)

1956-12-01 to 1956-12-31

overall

overall

N (%)

2 (2.00%)

\<=60

overall

N (%)

2 (2.00%)

overall

Male

N (%)

2 (2.00%)

\<=60

Male

N (%)

2 (2.00%)

1957-01-01 to 1957-01-31

overall

overall

N (%)

2 (2.00%)

\<=60

overall

N (%)

2 (2.00%)

overall

Male

N (%)

2 (2.00%)

\<=60

Male

N (%)

2 (2.00%)

1957-02-01 to 1957-02-28

overall

overall

N (%)

2 (2.00%)

\<=60

overall

N (%)

2 (2.00%)

overall

Male

N (%)

2 (2.00%)

\<=60

Male

N (%)

2 (2.00%)

1957-03-01 to 1957-03-31

overall

overall

N (%)

2 (2.00%)

\<=60

overall

N (%)

2 (2.00%)

overall

Male

N (%)

2 (2.00%)

\<=60

Male

N (%)

2 (2.00%)

1957-04-01 to 1957-04-30

overall

overall

N (%)

2 (2.00%)

\<=60

overall

N (%)

2 (2.00%)

overall

Male

N (%)

2 (2.00%)

\<=60

Male

N (%)

2 (2.00%)

1957-05-01 to 1957-05-31

overall

overall

N (%)

2 (2.00%)

\<=60

overall

N (%)

2 (2.00%)

overall

Male

N (%)

2 (2.00%)

\<=60

Male

N (%)

2 (2.00%)

1957-06-01 to 1957-06-30

overall

overall

N (%)

2 (2.00%)

\<=60

overall

N (%)

2 (2.00%)

overall

Male

N (%)

2 (2.00%)

\<=60

Male

N (%)

2 (2.00%)

1957-07-01 to 1957-07-31

overall

overall

N (%)

2 (2.00%)

\<=60

overall

N (%)

2 (2.00%)

overall

Male

N (%)

2 (2.00%)

\<=60

Male

N (%)

2 (2.00%)

1957-08-01 to 1957-08-31

overall

overall

N (%)

2 (2.00%)

\<=60

overall

N (%)

2 (2.00%)

overall

Male

N (%)

2 (2.00%)

\<=60

Male

N (%)

2 (2.00%)

1957-09-01 to 1957-09-30

overall

overall

N (%)

2 (2.00%)

\<=60

overall

N (%)

2 (2.00%)

overall

Male

N (%)

2 (2.00%)

\<=60

Male

N (%)

2 (2.00%)

1957-10-01 to 1957-10-31

overall

overall

N (%)

2 (2.00%)

\<=60

overall

N (%)

2 (2.00%)

overall

Male

N (%)

2 (2.00%)

\<=60

Male

N (%)

2 (2.00%)

1957-11-01 to 1957-11-30

overall

overall

N (%)

2 (2.00%)

\<=60

overall

N (%)

2 (2.00%)

overall

Male

N (%)

2 (2.00%)

\<=60

Male

N (%)

2 (2.00%)

1957-12-01 to 1957-12-31

overall

overall

N (%)

2 (2.00%)

\<=60

overall

N (%)

2 (2.00%)

overall

Male

N (%)

2 (2.00%)

\<=60

Male

N (%)

2 (2.00%)

1958-01-01 to 1958-01-31

overall

overall

N (%)

2 (2.00%)

\<=60

overall

N (%)

2 (2.00%)

overall

Male

N (%)

2 (2.00%)

\<=60

Male

N (%)

2 (2.00%)

1958-02-01 to 1958-02-28

overall

overall

N (%)

2 (2.00%)

\<=60

overall

N (%)

2 (2.00%)

overall

Male

N (%)

2 (2.00%)

\<=60

Male

N (%)

2 (2.00%)

1958-03-01 to 1958-03-31

overall

overall

N (%)

2 (2.00%)

\<=60

overall

N (%)

2 (2.00%)

overall

Male

N (%)

2 (2.00%)

\<=60

Male

N (%)

2 (2.00%)

1958-04-01 to 1958-04-30

overall

overall

N (%)

2 (2.00%)

\<=60

overall

N (%)

2 (2.00%)

overall

Male

N (%)

2 (2.00%)

\<=60

Male

N (%)

2 (2.00%)

1958-05-01 to 1958-05-31

overall

overall

N (%)

2 (2.00%)

\<=60

overall

N (%)

2 (2.00%)

overall

Male

N (%)

2 (2.00%)

\<=60

Male

N (%)

2 (2.00%)

1958-06-01 to 1958-06-30

overall

overall

N (%)

2 (2.00%)

\<=60

overall

N (%)

2 (2.00%)

overall

Male

N (%)

2 (2.00%)

\<=60

Male

N (%)

2 (2.00%)

1958-07-01 to 1958-07-31

overall

overall

N (%)

2 (2.00%)

\<=60

overall

N (%)

2 (2.00%)

overall

Male

N (%)

2 (2.00%)

\<=60

Male

N (%)

2 (2.00%)

1958-08-01 to 1958-08-31

overall

overall

N (%)

2 (2.00%)

\<=60

overall

N (%)

2 (2.00%)

overall

Male

N (%)

2 (2.00%)

\<=60

Male

N (%)

2 (2.00%)

1958-09-01 to 1958-09-30

overall

overall

N (%)

2 (2.00%)

\<=60

overall

N (%)

2 (2.00%)

overall

Male

N (%)

2 (2.00%)

\<=60

Male

N (%)

2 (2.00%)

1958-10-01 to 1958-10-31

overall

overall

N (%)

2 (2.00%)

\<=60

overall

N (%)

2 (2.00%)

overall

Male

N (%)

2 (2.00%)

\<=60

Male

N (%)

2 (2.00%)

1958-11-01 to 1958-11-30

overall

overall

N (%)

2 (2.00%)

\<=60

overall

N (%)

2 (2.00%)

overall

Male

N (%)

2 (2.00%)

\<=60

Male

N (%)

2 (2.00%)

1958-12-01 to 1958-12-31

overall

overall

N (%)

2 (2.00%)

\<=60

overall

N (%)

2 (2.00%)

overall

Male

N (%)

2 (2.00%)

\<=60

Male

N (%)

2 (2.00%)

1959-01-01 to 1959-01-31

overall

overall

N (%)

2 (2.00%)

\<=60

overall

N (%)

2 (2.00%)

overall

Male

N (%)

2 (2.00%)

\<=60

Male

N (%)

2 (2.00%)

1959-02-01 to 1959-02-28

overall

overall

N (%)

2 (2.00%)

\<=60

overall

N (%)

2 (2.00%)

overall

Male

N (%)

2 (2.00%)

\<=60

Male

N (%)

2 (2.00%)

1959-03-01 to 1959-03-31

overall

overall

N (%)

2 (2.00%)

\<=60

overall

N (%)

2 (2.00%)

overall

Male

N (%)

2 (2.00%)

\<=60

Male

N (%)

2 (2.00%)

1959-04-01 to 1959-04-30

overall

overall

N (%)

2 (2.00%)

\<=60

overall

N (%)

2 (2.00%)

overall

Male

N (%)

2 (2.00%)

\<=60

Male

N (%)

2 (2.00%)

1959-05-01 to 1959-05-31

overall

overall

N (%)

2 (2.00%)

\<=60

overall

N (%)

2 (2.00%)

overall

Male

N (%)

2 (2.00%)

\<=60

Male

N (%)

2 (2.00%)

1959-06-01 to 1959-06-30

overall

overall

N (%)

2 (2.00%)

\<=60

overall

N (%)

2 (2.00%)

overall

Male

N (%)

2 (2.00%)

\<=60

Male

N (%)

2 (2.00%)

1959-07-01 to 1959-07-31

overall

overall

N (%)

2 (2.00%)

\<=60

overall

N (%)

2 (2.00%)

overall

Male

N (%)

2 (2.00%)

\<=60

Male

N (%)

2 (2.00%)

1959-08-01 to 1959-08-31

overall

overall

N (%)

2 (2.00%)

\<=60

overall

N (%)

2 (2.00%)

overall

Male

N (%)

2 (2.00%)

\<=60

Male

N (%)

2 (2.00%)

1959-09-01 to 1959-09-30

overall

overall

N (%)

2 (2.00%)

\<=60

overall

N (%)

2 (2.00%)

overall

Male

N (%)

2 (2.00%)

\<=60

Male

N (%)

2 (2.00%)

1959-10-01 to 1959-10-31

overall

overall

N (%)

2 (2.00%)

\<=60

overall

N (%)

2 (2.00%)

overall

Male

N (%)

2 (2.00%)

\<=60

Male

N (%)

2 (2.00%)

1959-11-01 to 1959-11-30

overall

overall

N (%)

2 (2.00%)

\<=60

overall

N (%)

2 (2.00%)

overall

Male

N (%)

2 (2.00%)

\<=60

Male

N (%)

2 (2.00%)

1959-12-01 to 1959-12-31

overall

overall

N (%)

2 (2.00%)

\<=60

overall

N (%)

2 (2.00%)

overall

Male

N (%)

2 (2.00%)

\<=60

Male

N (%)

2 (2.00%)

1960-01-01 to 1960-01-31

overall

overall

N (%)

2 (2.00%)

\<=60

overall

N (%)

2 (2.00%)

overall

Male

N (%)

2 (2.00%)

\<=60

Male

N (%)

2 (2.00%)

1960-02-01 to 1960-02-29

overall

overall

N (%)

2 (2.00%)

\<=60

overall

N (%)

2 (2.00%)

overall

Male

N (%)

2 (2.00%)

\<=60

Male

N (%)

2 (2.00%)

1960-03-01 to 1960-03-31

overall

overall

N (%)

2 (2.00%)

\<=60

overall

N (%)

2 (2.00%)

overall

Male

N (%)

2 (2.00%)

\<=60

Male

N (%)

2 (2.00%)

1960-04-01 to 1960-04-30

overall

overall

N (%)

2 (2.00%)

\<=60

overall

N (%)

2 (2.00%)

overall

Male

N (%)

2 (2.00%)

\<=60

Male

N (%)

2 (2.00%)

1960-05-01 to 1960-05-31

overall

overall

N (%)

2 (2.00%)

\<=60

overall

N (%)

2 (2.00%)

overall

Male

N (%)

2 (2.00%)

\<=60

Male

N (%)

2 (2.00%)

1960-06-01 to 1960-06-30

overall

overall

N (%)

2 (2.00%)

\<=60

overall

N (%)

2 (2.00%)

overall

Male

N (%)

2 (2.00%)

\<=60

Male

N (%)

2 (2.00%)

1960-07-01 to 1960-07-31

overall

overall

N (%)

2 (2.00%)

\<=60

overall

N (%)

2 (2.00%)

overall

Male

N (%)

2 (2.00%)

\<=60

Male

N (%)

2 (2.00%)

1960-08-01 to 1960-08-31

overall

overall

N (%)

2 (2.00%)

\<=60

overall

N (%)

2 (2.00%)

overall

Male

N (%)

2 (2.00%)

\<=60

Male

N (%)

2 (2.00%)

1960-09-01 to 1960-09-30

overall

overall

N (%)

2 (2.00%)

\<=60

overall

N (%)

2 (2.00%)

overall

Male

N (%)

2 (2.00%)

\<=60

Male

N (%)

2 (2.00%)

1960-10-01 to 1960-10-31

overall

overall

N (%)

2 (2.00%)

\<=60

overall

N (%)

2 (2.00%)

overall

Male

N (%)

2 (2.00%)

\<=60

Male

N (%)

2 (2.00%)

1960-11-01 to 1960-11-30

overall

overall

N (%)

2 (2.00%)

\<=60

overall

N (%)

2 (2.00%)

overall

Male

N (%)

2 (2.00%)

\<=60

Male

N (%)

2 (2.00%)

1960-12-01 to 1960-12-31

overall

overall

N (%)

2 (2.00%)

\<=60

overall

N (%)

2 (2.00%)

overall

Male

N (%)

2 (2.00%)

\<=60

Male

N (%)

2 (2.00%)

1961-01-01 to 1961-01-31

overall

overall

N (%)

2 (2.00%)

\<=60

overall

N (%)

2 (2.00%)

overall

Male

N (%)

2 (2.00%)

\<=60

Male

N (%)

2 (2.00%)

1961-02-01 to 1961-02-28

overall

overall

N (%)

2 (2.00%)

\<=60

overall

N (%)

2 (2.00%)

overall

Male

N (%)

2 (2.00%)

\<=60

Male

N (%)

2 (2.00%)

1961-03-01 to 1961-03-31

overall

overall

N (%)

2 (2.00%)

\<=60

overall

N (%)

2 (2.00%)

overall

Male

N (%)

2 (2.00%)

\<=60

Male

N (%)

2 (2.00%)

1961-04-01 to 1961-04-30

overall

overall

N (%)

2 (2.00%)

\<=60

overall

N (%)

2 (2.00%)

overall

Male

N (%)

2 (2.00%)

\<=60

Male

N (%)

2 (2.00%)

1961-05-01 to 1961-05-31

overall

overall

N (%)

2 (2.00%)

\<=60

overall

N (%)

2 (2.00%)

overall

Male

N (%)

2 (2.00%)

\<=60

Male

N (%)

2 (2.00%)

1961-06-01 to 1961-06-30

overall

overall

N (%)

2 (2.00%)

\<=60

overall

N (%)

2 (2.00%)

overall

Male

N (%)

2 (2.00%)

\<=60

Male

N (%)

2 (2.00%)

1961-07-01 to 1961-07-31

overall

overall

N (%)

2 (2.00%)

\<=60

overall

N (%)

2 (2.00%)

overall

Male

N (%)

2 (2.00%)

\<=60

Male

N (%)

2 (2.00%)

1961-08-01 to 1961-08-31

overall

overall

N (%)

2 (2.00%)

\<=60

overall

N (%)

2 (2.00%)

overall

Male

N (%)

2 (2.00%)

\<=60

Male

N (%)

2 (2.00%)

1961-09-01 to 1961-09-30

overall

overall

N (%)

2 (2.00%)

\<=60

overall

N (%)

2 (2.00%)

overall

Male

N (%)

2 (2.00%)

\<=60

Male

N (%)

2 (2.00%)

1961-10-01 to 1961-10-31

overall

overall

N (%)

2 (2.00%)

\<=60

overall

N (%)

2 (2.00%)

overall

Male

N (%)

2 (2.00%)

\<=60

Male

N (%)

2 (2.00%)

1961-11-01 to 1961-11-30

overall

overall

N (%)

2 (2.00%)

\<=60

overall

N (%)

2 (2.00%)

overall

Male

N (%)

2 (2.00%)

\<=60

Male

N (%)

2 (2.00%)

1961-12-01 to 1961-12-31

overall

overall

N (%)

2 (2.00%)

\<=60

overall

N (%)

2 (2.00%)

overall

Male

N (%)

2 (2.00%)

\<=60

Male

N (%)

2 (2.00%)

1962-01-01 to 1962-01-31

overall

overall

N (%)

2 (2.00%)

\<=60

overall

N (%)

2 (2.00%)

overall

Male

N (%)

2 (2.00%)

\<=60

Male

N (%)

2 (2.00%)

1962-02-01 to 1962-02-28

overall

overall

N (%)

2 (2.00%)

\<=60

overall

N (%)

2 (2.00%)

overall

Male

N (%)

2 (2.00%)

\<=60

Male

N (%)

2 (2.00%)

1962-03-01 to 1962-03-31

overall

overall

N (%)

2 (2.00%)

\<=60

overall

N (%)

2 (2.00%)

overall

Male

N (%)

2 (2.00%)

\<=60

Male

N (%)

2 (2.00%)

1962-04-01 to 1962-04-30

overall

overall

N (%)

2 (2.00%)

\<=60

overall

N (%)

2 (2.00%)

overall

Male

N (%)

2 (2.00%)

\<=60

Male

N (%)

2 (2.00%)

1962-05-01 to 1962-05-31

overall

overall

N (%)

2 (2.00%)

\<=60

overall

N (%)

2 (2.00%)

overall

Male

N (%)

2 (2.00%)

\<=60

Male

N (%)

2 (2.00%)

1962-06-01 to 1962-06-30

overall

overall

N (%)

2 (2.00%)

\<=60

overall

N (%)

2 (2.00%)

overall

Male

N (%)

2 (2.00%)

\<=60

Male

N (%)

2 (2.00%)

1962-07-01 to 1962-07-31

overall

overall

N (%)

2 (2.00%)

\<=60

overall

N (%)

2 (2.00%)

overall

Male

N (%)

2 (2.00%)

\<=60

Male

N (%)

2 (2.00%)

1962-08-01 to 1962-08-31

overall

overall

N (%)

2 (2.00%)

\<=60

overall

N (%)

2 (2.00%)

overall

Male

N (%)

2 (2.00%)

\<=60

Male

N (%)

2 (2.00%)

1962-09-01 to 1962-09-30

overall

overall

N (%)

2 (2.00%)

\<=60

overall

N (%)

2 (2.00%)

overall

Male

N (%)

2 (2.00%)

\<=60

Male

N (%)

2 (2.00%)

1962-10-01 to 1962-10-31

overall

overall

N (%)

2 (2.00%)

\<=60

overall

N (%)

2 (2.00%)

overall

Male

N (%)

2 (2.00%)

\<=60

Male

N (%)

2 (2.00%)

1962-11-01 to 1962-11-30

overall

overall

N (%)

2 (2.00%)

\<=60

overall

N (%)

2 (2.00%)

overall

Male

N (%)

2 (2.00%)

\<=60

Male

N (%)

2 (2.00%)

1962-12-01 to 1962-12-31

overall

overall

N (%)

2 (2.00%)

\<=60

overall

N (%)

2 (2.00%)

overall

Male

N (%)

2 (2.00%)

\<=60

Male

N (%)

2 (2.00%)

1963-01-01 to 1963-01-31

overall

overall

N (%)

2 (2.00%)

\<=60

overall

N (%)

2 (2.00%)

overall

Male

N (%)

2 (2.00%)

\<=60

Male

N (%)

2 (2.00%)

1963-02-01 to 1963-02-28

overall

overall

N (%)

2 (2.00%)

\<=60

overall

N (%)

2 (2.00%)

overall

Male

N (%)

2 (2.00%)

\<=60

Male

N (%)

2 (2.00%)

1963-03-01 to 1963-03-31

overall

overall

N (%)

2 (2.00%)

\<=60

overall

N (%)

2 (2.00%)

overall

Male

N (%)

2 (2.00%)

\<=60

Male

N (%)

2 (2.00%)

1963-04-01 to 1963-04-30

overall

overall

N (%)

2 (2.00%)

\<=60

overall

N (%)

2 (2.00%)

overall

Male

N (%)

2 (2.00%)

\<=60

Male

N (%)

2 (2.00%)

1963-05-01 to 1963-05-31

overall

overall

N (%)

2 (2.00%)

\<=60

overall

N (%)

2 (2.00%)

overall

Male

N (%)

2 (2.00%)

\<=60

Male

N (%)

2 (2.00%)

1963-06-01 to 1963-06-30

overall

overall

N (%)

2 (2.00%)

\<=60

overall

N (%)

2 (2.00%)

overall

Male

N (%)

2 (2.00%)

\<=60

Male

N (%)

2 (2.00%)

1963-07-01 to 1963-07-31

overall

overall

N (%)

2 (2.00%)

\<=60

overall

N (%)

2 (2.00%)

overall

Male

N (%)

2 (2.00%)

\<=60

Male

N (%)

2 (2.00%)

1963-08-01 to 1963-08-31

overall

overall

N (%)

2 (2.00%)

\<=60

overall

N (%)

2 (2.00%)

overall

Male

N (%)

2 (2.00%)

\<=60

Male

N (%)

2 (2.00%)

1963-09-01 to 1963-09-30

overall

overall

N (%)

3 (3.00%)

\<=60

overall

N (%)

3 (3.00%)

overall

Male

N (%)

3 (3.00%)

\<=60

Male

N (%)

3 (3.00%)

1963-10-01 to 1963-10-31

overall

overall

N (%)

3 (3.00%)

\<=60

overall

N (%)

3 (3.00%)

overall

Male

N (%)

3 (3.00%)

\<=60

Male

N (%)

3 (3.00%)

1963-11-01 to 1963-11-30

overall

overall

N (%)

3 (3.00%)

\<=60

overall

N (%)

3 (3.00%)

overall

Male

N (%)

3 (3.00%)

\<=60

Male

N (%)

3 (3.00%)

1963-12-01 to 1963-12-31

overall

overall

N (%)

3 (3.00%)

\<=60

overall

N (%)

3 (3.00%)

overall

Male

N (%)

3 (3.00%)

\<=60

Male

N (%)

3 (3.00%)

1964-01-01 to 1964-01-31

overall

overall

N (%)

3 (3.00%)

\<=60

overall

N (%)

3 (3.00%)

overall

Male

N (%)

3 (3.00%)

\<=60

Male

N (%)

3 (3.00%)

1964-02-01 to 1964-02-29

overall

overall

N (%)

3 (3.00%)

\<=60

overall

N (%)

3 (3.00%)

overall

Male

N (%)

3 (3.00%)

\<=60

Male

N (%)

3 (3.00%)

1964-03-01 to 1964-03-31

overall

overall

N (%)

3 (3.00%)

\<=60

overall

N (%)

3 (3.00%)

overall

Male

N (%)

3 (3.00%)

\<=60

Male

N (%)

3 (3.00%)

1964-04-01 to 1964-04-30

overall

overall

N (%)

3 (3.00%)

\<=60

overall

N (%)

3 (3.00%)

overall

Male

N (%)

3 (3.00%)

\<=60

Male

N (%)

3 (3.00%)

1964-05-01 to 1964-05-31

overall

overall

N (%)

3 (3.00%)

\<=60

overall

N (%)

3 (3.00%)

overall

Male

N (%)

3 (3.00%)

\<=60

Male

N (%)

3 (3.00%)

1964-06-01 to 1964-06-30

overall

overall

N (%)

3 (3.00%)

\<=60

overall

N (%)

3 (3.00%)

overall

Male

N (%)

3 (3.00%)

\<=60

Male

N (%)

3 (3.00%)

1964-07-01 to 1964-07-31

overall

overall

N (%)

4 (4.00%)

\<=60

overall

N (%)

4 (4.00%)

overall

Male

N (%)

4 (4.00%)

\<=60

Male

N (%)

4 (4.00%)

1964-08-01 to 1964-08-31

overall

overall

N (%)

4 (4.00%)

\<=60

overall

N (%)

4 (4.00%)

overall

Male

N (%)

4 (4.00%)

\<=60

Male

N (%)

4 (4.00%)

1964-09-01 to 1964-09-30

overall

overall

N (%)

4 (4.00%)

\<=60

overall

N (%)

4 (4.00%)

overall

Male

N (%)

4 (4.00%)

\<=60

Male

N (%)

4 (4.00%)

1964-10-01 to 1964-10-31

overall

overall

N (%)

4 (4.00%)

\<=60

overall

N (%)

4 (4.00%)

overall

Male

N (%)

4 (4.00%)

\<=60

Male

N (%)

4 (4.00%)

1964-11-01 to 1964-11-30

overall

overall

N (%)

4 (4.00%)

\<=60

overall

N (%)

4 (4.00%)

overall

Male

N (%)

4 (4.00%)

\<=60

Male

N (%)

4 (4.00%)

1964-12-01 to 1964-12-31

overall

overall

N (%)

4 (4.00%)

\<=60

overall

N (%)

4 (4.00%)

overall

Male

N (%)

4 (4.00%)

\<=60

Male

N (%)

4 (4.00%)

1965-01-01 to 1965-01-31

overall

overall

N (%)

4 (4.00%)

\<=60

overall

N (%)

4 (4.00%)

overall

Male

N (%)

4 (4.00%)

\<=60

Male

N (%)

4 (4.00%)

1965-02-01 to 1965-02-28

overall

overall

N (%)

4 (4.00%)

\<=60

overall

N (%)

4 (4.00%)

overall

Male

N (%)

4 (4.00%)

\<=60

Male

N (%)

4 (4.00%)

1965-03-01 to 1965-03-31

overall

overall

N (%)

4 (4.00%)

\<=60

overall

N (%)

4 (4.00%)

overall

Male

N (%)

4 (4.00%)

\<=60

Male

N (%)

4 (4.00%)

1965-04-01 to 1965-04-30

overall

overall

N (%)

4 (4.00%)

\<=60

overall

N (%)

4 (4.00%)

overall

Male

N (%)

4 (4.00%)

\<=60

Male

N (%)

4 (4.00%)

1965-05-01 to 1965-05-31

overall

overall

N (%)

4 (4.00%)

\<=60

overall

N (%)

4 (4.00%)

overall

Male

N (%)

4 (4.00%)

\<=60

Male

N (%)

4 (4.00%)

1965-06-01 to 1965-06-30

overall

overall

N (%)

4 (4.00%)

\<=60

overall

N (%)

4 (4.00%)

overall

Male

N (%)

4 (4.00%)

\<=60

Male

N (%)

4 (4.00%)

1965-07-01 to 1965-07-31

overall

overall

N (%)

4 (4.00%)

\<=60

overall

N (%)

4 (4.00%)

overall

Male

N (%)

4 (4.00%)

\<=60

Male

N (%)

4 (4.00%)

1965-08-01 to 1965-08-31

overall

overall

N (%)

4 (4.00%)

\<=60

overall

N (%)

4 (4.00%)

overall

Male

N (%)

4 (4.00%)

\<=60

Male

N (%)

4 (4.00%)

1965-09-01 to 1965-09-30

overall

overall

N (%)

4 (4.00%)

\<=60

overall

N (%)

4 (4.00%)

overall

Male

N (%)

4 (4.00%)

\<=60

Male

N (%)

4 (4.00%)

1965-10-01 to 1965-10-31

overall

overall

N (%)

4 (4.00%)

\<=60

overall

N (%)

4 (4.00%)

overall

Male

N (%)

4 (4.00%)

\<=60

Male

N (%)

4 (4.00%)

1965-11-01 to 1965-11-30

overall

overall

N (%)

4 (4.00%)

\<=60

overall

N (%)

4 (4.00%)

overall

Male

N (%)

4 (4.00%)

\<=60

Male

N (%)

4 (4.00%)

1965-12-01 to 1965-12-31

overall

overall

N (%)

4 (4.00%)

\<=60

overall

N (%)

4 (4.00%)

overall

Male

N (%)

4 (4.00%)

\<=60

Male

N (%)

4 (4.00%)

1966-01-01 to 1966-01-31

overall

overall

N (%)

4 (4.00%)

\<=60

overall

N (%)

4 (4.00%)

overall

Male

N (%)

4 (4.00%)

\<=60

Male

N (%)

4 (4.00%)

1966-02-01 to 1966-02-28

overall

overall

N (%)

5 (5.00%)

\<=60

overall

N (%)

5 (5.00%)

overall

Male

N (%)

4 (4.00%)

Female

N (%)

1 (1.00%)

\<=60

Male

N (%)

4 (4.00%)

Female

N (%)

1 (1.00%)

1966-03-01 to 1966-03-31

overall

overall

N (%)

5 (5.00%)

\<=60

overall

N (%)

5 (5.00%)

overall

Male

N (%)

4 (4.00%)

Female

N (%)

1 (1.00%)

\<=60

Male

N (%)

4 (4.00%)

Female

N (%)

1 (1.00%)

1966-04-01 to 1966-04-30

overall

overall

N (%)

5 (5.00%)

\<=60

overall

N (%)

5 (5.00%)

overall

Male

N (%)

4 (4.00%)

Female

N (%)

1 (1.00%)

\<=60

Male

N (%)

4 (4.00%)

Female

N (%)

1 (1.00%)

1966-05-01 to 1966-05-31

overall

overall

N (%)

5 (5.00%)

\<=60

overall

N (%)

5 (5.00%)

overall

Male

N (%)

4 (4.00%)

Female

N (%)

1 (1.00%)

\<=60

Male

N (%)

4 (4.00%)

Female

N (%)

1 (1.00%)

1966-06-01 to 1966-06-30

overall

overall

N (%)

5 (5.00%)

\<=60

overall

N (%)

5 (5.00%)

overall

Male

N (%)

4 (4.00%)

Female

N (%)

1 (1.00%)

\<=60

Male

N (%)

4 (4.00%)

Female

N (%)

1 (1.00%)

1966-07-01 to 1966-07-31

overall

overall

N (%)

5 (5.00%)

\<=60

overall

N (%)

5 (5.00%)

overall

Male

N (%)

4 (4.00%)

Female

N (%)

1 (1.00%)

\<=60

Male

N (%)

4 (4.00%)

Female

N (%)

1 (1.00%)

1966-08-01 to 1966-08-31

overall

overall

N (%)

5 (5.00%)

\<=60

overall

N (%)

5 (5.00%)

overall

Male

N (%)

4 (4.00%)

Female

N (%)

1 (1.00%)

\<=60

Male

N (%)

4 (4.00%)

Female

N (%)

1 (1.00%)

1966-09-01 to 1966-09-30

overall

overall

N (%)

5 (5.00%)

\<=60

overall

N (%)

5 (5.00%)

overall

Male

N (%)

4 (4.00%)

Female

N (%)

1 (1.00%)

\<=60

Male

N (%)

4 (4.00%)

Female

N (%)

1 (1.00%)

1966-10-01 to 1966-10-31

overall

overall

N (%)

5 (5.00%)

\<=60

overall

N (%)

5 (5.00%)

overall

Male

N (%)

4 (4.00%)

Female

N (%)

1 (1.00%)

\<=60

Male

N (%)

4 (4.00%)

Female

N (%)

1 (1.00%)

1966-11-01 to 1966-11-30

overall

overall

N (%)

5 (5.00%)

\<=60

overall

N (%)

5 (5.00%)

overall

Male

N (%)

4 (4.00%)

Female

N (%)

1 (1.00%)

\<=60

Male

N (%)

4 (4.00%)

Female

N (%)

1 (1.00%)

1966-12-01 to 1966-12-31

overall

overall

N (%)

6 (6.00%)

\<=60

overall

N (%)

6 (6.00%)

overall

Male

N (%)

4 (4.00%)

Female

N (%)

2 (2.00%)

\<=60

Male

N (%)

4 (4.00%)

Female

N (%)

2 (2.00%)

1967-01-01 to 1967-01-31

overall

overall

N (%)

6 (6.00%)

\<=60

overall

N (%)

6 (6.00%)

overall

Male

N (%)

4 (4.00%)

Female

N (%)

2 (2.00%)

\<=60

Male

N (%)

4 (4.00%)

Female

N (%)

2 (2.00%)

1967-02-01 to 1967-02-28

overall

overall

N (%)

6 (6.00%)

\<=60

overall

N (%)

6 (6.00%)

overall

Male

N (%)

4 (4.00%)

Female

N (%)

2 (2.00%)

\<=60

Male

N (%)

4 (4.00%)

Female

N (%)

2 (2.00%)

1967-03-01 to 1967-03-31

overall

overall

N (%)

6 (6.00%)

\<=60

overall

N (%)

6 (6.00%)

overall

Male

N (%)

4 (4.00%)

Female

N (%)

2 (2.00%)

\<=60

Male

N (%)

4 (4.00%)

Female

N (%)

2 (2.00%)

1967-04-01 to 1967-04-30

overall

overall

N (%)

6 (6.00%)

\<=60

overall

N (%)

6 (6.00%)

overall

Male

N (%)

4 (4.00%)

Female

N (%)

2 (2.00%)

\<=60

Male

N (%)

4 (4.00%)

Female

N (%)

2 (2.00%)

1967-05-01 to 1967-05-31

overall

overall

N (%)

6 (6.00%)

\<=60

overall

N (%)

6 (6.00%)

overall

Male

N (%)

4 (4.00%)

Female

N (%)

2 (2.00%)

\<=60

Male

N (%)

4 (4.00%)

Female

N (%)

2 (2.00%)

1967-06-01 to 1967-06-30

overall

overall

N (%)

6 (6.00%)

\<=60

overall

N (%)

6 (6.00%)

overall

Male

N (%)

4 (4.00%)

Female

N (%)

2 (2.00%)

\<=60

Male

N (%)

4 (4.00%)

Female

N (%)

2 (2.00%)

1967-07-01 to 1967-07-31

overall

overall

N (%)

6 (6.00%)

\<=60

overall

N (%)

6 (6.00%)

overall

Male

N (%)

4 (4.00%)

Female

N (%)

2 (2.00%)

\<=60

Male

N (%)

4 (4.00%)

Female

N (%)

2 (2.00%)

1967-08-01 to 1967-08-31

overall

overall

N (%)

6 (6.00%)

\<=60

overall

N (%)

6 (6.00%)

overall

Male

N (%)

4 (4.00%)

Female

N (%)

2 (2.00%)

\<=60

Male

N (%)

4 (4.00%)

Female

N (%)

2 (2.00%)

1967-09-01 to 1967-09-30

overall

overall

N (%)

6 (6.00%)

\<=60

overall

N (%)

6 (6.00%)

overall

Male

N (%)

4 (4.00%)

Female

N (%)

2 (2.00%)

\<=60

Male

N (%)

4 (4.00%)

Female

N (%)

2 (2.00%)

1967-10-01 to 1967-10-31

overall

overall

N (%)

6 (6.00%)

\<=60

overall

N (%)

6 (6.00%)

overall

Male

N (%)

4 (4.00%)

Female

N (%)

2 (2.00%)

\<=60

Male

N (%)

4 (4.00%)

Female

N (%)

2 (2.00%)

1967-11-01 to 1967-11-30

overall

overall

N (%)

6 (6.00%)

\<=60

overall

N (%)

6 (6.00%)

overall

Male

N (%)

4 (4.00%)

Female

N (%)

2 (2.00%)

\<=60

Male

N (%)

4 (4.00%)

Female

N (%)

2 (2.00%)

1967-12-01 to 1967-12-31

overall

overall

N (%)

6 (6.00%)

\<=60

overall

N (%)

6 (6.00%)

overall

Male

N (%)

4 (4.00%)

Female

N (%)

2 (2.00%)

\<=60

Male

N (%)

4 (4.00%)

Female

N (%)

2 (2.00%)

1968-01-01 to 1968-01-31

overall

overall

N (%)

6 (6.00%)

\<=60

overall

N (%)

6 (6.00%)

overall

Male

N (%)

4 (4.00%)

Female

N (%)

2 (2.00%)

\<=60

Male

N (%)

4 (4.00%)

Female

N (%)

2 (2.00%)

1968-02-01 to 1968-02-29

overall

overall

N (%)

7 (7.00%)

\<=60

overall

N (%)

7 (7.00%)

overall

Male

N (%)

5 (5.00%)

Female

N (%)

2 (2.00%)

\<=60

Male

N (%)

5 (5.00%)

Female

N (%)

2 (2.00%)

1968-03-01 to 1968-03-31

overall

overall

N (%)

7 (7.00%)

\<=60

overall

N (%)

7 (7.00%)

overall

Male

N (%)

5 (5.00%)

Female

N (%)

2 (2.00%)

\<=60

Male

N (%)

5 (5.00%)

Female

N (%)

2 (2.00%)

1968-04-01 to 1968-04-30

overall

overall

N (%)

7 (7.00%)

\<=60

overall

N (%)

7 (7.00%)

overall

Male

N (%)

5 (5.00%)

Female

N (%)

2 (2.00%)

\<=60

Male

N (%)

5 (5.00%)

Female

N (%)

2 (2.00%)

1968-05-01 to 1968-05-31

overall

overall

N (%)

7 (7.00%)

\<=60

overall

N (%)

7 (7.00%)

overall

Male

N (%)

5 (5.00%)

Female

N (%)

2 (2.00%)

\<=60

Male

N (%)

5 (5.00%)

Female

N (%)

2 (2.00%)

1968-06-01 to 1968-06-30

overall

overall

N (%)

7 (7.00%)

\<=60

overall

N (%)

7 (7.00%)

overall

Male

N (%)

5 (5.00%)

Female

N (%)

2 (2.00%)

\<=60

Male

N (%)

5 (5.00%)

Female

N (%)

2 (2.00%)

1968-07-01 to 1968-07-31

overall

overall

N (%)

7 (7.00%)

\<=60

overall

N (%)

7 (7.00%)

overall

Male

N (%)

5 (5.00%)

Female

N (%)

2 (2.00%)

\<=60

Male

N (%)

5 (5.00%)

Female

N (%)

2 (2.00%)

1968-08-01 to 1968-08-31

overall

overall

N (%)

7 (7.00%)

\<=60

overall

N (%)

7 (7.00%)

overall

Male

N (%)

5 (5.00%)

Female

N (%)

2 (2.00%)

\<=60

Male

N (%)

5 (5.00%)

Female

N (%)

2 (2.00%)

1968-09-01 to 1968-09-30

overall

overall

N (%)

7 (7.00%)

\<=60

overall

N (%)

7 (7.00%)

overall

Male

N (%)

5 (5.00%)

Female

N (%)

2 (2.00%)

\<=60

Male

N (%)

5 (5.00%)

Female

N (%)

2 (2.00%)

1968-10-01 to 1968-10-31

overall

overall

N (%)

7 (7.00%)

\<=60

overall

N (%)

7 (7.00%)

overall

Male

N (%)

5 (5.00%)

Female

N (%)

2 (2.00%)

\<=60

Male

N (%)

5 (5.00%)

Female

N (%)

2 (2.00%)

1968-11-01 to 1968-11-30

overall

overall

N (%)

7 (7.00%)

\<=60

overall

N (%)

7 (7.00%)

overall

Male

N (%)

5 (5.00%)

Female

N (%)

2 (2.00%)

\<=60

Male

N (%)

5 (5.00%)

Female

N (%)

2 (2.00%)

1968-12-01 to 1968-12-31

overall

overall

N (%)

7 (7.00%)

\<=60

overall

N (%)

7 (7.00%)

overall

Male

N (%)

5 (5.00%)

Female

N (%)

2 (2.00%)

\<=60

Male

N (%)

5 (5.00%)

Female

N (%)

2 (2.00%)

1969-01-01 to 1969-01-31

overall

overall

N (%)

7 (7.00%)

\<=60

overall

N (%)

7 (7.00%)

overall

Male

N (%)

5 (5.00%)

Female

N (%)

2 (2.00%)

\<=60

Male

N (%)

5 (5.00%)

Female

N (%)

2 (2.00%)

1969-02-01 to 1969-02-28

overall

overall

N (%)

7 (7.00%)

\<=60

overall

N (%)

7 (7.00%)

overall

Male

N (%)

5 (5.00%)

Female

N (%)

2 (2.00%)

\<=60

Male

N (%)

5 (5.00%)

Female

N (%)

2 (2.00%)

1969-03-01 to 1969-03-31

overall

overall

N (%)

7 (7.00%)

\<=60

overall

N (%)

7 (7.00%)

overall

Male

N (%)

5 (5.00%)

Female

N (%)

2 (2.00%)

\<=60

Male

N (%)

5 (5.00%)

Female

N (%)

2 (2.00%)

1969-04-01 to 1969-04-30

overall

overall

N (%)

8 (8.00%)

\<=60

overall

N (%)

8 (8.00%)

overall

Male

N (%)

6 (6.00%)

Female

N (%)

2 (2.00%)

\<=60

Male

N (%)

6 (6.00%)

Female

N (%)

2 (2.00%)

1969-05-01 to 1969-05-31

overall

overall

N (%)

8 (8.00%)

\<=60

overall

N (%)

8 (8.00%)

overall

Male

N (%)

6 (6.00%)

Female

N (%)

2 (2.00%)

\<=60

Male

N (%)

6 (6.00%)

Female

N (%)

2 (2.00%)

1969-06-01 to 1969-06-30

overall

overall

N (%)

8 (8.00%)

\<=60

overall

N (%)

8 (8.00%)

overall

Male

N (%)

6 (6.00%)

Female

N (%)

2 (2.00%)

\<=60

Male

N (%)

6 (6.00%)

Female

N (%)

2 (2.00%)

1969-07-01 to 1969-07-31

overall

overall

N (%)

8 (8.00%)

\<=60

overall

N (%)

8 (8.00%)

overall

Male

N (%)

6 (6.00%)

Female

N (%)

2 (2.00%)

\<=60

Male

N (%)

6 (6.00%)

Female

N (%)

2 (2.00%)

1969-08-01 to 1969-08-31

overall

overall

N (%)

8 (8.00%)

\<=60

overall

N (%)

8 (8.00%)

overall

Male

N (%)

6 (6.00%)

Female

N (%)

2 (2.00%)

\<=60

Male

N (%)

6 (6.00%)

Female

N (%)

2 (2.00%)

1969-09-01 to 1969-09-30

overall

overall

N (%)

8 (8.00%)

\<=60

overall

N (%)

8 (8.00%)

overall

Male

N (%)

6 (6.00%)

Female

N (%)

2 (2.00%)

\<=60

Male

N (%)

6 (6.00%)

Female

N (%)

2 (2.00%)

1969-10-01 to 1969-10-31

overall

overall

N (%)

8 (8.00%)

\<=60

overall

N (%)

8 (8.00%)

overall

Male

N (%)

6 (6.00%)

Female

N (%)

2 (2.00%)

\<=60

Male

N (%)

6 (6.00%)

Female

N (%)

2 (2.00%)

1969-11-01 to 1969-11-30

overall

overall

N (%)

8 (8.00%)

\<=60

overall

N (%)

8 (8.00%)

overall

Male

N (%)

6 (6.00%)

Female

N (%)

2 (2.00%)

\<=60

Male

N (%)

6 (6.00%)

Female

N (%)

2 (2.00%)

1969-12-01 to 1969-12-31

overall

overall

N (%)

8 (8.00%)

\<=60

overall

N (%)

8 (8.00%)

overall

Male

N (%)

6 (6.00%)

Female

N (%)

2 (2.00%)

\<=60

Male

N (%)

6 (6.00%)

Female

N (%)

2 (2.00%)

1970-01-01 to 1970-01-31

overall

overall

N (%)

8 (8.00%)

\<=60

overall

N (%)

8 (8.00%)

overall

Male

N (%)

6 (6.00%)

Female

N (%)

2 (2.00%)

\<=60

Male

N (%)

6 (6.00%)

Female

N (%)

2 (2.00%)

1970-02-01 to 1970-02-28

overall

overall

N (%)

8 (8.00%)

\<=60

overall

N (%)

8 (8.00%)

overall

Male

N (%)

6 (6.00%)

Female

N (%)

2 (2.00%)

\<=60

Male

N (%)

6 (6.00%)

Female

N (%)

2 (2.00%)

1970-03-01 to 1970-03-31

overall

overall

N (%)

8 (8.00%)

\<=60

overall

N (%)

8 (8.00%)

overall

Male

N (%)

6 (6.00%)

Female

N (%)

2 (2.00%)

\<=60

Male

N (%)

6 (6.00%)

Female

N (%)

2 (2.00%)

1970-04-01 to 1970-04-30

overall

overall

N (%)

8 (8.00%)

\<=60

overall

N (%)

8 (8.00%)

overall

Male

N (%)

6 (6.00%)

Female

N (%)

2 (2.00%)

\<=60

Male

N (%)

6 (6.00%)

Female

N (%)

2 (2.00%)

1970-05-01 to 1970-05-31

overall

overall

N (%)

9 (9.00%)

\<=60

overall

N (%)

9 (9.00%)

overall

Male

N (%)

7 (7.00%)

Female

N (%)

2 (2.00%)

\<=60

Male

N (%)

7 (7.00%)

Female

N (%)

2 (2.00%)

1970-06-01 to 1970-06-30

overall

overall

N (%)

9 (9.00%)

\<=60

overall

N (%)

9 (9.00%)

overall

Male

N (%)

7 (7.00%)

Female

N (%)

2 (2.00%)

\<=60

Male

N (%)

7 (7.00%)

Female

N (%)

2 (2.00%)

1970-07-01 to 1970-07-31

overall

overall

N (%)

9 (9.00%)

\<=60

overall

N (%)

9 (9.00%)

overall

Male

N (%)

7 (7.00%)

Female

N (%)

2 (2.00%)

\<=60

Male

N (%)

7 (7.00%)

Female

N (%)

2 (2.00%)

1970-08-01 to 1970-08-31

overall

overall

N (%)

9 (9.00%)

\<=60

overall

N (%)

9 (9.00%)

overall

Male

N (%)

7 (7.00%)

Female

N (%)

2 (2.00%)

\<=60

Male

N (%)

7 (7.00%)

Female

N (%)

2 (2.00%)

1970-09-01 to 1970-09-30

overall

overall

N (%)

9 (9.00%)

\<=60

overall

N (%)

9 (9.00%)

overall

Male

N (%)

7 (7.00%)

Female

N (%)

2 (2.00%)

\<=60

Male

N (%)

7 (7.00%)

Female

N (%)

2 (2.00%)

1970-10-01 to 1970-10-31

overall

overall

N (%)

9 (9.00%)

\<=60

overall

N (%)

9 (9.00%)

overall

Male

N (%)

7 (7.00%)

Female

N (%)

2 (2.00%)

\<=60

Male

N (%)

7 (7.00%)

Female

N (%)

2 (2.00%)

1970-11-01 to 1970-11-30

overall

overall

N (%)

10 (10.00%)

\<=60

overall

N (%)

10 (10.00%)

overall

Male

N (%)

7 (7.00%)

Female

N (%)

3 (3.00%)

\<=60

Male

N (%)

7 (7.00%)

Female

N (%)

3 (3.00%)

1970-12-01 to 1970-12-31

overall

overall

N (%)

10 (10.00%)

\<=60

overall

N (%)

10 (10.00%)

overall

Male

N (%)

7 (7.00%)

Female

N (%)

3 (3.00%)

\<=60

Male

N (%)

7 (7.00%)

Female

N (%)

3 (3.00%)

1971-01-01 to 1971-01-31

overall

overall

N (%)

10 (10.00%)

\<=60

overall

N (%)

10 (10.00%)

overall

Male

N (%)

7 (7.00%)

Female

N (%)

3 (3.00%)

\<=60

Male

N (%)

7 (7.00%)

Female

N (%)

3 (3.00%)

1971-02-01 to 1971-02-28

overall

overall

N (%)

10 (10.00%)

\<=60

overall

N (%)

10 (10.00%)

overall

Male

N (%)

7 (7.00%)

Female

N (%)

3 (3.00%)

\<=60

Male

N (%)

7 (7.00%)

Female

N (%)

3 (3.00%)

1971-03-01 to 1971-03-31

overall

overall

N (%)

10 (10.00%)

\<=60

overall

N (%)

10 (10.00%)

overall

Male

N (%)

7 (7.00%)

Female

N (%)

3 (3.00%)

\<=60

Male

N (%)

7 (7.00%)

Female

N (%)

3 (3.00%)

1971-04-01 to 1971-04-30

overall

overall

N (%)

10 (10.00%)

\<=60

overall

N (%)

10 (10.00%)

overall

Male

N (%)

7 (7.00%)

Female

N (%)

3 (3.00%)

\<=60

Male

N (%)

7 (7.00%)

Female

N (%)

3 (3.00%)

1971-05-01 to 1971-05-31

overall

overall

N (%)

10 (10.00%)

\<=60

overall

N (%)

10 (10.00%)

overall

Male

N (%)

7 (7.00%)

Female

N (%)

3 (3.00%)

\<=60

Male

N (%)

7 (7.00%)

Female

N (%)

3 (3.00%)

1971-06-01 to 1971-06-30

overall

overall

N (%)

10 (10.00%)

\<=60

overall

N (%)

10 (10.00%)

overall

Male

N (%)

7 (7.00%)

Female

N (%)

3 (3.00%)

\<=60

Male

N (%)

7 (7.00%)

Female

N (%)

3 (3.00%)

1971-07-01 to 1971-07-31

overall

overall

N (%)

10 (10.00%)

\<=60

overall

N (%)

10 (10.00%)

overall

Male

N (%)

7 (7.00%)

Female

N (%)

3 (3.00%)

\<=60

Male

N (%)

7 (7.00%)

Female

N (%)

3 (3.00%)

1971-08-01 to 1971-08-31

overall

overall

N (%)

10 (10.00%)

\<=60

overall

N (%)

10 (10.00%)

overall

Male

N (%)

7 (7.00%)

Female

N (%)

3 (3.00%)

\<=60

Male

N (%)

7 (7.00%)

Female

N (%)

3 (3.00%)

1971-09-01 to 1971-09-30

overall

overall

N (%)

10 (10.00%)

\<=60

overall

N (%)

10 (10.00%)

overall

Male

N (%)

7 (7.00%)

Female

N (%)

3 (3.00%)

\<=60

Male

N (%)

7 (7.00%)

Female

N (%)

3 (3.00%)

1971-10-01 to 1971-10-31

overall

overall

N (%)

10 (10.00%)

\<=60

overall

N (%)

10 (10.00%)

overall

Male

N (%)

7 (7.00%)

Female

N (%)

3 (3.00%)

\<=60

Male

N (%)

7 (7.00%)

Female

N (%)

3 (3.00%)

1971-11-01 to 1971-11-30

overall

overall

N (%)

10 (10.00%)

\<=60

overall

N (%)

10 (10.00%)

overall

Male

N (%)

7 (7.00%)

Female

N (%)

3 (3.00%)

\<=60

Male

N (%)

7 (7.00%)

Female

N (%)

3 (3.00%)

1971-12-01 to 1971-12-31

overall

overall

N (%)

10 (10.00%)

\<=60

overall

N (%)

10 (10.00%)

overall

Male

N (%)

7 (7.00%)

Female

N (%)

3 (3.00%)

\<=60

Male

N (%)

7 (7.00%)

Female

N (%)

3 (3.00%)

1972-01-01 to 1972-01-31

overall

overall

N (%)

10 (10.00%)

\<=60

overall

N (%)

10 (10.00%)

overall

Male

N (%)

7 (7.00%)

Female

N (%)

3 (3.00%)

\<=60

Male

N (%)

7 (7.00%)

Female

N (%)

3 (3.00%)

1972-02-01 to 1972-02-29

overall

overall

N (%)

10 (10.00%)

\<=60

overall

N (%)

10 (10.00%)

overall

Male

N (%)

7 (7.00%)

Female

N (%)

3 (3.00%)

\<=60

Male

N (%)

7 (7.00%)

Female

N (%)

3 (3.00%)

1972-03-01 to 1972-03-31

overall

overall

N (%)

10 (10.00%)

\<=60

overall

N (%)

10 (10.00%)

overall

Male

N (%)

7 (7.00%)

Female

N (%)

3 (3.00%)

\<=60

Male

N (%)

7 (7.00%)

Female

N (%)

3 (3.00%)

1972-04-01 to 1972-04-30

overall

overall

N (%)

10 (10.00%)

\<=60

overall

N (%)

10 (10.00%)

overall

Male

N (%)

7 (7.00%)

Female

N (%)

3 (3.00%)

\<=60

Male

N (%)

7 (7.00%)

Female

N (%)

3 (3.00%)

1972-05-01 to 1972-05-31

overall

overall

N (%)

10 (10.00%)

\<=60

overall

N (%)

10 (10.00%)

overall

Male

N (%)

7 (7.00%)

Female

N (%)

3 (3.00%)

\<=60

Male

N (%)

7 (7.00%)

Female

N (%)

3 (3.00%)

1972-06-01 to 1972-06-30

overall

overall

N (%)

10 (10.00%)

\<=60

overall

N (%)

10 (10.00%)

overall

Male

N (%)

7 (7.00%)

Female

N (%)

3 (3.00%)

\<=60

Male

N (%)

7 (7.00%)

Female

N (%)

3 (3.00%)

1972-07-01 to 1972-07-31

overall

overall

N (%)

9 (9.00%)

\<=60

overall

N (%)

9 (9.00%)

overall

Male

N (%)

6 (6.00%)

Female

N (%)

3 (3.00%)

\<=60

Male

N (%)

6 (6.00%)

Female

N (%)

3 (3.00%)

1972-08-01 to 1972-08-31

overall

overall

N (%)

9 (9.00%)

\<=60

overall

N (%)

9 (9.00%)

overall

Male

N (%)

6 (6.00%)

Female

N (%)

3 (3.00%)

\<=60

Male

N (%)

6 (6.00%)

Female

N (%)

3 (3.00%)

1972-09-01 to 1972-09-30

overall

overall

N (%)

9 (9.00%)

\<=60

overall

N (%)

9 (9.00%)

overall

Male

N (%)

6 (6.00%)

Female

N (%)

3 (3.00%)

\<=60

Male

N (%)

6 (6.00%)

Female

N (%)

3 (3.00%)

1972-10-01 to 1972-10-31

overall

overall

N (%)

9 (9.00%)

\<=60

overall

N (%)

9 (9.00%)

overall

Male

N (%)

6 (6.00%)

Female

N (%)

3 (3.00%)

\<=60

Male

N (%)

6 (6.00%)

Female

N (%)

3 (3.00%)

1972-11-01 to 1972-11-30

overall

overall

N (%)

9 (9.00%)

\<=60

overall

N (%)

9 (9.00%)

overall

Male

N (%)

6 (6.00%)

Female

N (%)

3 (3.00%)

\<=60

Male

N (%)

6 (6.00%)

Female

N (%)

3 (3.00%)

1972-12-01 to 1972-12-31

overall

overall

N (%)

9 (9.00%)

\<=60

overall

N (%)

9 (9.00%)

overall

Male

N (%)

6 (6.00%)

Female

N (%)

3 (3.00%)

\<=60

Male

N (%)

6 (6.00%)

Female

N (%)

3 (3.00%)

1973-01-01 to 1973-01-31

overall

overall

N (%)

10 (10.00%)

\<=60

overall

N (%)

10 (10.00%)

overall

Male

N (%)

7 (7.00%)

Female

N (%)

3 (3.00%)

\<=60

Male

N (%)

7 (7.00%)

Female

N (%)

3 (3.00%)

1973-02-01 to 1973-02-28

overall

overall

N (%)

10 (10.00%)

\<=60

overall

N (%)

10 (10.00%)

overall

Male

N (%)

7 (7.00%)

Female

N (%)

3 (3.00%)

\<=60

Male

N (%)

7 (7.00%)

Female

N (%)

3 (3.00%)

1973-03-01 to 1973-03-31

overall

overall

N (%)

10 (10.00%)

\<=60

overall

N (%)

10 (10.00%)

overall

Male

N (%)

7 (7.00%)

Female

N (%)

3 (3.00%)

\<=60

Male

N (%)

7 (7.00%)

Female

N (%)

3 (3.00%)

1973-04-01 to 1973-04-30

overall

overall

N (%)

10 (10.00%)

\<=60

overall

N (%)

10 (10.00%)

overall

Male

N (%)

7 (7.00%)

Female

N (%)

3 (3.00%)

\<=60

Male

N (%)

7 (7.00%)

Female

N (%)

3 (3.00%)

1973-05-01 to 1973-05-31

overall

overall

N (%)

10 (10.00%)

\<=60

overall

N (%)

10 (10.00%)

overall

Male

N (%)

7 (7.00%)

Female

N (%)

3 (3.00%)

\<=60

Male

N (%)

7 (7.00%)

Female

N (%)

3 (3.00%)

1973-06-01 to 1973-06-30

overall

overall

N (%)

10 (10.00%)

\<=60

overall

N (%)

10 (10.00%)

overall

Male

N (%)

7 (7.00%)

Female

N (%)

3 (3.00%)

\<=60

Male

N (%)

7 (7.00%)

Female

N (%)

3 (3.00%)

1973-07-01 to 1973-07-31

overall

overall

N (%)

10 (10.00%)

\<=60

overall

N (%)

10 (10.00%)

overall

Male

N (%)

7 (7.00%)

Female

N (%)

3 (3.00%)

\<=60

Male

N (%)

7 (7.00%)

Female

N (%)

3 (3.00%)

1973-08-01 to 1973-08-31

overall

overall

N (%)

10 (10.00%)

\<=60

overall

N (%)

10 (10.00%)

overall

Male

N (%)

7 (7.00%)

Female

N (%)

3 (3.00%)

\<=60

Male

N (%)

7 (7.00%)

Female

N (%)

3 (3.00%)

1973-09-01 to 1973-09-30

overall

overall

N (%)

10 (10.00%)

\<=60

overall

N (%)

10 (10.00%)

overall

Male

N (%)

7 (7.00%)

Female

N (%)

3 (3.00%)

\<=60

Male

N (%)

7 (7.00%)

Female

N (%)

3 (3.00%)

1973-10-01 to 1973-10-31

overall

overall

N (%)

10 (10.00%)

\<=60

overall

N (%)

10 (10.00%)

overall

Male

N (%)

7 (7.00%)

Female

N (%)

3 (3.00%)

\<=60

Male

N (%)

7 (7.00%)

Female

N (%)

3 (3.00%)

1973-11-01 to 1973-11-30

overall

overall

N (%)

10 (10.00%)

\<=60

overall

N (%)

10 (10.00%)

overall

Male

N (%)

7 (7.00%)

Female

N (%)

3 (3.00%)

\<=60

Male

N (%)

7 (7.00%)

Female

N (%)

3 (3.00%)

1973-12-01 to 1973-12-31

overall

overall

N (%)

10 (10.00%)

\<=60

overall

N (%)

10 (10.00%)

overall

Male

N (%)

7 (7.00%)

Female

N (%)

3 (3.00%)

\<=60

Male

N (%)

7 (7.00%)

Female

N (%)

3 (3.00%)

1974-01-01 to 1974-01-31

overall

overall

N (%)

10 (10.00%)

\<=60

overall

N (%)

10 (10.00%)

overall

Male

N (%)

7 (7.00%)

Female

N (%)

3 (3.00%)

\<=60

Male

N (%)

7 (7.00%)

Female

N (%)

3 (3.00%)

1974-02-01 to 1974-02-28

overall

overall

N (%)

10 (10.00%)

\<=60

overall

N (%)

10 (10.00%)

overall

Male

N (%)

7 (7.00%)

Female

N (%)

3 (3.00%)

\<=60

Male

N (%)

7 (7.00%)

Female

N (%)

3 (3.00%)

1974-03-01 to 1974-03-31

overall

overall

N (%)

10 (10.00%)

\<=60

overall

N (%)

10 (10.00%)

overall

Male

N (%)

7 (7.00%)

Female

N (%)

3 (3.00%)

\<=60

Male

N (%)

7 (7.00%)

Female

N (%)

3 (3.00%)

1974-04-01 to 1974-04-30

overall

overall

N (%)

10 (10.00%)

\<=60

overall

N (%)

10 (10.00%)

overall

Male

N (%)

7 (7.00%)

Female

N (%)

3 (3.00%)

\<=60

Male

N (%)

7 (7.00%)

Female

N (%)

3 (3.00%)

1974-05-01 to 1974-05-31

overall

overall

N (%)

10 (10.00%)

\<=60

overall

N (%)

10 (10.00%)

overall

Male

N (%)

7 (7.00%)

Female

N (%)

3 (3.00%)

\<=60

Male

N (%)

7 (7.00%)

Female

N (%)

3 (3.00%)

1974-06-01 to 1974-06-30

overall

overall

N (%)

10 (10.00%)

\<=60

overall

N (%)

10 (10.00%)

overall

Male

N (%)

7 (7.00%)

Female

N (%)

3 (3.00%)

\<=60

Male

N (%)

7 (7.00%)

Female

N (%)

3 (3.00%)

1974-07-01 to 1974-07-31

overall

overall

N (%)

10 (10.00%)

\<=60

overall

N (%)

10 (10.00%)

overall

Male

N (%)

7 (7.00%)

Female

N (%)

3 (3.00%)

\<=60

Male

N (%)

7 (7.00%)

Female

N (%)

3 (3.00%)

1974-08-01 to 1974-08-31

overall

overall

N (%)

10 (10.00%)

\<=60

overall

N (%)

10 (10.00%)

overall

Male

N (%)

7 (7.00%)

Female

N (%)

3 (3.00%)

\<=60

Male

N (%)

7 (7.00%)

Female

N (%)

3 (3.00%)

1974-09-01 to 1974-09-30

overall

overall

N (%)

11 (11.00%)

\<=60

overall

N (%)

11 (11.00%)

overall

Male

N (%)

7 (7.00%)

Female

N (%)

4 (4.00%)

\<=60

Male

N (%)

7 (7.00%)

Female

N (%)

4 (4.00%)

1974-10-01 to 1974-10-31

overall

overall

N (%)

11 (11.00%)

\<=60

overall

N (%)

11 (11.00%)

overall

Male

N (%)

7 (7.00%)

Female

N (%)

4 (4.00%)

\<=60

Male

N (%)

7 (7.00%)

Female

N (%)

4 (4.00%)

1974-11-01 to 1974-11-30

overall

overall

N (%)

11 (11.00%)

\<=60

overall

N (%)

11 (11.00%)

overall

Male

N (%)

7 (7.00%)

Female

N (%)

4 (4.00%)

\<=60

Male

N (%)

7 (7.00%)

Female

N (%)

4 (4.00%)

1974-12-01 to 1974-12-31

overall

overall

N (%)

11 (11.00%)

\<=60

overall

N (%)

11 (11.00%)

overall

Male

N (%)

7 (7.00%)

Female

N (%)

4 (4.00%)

\<=60

Male

N (%)

7 (7.00%)

Female

N (%)

4 (4.00%)

1975-01-01 to 1975-01-31

overall

overall

N (%)

11 (11.00%)

\<=60

overall

N (%)

11 (11.00%)

overall

Male

N (%)

7 (7.00%)

Female

N (%)

4 (4.00%)

\<=60

Male

N (%)

7 (7.00%)

Female

N (%)

4 (4.00%)

1975-02-01 to 1975-02-28

overall

overall

N (%)

11 (11.00%)

\<=60

overall

N (%)

11 (11.00%)

overall

Male

N (%)

7 (7.00%)

Female

N (%)

4 (4.00%)

\<=60

Male

N (%)

7 (7.00%)

Female

N (%)

4 (4.00%)

1975-03-01 to 1975-03-31

overall

overall

N (%)

11 (11.00%)

\<=60

overall

N (%)

11 (11.00%)

overall

Male

N (%)

7 (7.00%)

Female

N (%)

4 (4.00%)

\<=60

Male

N (%)

7 (7.00%)

Female

N (%)

4 (4.00%)

1975-04-01 to 1975-04-30

overall

overall

N (%)

11 (11.00%)

\<=60

overall

N (%)

11 (11.00%)

overall

Male

N (%)

7 (7.00%)

Female

N (%)

4 (4.00%)

\<=60

Male

N (%)

7 (7.00%)

Female

N (%)

4 (4.00%)

1975-05-01 to 1975-05-31

overall

overall

N (%)

11 (11.00%)

\<=60

overall

N (%)

11 (11.00%)

overall

Male

N (%)

7 (7.00%)

Female

N (%)

4 (4.00%)

\<=60

Male

N (%)

7 (7.00%)

Female

N (%)

4 (4.00%)

1975-06-01 to 1975-06-30

overall

overall

N (%)

11 (11.00%)

\<=60

overall

N (%)

11 (11.00%)

overall

Male

N (%)

7 (7.00%)

Female

N (%)

4 (4.00%)

\<=60

Male

N (%)

7 (7.00%)

Female

N (%)

4 (4.00%)

1975-07-01 to 1975-07-31

overall

overall

N (%)

11 (11.00%)

\<=60

overall

N (%)

11 (11.00%)

overall

Male

N (%)

7 (7.00%)

Female

N (%)

4 (4.00%)

\<=60

Male

N (%)

7 (7.00%)

Female

N (%)

4 (4.00%)

1975-08-01 to 1975-08-31

overall

overall

N (%)

11 (11.00%)

\<=60

overall

N (%)

11 (11.00%)

overall

Male

N (%)

7 (7.00%)

Female

N (%)

4 (4.00%)

\<=60

Male

N (%)

7 (7.00%)

Female

N (%)

4 (4.00%)

1975-09-01 to 1975-09-30

overall

overall

N (%)

11 (11.00%)

\<=60

overall

N (%)

11 (11.00%)

overall

Male

N (%)

7 (7.00%)

Female

N (%)

4 (4.00%)

\<=60

Male

N (%)

7 (7.00%)

Female

N (%)

4 (4.00%)

1975-10-01 to 1975-10-31

overall

overall

N (%)

11 (11.00%)

\<=60

overall

N (%)

11 (11.00%)

overall

Male

N (%)

7 (7.00%)

Female

N (%)

4 (4.00%)

\<=60

Male

N (%)

7 (7.00%)

Female

N (%)

4 (4.00%)

1975-11-01 to 1975-11-30

overall

overall

N (%)

12 (12.00%)

\<=60

overall

N (%)

12 (12.00%)

overall

Male

N (%)

7 (7.00%)

Female

N (%)

5 (5.00%)

\<=60

Male

N (%)

7 (7.00%)

Female

N (%)

5 (5.00%)

1975-12-01 to 1975-12-31

overall

overall

N (%)

12 (12.00%)

\<=60

overall

N (%)

12 (12.00%)

overall

Male

N (%)

7 (7.00%)

Female

N (%)

5 (5.00%)

\<=60

Male

N (%)

7 (7.00%)

Female

N (%)

5 (5.00%)

1976-01-01 to 1976-01-31

overall

overall

N (%)

12 (12.00%)

\<=60

overall

N (%)

12 (12.00%)

overall

Male

N (%)

7 (7.00%)

Female

N (%)

5 (5.00%)

\<=60

Male

N (%)

7 (7.00%)

Female

N (%)

5 (5.00%)

1976-02-01 to 1976-02-29

overall

overall

N (%)

12 (12.00%)

\<=60

overall

N (%)

12 (12.00%)

overall

Male

N (%)

7 (7.00%)

Female

N (%)

5 (5.00%)

\<=60

Male

N (%)

7 (7.00%)

Female

N (%)

5 (5.00%)

1976-03-01 to 1976-03-31

overall

overall

N (%)

12 (12.00%)

\<=60

overall

N (%)

12 (12.00%)

overall

Male

N (%)

7 (7.00%)

Female

N (%)

5 (5.00%)

\<=60

Male

N (%)

7 (7.00%)

Female

N (%)

5 (5.00%)

1976-04-01 to 1976-04-30

overall

overall

N (%)

12 (12.00%)

\<=60

overall

N (%)

12 (12.00%)

overall

Male

N (%)

7 (7.00%)

Female

N (%)

5 (5.00%)

\<=60

Male

N (%)

7 (7.00%)

Female

N (%)

5 (5.00%)

1976-05-01 to 1976-05-31

overall

overall

N (%)

12 (12.00%)

\<=60

overall

N (%)

12 (12.00%)

overall

Male

N (%)

7 (7.00%)

Female

N (%)

5 (5.00%)

\<=60

Male

N (%)

7 (7.00%)

Female

N (%)

5 (5.00%)

1976-06-01 to 1976-06-30

overall

overall

N (%)

12 (12.00%)

\<=60

overall

N (%)

12 (12.00%)

overall

Male

N (%)

7 (7.00%)

Female

N (%)

5 (5.00%)

\<=60

Male

N (%)

7 (7.00%)

Female

N (%)

5 (5.00%)

1976-07-01 to 1976-07-31

overall

overall

N (%)

12 (12.00%)

\<=60

overall

N (%)

12 (12.00%)

overall

Male

N (%)

7 (7.00%)

Female

N (%)

5 (5.00%)

\<=60

Male

N (%)

7 (7.00%)

Female

N (%)

5 (5.00%)

1976-08-01 to 1976-08-31

overall

overall

N (%)

12 (12.00%)

\<=60

overall

N (%)

12 (12.00%)

overall

Male

N (%)

7 (7.00%)

Female

N (%)

5 (5.00%)

\<=60

Male

N (%)

7 (7.00%)

Female

N (%)

5 (5.00%)

1976-09-01 to 1976-09-30

overall

overall

N (%)

12 (12.00%)

\<=60

overall

N (%)

12 (12.00%)

overall

Male

N (%)

7 (7.00%)

Female

N (%)

5 (5.00%)

\<=60

Male

N (%)

7 (7.00%)

Female

N (%)

5 (5.00%)

1976-10-01 to 1976-10-31

overall

overall

N (%)

13 (13.00%)

\<=60

overall

N (%)

13 (13.00%)

overall

Female

N (%)

6 (6.00%)

Male

N (%)

7 (7.00%)

\<=60

Female

N (%)

6 (6.00%)

Male

N (%)

7 (7.00%)

1976-11-01 to 1976-11-30

overall

overall

N (%)

13 (13.00%)

\<=60

overall

N (%)

13 (13.00%)

overall

Female

N (%)

6 (6.00%)

Male

N (%)

7 (7.00%)

\<=60

Female

N (%)

6 (6.00%)

Male

N (%)

7 (7.00%)

1976-12-01 to 1976-12-31

overall

overall

N (%)

13 (13.00%)

\<=60

overall

N (%)

13 (13.00%)

overall

Female

N (%)

6 (6.00%)

Male

N (%)

7 (7.00%)

\<=60

Female

N (%)

6 (6.00%)

Male

N (%)

7 (7.00%)

1977-01-01 to 1977-01-31

overall

overall

N (%)

13 (13.00%)

\<=60

overall

N (%)

13 (13.00%)

overall

Female

N (%)

6 (6.00%)

Male

N (%)

7 (7.00%)

\<=60

Female

N (%)

6 (6.00%)

Male

N (%)

7 (7.00%)

1977-02-01 to 1977-02-28

overall

overall

N (%)

13 (13.00%)

\<=60

overall

N (%)

13 (13.00%)

overall

Female

N (%)

6 (6.00%)

Male

N (%)

7 (7.00%)

\<=60

Female

N (%)

6 (6.00%)

Male

N (%)

7 (7.00%)

1977-03-01 to 1977-03-31

overall

overall

N (%)

13 (13.00%)

\<=60

overall

N (%)

13 (13.00%)

overall

Female

N (%)

6 (6.00%)

Male

N (%)

7 (7.00%)

\<=60

Female

N (%)

6 (6.00%)

Male

N (%)

7 (7.00%)

1977-04-01 to 1977-04-30

overall

overall

N (%)

13 (13.00%)

\<=60

overall

N (%)

13 (13.00%)

overall

Female

N (%)

6 (6.00%)

Male

N (%)

7 (7.00%)

\<=60

Female

N (%)

6 (6.00%)

Male

N (%)

7 (7.00%)

1977-05-01 to 1977-05-31

overall

overall

N (%)

13 (13.00%)

\<=60

overall

N (%)

13 (13.00%)

overall

Female

N (%)

6 (6.00%)

Male

N (%)

7 (7.00%)

\<=60

Female

N (%)

6 (6.00%)

Male

N (%)

7 (7.00%)

1977-06-01 to 1977-06-30

overall

overall

N (%)

13 (13.00%)

\<=60

overall

N (%)

13 (13.00%)

overall

Female

N (%)

6 (6.00%)

Male

N (%)

7 (7.00%)

\<=60

Female

N (%)

6 (6.00%)

Male

N (%)

7 (7.00%)

1977-07-01 to 1977-07-31

overall

overall

N (%)

14 (14.00%)

\<=60

overall

N (%)

14 (14.00%)

overall

Female

N (%)

7 (7.00%)

Male

N (%)

7 (7.00%)

\<=60

Female

N (%)

7 (7.00%)

Male

N (%)

7 (7.00%)

1977-08-01 to 1977-08-31

overall

overall

N (%)

14 (14.00%)

\<=60

overall

N (%)

14 (14.00%)

overall

Female

N (%)

7 (7.00%)

Male

N (%)

7 (7.00%)

\<=60

Female

N (%)

7 (7.00%)

Male

N (%)

7 (7.00%)

1977-09-01 to 1977-09-30

overall

overall

N (%)

14 (14.00%)

\<=60

overall

N (%)

14 (14.00%)

overall

Female

N (%)

7 (7.00%)

Male

N (%)

7 (7.00%)

\<=60

Female

N (%)

7 (7.00%)

Male

N (%)

7 (7.00%)

1977-10-01 to 1977-10-31

overall

overall

N (%)

14 (14.00%)

\<=60

overall

N (%)

14 (14.00%)

overall

Female

N (%)

7 (7.00%)

Male

N (%)

7 (7.00%)

\<=60

Female

N (%)

7 (7.00%)

Male

N (%)

7 (7.00%)

1977-11-01 to 1977-11-30

overall

overall

N (%)

14 (14.00%)

\<=60

overall

N (%)

14 (14.00%)

overall

Female

N (%)

7 (7.00%)

Male

N (%)

7 (7.00%)

\<=60

Female

N (%)

7 (7.00%)

Male

N (%)

7 (7.00%)

1977-12-01 to 1977-12-31

overall

overall

N (%)

14 (14.00%)

\<=60

overall

N (%)

14 (14.00%)

overall

Female

N (%)

7 (7.00%)

Male

N (%)

7 (7.00%)

\<=60

Female

N (%)

7 (7.00%)

Male

N (%)

7 (7.00%)

1978-01-01 to 1978-01-31

overall

overall

N (%)

14 (14.00%)

\<=60

overall

N (%)

14 (14.00%)

overall

Female

N (%)

7 (7.00%)

Male

N (%)

7 (7.00%)

\<=60

Female

N (%)

7 (7.00%)

Male

N (%)

7 (7.00%)

1978-02-01 to 1978-02-28

overall

overall

N (%)

14 (14.00%)

\<=60

overall

N (%)

14 (14.00%)

overall

Female

N (%)

7 (7.00%)

Male

N (%)

7 (7.00%)

\<=60

Female

N (%)

7 (7.00%)

Male

N (%)

7 (7.00%)

1978-03-01 to 1978-03-31

overall

overall

N (%)

14 (14.00%)

\<=60

overall

N (%)

14 (14.00%)

overall

Female

N (%)

7 (7.00%)

Male

N (%)

7 (7.00%)

\<=60

Female

N (%)

7 (7.00%)

Male

N (%)

7 (7.00%)

1978-04-01 to 1978-04-30

overall

overall

N (%)

14 (14.00%)

\<=60

overall

N (%)

14 (14.00%)

overall

Female

N (%)

7 (7.00%)

Male

N (%)

7 (7.00%)

\<=60

Female

N (%)

7 (7.00%)

Male

N (%)

7 (7.00%)

1978-05-01 to 1978-05-31

overall

overall

N (%)

15 (15.00%)

\<=60

overall

N (%)

15 (15.00%)

overall

Female

N (%)

7 (7.00%)

Male

N (%)

8 (8.00%)

\<=60

Female

N (%)

7 (7.00%)

Male

N (%)

8 (8.00%)

1978-06-01 to 1978-06-30

overall

overall

N (%)

15 (15.00%)

\<=60

overall

N (%)

15 (15.00%)

overall

Female

N (%)

7 (7.00%)

Male

N (%)

8 (8.00%)

\<=60

Female

N (%)

7 (7.00%)

Male

N (%)

8 (8.00%)

1978-07-01 to 1978-07-31

overall

overall

N (%)

15 (15.00%)

\<=60

overall

N (%)

15 (15.00%)

overall

Female

N (%)

7 (7.00%)

Male

N (%)

8 (8.00%)

\<=60

Female

N (%)

7 (7.00%)

Male

N (%)

8 (8.00%)

1978-08-01 to 1978-08-31

overall

overall

N (%)

15 (15.00%)

\<=60

overall

N (%)

15 (15.00%)

overall

Female

N (%)

7 (7.00%)

Male

N (%)

8 (8.00%)

\<=60

Female

N (%)

7 (7.00%)

Male

N (%)

8 (8.00%)

1978-09-01 to 1978-09-30

overall

overall

N (%)

15 (15.00%)

\<=60

overall

N (%)

15 (15.00%)

overall

Female

N (%)

7 (7.00%)

Male

N (%)

8 (8.00%)

\<=60

Female

N (%)

7 (7.00%)

Male

N (%)

8 (8.00%)

1978-10-01 to 1978-10-31

overall

overall

N (%)

15 (15.00%)

\<=60

overall

N (%)

15 (15.00%)

overall

Female

N (%)

7 (7.00%)

Male

N (%)

8 (8.00%)

\<=60

Female

N (%)

7 (7.00%)

Male

N (%)

8 (8.00%)

1978-11-01 to 1978-11-30

overall

overall

N (%)

15 (15.00%)

\<=60

overall

N (%)

15 (15.00%)

overall

Female

N (%)

7 (7.00%)

Male

N (%)

8 (8.00%)

\<=60

Female

N (%)

7 (7.00%)

Male

N (%)

8 (8.00%)

1978-12-01 to 1978-12-31

overall

overall

N (%)

15 (15.00%)

\<=60

overall

N (%)

15 (15.00%)

overall

Female

N (%)

7 (7.00%)

Male

N (%)

8 (8.00%)

\<=60

Female

N (%)

7 (7.00%)

Male

N (%)

8 (8.00%)

1979-01-01 to 1979-01-31

overall

overall

N (%)

15 (15.00%)

\<=60

overall

N (%)

15 (15.00%)

overall

Female

N (%)

7 (7.00%)

Male

N (%)

8 (8.00%)

\<=60

Female

N (%)

7 (7.00%)

Male

N (%)

8 (8.00%)

1979-02-01 to 1979-02-28

overall

overall

N (%)

16 (16.00%)

\<=60

overall

N (%)

16 (16.00%)

overall

Female

N (%)

7 (7.00%)

Male

N (%)

9 (9.00%)

\<=60

Female

N (%)

7 (7.00%)

Male

N (%)

9 (9.00%)

1979-03-01 to 1979-03-31

overall

overall

N (%)

16 (16.00%)

\<=60

overall

N (%)

16 (16.00%)

overall

Female

N (%)

7 (7.00%)

Male

N (%)

9 (9.00%)

\<=60

Female

N (%)

7 (7.00%)

Male

N (%)

9 (9.00%)

1979-04-01 to 1979-04-30

overall

overall

N (%)

16 (16.00%)

\<=60

overall

N (%)

16 (16.00%)

overall

Female

N (%)

7 (7.00%)

Male

N (%)

9 (9.00%)

\<=60

Female

N (%)

7 (7.00%)

Male

N (%)

9 (9.00%)

1979-05-01 to 1979-05-31

overall

overall

N (%)

16 (16.00%)

\<=60

overall

N (%)

16 (16.00%)

overall

Female

N (%)

7 (7.00%)

Male

N (%)

9 (9.00%)

\<=60

Female

N (%)

7 (7.00%)

Male

N (%)

9 (9.00%)

1979-06-01 to 1979-06-30

overall

overall

N (%)

16 (16.00%)

\<=60

overall

N (%)

16 (16.00%)

overall

Female

N (%)

8 (8.00%)

Male

N (%)

8 (8.00%)

\<=60

Female

N (%)

8 (8.00%)

Male

N (%)

8 (8.00%)

1979-07-01 to 1979-07-31

overall

overall

N (%)

17 (17.00%)

\<=60

overall

N (%)

17 (17.00%)

overall

Female

N (%)

9 (9.00%)

Male

N (%)

8 (8.00%)

\<=60

Female

N (%)

9 (9.00%)

Male

N (%)

8 (8.00%)

1979-08-01 to 1979-08-31

overall

overall

N (%)

17 (17.00%)

\<=60

overall

N (%)

17 (17.00%)

overall

Female

N (%)

9 (9.00%)

Male

N (%)

8 (8.00%)

\<=60

Female

N (%)

9 (9.00%)

Male

N (%)

8 (8.00%)

1979-09-01 to 1979-09-30

overall

overall

N (%)

17 (17.00%)

\<=60

overall

N (%)

17 (17.00%)

overall

Female

N (%)

9 (9.00%)

Male

N (%)

8 (8.00%)

\<=60

Female

N (%)

9 (9.00%)

Male

N (%)

8 (8.00%)

1979-10-01 to 1979-10-31

overall

overall

N (%)

17 (17.00%)

\<=60

overall

N (%)

17 (17.00%)

overall

Female

N (%)

9 (9.00%)

Male

N (%)

8 (8.00%)

\<=60

Female

N (%)

9 (9.00%)

Male

N (%)

8 (8.00%)

1979-11-01 to 1979-11-30

overall

overall

N (%)

17 (17.00%)

\<=60

overall

N (%)

17 (17.00%)

overall

Female

N (%)

9 (9.00%)

Male

N (%)

8 (8.00%)

\<=60

Female

N (%)

9 (9.00%)

Male

N (%)

8 (8.00%)

1979-12-01 to 1979-12-31

overall

overall

N (%)

17 (17.00%)

\<=60

overall

N (%)

17 (17.00%)

overall

Female

N (%)

9 (9.00%)

Male

N (%)

8 (8.00%)

\<=60

Female

N (%)

9 (9.00%)

Male

N (%)

8 (8.00%)

1980-01-01 to 1980-01-31

overall

overall

N (%)

17 (17.00%)

\<=60

overall

N (%)

17 (17.00%)

overall

Female

N (%)

9 (9.00%)

Male

N (%)

8 (8.00%)

\<=60

Female

N (%)

9 (9.00%)

Male

N (%)

8 (8.00%)

1980-02-01 to 1980-02-29

overall

overall

N (%)

17 (17.00%)

\<=60

overall

N (%)

17 (17.00%)

overall

Female

N (%)

9 (9.00%)

Male

N (%)

8 (8.00%)

\<=60

Female

N (%)

9 (9.00%)

Male

N (%)

8 (8.00%)

1980-03-01 to 1980-03-31

overall

overall

N (%)

17 (17.00%)

\<=60

overall

N (%)

17 (17.00%)

overall

Female

N (%)

9 (9.00%)

Male

N (%)

8 (8.00%)

\<=60

Female

N (%)

9 (9.00%)

Male

N (%)

8 (8.00%)

1980-04-01 to 1980-04-30

overall

overall

N (%)

17 (17.00%)

\<=60

overall

N (%)

17 (17.00%)

overall

Female

N (%)

9 (9.00%)

Male

N (%)

8 (8.00%)

\<=60

Female

N (%)

9 (9.00%)

Male

N (%)

8 (8.00%)

1980-05-01 to 1980-05-31

overall

overall

N (%)

17 (17.00%)

\<=60

overall

N (%)

17 (17.00%)

overall

Female

N (%)

9 (9.00%)

Male

N (%)

8 (8.00%)

\<=60

Female

N (%)

9 (9.00%)

Male

N (%)

8 (8.00%)

1980-06-01 to 1980-06-30

overall

overall

N (%)

16 (16.00%)

\<=60

overall

N (%)

16 (16.00%)

overall

Male

N (%)

8 (8.00%)

Female

N (%)

8 (8.00%)

\<=60

Male

N (%)

8 (8.00%)

Female

N (%)

8 (8.00%)

1980-07-01 to 1980-07-31

overall

overall

N (%)

16 (16.00%)

\<=60

overall

N (%)

16 (16.00%)

overall

Male

N (%)

8 (8.00%)

Female

N (%)

8 (8.00%)

\<=60

Male

N (%)

8 (8.00%)

Female

N (%)

8 (8.00%)

1980-08-01 to 1980-08-31

overall

overall

N (%)

16 (16.00%)

\<=60

overall

N (%)

16 (16.00%)

overall

Male

N (%)

8 (8.00%)

Female

N (%)

8 (8.00%)

\<=60

Male

N (%)

8 (8.00%)

Female

N (%)

8 (8.00%)

1980-09-01 to 1980-09-30

overall

overall

N (%)

17 (17.00%)

\<=60

overall

N (%)

17 (17.00%)

overall

Male

N (%)

8 (8.00%)

Female

N (%)

9 (9.00%)

\<=60

Male

N (%)

8 (8.00%)

Female

N (%)

9 (9.00%)

1980-10-01 to 1980-10-31

overall

overall

N (%)

17 (17.00%)

\<=60

overall

N (%)

17 (17.00%)

overall

Male

N (%)

8 (8.00%)

Female

N (%)

9 (9.00%)

\<=60

Male

N (%)

8 (8.00%)

Female

N (%)

9 (9.00%)

1980-11-01 to 1980-11-30

overall

overall

N (%)

16 (16.00%)

\<=60

overall

N (%)

16 (16.00%)

overall

Male

N (%)

7 (7.00%)

Female

N (%)

9 (9.00%)

\<=60

Male

N (%)

7 (7.00%)

Female

N (%)

9 (9.00%)

1980-12-01 to 1980-12-31

overall

overall

N (%)

16 (16.00%)

\<=60

overall

N (%)

16 (16.00%)

overall

Male

N (%)

7 (7.00%)

Female

N (%)

9 (9.00%)

\<=60

Male

N (%)

7 (7.00%)

Female

N (%)

9 (9.00%)

1981-01-01 to 1981-01-31

overall

overall

N (%)

16 (16.00%)

\<=60

overall

N (%)

16 (16.00%)

overall

Male

N (%)

7 (7.00%)

Female

N (%)

9 (9.00%)

\<=60

Male

N (%)

7 (7.00%)

Female

N (%)

9 (9.00%)

1981-02-01 to 1981-02-28

overall

overall

N (%)

16 (16.00%)

\<=60

overall

N (%)

16 (16.00%)

overall

Male

N (%)

7 (7.00%)

Female

N (%)

9 (9.00%)

\<=60

Male

N (%)

7 (7.00%)

Female

N (%)

9 (9.00%)

1981-03-01 to 1981-03-31

overall

overall

N (%)

16 (16.00%)

\<=60

overall

N (%)

16 (16.00%)

overall

Male

N (%)

7 (7.00%)

Female

N (%)

9 (9.00%)

\<=60

Male

N (%)

7 (7.00%)

Female

N (%)

9 (9.00%)

1981-04-01 to 1981-04-30

overall

overall

N (%)

16 (16.00%)

\<=60

overall

N (%)

16 (16.00%)

overall

Male

N (%)

7 (7.00%)

Female

N (%)

9 (9.00%)

\<=60

Male

N (%)

7 (7.00%)

Female

N (%)

9 (9.00%)

1981-05-01 to 1981-05-31

overall

overall

N (%)

16 (16.00%)

\<=60

overall

N (%)

16 (16.00%)

overall

Male

N (%)

7 (7.00%)

Female

N (%)

9 (9.00%)

\<=60

Male

N (%)

7 (7.00%)

Female

N (%)

9 (9.00%)

1981-06-01 to 1981-06-30

overall

overall

N (%)

16 (16.00%)

\<=60

overall

N (%)

16 (16.00%)

overall

Male

N (%)

7 (7.00%)

Female

N (%)

9 (9.00%)

\<=60

Male

N (%)

7 (7.00%)

Female

N (%)

9 (9.00%)

1981-07-01 to 1981-07-31

overall

overall

N (%)

16 (16.00%)

\<=60

overall

N (%)

16 (16.00%)

overall

Male

N (%)

7 (7.00%)

Female

N (%)

9 (9.00%)

\<=60

Male

N (%)

7 (7.00%)

Female

N (%)

9 (9.00%)

1981-08-01 to 1981-08-31

overall

overall

N (%)

16 (16.00%)

\<=60

overall

N (%)

16 (16.00%)

overall

Male

N (%)

7 (7.00%)

Female

N (%)

9 (9.00%)

\<=60

Male

N (%)

7 (7.00%)

Female

N (%)

9 (9.00%)

1981-09-01 to 1981-09-30

overall

overall

N (%)

16 (16.00%)

\<=60

overall

N (%)

16 (16.00%)

overall

Male

N (%)

7 (7.00%)

Female

N (%)

9 (9.00%)

\<=60

Male

N (%)

7 (7.00%)

Female

N (%)

9 (9.00%)

1981-10-01 to 1981-10-31

overall

overall

N (%)

17 (17.00%)

\<=60

overall

N (%)

17 (17.00%)

overall

Male

N (%)

8 (8.00%)

Female

N (%)

9 (9.00%)

\<=60

Male

N (%)

8 (8.00%)

Female

N (%)

9 (9.00%)

1981-11-01 to 1981-11-30

overall

overall

N (%)

19 (19.00%)

\<=60

overall

N (%)

19 (19.00%)

overall

Male

N (%)

9 (9.00%)

Female

N (%)

10 (10.00%)

\<=60

Male

N (%)

9 (9.00%)

Female

N (%)

10 (10.00%)

1981-12-01 to 1981-12-31

overall

overall

N (%)

19 (19.00%)

\<=60

overall

N (%)

19 (19.00%)

overall

Male

N (%)

9 (9.00%)

Female

N (%)

10 (10.00%)

\<=60

Male

N (%)

9 (9.00%)

Female

N (%)

10 (10.00%)

1982-01-01 to 1982-01-31

overall

overall

N (%)

19 (19.00%)

\<=60

overall

N (%)

19 (19.00%)

overall

Male

N (%)

9 (9.00%)

Female

N (%)

10 (10.00%)

\<=60

Male

N (%)

9 (9.00%)

Female

N (%)

10 (10.00%)

1982-02-01 to 1982-02-28

overall

overall

N (%)

19 (19.00%)

\<=60

overall

N (%)

19 (19.00%)

overall

Male

N (%)

9 (9.00%)

Female

N (%)

10 (10.00%)

\<=60

Male

N (%)

9 (9.00%)

Female

N (%)

10 (10.00%)

1982-03-01 to 1982-03-31

overall

overall

N (%)

19 (19.00%)

\<=60

overall

N (%)

19 (19.00%)

overall

Male

N (%)

9 (9.00%)

Female

N (%)

10 (10.00%)

\<=60

Male

N (%)

9 (9.00%)

Female

N (%)

10 (10.00%)

1982-04-01 to 1982-04-30

overall

overall

N (%)

20 (20.00%)

\<=60

overall

N (%)

20 (20.00%)

overall

Male

N (%)

10 (10.00%)

Female

N (%)

10 (10.00%)

\<=60

Male

N (%)

10 (10.00%)

Female

N (%)

10 (10.00%)

1982-05-01 to 1982-05-31

overall

overall

N (%)

20 (20.00%)

\<=60

overall

N (%)

20 (20.00%)

overall

Male

N (%)

10 (10.00%)

Female

N (%)

10 (10.00%)

\<=60

Male

N (%)

10 (10.00%)

Female

N (%)

10 (10.00%)

1982-06-01 to 1982-06-30

overall

overall

N (%)

19 (19.00%)

\<=60

overall

N (%)

19 (19.00%)

overall

Male

N (%)

10 (10.00%)

Female

N (%)

9 (9.00%)

\<=60

Male

N (%)

10 (10.00%)

Female

N (%)

9 (9.00%)

1982-07-01 to 1982-07-31

overall

overall

N (%)

19 (19.00%)

\<=60

overall

N (%)

19 (19.00%)

overall

Male

N (%)

10 (10.00%)

Female

N (%)

9 (9.00%)

\<=60

Male

N (%)

10 (10.00%)

Female

N (%)

9 (9.00%)

1982-08-01 to 1982-08-31

overall

overall

N (%)

19 (19.00%)

\<=60

overall

N (%)

19 (19.00%)

overall

Male

N (%)

10 (10.00%)

Female

N (%)

9 (9.00%)

\<=60

Male

N (%)

10 (10.00%)

Female

N (%)

9 (9.00%)

1982-09-01 to 1982-09-30

overall

overall

N (%)

19 (19.00%)

\<=60

overall

N (%)

19 (19.00%)

overall

Male

N (%)

10 (10.00%)

Female

N (%)

9 (9.00%)

\<=60

Male

N (%)

10 (10.00%)

Female

N (%)

9 (9.00%)

1982-10-01 to 1982-10-31

overall

overall

N (%)

19 (19.00%)

\<=60

overall

N (%)

19 (19.00%)

overall

Male

N (%)

10 (10.00%)

Female

N (%)

9 (9.00%)

\<=60

Male

N (%)

10 (10.00%)

Female

N (%)

9 (9.00%)

1982-11-01 to 1982-11-30

overall

overall

N (%)

19 (19.00%)

\<=60

overall

N (%)

19 (19.00%)

overall

Male

N (%)

10 (10.00%)

Female

N (%)

9 (9.00%)

\<=60

Male

N (%)

10 (10.00%)

Female

N (%)

9 (9.00%)

1982-12-01 to 1982-12-31

overall

overall

N (%)

19 (19.00%)

\<=60

overall

N (%)

19 (19.00%)

overall

Male

N (%)

10 (10.00%)

Female

N (%)

9 (9.00%)

\<=60

Male

N (%)

10 (10.00%)

Female

N (%)

9 (9.00%)

1983-01-01 to 1983-01-31

overall

overall

N (%)

20 (20.00%)

\<=60

overall

N (%)

20 (20.00%)

overall

Male

N (%)

11 (11.00%)

Female

N (%)

9 (9.00%)

\<=60

Male

N (%)

11 (11.00%)

Female

N (%)

9 (9.00%)

1983-02-01 to 1983-02-28

overall

overall

N (%)

20 (20.00%)

\<=60

overall

N (%)

20 (20.00%)

overall

Male

N (%)

11 (11.00%)

Female

N (%)

9 (9.00%)

\<=60

Male

N (%)

11 (11.00%)

Female

N (%)

9 (9.00%)

1983-03-01 to 1983-03-31

overall

overall

N (%)

20 (20.00%)

\<=60

overall

N (%)

20 (20.00%)

overall

Male

N (%)

11 (11.00%)

Female

N (%)

9 (9.00%)

\<=60

Male

N (%)

11 (11.00%)

Female

N (%)

9 (9.00%)

1983-04-01 to 1983-04-30

overall

overall

N (%)

21 (21.00%)

\<=60

overall

N (%)

21 (21.00%)

overall

Male

N (%)

11 (11.00%)

Female

N (%)

10 (10.00%)

\<=60

Male

N (%)

11 (11.00%)

Female

N (%)

10 (10.00%)

1983-05-01 to 1983-05-31

overall

overall

N (%)

21 (21.00%)

\<=60

overall

N (%)

21 (21.00%)

overall

Male

N (%)

11 (11.00%)

Female

N (%)

10 (10.00%)

\<=60

Male

N (%)

11 (11.00%)

Female

N (%)

10 (10.00%)

1983-06-01 to 1983-06-30

overall

overall

N (%)

21 (21.00%)

\<=60

overall

N (%)

21 (21.00%)

overall

Male

N (%)

11 (11.00%)

Female

N (%)

10 (10.00%)

\<=60

Male

N (%)

11 (11.00%)

Female

N (%)

10 (10.00%)

1983-07-01 to 1983-07-31

overall

overall

N (%)

21 (21.00%)

\<=60

overall

N (%)

21 (21.00%)

overall

Male

N (%)

11 (11.00%)

Female

N (%)

10 (10.00%)

\<=60

Male

N (%)

11 (11.00%)

Female

N (%)

10 (10.00%)

1983-08-01 to 1983-08-31

overall

overall

N (%)

21 (21.00%)

\<=60

overall

N (%)

21 (21.00%)

overall

Male

N (%)

11 (11.00%)

Female

N (%)

10 (10.00%)

\<=60

Male

N (%)

11 (11.00%)

Female

N (%)

10 (10.00%)

1983-09-01 to 1983-09-30

overall

overall

N (%)

21 (21.00%)

\<=60

overall

N (%)

21 (21.00%)

overall

Male

N (%)

11 (11.00%)

Female

N (%)

10 (10.00%)

\<=60

Male

N (%)

11 (11.00%)

Female

N (%)

10 (10.00%)

1983-10-01 to 1983-10-31

overall

overall

N (%)

21 (21.00%)

\<=60

overall

N (%)

21 (21.00%)

overall

Male

N (%)

11 (11.00%)

Female

N (%)

10 (10.00%)

\<=60

Male

N (%)

11 (11.00%)

Female

N (%)

10 (10.00%)

1983-11-01 to 1983-11-30

overall

overall

N (%)

21 (21.00%)

\<=60

overall

N (%)

21 (21.00%)

overall

Male

N (%)

11 (11.00%)

Female

N (%)

10 (10.00%)

\<=60

Male

N (%)

11 (11.00%)

Female

N (%)

10 (10.00%)

1983-12-01 to 1983-12-31

overall

overall

N (%)

21 (21.00%)

\<=60

overall

N (%)

21 (21.00%)

overall

Male

N (%)

11 (11.00%)

Female

N (%)

10 (10.00%)

\<=60

Male

N (%)

11 (11.00%)

Female

N (%)

10 (10.00%)

1984-01-01 to 1984-01-31

overall

overall

N (%)

21 (21.00%)

\<=60

overall

N (%)

21 (21.00%)

overall

Male

N (%)

11 (11.00%)

Female

N (%)

10 (10.00%)

\<=60

Male

N (%)

11 (11.00%)

Female

N (%)

10 (10.00%)

1984-02-01 to 1984-02-29

overall

overall

N (%)

22 (22.00%)

\<=60

overall

N (%)

22 (22.00%)

overall

Male

N (%)

11 (11.00%)

Female

N (%)

11 (11.00%)

\<=60

Male

N (%)

11 (11.00%)

Female

N (%)

11 (11.00%)

1984-03-01 to 1984-03-31

overall

overall

N (%)

22 (22.00%)

\<=60

overall

N (%)

22 (22.00%)

overall

Male

N (%)

11 (11.00%)

Female

N (%)

11 (11.00%)

\<=60

Male

N (%)

11 (11.00%)

Female

N (%)

11 (11.00%)

1984-04-01 to 1984-04-30

overall

overall

N (%)

22 (22.00%)

\<=60

overall

N (%)

22 (22.00%)

overall

Male

N (%)

11 (11.00%)

Female

N (%)

11 (11.00%)

\<=60

Male

N (%)

11 (11.00%)

Female

N (%)

11 (11.00%)

1984-05-01 to 1984-05-31

overall

overall

N (%)

22 (22.00%)

\<=60

overall

N (%)

22 (22.00%)

overall

Male

N (%)

11 (11.00%)

Female

N (%)

11 (11.00%)

\<=60

Male

N (%)

11 (11.00%)

Female

N (%)

11 (11.00%)

1984-06-01 to 1984-06-30

overall

overall

N (%)

22 (22.00%)

\<=60

overall

N (%)

22 (22.00%)

overall

Male

N (%)

11 (11.00%)

Female

N (%)

11 (11.00%)

\<=60

Male

N (%)

11 (11.00%)

Female

N (%)

11 (11.00%)

1984-07-01 to 1984-07-31

overall

overall

N (%)

22 (22.00%)

\<=60

overall

N (%)

22 (22.00%)

overall

Male

N (%)

11 (11.00%)

Female

N (%)

11 (11.00%)

\<=60

Male

N (%)

11 (11.00%)

Female

N (%)

11 (11.00%)

1984-08-01 to 1984-08-31

overall

overall

N (%)

22 (22.00%)

\<=60

overall

N (%)

22 (22.00%)

overall

Male

N (%)

11 (11.00%)

Female

N (%)

11 (11.00%)

\<=60

Male

N (%)

11 (11.00%)

Female

N (%)

11 (11.00%)

1984-09-01 to 1984-09-30

overall

overall

N (%)

22 (22.00%)

\<=60

overall

N (%)

22 (22.00%)

overall

Male

N (%)

11 (11.00%)

Female

N (%)

11 (11.00%)

\<=60

Male

N (%)

11 (11.00%)

Female

N (%)

11 (11.00%)

1984-10-01 to 1984-10-31

overall

overall

N (%)

22 (22.00%)

\<=60

overall

N (%)

22 (22.00%)

overall

Male

N (%)

11 (11.00%)

Female

N (%)

11 (11.00%)

\<=60

Male

N (%)

11 (11.00%)

Female

N (%)

11 (11.00%)

1984-11-01 to 1984-11-30

overall

overall

N (%)

22 (22.00%)

\<=60

overall

N (%)

22 (22.00%)

overall

Male

N (%)

11 (11.00%)

Female

N (%)

11 (11.00%)

\<=60

Male

N (%)

11 (11.00%)

Female

N (%)

11 (11.00%)

1984-12-01 to 1984-12-31

overall

overall

N (%)

22 (22.00%)

\<=60

overall

N (%)

22 (22.00%)

overall

Male

N (%)

11 (11.00%)

Female

N (%)

11 (11.00%)

\<=60

Male

N (%)

11 (11.00%)

Female

N (%)

11 (11.00%)

1985-01-01 to 1985-01-31

overall

overall

N (%)

22 (22.00%)

\<=60

overall

N (%)

22 (22.00%)

overall

Male

N (%)

11 (11.00%)

Female

N (%)

11 (11.00%)

\<=60

Male

N (%)

11 (11.00%)

Female

N (%)

11 (11.00%)

1985-02-01 to 1985-02-28

overall

overall

N (%)

22 (22.00%)

\<=60

overall

N (%)

22 (22.00%)

overall

Male

N (%)

11 (11.00%)

Female

N (%)

11 (11.00%)

\<=60

Male

N (%)

11 (11.00%)

Female

N (%)

11 (11.00%)

1985-03-01 to 1985-03-31

overall

overall

N (%)

22 (22.00%)

\<=60

overall

N (%)

22 (22.00%)

overall

Male

N (%)

11 (11.00%)

Female

N (%)

11 (11.00%)

\<=60

Male

N (%)

11 (11.00%)

Female

N (%)

11 (11.00%)

1985-04-01 to 1985-04-30

overall

overall

N (%)

22 (22.00%)

\<=60

overall

N (%)

22 (22.00%)

overall

Male

N (%)

11 (11.00%)

Female

N (%)

11 (11.00%)

\<=60

Male

N (%)

11 (11.00%)

Female

N (%)

11 (11.00%)

1985-05-01 to 1985-05-31

overall

overall

N (%)

22 (22.00%)

\<=60

overall

N (%)

22 (22.00%)

overall

Male

N (%)

11 (11.00%)

Female

N (%)

11 (11.00%)

\<=60

Male

N (%)

11 (11.00%)

Female

N (%)

11 (11.00%)

1985-06-01 to 1985-06-30

overall

overall

N (%)

22 (22.00%)

\<=60

overall

N (%)

22 (22.00%)

overall

Male

N (%)

11 (11.00%)

Female

N (%)

11 (11.00%)

\<=60

Male

N (%)

11 (11.00%)

Female

N (%)

11 (11.00%)

1985-07-01 to 1985-07-31

overall

overall

N (%)

22 (22.00%)

\<=60

overall

N (%)

22 (22.00%)

overall

Male

N (%)

11 (11.00%)

Female

N (%)

11 (11.00%)

\<=60

Male

N (%)

11 (11.00%)

Female

N (%)

11 (11.00%)

1985-08-01 to 1985-08-31

overall

overall

N (%)

22 (22.00%)

\<=60

overall

N (%)

22 (22.00%)

overall

Male

N (%)

11 (11.00%)

Female

N (%)

11 (11.00%)

\<=60

Male

N (%)

11 (11.00%)

Female

N (%)

11 (11.00%)

1985-09-01 to 1985-09-30

overall

overall

N (%)

22 (22.00%)

\<=60

overall

N (%)

22 (22.00%)

overall

Male

N (%)

11 (11.00%)

Female

N (%)

11 (11.00%)

\<=60

Male

N (%)

11 (11.00%)

Female

N (%)

11 (11.00%)

1985-10-01 to 1985-10-31

overall

overall

N (%)

22 (22.00%)

\<=60

overall

N (%)

22 (22.00%)

overall

Male

N (%)

11 (11.00%)

Female

N (%)

11 (11.00%)

\<=60

Male

N (%)

11 (11.00%)

Female

N (%)

11 (11.00%)

1985-11-01 to 1985-11-30

overall

overall

N (%)

21 (21.00%)

\<=60

overall

N (%)

21 (21.00%)

overall

Male

N (%)

10 (10.00%)

Female

N (%)

11 (11.00%)

\<=60

Male

N (%)

10 (10.00%)

Female

N (%)

11 (11.00%)

1985-12-01 to 1985-12-31

overall

overall

N (%)

21 (21.00%)

\<=60

overall

N (%)

21 (21.00%)

overall

Male

N (%)

10 (10.00%)

Female

N (%)

11 (11.00%)

\<=60

Male

N (%)

10 (10.00%)

Female

N (%)

11 (11.00%)

1986-01-01 to 1986-01-31

overall

overall

N (%)

21 (21.00%)

\<=60

overall

N (%)

21 (21.00%)

overall

Male

N (%)

10 (10.00%)

Female

N (%)

11 (11.00%)

\<=60

Male

N (%)

10 (10.00%)

Female

N (%)

11 (11.00%)

1986-02-01 to 1986-02-28

overall

overall

N (%)

21 (21.00%)

\<=60

overall

N (%)

21 (21.00%)

overall

Male

N (%)

10 (10.00%)

Female

N (%)

11 (11.00%)

\<=60

Male

N (%)

10 (10.00%)

Female

N (%)

11 (11.00%)

1986-03-01 to 1986-03-31

overall

overall

N (%)

21 (21.00%)

\<=60

overall

N (%)

21 (21.00%)

overall

Male

N (%)

10 (10.00%)

Female

N (%)

11 (11.00%)

\<=60

Male

N (%)

10 (10.00%)

Female

N (%)

11 (11.00%)

1986-04-01 to 1986-04-30

overall

overall

N (%)

21 (21.00%)

\<=60

overall

N (%)

21 (21.00%)

overall

Male

N (%)

10 (10.00%)

Female

N (%)

11 (11.00%)

\<=60

Male

N (%)

10 (10.00%)

Female

N (%)

11 (11.00%)

1986-05-01 to 1986-05-31

overall

overall

N (%)

21 (21.00%)

\<=60

overall

N (%)

21 (21.00%)

overall

Male

N (%)

10 (10.00%)

Female

N (%)

11 (11.00%)

\<=60

Male

N (%)

10 (10.00%)

Female

N (%)

11 (11.00%)

1986-06-01 to 1986-06-30

overall

overall

N (%)

21 (21.00%)

\<=60

overall

N (%)

21 (21.00%)

overall

Male

N (%)

10 (10.00%)

Female

N (%)

11 (11.00%)

\<=60

Male

N (%)

10 (10.00%)

Female

N (%)

11 (11.00%)

1986-07-01 to 1986-07-31

overall

overall

N (%)

21 (21.00%)

\<=60

overall

N (%)

21 (21.00%)

overall

Male

N (%)

10 (10.00%)

Female

N (%)

11 (11.00%)

\<=60

Male

N (%)

10 (10.00%)

Female

N (%)

11 (11.00%)

1986-08-01 to 1986-08-31

overall

overall

N (%)

21 (21.00%)

\<=60

overall

N (%)

21 (21.00%)

overall

Male

N (%)

10 (10.00%)

Female

N (%)

11 (11.00%)

\<=60

Male

N (%)

10 (10.00%)

Female

N (%)

11 (11.00%)

1986-09-01 to 1986-09-30

overall

overall

N (%)

21 (21.00%)

\<=60

overall

N (%)

21 (21.00%)

overall

Male

N (%)

10 (10.00%)

Female

N (%)

11 (11.00%)

\<=60

Male

N (%)

10 (10.00%)

Female

N (%)

11 (11.00%)

1986-10-01 to 1986-10-31

overall

overall

N (%)

21 (21.00%)

\<=60

overall

N (%)

21 (21.00%)

overall

Male

N (%)

10 (10.00%)

Female

N (%)

11 (11.00%)

\<=60

Male

N (%)

10 (10.00%)

Female

N (%)

11 (11.00%)

1986-11-01 to 1986-11-30

overall

overall

N (%)

22 (22.00%)

\<=60

overall

N (%)

22 (22.00%)

overall

Male

N (%)

10 (10.00%)

Female

N (%)

12 (12.00%)

\<=60

Male

N (%)

10 (10.00%)

Female

N (%)

12 (12.00%)

1986-12-01 to 1986-12-31

overall

overall

N (%)

22 (22.00%)

\<=60

overall

N (%)

22 (22.00%)

overall

Male

N (%)

10 (10.00%)

Female

N (%)

12 (12.00%)

\<=60

Male

N (%)

10 (10.00%)

Female

N (%)

12 (12.00%)

1987-01-01 to 1987-01-31

overall

overall

N (%)

23 (23.00%)

\<=60

overall

N (%)

23 (23.00%)

overall

Male

N (%)

10 (10.00%)

Female

N (%)

13 (13.00%)

\<=60

Male

N (%)

10 (10.00%)

Female

N (%)

13 (13.00%)

1987-02-01 to 1987-02-28

overall

overall

N (%)

23 (23.00%)

\<=60

overall

N (%)

23 (23.00%)

overall

Male

N (%)

10 (10.00%)

Female

N (%)

13 (13.00%)

\<=60

Male

N (%)

10 (10.00%)

Female

N (%)

13 (13.00%)

1987-03-01 to 1987-03-31

overall

overall

N (%)

23 (23.00%)

\<=60

overall

N (%)

23 (23.00%)

overall

Male

N (%)

10 (10.00%)

Female

N (%)

13 (13.00%)

\<=60

Male

N (%)

10 (10.00%)

Female

N (%)

13 (13.00%)

1987-04-01 to 1987-04-30

overall

overall

N (%)

23 (23.00%)

\<=60

overall

N (%)

23 (23.00%)

overall

Male

N (%)

10 (10.00%)

Female

N (%)

13 (13.00%)

\<=60

Male

N (%)

10 (10.00%)

Female

N (%)

13 (13.00%)

1987-05-01 to 1987-05-31

overall

overall

N (%)

23 (23.00%)

\<=60

overall

N (%)

23 (23.00%)

overall

Male

N (%)

10 (10.00%)

Female

N (%)

13 (13.00%)

\<=60

Male

N (%)

10 (10.00%)

Female

N (%)

13 (13.00%)

1987-06-01 to 1987-06-30

overall

overall

N (%)

23 (23.00%)

\<=60

overall

N (%)

23 (23.00%)

overall

Male

N (%)

10 (10.00%)

Female

N (%)

13 (13.00%)

\<=60

Male

N (%)

10 (10.00%)

Female

N (%)

13 (13.00%)

1987-07-01 to 1987-07-31

overall

overall

N (%)

24 (24.00%)

\<=60

overall

N (%)

24 (24.00%)

overall

Male

N (%)

11 (11.00%)

Female

N (%)

13 (13.00%)

\<=60

Male

N (%)

11 (11.00%)

Female

N (%)

13 (13.00%)

1987-08-01 to 1987-08-31

overall

overall

N (%)

24 (24.00%)

\<=60

overall

N (%)

24 (24.00%)

overall

Male

N (%)

11 (11.00%)

Female

N (%)

13 (13.00%)

\<=60

Male

N (%)

11 (11.00%)

Female

N (%)

13 (13.00%)

1987-09-01 to 1987-09-30

overall

overall

N (%)

24 (24.00%)

\<=60

overall

N (%)

24 (24.00%)

overall

Male

N (%)

11 (11.00%)

Female

N (%)

13 (13.00%)

\<=60

Male

N (%)

11 (11.00%)

Female

N (%)

13 (13.00%)

1987-10-01 to 1987-10-31

overall

overall

N (%)

24 (24.00%)

\<=60

overall

N (%)

24 (24.00%)

overall

Male

N (%)

11 (11.00%)

Female

N (%)

13 (13.00%)

\<=60

Male

N (%)

11 (11.00%)

Female

N (%)

13 (13.00%)

1987-11-01 to 1987-11-30

overall

overall

N (%)

24 (24.00%)

\<=60

overall

N (%)

24 (24.00%)

overall

Male

N (%)

11 (11.00%)

Female

N (%)

13 (13.00%)

\<=60

Male

N (%)

11 (11.00%)

Female

N (%)

13 (13.00%)

1987-12-01 to 1987-12-31

overall

overall

N (%)

24 (24.00%)

\<=60

overall

N (%)

24 (24.00%)

overall

Male

N (%)

11 (11.00%)

Female

N (%)

13 (13.00%)

\<=60

Male

N (%)

11 (11.00%)

Female

N (%)

13 (13.00%)

1988-01-01 to 1988-01-31

overall

overall

N (%)

24 (24.00%)

\<=60

overall

N (%)

24 (24.00%)

overall

Male

N (%)

11 (11.00%)

Female

N (%)

13 (13.00%)

\<=60

Male

N (%)

11 (11.00%)

Female

N (%)

13 (13.00%)

1988-02-01 to 1988-02-29

overall

overall

N (%)

24 (24.00%)

\<=60

overall

N (%)

24 (24.00%)

overall

Male

N (%)

11 (11.00%)

Female

N (%)

13 (13.00%)

\<=60

Male

N (%)

11 (11.00%)

Female

N (%)

13 (13.00%)

1988-03-01 to 1988-03-31

overall

overall

N (%)

24 (24.00%)

\<=60

overall

N (%)

24 (24.00%)

overall

Male

N (%)

11 (11.00%)

Female

N (%)

13 (13.00%)

\<=60

Male

N (%)

11 (11.00%)

Female

N (%)

13 (13.00%)

1988-04-01 to 1988-04-30

overall

overall

N (%)

24 (24.00%)

\<=60

overall

N (%)

24 (24.00%)

overall

Male

N (%)

11 (11.00%)

Female

N (%)

13 (13.00%)

\<=60

Male

N (%)

11 (11.00%)

Female

N (%)

13 (13.00%)

1988-05-01 to 1988-05-31

overall

overall

N (%)

24 (24.00%)

\<=60

overall

N (%)

24 (24.00%)

overall

Male

N (%)

11 (11.00%)

Female

N (%)

13 (13.00%)

\<=60

Male

N (%)

11 (11.00%)

Female

N (%)

13 (13.00%)

1988-06-01 to 1988-06-30

overall

overall

N (%)

24 (24.00%)

\<=60

overall

N (%)

24 (24.00%)

overall

Male

N (%)

11 (11.00%)

Female

N (%)

13 (13.00%)

\<=60

Male

N (%)

11 (11.00%)

Female

N (%)

13 (13.00%)

1988-07-01 to 1988-07-31

overall

overall

N (%)

25 (25.00%)

\<=60

overall

N (%)

25 (25.00%)

overall

Male

N (%)

11 (11.00%)

Female

N (%)

14 (14.00%)

\<=60

Male

N (%)

11 (11.00%)

Female

N (%)

14 (14.00%)

1988-08-01 to 1988-08-31

overall

overall

N (%)

25 (25.00%)

\<=60

overall

N (%)

25 (25.00%)

overall

Male

N (%)

11 (11.00%)

Female

N (%)

14 (14.00%)

\<=60

Male

N (%)

11 (11.00%)

Female

N (%)

14 (14.00%)

1988-09-01 to 1988-09-30

overall

overall

N (%)

25 (25.00%)

\<=60

overall

N (%)

25 (25.00%)

overall

Male

N (%)

11 (11.00%)

Female

N (%)

14 (14.00%)

\<=60

Male

N (%)

11 (11.00%)

Female

N (%)

14 (14.00%)

1988-10-01 to 1988-10-31

overall

overall

N (%)

25 (25.00%)

\<=60

overall

N (%)

25 (25.00%)

overall

Male

N (%)

11 (11.00%)

Female

N (%)

14 (14.00%)

\<=60

Male

N (%)

11 (11.00%)

Female

N (%)

14 (14.00%)

1988-11-01 to 1988-11-30

overall

overall

N (%)

25 (25.00%)

\<=60

overall

N (%)

25 (25.00%)

overall

Male

N (%)

11 (11.00%)

Female

N (%)

14 (14.00%)

\<=60

Male

N (%)

11 (11.00%)

Female

N (%)

14 (14.00%)

1988-12-01 to 1988-12-31

overall

overall

N (%)

25 (25.00%)

\<=60

overall

N (%)

25 (25.00%)

overall

Male

N (%)

11 (11.00%)

Female

N (%)

14 (14.00%)

\<=60

Male

N (%)

11 (11.00%)

Female

N (%)

14 (14.00%)

1989-01-01 to 1989-01-31

overall

overall

N (%)

25 (25.00%)

\<=60

overall

N (%)

25 (25.00%)

overall

Male

N (%)

11 (11.00%)

Female

N (%)

14 (14.00%)

\<=60

Male

N (%)

11 (11.00%)

Female

N (%)

14 (14.00%)

1989-02-01 to 1989-02-28

overall

overall

N (%)

25 (25.00%)

\<=60

overall

N (%)

25 (25.00%)

overall

Male

N (%)

11 (11.00%)

Female

N (%)

14 (14.00%)

\<=60

Male

N (%)

11 (11.00%)

Female

N (%)

14 (14.00%)

1989-03-01 to 1989-03-31

overall

overall

N (%)

26 (26.00%)

\<=60

overall

N (%)

26 (26.00%)

overall

Male

N (%)

11 (11.00%)

Female

N (%)

15 (15.00%)

\<=60

Male

N (%)

11 (11.00%)

Female

N (%)

15 (15.00%)

1989-04-01 to 1989-04-30

overall

overall

N (%)

26 (26.00%)

\<=60

overall

N (%)

26 (26.00%)

overall

Male

N (%)

11 (11.00%)

Female

N (%)

15 (15.00%)

\<=60

Male

N (%)

11 (11.00%)

Female

N (%)

15 (15.00%)

1989-05-01 to 1989-05-31

overall

overall

N (%)

27 (27.00%)

\<=60

overall

N (%)

27 (27.00%)

overall

Male

N (%)

12 (12.00%)

Female

N (%)

15 (15.00%)

\<=60

Male

N (%)

12 (12.00%)

Female

N (%)

15 (15.00%)

1989-06-01 to 1989-06-30

overall

overall

N (%)

27 (27.00%)

\<=60

overall

N (%)

27 (27.00%)

overall

Male

N (%)

12 (12.00%)

Female

N (%)

15 (15.00%)

\<=60

Male

N (%)

12 (12.00%)

Female

N (%)

15 (15.00%)

1989-07-01 to 1989-07-31

overall

overall

N (%)

27 (27.00%)

\<=60

overall

N (%)

27 (27.00%)

overall

Male

N (%)

12 (12.00%)

Female

N (%)

15 (15.00%)

\<=60

Male

N (%)

12 (12.00%)

Female

N (%)

15 (15.00%)

1989-08-01 to 1989-08-31

overall

overall

N (%)

27 (27.00%)

\<=60

overall

N (%)

27 (27.00%)

overall

Male

N (%)

12 (12.00%)

Female

N (%)

15 (15.00%)

\<=60

Male

N (%)

12 (12.00%)

Female

N (%)

15 (15.00%)

1989-09-01 to 1989-09-30

overall

overall

N (%)

27 (27.00%)

\<=60

overall

N (%)

27 (27.00%)

overall

Male

N (%)

12 (12.00%)

Female

N (%)

15 (15.00%)

\<=60

Male

N (%)

12 (12.00%)

Female

N (%)

15 (15.00%)

1989-10-01 to 1989-10-31

overall

overall

N (%)

27 (27.00%)

\<=60

overall

N (%)

27 (27.00%)

overall

Male

N (%)

12 (12.00%)

Female

N (%)

15 (15.00%)

\<=60

Male

N (%)

12 (12.00%)

Female

N (%)

15 (15.00%)

1989-11-01 to 1989-11-30

overall

overall

N (%)

27 (27.00%)

\<=60

overall

N (%)

27 (27.00%)

overall

Male

N (%)

12 (12.00%)

Female

N (%)

15 (15.00%)

\<=60

Male

N (%)

12 (12.00%)

Female

N (%)

15 (15.00%)

1989-12-01 to 1989-12-31

overall

overall

N (%)

27 (27.00%)

\<=60

overall

N (%)

27 (27.00%)

overall

Male

N (%)

12 (12.00%)

Female

N (%)

15 (15.00%)

\<=60

Male

N (%)

12 (12.00%)

Female

N (%)

15 (15.00%)

1990-01-01 to 1990-01-31

overall

overall

N (%)

27 (27.00%)

\<=60

overall

N (%)

27 (27.00%)

overall

Male

N (%)

12 (12.00%)

Female

N (%)

15 (15.00%)

\<=60

Male

N (%)

12 (12.00%)

Female

N (%)

15 (15.00%)

1990-02-01 to 1990-02-28

overall

overall

N (%)

26 (26.00%)

\<=60

overall

N (%)

26 (26.00%)

overall

Male

N (%)

11 (11.00%)

Female

N (%)

15 (15.00%)

\<=60

Male

N (%)

11 (11.00%)

Female

N (%)

15 (15.00%)

1990-03-01 to 1990-03-31

overall

overall

N (%)

26 (26.00%)

\<=60

overall

N (%)

26 (26.00%)

overall

Male

N (%)

11 (11.00%)

Female

N (%)

15 (15.00%)

\<=60

Male

N (%)

11 (11.00%)

Female

N (%)

15 (15.00%)

1990-04-01 to 1990-04-30

overall

overall

N (%)

26 (26.00%)

\<=60

overall

N (%)

26 (26.00%)

overall

Male

N (%)

11 (11.00%)

Female

N (%)

15 (15.00%)

\<=60

Male

N (%)

11 (11.00%)

Female

N (%)

15 (15.00%)

1990-05-01 to 1990-05-31

overall

overall

N (%)

26 (26.00%)

\<=60

overall

N (%)

26 (26.00%)

overall

Male

N (%)

11 (11.00%)

Female

N (%)

15 (15.00%)

\<=60

Male

N (%)

11 (11.00%)

Female

N (%)

15 (15.00%)

1990-06-01 to 1990-06-30

overall

overall

N (%)

26 (26.00%)

\<=60

overall

N (%)

26 (26.00%)

overall

Male

N (%)

11 (11.00%)

Female

N (%)

15 (15.00%)

\<=60

Male

N (%)

11 (11.00%)

Female

N (%)

15 (15.00%)

1990-07-01 to 1990-07-31

overall

overall

N (%)

26 (26.00%)

\<=60

overall

N (%)

26 (26.00%)

overall

Male

N (%)

11 (11.00%)

Female

N (%)

15 (15.00%)

\<=60

Male

N (%)

11 (11.00%)

Female

N (%)

15 (15.00%)

1990-08-01 to 1990-08-31

overall

overall

N (%)

26 (26.00%)

\<=60

overall

N (%)

26 (26.00%)

overall

Male

N (%)

11 (11.00%)

Female

N (%)

15 (15.00%)

\<=60

Male

N (%)

11 (11.00%)

Female

N (%)

15 (15.00%)

1990-09-01 to 1990-09-30

overall

overall

N (%)

26 (26.00%)

\<=60

overall

N (%)

26 (26.00%)

overall

Male

N (%)

11 (11.00%)

Female

N (%)

15 (15.00%)

\<=60

Male

N (%)

11 (11.00%)

Female

N (%)

15 (15.00%)

1990-10-01 to 1990-10-31

overall

overall

N (%)

26 (26.00%)

\<=60

overall

N (%)

26 (26.00%)

overall

Male

N (%)

11 (11.00%)

Female

N (%)

15 (15.00%)

\<=60

Male

N (%)

11 (11.00%)

Female

N (%)

15 (15.00%)

1990-11-01 to 1990-11-30

overall

overall

N (%)

26 (26.00%)

\<=60

overall

N (%)

26 (26.00%)

overall

Male

N (%)

11 (11.00%)

Female

N (%)

15 (15.00%)

\<=60

Male

N (%)

11 (11.00%)

Female

N (%)

15 (15.00%)

1990-12-01 to 1990-12-31

overall

overall

N (%)

26 (26.00%)

\<=60

overall

N (%)

26 (26.00%)

overall

Male

N (%)

11 (11.00%)

Female

N (%)

15 (15.00%)

\<=60

Male

N (%)

11 (11.00%)

Female

N (%)

15 (15.00%)

1991-01-01 to 1991-01-31

overall

overall

N (%)

27 (27.00%)

\<=60

overall

N (%)

27 (27.00%)

overall

Male

N (%)

12 (12.00%)

Female

N (%)

15 (15.00%)

\<=60

Male

N (%)

12 (12.00%)

Female

N (%)

15 (15.00%)

1991-02-01 to 1991-02-28

overall

overall

N (%)

27 (27.00%)

\<=60

overall

N (%)

27 (27.00%)

overall

Male

N (%)

12 (12.00%)

Female

N (%)

15 (15.00%)

\<=60

Male

N (%)

12 (12.00%)

Female

N (%)

15 (15.00%)

1991-03-01 to 1991-03-31

overall

overall

N (%)

27 (27.00%)

\<=60

overall

N (%)

27 (27.00%)

overall

Male

N (%)

12 (12.00%)

Female

N (%)

15 (15.00%)

\<=60

Male

N (%)

12 (12.00%)

Female

N (%)

15 (15.00%)

1991-04-01 to 1991-04-30

overall

overall

N (%)

27 (27.00%)

\<=60

overall

N (%)

27 (27.00%)

overall

Male

N (%)

12 (12.00%)

Female

N (%)

15 (15.00%)

\<=60

Male

N (%)

12 (12.00%)

Female

N (%)

15 (15.00%)

1991-05-01 to 1991-05-31

overall

overall

N (%)

27 (27.00%)

\<=60

overall

N (%)

27 (27.00%)

overall

Male

N (%)

12 (12.00%)

Female

N (%)

15 (15.00%)

\<=60

Male

N (%)

12 (12.00%)

Female

N (%)

15 (15.00%)

1991-06-01 to 1991-06-30

overall

overall

N (%)

28 (28.00%)

\<=60

overall

N (%)

28 (28.00%)

overall

Male

N (%)

13 (13.00%)

Female

N (%)

15 (15.00%)

\<=60

Male

N (%)

13 (13.00%)

Female

N (%)

15 (15.00%)

1991-07-01 to 1991-07-31

overall

overall

N (%)

28 (28.00%)

\<=60

overall

N (%)

28 (28.00%)

overall

Male

N (%)

13 (13.00%)

Female

N (%)

15 (15.00%)

\<=60

Male

N (%)

13 (13.00%)

Female

N (%)

15 (15.00%)

1991-08-01 to 1991-08-31

overall

overall

N (%)

28 (28.00%)

\<=60

overall

N (%)

28 (28.00%)

overall

Male

N (%)

13 (13.00%)

Female

N (%)

15 (15.00%)

\<=60

Male

N (%)

13 (13.00%)

Female

N (%)

15 (15.00%)

1991-09-01 to 1991-09-30

overall

overall

N (%)

28 (28.00%)

\<=60

overall

N (%)

28 (28.00%)

overall

Male

N (%)

13 (13.00%)

Female

N (%)

15 (15.00%)

\<=60

Male

N (%)

13 (13.00%)

Female

N (%)

15 (15.00%)

1991-10-01 to 1991-10-31

overall

overall

N (%)

28 (28.00%)

\<=60

overall

N (%)

28 (28.00%)

overall

Male

N (%)

13 (13.00%)

Female

N (%)

15 (15.00%)

\<=60

Male

N (%)

13 (13.00%)

Female

N (%)

15 (15.00%)

1991-11-01 to 1991-11-30

overall

overall

N (%)

28 (28.00%)

\<=60

overall

N (%)

28 (28.00%)

overall

Male

N (%)

13 (13.00%)

Female

N (%)

15 (15.00%)

\<=60

Male

N (%)

13 (13.00%)

Female

N (%)

15 (15.00%)

1991-12-01 to 1991-12-31

overall

overall

N (%)

30 (30.00%)

\<=60

overall

N (%)

30 (30.00%)

overall

Male

N (%)

15 (15.00%)

Female

N (%)

15 (15.00%)

\<=60

Male

N (%)

15 (15.00%)

Female

N (%)

15 (15.00%)

1992-01-01 to 1992-01-31

overall

overall

N (%)

30 (30.00%)

\<=60

overall

N (%)

30 (30.00%)

overall

Male

N (%)

15 (15.00%)

Female

N (%)

15 (15.00%)

\<=60

Male

N (%)

15 (15.00%)

Female

N (%)

15 (15.00%)

1992-02-01 to 1992-02-29

overall

overall

N (%)

30 (30.00%)

\<=60

overall

N (%)

30 (30.00%)

overall

Male

N (%)

15 (15.00%)

Female

N (%)

15 (15.00%)

\<=60

Male

N (%)

15 (15.00%)

Female

N (%)

15 (15.00%)

1992-03-01 to 1992-03-31

overall

overall

N (%)

30 (30.00%)

\<=60

overall

N (%)

30 (30.00%)

overall

Male

N (%)

15 (15.00%)

Female

N (%)

15 (15.00%)

\<=60

Male

N (%)

15 (15.00%)

Female

N (%)

15 (15.00%)

1992-04-01 to 1992-04-30

overall

overall

N (%)

30 (30.00%)

\<=60

overall

N (%)

30 (30.00%)

overall

Male

N (%)

15 (15.00%)

Female

N (%)

15 (15.00%)

\<=60

Male

N (%)

15 (15.00%)

Female

N (%)

15 (15.00%)

1992-05-01 to 1992-05-31

overall

overall

N (%)

31 (31.00%)

\<=60

overall

N (%)

31 (31.00%)

overall

Male

N (%)

15 (15.00%)

Female

N (%)

16 (16.00%)

\<=60

Male

N (%)

15 (15.00%)

Female

N (%)

16 (16.00%)

1992-06-01 to 1992-06-30

overall

overall

N (%)

32 (32.00%)

\<=60

overall

N (%)

32 (32.00%)

overall

Male

N (%)

15 (15.00%)

Female

N (%)

17 (17.00%)

\<=60

Male

N (%)

15 (15.00%)

Female

N (%)

17 (17.00%)

1992-07-01 to 1992-07-31

overall

overall

N (%)

32 (32.00%)

\<=60

overall

N (%)

32 (32.00%)

overall

Male

N (%)

15 (15.00%)

Female

N (%)

17 (17.00%)

\<=60

Male

N (%)

15 (15.00%)

Female

N (%)

17 (17.00%)

1992-08-01 to 1992-08-31

overall

overall

N (%)

32 (32.00%)

\<=60

overall

N (%)

32 (32.00%)

overall

Male

N (%)

15 (15.00%)

Female

N (%)

17 (17.00%)

\<=60

Male

N (%)

15 (15.00%)

Female

N (%)

17 (17.00%)

1992-09-01 to 1992-09-30

overall

overall

N (%)

32 (32.00%)

\<=60

overall

N (%)

32 (32.00%)

overall

Male

N (%)

15 (15.00%)

Female

N (%)

17 (17.00%)

\<=60

Male

N (%)

15 (15.00%)

Female

N (%)

17 (17.00%)

1992-10-01 to 1992-10-31

overall

overall

N (%)

33 (33.00%)

\<=60

overall

N (%)

33 (33.00%)

overall

Male

N (%)

15 (15.00%)

Female

N (%)

18 (18.00%)

\<=60

Male

N (%)

15 (15.00%)

Female

N (%)

18 (18.00%)

1992-11-01 to 1992-11-30

overall

overall

N (%)

33 (33.00%)

\<=60

overall

N (%)

33 (33.00%)

overall

Male

N (%)

15 (15.00%)

Female

N (%)

18 (18.00%)

\<=60

Male

N (%)

15 (15.00%)

Female

N (%)

18 (18.00%)

1992-12-01 to 1992-12-31

overall

overall

N (%)

33 (33.00%)

\<=60

overall

N (%)

33 (33.00%)

overall

Male

N (%)

15 (15.00%)

Female

N (%)

18 (18.00%)

\<=60

Male

N (%)

15 (15.00%)

Female

N (%)

18 (18.00%)

1993-01-01 to 1993-01-31

overall

overall

N (%)

33 (33.00%)

\<=60

overall

N (%)

33 (33.00%)

overall

Male

N (%)

15 (15.00%)

Female

N (%)

18 (18.00%)

\<=60

Male

N (%)

15 (15.00%)

Female

N (%)

18 (18.00%)

1993-02-01 to 1993-02-28

overall

overall

N (%)

32 (32.00%)

\<=60

overall

N (%)

32 (32.00%)

overall

Male

N (%)

14 (14.00%)

Female

N (%)

18 (18.00%)

\<=60

Male

N (%)

14 (14.00%)

Female

N (%)

18 (18.00%)

1993-03-01 to 1993-03-31

overall

overall

N (%)

32 (32.00%)

\<=60

overall

N (%)

32 (32.00%)

overall

Male

N (%)

14 (14.00%)

Female

N (%)

18 (18.00%)

\<=60

Male

N (%)

14 (14.00%)

Female

N (%)

18 (18.00%)

1993-04-01 to 1993-04-30

overall

overall

N (%)

32 (32.00%)

\<=60

overall

N (%)

32 (32.00%)

overall

Male

N (%)

14 (14.00%)

Female

N (%)

18 (18.00%)

\<=60

Male

N (%)

14 (14.00%)

Female

N (%)

18 (18.00%)

1993-05-01 to 1993-05-31

overall

overall

N (%)

32 (32.00%)

\<=60

overall

N (%)

32 (32.00%)

overall

Male

N (%)

14 (14.00%)

Female

N (%)

18 (18.00%)

\<=60

Male

N (%)

14 (14.00%)

Female

N (%)

18 (18.00%)

1993-06-01 to 1993-06-30

overall

overall

N (%)

32 (32.00%)

\<=60

overall

N (%)

32 (32.00%)

overall

Male

N (%)

14 (14.00%)

Female

N (%)

18 (18.00%)

\<=60

Male

N (%)

14 (14.00%)

Female

N (%)

18 (18.00%)

1993-07-01 to 1993-07-31

overall

overall

N (%)

32 (32.00%)

\<=60

overall

N (%)

32 (32.00%)

overall

Male

N (%)

14 (14.00%)

Female

N (%)

18 (18.00%)

\<=60

Male

N (%)

14 (14.00%)

Female

N (%)

18 (18.00%)

1993-08-01 to 1993-08-31

overall

overall

N (%)

32 (32.00%)

\<=60

overall

N (%)

32 (32.00%)

overall

Male

N (%)

14 (14.00%)

Female

N (%)

18 (18.00%)

\<=60

Male

N (%)

14 (14.00%)

Female

N (%)

18 (18.00%)

1993-09-01 to 1993-09-30

overall

overall

N (%)

33 (33.00%)

\<=60

overall

N (%)

33 (33.00%)

overall

Male

N (%)

15 (15.00%)

Female

N (%)

18 (18.00%)

\<=60

Male

N (%)

15 (15.00%)

Female

N (%)

18 (18.00%)

1993-10-01 to 1993-10-31

overall

overall

N (%)

33 (33.00%)

\<=60

overall

N (%)

33 (33.00%)

overall

Male

N (%)

15 (15.00%)

Female

N (%)

18 (18.00%)

\<=60

Male

N (%)

15 (15.00%)

Female

N (%)

18 (18.00%)

1993-11-01 to 1993-11-30

overall

overall

N (%)

33 (33.00%)

\<=60

overall

N (%)

33 (33.00%)

overall

Male

N (%)

15 (15.00%)

Female

N (%)

18 (18.00%)

\<=60

Male

N (%)

15 (15.00%)

Female

N (%)

18 (18.00%)

1993-12-01 to 1993-12-31

overall

overall

N (%)

33 (33.00%)

\<=60

overall

N (%)

33 (33.00%)

overall

Male

N (%)

15 (15.00%)

Female

N (%)

18 (18.00%)

\<=60

Male

N (%)

15 (15.00%)

Female

N (%)

18 (18.00%)

1994-01-01 to 1994-01-31

overall

overall

N (%)

32 (32.00%)

\<=60

overall

N (%)

32 (32.00%)

overall

Male

N (%)

14 (14.00%)

Female

N (%)

18 (18.00%)

\<=60

Male

N (%)

14 (14.00%)

Female

N (%)

18 (18.00%)

1994-02-01 to 1994-02-28

overall

overall

N (%)

32 (32.00%)

\<=60

overall

N (%)

32 (32.00%)

overall

Male

N (%)

14 (14.00%)

Female

N (%)

18 (18.00%)

\<=60

Male

N (%)

14 (14.00%)

Female

N (%)

18 (18.00%)

1994-03-01 to 1994-03-31

overall

overall

N (%)

32 (32.00%)

\<=60

overall

N (%)

32 (32.00%)

overall

Male

N (%)

14 (14.00%)

Female

N (%)

18 (18.00%)

\<=60

Male

N (%)

14 (14.00%)

Female

N (%)

18 (18.00%)

1994-04-01 to 1994-04-30

overall

overall

N (%)

32 (32.00%)

\<=60

overall

N (%)

32 (32.00%)

overall

Male

N (%)

14 (14.00%)

Female

N (%)

18 (18.00%)

\<=60

Male

N (%)

14 (14.00%)

Female

N (%)

18 (18.00%)

1994-05-01 to 1994-05-31

overall

overall

N (%)

33 (33.00%)

\<=60

overall

N (%)

33 (33.00%)

overall

Male

N (%)

14 (14.00%)

Female

N (%)

19 (19.00%)

\<=60

Male

N (%)

14 (14.00%)

Female

N (%)

19 (19.00%)

1994-06-01 to 1994-06-30

overall

overall

N (%)

33 (33.00%)

\<=60

overall

N (%)

33 (33.00%)

overall

Male

N (%)

14 (14.00%)

Female

N (%)

19 (19.00%)

\<=60

Male

N (%)

14 (14.00%)

Female

N (%)

19 (19.00%)

1994-07-01 to 1994-07-31

overall

overall

N (%)

33 (33.00%)

\<=60

overall

N (%)

33 (33.00%)

overall

Male

N (%)

14 (14.00%)

Female

N (%)

19 (19.00%)

\<=60

Male

N (%)

14 (14.00%)

Female

N (%)

19 (19.00%)

1994-08-01 to 1994-08-31

overall

overall

N (%)

34 (34.00%)

\<=60

overall

N (%)

34 (34.00%)

overall

Male

N (%)

15 (15.00%)

Female

N (%)

19 (19.00%)

\<=60

Male

N (%)

15 (15.00%)

Female

N (%)

19 (19.00%)

1994-09-01 to 1994-09-30

overall

overall

N (%)

34 (34.00%)

\<=60

overall

N (%)

34 (34.00%)

overall

Male

N (%)

15 (15.00%)

Female

N (%)

19 (19.00%)

\<=60

Male

N (%)

15 (15.00%)

Female

N (%)

19 (19.00%)

1994-10-01 to 1994-10-31

overall

overall

N (%)

34 (34.00%)

\<=60

overall

N (%)

34 (34.00%)

overall

Male

N (%)

15 (15.00%)

Female

N (%)

19 (19.00%)

\<=60

Male

N (%)

15 (15.00%)

Female

N (%)

19 (19.00%)

1994-11-01 to 1994-11-30

overall

overall

N (%)

33 (33.00%)

\<=60

overall

N (%)

33 (33.00%)

overall

Male

N (%)

15 (15.00%)

Female

N (%)

18 (18.00%)

\<=60

Male

N (%)

15 (15.00%)

Female

N (%)

18 (18.00%)

1994-12-01 to 1994-12-31

overall

overall

N (%)

34 (34.00%)

\<=60

overall

N (%)

34 (34.00%)

overall

Male

N (%)

15 (15.00%)

Female

N (%)

19 (19.00%)

\<=60

Male

N (%)

15 (15.00%)

Female

N (%)

19 (19.00%)

1995-01-01 to 1995-01-31

overall

overall

N (%)

34 (34.00%)

\<=60

overall

N (%)

34 (34.00%)

overall

Male

N (%)

15 (15.00%)

Female

N (%)

19 (19.00%)

\<=60

Male

N (%)

15 (15.00%)

Female

N (%)

19 (19.00%)

1995-02-01 to 1995-02-28

overall

overall

N (%)

34 (34.00%)

\<=60

overall

N (%)

34 (34.00%)

overall

Male

N (%)

15 (15.00%)

Female

N (%)

19 (19.00%)

\<=60

Male

N (%)

15 (15.00%)

Female

N (%)

19 (19.00%)

1995-03-01 to 1995-03-31

overall

overall

N (%)

34 (34.00%)

\<=60

overall

N (%)

34 (34.00%)

overall

Male

N (%)

15 (15.00%)

Female

N (%)

19 (19.00%)

\<=60

Male

N (%)

15 (15.00%)

Female

N (%)

19 (19.00%)

1995-04-01 to 1995-04-30

overall

overall

N (%)

35 (35.00%)

\<=60

overall

N (%)

35 (35.00%)

overall

Male

N (%)

16 (16.00%)

Female

N (%)

19 (19.00%)

\<=60

Male

N (%)

16 (16.00%)

Female

N (%)

19 (19.00%)

1995-05-01 to 1995-05-31

overall

overall

N (%)

35 (35.00%)

\<=60

overall

N (%)

35 (35.00%)

overall

Male

N (%)

16 (16.00%)

Female

N (%)

19 (19.00%)

\<=60

Male

N (%)

16 (16.00%)

Female

N (%)

19 (19.00%)

1995-06-01 to 1995-06-30

overall

overall

N (%)

35 (35.00%)

\<=60

overall

N (%)

35 (35.00%)

overall

Male

N (%)

16 (16.00%)

Female

N (%)

19 (19.00%)

\<=60

Male

N (%)

16 (16.00%)

Female

N (%)

19 (19.00%)

1995-07-01 to 1995-07-31

overall

overall

N (%)

35 (35.00%)

\<=60

overall

N (%)

35 (35.00%)

overall

Male

N (%)

16 (16.00%)

Female

N (%)

19 (19.00%)

\<=60

Male

N (%)

16 (16.00%)

Female

N (%)

19 (19.00%)

1995-08-01 to 1995-08-31

overall

overall

N (%)

35 (35.00%)

\<=60

overall

N (%)

35 (35.00%)

overall

Male

N (%)

16 (16.00%)

Female

N (%)

19 (19.00%)

\<=60

Male

N (%)

16 (16.00%)

Female

N (%)

19 (19.00%)

1995-09-01 to 1995-09-30

overall

overall

N (%)

35 (35.00%)

\<=60

overall

N (%)

35 (35.00%)

overall

Male

N (%)

16 (16.00%)

Female

N (%)

19 (19.00%)

\<=60

Male

N (%)

16 (16.00%)

Female

N (%)

19 (19.00%)

1995-10-01 to 1995-10-31

overall

overall

N (%)

35 (35.00%)

\<=60

overall

N (%)

35 (35.00%)

overall

Male

N (%)

16 (16.00%)

Female

N (%)

19 (19.00%)

\<=60

Male

N (%)

16 (16.00%)

Female

N (%)

19 (19.00%)

1995-11-01 to 1995-11-30

overall

overall

N (%)

35 (35.00%)

\<=60

overall

N (%)

35 (35.00%)

overall

Male

N (%)

16 (16.00%)

Female

N (%)

19 (19.00%)

\<=60

Male

N (%)

16 (16.00%)

Female

N (%)

19 (19.00%)

1995-12-01 to 1995-12-31

overall

overall

N (%)

35 (35.00%)

\<=60

overall

N (%)

35 (35.00%)

overall

Male

N (%)

16 (16.00%)

Female

N (%)

19 (19.00%)

\<=60

Male

N (%)

16 (16.00%)

Female

N (%)

19 (19.00%)

1996-01-01 to 1996-01-31

overall

overall

N (%)

36 (36.00%)

\<=60

overall

N (%)

36 (36.00%)

overall

Male

N (%)

17 (17.00%)

Female

N (%)

19 (19.00%)

\<=60

Male

N (%)

17 (17.00%)

Female

N (%)

19 (19.00%)

1996-02-01 to 1996-02-29

overall

overall

N (%)

37 (37.00%)

\<=60

overall

N (%)

37 (37.00%)

overall

Male

N (%)

18 (18.00%)

Female

N (%)

19 (19.00%)

\<=60

Male

N (%)

18 (18.00%)

Female

N (%)

19 (19.00%)

1996-03-01 to 1996-03-31

overall

overall

N (%)

37 (37.00%)

\<=60

overall

N (%)

37 (37.00%)

overall

Male

N (%)

18 (18.00%)

Female

N (%)

19 (19.00%)

\<=60

Male

N (%)

18 (18.00%)

Female

N (%)

19 (19.00%)

1996-04-01 to 1996-04-30

overall

overall

N (%)

37 (37.00%)

\<=60

overall

N (%)

37 (37.00%)

overall

Male

N (%)

18 (18.00%)

Female

N (%)

19 (19.00%)

\<=60

Male

N (%)

18 (18.00%)

Female

N (%)

19 (19.00%)

1996-05-01 to 1996-05-31

overall

overall

N (%)

38 (38.00%)

\<=60

overall

N (%)

38 (38.00%)

overall

Male

N (%)

19 (19.00%)

Female

N (%)

19 (19.00%)

\<=60

Male

N (%)

19 (19.00%)

Female

N (%)

19 (19.00%)

1996-06-01 to 1996-06-30

overall

overall

N (%)

38 (38.00%)

\<=60

overall

N (%)

38 (38.00%)

overall

Male

N (%)

19 (19.00%)

Female

N (%)

19 (19.00%)

\<=60

Male

N (%)

19 (19.00%)

Female

N (%)

19 (19.00%)

1996-07-01 to 1996-07-31

overall

overall

N (%)

38 (38.00%)

\<=60

overall

N (%)

38 (38.00%)

overall

Male

N (%)

19 (19.00%)

Female

N (%)

19 (19.00%)

\<=60

Male

N (%)

19 (19.00%)

Female

N (%)

19 (19.00%)

1996-08-01 to 1996-08-31

overall

overall

N (%)

38 (38.00%)

\<=60

overall

N (%)

38 (38.00%)

overall

Male

N (%)

19 (19.00%)

Female

N (%)

19 (19.00%)

\<=60

Male

N (%)

19 (19.00%)

Female

N (%)

19 (19.00%)

1996-09-01 to 1996-09-30

overall

overall

N (%)

38 (38.00%)

\<=60

overall

N (%)

38 (38.00%)

overall

Male

N (%)

19 (19.00%)

Female

N (%)

19 (19.00%)

\<=60

Male

N (%)

19 (19.00%)

Female

N (%)

19 (19.00%)

1996-10-01 to 1996-10-31

overall

overall

N (%)

39 (39.00%)

\<=60

overall

N (%)

39 (39.00%)

overall

Male

N (%)

19 (19.00%)

Female

N (%)

20 (20.00%)

\<=60

Male

N (%)

19 (19.00%)

Female

N (%)

20 (20.00%)

1996-11-01 to 1996-11-30

overall

overall

N (%)

39 (39.00%)

\<=60

overall

N (%)

39 (39.00%)

overall

Male

N (%)

19 (19.00%)

Female

N (%)

20 (20.00%)

\<=60

Male

N (%)

19 (19.00%)

Female

N (%)

20 (20.00%)

1996-12-01 to 1996-12-31

overall

overall

N (%)

38 (38.00%)

\<=60

overall

N (%)

38 (38.00%)

overall

Male

N (%)

19 (19.00%)

Female

N (%)

19 (19.00%)

\<=60

Male

N (%)

19 (19.00%)

Female

N (%)

19 (19.00%)

1997-01-01 to 1997-01-31

overall

overall

N (%)

38 (38.00%)

\<=60

overall

N (%)

38 (38.00%)

overall

Male

N (%)

19 (19.00%)

Female

N (%)

19 (19.00%)

\<=60

Male

N (%)

19 (19.00%)

Female

N (%)

19 (19.00%)

1997-02-01 to 1997-02-28

overall

overall

N (%)

38 (38.00%)

\<=60

overall

N (%)

38 (38.00%)

overall

Male

N (%)

19 (19.00%)

Female

N (%)

19 (19.00%)

\<=60

Male

N (%)

19 (19.00%)

Female

N (%)

19 (19.00%)

1997-03-01 to 1997-03-31

overall

overall

N (%)

38 (38.00%)

\<=60

overall

N (%)

38 (38.00%)

overall

Male

N (%)

19 (19.00%)

Female

N (%)

19 (19.00%)

\<=60

Male

N (%)

19 (19.00%)

Female

N (%)

19 (19.00%)

1997-04-01 to 1997-04-30

overall

overall

N (%)

38 (38.00%)

\<=60

overall

N (%)

38 (38.00%)

overall

Male

N (%)

19 (19.00%)

Female

N (%)

19 (19.00%)

\<=60

Male

N (%)

19 (19.00%)

Female

N (%)

19 (19.00%)

1997-05-01 to 1997-05-31

overall

overall

N (%)

37 (37.00%)

\<=60

overall

N (%)

37 (37.00%)

overall

Male

N (%)

18 (18.00%)

Female

N (%)

19 (19.00%)

\<=60

Male

N (%)

18 (18.00%)

Female

N (%)

19 (19.00%)

1997-06-01 to 1997-06-30

overall

overall

N (%)

37 (37.00%)

\<=60

overall

N (%)

37 (37.00%)

overall

Male

N (%)

18 (18.00%)

Female

N (%)

19 (19.00%)

\<=60

Male

N (%)

18 (18.00%)

Female

N (%)

19 (19.00%)

1997-07-01 to 1997-07-31

overall

overall

N (%)

37 (37.00%)

\<=60

overall

N (%)

37 (37.00%)

overall

Male

N (%)

18 (18.00%)

Female

N (%)

19 (19.00%)

\<=60

Male

N (%)

18 (18.00%)

Female

N (%)

19 (19.00%)

1997-08-01 to 1997-08-31

overall

overall

N (%)

37 (37.00%)

\<=60

overall

N (%)

37 (37.00%)

overall

Male

N (%)

18 (18.00%)

Female

N (%)

19 (19.00%)

\<=60

Male

N (%)

18 (18.00%)

Female

N (%)

19 (19.00%)

1997-09-01 to 1997-09-30

overall

overall

N (%)

37 (37.00%)

\<=60

overall

N (%)

37 (37.00%)

overall

Male

N (%)

18 (18.00%)

Female

N (%)

19 (19.00%)

\<=60

Male

N (%)

18 (18.00%)

Female

N (%)

19 (19.00%)

1997-10-01 to 1997-10-31

overall

overall

N (%)

37 (37.00%)

\<=60

overall

N (%)

37 (37.00%)

overall

Male

N (%)

18 (18.00%)

Female

N (%)

19 (19.00%)

\<=60

Male

N (%)

18 (18.00%)

Female

N (%)

19 (19.00%)

1997-11-01 to 1997-11-30

overall

overall

N (%)

37 (37.00%)

\<=60

overall

N (%)

37 (37.00%)

overall

Male

N (%)

18 (18.00%)

Female

N (%)

19 (19.00%)

\<=60

Male

N (%)

18 (18.00%)

Female

N (%)

19 (19.00%)

1997-12-01 to 1997-12-31

overall

overall

N (%)

38 (38.00%)

\<=60

overall

N (%)

38 (38.00%)

overall

Male

N (%)

19 (19.00%)

Female

N (%)

19 (19.00%)

\<=60

Male

N (%)

19 (19.00%)

Female

N (%)

19 (19.00%)

1998-01-01 to 1998-01-31

overall

overall

N (%)

37 (37.00%)

\<=60

overall

N (%)

37 (37.00%)

overall

Male

N (%)

19 (19.00%)

Female

N (%)

18 (18.00%)

\<=60

Male

N (%)

19 (19.00%)

Female

N (%)

18 (18.00%)

1998-02-01 to 1998-02-28

overall

overall

N (%)

38 (38.00%)

\<=60

overall

N (%)

38 (38.00%)

overall

Male

N (%)

20 (20.00%)

Female

N (%)

18 (18.00%)

\<=60

Male

N (%)

20 (20.00%)

Female

N (%)

18 (18.00%)

1998-03-01 to 1998-03-31

overall

overall

N (%)

38 (38.00%)

\<=60

overall

N (%)

38 (38.00%)

overall

Male

N (%)

20 (20.00%)

Female

N (%)

18 (18.00%)

\<=60

Male

N (%)

20 (20.00%)

Female

N (%)

18 (18.00%)

1998-04-01 to 1998-04-30

overall

overall

N (%)

38 (38.00%)

\<=60

overall

N (%)

38 (38.00%)

overall

Male

N (%)

20 (20.00%)

Female

N (%)

18 (18.00%)

\<=60

Male

N (%)

20 (20.00%)

Female

N (%)

18 (18.00%)

1998-05-01 to 1998-05-31

overall

overall

N (%)

38 (38.00%)

\<=60

overall

N (%)

38 (38.00%)

overall

Male

N (%)

20 (20.00%)

Female

N (%)

18 (18.00%)

\<=60

Male

N (%)

20 (20.00%)

Female

N (%)

18 (18.00%)

1998-06-01 to 1998-06-30

overall

overall

N (%)

39 (39.00%)

\<=60

overall

N (%)

39 (39.00%)

overall

Male

N (%)

21 (21.00%)

Female

N (%)

18 (18.00%)

\<=60

Male

N (%)

21 (21.00%)

Female

N (%)

18 (18.00%)

1998-07-01 to 1998-07-31

overall

overall

N (%)

39 (39.00%)

\<=60

overall

N (%)

39 (39.00%)

overall

Male

N (%)

21 (21.00%)

Female

N (%)

18 (18.00%)

\<=60

Male

N (%)

21 (21.00%)

Female

N (%)

18 (18.00%)

1998-08-01 to 1998-08-31

overall

overall

N (%)

39 (39.00%)

\<=60

overall

N (%)

39 (39.00%)

overall

Male

N (%)

21 (21.00%)

Female

N (%)

18 (18.00%)

\<=60

Male

N (%)

21 (21.00%)

Female

N (%)

18 (18.00%)

1998-09-01 to 1998-09-30

overall

overall

N (%)

38 (38.00%)

\<=60

overall

N (%)

38 (38.00%)

overall

Male

N (%)

20 (20.00%)

Female

N (%)

18 (18.00%)

\<=60

Male

N (%)

20 (20.00%)

Female

N (%)

18 (18.00%)

1998-10-01 to 1998-10-31

overall

overall

N (%)

38 (38.00%)

\<=60

overall

N (%)

38 (38.00%)

overall

Male

N (%)

20 (20.00%)

Female

N (%)

18 (18.00%)

\<=60

Male

N (%)

20 (20.00%)

Female

N (%)

18 (18.00%)

1998-11-01 to 1998-11-30

overall

overall

N (%)

39 (39.00%)

\<=60

overall

N (%)

39 (39.00%)

overall

Male

N (%)

20 (20.00%)

Female

N (%)

19 (19.00%)

\<=60

Male

N (%)

20 (20.00%)

Female

N (%)

19 (19.00%)

1998-12-01 to 1998-12-31

overall

overall

N (%)

40 (40.00%)

\<=60

overall

N (%)

40 (40.00%)

overall

Male

N (%)

21 (21.00%)

Female

N (%)

19 (19.00%)

\<=60

Male

N (%)

21 (21.00%)

Female

N (%)

19 (19.00%)

1999-01-01 to 1999-01-31

overall

overall

N (%)

40 (40.00%)

\<=60

overall

N (%)

40 (40.00%)

overall

Male

N (%)

21 (21.00%)

Female

N (%)

19 (19.00%)

\<=60

Male

N (%)

21 (21.00%)

Female

N (%)

19 (19.00%)

1999-02-01 to 1999-02-28

overall

overall

N (%)

40 (40.00%)

\<=60

overall

N (%)

40 (40.00%)

overall

Male

N (%)

21 (21.00%)

Female

N (%)

19 (19.00%)

\<=60

Male

N (%)

21 (21.00%)

Female

N (%)

19 (19.00%)

1999-03-01 to 1999-03-31

overall

overall

N (%)

40 (40.00%)

\<=60

overall

N (%)

40 (40.00%)

overall

Male

N (%)

21 (21.00%)

Female

N (%)

19 (19.00%)

\<=60

Male

N (%)

21 (21.00%)

Female

N (%)

19 (19.00%)

1999-04-01 to 1999-04-30

overall

overall

N (%)

40 (40.00%)

\<=60

overall

N (%)

40 (40.00%)

overall

Male

N (%)

21 (21.00%)

Female

N (%)

19 (19.00%)

\<=60

Male

N (%)

21 (21.00%)

Female

N (%)

19 (19.00%)

1999-05-01 to 1999-05-31

overall

overall

N (%)

40 (40.00%)

\<=60

overall

N (%)

40 (40.00%)

overall

Male

N (%)

21 (21.00%)

Female

N (%)

19 (19.00%)

\<=60

Male

N (%)

21 (21.00%)

Female

N (%)

19 (19.00%)

1999-06-01 to 1999-06-30

overall

overall

N (%)

40 (40.00%)

\<=60

overall

N (%)

40 (40.00%)

overall

Male

N (%)

21 (21.00%)

Female

N (%)

19 (19.00%)

\<=60

Male

N (%)

21 (21.00%)

Female

N (%)

19 (19.00%)

1999-07-01 to 1999-07-31

overall

overall

N (%)

40 (40.00%)

\<=60

overall

N (%)

40 (40.00%)

overall

Male

N (%)

21 (21.00%)

Female

N (%)

19 (19.00%)

\<=60

Male

N (%)

21 (21.00%)

Female

N (%)

19 (19.00%)

1999-08-01 to 1999-08-31

overall

overall

N (%)

40 (40.00%)

\<=60

overall

N (%)

40 (40.00%)

overall

Male

N (%)

21 (21.00%)

Female

N (%)

19 (19.00%)

\<=60

Male

N (%)

21 (21.00%)

Female

N (%)

19 (19.00%)

1999-09-01 to 1999-09-30

overall

overall

N (%)

40 (40.00%)

\<=60

overall

N (%)

40 (40.00%)

overall

Male

N (%)

21 (21.00%)

Female

N (%)

19 (19.00%)

\<=60

Male

N (%)

21 (21.00%)

Female

N (%)

19 (19.00%)

1999-10-01 to 1999-10-31

overall

overall

N (%)

41 (41.00%)

\<=60

overall

N (%)

41 (41.00%)

overall

Male

N (%)

21 (21.00%)

Female

N (%)

20 (20.00%)

\<=60

Male

N (%)

21 (21.00%)

Female

N (%)

20 (20.00%)

1999-11-01 to 1999-11-30

overall

overall

N (%)

41 (41.00%)

\<=60

overall

N (%)

41 (41.00%)

overall

Male

N (%)

21 (21.00%)

Female

N (%)

20 (20.00%)

\<=60

Male

N (%)

21 (21.00%)

Female

N (%)

20 (20.00%)

1999-12-01 to 1999-12-31

overall

overall

N (%)

41 (41.00%)

\<=60

overall

N (%)

41 (41.00%)

overall

Male

N (%)

21 (21.00%)

Female

N (%)

20 (20.00%)

\<=60

Male

N (%)

21 (21.00%)

Female

N (%)

20 (20.00%)

2000-01-01 to 2000-01-31

overall

overall

N (%)

42 (42.00%)

\<=60

overall

N (%)

42 (42.00%)

overall

Male

N (%)

21 (21.00%)

Female

N (%)

21 (21.00%)

\<=60

Male

N (%)

21 (21.00%)

Female

N (%)

21 (21.00%)

2000-02-01 to 2000-02-29

overall

overall

N (%)

42 (42.00%)

\<=60

overall

N (%)

42 (42.00%)

overall

Male

N (%)

21 (21.00%)

Female

N (%)

21 (21.00%)

\<=60

Male

N (%)

21 (21.00%)

Female

N (%)

21 (21.00%)

2000-03-01 to 2000-03-31

overall

overall

N (%)

42 (42.00%)

\<=60

overall

N (%)

42 (42.00%)

overall

Male

N (%)

20 (20.00%)

Female

N (%)

22 (22.00%)

\<=60

Male

N (%)

20 (20.00%)

Female

N (%)

22 (22.00%)

2000-04-01 to 2000-04-30

overall

overall

N (%)

42 (42.00%)

\<=60

overall

N (%)

42 (42.00%)

overall

Male

N (%)

20 (20.00%)

Female

N (%)

22 (22.00%)

\<=60

Male

N (%)

20 (20.00%)

Female

N (%)

22 (22.00%)

2000-05-01 to 2000-05-31

overall

overall

N (%)

41 (41.00%)

\<=60

overall

N (%)

41 (41.00%)

overall

Male

N (%)

19 (19.00%)

Female

N (%)

22 (22.00%)

\<=60

Male

N (%)

19 (19.00%)

Female

N (%)

22 (22.00%)

2000-06-01 to 2000-06-30

overall

overall

N (%)

41 (41.00%)

\<=60

overall

N (%)

41 (41.00%)

overall

Male

N (%)

19 (19.00%)

Female

N (%)

22 (22.00%)

\<=60

Male

N (%)

19 (19.00%)

Female

N (%)

22 (22.00%)

2000-07-01 to 2000-07-31

overall

overall

N (%)

42 (42.00%)

\<=60

overall

N (%)

42 (42.00%)

overall

Male

N (%)

20 (20.00%)

Female

N (%)

22 (22.00%)

\<=60

Male

N (%)

20 (20.00%)

Female

N (%)

22 (22.00%)

2000-08-01 to 2000-08-31

overall

overall

N (%)

42 (42.00%)

\<=60

overall

N (%)

42 (42.00%)

overall

Male

N (%)

20 (20.00%)

Female

N (%)

22 (22.00%)

\<=60

Male

N (%)

20 (20.00%)

Female

N (%)

22 (22.00%)

2000-09-01 to 2000-09-30

overall

overall

N (%)

42 (42.00%)

\<=60

overall

N (%)

42 (42.00%)

overall

Male

N (%)

20 (20.00%)

Female

N (%)

22 (22.00%)

\<=60

Male

N (%)

20 (20.00%)

Female

N (%)

22 (22.00%)

2000-10-01 to 2000-10-31

overall

overall

N (%)

41 (41.00%)

\<=60

overall

N (%)

41 (41.00%)

overall

Male

N (%)

20 (20.00%)

Female

N (%)

21 (21.00%)

\<=60

Male

N (%)

20 (20.00%)

Female

N (%)

21 (21.00%)

2000-11-01 to 2000-11-30

overall

overall

N (%)

41 (41.00%)

\<=60

overall

N (%)

41 (41.00%)

overall

Male

N (%)

20 (20.00%)

Female

N (%)

21 (21.00%)

\<=60

Male

N (%)

20 (20.00%)

Female

N (%)

21 (21.00%)

2000-12-01 to 2000-12-31

overall

overall

N (%)

41 (41.00%)

\<=60

overall

N (%)

41 (41.00%)

overall

Male

N (%)

20 (20.00%)

Female

N (%)

21 (21.00%)

\<=60

Male

N (%)

20 (20.00%)

Female

N (%)

21 (21.00%)

2001-01-01 to 2001-01-31

overall

overall

N (%)

41 (41.00%)

\<=60

overall

N (%)

41 (41.00%)

overall

Male

N (%)

20 (20.00%)

Female

N (%)

21 (21.00%)

\<=60

Male

N (%)

20 (20.00%)

Female

N (%)

21 (21.00%)

2001-02-01 to 2001-02-28

overall

overall

N (%)

41 (41.00%)

\<=60

overall

N (%)

41 (41.00%)

overall

Male

N (%)

20 (20.00%)

Female

N (%)

21 (21.00%)

\<=60

Male

N (%)

20 (20.00%)

Female

N (%)

21 (21.00%)

2001-03-01 to 2001-03-31

overall

overall

N (%)

41 (41.00%)

\<=60

overall

N (%)

41 (41.00%)

overall

Male

N (%)

20 (20.00%)

Female

N (%)

21 (21.00%)

\<=60

Male

N (%)

20 (20.00%)

Female

N (%)

21 (21.00%)

2001-04-01 to 2001-04-30

overall

overall

N (%)

42 (42.00%)

\<=60

overall

N (%)

42 (42.00%)

overall

Male

N (%)

20 (20.00%)

Female

N (%)

22 (22.00%)

\<=60

Male

N (%)

20 (20.00%)

Female

N (%)

22 (22.00%)

2001-05-01 to 2001-05-31

overall

overall

N (%)

43 (43.00%)

\<=60

overall

N (%)

43 (43.00%)

overall

Male

N (%)

21 (21.00%)

Female

N (%)

22 (22.00%)

\<=60

Male

N (%)

21 (21.00%)

Female

N (%)

22 (22.00%)

2001-06-01 to 2001-06-30

overall

overall

N (%)

42 (42.00%)

\<=60

overall

N (%)

42 (42.00%)

overall

Male

N (%)

20 (20.00%)

Female

N (%)

22 (22.00%)

\<=60

Male

N (%)

20 (20.00%)

Female

N (%)

22 (22.00%)

2001-07-01 to 2001-07-31

overall

overall

N (%)

42 (42.00%)

\<=60

overall

N (%)

42 (42.00%)

overall

Male

N (%)

19 (19.00%)

Female

N (%)

23 (23.00%)

\<=60

Male

N (%)

19 (19.00%)

Female

N (%)

23 (23.00%)

2001-08-01 to 2001-08-31

overall

overall

N (%)

42 (42.00%)

\<=60

overall

N (%)

42 (42.00%)

overall

Male

N (%)

19 (19.00%)

Female

N (%)

23 (23.00%)

\<=60

Male

N (%)

19 (19.00%)

Female

N (%)

23 (23.00%)

2001-09-01 to 2001-09-30

overall

overall

N (%)

42 (42.00%)

\<=60

overall

N (%)

42 (42.00%)

overall

Male

N (%)

19 (19.00%)

Female

N (%)

23 (23.00%)

\<=60

Male

N (%)

19 (19.00%)

Female

N (%)

23 (23.00%)

2001-10-01 to 2001-10-31

overall

overall

N (%)

42 (42.00%)

\<=60

overall

N (%)

42 (42.00%)

overall

Male

N (%)

19 (19.00%)

Female

N (%)

23 (23.00%)

\<=60

Male

N (%)

19 (19.00%)

Female

N (%)

23 (23.00%)

2001-11-01 to 2001-11-30

overall

overall

N (%)

42 (42.00%)

\<=60

overall

N (%)

42 (42.00%)

overall

Male

N (%)

19 (19.00%)

Female

N (%)

23 (23.00%)

\<=60

Male

N (%)

19 (19.00%)

Female

N (%)

23 (23.00%)

2001-12-01 to 2001-12-31

overall

overall

N (%)

42 (42.00%)

\<=60

overall

N (%)

42 (42.00%)

overall

Male

N (%)

19 (19.00%)

Female

N (%)

23 (23.00%)

\<=60

Male

N (%)

19 (19.00%)

Female

N (%)

23 (23.00%)

2002-01-01 to 2002-01-31

overall

overall

N (%)

43 (43.00%)

\<=60

overall

N (%)

43 (43.00%)

overall

Male

N (%)

20 (20.00%)

Female

N (%)

23 (23.00%)

\<=60

Male

N (%)

20 (20.00%)

Female

N (%)

23 (23.00%)

2002-02-01 to 2002-02-28

overall

overall

N (%)

43 (43.00%)

\<=60

overall

N (%)

43 (43.00%)

overall

Male

N (%)

20 (20.00%)

Female

N (%)

23 (23.00%)

\<=60

Male

N (%)

20 (20.00%)

Female

N (%)

23 (23.00%)

2002-03-01 to 2002-03-31

overall

overall

N (%)

42 (42.00%)

\<=60

overall

N (%)

42 (42.00%)

overall

Male

N (%)

20 (20.00%)

Female

N (%)

22 (22.00%)

\<=60

Male

N (%)

20 (20.00%)

Female

N (%)

22 (22.00%)

2002-04-01 to 2002-04-30

overall

overall

N (%)

42 (42.00%)

\<=60

overall

N (%)

42 (42.00%)

overall

Male

N (%)

20 (20.00%)

Female

N (%)

22 (22.00%)

\<=60

Male

N (%)

20 (20.00%)

Female

N (%)

22 (22.00%)

2002-05-01 to 2002-05-31

overall

overall

N (%)

42 (42.00%)

\<=60

overall

N (%)

42 (42.00%)

overall

Male

N (%)

20 (20.00%)

Female

N (%)

22 (22.00%)

\<=60

Male

N (%)

20 (20.00%)

Female

N (%)

22 (22.00%)

2002-06-01 to 2002-06-30

overall

overall

N (%)

43 (43.00%)

\<=60

overall

N (%)

43 (43.00%)

overall

Male

N (%)

21 (21.00%)

Female

N (%)

22 (22.00%)

\<=60

Male

N (%)

21 (21.00%)

Female

N (%)

22 (22.00%)

2002-07-01 to 2002-07-31

overall

overall

N (%)

43 (43.00%)

\<=60

overall

N (%)

43 (43.00%)

overall

Male

N (%)

21 (21.00%)

Female

N (%)

22 (22.00%)

\<=60

Male

N (%)

21 (21.00%)

Female

N (%)

22 (22.00%)

2002-08-01 to 2002-08-31

overall

overall

N (%)

43 (43.00%)

\<=60

overall

N (%)

43 (43.00%)

overall

Male

N (%)

21 (21.00%)

Female

N (%)

22 (22.00%)

\<=60

Male

N (%)

21 (21.00%)

Female

N (%)

22 (22.00%)

2002-09-01 to 2002-09-30

overall

overall

N (%)

42 (42.00%)

\<=60

overall

N (%)

42 (42.00%)

overall

Male

N (%)

20 (20.00%)

Female

N (%)

22 (22.00%)

\<=60

Male

N (%)

20 (20.00%)

Female

N (%)

22 (22.00%)

2002-10-01 to 2002-10-31

overall

overall

N (%)

44 (44.00%)

\<=60

overall

N (%)

44 (44.00%)

overall

Male

N (%)

22 (22.00%)

Female

N (%)

22 (22.00%)

\<=60

Male

N (%)

22 (22.00%)

Female

N (%)

22 (22.00%)

2002-11-01 to 2002-11-30

overall

overall

N (%)

44 (44.00%)

\<=60

overall

N (%)

44 (44.00%)

overall

Male

N (%)

22 (22.00%)

Female

N (%)

22 (22.00%)

\<=60

Male

N (%)

22 (22.00%)

Female

N (%)

22 (22.00%)

2002-12-01 to 2002-12-31

overall

overall

N (%)

44 (44.00%)

\<=60

overall

N (%)

44 (44.00%)

overall

Male

N (%)

22 (22.00%)

Female

N (%)

22 (22.00%)

\<=60

Male

N (%)

22 (22.00%)

Female

N (%)

22 (22.00%)

2003-01-01 to 2003-01-31

overall

overall

N (%)

45 (45.00%)

\<=60

overall

N (%)

45 (45.00%)

overall

Male

N (%)

22 (22.00%)

Female

N (%)

23 (23.00%)

\<=60

Male

N (%)

22 (22.00%)

Female

N (%)

23 (23.00%)

2003-02-01 to 2003-02-28

overall

overall

N (%)

45 (45.00%)

\<=60

overall

N (%)

45 (45.00%)

overall

Male

N (%)

22 (22.00%)

Female

N (%)

23 (23.00%)

\<=60

Male

N (%)

22 (22.00%)

Female

N (%)

23 (23.00%)

2003-03-01 to 2003-03-31

overall

overall

N (%)

45 (45.00%)

\<=60

overall

N (%)

45 (45.00%)

overall

Male

N (%)

22 (22.00%)

Female

N (%)

23 (23.00%)

\<=60

Male

N (%)

22 (22.00%)

Female

N (%)

23 (23.00%)

2003-04-01 to 2003-04-30

overall

overall

N (%)

45 (45.00%)

\<=60

overall

N (%)

45 (45.00%)

overall

Male

N (%)

22 (22.00%)

Female

N (%)

23 (23.00%)

\<=60

Male

N (%)

22 (22.00%)

Female

N (%)

23 (23.00%)

2003-05-01 to 2003-05-31

overall

overall

N (%)

45 (45.00%)

\<=60

overall

N (%)

45 (45.00%)

overall

Male

N (%)

22 (22.00%)

Female

N (%)

23 (23.00%)

\<=60

Male

N (%)

22 (22.00%)

Female

N (%)

23 (23.00%)

2003-06-01 to 2003-06-30

overall

overall

N (%)

45 (45.00%)

\<=60

overall

N (%)

45 (45.00%)

overall

Male

N (%)

22 (22.00%)

Female

N (%)

23 (23.00%)

\<=60

Male

N (%)

22 (22.00%)

Female

N (%)

23 (23.00%)

2003-07-01 to 2003-07-31

overall

overall

N (%)

45 (45.00%)

\<=60

overall

N (%)

45 (45.00%)

overall

Male

N (%)

22 (22.00%)

Female

N (%)

23 (23.00%)

\<=60

Male

N (%)

22 (22.00%)

Female

N (%)

23 (23.00%)

2003-08-01 to 2003-08-31

overall

overall

N (%)

45 (45.00%)

\<=60

overall

N (%)

45 (45.00%)

overall

Male

N (%)

22 (22.00%)

Female

N (%)

23 (23.00%)

\<=60

Male

N (%)

22 (22.00%)

Female

N (%)

23 (23.00%)

2003-09-01 to 2003-09-30

overall

overall

N (%)

45 (45.00%)

\<=60

overall

N (%)

45 (45.00%)

overall

Male

N (%)

22 (22.00%)

Female

N (%)

23 (23.00%)

\<=60

Male

N (%)

22 (22.00%)

Female

N (%)

23 (23.00%)

2003-10-01 to 2003-10-31

overall

overall

N (%)

45 (45.00%)

\<=60

overall

N (%)

45 (45.00%)

overall

Male

N (%)

22 (22.00%)

Female

N (%)

23 (23.00%)

\<=60

Male

N (%)

22 (22.00%)

Female

N (%)

23 (23.00%)

2003-11-01 to 2003-11-30

overall

overall

N (%)

45 (45.00%)

\<=60

overall

N (%)

45 (45.00%)

overall

Male

N (%)

22 (22.00%)

Female

N (%)

23 (23.00%)

\<=60

Male

N (%)

22 (22.00%)

Female

N (%)

23 (23.00%)

2003-12-01 to 2003-12-31

overall

overall

N (%)

45 (45.00%)

\<=60

overall

N (%)

45 (45.00%)

overall

Male

N (%)

22 (22.00%)

Female

N (%)

23 (23.00%)

\<=60

Male

N (%)

22 (22.00%)

Female

N (%)

23 (23.00%)

2004-01-01 to 2004-01-31

overall

overall

N (%)

46 (46.00%)

\<=60

overall

N (%)

46 (46.00%)

overall

Male

N (%)

22 (22.00%)

Female

N (%)

24 (24.00%)

\<=60

Male

N (%)

22 (22.00%)

Female

N (%)

24 (24.00%)

2004-02-01 to 2004-02-29

overall

overall

N (%)

45 (45.00%)

\<=60

overall

N (%)

45 (45.00%)

overall

Male

N (%)

21 (21.00%)

Female

N (%)

24 (24.00%)

\<=60

Male

N (%)

21 (21.00%)

Female

N (%)

24 (24.00%)

2004-03-01 to 2004-03-31

overall

overall

N (%)

45 (45.00%)

\<=60

overall

N (%)

45 (45.00%)

overall

Male

N (%)

21 (21.00%)

Female

N (%)

24 (24.00%)

\<=60

Male

N (%)

21 (21.00%)

Female

N (%)

24 (24.00%)

2004-04-01 to 2004-04-30

overall

overall

N (%)

45 (45.00%)

\<=60

overall

N (%)

45 (45.00%)

overall

Male

N (%)

21 (21.00%)

Female

N (%)

24 (24.00%)

\<=60

Male

N (%)

21 (21.00%)

Female

N (%)

24 (24.00%)

2004-05-01 to 2004-05-31

overall

overall

N (%)

47 (47.00%)

\<=60

overall

N (%)

47 (47.00%)

overall

Male

N (%)

23 (23.00%)

Female

N (%)

24 (24.00%)

\<=60

Male

N (%)

23 (23.00%)

Female

N (%)

24 (24.00%)

2004-06-01 to 2004-06-30

overall

overall

N (%)

47 (47.00%)

\<=60

overall

N (%)

47 (47.00%)

overall

Male

N (%)

23 (23.00%)

Female

N (%)

24 (24.00%)

\<=60

Male

N (%)

23 (23.00%)

Female

N (%)

24 (24.00%)

2004-07-01 to 2004-07-31

overall

overall

N (%)

46 (46.00%)

\<=60

overall

N (%)

46 (46.00%)

overall

Male

N (%)

23 (23.00%)

Female

N (%)

23 (23.00%)

\<=60

Male

N (%)

23 (23.00%)

Female

N (%)

23 (23.00%)

2004-08-01 to 2004-08-31

overall

overall

N (%)

46 (46.00%)

\<=60

overall

N (%)

46 (46.00%)

overall

Male

N (%)

23 (23.00%)

Female

N (%)

23 (23.00%)

\<=60

Male

N (%)

23 (23.00%)

Female

N (%)

23 (23.00%)

2004-09-01 to 2004-09-30

overall

overall

N (%)

46 (46.00%)

\<=60

overall

N (%)

46 (46.00%)

overall

Male

N (%)

23 (23.00%)

Female

N (%)

23 (23.00%)

\<=60

Male

N (%)

23 (23.00%)

Female

N (%)

23 (23.00%)

2004-10-01 to 2004-10-31

overall

overall

N (%)

44 (44.00%)

\<=60

overall

N (%)

44 (44.00%)

overall

Male

N (%)

22 (22.00%)

Female

N (%)

22 (22.00%)

\<=60

Male

N (%)

22 (22.00%)

Female

N (%)

22 (22.00%)

2004-11-01 to 2004-11-30

overall

overall

N (%)

43 (43.00%)

\<=60

overall

N (%)

43 (43.00%)

overall

Male

N (%)

22 (22.00%)

Female

N (%)

21 (21.00%)

\<=60

Male

N (%)

22 (22.00%)

Female

N (%)

21 (21.00%)

2004-12-01 to 2004-12-31

overall

overall

N (%)

43 (43.00%)

\<=60

overall

N (%)

43 (43.00%)

overall

Male

N (%)

22 (22.00%)

Female

N (%)

21 (21.00%)

\<=60

Male

N (%)

22 (22.00%)

Female

N (%)

21 (21.00%)

2005-01-01 to 2005-01-31

overall

overall

N (%)

43 (43.00%)

\<=60

overall

N (%)

43 (43.00%)

overall

Male

N (%)

22 (22.00%)

Female

N (%)

21 (21.00%)

\<=60

Male

N (%)

22 (22.00%)

Female

N (%)

21 (21.00%)

2005-02-01 to 2005-02-28

overall

overall

N (%)

43 (43.00%)

\<=60

overall

N (%)

43 (43.00%)

overall

Male

N (%)

22 (22.00%)

Female

N (%)

21 (21.00%)

\<=60

Male

N (%)

22 (22.00%)

Female

N (%)

21 (21.00%)

2005-03-01 to 2005-03-31

overall

overall

N (%)

43 (43.00%)

\<=60

overall

N (%)

43 (43.00%)

overall

Male

N (%)

22 (22.00%)

Female

N (%)

21 (21.00%)

\<=60

Male

N (%)

22 (22.00%)

Female

N (%)

21 (21.00%)

2005-04-01 to 2005-04-30

overall

overall

N (%)

43 (43.00%)

\<=60

overall

N (%)

43 (43.00%)

overall

Male

N (%)

22 (22.00%)

Female

N (%)

21 (21.00%)

\<=60

Male

N (%)

22 (22.00%)

Female

N (%)

21 (21.00%)

2005-05-01 to 2005-05-31

overall

overall

N (%)

43 (43.00%)

\<=60

overall

N (%)

43 (43.00%)

overall

Male

N (%)

22 (22.00%)

Female

N (%)

21 (21.00%)

\<=60

Male

N (%)

22 (22.00%)

Female

N (%)

21 (21.00%)

2005-06-01 to 2005-06-30

overall

overall

N (%)

42 (42.00%)

\<=60

overall

N (%)

42 (42.00%)

overall

Male

N (%)

22 (22.00%)

Female

N (%)

20 (20.00%)

\<=60

Male

N (%)

22 (22.00%)

Female

N (%)

20 (20.00%)

2005-07-01 to 2005-07-31

overall

overall

N (%)

42 (42.00%)

\<=60

overall

N (%)

42 (42.00%)

overall

Male

N (%)

22 (22.00%)

Female

N (%)

20 (20.00%)

\<=60

Male

N (%)

22 (22.00%)

Female

N (%)

20 (20.00%)

2005-08-01 to 2005-08-31

overall

overall

N (%)

42 (42.00%)

\<=60

overall

N (%)

42 (42.00%)

overall

Male

N (%)

22 (22.00%)

Female

N (%)

20 (20.00%)

\<=60

Male

N (%)

22 (22.00%)

Female

N (%)

20 (20.00%)

2005-09-01 to 2005-09-30

overall

overall

N (%)

43 (43.00%)

\<=60

overall

N (%)

43 (43.00%)

overall

Male

N (%)

22 (22.00%)

Female

N (%)

21 (21.00%)

\<=60

Male

N (%)

22 (22.00%)

Female

N (%)

21 (21.00%)

2005-10-01 to 2005-10-31

overall

overall

N (%)

43 (43.00%)

\<=60

overall

N (%)

43 (43.00%)

overall

Male

N (%)

22 (22.00%)

Female

N (%)

21 (21.00%)

\<=60

Male

N (%)

22 (22.00%)

Female

N (%)

21 (21.00%)

2005-11-01 to 2005-11-30

overall

overall

N (%)

43 (43.00%)

\<=60

overall

N (%)

43 (43.00%)

overall

Male

N (%)

22 (22.00%)

Female

N (%)

21 (21.00%)

\<=60

Male

N (%)

22 (22.00%)

Female

N (%)

21 (21.00%)

2005-12-01 to 2005-12-31

overall

overall

N (%)

43 (43.00%)

\<=60

overall

N (%)

43 (43.00%)

overall

Male

N (%)

22 (22.00%)

Female

N (%)

21 (21.00%)

\<=60

Male

N (%)

22 (22.00%)

Female

N (%)

21 (21.00%)

2006-01-01 to 2006-01-31

overall

overall

N (%)

43 (43.00%)

\<=60

overall

N (%)

43 (43.00%)

overall

Male

N (%)

22 (22.00%)

Female

N (%)

21 (21.00%)

\<=60

Male

N (%)

22 (22.00%)

Female

N (%)

21 (21.00%)

2006-02-01 to 2006-02-28

overall

overall

N (%)

43 (43.00%)

\<=60

overall

N (%)

43 (43.00%)

overall

Male

N (%)

22 (22.00%)

Female

N (%)

21 (21.00%)

\<=60

Male

N (%)

22 (22.00%)

Female

N (%)

21 (21.00%)

2006-03-01 to 2006-03-31

overall

overall

N (%)

43 (43.00%)

\<=60

overall

N (%)

43 (43.00%)

overall

Male

N (%)

22 (22.00%)

Female

N (%)

21 (21.00%)

\<=60

Male

N (%)

22 (22.00%)

Female

N (%)

21 (21.00%)

2006-04-01 to 2006-04-30

overall

overall

N (%)

42 (42.00%)

\<=60

overall

N (%)

42 (42.00%)

overall

Male

N (%)

21 (21.00%)

Female

N (%)

21 (21.00%)

\<=60

Male

N (%)

21 (21.00%)

Female

N (%)

21 (21.00%)

2006-05-01 to 2006-05-31

overall

overall

N (%)

42 (42.00%)

\<=60

overall

N (%)

42 (42.00%)

overall

Male

N (%)

21 (21.00%)

Female

N (%)

21 (21.00%)

\<=60

Male

N (%)

21 (21.00%)

Female

N (%)

21 (21.00%)

2006-06-01 to 2006-06-30

overall

overall

N (%)

41 (41.00%)

\<=60

overall

N (%)

41 (41.00%)

overall

Male

N (%)

20 (20.00%)

Female

N (%)

21 (21.00%)

\<=60

Male

N (%)

20 (20.00%)

Female

N (%)

21 (21.00%)

2006-07-01 to 2006-07-31

overall

overall

N (%)

41 (41.00%)

\<=60

overall

N (%)

41 (41.00%)

overall

Male

N (%)

20 (20.00%)

Female

N (%)

21 (21.00%)

\<=60

Male

N (%)

20 (20.00%)

Female

N (%)

21 (21.00%)

2006-08-01 to 2006-08-31

overall

overall

N (%)

42 (42.00%)

\<=60

overall

N (%)

42 (42.00%)

overall

Male

N (%)

20 (20.00%)

Female

N (%)

22 (22.00%)

\<=60

Male

N (%)

20 (20.00%)

Female

N (%)

22 (22.00%)

2006-09-01 to 2006-09-30

overall

overall

N (%)

42 (42.00%)

\<=60

overall

N (%)

42 (42.00%)

overall

Male

N (%)

20 (20.00%)

Female

N (%)

22 (22.00%)

\<=60

Male

N (%)

20 (20.00%)

Female

N (%)

22 (22.00%)

2006-10-01 to 2006-10-31

overall

overall

N (%)

42 (42.00%)

\<=60

overall

N (%)

42 (42.00%)

overall

Male

N (%)

20 (20.00%)

Female

N (%)

22 (22.00%)

\<=60

Male

N (%)

20 (20.00%)

Female

N (%)

22 (22.00%)

2006-11-01 to 2006-11-30

overall

overall

N (%)

42 (42.00%)

\<=60

overall

N (%)

42 (42.00%)

overall

Male

N (%)

20 (20.00%)

Female

N (%)

22 (22.00%)

\<=60

Male

N (%)

20 (20.00%)

Female

N (%)

22 (22.00%)

2006-12-01 to 2006-12-31

overall

overall

N (%)

42 (42.00%)

\<=60

overall

N (%)

42 (42.00%)

overall

Male

N (%)

20 (20.00%)

Female

N (%)

22 (22.00%)

\<=60

Male

N (%)

20 (20.00%)

Female

N (%)

22 (22.00%)

2007-01-01 to 2007-01-31

overall

overall

N (%)

42 (42.00%)

\<=60

overall

N (%)

42 (42.00%)

overall

Male

N (%)

20 (20.00%)

Female

N (%)

22 (22.00%)

\<=60

Male

N (%)

20 (20.00%)

Female

N (%)

22 (22.00%)

2007-02-01 to 2007-02-28

overall

overall

N (%)

41 (41.00%)

\<=60

overall

N (%)

41 (41.00%)

overall

Male

N (%)

19 (19.00%)

Female

N (%)

22 (22.00%)

\<=60

Male

N (%)

19 (19.00%)

Female

N (%)

22 (22.00%)

2007-03-01 to 2007-03-31

overall

overall

N (%)

41 (41.00%)

\<=60

overall

N (%)

41 (41.00%)

overall

Male

N (%)

19 (19.00%)

Female

N (%)

22 (22.00%)

\<=60

Male

N (%)

19 (19.00%)

Female

N (%)

22 (22.00%)

2007-04-01 to 2007-04-30

overall

overall

N (%)

41 (41.00%)

\<=60

overall

N (%)

41 (41.00%)

overall

Male

N (%)

19 (19.00%)

Female

N (%)

22 (22.00%)

\<=60

Male

N (%)

19 (19.00%)

Female

N (%)

22 (22.00%)

2007-05-01 to 2007-05-31

overall

overall

N (%)

40 (40.00%)

\<=60

overall

N (%)

40 (40.00%)

overall

Male

N (%)

18 (18.00%)

Female

N (%)

22 (22.00%)

\<=60

Male

N (%)

18 (18.00%)

Female

N (%)

22 (22.00%)

2007-06-01 to 2007-06-30

overall

overall

N (%)

40 (40.00%)

\<=60

overall

N (%)

40 (40.00%)

overall

Male

N (%)

18 (18.00%)

Female

N (%)

22 (22.00%)

\<=60

Male

N (%)

18 (18.00%)

Female

N (%)

22 (22.00%)

2007-07-01 to 2007-07-31

overall

overall

N (%)

40 (40.00%)

\<=60

overall

N (%)

40 (40.00%)

overall

Male

N (%)

18 (18.00%)

Female

N (%)

22 (22.00%)

\<=60

Male

N (%)

18 (18.00%)

Female

N (%)

22 (22.00%)

2007-08-01 to 2007-08-31

overall

overall

N (%)

41 (41.00%)

\<=60

overall

N (%)

41 (41.00%)

overall

Male

N (%)

19 (19.00%)

Female

N (%)

22 (22.00%)

\<=60

Male

N (%)

19 (19.00%)

Female

N (%)

22 (22.00%)

2007-09-01 to 2007-09-30

overall

overall

N (%)

41 (41.00%)

\<=60

overall

N (%)

41 (41.00%)

overall

Male

N (%)

19 (19.00%)

Female

N (%)

22 (22.00%)

\<=60

Male

N (%)

19 (19.00%)

Female

N (%)

22 (22.00%)

2007-10-01 to 2007-10-31

overall

overall

N (%)

41 (41.00%)

\<=60

overall

N (%)

41 (41.00%)

overall

Male

N (%)

19 (19.00%)

Female

N (%)

22 (22.00%)

\<=60

Male

N (%)

19 (19.00%)

Female

N (%)

22 (22.00%)

2007-11-01 to 2007-11-30

overall

overall

N (%)

42 (42.00%)

\<=60

overall

N (%)

42 (42.00%)

overall

Male

N (%)

19 (19.00%)

Female

N (%)

23 (23.00%)

\<=60

Male

N (%)

19 (19.00%)

Female

N (%)

23 (23.00%)

2007-12-01 to 2007-12-31

overall

overall

N (%)

42 (42.00%)

\<=60

overall

N (%)

42 (42.00%)

overall

Male

N (%)

19 (19.00%)

Female

N (%)

23 (23.00%)

\<=60

Male

N (%)

19 (19.00%)

Female

N (%)

23 (23.00%)

2008-01-01 to 2008-01-31

overall

overall

N (%)

42 (42.00%)

\<=60

overall

N (%)

42 (42.00%)

overall

Male

N (%)

19 (19.00%)

Female

N (%)

23 (23.00%)

\<=60

Male

N (%)

19 (19.00%)

Female

N (%)

23 (23.00%)

2008-02-01 to 2008-02-29

overall

overall

N (%)

41 (41.00%)

\<=60

overall

N (%)

41 (41.00%)

overall

Male

N (%)

18 (18.00%)

Female

N (%)

23 (23.00%)

\<=60

Male

N (%)

18 (18.00%)

Female

N (%)

23 (23.00%)

2008-03-01 to 2008-03-31

overall

overall

N (%)

41 (41.00%)

\<=60

overall

N (%)

41 (41.00%)

overall

Male

N (%)

18 (18.00%)

Female

N (%)

23 (23.00%)

\<=60

Male

N (%)

18 (18.00%)

Female

N (%)

23 (23.00%)

2008-04-01 to 2008-04-30

overall

overall

N (%)

38 (38.00%)

\<=60

overall

N (%)

38 (38.00%)

overall

Male

N (%)

18 (18.00%)

Female

N (%)

20 (20.00%)

\<=60

Male

N (%)

18 (18.00%)

Female

N (%)

20 (20.00%)

2008-05-01 to 2008-05-31

overall

overall

N (%)

36 (36.00%)

\<=60

overall

N (%)

36 (36.00%)

overall

Male

N (%)

18 (18.00%)

Female

N (%)

18 (18.00%)

\<=60

Male

N (%)

18 (18.00%)

Female

N (%)

18 (18.00%)

2008-06-01 to 2008-06-30

overall

overall

N (%)

36 (36.00%)

\<=60

overall

N (%)

36 (36.00%)

overall

Male

N (%)

18 (18.00%)

Female

N (%)

18 (18.00%)

\<=60

Male

N (%)

18 (18.00%)

Female

N (%)

18 (18.00%)

2008-07-01 to 2008-07-31

overall

overall

N (%)

35 (35.00%)

\<=60

overall

N (%)

35 (35.00%)

overall

Male

N (%)

17 (17.00%)

Female

N (%)

18 (18.00%)

\<=60

Male

N (%)

17 (17.00%)

Female

N (%)

18 (18.00%)

2008-08-01 to 2008-08-31

overall

overall

N (%)

35 (35.00%)

\<=60

overall

N (%)

35 (35.00%)

overall

Male

N (%)

17 (17.00%)

Female

N (%)

18 (18.00%)

\<=60

Male

N (%)

17 (17.00%)

Female

N (%)

18 (18.00%)

2008-09-01 to 2008-09-30

overall

overall

N (%)

34 (34.00%)

\<=60

overall

N (%)

34 (34.00%)

overall

Male

N (%)

16 (16.00%)

Female

N (%)

18 (18.00%)

\<=60

Male

N (%)

16 (16.00%)

Female

N (%)

18 (18.00%)

2008-10-01 to 2008-10-31

overall

overall

N (%)

33 (33.00%)

\<=60

overall

N (%)

33 (33.00%)

overall

Male

N (%)

15 (15.00%)

Female

N (%)

18 (18.00%)

\<=60

Male

N (%)

15 (15.00%)

Female

N (%)

18 (18.00%)

2008-11-01 to 2008-11-30

overall

overall

N (%)

33 (33.00%)

\<=60

overall

N (%)

33 (33.00%)

overall

Male

N (%)

15 (15.00%)

Female

N (%)

18 (18.00%)

\<=60

Male

N (%)

15 (15.00%)

Female

N (%)

18 (18.00%)

2008-12-01 to 2008-12-31

overall

overall

N (%)

33 (33.00%)

\<=60

overall

N (%)

33 (33.00%)

overall

Male

N (%)

15 (15.00%)

Female

N (%)

18 (18.00%)

\<=60

Male

N (%)

15 (15.00%)

Female

N (%)

18 (18.00%)

2009-01-01 to 2009-01-31

overall

overall

N (%)

31 (31.00%)

\<=60

overall

N (%)

31 (31.00%)

overall

Male

N (%)

15 (15.00%)

Female

N (%)

16 (16.00%)

\<=60

Male

N (%)

15 (15.00%)

Female

N (%)

16 (16.00%)

2009-02-01 to 2009-02-28

overall

overall

N (%)

31 (31.00%)

\<=60

overall

N (%)

31 (31.00%)

overall

Male

N (%)

15 (15.00%)

Female

N (%)

16 (16.00%)

\<=60

Male

N (%)

15 (15.00%)

Female

N (%)

16 (16.00%)

2009-03-01 to 2009-03-31

overall

overall

N (%)

31 (31.00%)

\<=60

overall

N (%)

31 (31.00%)

overall

Male

N (%)

15 (15.00%)

Female

N (%)

16 (16.00%)

\<=60

Male

N (%)

15 (15.00%)

Female

N (%)

16 (16.00%)

2009-04-01 to 2009-04-30

overall

overall

N (%)

31 (31.00%)

\<=60

overall

N (%)

31 (31.00%)

overall

Male

N (%)

15 (15.00%)

Female

N (%)

16 (16.00%)

\<=60

Male

N (%)

15 (15.00%)

Female

N (%)

16 (16.00%)

2009-05-01 to 2009-05-31

overall

overall

N (%)

30 (30.00%)

\<=60

overall

N (%)

30 (30.00%)

overall

Male

N (%)

14 (14.00%)

Female

N (%)

16 (16.00%)

\<=60

Male

N (%)

14 (14.00%)

Female

N (%)

16 (16.00%)

2009-06-01 to 2009-06-30

overall

overall

N (%)

31 (31.00%)

\<=60

overall

N (%)

31 (31.00%)

overall

Male

N (%)

15 (15.00%)

Female

N (%)

16 (16.00%)

\<=60

Male

N (%)

15 (15.00%)

Female

N (%)

16 (16.00%)

2009-07-01 to 2009-07-31

overall

overall

N (%)

31 (31.00%)

\<=60

overall

N (%)

31 (31.00%)

overall

Male

N (%)

15 (15.00%)

Female

N (%)

16 (16.00%)

\<=60

Male

N (%)

15 (15.00%)

Female

N (%)

16 (16.00%)

2009-08-01 to 2009-08-31

overall

overall

N (%)

31 (31.00%)

\<=60

overall

N (%)

31 (31.00%)

overall

Male

N (%)

15 (15.00%)

Female

N (%)

16 (16.00%)

\<=60

Male

N (%)

15 (15.00%)

Female

N (%)

16 (16.00%)

2009-09-01 to 2009-09-30

overall

overall

N (%)

31 (31.00%)

\<=60

overall

N (%)

31 (31.00%)

overall

Male

N (%)

15 (15.00%)

Female

N (%)

16 (16.00%)

\<=60

Male

N (%)

15 (15.00%)

Female

N (%)

16 (16.00%)

2009-10-01 to 2009-10-31

overall

overall

N (%)

31 (31.00%)

\<=60

overall

N (%)

31 (31.00%)

overall

Male

N (%)

15 (15.00%)

Female

N (%)

16 (16.00%)

\<=60

Male

N (%)

15 (15.00%)

Female

N (%)

16 (16.00%)

2009-11-01 to 2009-11-30

overall

overall

N (%)

33 (33.00%)

\<=60

overall

N (%)

33 (33.00%)

overall

Male

N (%)

16 (16.00%)

Female

N (%)

17 (17.00%)

\<=60

Male

N (%)

16 (16.00%)

Female

N (%)

17 (17.00%)

2009-12-01 to 2009-12-31

overall

overall

N (%)

33 (33.00%)

\<=60

overall

N (%)

33 (33.00%)

overall

Male

N (%)

16 (16.00%)

Female

N (%)

17 (17.00%)

\<=60

Male

N (%)

16 (16.00%)

Female

N (%)

17 (17.00%)

2010-01-01 to 2010-01-31

overall

overall

N (%)

32 (32.00%)

\<=60

overall

N (%)

32 (32.00%)

overall

Male

N (%)

16 (16.00%)

Female

N (%)

16 (16.00%)

\<=60

Male

N (%)

16 (16.00%)

Female

N (%)

16 (16.00%)

2010-02-01 to 2010-02-28

overall

overall

N (%)

32 (32.00%)

\<=60

overall

N (%)

32 (32.00%)

overall

Male

N (%)

16 (16.00%)

Female

N (%)

16 (16.00%)

\<=60

Male

N (%)

16 (16.00%)

Female

N (%)

16 (16.00%)

2010-03-01 to 2010-03-31

overall

overall

N (%)

32 (32.00%)

\<=60

overall

N (%)

32 (32.00%)

overall

Male

N (%)

16 (16.00%)

Female

N (%)

16 (16.00%)

\<=60

Male

N (%)

16 (16.00%)

Female

N (%)

16 (16.00%)

2010-04-01 to 2010-04-30

overall

overall

N (%)

31 (31.00%)

\<=60

overall

N (%)

31 (31.00%)

overall

Male

N (%)

15 (15.00%)

Female

N (%)

16 (16.00%)

\<=60

Male

N (%)

15 (15.00%)

Female

N (%)

16 (16.00%)

2010-05-01 to 2010-05-31

overall

overall

N (%)

31 (31.00%)

\<=60

overall

N (%)

31 (31.00%)

overall

Male

N (%)

15 (15.00%)

Female

N (%)

16 (16.00%)

\<=60

Male

N (%)

15 (15.00%)

Female

N (%)

16 (16.00%)

2010-06-01 to 2010-06-30

overall

overall

N (%)

30 (30.00%)

\<=60

overall

N (%)

30 (30.00%)

overall

Male

N (%)

15 (15.00%)

Female

N (%)

15 (15.00%)

\<=60

Male

N (%)

15 (15.00%)

Female

N (%)

15 (15.00%)

2010-07-01 to 2010-07-31

overall

overall

N (%)

30 (30.00%)

\<=60

overall

N (%)

30 (30.00%)

overall

Male

N (%)

15 (15.00%)

Female

N (%)

15 (15.00%)

\<=60

Male

N (%)

15 (15.00%)

Female

N (%)

15 (15.00%)

2010-08-01 to 2010-08-31

overall

overall

N (%)

30 (30.00%)

\<=60

overall

N (%)

30 (30.00%)

overall

Male

N (%)

15 (15.00%)

Female

N (%)

15 (15.00%)

\<=60

Male

N (%)

15 (15.00%)

Female

N (%)

15 (15.00%)

2010-09-01 to 2010-09-30

overall

overall

N (%)

29 (29.00%)

\<=60

overall

N (%)

29 (29.00%)

overall

Male

N (%)

14 (14.00%)

Female

N (%)

15 (15.00%)

\<=60

Male

N (%)

14 (14.00%)

Female

N (%)

15 (15.00%)

2010-10-01 to 2010-10-31

overall

overall

N (%)

30 (30.00%)

\<=60

overall

N (%)

30 (30.00%)

overall

Male

N (%)

14 (14.00%)

Female

N (%)

16 (16.00%)

\<=60

Male

N (%)

14 (14.00%)

Female

N (%)

16 (16.00%)

2010-11-01 to 2010-11-30

overall

overall

N (%)

31 (31.00%)

\<=60

overall

N (%)

31 (31.00%)

overall

Male

N (%)

15 (15.00%)

Female

N (%)

16 (16.00%)

\<=60

Male

N (%)

15 (15.00%)

Female

N (%)

16 (16.00%)

2010-12-01 to 2010-12-31

overall

overall

N (%)

30 (30.00%)

\<=60

overall

N (%)

30 (30.00%)

overall

Male

N (%)

15 (15.00%)

Female

N (%)

15 (15.00%)

\<=60

Male

N (%)

15 (15.00%)

Female

N (%)

15 (15.00%)

2011-01-01 to 2011-01-31

overall

overall

N (%)

30 (30.00%)

\<=60

overall

N (%)

30 (30.00%)

overall

Male

N (%)

15 (15.00%)

Female

N (%)

15 (15.00%)

\<=60

Male

N (%)

15 (15.00%)

Female

N (%)

15 (15.00%)

2011-02-01 to 2011-02-28

overall

overall

N (%)

30 (30.00%)

\<=60

overall

N (%)

30 (30.00%)

overall

Male

N (%)

15 (15.00%)

Female

N (%)

15 (15.00%)

\<=60

Male

N (%)

15 (15.00%)

Female

N (%)

15 (15.00%)

2011-03-01 to 2011-03-31

overall

overall

N (%)

30 (30.00%)

\<=60

overall

N (%)

30 (30.00%)

overall

Male

N (%)

15 (15.00%)

Female

N (%)

15 (15.00%)

\<=60

Male

N (%)

15 (15.00%)

Female

N (%)

15 (15.00%)

2011-04-01 to 2011-04-30

overall

overall

N (%)

30 (30.00%)

\<=60

overall

N (%)

30 (30.00%)

overall

Male

N (%)

15 (15.00%)

Female

N (%)

15 (15.00%)

\<=60

Male

N (%)

15 (15.00%)

Female

N (%)

15 (15.00%)

2011-05-01 to 2011-05-31

overall

overall

N (%)

30 (30.00%)

\<=60

overall

N (%)

30 (30.00%)

overall

Male

N (%)

15 (15.00%)

Female

N (%)

15 (15.00%)

\<=60

Male

N (%)

15 (15.00%)

Female

N (%)

15 (15.00%)

2011-06-01 to 2011-06-30

overall

overall

N (%)

30 (30.00%)

\<=60

overall

N (%)

30 (30.00%)

overall

Male

N (%)

15 (15.00%)

Female

N (%)

15 (15.00%)

\<=60

Male

N (%)

15 (15.00%)

Female

N (%)

15 (15.00%)

2011-07-01 to 2011-07-31

overall

overall

N (%)

31 (31.00%)

\<=60

overall

N (%)

31 (31.00%)

overall

Male

N (%)

16 (16.00%)

Female

N (%)

15 (15.00%)

\<=60

Male

N (%)

16 (16.00%)

Female

N (%)

15 (15.00%)

2011-08-01 to 2011-08-31

overall

overall

N (%)

31 (31.00%)

\<=60

overall

N (%)

31 (31.00%)

overall

Male

N (%)

16 (16.00%)

Female

N (%)

15 (15.00%)

\<=60

Male

N (%)

16 (16.00%)

Female

N (%)

15 (15.00%)

2011-09-01 to 2011-09-30

overall

overall

N (%)

31 (31.00%)

\<=60

overall

N (%)

31 (31.00%)

overall

Male

N (%)

16 (16.00%)

Female

N (%)

15 (15.00%)

\<=60

Male

N (%)

16 (16.00%)

Female

N (%)

15 (15.00%)

2011-10-01 to 2011-10-31

overall

overall

N (%)

31 (31.00%)

\<=60

overall

N (%)

31 (31.00%)

overall

Male

N (%)

16 (16.00%)

Female

N (%)

15 (15.00%)

\<=60

Male

N (%)

16 (16.00%)

Female

N (%)

15 (15.00%)

2011-11-01 to 2011-11-30

overall

overall

N (%)

31 (31.00%)

\<=60

overall

N (%)

31 (31.00%)

overall

Male

N (%)

16 (16.00%)

Female

N (%)

15 (15.00%)

\<=60

Male

N (%)

16 (16.00%)

Female

N (%)

15 (15.00%)

2011-12-01 to 2011-12-31

overall

overall

N (%)

31 (31.00%)

\<=60

overall

N (%)

31 (31.00%)

overall

Male

N (%)

16 (16.00%)

Female

N (%)

15 (15.00%)

\<=60

Male

N (%)

16 (16.00%)

Female

N (%)

15 (15.00%)

2012-01-01 to 2012-01-31

overall

overall

N (%)

31 (31.00%)

\<=60

overall

N (%)

31 (31.00%)

overall

Male

N (%)

16 (16.00%)

Female

N (%)

15 (15.00%)

\<=60

Male

N (%)

16 (16.00%)

Female

N (%)

15 (15.00%)

2012-02-01 to 2012-02-29

overall

overall

N (%)

31 (31.00%)

\<=60

overall

N (%)

31 (31.00%)

overall

Male

N (%)

16 (16.00%)

Female

N (%)

15 (15.00%)

\<=60

Male

N (%)

16 (16.00%)

Female

N (%)

15 (15.00%)

2012-03-01 to 2012-03-31

overall

overall

N (%)

31 (31.00%)

\<=60

overall

N (%)

31 (31.00%)

overall

Male

N (%)

16 (16.00%)

Female

N (%)

15 (15.00%)

\<=60

Male

N (%)

16 (16.00%)

Female

N (%)

15 (15.00%)

2012-04-01 to 2012-04-30

overall

overall

N (%)

32 (32.00%)

\<=60

overall

N (%)

32 (32.00%)

overall

Male

N (%)

16 (16.00%)

Female

N (%)

16 (16.00%)

\<=60

Male

N (%)

16 (16.00%)

Female

N (%)

16 (16.00%)

2012-05-01 to 2012-05-31

overall

overall

N (%)

31 (31.00%)

\<=60

overall

N (%)

31 (31.00%)

overall

Male

N (%)

16 (16.00%)

Female

N (%)

15 (15.00%)

\<=60

Male

N (%)

16 (16.00%)

Female

N (%)

15 (15.00%)

2012-06-01 to 2012-06-30

overall

overall

N (%)

31 (31.00%)

\<=60

overall

N (%)

31 (31.00%)

overall

Male

N (%)

16 (16.00%)

Female

N (%)

15 (15.00%)

\<=60

Male

N (%)

16 (16.00%)

Female

N (%)

15 (15.00%)

2012-07-01 to 2012-07-31

overall

overall

N (%)

30 (30.00%)

\<=60

overall

N (%)

30 (30.00%)

overall

Male

N (%)

15 (15.00%)

Female

N (%)

15 (15.00%)

\<=60

Male

N (%)

15 (15.00%)

Female

N (%)

15 (15.00%)

2012-08-01 to 2012-08-31

overall

overall

N (%)

30 (30.00%)

\<=60

overall

N (%)

30 (30.00%)

overall

Male

N (%)

15 (15.00%)

Female

N (%)

15 (15.00%)

\<=60

Male

N (%)

15 (15.00%)

Female

N (%)

15 (15.00%)

2012-09-01 to 2012-09-30

overall

overall

N (%)

29 (29.00%)

\<=60

overall

N (%)

29 (29.00%)

overall

Male

N (%)

14 (14.00%)

Female

N (%)

15 (15.00%)

\<=60

Male

N (%)

14 (14.00%)

Female

N (%)

15 (15.00%)

2012-10-01 to 2012-10-31

overall

overall

N (%)

28 (28.00%)

\<=60

overall

N (%)

28 (28.00%)

overall

Male

N (%)

13 (13.00%)

Female

N (%)

15 (15.00%)

\<=60

Male

N (%)

13 (13.00%)

Female

N (%)

15 (15.00%)

2012-11-01 to 2012-11-30

overall

overall

N (%)

26 (26.00%)

\<=60

overall

N (%)

26 (26.00%)

overall

Male

N (%)

13 (13.00%)

Female

N (%)

13 (13.00%)

\<=60

Male

N (%)

13 (13.00%)

Female

N (%)

13 (13.00%)

2012-12-01 to 2012-12-31

overall

overall

N (%)

27 (27.00%)

\<=60

overall

N (%)

27 (27.00%)

overall

Male

N (%)

13 (13.00%)

Female

N (%)

14 (14.00%)

\<=60

Male

N (%)

13 (13.00%)

Female

N (%)

14 (14.00%)

2013-01-01 to 2013-01-31

overall

overall

N (%)

27 (27.00%)

\<=60

overall

N (%)

27 (27.00%)

overall

Male

N (%)

13 (13.00%)

Female

N (%)

14 (14.00%)

\<=60

Male

N (%)

13 (13.00%)

Female

N (%)

14 (14.00%)

2013-02-01 to 2013-02-28

overall

overall

N (%)

27 (27.00%)

\<=60

overall

N (%)

27 (27.00%)

overall

Male

N (%)

13 (13.00%)

Female

N (%)

14 (14.00%)

\<=60

Male

N (%)

13 (13.00%)

Female

N (%)

14 (14.00%)

2013-03-01 to 2013-03-31

overall

overall

N (%)

26 (26.00%)

\<=60

overall

N (%)

26 (26.00%)

overall

Male

N (%)

13 (13.00%)

Female

N (%)

13 (13.00%)

\<=60

Male

N (%)

13 (13.00%)

Female

N (%)

13 (13.00%)

2013-04-01 to 2013-04-30

overall

overall

N (%)

26 (26.00%)

\<=60

overall

N (%)

26 (26.00%)

overall

Male

N (%)

13 (13.00%)

Female

N (%)

13 (13.00%)

\<=60

Male

N (%)

13 (13.00%)

Female

N (%)

13 (13.00%)

2013-05-01 to 2013-05-31

overall

overall

N (%)

26 (26.00%)

\<=60

overall

N (%)

26 (26.00%)

overall

Male

N (%)

13 (13.00%)

Female

N (%)

13 (13.00%)

\<=60

Male

N (%)

13 (13.00%)

Female

N (%)

13 (13.00%)

2013-06-01 to 2013-06-30

overall

overall

N (%)

27 (27.00%)

\<=60

overall

N (%)

27 (27.00%)

overall

Male

N (%)

13 (13.00%)

Female

N (%)

14 (14.00%)

\<=60

Male

N (%)

13 (13.00%)

Female

N (%)

14 (14.00%)

2013-07-01 to 2013-07-31

overall

overall

N (%)

26 (26.00%)

\<=60

overall

N (%)

26 (26.00%)

overall

Male

N (%)

12 (12.00%)

Female

N (%)

14 (14.00%)

\<=60

Male

N (%)

12 (12.00%)

Female

N (%)

14 (14.00%)

2013-08-01 to 2013-08-31

overall

overall

N (%)

26 (26.00%)

\<=60

overall

N (%)

26 (26.00%)

overall

Male

N (%)

12 (12.00%)

Female

N (%)

14 (14.00%)

\<=60

Male

N (%)

12 (12.00%)

Female

N (%)

14 (14.00%)

2013-09-01 to 2013-09-30

overall

overall

N (%)

25 (25.00%)

\<=60

overall

N (%)

25 (25.00%)

overall

Male

N (%)

12 (12.00%)

Female

N (%)

13 (13.00%)

\<=60

Male

N (%)

12 (12.00%)

Female

N (%)

13 (13.00%)

2013-10-01 to 2013-10-31

overall

overall

N (%)

25 (25.00%)

\<=60

overall

N (%)

25 (25.00%)

overall

Male

N (%)

12 (12.00%)

Female

N (%)

13 (13.00%)

\<=60

Male

N (%)

12 (12.00%)

Female

N (%)

13 (13.00%)

2013-11-01 to 2013-11-30

overall

overall

N (%)

25 (25.00%)

\<=60

overall

N (%)

25 (25.00%)

overall

Male

N (%)

12 (12.00%)

Female

N (%)

13 (13.00%)

\<=60

Male

N (%)

12 (12.00%)

Female

N (%)

13 (13.00%)

2013-12-01 to 2013-12-31

overall

overall

N (%)

25 (25.00%)

\<=60

overall

N (%)

25 (25.00%)

overall

Male

N (%)

12 (12.00%)

Female

N (%)

13 (13.00%)

\<=60

Male

N (%)

12 (12.00%)

Female

N (%)

13 (13.00%)

2014-01-01 to 2014-01-31

overall

overall

N (%)

25 (25.00%)

\<=60

overall

N (%)

25 (25.00%)

overall

Male

N (%)

12 (12.00%)

Female

N (%)

13 (13.00%)

\<=60

Male

N (%)

12 (12.00%)

Female

N (%)

13 (13.00%)

2014-02-01 to 2014-02-28

overall

overall

N (%)

25 (25.00%)

\<=60

overall

N (%)

25 (25.00%)

overall

Male

N (%)

12 (12.00%)

Female

N (%)

13 (13.00%)

\<=60

Male

N (%)

12 (12.00%)

Female

N (%)

13 (13.00%)

2014-03-01 to 2014-03-31

overall

overall

N (%)

25 (25.00%)

\<=60

overall

N (%)

25 (25.00%)

overall

Male

N (%)

12 (12.00%)

Female

N (%)

13 (13.00%)

\<=60

Male

N (%)

12 (12.00%)

Female

N (%)

13 (13.00%)

2014-04-01 to 2014-04-30

overall

overall

N (%)

26 (26.00%)

\<=60

overall

N (%)

26 (26.00%)

overall

Male

N (%)

13 (13.00%)

Female

N (%)

13 (13.00%)

\<=60

Male

N (%)

13 (13.00%)

Female

N (%)

13 (13.00%)

2014-05-01 to 2014-05-31

overall

overall

N (%)

25 (25.00%)

\<=60

overall

N (%)

25 (25.00%)

overall

Male

N (%)

13 (13.00%)

Female

N (%)

12 (12.00%)

\<=60

Male

N (%)

13 (13.00%)

Female

N (%)

12 (12.00%)

2014-06-01 to 2014-06-30

overall

overall

N (%)

24 (24.00%)

\<=60

overall

N (%)

24 (24.00%)

overall

Male

N (%)

13 (13.00%)

Female

N (%)

11 (11.00%)

\<=60

Male

N (%)

13 (13.00%)

Female

N (%)

11 (11.00%)

2014-07-01 to 2014-07-31

overall

overall

N (%)

24 (24.00%)

\<=60

overall

N (%)

24 (24.00%)

overall

Male

N (%)

13 (13.00%)

Female

N (%)

11 (11.00%)

\<=60

Male

N (%)

13 (13.00%)

Female

N (%)

11 (11.00%)

2014-08-01 to 2014-08-31

overall

overall

N (%)

25 (25.00%)

\<=60

overall

N (%)

25 (25.00%)

overall

Male

N (%)

13 (13.00%)

Female

N (%)

12 (12.00%)

\<=60

Male

N (%)

13 (13.00%)

Female

N (%)

12 (12.00%)

2014-09-01 to 2014-09-30

overall

overall

N (%)

24 (24.00%)

\<=60

overall

N (%)

24 (24.00%)

overall

Male

N (%)

13 (13.00%)

Female

N (%)

11 (11.00%)

\<=60

Male

N (%)

13 (13.00%)

Female

N (%)

11 (11.00%)

2014-10-01 to 2014-10-31

overall

overall

N (%)

24 (24.00%)

\<=60

overall

N (%)

24 (24.00%)

overall

Male

N (%)

13 (13.00%)

Female

N (%)

11 (11.00%)

\<=60

Male

N (%)

13 (13.00%)

Female

N (%)

11 (11.00%)

2014-11-01 to 2014-11-30

overall

overall

N (%)

24 (24.00%)

\<=60

overall

N (%)

24 (24.00%)

overall

Male

N (%)

13 (13.00%)

Female

N (%)

11 (11.00%)

\<=60

Male

N (%)

13 (13.00%)

Female

N (%)

11 (11.00%)

2014-12-01 to 2014-12-31

overall

overall

N (%)

24 (24.00%)

\<=60

overall

N (%)

24 (24.00%)

overall

Male

N (%)

13 (13.00%)

Female

N (%)

11 (11.00%)

\<=60

Male

N (%)

13 (13.00%)

Female

N (%)

11 (11.00%)

2015-01-01 to 2015-01-31

overall

overall

N (%)

24 (24.00%)

\<=60

overall

N (%)

24 (24.00%)

overall

Male

N (%)

13 (13.00%)

Female

N (%)

11 (11.00%)

\<=60

Male

N (%)

13 (13.00%)

Female

N (%)

11 (11.00%)

2015-02-01 to 2015-02-28

overall

overall

N (%)

24 (24.00%)

\<=60

overall

N (%)

24 (24.00%)

overall

Male

N (%)

13 (13.00%)

Female

N (%)

11 (11.00%)

\<=60

Male

N (%)

13 (13.00%)

Female

N (%)

11 (11.00%)

2015-03-01 to 2015-03-31

overall

overall

N (%)

24 (24.00%)

\<=60

overall

N (%)

24 (24.00%)

overall

Male

N (%)

13 (13.00%)

Female

N (%)

11 (11.00%)

\<=60

Male

N (%)

13 (13.00%)

Female

N (%)

11 (11.00%)

2015-04-01 to 2015-04-30

overall

overall

N (%)

24 (24.00%)

\<=60

overall

N (%)

24 (24.00%)

overall

Male

N (%)

13 (13.00%)

Female

N (%)

11 (11.00%)

\<=60

Male

N (%)

13 (13.00%)

Female

N (%)

11 (11.00%)

2015-05-01 to 2015-05-31

overall

overall

N (%)

24 (24.00%)

\<=60

overall

N (%)

24 (24.00%)

overall

Male

N (%)

13 (13.00%)

Female

N (%)

11 (11.00%)

\<=60

Male

N (%)

13 (13.00%)

Female

N (%)

11 (11.00%)

2015-06-01 to 2015-06-30

overall

overall

N (%)

23 (23.00%)

\<=60

overall

N (%)

23 (23.00%)

overall

Male

N (%)

13 (13.00%)

Female

N (%)

10 (10.00%)

\<=60

Male

N (%)

13 (13.00%)

Female

N (%)

10 (10.00%)

2015-07-01 to 2015-07-31

overall

overall

N (%)

23 (23.00%)

\<=60

overall

N (%)

23 (23.00%)

overall

Male

N (%)

13 (13.00%)

Female

N (%)

10 (10.00%)

\<=60

Male

N (%)

13 (13.00%)

Female

N (%)

10 (10.00%)

2015-08-01 to 2015-08-31

overall

overall

N (%)

23 (23.00%)

\<=60

overall

N (%)

23 (23.00%)

overall

Male

N (%)

13 (13.00%)

Female

N (%)

10 (10.00%)

\<=60

Male

N (%)

13 (13.00%)

Female

N (%)

10 (10.00%)

2015-09-01 to 2015-09-30

overall

overall

N (%)

22 (22.00%)

\<=60

overall

N (%)

22 (22.00%)

overall

Male

N (%)

13 (13.00%)

Female

N (%)

9 (9.00%)

\<=60

Male

N (%)

13 (13.00%)

Female

N (%)

9 (9.00%)

2015-10-01 to 2015-10-31

overall

overall

N (%)

22 (22.00%)

\<=60

overall

N (%)

22 (22.00%)

overall

Male

N (%)

13 (13.00%)

Female

N (%)

9 (9.00%)

\<=60

Male

N (%)

13 (13.00%)

Female

N (%)

9 (9.00%)

2015-11-01 to 2015-11-30

overall

overall

N (%)

22 (22.00%)

\<=60

overall

N (%)

22 (22.00%)

overall

Male

N (%)

13 (13.00%)

Female

N (%)

9 (9.00%)

\<=60

Male

N (%)

13 (13.00%)

Female

N (%)

9 (9.00%)

2015-12-01 to 2015-12-31

overall

overall

N (%)

23 (23.00%)

\<=60

overall

N (%)

23 (23.00%)

overall

Male

N (%)

13 (13.00%)

Female

N (%)

10 (10.00%)

\<=60

Male

N (%)

13 (13.00%)

Female

N (%)

10 (10.00%)

2016-01-01 to 2016-01-31

overall

overall

N (%)

22 (22.00%)

\<=60

overall

N (%)

22 (22.00%)

overall

Male

N (%)

12 (12.00%)

Female

N (%)

10 (10.00%)

\<=60

Male

N (%)

12 (12.00%)

Female

N (%)

10 (10.00%)

2016-02-01 to 2016-02-29

overall

overall

N (%)

22 (22.00%)

\>60

overall

N (%)

1 (1.00%)

\<=60

overall

N (%)

21 (21.00%)

overall

Male

N (%)

12 (12.00%)

Female

N (%)

10 (10.00%)

\<=60

Male

N (%)

12 (12.00%)

Female

N (%)

9 (9.00%)

\>60

Female

N (%)

1 (1.00%)

2016-03-01 to 2016-03-31

overall

overall

N (%)

22 (22.00%)

\>60

overall

N (%)

1 (1.00%)

\<=60

overall

N (%)

21 (21.00%)

overall

Male

N (%)

10 (10.00%)

Female

N (%)

12 (12.00%)

\<=60

Male

N (%)

10 (10.00%)

Female

N (%)

11 (11.00%)

\>60

Female

N (%)

1 (1.00%)

2016-04-01 to 2016-04-30

overall

overall

N (%)

22 (22.00%)

\>60

overall

N (%)

1 (1.00%)

\<=60

overall

N (%)

21 (21.00%)

overall

Male

N (%)

10 (10.00%)

Female

N (%)

12 (12.00%)

\<=60

Male

N (%)

10 (10.00%)

Female

N (%)

11 (11.00%)

\>60

Female

N (%)

1 (1.00%)

2016-05-01 to 2016-05-31

overall

overall

N (%)

23 (23.00%)

\>60

overall

N (%)

1 (1.00%)

\<=60

overall

N (%)

22 (22.00%)

overall

Male

N (%)

10 (10.00%)

Female

N (%)

13 (13.00%)

\>60

Female

N (%)

1 (1.00%)

\<=60

Male

N (%)

10 (10.00%)

Female

N (%)

12 (12.00%)

2016-06-01 to 2016-06-30

overall

overall

N (%)

22 (22.00%)

\<=60

overall

N (%)

21 (21.00%)

\>60

overall

N (%)

1 (1.00%)

overall

Male

N (%)

9 (9.00%)

Female

N (%)

13 (13.00%)

\<=60

Male

N (%)

9 (9.00%)

Female

N (%)

12 (12.00%)

\>60

Female

N (%)

1 (1.00%)

2016-07-01 to 2016-07-31

overall

overall

N (%)

22 (22.00%)

\>60

overall

N (%)

1 (1.00%)

\<=60

overall

N (%)

21 (21.00%)

overall

Male

N (%)

8 (8.00%)

Female

N (%)

14 (14.00%)

\<=60

Male

N (%)

8 (8.00%)

Female

N (%)

13 (13.00%)

\>60

Female

N (%)

1 (1.00%)

2016-08-01 to 2016-08-31

overall

overall

N (%)

23 (23.00%)

\<=60

overall

N (%)

22 (22.00%)

\>60

overall

N (%)

1 (1.00%)

overall

Male

N (%)

8 (8.00%)

Female

N (%)

15 (15.00%)

\>60

Female

N (%)

1 (1.00%)

\<=60

Male

N (%)

8 (8.00%)

Female

N (%)

14 (14.00%)

2016-09-01 to 2016-09-30

overall

overall

N (%)

23 (23.00%)

\<=60

overall

N (%)

22 (22.00%)

\>60

overall

N (%)

1 (1.00%)

overall

Male

N (%)

8 (8.00%)

Female

N (%)

15 (15.00%)

\<=60

Male

N (%)

8 (8.00%)

Female

N (%)

14 (14.00%)

\>60

Female

N (%)

1 (1.00%)

2016-10-01 to 2016-10-31

overall

overall

N (%)

23 (23.00%)

\<=60

overall

N (%)

22 (22.00%)

\>60

overall

N (%)

1 (1.00%)

overall

Male

N (%)

8 (8.00%)

Female

N (%)

15 (15.00%)

\<=60

Male

N (%)

8 (8.00%)

Female

N (%)

14 (14.00%)

\>60

Female

N (%)

1 (1.00%)

2016-11-01 to 2016-11-30

overall

overall

N (%)

24 (24.00%)

\>60

overall

N (%)

1 (1.00%)

\<=60

overall

N (%)

23 (23.00%)

overall

Male

N (%)

9 (9.00%)

Female

N (%)

15 (15.00%)

\<=60

Male

N (%)

9 (9.00%)

Female

N (%)

14 (14.00%)

\>60

Female

N (%)

1 (1.00%)

2016-12-01 to 2016-12-31

overall

overall

N (%)

24 (24.00%)

\>60

overall

N (%)

1 (1.00%)

\<=60

overall

N (%)

23 (23.00%)

overall

Male

N (%)

9 (9.00%)

Female

N (%)

15 (15.00%)

\>60

Female

N (%)

1 (1.00%)

\<=60

Male

N (%)

9 (9.00%)

Female

N (%)

14 (14.00%)

2017-01-01 to 2017-01-31

overall

overall

N (%)

24 (24.00%)

\<=60

overall

N (%)

23 (23.00%)

\>60

overall

N (%)

1 (1.00%)

overall

Male

N (%)

9 (9.00%)

Female

N (%)

15 (15.00%)

\>60

Female

N (%)

1 (1.00%)

\<=60

Male

N (%)

9 (9.00%)

Female

N (%)

14 (14.00%)

2017-02-01 to 2017-02-28

overall

overall

N (%)

24 (24.00%)

\>60

overall

N (%)

1 (1.00%)

\<=60

overall

N (%)

23 (23.00%)

overall

Male

N (%)

9 (9.00%)

Female

N (%)

15 (15.00%)

\<=60

Male

N (%)

9 (9.00%)

Female

N (%)

14 (14.00%)

\>60

Female

N (%)

1 (1.00%)

2017-03-01 to 2017-03-31

overall

overall

N (%)

25 (25.00%)

\<=60

overall

N (%)

24 (24.00%)

\>60

overall

N (%)

1 (1.00%)

overall

Male

N (%)

9 (9.00%)

Female

N (%)

16 (16.00%)

\>60

Female

N (%)

1 (1.00%)

\<=60

Male

N (%)

9 (9.00%)

Female

N (%)

15 (15.00%)

2017-04-01 to 2017-04-30

overall

overall

N (%)

25 (25.00%)

\>60

overall

N (%)

1 (1.00%)

\<=60

overall

N (%)

24 (24.00%)

overall

Male

N (%)

9 (9.00%)

Female

N (%)

16 (16.00%)

\<=60

Male

N (%)

9 (9.00%)

Female

N (%)

15 (15.00%)

\>60

Female

N (%)

1 (1.00%)

2017-05-01 to 2017-05-31

overall

overall

N (%)

25 (25.00%)

\>60

overall

N (%)

1 (1.00%)

\<=60

overall

N (%)

24 (24.00%)

overall

Male

N (%)

9 (9.00%)

Female

N (%)

16 (16.00%)

\>60

Female

N (%)

1 (1.00%)

\<=60

Male

N (%)

9 (9.00%)

Female

N (%)

15 (15.00%)

2017-06-01 to 2017-06-30

overall

overall

N (%)

24 (24.00%)

\<=60

overall

N (%)

23 (23.00%)

\>60

overall

N (%)

1 (1.00%)

overall

Male

N (%)

9 (9.00%)

Female

N (%)

15 (15.00%)

\>60

Female

N (%)

1 (1.00%)

\<=60

Male

N (%)

9 (9.00%)

Female

N (%)

14 (14.00%)

2017-07-01 to 2017-07-31

overall

overall

N (%)

25 (25.00%)

\>60

overall

N (%)

1 (1.00%)

\<=60

overall

N (%)

24 (24.00%)

overall

Male

N (%)

10 (10.00%)

Female

N (%)

15 (15.00%)

\<=60

Male

N (%)

10 (10.00%)

Female

N (%)

14 (14.00%)

\>60

Female

N (%)

1 (1.00%)

2017-08-01 to 2017-08-31

overall

overall

N (%)

23 (23.00%)

\>60

overall

N (%)

1 (1.00%)

\<=60

overall

N (%)

22 (22.00%)

overall

Male

N (%)

10 (10.00%)

Female

N (%)

13 (13.00%)

\<=60

Male

N (%)

10 (10.00%)

Female

N (%)

12 (12.00%)

\>60

Female

N (%)

1 (1.00%)

2017-09-01 to 2017-09-30

overall

overall

N (%)

22 (22.00%)

\>60

overall

N (%)

1 (1.00%)

\<=60

overall

N (%)

21 (21.00%)

overall

Male

N (%)

10 (10.00%)

Female

N (%)

12 (12.00%)

\<=60

Male

N (%)

10 (10.00%)

Female

N (%)

11 (11.00%)

\>60

Female

N (%)

1 (1.00%)

2017-10-01 to 2017-10-31

overall

overall

N (%)

20 (20.00%)

\<=60

overall

N (%)

19 (19.00%)

\>60

overall

N (%)

1 (1.00%)

overall

Male

N (%)

9 (9.00%)

Female

N (%)

11 (11.00%)

\>60

Female

N (%)

1 (1.00%)

\<=60

Male

N (%)

9 (9.00%)

Female

N (%)

10 (10.00%)

2017-11-01 to 2017-11-30

overall

overall

N (%)

20 (20.00%)

\>60

overall

N (%)

1 (1.00%)

\<=60

overall

N (%)

19 (19.00%)

overall

Male

N (%)

9 (9.00%)

Female

N (%)

11 (11.00%)

\>60

Female

N (%)

1 (1.00%)

\<=60

Male

N (%)

9 (9.00%)

Female

N (%)

10 (10.00%)

2017-12-01 to 2017-12-31

overall

overall

N (%)

20 (20.00%)

\>60

overall

N (%)

1 (1.00%)

\<=60

overall

N (%)

19 (19.00%)

overall

Male

N (%)

9 (9.00%)

Female

N (%)

11 (11.00%)

\>60

Female

N (%)

1 (1.00%)

\<=60

Male

N (%)

9 (9.00%)

Female

N (%)

10 (10.00%)

2018-01-01 to 2018-01-31

overall

overall

N (%)

19 (19.00%)

\<=60

overall

N (%)

17 (17.00%)

\>60

overall

N (%)

2 (2.00%)

overall

Male

N (%)

9 (9.00%)

Female

N (%)

10 (10.00%)

\>60

Female

N (%)

2 (2.00%)

\<=60

Male

N (%)

9 (9.00%)

Female

N (%)

8 (8.00%)

2018-02-01 to 2018-02-28

overall

overall

N (%)

16 (16.00%)

\<=60

overall

N (%)

14 (14.00%)

\>60

overall

N (%)

2 (2.00%)

overall

Male

N (%)

7 (7.00%)

Female

N (%)

9 (9.00%)

\<=60

Male

N (%)

7 (7.00%)

Female

N (%)

7 (7.00%)

\>60

Female

N (%)

2 (2.00%)

2018-03-01 to 2018-03-31

overall

overall

N (%)

16 (16.00%)

\<=60

overall

N (%)

14 (14.00%)

\>60

overall

N (%)

2 (2.00%)

overall

Male

N (%)

7 (7.00%)

Female

N (%)

9 (9.00%)

\<=60

Male

N (%)

7 (7.00%)

Female

N (%)

7 (7.00%)

\>60

Female

N (%)

2 (2.00%)

2018-04-01 to 2018-04-30

overall

overall

N (%)

16 (16.00%)

\>60

overall

N (%)

2 (2.00%)

\<=60

overall

N (%)

14 (14.00%)

overall

Male

N (%)

7 (7.00%)

Female

N (%)

9 (9.00%)

\<=60

Male

N (%)

7 (7.00%)

Female

N (%)

7 (7.00%)

\>60

Female

N (%)

2 (2.00%)

2018-05-01 to 2018-05-31

overall

overall

N (%)

16 (16.00%)

\>60

overall

N (%)

2 (2.00%)

\<=60

overall

N (%)

14 (14.00%)

overall

Male

N (%)

7 (7.00%)

Female

N (%)

9 (9.00%)

\<=60

Male

N (%)

7 (7.00%)

Female

N (%)

7 (7.00%)

\>60

Female

N (%)

2 (2.00%)

2018-06-01 to 2018-06-30

overall

overall

N (%)

17 (17.00%)

\<=60

overall

N (%)

15 (15.00%)

\>60

overall

N (%)

2 (2.00%)

overall

Male

N (%)

7 (7.00%)

Female

N (%)

10 (10.00%)

\<=60

Male

N (%)

7 (7.00%)

Female

N (%)

8 (8.00%)

\>60

Female

N (%)

2 (2.00%)

2018-07-01 to 2018-07-31

overall

overall

N (%)

15 (15.00%)

\>60

overall

N (%)

2 (2.00%)

\<=60

overall

N (%)

13 (13.00%)

overall

Male

N (%)

5 (5.00%)

Female

N (%)

10 (10.00%)

\<=60

Male

N (%)

5 (5.00%)

Female

N (%)

8 (8.00%)

\>60

Female

N (%)

2 (2.00%)

2018-08-01 to 2018-08-31

overall

overall

N (%)

14 (14.00%)

\<=60

overall

N (%)

12 (12.00%)

\>60

overall

N (%)

2 (2.00%)

overall

Male

N (%)

5 (5.00%)

Female

N (%)

9 (9.00%)

\<=60

Male

N (%)

5 (5.00%)

Female

N (%)

7 (7.00%)

\>60

Female

N (%)

2 (2.00%)

2018-09-01 to 2018-09-30

overall

overall

N (%)

13 (13.00%)

\>60

overall

N (%)

2 (2.00%)

\<=60

overall

N (%)

11 (11.00%)

overall

Male

N (%)

5 (5.00%)

Female

N (%)

8 (8.00%)

\<=60

Male

N (%)

5 (5.00%)

Female

N (%)

6 (6.00%)

\>60

Female

N (%)

2 (2.00%)

2018-10-01 to 2018-10-31

overall

overall

N (%)

12 (12.00%)

\>60

overall

N (%)

2 (2.00%)

\<=60

overall

N (%)

10 (10.00%)

overall

Male

N (%)

5 (5.00%)

Female

N (%)

7 (7.00%)

\>60

Female

N (%)

2 (2.00%)

\<=60

Male

N (%)

5 (5.00%)

Female

N (%)

5 (5.00%)

2018-11-01 to 2018-11-30

overall

overall

N (%)

12 (12.00%)

\<=60

overall

N (%)

10 (10.00%)

\>60

overall

N (%)

2 (2.00%)

overall

Male

N (%)

5 (5.00%)

Female

N (%)

7 (7.00%)

\>60

Female

N (%)

2 (2.00%)

\<=60

Male

N (%)

5 (5.00%)

Female

N (%)

5 (5.00%)

2018-12-01 to 2018-12-31

overall

overall

N (%)

9 (9.00%)

\>60

overall

N (%)

2 (2.00%)

\<=60

overall

N (%)

7 (7.00%)

overall

Female

N (%)

6 (6.00%)

Male

N (%)

3 (3.00%)

\<=60

Female

N (%)

4 (4.00%)

Male

N (%)

3 (3.00%)

\>60

Female

N (%)

2 (2.00%)

2019-01-01 to 2019-01-31

overall

overall

N (%)

10 (10.00%)

\<=60

overall

N (%)

8 (8.00%)

\>60

overall

N (%)

2 (2.00%)

overall

Female

N (%)

7 (7.00%)

Male

N (%)

3 (3.00%)

\>60

Female

N (%)

2 (2.00%)

\<=60

Female

N (%)

5 (5.00%)

Male

N (%)

3 (3.00%)

2019-02-01 to 2019-02-28

overall

overall

N (%)

6 (6.00%)

\<=60

overall

N (%)

4 (4.00%)

\>60

overall

N (%)

2 (2.00%)

overall

Female

N (%)

6 (6.00%)

\>60

Female

N (%)

2 (2.00%)

\<=60

Female

N (%)

4 (4.00%)

2019-03-01 to 2019-03-31

overall

overall

N (%)

5 (5.00%)

\>60

overall

N (%)

1 (1.00%)

\<=60

overall

N (%)

4 (4.00%)

overall

Female

N (%)

5 (5.00%)

\<=60

Female

N (%)

4 (4.00%)

\>60

Female

N (%)

1 (1.00%)

2019-04-01 to 2019-04-30

overall

overall

N (%)

5 (5.00%)

\>60

overall

N (%)

1 (1.00%)

\<=60

overall

N (%)

4 (4.00%)

overall

Female

N (%)

5 (5.00%)

\>60

Female

N (%)

1 (1.00%)

\<=60

Female

N (%)

4 (4.00%)

2019-05-01 to 2019-05-31

overall

overall

N (%)

5 (5.00%)

\>60

overall

N (%)

1 (1.00%)

\<=60

overall

N (%)

4 (4.00%)

overall

Female

N (%)

5 (5.00%)

\<=60

Female

N (%)

4 (4.00%)

\>60

Female

N (%)

1 (1.00%)

2019-06-01 to 2019-06-30

overall

overall

N (%)

4 (4.00%)

\<=60

overall

N (%)

4 (4.00%)

overall

Female

N (%)

4 (4.00%)

\<=60

Female

N (%)

4 (4.00%)

2019-07-01 to 2019-07-31

overall

overall

N (%)

4 (4.00%)

\<=60

overall

N (%)

4 (4.00%)

overall

Female

N (%)

4 (4.00%)

\<=60

Female

N (%)

4 (4.00%)

2019-08-01 to 2019-08-31

overall

overall

N (%)

3 (3.00%)

\<=60

overall

N (%)

3 (3.00%)

overall

Female

N (%)

3 (3.00%)

\<=60

Female

N (%)

3 (3.00%)

2019-09-01 to 2019-09-30

overall

overall

N (%)

3 (3.00%)

\<=60

overall

N (%)

3 (3.00%)

overall

Female

N (%)

3 (3.00%)

\<=60

Female

N (%)

3 (3.00%)

2019-10-01 to 2019-10-31

overall

overall

N (%)

3 (3.00%)

\<=60

overall

N (%)

3 (3.00%)

overall

Female

N (%)

3 (3.00%)

\<=60

Female

N (%)

3 (3.00%)

2019-11-01 to 2019-11-30

overall

overall

N (%)

2 (2.00%)

\<=60

overall

N (%)

2 (2.00%)

overall

Female

N (%)

2 (2.00%)

\<=60

Female

N (%)

2 (2.00%)

2019-12-01 to 2019-12-31

overall

overall

N (%)

1 (1.00%)

\<=60

overall

N (%)

1 (1.00%)

overall

Female

N (%)

1 (1.00%)

\<=60

Female

N (%)

1 (1.00%)

overall

overall

overall

N (%)

100 (100.00%)

\<=60

overall

N (%)

100 (100.00%)

overall

Male

N (%)

48 (48.00%)

Female

N (%)

52 (52.00%)

\<=60

Male

N (%)

48 (48.00%)

Female

N (%)

52 (52.00%)

Person-days

1954-08-01 to 1954-08-31

overall

overall

N (%)

21 (0.00%)

\<=60

overall

N (%)

21 (0.00%)

overall

Male

N (%)

21 (0.00%)

\<=60

Male

N (%)

21 (0.00%)

1954-09-01 to 1954-09-30

overall

overall

N (%)

30 (0.01%)

\<=60

overall

N (%)

30 (0.01%)

overall

Male

N (%)

30 (0.01%)

\<=60

Male

N (%)

30 (0.01%)

1954-10-01 to 1954-10-31

overall

overall

N (%)

31 (0.01%)

\<=60

overall

N (%)

31 (0.01%)

overall

Male

N (%)

31 (0.01%)

\<=60

Male

N (%)

31 (0.01%)

1954-11-01 to 1954-11-30

overall

overall

N (%)

30 (0.01%)

\<=60

overall

N (%)

30 (0.01%)

overall

Male

N (%)

30 (0.01%)

\<=60

Male

N (%)

30 (0.01%)

1954-12-01 to 1954-12-31

overall

overall

N (%)

31 (0.01%)

\<=60

overall

N (%)

31 (0.01%)

overall

Male

N (%)

31 (0.01%)

\<=60

Male

N (%)

31 (0.01%)

1955-01-01 to 1955-01-31

overall

overall

N (%)

31 (0.01%)

\<=60

overall

N (%)

31 (0.01%)

overall

Male

N (%)

31 (0.01%)

\<=60

Male

N (%)

31 (0.01%)

1955-02-01 to 1955-02-28

overall

overall

N (%)

28 (0.01%)

\<=60

overall

N (%)

28 (0.01%)

overall

Male

N (%)

28 (0.01%)

\<=60

Male

N (%)

28 (0.01%)

1955-03-01 to 1955-03-31

overall

overall

N (%)

31 (0.01%)

\<=60

overall

N (%)

31 (0.01%)

overall

Male

N (%)

31 (0.01%)

\<=60

Male

N (%)

31 (0.01%)

1955-04-01 to 1955-04-30

overall

overall

N (%)

30 (0.01%)

\<=60

overall

N (%)

30 (0.01%)

overall

Male

N (%)

30 (0.01%)

\<=60

Male

N (%)

30 (0.01%)

1955-05-01 to 1955-05-31

overall

overall

N (%)

31 (0.01%)

\<=60

overall

N (%)

31 (0.01%)

overall

Male

N (%)

31 (0.01%)

\<=60

Male

N (%)

31 (0.01%)

1955-06-01 to 1955-06-30

overall

overall

N (%)

30 (0.01%)

\<=60

overall

N (%)

30 (0.01%)

overall

Male

N (%)

30 (0.01%)

\<=60

Male

N (%)

30 (0.01%)

1955-07-01 to 1955-07-31

overall

overall

N (%)

31 (0.01%)

\<=60

overall

N (%)

31 (0.01%)

overall

Male

N (%)

31 (0.01%)

\<=60

Male

N (%)

31 (0.01%)

1955-08-01 to 1955-08-31

overall

overall

N (%)

31 (0.01%)

\<=60

overall

N (%)

31 (0.01%)

overall

Male

N (%)

31 (0.01%)

\<=60

Male

N (%)

31 (0.01%)

1955-09-01 to 1955-09-30

overall

overall

N (%)

30 (0.01%)

\<=60

overall

N (%)

30 (0.01%)

overall

Male

N (%)

30 (0.01%)

\<=60

Male

N (%)

30 (0.01%)

1955-10-01 to 1955-10-31

overall

overall

N (%)

31 (0.01%)

\<=60

overall

N (%)

31 (0.01%)

overall

Male

N (%)

31 (0.01%)

\<=60

Male

N (%)

31 (0.01%)

1955-11-01 to 1955-11-30

overall

overall

N (%)

30 (0.01%)

\<=60

overall

N (%)

30 (0.01%)

overall

Male

N (%)

30 (0.01%)

\<=60

Male

N (%)

30 (0.01%)

1955-12-01 to 1955-12-31

overall

overall

N (%)

31 (0.01%)

\<=60

overall

N (%)

31 (0.01%)

overall

Male

N (%)

31 (0.01%)

\<=60

Male

N (%)

31 (0.01%)

1956-01-01 to 1956-01-31

overall

overall

N (%)

31 (0.01%)

\<=60

overall

N (%)

31 (0.01%)

overall

Male

N (%)

31 (0.01%)

\<=60

Male

N (%)

31 (0.01%)

1956-02-01 to 1956-02-29

overall

overall

N (%)

29 (0.01%)

\<=60

overall

N (%)

29 (0.01%)

overall

Male

N (%)

29 (0.01%)

\<=60

Male

N (%)

29 (0.01%)

1956-03-01 to 1956-03-31

overall

overall

N (%)

31 (0.01%)

\<=60

overall

N (%)

31 (0.01%)

overall

Male

N (%)

31 (0.01%)

\<=60

Male

N (%)

31 (0.01%)

1956-04-01 to 1956-04-30

overall

overall

N (%)

30 (0.01%)

\<=60

overall

N (%)

30 (0.01%)

overall

Male

N (%)

30 (0.01%)

\<=60

Male

N (%)

30 (0.01%)

1956-05-01 to 1956-05-31

overall

overall

N (%)

31 (0.01%)

\<=60

overall

N (%)

31 (0.01%)

overall

Male

N (%)

31 (0.01%)

\<=60

Male

N (%)

31 (0.01%)

1956-06-01 to 1956-06-30

overall

overall

N (%)

30 (0.01%)

\<=60

overall

N (%)

30 (0.01%)

overall

Male

N (%)

30 (0.01%)

\<=60

Male

N (%)

30 (0.01%)

1956-07-01 to 1956-07-31

overall

overall

N (%)

31 (0.01%)

\<=60

overall

N (%)

31 (0.01%)

overall

Male

N (%)

31 (0.01%)

\<=60

Male

N (%)

31 (0.01%)

1956-08-01 to 1956-08-31

overall

overall

N (%)

31 (0.01%)

\<=60

overall

N (%)

31 (0.01%)

overall

Male

N (%)

31 (0.01%)

\<=60

Male

N (%)

31 (0.01%)

1956-09-01 to 1956-09-30

overall

overall

N (%)

45 (0.01%)

\<=60

overall

N (%)

45 (0.01%)

overall

Male

N (%)

45 (0.01%)

\<=60

Male

N (%)

45 (0.01%)

1956-10-01 to 1956-10-31

overall

overall

N (%)

62 (0.01%)

\<=60

overall

N (%)

62 (0.01%)

overall

Male

N (%)

62 (0.01%)

\<=60

Male

N (%)

62 (0.01%)

1956-11-01 to 1956-11-30

overall

overall

N (%)

60 (0.01%)

\<=60

overall

N (%)

60 (0.01%)

overall

Male

N (%)

60 (0.01%)

\<=60

Male

N (%)

60 (0.01%)

1956-12-01 to 1956-12-31

overall

overall

N (%)

62 (0.01%)

\<=60

overall

N (%)

62 (0.01%)

overall

Male

N (%)

62 (0.01%)

\<=60

Male

N (%)

62 (0.01%)

1957-01-01 to 1957-01-31

overall

overall

N (%)

62 (0.01%)

\<=60

overall

N (%)

62 (0.01%)

overall

Male

N (%)

62 (0.01%)

\<=60

Male

N (%)

62 (0.01%)

1957-02-01 to 1957-02-28

overall

overall

N (%)

56 (0.01%)

\<=60

overall

N (%)

56 (0.01%)

overall

Male

N (%)

56 (0.01%)

\<=60

Male

N (%)

56 (0.01%)

1957-03-01 to 1957-03-31

overall

overall

N (%)

62 (0.01%)

\<=60

overall

N (%)

62 (0.01%)

overall

Male

N (%)

62 (0.01%)

\<=60

Male

N (%)

62 (0.01%)

1957-04-01 to 1957-04-30

overall

overall

N (%)

60 (0.01%)

\<=60

overall

N (%)

60 (0.01%)

overall

Male

N (%)

60 (0.01%)

\<=60

Male

N (%)

60 (0.01%)

1957-05-01 to 1957-05-31

overall

overall

N (%)

62 (0.01%)

\<=60

overall

N (%)

62 (0.01%)

overall

Male

N (%)

62 (0.01%)

\<=60

Male

N (%)

62 (0.01%)

1957-06-01 to 1957-06-30

overall

overall

N (%)

60 (0.01%)

\<=60

overall

N (%)

60 (0.01%)

overall

Male

N (%)

60 (0.01%)

\<=60

Male

N (%)

60 (0.01%)

1957-07-01 to 1957-07-31

overall

overall

N (%)

62 (0.01%)

\<=60

overall

N (%)

62 (0.01%)

overall

Male

N (%)

62 (0.01%)

\<=60

Male

N (%)

62 (0.01%)

1957-08-01 to 1957-08-31

overall

overall

N (%)

62 (0.01%)

\<=60

overall

N (%)

62 (0.01%)

overall

Male

N (%)

62 (0.01%)

\<=60

Male

N (%)

62 (0.01%)

1957-09-01 to 1957-09-30

overall

overall

N (%)

60 (0.01%)

\<=60

overall

N (%)

60 (0.01%)

overall

Male

N (%)

60 (0.01%)

\<=60

Male

N (%)

60 (0.01%)

1957-10-01 to 1957-10-31

overall

overall

N (%)

62 (0.01%)

\<=60

overall

N (%)

62 (0.01%)

overall

Male

N (%)

62 (0.01%)

\<=60

Male

N (%)

62 (0.01%)

1957-11-01 to 1957-11-30

overall

overall

N (%)

60 (0.01%)

\<=60

overall

N (%)

60 (0.01%)

overall

Male

N (%)

60 (0.01%)

\<=60

Male

N (%)

60 (0.01%)

1957-12-01 to 1957-12-31

overall

overall

N (%)

62 (0.01%)

\<=60

overall

N (%)

62 (0.01%)

overall

Male

N (%)

62 (0.01%)

\<=60

Male

N (%)

62 (0.01%)

1958-01-01 to 1958-01-31

overall

overall

N (%)

62 (0.01%)

\<=60

overall

N (%)

62 (0.01%)

overall

Male

N (%)

62 (0.01%)

\<=60

Male

N (%)

62 (0.01%)

1958-02-01 to 1958-02-28

overall

overall

N (%)

56 (0.01%)

\<=60

overall

N (%)

56 (0.01%)

overall

Male

N (%)

56 (0.01%)

\<=60

Male

N (%)

56 (0.01%)

1958-03-01 to 1958-03-31

overall

overall

N (%)

62 (0.01%)

\<=60

overall

N (%)

62 (0.01%)

overall

Male

N (%)

62 (0.01%)

\<=60

Male

N (%)

62 (0.01%)

1958-04-01 to 1958-04-30

overall

overall

N (%)

60 (0.01%)

\<=60

overall

N (%)

60 (0.01%)

overall

Male

N (%)

60 (0.01%)

\<=60

Male

N (%)

60 (0.01%)

1958-05-01 to 1958-05-31

overall

overall

N (%)

62 (0.01%)

\<=60

overall

N (%)

62 (0.01%)

overall

Male

N (%)

62 (0.01%)

\<=60

Male

N (%)

62 (0.01%)

1958-06-01 to 1958-06-30

overall

overall

N (%)

60 (0.01%)

\<=60

overall

N (%)

60 (0.01%)

overall

Male

N (%)

60 (0.01%)

\<=60

Male

N (%)

60 (0.01%)

1958-07-01 to 1958-07-31

overall

overall

N (%)

62 (0.01%)

\<=60

overall

N (%)

62 (0.01%)

overall

Male

N (%)

62 (0.01%)

\<=60

Male

N (%)

62 (0.01%)

1958-08-01 to 1958-08-31

overall

overall

N (%)

62 (0.01%)

\<=60

overall

N (%)

62 (0.01%)

overall

Male

N (%)

62 (0.01%)

\<=60

Male

N (%)

62 (0.01%)

1958-09-01 to 1958-09-30

overall

overall

N (%)

60 (0.01%)

\<=60

overall

N (%)

60 (0.01%)

overall

Male

N (%)

60 (0.01%)

\<=60

Male

N (%)

60 (0.01%)

1958-10-01 to 1958-10-31

overall

overall

N (%)

62 (0.01%)

\<=60

overall

N (%)

62 (0.01%)

overall

Male

N (%)

62 (0.01%)

\<=60

Male

N (%)

62 (0.01%)

1958-11-01 to 1958-11-30

overall

overall

N (%)

60 (0.01%)

\<=60

overall

N (%)

60 (0.01%)

overall

Male

N (%)

60 (0.01%)

\<=60

Male

N (%)

60 (0.01%)

1958-12-01 to 1958-12-31

overall

overall

N (%)

62 (0.01%)

\<=60

overall

N (%)

62 (0.01%)

overall

Male

N (%)

62 (0.01%)

\<=60

Male

N (%)

62 (0.01%)

1959-01-01 to 1959-01-31

overall

overall

N (%)

62 (0.01%)

\<=60

overall

N (%)

62 (0.01%)

overall

Male

N (%)

62 (0.01%)

\<=60

Male

N (%)

62 (0.01%)

1959-02-01 to 1959-02-28

overall

overall

N (%)

56 (0.01%)

\<=60

overall

N (%)

56 (0.01%)

overall

Male

N (%)

56 (0.01%)

\<=60

Male

N (%)

56 (0.01%)

1959-03-01 to 1959-03-31

overall

overall

N (%)

62 (0.01%)

\<=60

overall

N (%)

62 (0.01%)

overall

Male

N (%)

62 (0.01%)

\<=60

Male

N (%)

62 (0.01%)

1959-04-01 to 1959-04-30

overall

overall

N (%)

60 (0.01%)

\<=60

overall

N (%)

60 (0.01%)

overall

Male

N (%)

60 (0.01%)

\<=60

Male

N (%)

60 (0.01%)

1959-05-01 to 1959-05-31

overall

overall

N (%)

62 (0.01%)

\<=60

overall

N (%)

62 (0.01%)

overall

Male

N (%)

62 (0.01%)

\<=60

Male

N (%)

62 (0.01%)

1959-06-01 to 1959-06-30

overall

overall

N (%)

60 (0.01%)

\<=60

overall

N (%)

60 (0.01%)

overall

Male

N (%)

60 (0.01%)

\<=60

Male

N (%)

60 (0.01%)

1959-07-01 to 1959-07-31

overall

overall

N (%)

62 (0.01%)

\<=60

overall

N (%)

62 (0.01%)

overall

Male

N (%)

62 (0.01%)

\<=60

Male

N (%)

62 (0.01%)

1959-08-01 to 1959-08-31

overall

overall

N (%)

62 (0.01%)

\<=60

overall

N (%)

62 (0.01%)

overall

Male

N (%)

62 (0.01%)

\<=60

Male

N (%)

62 (0.01%)

1959-09-01 to 1959-09-30

overall

overall

N (%)

60 (0.01%)

\<=60

overall

N (%)

60 (0.01%)

overall

Male

N (%)

60 (0.01%)

\<=60

Male

N (%)

60 (0.01%)

1959-10-01 to 1959-10-31

overall

overall

N (%)

62 (0.01%)

\<=60

overall

N (%)

62 (0.01%)

overall

Male

N (%)

62 (0.01%)

\<=60

Male

N (%)

62 (0.01%)

1959-11-01 to 1959-11-30

overall

overall

N (%)

60 (0.01%)

\<=60

overall

N (%)

60 (0.01%)

overall

Male

N (%)

60 (0.01%)

\<=60

Male

N (%)

60 (0.01%)

1959-12-01 to 1959-12-31

overall

overall

N (%)

62 (0.01%)

\<=60

overall

N (%)

62 (0.01%)

overall

Male

N (%)

62 (0.01%)

\<=60

Male

N (%)

62 (0.01%)

1960-01-01 to 1960-01-31

overall

overall

N (%)

62 (0.01%)

\<=60

overall

N (%)

62 (0.01%)

overall

Male

N (%)

62 (0.01%)

\<=60

Male

N (%)

62 (0.01%)

1960-02-01 to 1960-02-29

overall

overall

N (%)

58 (0.01%)

\<=60

overall

N (%)

58 (0.01%)

overall

Male

N (%)

58 (0.01%)

\<=60

Male

N (%)

58 (0.01%)

1960-03-01 to 1960-03-31

overall

overall

N (%)

62 (0.01%)

\<=60

overall

N (%)

62 (0.01%)

overall

Male

N (%)

62 (0.01%)

\<=60

Male

N (%)

62 (0.01%)

1960-04-01 to 1960-04-30

overall

overall

N (%)

60 (0.01%)

\<=60

overall

N (%)

60 (0.01%)

overall

Male

N (%)

60 (0.01%)

\<=60

Male

N (%)

60 (0.01%)

1960-05-01 to 1960-05-31

overall

overall

N (%)

62 (0.01%)

\<=60

overall

N (%)

62 (0.01%)

overall

Male

N (%)

62 (0.01%)

\<=60

Male

N (%)

62 (0.01%)

1960-06-01 to 1960-06-30

overall

overall

N (%)

60 (0.01%)

\<=60

overall

N (%)

60 (0.01%)

overall

Male

N (%)

60 (0.01%)

\<=60

Male

N (%)

60 (0.01%)

1960-07-01 to 1960-07-31

overall

overall

N (%)

62 (0.01%)

\<=60

overall

N (%)

62 (0.01%)

overall

Male

N (%)

62 (0.01%)

\<=60

Male

N (%)

62 (0.01%)

1960-08-01 to 1960-08-31

overall

overall

N (%)

62 (0.01%)

\<=60

overall

N (%)

62 (0.01%)

overall

Male

N (%)

62 (0.01%)

\<=60

Male

N (%)

62 (0.01%)

1960-09-01 to 1960-09-30

overall

overall

N (%)

60 (0.01%)

\<=60

overall

N (%)

60 (0.01%)

overall

Male

N (%)

60 (0.01%)

\<=60

Male

N (%)

60 (0.01%)

1960-10-01 to 1960-10-31

overall

overall

N (%)

62 (0.01%)

\<=60

overall

N (%)

62 (0.01%)

overall

Male

N (%)

62 (0.01%)

\<=60

Male

N (%)

62 (0.01%)

1960-11-01 to 1960-11-30

overall

overall

N (%)

60 (0.01%)

\<=60

overall

N (%)

60 (0.01%)

overall

Male

N (%)

60 (0.01%)

\<=60

Male

N (%)

60 (0.01%)

1960-12-01 to 1960-12-31

overall

overall

N (%)

62 (0.01%)

\<=60

overall

N (%)

62 (0.01%)

overall

Male

N (%)

62 (0.01%)

\<=60

Male

N (%)

62 (0.01%)

1961-01-01 to 1961-01-31

overall

overall

N (%)

62 (0.01%)

\<=60

overall

N (%)

62 (0.01%)

overall

Male

N (%)

62 (0.01%)

\<=60

Male

N (%)

62 (0.01%)

1961-02-01 to 1961-02-28

overall

overall

N (%)

56 (0.01%)

\<=60

overall

N (%)

56 (0.01%)

overall

Male

N (%)

56 (0.01%)

\<=60

Male

N (%)

56 (0.01%)

1961-03-01 to 1961-03-31

overall

overall

N (%)

62 (0.01%)

\<=60

overall

N (%)

62 (0.01%)

overall

Male

N (%)

62 (0.01%)

\<=60

Male

N (%)

62 (0.01%)

1961-04-01 to 1961-04-30

overall

overall

N (%)

60 (0.01%)

\<=60

overall

N (%)

60 (0.01%)

overall

Male

N (%)

60 (0.01%)

\<=60

Male

N (%)

60 (0.01%)

1961-05-01 to 1961-05-31

overall

overall

N (%)

62 (0.01%)

\<=60

overall

N (%)

62 (0.01%)

overall

Male

N (%)

62 (0.01%)

\<=60

Male

N (%)

62 (0.01%)

1961-06-01 to 1961-06-30

overall

overall

N (%)

60 (0.01%)

\<=60

overall

N (%)

60 (0.01%)

overall

Male

N (%)

60 (0.01%)

\<=60

Male

N (%)

60 (0.01%)

1961-07-01 to 1961-07-31

overall

overall

N (%)

62 (0.01%)

\<=60

overall

N (%)

62 (0.01%)

overall

Male

N (%)

62 (0.01%)

\<=60

Male

N (%)

62 (0.01%)

1961-08-01 to 1961-08-31

overall

overall

N (%)

62 (0.01%)

\<=60

overall

N (%)

62 (0.01%)

overall

Male

N (%)

62 (0.01%)

\<=60

Male

N (%)

62 (0.01%)

1961-09-01 to 1961-09-30

overall

overall

N (%)

60 (0.01%)

\<=60

overall

N (%)

60 (0.01%)

overall

Male

N (%)

60 (0.01%)

\<=60

Male

N (%)

60 (0.01%)

1961-10-01 to 1961-10-31

overall

overall

N (%)

62 (0.01%)

\<=60

overall

N (%)

62 (0.01%)

overall

Male

N (%)

62 (0.01%)

\<=60

Male

N (%)

62 (0.01%)

1961-11-01 to 1961-11-30

overall

overall

N (%)

60 (0.01%)

\<=60

overall

N (%)

60 (0.01%)

overall

Male

N (%)

60 (0.01%)

\<=60

Male

N (%)

60 (0.01%)

1961-12-01 to 1961-12-31

overall

overall

N (%)

62 (0.01%)

\<=60

overall

N (%)

62 (0.01%)

overall

Male

N (%)

62 (0.01%)

\<=60

Male

N (%)

62 (0.01%)

1962-01-01 to 1962-01-31

overall

overall

N (%)

62 (0.01%)

\<=60

overall

N (%)

62 (0.01%)

overall

Male

N (%)

62 (0.01%)

\<=60

Male

N (%)

62 (0.01%)

1962-02-01 to 1962-02-28

overall

overall

N (%)

56 (0.01%)

\<=60

overall

N (%)

56 (0.01%)

overall

Male

N (%)

56 (0.01%)

\<=60

Male

N (%)

56 (0.01%)

1962-03-01 to 1962-03-31

overall

overall

N (%)

62 (0.01%)

\<=60

overall

N (%)

62 (0.01%)

overall

Male

N (%)

62 (0.01%)

\<=60

Male

N (%)

62 (0.01%)

1962-04-01 to 1962-04-30

overall

overall

N (%)

60 (0.01%)

\<=60

overall

N (%)

60 (0.01%)

overall

Male

N (%)

60 (0.01%)

\<=60

Male

N (%)

60 (0.01%)

1962-05-01 to 1962-05-31

overall

overall

N (%)

62 (0.01%)

\<=60

overall

N (%)

62 (0.01%)

overall

Male

N (%)

62 (0.01%)

\<=60

Male

N (%)

62 (0.01%)

1962-06-01 to 1962-06-30

overall

overall

N (%)

60 (0.01%)

\<=60

overall

N (%)

60 (0.01%)

overall

Male

N (%)

60 (0.01%)

\<=60

Male

N (%)

60 (0.01%)

1962-07-01 to 1962-07-31

overall

overall

N (%)

62 (0.01%)

\<=60

overall

N (%)

62 (0.01%)

overall

Male

N (%)

62 (0.01%)

\<=60

Male

N (%)

62 (0.01%)

1962-08-01 to 1962-08-31

overall

overall

N (%)

62 (0.01%)

\<=60

overall

N (%)

62 (0.01%)

overall

Male

N (%)

62 (0.01%)

\<=60

Male

N (%)

62 (0.01%)

1962-09-01 to 1962-09-30

overall

overall

N (%)

60 (0.01%)

\<=60

overall

N (%)

60 (0.01%)

overall

Male

N (%)

60 (0.01%)

\<=60

Male

N (%)

60 (0.01%)

1962-10-01 to 1962-10-31

overall

overall

N (%)

62 (0.01%)

\<=60

overall

N (%)

62 (0.01%)

overall

Male

N (%)

62 (0.01%)

\<=60

Male

N (%)

62 (0.01%)

1962-11-01 to 1962-11-30

overall

overall

N (%)

60 (0.01%)

\<=60

overall

N (%)

60 (0.01%)

overall

Male

N (%)

60 (0.01%)

\<=60

Male

N (%)

60 (0.01%)

1962-12-01 to 1962-12-31

overall

overall

N (%)

62 (0.01%)

\<=60

overall

N (%)

62 (0.01%)

overall

Male

N (%)

62 (0.01%)

\<=60

Male

N (%)

62 (0.01%)

1963-01-01 to 1963-01-31

overall

overall

N (%)

62 (0.01%)

\<=60

overall

N (%)

62 (0.01%)

overall

Male

N (%)

62 (0.01%)

\<=60

Male

N (%)

62 (0.01%)

1963-02-01 to 1963-02-28

overall

overall

N (%)

56 (0.01%)

\<=60

overall

N (%)

56 (0.01%)

overall

Male

N (%)

56 (0.01%)

\<=60

Male

N (%)

56 (0.01%)

1963-03-01 to 1963-03-31

overall

overall

N (%)

62 (0.01%)

\<=60

overall

N (%)

62 (0.01%)

overall

Male

N (%)

62 (0.01%)

\<=60

Male

N (%)

62 (0.01%)

1963-04-01 to 1963-04-30

overall

overall

N (%)

60 (0.01%)

\<=60

overall

N (%)

60 (0.01%)

overall

Male

N (%)

60 (0.01%)

\<=60

Male

N (%)

60 (0.01%)

1963-05-01 to 1963-05-31

overall

overall

N (%)

62 (0.01%)

\<=60

overall

N (%)

62 (0.01%)

overall

Male

N (%)

62 (0.01%)

\<=60

Male

N (%)

62 (0.01%)

1963-06-01 to 1963-06-30

overall

overall

N (%)

60 (0.01%)

\<=60

overall

N (%)

60 (0.01%)

overall

Male

N (%)

60 (0.01%)

\<=60

Male

N (%)

60 (0.01%)

1963-07-01 to 1963-07-31

overall

overall

N (%)

62 (0.01%)

\<=60

overall

N (%)

62 (0.01%)

overall

Male

N (%)

62 (0.01%)

\<=60

Male

N (%)

62 (0.01%)

1963-08-01 to 1963-08-31

overall

overall

N (%)

62 (0.01%)

\<=60

overall

N (%)

62 (0.01%)

overall

Male

N (%)

62 (0.01%)

\<=60

Male

N (%)

62 (0.01%)

1963-09-01 to 1963-09-30

overall

overall

N (%)

90 (0.02%)

\<=60

overall

N (%)

90 (0.02%)

overall

Male

N (%)

90 (0.02%)

\<=60

Male

N (%)

90 (0.02%)

1963-10-01 to 1963-10-31

overall

overall

N (%)

93 (0.02%)

\<=60

overall

N (%)

93 (0.02%)

overall

Male

N (%)

93 (0.02%)

\<=60

Male

N (%)

93 (0.02%)

1963-11-01 to 1963-11-30

overall

overall

N (%)

90 (0.02%)

\<=60

overall

N (%)

90 (0.02%)

overall

Male

N (%)

90 (0.02%)

\<=60

Male

N (%)

90 (0.02%)

1963-12-01 to 1963-12-31

overall

overall

N (%)

93 (0.02%)

\<=60

overall

N (%)

93 (0.02%)

overall

Male

N (%)

93 (0.02%)

\<=60

Male

N (%)

93 (0.02%)

1964-01-01 to 1964-01-31

overall

overall

N (%)

93 (0.02%)

\<=60

overall

N (%)

93 (0.02%)

overall

Male

N (%)

93 (0.02%)

\<=60

Male

N (%)

93 (0.02%)

1964-02-01 to 1964-02-29

overall

overall

N (%)

87 (0.02%)

\<=60

overall

N (%)

87 (0.02%)

overall

Male

N (%)

87 (0.02%)

\<=60

Male

N (%)

87 (0.02%)

1964-03-01 to 1964-03-31

overall

overall

N (%)

93 (0.02%)

\<=60

overall

N (%)

93 (0.02%)

overall

Male

N (%)

93 (0.02%)

\<=60

Male

N (%)

93 (0.02%)

1964-04-01 to 1964-04-30

overall

overall

N (%)

90 (0.02%)

\<=60

overall

N (%)

90 (0.02%)

overall

Male

N (%)

90 (0.02%)

\<=60

Male

N (%)

90 (0.02%)

1964-05-01 to 1964-05-31

overall

overall

N (%)

93 (0.02%)

\<=60

overall

N (%)

93 (0.02%)

overall

Male

N (%)

93 (0.02%)

\<=60

Male

N (%)

93 (0.02%)

1964-06-01 to 1964-06-30

overall

overall

N (%)

90 (0.02%)

\<=60

overall

N (%)

90 (0.02%)

overall

Male

N (%)

90 (0.02%)

\<=60

Male

N (%)

90 (0.02%)

1964-07-01 to 1964-07-31

overall

overall

N (%)

104 (0.02%)

\<=60

overall

N (%)

104 (0.02%)

overall

Male

N (%)

104 (0.02%)

\<=60

Male

N (%)

104 (0.02%)

1964-08-01 to 1964-08-31

overall

overall

N (%)

124 (0.03%)

\<=60

overall

N (%)

124 (0.03%)

overall

Male

N (%)

124 (0.03%)

\<=60

Male

N (%)

124 (0.03%)

1964-09-01 to 1964-09-30

overall

overall

N (%)

120 (0.02%)

\<=60

overall

N (%)

120 (0.02%)

overall

Male

N (%)

120 (0.02%)

\<=60

Male

N (%)

120 (0.02%)

1964-10-01 to 1964-10-31

overall

overall

N (%)

124 (0.03%)

\<=60

overall

N (%)

124 (0.03%)

overall

Male

N (%)

124 (0.03%)

\<=60

Male

N (%)

124 (0.03%)

1964-11-01 to 1964-11-30

overall

overall

N (%)

120 (0.02%)

\<=60

overall

N (%)

120 (0.02%)

overall

Male

N (%)

120 (0.02%)

\<=60

Male

N (%)

120 (0.02%)

1964-12-01 to 1964-12-31

overall

overall

N (%)

124 (0.03%)

\<=60

overall

N (%)

124 (0.03%)

overall

Male

N (%)

124 (0.03%)

\<=60

Male

N (%)

124 (0.03%)

1965-01-01 to 1965-01-31

overall

overall

N (%)

124 (0.03%)

\<=60

overall

N (%)

124 (0.03%)

overall

Male

N (%)

124 (0.03%)

\<=60

Male

N (%)

124 (0.03%)

1965-02-01 to 1965-02-28

overall

overall

N (%)

112 (0.02%)

\<=60

overall

N (%)

112 (0.02%)

overall

Male

N (%)

112 (0.02%)

\<=60

Male

N (%)

112 (0.02%)

1965-03-01 to 1965-03-31

overall

overall

N (%)

124 (0.03%)

\<=60

overall

N (%)

124 (0.03%)

overall

Male

N (%)

124 (0.03%)

\<=60

Male

N (%)

124 (0.03%)

1965-04-01 to 1965-04-30

overall

overall

N (%)

120 (0.02%)

\<=60

overall

N (%)

120 (0.02%)

overall

Male

N (%)

120 (0.02%)

\<=60

Male

N (%)

120 (0.02%)

1965-05-01 to 1965-05-31

overall

overall

N (%)

124 (0.03%)

\<=60

overall

N (%)

124 (0.03%)

overall

Male

N (%)

124 (0.03%)

\<=60

Male

N (%)

124 (0.03%)

1965-06-01 to 1965-06-30

overall

overall

N (%)

120 (0.02%)

\<=60

overall

N (%)

120 (0.02%)

overall

Male

N (%)

120 (0.02%)

\<=60

Male

N (%)

120 (0.02%)

1965-07-01 to 1965-07-31

overall

overall

N (%)

124 (0.03%)

\<=60

overall

N (%)

124 (0.03%)

overall

Male

N (%)

124 (0.03%)

\<=60

Male

N (%)

124 (0.03%)

1965-08-01 to 1965-08-31

overall

overall

N (%)

124 (0.03%)

\<=60

overall

N (%)

124 (0.03%)

overall

Male

N (%)

124 (0.03%)

\<=60

Male

N (%)

124 (0.03%)

1965-09-01 to 1965-09-30

overall

overall

N (%)

120 (0.02%)

\<=60

overall

N (%)

120 (0.02%)

overall

Male

N (%)

120 (0.02%)

\<=60

Male

N (%)

120 (0.02%)

1965-10-01 to 1965-10-31

overall

overall

N (%)

124 (0.03%)

\<=60

overall

N (%)

124 (0.03%)

overall

Male

N (%)

124 (0.03%)

\<=60

Male

N (%)

124 (0.03%)

1965-11-01 to 1965-11-30

overall

overall

N (%)

120 (0.02%)

\<=60

overall

N (%)

120 (0.02%)

overall

Male

N (%)

120 (0.02%)

\<=60

Male

N (%)

120 (0.02%)

1965-12-01 to 1965-12-31

overall

overall

N (%)

124 (0.03%)

\<=60

overall

N (%)

124 (0.03%)

overall

Male

N (%)

124 (0.03%)

\<=60

Male

N (%)

124 (0.03%)

1966-01-01 to 1966-01-31

overall

overall

N (%)

124 (0.03%)

\<=60

overall

N (%)

124 (0.03%)

overall

Male

N (%)

124 (0.03%)

\<=60

Male

N (%)

124 (0.03%)

1966-02-01 to 1966-02-28

overall

overall

N (%)

136 (0.03%)

\<=60

overall

N (%)

136 (0.03%)

overall

Male

N (%)

112 (0.02%)

Female

N (%)

24 (0.00%)

\<=60

Male

N (%)

112 (0.02%)

Female

N (%)

24 (0.00%)

1966-03-01 to 1966-03-31

overall

overall

N (%)

155 (0.03%)

\<=60

overall

N (%)

155 (0.03%)

overall

Male

N (%)

124 (0.03%)

Female

N (%)

31 (0.01%)

\<=60

Male

N (%)

124 (0.03%)

Female

N (%)

31 (0.01%)

1966-04-01 to 1966-04-30

overall

overall

N (%)

150 (0.03%)

\<=60

overall

N (%)

150 (0.03%)

overall

Male

N (%)

120 (0.02%)

Female

N (%)

30 (0.01%)

\<=60

Male

N (%)

120 (0.02%)

Female

N (%)

30 (0.01%)

1966-05-01 to 1966-05-31

overall

overall

N (%)

155 (0.03%)

\<=60

overall

N (%)

155 (0.03%)

overall

Male

N (%)

124 (0.03%)

Female

N (%)

31 (0.01%)

\<=60

Male

N (%)

124 (0.03%)

Female

N (%)

31 (0.01%)

1966-06-01 to 1966-06-30

overall

overall

N (%)

150 (0.03%)

\<=60

overall

N (%)

150 (0.03%)

overall

Male

N (%)

120 (0.02%)

Female

N (%)

30 (0.01%)

\<=60

Male

N (%)

120 (0.02%)

Female

N (%)

30 (0.01%)

1966-07-01 to 1966-07-31

overall

overall

N (%)

155 (0.03%)

\<=60

overall

N (%)

155 (0.03%)

overall

Male

N (%)

124 (0.03%)

Female

N (%)

31 (0.01%)

\<=60

Male

N (%)

124 (0.03%)

Female

N (%)

31 (0.01%)

1966-08-01 to 1966-08-31

overall

overall

N (%)

155 (0.03%)

\<=60

overall

N (%)

155 (0.03%)

overall

Male

N (%)

124 (0.03%)

Female

N (%)

31 (0.01%)

\<=60

Male

N (%)

124 (0.03%)

Female

N (%)

31 (0.01%)

1966-09-01 to 1966-09-30

overall

overall

N (%)

150 (0.03%)

\<=60

overall

N (%)

150 (0.03%)

overall

Male

N (%)

120 (0.02%)

Female

N (%)

30 (0.01%)

\<=60

Male

N (%)

120 (0.02%)

Female

N (%)

30 (0.01%)

1966-10-01 to 1966-10-31

overall

overall

N (%)

155 (0.03%)

\<=60

overall

N (%)

155 (0.03%)

overall

Male

N (%)

124 (0.03%)

Female

N (%)

31 (0.01%)

\<=60

Male

N (%)

124 (0.03%)

Female

N (%)

31 (0.01%)

1966-11-01 to 1966-11-30

overall

overall

N (%)

150 (0.03%)

\<=60

overall

N (%)

150 (0.03%)

overall

Male

N (%)

120 (0.02%)

Female

N (%)

30 (0.01%)

\<=60

Male

N (%)

120 (0.02%)

Female

N (%)

30 (0.01%)

1966-12-01 to 1966-12-31

overall

overall

N (%)

163 (0.03%)

\<=60

overall

N (%)

163 (0.03%)

overall

Male

N (%)

124 (0.03%)

Female

N (%)

39 (0.01%)

\<=60

Male

N (%)

124 (0.03%)

Female

N (%)

39 (0.01%)

1967-01-01 to 1967-01-31

overall

overall

N (%)

186 (0.04%)

\<=60

overall

N (%)

186 (0.04%)

overall

Male

N (%)

124 (0.03%)

Female

N (%)

62 (0.01%)

\<=60

Male

N (%)

124 (0.03%)

Female

N (%)

62 (0.01%)

1967-02-01 to 1967-02-28

overall

overall

N (%)

168 (0.03%)

\<=60

overall

N (%)

168 (0.03%)

overall

Male

N (%)

112 (0.02%)

Female

N (%)

56 (0.01%)

\<=60

Male

N (%)

112 (0.02%)

Female

N (%)

56 (0.01%)

1967-03-01 to 1967-03-31

overall

overall

N (%)

186 (0.04%)

\<=60

overall

N (%)

186 (0.04%)

overall

Male

N (%)

124 (0.03%)

Female

N (%)

62 (0.01%)

\<=60

Male

N (%)

124 (0.03%)

Female

N (%)

62 (0.01%)

1967-04-01 to 1967-04-30

overall

overall

N (%)

180 (0.04%)

\<=60

overall

N (%)

180 (0.04%)

overall

Male

N (%)

120 (0.02%)

Female

N (%)

60 (0.01%)

\<=60

Male

N (%)

120 (0.02%)

Female

N (%)

60 (0.01%)

1967-05-01 to 1967-05-31

overall

overall

N (%)

186 (0.04%)

\<=60

overall

N (%)

186 (0.04%)

overall

Male

N (%)

124 (0.03%)

Female

N (%)

62 (0.01%)

\<=60

Male

N (%)

124 (0.03%)

Female

N (%)

62 (0.01%)

1967-06-01 to 1967-06-30

overall

overall

N (%)

180 (0.04%)

\<=60

overall

N (%)

180 (0.04%)

overall

Male

N (%)

120 (0.02%)

Female

N (%)

60 (0.01%)

\<=60

Male

N (%)

120 (0.02%)

Female

N (%)

60 (0.01%)

1967-07-01 to 1967-07-31

overall

overall

N (%)

186 (0.04%)

\<=60

overall

N (%)

186 (0.04%)

overall

Male

N (%)

124 (0.03%)

Female

N (%)

62 (0.01%)

\<=60

Male

N (%)

124 (0.03%)

Female

N (%)

62 (0.01%)

1967-08-01 to 1967-08-31

overall

overall

N (%)

186 (0.04%)

\<=60

overall

N (%)

186 (0.04%)

overall

Male

N (%)

124 (0.03%)

Female

N (%)

62 (0.01%)

\<=60

Male

N (%)

124 (0.03%)

Female

N (%)

62 (0.01%)

1967-09-01 to 1967-09-30

overall

overall

N (%)

180 (0.04%)

\<=60

overall

N (%)

180 (0.04%)

overall

Male

N (%)

120 (0.02%)

Female

N (%)

60 (0.01%)

\<=60

Male

N (%)

120 (0.02%)

Female

N (%)

60 (0.01%)

1967-10-01 to 1967-10-31

overall

overall

N (%)

186 (0.04%)

\<=60

overall

N (%)

186 (0.04%)

overall

Male

N (%)

124 (0.03%)

Female

N (%)

62 (0.01%)

\<=60

Male

N (%)

124 (0.03%)

Female

N (%)

62 (0.01%)

1967-11-01 to 1967-11-30

overall

overall

N (%)

180 (0.04%)

\<=60

overall

N (%)

180 (0.04%)

overall

Male

N (%)

120 (0.02%)

Female

N (%)

60 (0.01%)

\<=60

Male

N (%)

120 (0.02%)

Female

N (%)

60 (0.01%)

1967-12-01 to 1967-12-31

overall

overall

N (%)

186 (0.04%)

\<=60

overall

N (%)

186 (0.04%)

overall

Male

N (%)

124 (0.03%)

Female

N (%)

62 (0.01%)

\<=60

Male

N (%)

124 (0.03%)

Female

N (%)

62 (0.01%)

1968-01-01 to 1968-01-31

overall

overall

N (%)

186 (0.04%)

\<=60

overall

N (%)

186 (0.04%)

overall

Male

N (%)

124 (0.03%)

Female

N (%)

62 (0.01%)

\<=60

Male

N (%)

124 (0.03%)

Female

N (%)

62 (0.01%)

1968-02-01 to 1968-02-29

overall

overall

N (%)

203 (0.04%)

\<=60

overall

N (%)

203 (0.04%)

overall

Male

N (%)

145 (0.03%)

Female

N (%)

58 (0.01%)

\<=60

Male

N (%)

145 (0.03%)

Female

N (%)

58 (0.01%)

1968-03-01 to 1968-03-31

overall

overall

N (%)

217 (0.04%)

\<=60

overall

N (%)

217 (0.04%)

overall

Male

N (%)

155 (0.03%)

Female

N (%)

62 (0.01%)

\<=60

Male

N (%)

155 (0.03%)

Female

N (%)

62 (0.01%)

1968-04-01 to 1968-04-30

overall

overall

N (%)

210 (0.04%)

\<=60

overall

N (%)

210 (0.04%)

overall

Male

N (%)

150 (0.03%)

Female

N (%)

60 (0.01%)

\<=60

Male

N (%)

150 (0.03%)

Female

N (%)

60 (0.01%)

1968-05-01 to 1968-05-31

overall

overall

N (%)

217 (0.04%)

\<=60

overall

N (%)

217 (0.04%)

overall

Male

N (%)

155 (0.03%)

Female

N (%)

62 (0.01%)

\<=60

Male

N (%)

155 (0.03%)

Female

N (%)

62 (0.01%)

1968-06-01 to 1968-06-30

overall

overall

N (%)

210 (0.04%)

\<=60

overall

N (%)

210 (0.04%)

overall

Male

N (%)

150 (0.03%)

Female

N (%)

60 (0.01%)

\<=60

Male

N (%)

150 (0.03%)

Female

N (%)

60 (0.01%)

1968-07-01 to 1968-07-31

overall

overall

N (%)

217 (0.04%)

\<=60

overall

N (%)

217 (0.04%)

overall

Male

N (%)

155 (0.03%)

Female

N (%)

62 (0.01%)

\<=60

Male

N (%)

155 (0.03%)

Female

N (%)

62 (0.01%)

1968-08-01 to 1968-08-31

overall

overall

N (%)

217 (0.04%)

\<=60

overall

N (%)

217 (0.04%)

overall

Male

N (%)

155 (0.03%)

Female

N (%)

62 (0.01%)

\<=60

Male

N (%)

155 (0.03%)

Female

N (%)

62 (0.01%)

1968-09-01 to 1968-09-30

overall

overall

N (%)

210 (0.04%)

\<=60

overall

N (%)

210 (0.04%)

overall

Male

N (%)

150 (0.03%)

Female

N (%)

60 (0.01%)

\<=60

Male

N (%)

150 (0.03%)

Female

N (%)

60 (0.01%)

1968-10-01 to 1968-10-31

overall

overall

N (%)

217 (0.04%)

\<=60

overall

N (%)

217 (0.04%)

overall

Male

N (%)

155 (0.03%)

Female

N (%)

62 (0.01%)

\<=60

Male

N (%)

155 (0.03%)

Female

N (%)

62 (0.01%)

1968-11-01 to 1968-11-30

overall

overall

N (%)

210 (0.04%)

\<=60

overall

N (%)

210 (0.04%)

overall

Male

N (%)

150 (0.03%)

Female

N (%)

60 (0.01%)

\<=60

Male

N (%)

150 (0.03%)

Female

N (%)

60 (0.01%)

1968-12-01 to 1968-12-31

overall

overall

N (%)

217 (0.04%)

\<=60

overall

N (%)

217 (0.04%)

overall

Male

N (%)

155 (0.03%)

Female

N (%)

62 (0.01%)

\<=60

Male

N (%)

155 (0.03%)

Female

N (%)

62 (0.01%)

1969-01-01 to 1969-01-31

overall

overall

N (%)

217 (0.04%)

\<=60

overall

N (%)

217 (0.04%)

overall

Male

N (%)

155 (0.03%)

Female

N (%)

62 (0.01%)

\<=60

Male

N (%)

155 (0.03%)

Female

N (%)

62 (0.01%)

1969-02-01 to 1969-02-28

overall

overall

N (%)

196 (0.04%)

\<=60

overall

N (%)

196 (0.04%)

overall

Male

N (%)

140 (0.03%)

Female

N (%)

56 (0.01%)

\<=60

Male

N (%)

140 (0.03%)

Female

N (%)

56 (0.01%)

1969-03-01 to 1969-03-31

overall

overall

N (%)

217 (0.04%)

\<=60

overall

N (%)

217 (0.04%)

overall

Male

N (%)

155 (0.03%)

Female

N (%)

62 (0.01%)

\<=60

Male

N (%)

155 (0.03%)

Female

N (%)

62 (0.01%)

1969-04-01 to 1969-04-30

overall

overall

N (%)

240 (0.05%)

\<=60

overall

N (%)

240 (0.05%)

overall

Male

N (%)

180 (0.04%)

Female

N (%)

60 (0.01%)

\<=60

Male

N (%)

180 (0.04%)

Female

N (%)

60 (0.01%)

1969-05-01 to 1969-05-31

overall

overall

N (%)

248 (0.05%)

\<=60

overall

N (%)

248 (0.05%)

overall

Male

N (%)

186 (0.04%)

Female

N (%)

62 (0.01%)

\<=60

Male

N (%)

186 (0.04%)

Female

N (%)

62 (0.01%)

1969-06-01 to 1969-06-30

overall

overall

N (%)

240 (0.05%)

\<=60

overall

N (%)

240 (0.05%)

overall

Male

N (%)

180 (0.04%)

Female

N (%)

60 (0.01%)

\<=60

Male

N (%)

180 (0.04%)

Female

N (%)

60 (0.01%)

1969-07-01 to 1969-07-31

overall

overall

N (%)

248 (0.05%)

\<=60

overall

N (%)

248 (0.05%)

overall

Male

N (%)

186 (0.04%)

Female

N (%)

62 (0.01%)

\<=60

Male

N (%)

186 (0.04%)

Female

N (%)

62 (0.01%)

1969-08-01 to 1969-08-31

overall

overall

N (%)

248 (0.05%)

\<=60

overall

N (%)

248 (0.05%)

overall

Male

N (%)

186 (0.04%)

Female

N (%)

62 (0.01%)

\<=60

Male

N (%)

186 (0.04%)

Female

N (%)

62 (0.01%)

1969-09-01 to 1969-09-30

overall

overall

N (%)

240 (0.05%)

\<=60

overall

N (%)

240 (0.05%)

overall

Male

N (%)

180 (0.04%)

Female

N (%)

60 (0.01%)

\<=60

Male

N (%)

180 (0.04%)

Female

N (%)

60 (0.01%)

1969-10-01 to 1969-10-31

overall

overall

N (%)

248 (0.05%)

\<=60

overall

N (%)

248 (0.05%)

overall

Male

N (%)

186 (0.04%)

Female

N (%)

62 (0.01%)

\<=60

Male

N (%)

186 (0.04%)

Female

N (%)

62 (0.01%)

1969-11-01 to 1969-11-30

overall

overall

N (%)

240 (0.05%)

\<=60

overall

N (%)

240 (0.05%)

overall

Male

N (%)

180 (0.04%)

Female

N (%)

60 (0.01%)

\<=60

Male

N (%)

180 (0.04%)

Female

N (%)

60 (0.01%)

1969-12-01 to 1969-12-31

overall

overall

N (%)

248 (0.05%)

\<=60

overall

N (%)

248 (0.05%)

overall

Male

N (%)

186 (0.04%)

Female

N (%)

62 (0.01%)

\<=60

Male

N (%)

186 (0.04%)

Female

N (%)

62 (0.01%)

1970-01-01 to 1970-01-31

overall

overall

N (%)

248 (0.05%)

\<=60

overall

N (%)

248 (0.05%)

overall

Male

N (%)

186 (0.04%)

Female

N (%)

62 (0.01%)

\<=60

Male

N (%)

186 (0.04%)

Female

N (%)

62 (0.01%)

1970-02-01 to 1970-02-28

overall

overall

N (%)

224 (0.05%)

\<=60

overall

N (%)

224 (0.05%)

overall

Male

N (%)

168 (0.03%)

Female

N (%)

56 (0.01%)

\<=60

Male

N (%)

168 (0.03%)

Female

N (%)

56 (0.01%)

1970-03-01 to 1970-03-31

overall

overall

N (%)

248 (0.05%)

\<=60

overall

N (%)

248 (0.05%)

overall

Male

N (%)

186 (0.04%)

Female

N (%)

62 (0.01%)

\<=60

Male

N (%)

186 (0.04%)

Female

N (%)

62 (0.01%)

1970-04-01 to 1970-04-30

overall

overall

N (%)

240 (0.05%)

\<=60

overall

N (%)

240 (0.05%)

overall

Male

N (%)

180 (0.04%)

Female

N (%)

60 (0.01%)

\<=60

Male

N (%)

180 (0.04%)

Female

N (%)

60 (0.01%)

1970-05-01 to 1970-05-31

overall

overall

N (%)

260 (0.05%)

\<=60

overall

N (%)

260 (0.05%)

overall

Male

N (%)

198 (0.04%)

Female

N (%)

62 (0.01%)

\<=60

Male

N (%)

198 (0.04%)

Female

N (%)

62 (0.01%)

1970-06-01 to 1970-06-30

overall

overall

N (%)

270 (0.05%)

\<=60

overall

N (%)

270 (0.05%)

overall

Male

N (%)

210 (0.04%)

Female

N (%)

60 (0.01%)

\<=60

Male

N (%)

210 (0.04%)

Female

N (%)

60 (0.01%)

1970-07-01 to 1970-07-31

overall

overall

N (%)

279 (0.06%)

\<=60

overall

N (%)

279 (0.06%)

overall

Male

N (%)

217 (0.04%)

Female

N (%)

62 (0.01%)

\<=60

Male

N (%)

217 (0.04%)

Female

N (%)

62 (0.01%)

1970-08-01 to 1970-08-31

overall

overall

N (%)

279 (0.06%)

\<=60

overall

N (%)

279 (0.06%)

overall

Male

N (%)

217 (0.04%)

Female

N (%)

62 (0.01%)

\<=60

Male

N (%)

217 (0.04%)

Female

N (%)

62 (0.01%)

1970-09-01 to 1970-09-30

overall

overall

N (%)

270 (0.05%)

\<=60

overall

N (%)

270 (0.05%)

overall

Male

N (%)

210 (0.04%)

Female

N (%)

60 (0.01%)

\<=60

Male

N (%)

210 (0.04%)

Female

N (%)

60 (0.01%)

1970-10-01 to 1970-10-31

overall

overall

N (%)

279 (0.06%)

\<=60

overall

N (%)

279 (0.06%)

overall

Male

N (%)

217 (0.04%)

Female

N (%)

62 (0.01%)

\<=60

Male

N (%)

217 (0.04%)

Female

N (%)

62 (0.01%)

1970-11-01 to 1970-11-30

overall

overall

N (%)

291 (0.06%)

\<=60

overall

N (%)

291 (0.06%)

overall

Male

N (%)

210 (0.04%)

Female

N (%)

81 (0.02%)

\<=60

Male

N (%)

210 (0.04%)

Female

N (%)

81 (0.02%)

1970-12-01 to 1970-12-31

overall

overall

N (%)

310 (0.06%)

\<=60

overall

N (%)

310 (0.06%)

overall

Male

N (%)

217 (0.04%)

Female

N (%)

93 (0.02%)

\<=60

Male

N (%)

217 (0.04%)

Female

N (%)

93 (0.02%)

1971-01-01 to 1971-01-31

overall

overall

N (%)

310 (0.06%)

\<=60

overall

N (%)

310 (0.06%)

overall

Male

N (%)

217 (0.04%)

Female

N (%)

93 (0.02%)

\<=60

Male

N (%)

217 (0.04%)

Female

N (%)

93 (0.02%)

1971-02-01 to 1971-02-28

overall

overall

N (%)

280 (0.06%)

\<=60

overall

N (%)

280 (0.06%)

overall

Male

N (%)

196 (0.04%)

Female

N (%)

84 (0.02%)

\<=60

Male

N (%)

196 (0.04%)

Female

N (%)

84 (0.02%)

1971-03-01 to 1971-03-31

overall

overall

N (%)

310 (0.06%)

\<=60

overall

N (%)

310 (0.06%)

overall

Male

N (%)

217 (0.04%)

Female

N (%)

93 (0.02%)

\<=60

Male

N (%)

217 (0.04%)

Female

N (%)

93 (0.02%)

1971-04-01 to 1971-04-30

overall

overall

N (%)

300 (0.06%)

\<=60

overall

N (%)

300 (0.06%)

overall

Male

N (%)

210 (0.04%)

Female

N (%)

90 (0.02%)

\<=60

Male

N (%)

210 (0.04%)

Female

N (%)

90 (0.02%)

1971-05-01 to 1971-05-31

overall

overall

N (%)

310 (0.06%)

\<=60

overall

N (%)

310 (0.06%)

overall

Male

N (%)

217 (0.04%)

Female

N (%)

93 (0.02%)

\<=60

Male

N (%)

217 (0.04%)

Female

N (%)

93 (0.02%)

1971-06-01 to 1971-06-30

overall

overall

N (%)

300 (0.06%)

\<=60

overall

N (%)

300 (0.06%)

overall

Male

N (%)

210 (0.04%)

Female

N (%)

90 (0.02%)

\<=60

Male

N (%)

210 (0.04%)

Female

N (%)

90 (0.02%)

1971-07-01 to 1971-07-31

overall

overall

N (%)

310 (0.06%)

\<=60

overall

N (%)

310 (0.06%)

overall

Male

N (%)

217 (0.04%)

Female

N (%)

93 (0.02%)

\<=60

Male

N (%)

217 (0.04%)

Female

N (%)

93 (0.02%)

1971-08-01 to 1971-08-31

overall

overall

N (%)

310 (0.06%)

\<=60

overall

N (%)

310 (0.06%)

overall

Male

N (%)

217 (0.04%)

Female

N (%)

93 (0.02%)

\<=60

Male

N (%)

217 (0.04%)

Female

N (%)

93 (0.02%)

1971-09-01 to 1971-09-30

overall

overall

N (%)

300 (0.06%)

\<=60

overall

N (%)

300 (0.06%)

overall

Male

N (%)

210 (0.04%)

Female

N (%)

90 (0.02%)

\<=60

Male

N (%)

210 (0.04%)

Female

N (%)

90 (0.02%)

1971-10-01 to 1971-10-31

overall

overall

N (%)

310 (0.06%)

\<=60

overall

N (%)

310 (0.06%)

overall

Male

N (%)

217 (0.04%)

Female

N (%)

93 (0.02%)

\<=60

Male

N (%)

217 (0.04%)

Female

N (%)

93 (0.02%)

1971-11-01 to 1971-11-30

overall

overall

N (%)

300 (0.06%)

\<=60

overall

N (%)

300 (0.06%)

overall

Male

N (%)

210 (0.04%)

Female

N (%)

90 (0.02%)

\<=60

Male

N (%)

210 (0.04%)

Female

N (%)

90 (0.02%)

1971-12-01 to 1971-12-31

overall

overall

N (%)

310 (0.06%)

\<=60

overall

N (%)

310 (0.06%)

overall

Male

N (%)

217 (0.04%)

Female

N (%)

93 (0.02%)

\<=60

Male

N (%)

217 (0.04%)

Female

N (%)

93 (0.02%)

1972-01-01 to 1972-01-31

overall

overall

N (%)

310 (0.06%)

\<=60

overall

N (%)

310 (0.06%)

overall

Male

N (%)

217 (0.04%)

Female

N (%)

93 (0.02%)

\<=60

Male

N (%)

217 (0.04%)

Female

N (%)

93 (0.02%)

1972-02-01 to 1972-02-29

overall

overall

N (%)

290 (0.06%)

\<=60

overall

N (%)

290 (0.06%)

overall

Male

N (%)

203 (0.04%)

Female

N (%)

87 (0.02%)

\<=60

Male

N (%)

203 (0.04%)

Female

N (%)

87 (0.02%)

1972-03-01 to 1972-03-31

overall

overall

N (%)

310 (0.06%)

\<=60

overall

N (%)

310 (0.06%)

overall

Male

N (%)

217 (0.04%)

Female

N (%)

93 (0.02%)

\<=60

Male

N (%)

217 (0.04%)

Female

N (%)

93 (0.02%)

1972-04-01 to 1972-04-30

overall

overall

N (%)

300 (0.06%)

\<=60

overall

N (%)

300 (0.06%)

overall

Male

N (%)

210 (0.04%)

Female

N (%)

90 (0.02%)

\<=60

Male

N (%)

210 (0.04%)

Female

N (%)

90 (0.02%)

1972-05-01 to 1972-05-31

overall

overall

N (%)

310 (0.06%)

\<=60

overall

N (%)

310 (0.06%)

overall

Male

N (%)

217 (0.04%)

Female

N (%)

93 (0.02%)

\<=60

Male

N (%)

217 (0.04%)

Female

N (%)

93 (0.02%)

1972-06-01 to 1972-06-30

overall

overall

N (%)

286 (0.06%)

\<=60

overall

N (%)

286 (0.06%)

overall

Male

N (%)

196 (0.04%)

Female

N (%)

90 (0.02%)

\<=60

Male

N (%)

196 (0.04%)

Female

N (%)

90 (0.02%)

1972-07-01 to 1972-07-31

overall

overall

N (%)

279 (0.06%)

\<=60

overall

N (%)

279 (0.06%)

overall

Male

N (%)

186 (0.04%)

Female

N (%)

93 (0.02%)

\<=60

Male

N (%)

186 (0.04%)

Female

N (%)

93 (0.02%)

1972-08-01 to 1972-08-31

overall

overall

N (%)

279 (0.06%)

\<=60

overall

N (%)

279 (0.06%)

overall

Male

N (%)

186 (0.04%)

Female

N (%)

93 (0.02%)

\<=60

Male

N (%)

186 (0.04%)

Female

N (%)

93 (0.02%)

1972-09-01 to 1972-09-30

overall

overall

N (%)

270 (0.05%)

\<=60

overall

N (%)

270 (0.05%)

overall

Male

N (%)

180 (0.04%)

Female

N (%)

90 (0.02%)

\<=60

Male

N (%)

180 (0.04%)

Female

N (%)

90 (0.02%)

1972-10-01 to 1972-10-31

overall

overall

N (%)

279 (0.06%)

\<=60

overall

N (%)

279 (0.06%)

overall

Male

N (%)

186 (0.04%)

Female

N (%)

93 (0.02%)

\<=60

Male

N (%)

186 (0.04%)

Female

N (%)

93 (0.02%)

1972-11-01 to 1972-11-30

overall

overall

N (%)

270 (0.05%)

\<=60

overall

N (%)

270 (0.05%)

overall

Male

N (%)

180 (0.04%)

Female

N (%)

90 (0.02%)

\<=60

Male

N (%)

180 (0.04%)

Female

N (%)

90 (0.02%)

1972-12-01 to 1972-12-31

overall

overall

N (%)

279 (0.06%)

\<=60

overall

N (%)

279 (0.06%)

overall

Male

N (%)

186 (0.04%)

Female

N (%)

93 (0.02%)

\<=60

Male

N (%)

186 (0.04%)

Female

N (%)

93 (0.02%)

1973-01-01 to 1973-01-31

overall

overall

N (%)

286 (0.06%)

\<=60

overall

N (%)

286 (0.06%)

overall

Male

N (%)

193 (0.04%)

Female

N (%)

93 (0.02%)

\<=60

Male

N (%)

193 (0.04%)

Female

N (%)

93 (0.02%)

1973-02-01 to 1973-02-28

overall

overall

N (%)

280 (0.06%)

\<=60

overall

N (%)

280 (0.06%)

overall

Male

N (%)

196 (0.04%)

Female

N (%)

84 (0.02%)

\<=60

Male

N (%)

196 (0.04%)

Female

N (%)

84 (0.02%)

1973-03-01 to 1973-03-31

overall

overall

N (%)

310 (0.06%)

\<=60

overall

N (%)

310 (0.06%)

overall

Male

N (%)

217 (0.04%)

Female

N (%)

93 (0.02%)

\<=60

Male

N (%)

217 (0.04%)

Female

N (%)

93 (0.02%)

1973-04-01 to 1973-04-30

overall

overall

N (%)

300 (0.06%)

\<=60

overall

N (%)

300 (0.06%)

overall

Male

N (%)

210 (0.04%)

Female

N (%)

90 (0.02%)

\<=60

Male

N (%)

210 (0.04%)

Female

N (%)

90 (0.02%)

1973-05-01 to 1973-05-31

overall

overall

N (%)

310 (0.06%)

\<=60

overall

N (%)

310 (0.06%)

overall

Male

N (%)

217 (0.04%)

Female

N (%)

93 (0.02%)

\<=60

Male

N (%)

217 (0.04%)

Female

N (%)

93 (0.02%)

1973-06-01 to 1973-06-30

overall

overall

N (%)

300 (0.06%)

\<=60

overall

N (%)

300 (0.06%)

overall

Male

N (%)

210 (0.04%)

Female

N (%)

90 (0.02%)

\<=60

Male

N (%)

210 (0.04%)

Female

N (%)

90 (0.02%)

1973-07-01 to 1973-07-31

overall

overall

N (%)

310 (0.06%)

\<=60

overall

N (%)

310 (0.06%)

overall

Male

N (%)

217 (0.04%)

Female

N (%)

93 (0.02%)

\<=60

Male

N (%)

217 (0.04%)

Female

N (%)

93 (0.02%)

1973-08-01 to 1973-08-31

overall

overall

N (%)

310 (0.06%)

\<=60

overall

N (%)

310 (0.06%)

overall

Male

N (%)

217 (0.04%)

Female

N (%)

93 (0.02%)

\<=60

Male

N (%)

217 (0.04%)

Female

N (%)

93 (0.02%)

1973-09-01 to 1973-09-30

overall

overall

N (%)

300 (0.06%)

\<=60

overall

N (%)

300 (0.06%)

overall

Male

N (%)

210 (0.04%)

Female

N (%)

90 (0.02%)

\<=60

Male

N (%)

210 (0.04%)

Female

N (%)

90 (0.02%)

1973-10-01 to 1973-10-31

overall

overall

N (%)

310 (0.06%)

\<=60

overall

N (%)

310 (0.06%)

overall

Male

N (%)

217 (0.04%)

Female

N (%)

93 (0.02%)

\<=60

Male

N (%)

217 (0.04%)

Female

N (%)

93 (0.02%)

1973-11-01 to 1973-11-30

overall

overall

N (%)

300 (0.06%)

\<=60

overall

N (%)

300 (0.06%)

overall

Male

N (%)

210 (0.04%)

Female

N (%)

90 (0.02%)

\<=60

Male

N (%)

210 (0.04%)

Female

N (%)

90 (0.02%)

1973-12-01 to 1973-12-31

overall

overall

N (%)

310 (0.06%)

\<=60

overall

N (%)

310 (0.06%)

overall

Male

N (%)

217 (0.04%)

Female

N (%)

93 (0.02%)

\<=60

Male

N (%)

217 (0.04%)

Female

N (%)

93 (0.02%)

1974-01-01 to 1974-01-31

overall

overall

N (%)

310 (0.06%)

\<=60

overall

N (%)

310 (0.06%)

overall

Male

N (%)

217 (0.04%)

Female

N (%)

93 (0.02%)

\<=60

Male

N (%)

217 (0.04%)

Female

N (%)

93 (0.02%)

1974-02-01 to 1974-02-28

overall

overall

N (%)

280 (0.06%)

\<=60

overall

N (%)

280 (0.06%)

overall

Male

N (%)

196 (0.04%)

Female

N (%)

84 (0.02%)

\<=60

Male

N (%)

196 (0.04%)

Female

N (%)

84 (0.02%)

1974-03-01 to 1974-03-31

overall

overall

N (%)

310 (0.06%)

\<=60

overall

N (%)

310 (0.06%)

overall

Male

N (%)

217 (0.04%)

Female

N (%)

93 (0.02%)

\<=60

Male

N (%)

217 (0.04%)

Female

N (%)

93 (0.02%)

1974-04-01 to 1974-04-30

overall

overall

N (%)

300 (0.06%)

\<=60

overall

N (%)

300 (0.06%)

overall

Male

N (%)

210 (0.04%)

Female

N (%)

90 (0.02%)

\<=60

Male

N (%)

210 (0.04%)

Female

N (%)

90 (0.02%)

1974-05-01 to 1974-05-31

overall

overall

N (%)

310 (0.06%)

\<=60

overall

N (%)

310 (0.06%)

overall

Male

N (%)

217 (0.04%)

Female

N (%)

93 (0.02%)

\<=60

Male

N (%)

217 (0.04%)

Female

N (%)

93 (0.02%)

1974-06-01 to 1974-06-30

overall

overall

N (%)

300 (0.06%)

\<=60

overall

N (%)

300 (0.06%)

overall

Male

N (%)

210 (0.04%)

Female

N (%)

90 (0.02%)

\<=60

Male

N (%)

210 (0.04%)

Female

N (%)

90 (0.02%)

1974-07-01 to 1974-07-31

overall

overall

N (%)

310 (0.06%)

\<=60

overall

N (%)

310 (0.06%)

overall

Male

N (%)

217 (0.04%)

Female

N (%)

93 (0.02%)

\<=60

Male

N (%)

217 (0.04%)

Female

N (%)

93 (0.02%)

1974-08-01 to 1974-08-31

overall

overall

N (%)

310 (0.06%)

\<=60

overall

N (%)

310 (0.06%)

overall

Male

N (%)

217 (0.04%)

Female

N (%)

93 (0.02%)

\<=60

Male

N (%)

217 (0.04%)

Female

N (%)

93 (0.02%)

1974-09-01 to 1974-09-30

overall

overall

N (%)

328 (0.07%)

\<=60

overall

N (%)

328 (0.07%)

overall

Male

N (%)

210 (0.04%)

Female

N (%)

118 (0.02%)

\<=60

Male

N (%)

210 (0.04%)

Female

N (%)

118 (0.02%)

1974-10-01 to 1974-10-31

overall

overall

N (%)

341 (0.07%)

\<=60

overall

N (%)

341 (0.07%)

overall

Male

N (%)

217 (0.04%)

Female

N (%)

124 (0.03%)

\<=60

Male

N (%)

217 (0.04%)

Female

N (%)

124 (0.03%)

1974-11-01 to 1974-11-30

overall

overall

N (%)

330 (0.07%)

\<=60

overall

N (%)

330 (0.07%)

overall

Male

N (%)

210 (0.04%)

Female

N (%)

120 (0.02%)

\<=60

Male

N (%)

210 (0.04%)

Female

N (%)

120 (0.02%)

1974-12-01 to 1974-12-31

overall

overall

N (%)

341 (0.07%)

\<=60

overall

N (%)

341 (0.07%)

overall

Male

N (%)

217 (0.04%)

Female

N (%)

124 (0.03%)

\<=60

Male

N (%)

217 (0.04%)

Female

N (%)

124 (0.03%)

1975-01-01 to 1975-01-31

overall

overall

N (%)

341 (0.07%)

\<=60

overall

N (%)

341 (0.07%)

overall

Male

N (%)

217 (0.04%)

Female

N (%)

124 (0.03%)

\<=60

Male

N (%)

217 (0.04%)

Female

N (%)

124 (0.03%)

1975-02-01 to 1975-02-28

overall

overall

N (%)

308 (0.06%)

\<=60

overall

N (%)

308 (0.06%)

overall

Male

N (%)

196 (0.04%)

Female

N (%)

112 (0.02%)

\<=60

Male

N (%)

196 (0.04%)

Female

N (%)

112 (0.02%)

1975-03-01 to 1975-03-31

overall

overall

N (%)

341 (0.07%)

\<=60

overall

N (%)

341 (0.07%)

overall

Male

N (%)

217 (0.04%)

Female

N (%)

124 (0.03%)

\<=60

Male

N (%)

217 (0.04%)

Female

N (%)

124 (0.03%)

1975-04-01 to 1975-04-30

overall

overall

N (%)

330 (0.07%)

\<=60

overall

N (%)

330 (0.07%)

overall

Male

N (%)

210 (0.04%)

Female

N (%)

120 (0.02%)

\<=60

Male

N (%)

210 (0.04%)

Female

N (%)

120 (0.02%)

1975-05-01 to 1975-05-31

overall

overall

N (%)

341 (0.07%)

\<=60

overall

N (%)

341 (0.07%)

overall

Male

N (%)

217 (0.04%)

Female

N (%)

124 (0.03%)

\<=60

Male

N (%)

217 (0.04%)

Female

N (%)

124 (0.03%)

1975-06-01 to 1975-06-30

overall

overall

N (%)

330 (0.07%)

\<=60

overall

N (%)

330 (0.07%)

overall

Male

N (%)

210 (0.04%)

Female

N (%)

120 (0.02%)

\<=60

Male

N (%)

210 (0.04%)

Female

N (%)

120 (0.02%)

1975-07-01 to 1975-07-31

overall

overall

N (%)

341 (0.07%)

\<=60

overall

N (%)

341 (0.07%)

overall

Male

N (%)

217 (0.04%)

Female

N (%)

124 (0.03%)

\<=60

Male

N (%)

217 (0.04%)

Female

N (%)

124 (0.03%)

1975-08-01 to 1975-08-31

overall

overall

N (%)

341 (0.07%)

\<=60

overall

N (%)

341 (0.07%)

overall

Male

N (%)

217 (0.04%)

Female

N (%)

124 (0.03%)

\<=60

Male

N (%)

217 (0.04%)

Female

N (%)

124 (0.03%)

1975-09-01 to 1975-09-30

overall

overall

N (%)

330 (0.07%)

\<=60

overall

N (%)

330 (0.07%)

overall

Male

N (%)

210 (0.04%)

Female

N (%)

120 (0.02%)

\<=60

Male

N (%)

210 (0.04%)

Female

N (%)

120 (0.02%)

1975-10-01 to 1975-10-31

overall

overall

N (%)

341 (0.07%)

\<=60

overall

N (%)

341 (0.07%)

overall

Male

N (%)

217 (0.04%)

Female

N (%)

124 (0.03%)

\<=60

Male

N (%)

217 (0.04%)

Female

N (%)

124 (0.03%)

1975-11-01 to 1975-11-30

overall

overall

N (%)

359 (0.07%)

\<=60

overall

N (%)

359 (0.07%)

overall

Male

N (%)

210 (0.04%)

Female

N (%)

149 (0.03%)

\<=60

Male

N (%)

210 (0.04%)

Female

N (%)

149 (0.03%)

1975-12-01 to 1975-12-31

overall

overall

N (%)

372 (0.08%)

\<=60

overall

N (%)

372 (0.08%)

overall

Male

N (%)

217 (0.04%)

Female

N (%)

155 (0.03%)

\<=60

Male

N (%)

217 (0.04%)

Female

N (%)

155 (0.03%)

1976-01-01 to 1976-01-31

overall

overall

N (%)

372 (0.08%)

\<=60

overall

N (%)

372 (0.08%)

overall

Male

N (%)

217 (0.04%)

Female

N (%)

155 (0.03%)

\<=60

Male

N (%)

217 (0.04%)

Female

N (%)

155 (0.03%)

1976-02-01 to 1976-02-29

overall

overall

N (%)

348 (0.07%)

\<=60

overall

N (%)

348 (0.07%)

overall

Male

N (%)

203 (0.04%)

Female

N (%)

145 (0.03%)

\<=60

Male

N (%)

203 (0.04%)

Female

N (%)

145 (0.03%)

1976-03-01 to 1976-03-31

overall

overall

N (%)

372 (0.08%)

\<=60

overall

N (%)

372 (0.08%)

overall

Male

N (%)

217 (0.04%)

Female

N (%)

155 (0.03%)

\<=60

Male

N (%)

217 (0.04%)

Female

N (%)

155 (0.03%)

1976-04-01 to 1976-04-30

overall

overall

N (%)

360 (0.07%)

\<=60

overall

N (%)

360 (0.07%)

overall

Male

N (%)

210 (0.04%)

Female

N (%)

150 (0.03%)

\<=60

Male

N (%)

210 (0.04%)

Female

N (%)

150 (0.03%)

1976-05-01 to 1976-05-31

overall

overall

N (%)

372 (0.08%)

\<=60

overall

N (%)

372 (0.08%)

overall

Male

N (%)

217 (0.04%)

Female

N (%)

155 (0.03%)

\<=60

Male

N (%)

217 (0.04%)

Female

N (%)

155 (0.03%)

1976-06-01 to 1976-06-30

overall

overall

N (%)

360 (0.07%)

\<=60

overall

N (%)

360 (0.07%)

overall

Male

N (%)

210 (0.04%)

Female

N (%)

150 (0.03%)

\<=60

Male

N (%)

210 (0.04%)

Female

N (%)

150 (0.03%)

1976-07-01 to 1976-07-31

overall

overall

N (%)

372 (0.08%)

\<=60

overall

N (%)

372 (0.08%)

overall

Male

N (%)

217 (0.04%)

Female

N (%)

155 (0.03%)

\<=60

Male

N (%)

217 (0.04%)

Female

N (%)

155 (0.03%)

1976-08-01 to 1976-08-31

overall

overall

N (%)

372 (0.08%)

\<=60

overall

N (%)

372 (0.08%)

overall

Male

N (%)

217 (0.04%)

Female

N (%)

155 (0.03%)

\<=60

Male

N (%)

217 (0.04%)

Female

N (%)

155 (0.03%)

1976-09-01 to 1976-09-30

overall

overall

N (%)

360 (0.07%)

\<=60

overall

N (%)

360 (0.07%)

overall

Male

N (%)

210 (0.04%)

Female

N (%)

150 (0.03%)

\<=60

Male

N (%)

210 (0.04%)

Female

N (%)

150 (0.03%)

1976-10-01 to 1976-10-31

overall

overall

N (%)

389 (0.08%)

\<=60

overall

N (%)

389 (0.08%)

overall

Female

N (%)

172 (0.03%)

Male

N (%)

217 (0.04%)

\<=60

Female

N (%)

172 (0.03%)

Male

N (%)

217 (0.04%)

1976-11-01 to 1976-11-30

overall

overall

N (%)

390 (0.08%)

\<=60

overall

N (%)

390 (0.08%)

overall

Female

N (%)

180 (0.04%)

Male

N (%)

210 (0.04%)

\<=60

Female

N (%)

180 (0.04%)

Male

N (%)

210 (0.04%)

1976-12-01 to 1976-12-31

overall

overall

N (%)

403 (0.08%)

\<=60

overall

N (%)

403 (0.08%)

overall

Female

N (%)

186 (0.04%)

Male

N (%)

217 (0.04%)

\<=60

Female

N (%)

186 (0.04%)

Male

N (%)

217 (0.04%)

1977-01-01 to 1977-01-31

overall

overall

N (%)

403 (0.08%)

\<=60

overall

N (%)

403 (0.08%)

overall

Female

N (%)

186 (0.04%)

Male

N (%)

217 (0.04%)

\<=60

Female

N (%)

186 (0.04%)

Male

N (%)

217 (0.04%)

1977-02-01 to 1977-02-28

overall

overall

N (%)

364 (0.07%)

\<=60

overall

N (%)

364 (0.07%)

overall

Female

N (%)

168 (0.03%)

Male

N (%)

196 (0.04%)

\<=60

Female

N (%)

168 (0.03%)

Male

N (%)

196 (0.04%)

1977-03-01 to 1977-03-31

overall

overall

N (%)

403 (0.08%)

\<=60

overall

N (%)

403 (0.08%)

overall

Female

N (%)

186 (0.04%)

Male

N (%)

217 (0.04%)

\<=60

Female

N (%)

186 (0.04%)

Male

N (%)

217 (0.04%)

1977-04-01 to 1977-04-30

overall

overall

N (%)

390 (0.08%)

\<=60

overall

N (%)

390 (0.08%)

overall

Female

N (%)

180 (0.04%)

Male

N (%)

210 (0.04%)

\<=60

Female

N (%)

180 (0.04%)

Male

N (%)

210 (0.04%)

1977-05-01 to 1977-05-31

overall

overall

N (%)

403 (0.08%)

\<=60

overall

N (%)

403 (0.08%)

overall

Female

N (%)

186 (0.04%)

Male

N (%)

217 (0.04%)

\<=60

Female

N (%)

186 (0.04%)

Male

N (%)

217 (0.04%)

1977-06-01 to 1977-06-30

overall

overall

N (%)

390 (0.08%)

\<=60

overall

N (%)

390 (0.08%)

overall

Female

N (%)

180 (0.04%)

Male

N (%)

210 (0.04%)

\<=60

Female

N (%)

180 (0.04%)

Male

N (%)

210 (0.04%)

1977-07-01 to 1977-07-31

overall

overall

N (%)

406 (0.08%)

\<=60

overall

N (%)

406 (0.08%)

overall

Female

N (%)

189 (0.04%)

Male

N (%)

217 (0.04%)

\<=60

Female

N (%)

189 (0.04%)

Male

N (%)

217 (0.04%)

1977-08-01 to 1977-08-31

overall

overall

N (%)

434 (0.09%)

\<=60

overall

N (%)

434 (0.09%)

overall

Female

N (%)

217 (0.04%)

Male

N (%)

217 (0.04%)

\<=60

Female

N (%)

217 (0.04%)

Male

N (%)

217 (0.04%)

1977-09-01 to 1977-09-30

overall

overall

N (%)

420 (0.09%)

\<=60

overall

N (%)

420 (0.09%)

overall

Female

N (%)

210 (0.04%)

Male

N (%)

210 (0.04%)

\<=60

Female

N (%)

210 (0.04%)

Male

N (%)

210 (0.04%)

1977-10-01 to 1977-10-31

overall

overall

N (%)

434 (0.09%)

\<=60

overall

N (%)

434 (0.09%)

overall

Female

N (%)

217 (0.04%)

Male

N (%)

217 (0.04%)

\<=60

Female

N (%)

217 (0.04%)

Male

N (%)

217 (0.04%)

1977-11-01 to 1977-11-30

overall

overall

N (%)

420 (0.09%)

\<=60

overall

N (%)

420 (0.09%)

overall

Female

N (%)

210 (0.04%)

Male

N (%)

210 (0.04%)

\<=60

Female

N (%)

210 (0.04%)

Male

N (%)

210 (0.04%)

1977-12-01 to 1977-12-31

overall

overall

N (%)

434 (0.09%)

\<=60

overall

N (%)

434 (0.09%)

overall

Female

N (%)

217 (0.04%)

Male

N (%)

217 (0.04%)

\<=60

Female

N (%)

217 (0.04%)

Male

N (%)

217 (0.04%)

1978-01-01 to 1978-01-31

overall

overall

N (%)

434 (0.09%)

\<=60

overall

N (%)

434 (0.09%)

overall

Female

N (%)

217 (0.04%)

Male

N (%)

217 (0.04%)

\<=60

Female

N (%)

217 (0.04%)

Male

N (%)

217 (0.04%)

1978-02-01 to 1978-02-28

overall

overall

N (%)

392 (0.08%)

\<=60

overall

N (%)

392 (0.08%)

overall

Female

N (%)

196 (0.04%)

Male

N (%)

196 (0.04%)

\<=60

Female

N (%)

196 (0.04%)

Male

N (%)

196 (0.04%)

1978-03-01 to 1978-03-31

overall

overall

N (%)

434 (0.09%)

\<=60

overall

N (%)

434 (0.09%)

overall

Female

N (%)

217 (0.04%)

Male

N (%)

217 (0.04%)

\<=60

Female

N (%)

217 (0.04%)

Male

N (%)

217 (0.04%)

1978-04-01 to 1978-04-30

overall

overall

N (%)

420 (0.09%)

\<=60

overall

N (%)

420 (0.09%)

overall

Female

N (%)

210 (0.04%)

Male

N (%)

210 (0.04%)

\<=60

Female

N (%)

210 (0.04%)

Male

N (%)

210 (0.04%)

1978-05-01 to 1978-05-31

overall

overall

N (%)

449 (0.09%)

\<=60

overall

N (%)

449 (0.09%)

overall

Female

N (%)

217 (0.04%)

Male

N (%)

232 (0.05%)

\<=60

Female

N (%)

217 (0.04%)

Male

N (%)

232 (0.05%)

1978-06-01 to 1978-06-30

overall

overall

N (%)

450 (0.09%)

\<=60

overall

N (%)

450 (0.09%)

overall

Female

N (%)

210 (0.04%)

Male

N (%)

240 (0.05%)

\<=60

Female

N (%)

210 (0.04%)

Male

N (%)

240 (0.05%)

1978-07-01 to 1978-07-31

overall

overall

N (%)

465 (0.09%)

\<=60

overall

N (%)

465 (0.09%)

overall

Female

N (%)

217 (0.04%)

Male

N (%)

248 (0.05%)

\<=60

Female

N (%)

217 (0.04%)

Male

N (%)

248 (0.05%)

1978-08-01 to 1978-08-31

overall

overall

N (%)

465 (0.09%)

\<=60

overall

N (%)

465 (0.09%)

overall

Female

N (%)

217 (0.04%)

Male

N (%)

248 (0.05%)

\<=60

Female

N (%)

217 (0.04%)

Male

N (%)

248 (0.05%)

1978-09-01 to 1978-09-30

overall

overall

N (%)

450 (0.09%)

\<=60

overall

N (%)

450 (0.09%)

overall

Female

N (%)

210 (0.04%)

Male

N (%)

240 (0.05%)

\<=60

Female

N (%)

210 (0.04%)

Male

N (%)

240 (0.05%)

1978-10-01 to 1978-10-31

overall

overall

N (%)

465 (0.09%)

\<=60

overall

N (%)

465 (0.09%)

overall

Female

N (%)

217 (0.04%)

Male

N (%)

248 (0.05%)

\<=60

Female

N (%)

217 (0.04%)

Male

N (%)

248 (0.05%)

1978-11-01 to 1978-11-30

overall

overall

N (%)

450 (0.09%)

\<=60

overall

N (%)

450 (0.09%)

overall

Female

N (%)

210 (0.04%)

Male

N (%)

240 (0.05%)

\<=60

Female

N (%)

210 (0.04%)

Male

N (%)

240 (0.05%)

1978-12-01 to 1978-12-31

overall

overall

N (%)

465 (0.09%)

\<=60

overall

N (%)

465 (0.09%)

overall

Female

N (%)

217 (0.04%)

Male

N (%)

248 (0.05%)

\<=60

Female

N (%)

217 (0.04%)

Male

N (%)

248 (0.05%)

1979-01-01 to 1979-01-31

overall

overall

N (%)

465 (0.09%)

\<=60

overall

N (%)

465 (0.09%)

overall

Female

N (%)

217 (0.04%)

Male

N (%)

248 (0.05%)

\<=60

Female

N (%)

217 (0.04%)

Male

N (%)

248 (0.05%)

1979-02-01 to 1979-02-28

overall

overall

N (%)

428 (0.09%)

\<=60

overall

N (%)

428 (0.09%)

overall

Female

N (%)

196 (0.04%)

Male

N (%)

232 (0.05%)

\<=60

Female

N (%)

196 (0.04%)

Male

N (%)

232 (0.05%)

1979-03-01 to 1979-03-31

overall

overall

N (%)

496 (0.10%)

\<=60

overall

N (%)

496 (0.10%)

overall

Female

N (%)

217 (0.04%)

Male

N (%)

279 (0.06%)

\<=60

Female

N (%)

217 (0.04%)

Male

N (%)

279 (0.06%)

1979-04-01 to 1979-04-30

overall

overall

N (%)

480 (0.10%)

\<=60

overall

N (%)

480 (0.10%)

overall

Female

N (%)

210 (0.04%)

Male

N (%)

270 (0.05%)

\<=60

Female

N (%)

210 (0.04%)

Male

N (%)

270 (0.05%)

1979-05-01 to 1979-05-31

overall

overall

N (%)

492 (0.10%)

\<=60

overall

N (%)

492 (0.10%)

overall

Female

N (%)

217 (0.04%)

Male

N (%)

275 (0.06%)

\<=60

Female

N (%)

217 (0.04%)

Male

N (%)

275 (0.06%)

1979-06-01 to 1979-06-30

overall

overall

N (%)

468 (0.09%)

\<=60

overall

N (%)

468 (0.09%)

overall

Female

N (%)

228 (0.05%)

Male

N (%)

240 (0.05%)

\<=60

Female

N (%)

228 (0.05%)

Male

N (%)

240 (0.05%)

1979-07-01 to 1979-07-31

overall

overall

N (%)

503 (0.10%)

\<=60

overall

N (%)

503 (0.10%)

overall

Female

N (%)

255 (0.05%)

Male

N (%)

248 (0.05%)

\<=60

Female

N (%)

255 (0.05%)

Male

N (%)

248 (0.05%)

1979-08-01 to 1979-08-31

overall

overall

N (%)

527 (0.11%)

\<=60

overall

N (%)

527 (0.11%)

overall

Female

N (%)

279 (0.06%)

Male

N (%)

248 (0.05%)

\<=60

Female

N (%)

279 (0.06%)

Male

N (%)

248 (0.05%)

1979-09-01 to 1979-09-30

overall

overall

N (%)

510 (0.10%)

\<=60

overall

N (%)

510 (0.10%)

overall

Female

N (%)

270 (0.05%)

Male

N (%)

240 (0.05%)

\<=60

Female

N (%)

270 (0.05%)

Male

N (%)

240 (0.05%)

1979-10-01 to 1979-10-31

overall

overall

N (%)

527 (0.11%)

\<=60

overall

N (%)

527 (0.11%)

overall

Female

N (%)

279 (0.06%)

Male

N (%)

248 (0.05%)

\<=60

Female

N (%)

279 (0.06%)

Male

N (%)

248 (0.05%)

1979-11-01 to 1979-11-30

overall

overall

N (%)

510 (0.10%)

\<=60

overall

N (%)

510 (0.10%)

overall

Female

N (%)

270 (0.05%)

Male

N (%)

240 (0.05%)

\<=60

Female

N (%)

270 (0.05%)

Male

N (%)

240 (0.05%)

1979-12-01 to 1979-12-31

overall

overall

N (%)

527 (0.11%)

\<=60

overall

N (%)

527 (0.11%)

overall

Female

N (%)

279 (0.06%)

Male

N (%)

248 (0.05%)

\<=60

Female

N (%)

279 (0.06%)

Male

N (%)

248 (0.05%)

1980-01-01 to 1980-01-31

overall

overall

N (%)

527 (0.11%)

\<=60

overall

N (%)

527 (0.11%)

overall

Female

N (%)

279 (0.06%)

Male

N (%)

248 (0.05%)

\<=60

Female

N (%)

279 (0.06%)

Male

N (%)

248 (0.05%)

1980-02-01 to 1980-02-29

overall

overall

N (%)

493 (0.10%)

\<=60

overall

N (%)

493 (0.10%)

overall

Female

N (%)

261 (0.05%)

Male

N (%)

232 (0.05%)

\<=60

Female

N (%)

261 (0.05%)

Male

N (%)

232 (0.05%)

1980-03-01 to 1980-03-31

overall

overall

N (%)

527 (0.11%)

\<=60

overall

N (%)

527 (0.11%)

overall

Female

N (%)

279 (0.06%)

Male

N (%)

248 (0.05%)

\<=60

Female

N (%)

279 (0.06%)

Male

N (%)

248 (0.05%)

1980-04-01 to 1980-04-30

overall

overall

N (%)

510 (0.10%)

\<=60

overall

N (%)

510 (0.10%)

overall

Female

N (%)

270 (0.05%)

Male

N (%)

240 (0.05%)

\<=60

Female

N (%)

270 (0.05%)

Male

N (%)

240 (0.05%)

1980-05-01 to 1980-05-31

overall

overall

N (%)

501 (0.10%)

\<=60

overall

N (%)

501 (0.10%)

overall

Female

N (%)

253 (0.05%)

Male

N (%)

248 (0.05%)

\<=60

Female

N (%)

253 (0.05%)

Male

N (%)

248 (0.05%)

1980-06-01 to 1980-06-30

overall

overall

N (%)

480 (0.10%)

\<=60

overall

N (%)

480 (0.10%)

overall

Male

N (%)

240 (0.05%)

Female

N (%)

240 (0.05%)

\<=60

Male

N (%)

240 (0.05%)

Female

N (%)

240 (0.05%)

1980-07-01 to 1980-07-31

overall

overall

N (%)

496 (0.10%)

\<=60

overall

N (%)

496 (0.10%)

overall

Male

N (%)

248 (0.05%)

Female

N (%)

248 (0.05%)

\<=60

Male

N (%)

248 (0.05%)

Female

N (%)

248 (0.05%)

1980-08-01 to 1980-08-31

overall

overall

N (%)

496 (0.10%)

\<=60

overall

N (%)

496 (0.10%)

overall

Male

N (%)

248 (0.05%)

Female

N (%)

248 (0.05%)

\<=60

Male

N (%)

248 (0.05%)

Female

N (%)

248 (0.05%)

1980-09-01 to 1980-09-30

overall

overall

N (%)

485 (0.10%)

\<=60

overall

N (%)

485 (0.10%)

overall

Male

N (%)

240 (0.05%)

Female

N (%)

245 (0.05%)

\<=60

Male

N (%)

240 (0.05%)

Female

N (%)

245 (0.05%)

1980-10-01 to 1980-10-31

overall

overall

N (%)

498 (0.10%)

\<=60

overall

N (%)

498 (0.10%)

overall

Male

N (%)

219 (0.04%)

Female

N (%)

279 (0.06%)

\<=60

Male

N (%)

219 (0.04%)

Female

N (%)

279 (0.06%)

1980-11-01 to 1980-11-30

overall

overall

N (%)

480 (0.10%)

\<=60

overall

N (%)

480 (0.10%)

overall

Male

N (%)

210 (0.04%)

Female

N (%)

270 (0.05%)

\<=60

Male

N (%)

210 (0.04%)

Female

N (%)

270 (0.05%)

1980-12-01 to 1980-12-31

overall

overall

N (%)

496 (0.10%)

\<=60

overall

N (%)

496 (0.10%)

overall

Male

N (%)

217 (0.04%)

Female

N (%)

279 (0.06%)

\<=60

Male

N (%)

217 (0.04%)

Female

N (%)

279 (0.06%)

1981-01-01 to 1981-01-31

overall

overall

N (%)

496 (0.10%)

\<=60

overall

N (%)

496 (0.10%)

overall

Male

N (%)

217 (0.04%)

Female

N (%)

279 (0.06%)

\<=60

Male

N (%)

217 (0.04%)

Female

N (%)

279 (0.06%)

1981-02-01 to 1981-02-28

overall

overall

N (%)

448 (0.09%)

\<=60

overall

N (%)

448 (0.09%)

overall

Male

N (%)

196 (0.04%)

Female

N (%)

252 (0.05%)

\<=60

Male

N (%)

196 (0.04%)

Female

N (%)

252 (0.05%)

1981-03-01 to 1981-03-31

overall

overall

N (%)

496 (0.10%)

\<=60

overall

N (%)

496 (0.10%)

overall

Male

N (%)

217 (0.04%)

Female

N (%)

279 (0.06%)

\<=60

Male

N (%)

217 (0.04%)

Female

N (%)

279 (0.06%)

1981-04-01 to 1981-04-30

overall

overall

N (%)

480 (0.10%)

\<=60

overall

N (%)

480 (0.10%)

overall

Male

N (%)

210 (0.04%)

Female

N (%)

270 (0.05%)

\<=60

Male

N (%)

210 (0.04%)

Female

N (%)

270 (0.05%)

1981-05-01 to 1981-05-31

overall

overall

N (%)

496 (0.10%)

\<=60

overall

N (%)

496 (0.10%)

overall

Male

N (%)

217 (0.04%)

Female

N (%)

279 (0.06%)

\<=60

Male

N (%)

217 (0.04%)

Female

N (%)

279 (0.06%)

1981-06-01 to 1981-06-30

overall

overall

N (%)

480 (0.10%)

\<=60

overall

N (%)

480 (0.10%)

overall

Male

N (%)

210 (0.04%)

Female

N (%)

270 (0.05%)

\<=60

Male

N (%)

210 (0.04%)

Female

N (%)

270 (0.05%)

1981-07-01 to 1981-07-31

overall

overall

N (%)

496 (0.10%)

\<=60

overall

N (%)

496 (0.10%)

overall

Male

N (%)

217 (0.04%)

Female

N (%)

279 (0.06%)

\<=60

Male

N (%)

217 (0.04%)

Female

N (%)

279 (0.06%)

1981-08-01 to 1981-08-31

overall

overall

N (%)

496 (0.10%)

\<=60

overall

N (%)

496 (0.10%)

overall

Male

N (%)

217 (0.04%)

Female

N (%)

279 (0.06%)

\<=60

Male

N (%)

217 (0.04%)

Female

N (%)

279 (0.06%)

1981-09-01 to 1981-09-30

overall

overall

N (%)

480 (0.10%)

\<=60

overall

N (%)

480 (0.10%)

overall

Male

N (%)

210 (0.04%)

Female

N (%)

270 (0.05%)

\<=60

Male

N (%)

210 (0.04%)

Female

N (%)

270 (0.05%)

1981-10-01 to 1981-10-31

overall

overall

N (%)

510 (0.10%)

\<=60

overall

N (%)

510 (0.10%)

overall

Male

N (%)

231 (0.05%)

Female

N (%)

279 (0.06%)

\<=60

Male

N (%)

231 (0.05%)

Female

N (%)

279 (0.06%)

1981-11-01 to 1981-11-30

overall

overall

N (%)

536 (0.11%)

\<=60

overall

N (%)

536 (0.11%)

overall

Male

N (%)

244 (0.05%)

Female

N (%)

292 (0.06%)

\<=60

Male

N (%)

244 (0.05%)

Female

N (%)

292 (0.06%)

1981-12-01 to 1981-12-31

overall

overall

N (%)

589 (0.12%)

\<=60

overall

N (%)

589 (0.12%)

overall

Male

N (%)

279 (0.06%)

Female

N (%)

310 (0.06%)

\<=60

Male

N (%)

279 (0.06%)

Female

N (%)

310 (0.06%)

1982-01-01 to 1982-01-31

overall

overall

N (%)

589 (0.12%)

\<=60

overall

N (%)

589 (0.12%)

overall

Male

N (%)

279 (0.06%)

Female

N (%)

310 (0.06%)

\<=60

Male

N (%)

279 (0.06%)

Female

N (%)

310 (0.06%)

1982-02-01 to 1982-02-28

overall

overall

N (%)

532 (0.11%)

\<=60

overall

N (%)

532 (0.11%)

overall

Male

N (%)

252 (0.05%)

Female

N (%)

280 (0.06%)

\<=60

Male

N (%)

252 (0.05%)

Female

N (%)

280 (0.06%)

1982-03-01 to 1982-03-31

overall

overall

N (%)

589 (0.12%)

\<=60

overall

N (%)

589 (0.12%)

overall

Male

N (%)

279 (0.06%)

Female

N (%)

310 (0.06%)

\<=60

Male

N (%)

279 (0.06%)

Female

N (%)

310 (0.06%)

1982-04-01 to 1982-04-30

overall

overall

N (%)

571 (0.12%)

\<=60

overall

N (%)

571 (0.12%)

overall

Male

N (%)

271 (0.05%)

Female

N (%)

300 (0.06%)

\<=60

Male

N (%)

271 (0.05%)

Female

N (%)

300 (0.06%)

1982-05-01 to 1982-05-31

overall

overall

N (%)

603 (0.12%)

\<=60

overall

N (%)

603 (0.12%)

overall

Male

N (%)

310 (0.06%)

Female

N (%)

293 (0.06%)

\<=60

Male

N (%)

310 (0.06%)

Female

N (%)

293 (0.06%)

1982-06-01 to 1982-06-30

overall

overall

N (%)

570 (0.12%)

\<=60

overall

N (%)

570 (0.12%)

overall

Male

N (%)

300 (0.06%)

Female

N (%)

270 (0.05%)

\<=60

Male

N (%)

300 (0.06%)

Female

N (%)

270 (0.05%)

1982-07-01 to 1982-07-31

overall

overall

N (%)

589 (0.12%)

\<=60

overall

N (%)

589 (0.12%)

overall

Male

N (%)

310 (0.06%)

Female

N (%)

279 (0.06%)

\<=60

Male

N (%)

310 (0.06%)

Female

N (%)

279 (0.06%)

1982-08-01 to 1982-08-31

overall

overall

N (%)

589 (0.12%)

\<=60

overall

N (%)

589 (0.12%)

overall

Male

N (%)

310 (0.06%)

Female

N (%)

279 (0.06%)

\<=60

Male

N (%)

310 (0.06%)

Female

N (%)

279 (0.06%)

1982-09-01 to 1982-09-30

overall

overall

N (%)

570 (0.12%)

\<=60

overall

N (%)

570 (0.12%)

overall

Male

N (%)

300 (0.06%)

Female

N (%)

270 (0.05%)

\<=60

Male

N (%)

300 (0.06%)

Female

N (%)

270 (0.05%)

1982-10-01 to 1982-10-31

overall

overall

N (%)

589 (0.12%)

\<=60

overall

N (%)

589 (0.12%)

overall

Male

N (%)

310 (0.06%)

Female

N (%)

279 (0.06%)

\<=60

Male

N (%)

310 (0.06%)

Female

N (%)

279 (0.06%)

1982-11-01 to 1982-11-30

overall

overall

N (%)

570 (0.12%)

\<=60

overall

N (%)

570 (0.12%)

overall

Male

N (%)

300 (0.06%)

Female

N (%)

270 (0.05%)

\<=60

Male

N (%)

300 (0.06%)

Female

N (%)

270 (0.05%)

1982-12-01 to 1982-12-31

overall

overall

N (%)

589 (0.12%)

\<=60

overall

N (%)

589 (0.12%)

overall

Male

N (%)

310 (0.06%)

Female

N (%)

279 (0.06%)

\<=60

Male

N (%)

310 (0.06%)

Female

N (%)

279 (0.06%)

1983-01-01 to 1983-01-31

overall

overall

N (%)

605 (0.12%)

\<=60

overall

N (%)

605 (0.12%)

overall

Male

N (%)

326 (0.07%)

Female

N (%)

279 (0.06%)

\<=60

Male

N (%)

326 (0.07%)

Female

N (%)

279 (0.06%)

1983-02-01 to 1983-02-28

overall

overall

N (%)

560 (0.11%)

\<=60

overall

N (%)

560 (0.11%)

overall

Male

N (%)

308 (0.06%)

Female

N (%)

252 (0.05%)

\<=60

Male

N (%)

308 (0.06%)

Female

N (%)

252 (0.05%)

1983-03-01 to 1983-03-31

overall

overall

N (%)

620 (0.13%)

\<=60

overall

N (%)

620 (0.13%)

overall

Male

N (%)

341 (0.07%)

Female

N (%)

279 (0.06%)

\<=60

Male

N (%)

341 (0.07%)

Female

N (%)

279 (0.06%)

1983-04-01 to 1983-04-30

overall

overall

N (%)

622 (0.13%)

\<=60

overall

N (%)

622 (0.13%)

overall

Male

N (%)

330 (0.07%)

Female

N (%)

292 (0.06%)

\<=60

Male

N (%)

330 (0.07%)

Female

N (%)

292 (0.06%)

1983-05-01 to 1983-05-31

overall

overall

N (%)

651 (0.13%)

\<=60

overall

N (%)

651 (0.13%)

overall

Male

N (%)

341 (0.07%)

Female

N (%)

310 (0.06%)

\<=60

Male

N (%)

341 (0.07%)

Female

N (%)

310 (0.06%)

1983-06-01 to 1983-06-30

overall

overall

N (%)

630 (0.13%)

\<=60

overall

N (%)

630 (0.13%)

overall

Male

N (%)

330 (0.07%)

Female

N (%)

300 (0.06%)

\<=60

Male

N (%)

330 (0.07%)

Female

N (%)

300 (0.06%)

1983-07-01 to 1983-07-31

overall

overall

N (%)

651 (0.13%)

\<=60

overall

N (%)

651 (0.13%)

overall

Male

N (%)

341 (0.07%)

Female

N (%)

310 (0.06%)

\<=60

Male

N (%)

341 (0.07%)

Female

N (%)

310 (0.06%)

1983-08-01 to 1983-08-31

overall

overall

N (%)

651 (0.13%)

\<=60

overall

N (%)

651 (0.13%)

overall

Male

N (%)

341 (0.07%)

Female

N (%)

310 (0.06%)

\<=60

Male

N (%)

341 (0.07%)

Female

N (%)

310 (0.06%)

1983-09-01 to 1983-09-30

overall

overall

N (%)

630 (0.13%)

\<=60

overall

N (%)

630 (0.13%)

overall

Male

N (%)

330 (0.07%)

Female

N (%)

300 (0.06%)

\<=60

Male

N (%)

330 (0.07%)

Female

N (%)

300 (0.06%)

1983-10-01 to 1983-10-31

overall

overall

N (%)

651 (0.13%)

\<=60

overall

N (%)

651 (0.13%)

overall

Male

N (%)

341 (0.07%)

Female

N (%)

310 (0.06%)

\<=60

Male

N (%)

341 (0.07%)

Female

N (%)

310 (0.06%)

1983-11-01 to 1983-11-30

overall

overall

N (%)

630 (0.13%)

\<=60

overall

N (%)

630 (0.13%)

overall

Male

N (%)

330 (0.07%)

Female

N (%)

300 (0.06%)

\<=60

Male

N (%)

330 (0.07%)

Female

N (%)

300 (0.06%)

1983-12-01 to 1983-12-31

overall

overall

N (%)

651 (0.13%)

\<=60

overall

N (%)

651 (0.13%)

overall

Male

N (%)

341 (0.07%)

Female

N (%)

310 (0.06%)

\<=60

Male

N (%)

341 (0.07%)

Female

N (%)

310 (0.06%)

1984-01-01 to 1984-01-31

overall

overall

N (%)

651 (0.13%)

\<=60

overall

N (%)

651 (0.13%)

overall

Male

N (%)

341 (0.07%)

Female

N (%)

310 (0.06%)

\<=60

Male

N (%)

341 (0.07%)

Female

N (%)

310 (0.06%)

1984-02-01 to 1984-02-29

overall

overall

N (%)

632 (0.13%)

\<=60

overall

N (%)

632 (0.13%)

overall

Male

N (%)

319 (0.06%)

Female

N (%)

313 (0.06%)

\<=60

Male

N (%)

319 (0.06%)

Female

N (%)

313 (0.06%)

1984-03-01 to 1984-03-31

overall

overall

N (%)

682 (0.14%)

\<=60

overall

N (%)

682 (0.14%)

overall

Male

N (%)

341 (0.07%)

Female

N (%)

341 (0.07%)

\<=60

Male

N (%)

341 (0.07%)

Female

N (%)

341 (0.07%)

1984-04-01 to 1984-04-30

overall

overall

N (%)

660 (0.13%)

\<=60

overall

N (%)

660 (0.13%)

overall

Male

N (%)

330 (0.07%)

Female

N (%)

330 (0.07%)

\<=60

Male

N (%)

330 (0.07%)

Female

N (%)

330 (0.07%)

1984-05-01 to 1984-05-31

overall

overall

N (%)

682 (0.14%)

\<=60

overall

N (%)

682 (0.14%)

overall

Male

N (%)

341 (0.07%)

Female

N (%)

341 (0.07%)

\<=60

Male

N (%)

341 (0.07%)

Female

N (%)

341 (0.07%)

1984-06-01 to 1984-06-30

overall

overall

N (%)

660 (0.13%)

\<=60

overall

N (%)

660 (0.13%)

overall

Male

N (%)

330 (0.07%)

Female

N (%)

330 (0.07%)

\<=60

Male

N (%)

330 (0.07%)

Female

N (%)

330 (0.07%)

1984-07-01 to 1984-07-31

overall

overall

N (%)

682 (0.14%)

\<=60

overall

N (%)

682 (0.14%)

overall

Male

N (%)

341 (0.07%)

Female

N (%)

341 (0.07%)

\<=60

Male

N (%)

341 (0.07%)

Female

N (%)

341 (0.07%)

1984-08-01 to 1984-08-31

overall

overall

N (%)

682 (0.14%)

\<=60

overall

N (%)

682 (0.14%)

overall

Male

N (%)

341 (0.07%)

Female

N (%)

341 (0.07%)

\<=60

Male

N (%)

341 (0.07%)

Female

N (%)

341 (0.07%)

1984-09-01 to 1984-09-30

overall

overall

N (%)

660 (0.13%)

\<=60

overall

N (%)

660 (0.13%)

overall

Male

N (%)

330 (0.07%)

Female

N (%)

330 (0.07%)

\<=60

Male

N (%)

330 (0.07%)

Female

N (%)

330 (0.07%)

1984-10-01 to 1984-10-31

overall

overall

N (%)

682 (0.14%)

\<=60

overall

N (%)

682 (0.14%)

overall

Male

N (%)

341 (0.07%)

Female

N (%)

341 (0.07%)

\<=60

Male

N (%)

341 (0.07%)

Female

N (%)

341 (0.07%)

1984-11-01 to 1984-11-30

overall

overall

N (%)

660 (0.13%)

\<=60

overall

N (%)

660 (0.13%)

overall

Male

N (%)

330 (0.07%)

Female

N (%)

330 (0.07%)

\<=60

Male

N (%)

330 (0.07%)

Female

N (%)

330 (0.07%)

1984-12-01 to 1984-12-31

overall

overall

N (%)

682 (0.14%)

\<=60

overall

N (%)

682 (0.14%)

overall

Male

N (%)

341 (0.07%)

Female

N (%)

341 (0.07%)

\<=60

Male

N (%)

341 (0.07%)

Female

N (%)

341 (0.07%)

1985-01-01 to 1985-01-31

overall

overall

N (%)

682 (0.14%)

\<=60

overall

N (%)

682 (0.14%)

overall

Male

N (%)

341 (0.07%)

Female

N (%)

341 (0.07%)

\<=60

Male

N (%)

341 (0.07%)

Female

N (%)

341 (0.07%)

1985-02-01 to 1985-02-28

overall

overall

N (%)

616 (0.12%)

\<=60

overall

N (%)

616 (0.12%)

overall

Male

N (%)

308 (0.06%)

Female

N (%)

308 (0.06%)

\<=60

Male

N (%)

308 (0.06%)

Female

N (%)

308 (0.06%)

1985-03-01 to 1985-03-31

overall

overall

N (%)

682 (0.14%)

\<=60

overall

N (%)

682 (0.14%)

overall

Male

N (%)

341 (0.07%)

Female

N (%)

341 (0.07%)

\<=60

Male

N (%)

341 (0.07%)

Female

N (%)

341 (0.07%)

1985-04-01 to 1985-04-30

overall

overall

N (%)

660 (0.13%)

\<=60

overall

N (%)

660 (0.13%)

overall

Male

N (%)

330 (0.07%)

Female

N (%)

330 (0.07%)

\<=60

Male

N (%)

330 (0.07%)

Female

N (%)

330 (0.07%)

1985-05-01 to 1985-05-31

overall

overall

N (%)

682 (0.14%)

\<=60

overall

N (%)

682 (0.14%)

overall

Male

N (%)

341 (0.07%)

Female

N (%)

341 (0.07%)

\<=60

Male

N (%)

341 (0.07%)

Female

N (%)

341 (0.07%)

1985-06-01 to 1985-06-30

overall

overall

N (%)

660 (0.13%)

\<=60

overall

N (%)

660 (0.13%)

overall

Male

N (%)

330 (0.07%)

Female

N (%)

330 (0.07%)

\<=60

Male

N (%)

330 (0.07%)

Female

N (%)

330 (0.07%)

1985-07-01 to 1985-07-31

overall

overall

N (%)

682 (0.14%)

\<=60

overall

N (%)

682 (0.14%)

overall

Male

N (%)

341 (0.07%)

Female

N (%)

341 (0.07%)

\<=60

Male

N (%)

341 (0.07%)

Female

N (%)

341 (0.07%)

1985-08-01 to 1985-08-31

overall

overall

N (%)

682 (0.14%)

\<=60

overall

N (%)

682 (0.14%)

overall

Male

N (%)

341 (0.07%)

Female

N (%)

341 (0.07%)

\<=60

Male

N (%)

341 (0.07%)

Female

N (%)

341 (0.07%)

1985-09-01 to 1985-09-30

overall

overall

N (%)

660 (0.13%)

\<=60

overall

N (%)

660 (0.13%)

overall

Male

N (%)

330 (0.07%)

Female

N (%)

330 (0.07%)

\<=60

Male

N (%)

330 (0.07%)

Female

N (%)

330 (0.07%)

1985-10-01 to 1985-10-31

overall

overall

N (%)

661 (0.13%)

\<=60

overall

N (%)

661 (0.13%)

overall

Male

N (%)

320 (0.06%)

Female

N (%)

341 (0.07%)

\<=60

Male

N (%)

320 (0.06%)

Female

N (%)

341 (0.07%)

1985-11-01 to 1985-11-30

overall

overall

N (%)

630 (0.13%)

\<=60

overall

N (%)

630 (0.13%)

overall

Male

N (%)

300 (0.06%)

Female

N (%)

330 (0.07%)

\<=60

Male

N (%)

300 (0.06%)

Female

N (%)

330 (0.07%)

1985-12-01 to 1985-12-31

overall

overall

N (%)

651 (0.13%)

\<=60

overall

N (%)

651 (0.13%)

overall

Male

N (%)

310 (0.06%)

Female

N (%)

341 (0.07%)

\<=60

Male

N (%)

310 (0.06%)

Female

N (%)

341 (0.07%)

1986-01-01 to 1986-01-31

overall

overall

N (%)

651 (0.13%)

\<=60

overall

N (%)

651 (0.13%)

overall

Male

N (%)

310 (0.06%)

Female

N (%)

341 (0.07%)

\<=60

Male

N (%)

310 (0.06%)

Female

N (%)

341 (0.07%)

1986-02-01 to 1986-02-28

overall

overall

N (%)

588 (0.12%)

\<=60

overall

N (%)

588 (0.12%)

overall

Male

N (%)

280 (0.06%)

Female

N (%)

308 (0.06%)

\<=60

Male

N (%)

280 (0.06%)

Female

N (%)

308 (0.06%)

1986-03-01 to 1986-03-31

overall

overall

N (%)

651 (0.13%)

\<=60

overall

N (%)

651 (0.13%)

overall

Male

N (%)

310 (0.06%)

Female

N (%)

341 (0.07%)

\<=60

Male

N (%)

310 (0.06%)

Female

N (%)

341 (0.07%)

1986-04-01 to 1986-04-30

overall

overall

N (%)

630 (0.13%)

\<=60

overall

N (%)

630 (0.13%)

overall

Male

N (%)

300 (0.06%)

Female

N (%)

330 (0.07%)

\<=60

Male

N (%)

300 (0.06%)

Female

N (%)

330 (0.07%)

1986-05-01 to 1986-05-31

overall

overall

N (%)

651 (0.13%)

\<=60

overall

N (%)

651 (0.13%)

overall

Male

N (%)

310 (0.06%)

Female

N (%)

341 (0.07%)

\<=60

Male

N (%)

310 (0.06%)

Female

N (%)

341 (0.07%)

1986-06-01 to 1986-06-30

overall

overall

N (%)

630 (0.13%)

\<=60

overall

N (%)

630 (0.13%)

overall

Male

N (%)

300 (0.06%)

Female

N (%)

330 (0.07%)

\<=60

Male

N (%)

300 (0.06%)

Female

N (%)

330 (0.07%)

1986-07-01 to 1986-07-31

overall

overall

N (%)

651 (0.13%)

\<=60

overall

N (%)

651 (0.13%)

overall

Male

N (%)

310 (0.06%)

Female

N (%)

341 (0.07%)

\<=60

Male

N (%)

310 (0.06%)

Female

N (%)

341 (0.07%)

1986-08-01 to 1986-08-31

overall

overall

N (%)

651 (0.13%)

\<=60

overall

N (%)

651 (0.13%)

overall

Male

N (%)

310 (0.06%)

Female

N (%)

341 (0.07%)

\<=60

Male

N (%)

310 (0.06%)

Female

N (%)

341 (0.07%)

1986-09-01 to 1986-09-30

overall

overall

N (%)

630 (0.13%)

\<=60

overall

N (%)

630 (0.13%)

overall

Male

N (%)

300 (0.06%)

Female

N (%)

330 (0.07%)

\<=60

Male

N (%)

300 (0.06%)

Female

N (%)

330 (0.07%)

1986-10-01 to 1986-10-31

overall

overall

N (%)

651 (0.13%)

\<=60

overall

N (%)

651 (0.13%)

overall

Male

N (%)

310 (0.06%)

Female

N (%)

341 (0.07%)

\<=60

Male

N (%)

310 (0.06%)

Female

N (%)

341 (0.07%)

1986-11-01 to 1986-11-30

overall

overall

N (%)

632 (0.13%)

\<=60

overall

N (%)

632 (0.13%)

overall

Male

N (%)

300 (0.06%)

Female

N (%)

332 (0.07%)

\<=60

Male

N (%)

300 (0.06%)

Female

N (%)

332 (0.07%)

1986-12-01 to 1986-12-31

overall

overall

N (%)

682 (0.14%)

\<=60

overall

N (%)

682 (0.14%)

overall

Male

N (%)

310 (0.06%)

Female

N (%)

372 (0.08%)

\<=60

Male

N (%)

310 (0.06%)

Female

N (%)

372 (0.08%)

1987-01-01 to 1987-01-31

overall

overall

N (%)

696 (0.14%)

\<=60

overall

N (%)

696 (0.14%)

overall

Male

N (%)

310 (0.06%)

Female

N (%)

386 (0.08%)

\<=60

Male

N (%)

310 (0.06%)

Female

N (%)

386 (0.08%)

1987-02-01 to 1987-02-28

overall

overall

N (%)

644 (0.13%)

\<=60

overall

N (%)

644 (0.13%)

overall

Male

N (%)

280 (0.06%)

Female

N (%)

364 (0.07%)

\<=60

Male

N (%)

280 (0.06%)

Female

N (%)

364 (0.07%)

1987-03-01 to 1987-03-31

overall

overall

N (%)

713 (0.14%)

\<=60

overall

N (%)

713 (0.14%)

overall

Male

N (%)

310 (0.06%)

Female

N (%)

403 (0.08%)

\<=60

Male

N (%)

310 (0.06%)

Female

N (%)

403 (0.08%)

1987-04-01 to 1987-04-30

overall

overall

N (%)

690 (0.14%)

\<=60

overall

N (%)

690 (0.14%)

overall

Male

N (%)

300 (0.06%)

Female

N (%)

390 (0.08%)

\<=60

Male

N (%)

300 (0.06%)

Female

N (%)

390 (0.08%)

1987-05-01 to 1987-05-31

overall

overall

N (%)

713 (0.14%)

\<=60

overall

N (%)

713 (0.14%)

overall

Male

N (%)

310 (0.06%)

Female

N (%)

403 (0.08%)

\<=60

Male

N (%)

310 (0.06%)

Female

N (%)

403 (0.08%)

1987-06-01 to 1987-06-30

overall

overall

N (%)

690 (0.14%)

\<=60

overall

N (%)

690 (0.14%)

overall

Male

N (%)

300 (0.06%)

Female

N (%)

390 (0.08%)

\<=60

Male

N (%)

300 (0.06%)

Female

N (%)

390 (0.08%)

1987-07-01 to 1987-07-31

overall

overall

N (%)

721 (0.15%)

\<=60

overall

N (%)

721 (0.15%)

overall

Male

N (%)

318 (0.06%)

Female

N (%)

403 (0.08%)

\<=60

Male

N (%)

318 (0.06%)

Female

N (%)

403 (0.08%)

1987-08-01 to 1987-08-31

overall

overall

N (%)

744 (0.15%)

\<=60

overall

N (%)

744 (0.15%)

overall

Male

N (%)

341 (0.07%)

Female

N (%)

403 (0.08%)

\<=60

Male

N (%)

341 (0.07%)

Female

N (%)

403 (0.08%)

1987-09-01 to 1987-09-30

overall

overall

N (%)

720 (0.15%)

\<=60

overall

N (%)

720 (0.15%)

overall

Male

N (%)

330 (0.07%)

Female

N (%)

390 (0.08%)

\<=60

Male

N (%)

330 (0.07%)

Female

N (%)

390 (0.08%)

1987-10-01 to 1987-10-31

overall

overall

N (%)

744 (0.15%)

\<=60

overall

N (%)

744 (0.15%)

overall

Male

N (%)

341 (0.07%)

Female

N (%)

403 (0.08%)

\<=60

Male

N (%)

341 (0.07%)

Female

N (%)

403 (0.08%)

1987-11-01 to 1987-11-30

overall

overall

N (%)

720 (0.15%)

\<=60

overall

N (%)

720 (0.15%)

overall

Male

N (%)

330 (0.07%)

Female

N (%)

390 (0.08%)

\<=60

Male

N (%)

330 (0.07%)

Female

N (%)

390 (0.08%)

1987-12-01 to 1987-12-31

overall

overall

N (%)

744 (0.15%)

\<=60

overall

N (%)

744 (0.15%)

overall

Male

N (%)

341 (0.07%)

Female

N (%)

403 (0.08%)

\<=60

Male

N (%)

341 (0.07%)

Female

N (%)

403 (0.08%)

1988-01-01 to 1988-01-31

overall

overall

N (%)

744 (0.15%)

\<=60

overall

N (%)

744 (0.15%)

overall

Male

N (%)

341 (0.07%)

Female

N (%)

403 (0.08%)

\<=60

Male

N (%)

341 (0.07%)

Female

N (%)

403 (0.08%)

1988-02-01 to 1988-02-29

overall

overall

N (%)

696 (0.14%)

\<=60

overall

N (%)

696 (0.14%)

overall

Male

N (%)

319 (0.06%)

Female

N (%)

377 (0.08%)

\<=60

Male

N (%)

319 (0.06%)

Female

N (%)

377 (0.08%)

1988-03-01 to 1988-03-31

overall

overall

N (%)

744 (0.15%)

\<=60

overall

N (%)

744 (0.15%)

overall

Male

N (%)

341 (0.07%)

Female

N (%)

403 (0.08%)

\<=60

Male

N (%)

341 (0.07%)

Female

N (%)

403 (0.08%)

1988-04-01 to 1988-04-30

overall

overall

N (%)

720 (0.15%)

\<=60

overall

N (%)

720 (0.15%)

overall

Male

N (%)

330 (0.07%)

Female

N (%)

390 (0.08%)

\<=60

Male

N (%)

330 (0.07%)

Female

N (%)

390 (0.08%)

1988-05-01 to 1988-05-31

overall

overall

N (%)

744 (0.15%)

\<=60

overall

N (%)

744 (0.15%)

overall

Male

N (%)

341 (0.07%)

Female

N (%)

403 (0.08%)

\<=60

Male

N (%)

341 (0.07%)

Female

N (%)

403 (0.08%)

1988-06-01 to 1988-06-30

overall

overall

N (%)

720 (0.15%)

\<=60

overall

N (%)

720 (0.15%)

overall

Male

N (%)

330 (0.07%)

Female

N (%)

390 (0.08%)

\<=60

Male

N (%)

330 (0.07%)

Female

N (%)

390 (0.08%)

1988-07-01 to 1988-07-31

overall

overall

N (%)

760 (0.15%)

\<=60

overall

N (%)

760 (0.15%)

overall

Male

N (%)

341 (0.07%)

Female

N (%)

419 (0.08%)

\<=60

Male

N (%)

341 (0.07%)

Female

N (%)

419 (0.08%)

1988-08-01 to 1988-08-31

overall

overall

N (%)

775 (0.16%)

\<=60

overall

N (%)

775 (0.16%)

overall

Male

N (%)

341 (0.07%)

Female

N (%)

434 (0.09%)

\<=60

Male

N (%)

341 (0.07%)

Female

N (%)

434 (0.09%)

1988-09-01 to 1988-09-30

overall

overall

N (%)

750 (0.15%)

\<=60

overall

N (%)

750 (0.15%)

overall

Male

N (%)

330 (0.07%)

Female

N (%)

420 (0.09%)

\<=60

Male

N (%)

330 (0.07%)

Female

N (%)

420 (0.09%)

1988-10-01 to 1988-10-31

overall

overall

N (%)

775 (0.16%)

\<=60

overall

N (%)

775 (0.16%)

overall

Male

N (%)

341 (0.07%)

Female

N (%)

434 (0.09%)

\<=60

Male

N (%)

341 (0.07%)

Female

N (%)

434 (0.09%)

1988-11-01 to 1988-11-30

overall

overall

N (%)

750 (0.15%)

\<=60

overall

N (%)

750 (0.15%)

overall

Male

N (%)

330 (0.07%)

Female

N (%)

420 (0.09%)

\<=60

Male

N (%)

330 (0.07%)

Female

N (%)

420 (0.09%)

1988-12-01 to 1988-12-31

overall

overall

N (%)

775 (0.16%)

\<=60

overall

N (%)

775 (0.16%)

overall

Male

N (%)

341 (0.07%)

Female

N (%)

434 (0.09%)

\<=60

Male

N (%)

341 (0.07%)

Female

N (%)

434 (0.09%)

1989-01-01 to 1989-01-31

overall

overall

N (%)

775 (0.16%)

\<=60

overall

N (%)

775 (0.16%)

overall

Male

N (%)

341 (0.07%)

Female

N (%)

434 (0.09%)

\<=60

Male

N (%)

341 (0.07%)

Female

N (%)

434 (0.09%)

1989-02-01 to 1989-02-28

overall

overall

N (%)

700 (0.14%)

\<=60

overall

N (%)

700 (0.14%)

overall

Male

N (%)

308 (0.06%)

Female

N (%)

392 (0.08%)

\<=60

Male

N (%)

308 (0.06%)

Female

N (%)

392 (0.08%)

1989-03-01 to 1989-03-31

overall

overall

N (%)

801 (0.16%)

\<=60

overall

N (%)

801 (0.16%)

overall

Male

N (%)

341 (0.07%)

Female

N (%)

460 (0.09%)

\<=60

Male

N (%)

341 (0.07%)

Female

N (%)

460 (0.09%)

1989-04-01 to 1989-04-30

overall

overall

N (%)

780 (0.16%)

\<=60

overall

N (%)

780 (0.16%)

overall

Male

N (%)

330 (0.07%)

Female

N (%)

450 (0.09%)

\<=60

Male

N (%)

330 (0.07%)

Female

N (%)

450 (0.09%)

1989-05-01 to 1989-05-31

overall

overall

N (%)

809 (0.16%)

\<=60

overall

N (%)

809 (0.16%)

overall

Male

N (%)

344 (0.07%)

Female

N (%)

465 (0.09%)

\<=60

Male

N (%)

344 (0.07%)

Female

N (%)

465 (0.09%)

1989-06-01 to 1989-06-30

overall

overall

N (%)

810 (0.16%)

\<=60

overall

N (%)

810 (0.16%)

overall

Male

N (%)

360 (0.07%)

Female

N (%)

450 (0.09%)

\<=60

Male

N (%)

360 (0.07%)

Female

N (%)

450 (0.09%)

1989-07-01 to 1989-07-31

overall

overall

N (%)

837 (0.17%)

\<=60

overall

N (%)

837 (0.17%)

overall

Male

N (%)

372 (0.08%)

Female

N (%)

465 (0.09%)

\<=60

Male

N (%)

372 (0.08%)

Female

N (%)

465 (0.09%)

1989-08-01 to 1989-08-31

overall

overall

N (%)

837 (0.17%)

\<=60

overall

N (%)

837 (0.17%)

overall

Male

N (%)

372 (0.08%)

Female

N (%)

465 (0.09%)

\<=60

Male

N (%)

372 (0.08%)

Female

N (%)

465 (0.09%)

1989-09-01 to 1989-09-30

overall

overall

N (%)

810 (0.16%)

\<=60

overall

N (%)

810 (0.16%)

overall

Male

N (%)

360 (0.07%)

Female

N (%)

450 (0.09%)

\<=60

Male

N (%)

360 (0.07%)

Female

N (%)

450 (0.09%)

1989-10-01 to 1989-10-31

overall

overall

N (%)

837 (0.17%)

\<=60

overall

N (%)

837 (0.17%)

overall

Male

N (%)

372 (0.08%)

Female

N (%)

465 (0.09%)

\<=60

Male

N (%)

372 (0.08%)

Female

N (%)

465 (0.09%)

1989-11-01 to 1989-11-30

overall

overall

N (%)

810 (0.16%)

\<=60

overall

N (%)

810 (0.16%)

overall

Male

N (%)

360 (0.07%)

Female

N (%)

450 (0.09%)

\<=60

Male

N (%)

360 (0.07%)

Female

N (%)

450 (0.09%)

1989-12-01 to 1989-12-31

overall

overall

N (%)

837 (0.17%)

\<=60

overall

N (%)

837 (0.17%)

overall

Male

N (%)

372 (0.08%)

Female

N (%)

465 (0.09%)

\<=60

Male

N (%)

372 (0.08%)

Female

N (%)

465 (0.09%)

1990-01-01 to 1990-01-31

overall

overall

N (%)

813 (0.16%)

\<=60

overall

N (%)

813 (0.16%)

overall

Male

N (%)

348 (0.07%)

Female

N (%)

465 (0.09%)

\<=60

Male

N (%)

348 (0.07%)

Female

N (%)

465 (0.09%)

1990-02-01 to 1990-02-28

overall

overall

N (%)

728 (0.15%)

\<=60

overall

N (%)

728 (0.15%)

overall

Male

N (%)

308 (0.06%)

Female

N (%)

420 (0.09%)

\<=60

Male

N (%)

308 (0.06%)

Female

N (%)

420 (0.09%)

1990-03-01 to 1990-03-31

overall

overall

N (%)

806 (0.16%)

\<=60

overall

N (%)

806 (0.16%)

overall

Male

N (%)

341 (0.07%)

Female

N (%)

465 (0.09%)

\<=60

Male

N (%)

341 (0.07%)

Female

N (%)

465 (0.09%)

1990-04-01 to 1990-04-30

overall

overall

N (%)

780 (0.16%)

\<=60

overall

N (%)

780 (0.16%)

overall

Male

N (%)

330 (0.07%)

Female

N (%)

450 (0.09%)

\<=60

Male

N (%)

330 (0.07%)

Female

N (%)

450 (0.09%)

1990-05-01 to 1990-05-31

overall

overall

N (%)

806 (0.16%)

\<=60

overall

N (%)

806 (0.16%)

overall

Male

N (%)

341 (0.07%)

Female

N (%)

465 (0.09%)

\<=60

Male

N (%)

341 (0.07%)

Female

N (%)

465 (0.09%)

1990-06-01 to 1990-06-30

overall

overall

N (%)

780 (0.16%)

\<=60

overall

N (%)

780 (0.16%)

overall

Male

N (%)

330 (0.07%)

Female

N (%)

450 (0.09%)

\<=60

Male

N (%)

330 (0.07%)

Female

N (%)

450 (0.09%)

1990-07-01 to 1990-07-31

overall

overall

N (%)

806 (0.16%)

\<=60

overall

N (%)

806 (0.16%)

overall

Male

N (%)

341 (0.07%)

Female

N (%)

465 (0.09%)

\<=60

Male

N (%)

341 (0.07%)

Female

N (%)

465 (0.09%)

1990-08-01 to 1990-08-31

overall

overall

N (%)

806 (0.16%)

\<=60

overall

N (%)

806 (0.16%)

overall

Male

N (%)

341 (0.07%)

Female

N (%)

465 (0.09%)

\<=60

Male

N (%)

341 (0.07%)

Female

N (%)

465 (0.09%)

1990-09-01 to 1990-09-30

overall

overall

N (%)

780 (0.16%)

\<=60

overall

N (%)

780 (0.16%)

overall

Male

N (%)

330 (0.07%)

Female

N (%)

450 (0.09%)

\<=60

Male

N (%)

330 (0.07%)

Female

N (%)

450 (0.09%)

1990-10-01 to 1990-10-31

overall

overall

N (%)

806 (0.16%)

\<=60

overall

N (%)

806 (0.16%)

overall

Male

N (%)

341 (0.07%)

Female

N (%)

465 (0.09%)

\<=60

Male

N (%)

341 (0.07%)

Female

N (%)

465 (0.09%)

1990-11-01 to 1990-11-30

overall

overall

N (%)

780 (0.16%)

\<=60

overall

N (%)

780 (0.16%)

overall

Male

N (%)

330 (0.07%)

Female

N (%)

450 (0.09%)

\<=60

Male

N (%)

330 (0.07%)

Female

N (%)

450 (0.09%)

1990-12-01 to 1990-12-31

overall

overall

N (%)

806 (0.16%)

\<=60

overall

N (%)

806 (0.16%)

overall

Male

N (%)

341 (0.07%)

Female

N (%)

465 (0.09%)

\<=60

Male

N (%)

341 (0.07%)

Female

N (%)

465 (0.09%)

1991-01-01 to 1991-01-31

overall

overall

N (%)

834 (0.17%)

\<=60

overall

N (%)

834 (0.17%)

overall

Male

N (%)

369 (0.07%)

Female

N (%)

465 (0.09%)

\<=60

Male

N (%)

369 (0.07%)

Female

N (%)

465 (0.09%)

1991-02-01 to 1991-02-28

overall

overall

N (%)

756 (0.15%)

\<=60

overall

N (%)

756 (0.15%)

overall

Male

N (%)

336 (0.07%)

Female

N (%)

420 (0.09%)

\<=60

Male

N (%)

336 (0.07%)

Female

N (%)

420 (0.09%)

1991-03-01 to 1991-03-31

overall

overall

N (%)

837 (0.17%)

\<=60

overall

N (%)

837 (0.17%)

overall

Male

N (%)

372 (0.08%)

Female

N (%)

465 (0.09%)

\<=60

Male

N (%)

372 (0.08%)

Female

N (%)

465 (0.09%)

1991-04-01 to 1991-04-30

overall

overall

N (%)

810 (0.16%)

\<=60

overall

N (%)

810 (0.16%)

overall

Male

N (%)

360 (0.07%)

Female

N (%)

450 (0.09%)

\<=60

Male

N (%)

360 (0.07%)

Female

N (%)

450 (0.09%)

1991-05-01 to 1991-05-31

overall

overall

N (%)

837 (0.17%)

\<=60

overall

N (%)

837 (0.17%)

overall

Male

N (%)

372 (0.08%)

Female

N (%)

465 (0.09%)

\<=60

Male

N (%)

372 (0.08%)

Female

N (%)

465 (0.09%)

1991-06-01 to 1991-06-30

overall

overall

N (%)

822 (0.17%)

\<=60

overall

N (%)

822 (0.17%)

overall

Male

N (%)

372 (0.08%)

Female

N (%)

450 (0.09%)

\<=60

Male

N (%)

372 (0.08%)

Female

N (%)

450 (0.09%)

1991-07-01 to 1991-07-31

overall

overall

N (%)

868 (0.18%)

\<=60

overall

N (%)

868 (0.18%)

overall

Male

N (%)

403 (0.08%)

Female

N (%)

465 (0.09%)

\<=60

Male

N (%)

403 (0.08%)

Female

N (%)

465 (0.09%)

1991-08-01 to 1991-08-31

overall

overall

N (%)

868 (0.18%)

\<=60

overall

N (%)

868 (0.18%)

overall

Male

N (%)

403 (0.08%)

Female

N (%)

465 (0.09%)

\<=60

Male

N (%)

403 (0.08%)

Female

N (%)

465 (0.09%)

1991-09-01 to 1991-09-30

overall

overall

N (%)

840 (0.17%)

\<=60

overall

N (%)

840 (0.17%)

overall

Male

N (%)

390 (0.08%)

Female

N (%)

450 (0.09%)

\<=60

Male

N (%)

390 (0.08%)

Female

N (%)

450 (0.09%)

1991-10-01 to 1991-10-31

overall

overall

N (%)

868 (0.18%)

\<=60

overall

N (%)

868 (0.18%)

overall

Male

N (%)

403 (0.08%)

Female

N (%)

465 (0.09%)

\<=60

Male

N (%)

403 (0.08%)

Female

N (%)

465 (0.09%)

1991-11-01 to 1991-11-30

overall

overall

N (%)

840 (0.17%)

\<=60

overall

N (%)

840 (0.17%)

overall

Male

N (%)

390 (0.08%)

Female

N (%)

450 (0.09%)

\<=60

Male

N (%)

390 (0.08%)

Female

N (%)

450 (0.09%)

1991-12-01 to 1991-12-31

overall

overall

N (%)

922 (0.19%)

\<=60

overall

N (%)

922 (0.19%)

overall

Male

N (%)

457 (0.09%)

Female

N (%)

465 (0.09%)

\<=60

Male

N (%)

457 (0.09%)

Female

N (%)

465 (0.09%)

1992-01-01 to 1992-01-31

overall

overall

N (%)

930 (0.19%)

\<=60

overall

N (%)

930 (0.19%)

overall

Male

N (%)

465 (0.09%)

Female

N (%)

465 (0.09%)

\<=60

Male

N (%)

465 (0.09%)

Female

N (%)

465 (0.09%)

1992-02-01 to 1992-02-29

overall

overall

N (%)

870 (0.18%)

\<=60

overall

N (%)

870 (0.18%)

overall

Male

N (%)

435 (0.09%)

Female

N (%)

435 (0.09%)

\<=60

Male

N (%)

435 (0.09%)

Female

N (%)

435 (0.09%)

1992-03-01 to 1992-03-31

overall

overall

N (%)

930 (0.19%)

\<=60

overall

N (%)

930 (0.19%)

overall

Male

N (%)

465 (0.09%)

Female

N (%)

465 (0.09%)

\<=60

Male

N (%)

465 (0.09%)

Female

N (%)

465 (0.09%)

1992-04-01 to 1992-04-30

overall

overall

N (%)

900 (0.18%)

\<=60

overall

N (%)

900 (0.18%)

overall

Male

N (%)

450 (0.09%)

Female

N (%)

450 (0.09%)

\<=60

Male

N (%)

450 (0.09%)

Female

N (%)

450 (0.09%)

1992-05-01 to 1992-05-31

overall

overall

N (%)

942 (0.19%)

\<=60

overall

N (%)

942 (0.19%)

overall

Male

N (%)

465 (0.09%)

Female

N (%)

477 (0.10%)

\<=60

Male

N (%)

465 (0.09%)

Female

N (%)

477 (0.10%)

1992-06-01 to 1992-06-30

overall

overall

N (%)

951 (0.19%)

\<=60

overall

N (%)

951 (0.19%)

overall

Male

N (%)

450 (0.09%)

Female

N (%)

501 (0.10%)

\<=60

Male

N (%)

450 (0.09%)

Female

N (%)

501 (0.10%)

1992-07-01 to 1992-07-31

overall

overall

N (%)

992 (0.20%)

\<=60

overall

N (%)

992 (0.20%)

overall

Male

N (%)

465 (0.09%)

Female

N (%)

527 (0.11%)

\<=60

Male

N (%)

465 (0.09%)

Female

N (%)

527 (0.11%)

1992-08-01 to 1992-08-31

overall

overall

N (%)

992 (0.20%)

\<=60

overall

N (%)

992 (0.20%)

overall

Male

N (%)

465 (0.09%)

Female

N (%)

527 (0.11%)

\<=60

Male

N (%)

465 (0.09%)

Female

N (%)

527 (0.11%)

1992-09-01 to 1992-09-30

overall

overall

N (%)

960 (0.19%)

\<=60

overall

N (%)

960 (0.19%)

overall

Male

N (%)

450 (0.09%)

Female

N (%)

510 (0.10%)

\<=60

Male

N (%)

450 (0.09%)

Female

N (%)

510 (0.10%)

1992-10-01 to 1992-10-31

overall

overall

N (%)

993 (0.20%)

\<=60

overall

N (%)

993 (0.20%)

overall

Male

N (%)

465 (0.09%)

Female

N (%)

528 (0.11%)

\<=60

Male

N (%)

465 (0.09%)

Female

N (%)

528 (0.11%)

1992-11-01 to 1992-11-30

overall

overall

N (%)

990 (0.20%)

\<=60

overall

N (%)

990 (0.20%)

overall

Male

N (%)

450 (0.09%)

Female

N (%)

540 (0.11%)

\<=60

Male

N (%)

450 (0.09%)

Female

N (%)

540 (0.11%)

1992-12-01 to 1992-12-31

overall

overall

N (%)

1,023 (0.21%)

\<=60

overall

N (%)

1,023 (0.21%)

overall

Male

N (%)

465 (0.09%)

Female

N (%)

558 (0.11%)

\<=60

Male

N (%)

465 (0.09%)

Female

N (%)

558 (0.11%)

1993-01-01 to 1993-01-31

overall

overall

N (%)

1,011 (0.21%)

\<=60

overall

N (%)

1,011 (0.21%)

overall

Male

N (%)

453 (0.09%)

Female

N (%)

558 (0.11%)

\<=60

Male

N (%)

453 (0.09%)

Female

N (%)

558 (0.11%)

1993-02-01 to 1993-02-28

overall

overall

N (%)

896 (0.18%)

\<=60

overall

N (%)

896 (0.18%)

overall

Male

N (%)

392 (0.08%)

Female

N (%)

504 (0.10%)

\<=60

Male

N (%)

392 (0.08%)

Female

N (%)

504 (0.10%)

1993-03-01 to 1993-03-31

overall

overall

N (%)

992 (0.20%)

\<=60

overall

N (%)

992 (0.20%)

overall

Male

N (%)

434 (0.09%)

Female

N (%)

558 (0.11%)

\<=60

Male

N (%)

434 (0.09%)

Female

N (%)

558 (0.11%)

1993-04-01 to 1993-04-30

overall

overall

N (%)

960 (0.19%)

\<=60

overall

N (%)

960 (0.19%)

overall

Male

N (%)

420 (0.09%)

Female

N (%)

540 (0.11%)

\<=60

Male

N (%)

420 (0.09%)

Female

N (%)

540 (0.11%)

1993-05-01 to 1993-05-31

overall

overall

N (%)

992 (0.20%)

\<=60

overall

N (%)

992 (0.20%)

overall

Male

N (%)

434 (0.09%)

Female

N (%)

558 (0.11%)

\<=60

Male

N (%)

434 (0.09%)

Female

N (%)

558 (0.11%)

1993-06-01 to 1993-06-30

overall

overall

N (%)

960 (0.19%)

\<=60

overall

N (%)

960 (0.19%)

overall

Male

N (%)

420 (0.09%)

Female

N (%)

540 (0.11%)

\<=60

Male

N (%)

420 (0.09%)

Female

N (%)

540 (0.11%)

1993-07-01 to 1993-07-31

overall

overall

N (%)

992 (0.20%)

\<=60

overall

N (%)

992 (0.20%)

overall

Male

N (%)

434 (0.09%)

Female

N (%)

558 (0.11%)

\<=60

Male

N (%)

434 (0.09%)

Female

N (%)

558 (0.11%)

1993-08-01 to 1993-08-31

overall

overall

N (%)

992 (0.20%)

\<=60

overall

N (%)

992 (0.20%)

overall

Male

N (%)

434 (0.09%)

Female

N (%)

558 (0.11%)

\<=60

Male

N (%)

434 (0.09%)

Female

N (%)

558 (0.11%)

1993-09-01 to 1993-09-30

overall

overall

N (%)

985 (0.20%)

\<=60

overall

N (%)

985 (0.20%)

overall

Male

N (%)

445 (0.09%)

Female

N (%)

540 (0.11%)

\<=60

Male

N (%)

445 (0.09%)

Female

N (%)

540 (0.11%)

1993-10-01 to 1993-10-31

overall

overall

N (%)

1,023 (0.21%)

\<=60

overall

N (%)

1,023 (0.21%)

overall

Male

N (%)

465 (0.09%)

Female

N (%)

558 (0.11%)

\<=60

Male

N (%)

465 (0.09%)

Female

N (%)

558 (0.11%)

1993-11-01 to 1993-11-30

overall

overall

N (%)

990 (0.20%)

\<=60

overall

N (%)

990 (0.20%)

overall

Male

N (%)

450 (0.09%)

Female

N (%)

540 (0.11%)

\<=60

Male

N (%)

450 (0.09%)

Female

N (%)

540 (0.11%)

1993-12-01 to 1993-12-31

overall

overall

N (%)

1,017 (0.21%)

\<=60

overall

N (%)

1,017 (0.21%)

overall

Male

N (%)

459 (0.09%)

Female

N (%)

558 (0.11%)

\<=60

Male

N (%)

459 (0.09%)

Female

N (%)

558 (0.11%)

1994-01-01 to 1994-01-31

overall

overall

N (%)

992 (0.20%)

\<=60

overall

N (%)

992 (0.20%)

overall

Male

N (%)

434 (0.09%)

Female

N (%)

558 (0.11%)

\<=60

Male

N (%)

434 (0.09%)

Female

N (%)

558 (0.11%)

1994-02-01 to 1994-02-28

overall

overall

N (%)

896 (0.18%)

\<=60

overall

N (%)

896 (0.18%)

overall

Male

N (%)

392 (0.08%)

Female

N (%)

504 (0.10%)

\<=60

Male

N (%)

392 (0.08%)

Female

N (%)

504 (0.10%)

1994-03-01 to 1994-03-31

overall

overall

N (%)

992 (0.20%)

\<=60

overall

N (%)

992 (0.20%)

overall

Male

N (%)

434 (0.09%)

Female

N (%)

558 (0.11%)

\<=60

Male

N (%)

434 (0.09%)

Female

N (%)

558 (0.11%)

1994-04-01 to 1994-04-30

overall

overall

N (%)

960 (0.19%)

\<=60

overall

N (%)

960 (0.19%)

overall

Male

N (%)

420 (0.09%)

Female

N (%)

540 (0.11%)

\<=60

Male

N (%)

420 (0.09%)

Female

N (%)

540 (0.11%)

1994-05-01 to 1994-05-31

overall

overall

N (%)

995 (0.20%)

\<=60

overall

N (%)

995 (0.20%)

overall

Male

N (%)

434 (0.09%)

Female

N (%)

561 (0.11%)

\<=60

Male

N (%)

434 (0.09%)

Female

N (%)

561 (0.11%)

1994-06-01 to 1994-06-30

overall

overall

N (%)

990 (0.20%)

\<=60

overall

N (%)

990 (0.20%)

overall

Male

N (%)

420 (0.09%)

Female

N (%)

570 (0.12%)

\<=60

Male

N (%)

420 (0.09%)

Female

N (%)

570 (0.12%)

1994-07-01 to 1994-07-31

overall

overall

N (%)

1,023 (0.21%)

\<=60

overall

N (%)

1,023 (0.21%)

overall

Male

N (%)

434 (0.09%)

Female

N (%)

589 (0.12%)

\<=60

Male

N (%)

434 (0.09%)

Female

N (%)

589 (0.12%)

1994-08-01 to 1994-08-31

overall

overall

N (%)

1,045 (0.21%)

\<=60

overall

N (%)

1,045 (0.21%)

overall

Male

N (%)

456 (0.09%)

Female

N (%)

589 (0.12%)

\<=60

Male

N (%)

456 (0.09%)

Female

N (%)

589 (0.12%)

1994-09-01 to 1994-09-30

overall

overall

N (%)

1,020 (0.21%)

\<=60

overall

N (%)

1,020 (0.21%)

overall

Male

N (%)

450 (0.09%)

Female

N (%)

570 (0.12%)

\<=60

Male

N (%)

450 (0.09%)

Female

N (%)

570 (0.12%)

1994-10-01 to 1994-10-31

overall

overall

N (%)

1,046 (0.21%)

\<=60

overall

N (%)

1,046 (0.21%)

overall

Male

N (%)

465 (0.09%)

Female

N (%)

581 (0.12%)

\<=60

Male

N (%)

465 (0.09%)

Female

N (%)

581 (0.12%)

1994-11-01 to 1994-11-30

overall

overall

N (%)

990 (0.20%)

\<=60

overall

N (%)

990 (0.20%)

overall

Male

N (%)

450 (0.09%)

Female

N (%)

540 (0.11%)

\<=60

Male

N (%)

450 (0.09%)

Female

N (%)

540 (0.11%)

1994-12-01 to 1994-12-31

overall

overall

N (%)

1,028 (0.21%)

\<=60

overall

N (%)

1,028 (0.21%)

overall

Male

N (%)

465 (0.09%)

Female

N (%)

563 (0.11%)

\<=60

Male

N (%)

465 (0.09%)

Female

N (%)

563 (0.11%)

1995-01-01 to 1995-01-31

overall

overall

N (%)

1,054 (0.21%)

\<=60

overall

N (%)

1,054 (0.21%)

overall

Male

N (%)

465 (0.09%)

Female

N (%)

589 (0.12%)

\<=60

Male

N (%)

465 (0.09%)

Female

N (%)

589 (0.12%)

1995-02-01 to 1995-02-28

overall

overall

N (%)

952 (0.19%)

\<=60

overall

N (%)

952 (0.19%)

overall

Male

N (%)

420 (0.09%)

Female

N (%)

532 (0.11%)

\<=60

Male

N (%)

420 (0.09%)

Female

N (%)

532 (0.11%)

1995-03-01 to 1995-03-31

overall

overall

N (%)

1,054 (0.21%)

\<=60

overall

N (%)

1,054 (0.21%)

overall

Male

N (%)

465 (0.09%)

Female

N (%)

589 (0.12%)

\<=60

Male

N (%)

465 (0.09%)

Female

N (%)

589 (0.12%)

1995-04-01 to 1995-04-30

overall

overall

N (%)

1,046 (0.21%)

\<=60

overall

N (%)

1,046 (0.21%)

overall

Male

N (%)

476 (0.10%)

Female

N (%)

570 (0.12%)

\<=60

Male

N (%)

476 (0.10%)

Female

N (%)

570 (0.12%)

1995-05-01 to 1995-05-31

overall

overall

N (%)

1,085 (0.22%)

\<=60

overall

N (%)

1,085 (0.22%)

overall

Male

N (%)

496 (0.10%)

Female

N (%)

589 (0.12%)

\<=60

Male

N (%)

496 (0.10%)

Female

N (%)

589 (0.12%)

1995-06-01 to 1995-06-30

overall

overall

N (%)

1,050 (0.21%)

\<=60

overall

N (%)

1,050 (0.21%)

overall

Male

N (%)

480 (0.10%)

Female

N (%)

570 (0.12%)

\<=60

Male

N (%)

480 (0.10%)

Female

N (%)

570 (0.12%)

1995-07-01 to 1995-07-31

overall

overall

N (%)

1,085 (0.22%)

\<=60

overall

N (%)

1,085 (0.22%)

overall

Male

N (%)

496 (0.10%)

Female

N (%)

589 (0.12%)

\<=60

Male

N (%)

496 (0.10%)

Female

N (%)

589 (0.12%)

1995-08-01 to 1995-08-31

overall

overall

N (%)

1,085 (0.22%)

\<=60

overall

N (%)

1,085 (0.22%)

overall

Male

N (%)

496 (0.10%)

Female

N (%)

589 (0.12%)

\<=60

Male

N (%)

496 (0.10%)

Female

N (%)

589 (0.12%)

1995-09-01 to 1995-09-30

overall

overall

N (%)

1,050 (0.21%)

\<=60

overall

N (%)

1,050 (0.21%)

overall

Male

N (%)

480 (0.10%)

Female

N (%)

570 (0.12%)

\<=60

Male

N (%)

480 (0.10%)

Female

N (%)

570 (0.12%)

1995-10-01 to 1995-10-31

overall

overall

N (%)

1,085 (0.22%)

\<=60

overall

N (%)

1,085 (0.22%)

overall

Male

N (%)

496 (0.10%)

Female

N (%)

589 (0.12%)

\<=60

Male

N (%)

496 (0.10%)

Female

N (%)

589 (0.12%)

1995-11-01 to 1995-11-30

overall

overall

N (%)

1,050 (0.21%)

\<=60

overall

N (%)

1,050 (0.21%)

overall

Male

N (%)

480 (0.10%)

Female

N (%)

570 (0.12%)

\<=60

Male

N (%)

480 (0.10%)

Female

N (%)

570 (0.12%)

1995-12-01 to 1995-12-31

overall

overall

N (%)

1,085 (0.22%)

\<=60

overall

N (%)

1,085 (0.22%)

overall

Male

N (%)

496 (0.10%)

Female

N (%)

589 (0.12%)

\<=60

Male

N (%)

496 (0.10%)

Female

N (%)

589 (0.12%)

1996-01-01 to 1996-01-31

overall

overall

N (%)

1,107 (0.22%)

\<=60

overall

N (%)

1,107 (0.22%)

overall

Male

N (%)

518 (0.11%)

Female

N (%)

589 (0.12%)

\<=60

Male

N (%)

518 (0.11%)

Female

N (%)

589 (0.12%)

1996-02-01 to 1996-02-29

overall

overall

N (%)

1,052 (0.21%)

\<=60

overall

N (%)

1,052 (0.21%)

overall

Male

N (%)

501 (0.10%)

Female

N (%)

551 (0.11%)

\<=60

Male

N (%)

501 (0.10%)

Female

N (%)

551 (0.11%)

1996-03-01 to 1996-03-31

overall

overall

N (%)

1,147 (0.23%)

\<=60

overall

N (%)

1,147 (0.23%)

overall

Male

N (%)

558 (0.11%)

Female

N (%)

589 (0.12%)

\<=60

Male

N (%)

558 (0.11%)

Female

N (%)

589 (0.12%)

1996-04-01 to 1996-04-30

overall

overall

N (%)

1,110 (0.23%)

\<=60

overall

N (%)

1,110 (0.23%)

overall

Male

N (%)

540 (0.11%)

Female

N (%)

570 (0.12%)

\<=60

Male

N (%)

540 (0.11%)

Female

N (%)

570 (0.12%)

1996-05-01 to 1996-05-31

overall

overall

N (%)

1,155 (0.23%)

\<=60

overall

N (%)

1,155 (0.23%)

overall

Male

N (%)

566 (0.11%)

Female

N (%)

589 (0.12%)

\<=60

Male

N (%)

566 (0.11%)

Female

N (%)

589 (0.12%)

1996-06-01 to 1996-06-30

overall

overall

N (%)

1,140 (0.23%)

\<=60

overall

N (%)

1,140 (0.23%)

overall

Male

N (%)

570 (0.12%)

Female

N (%)

570 (0.12%)

\<=60

Male

N (%)

570 (0.12%)

Female

N (%)

570 (0.12%)

1996-07-01 to 1996-07-31

overall

overall

N (%)

1,178 (0.24%)

\<=60

overall

N (%)

1,178 (0.24%)

overall

Male

N (%)

589 (0.12%)

Female

N (%)

589 (0.12%)

\<=60

Male

N (%)

589 (0.12%)

Female

N (%)

589 (0.12%)

1996-08-01 to 1996-08-31

overall

overall

N (%)

1,178 (0.24%)

\<=60

overall

N (%)

1,178 (0.24%)

overall

Male

N (%)

589 (0.12%)

Female

N (%)

589 (0.12%)

\<=60

Male

N (%)

589 (0.12%)

Female

N (%)

589 (0.12%)

1996-09-01 to 1996-09-30

overall

overall

N (%)

1,140 (0.23%)

\<=60

overall

N (%)

1,140 (0.23%)

overall

Male

N (%)

570 (0.12%)

Female

N (%)

570 (0.12%)

\<=60

Male

N (%)

570 (0.12%)

Female

N (%)

570 (0.12%)

1996-10-01 to 1996-10-31

overall

overall

N (%)

1,194 (0.24%)

\<=60

overall

N (%)

1,194 (0.24%)

overall

Male

N (%)

589 (0.12%)

Female

N (%)

605 (0.12%)

\<=60

Male

N (%)

589 (0.12%)

Female

N (%)

605 (0.12%)

1996-11-01 to 1996-11-30

overall

overall

N (%)

1,170 (0.24%)

\<=60

overall

N (%)

1,170 (0.24%)

overall

Male

N (%)

570 (0.12%)

Female

N (%)

600 (0.12%)

\<=60

Male

N (%)

570 (0.12%)

Female

N (%)

600 (0.12%)

1996-12-01 to 1996-12-31

overall

overall

N (%)

1,178 (0.24%)

\<=60

overall

N (%)

1,178 (0.24%)

overall

Male

N (%)

589 (0.12%)

Female

N (%)

589 (0.12%)

\<=60

Male

N (%)

589 (0.12%)

Female

N (%)

589 (0.12%)

1997-01-01 to 1997-01-31

overall

overall

N (%)

1,178 (0.24%)

\<=60

overall

N (%)

1,178 (0.24%)

overall

Male

N (%)

589 (0.12%)

Female

N (%)

589 (0.12%)

\<=60

Male

N (%)

589 (0.12%)

Female

N (%)

589 (0.12%)

1997-02-01 to 1997-02-28

overall

overall

N (%)

1,064 (0.22%)

\<=60

overall

N (%)

1,064 (0.22%)

overall

Male

N (%)

532 (0.11%)

Female

N (%)

532 (0.11%)

\<=60

Male

N (%)

532 (0.11%)

Female

N (%)

532 (0.11%)

1997-03-01 to 1997-03-31

overall

overall

N (%)

1,178 (0.24%)

\<=60

overall

N (%)

1,178 (0.24%)

overall

Male

N (%)

589 (0.12%)

Female

N (%)

589 (0.12%)

\<=60

Male

N (%)

589 (0.12%)

Female

N (%)

589 (0.12%)

1997-04-01 to 1997-04-30

overall

overall

N (%)

1,111 (0.23%)

\<=60

overall

N (%)

1,111 (0.23%)

overall

Male

N (%)

541 (0.11%)

Female

N (%)

570 (0.12%)

\<=60

Male

N (%)

541 (0.11%)

Female

N (%)

570 (0.12%)

1997-05-01 to 1997-05-31

overall

overall

N (%)

1,147 (0.23%)

\<=60

overall

N (%)

1,147 (0.23%)

overall

Male

N (%)

558 (0.11%)

Female

N (%)

589 (0.12%)

\<=60

Male

N (%)

558 (0.11%)

Female

N (%)

589 (0.12%)

1997-06-01 to 1997-06-30

overall

overall

N (%)

1,110 (0.23%)

\<=60

overall

N (%)

1,110 (0.23%)

overall

Male

N (%)

540 (0.11%)

Female

N (%)

570 (0.12%)

\<=60

Male

N (%)

540 (0.11%)

Female

N (%)

570 (0.12%)

1997-07-01 to 1997-07-31

overall

overall

N (%)

1,147 (0.23%)

\<=60

overall

N (%)

1,147 (0.23%)

overall

Male

N (%)

558 (0.11%)

Female

N (%)

589 (0.12%)

\<=60

Male

N (%)

558 (0.11%)

Female

N (%)

589 (0.12%)

1997-08-01 to 1997-08-31

overall

overall

N (%)

1,147 (0.23%)

\<=60

overall

N (%)

1,147 (0.23%)

overall

Male

N (%)

558 (0.11%)

Female

N (%)

589 (0.12%)

\<=60

Male

N (%)

558 (0.11%)

Female

N (%)

589 (0.12%)

1997-09-01 to 1997-09-30

overall

overall

N (%)

1,110 (0.23%)

\<=60

overall

N (%)

1,110 (0.23%)

overall

Male

N (%)

540 (0.11%)

Female

N (%)

570 (0.12%)

\<=60

Male

N (%)

540 (0.11%)

Female

N (%)

570 (0.12%)

1997-10-01 to 1997-10-31

overall

overall

N (%)

1,147 (0.23%)

\<=60

overall

N (%)

1,147 (0.23%)

overall

Male

N (%)

558 (0.11%)

Female

N (%)

589 (0.12%)

\<=60

Male

N (%)

558 (0.11%)

Female

N (%)

589 (0.12%)

1997-11-01 to 1997-11-30

overall

overall

N (%)

1,110 (0.23%)

\<=60

overall

N (%)

1,110 (0.23%)

overall

Male

N (%)

540 (0.11%)

Female

N (%)

570 (0.12%)

\<=60

Male

N (%)

540 (0.11%)

Female

N (%)

570 (0.12%)

1997-12-01 to 1997-12-31

overall

overall

N (%)

1,143 (0.23%)

\<=60

overall

N (%)

1,143 (0.23%)

overall

Male

N (%)

583 (0.12%)

Female

N (%)

560 (0.11%)

\<=60

Male

N (%)

583 (0.12%)

Female

N (%)

560 (0.11%)

1998-01-01 to 1998-01-31

overall

overall

N (%)

1,147 (0.23%)

\<=60

overall

N (%)

1,147 (0.23%)

overall

Male

N (%)

589 (0.12%)

Female

N (%)

558 (0.11%)

\<=60

Male

N (%)

589 (0.12%)

Female

N (%)

558 (0.11%)

1998-02-01 to 1998-02-28

overall

overall

N (%)

1,049 (0.21%)

\<=60

overall

N (%)

1,049 (0.21%)

overall

Male

N (%)

545 (0.11%)

Female

N (%)

504 (0.10%)

\<=60

Male

N (%)

545 (0.11%)

Female

N (%)

504 (0.10%)

1998-03-01 to 1998-03-31

overall

overall

N (%)

1,178 (0.24%)

\<=60

overall

N (%)

1,178 (0.24%)

overall

Male

N (%)

620 (0.13%)

Female

N (%)

558 (0.11%)

\<=60

Male

N (%)

620 (0.13%)

Female

N (%)

558 (0.11%)

1998-04-01 to 1998-04-30

overall

overall

N (%)

1,140 (0.23%)

\<=60

overall

N (%)

1,140 (0.23%)

overall

Male

N (%)

600 (0.12%)

Female

N (%)

540 (0.11%)

\<=60

Male

N (%)

600 (0.12%)

Female

N (%)

540 (0.11%)

1998-05-01 to 1998-05-31

overall

overall

N (%)

1,178 (0.24%)

\<=60

overall

N (%)

1,178 (0.24%)

overall

Male

N (%)

620 (0.13%)

Female

N (%)

558 (0.11%)

\<=60

Male

N (%)

620 (0.13%)

Female

N (%)

558 (0.11%)

1998-06-01 to 1998-06-30

overall

overall

N (%)

1,164 (0.24%)

\<=60

overall

N (%)

1,164 (0.24%)

overall

Male

N (%)

624 (0.13%)

Female

N (%)

540 (0.11%)

\<=60

Male

N (%)

624 (0.13%)

Female

N (%)

540 (0.11%)

1998-07-01 to 1998-07-31

overall

overall

N (%)

1,209 (0.25%)

\<=60

overall

N (%)

1,209 (0.25%)

overall

Male

N (%)

651 (0.13%)

Female

N (%)

558 (0.11%)

\<=60

Male

N (%)

651 (0.13%)

Female

N (%)

558 (0.11%)

1998-08-01 to 1998-08-31

overall

overall

N (%)

1,198 (0.24%)

\<=60

overall

N (%)

1,198 (0.24%)

overall

Male

N (%)

640 (0.13%)

Female

N (%)

558 (0.11%)

\<=60

Male

N (%)

640 (0.13%)

Female

N (%)

558 (0.11%)

1998-09-01 to 1998-09-30

overall

overall

N (%)

1,140 (0.23%)

\<=60

overall

N (%)

1,140 (0.23%)

overall

Male

N (%)

600 (0.12%)

Female

N (%)

540 (0.11%)

\<=60

Male

N (%)

600 (0.12%)

Female

N (%)

540 (0.11%)

1998-10-01 to 1998-10-31

overall

overall

N (%)

1,178 (0.24%)

\<=60

overall

N (%)

1,178 (0.24%)

overall

Male

N (%)

620 (0.13%)

Female

N (%)

558 (0.11%)

\<=60

Male

N (%)

620 (0.13%)

Female

N (%)

558 (0.11%)

1998-11-01 to 1998-11-30

overall

overall

N (%)

1,167 (0.24%)

\<=60

overall

N (%)

1,167 (0.24%)

overall

Male

N (%)

600 (0.12%)

Female

N (%)

567 (0.12%)

\<=60

Male

N (%)

600 (0.12%)

Female

N (%)

567 (0.12%)

1998-12-01 to 1998-12-31

overall

overall

N (%)

1,219 (0.25%)

\<=60

overall

N (%)

1,219 (0.25%)

overall

Male

N (%)

630 (0.13%)

Female

N (%)

589 (0.12%)

\<=60

Male

N (%)

630 (0.13%)

Female

N (%)

589 (0.12%)

1999-01-01 to 1999-01-31

overall

overall

N (%)

1,240 (0.25%)

\<=60

overall

N (%)

1,240 (0.25%)

overall

Male

N (%)

651 (0.13%)

Female

N (%)

589 (0.12%)

\<=60

Male

N (%)

651 (0.13%)

Female

N (%)

589 (0.12%)

1999-02-01 to 1999-02-28

overall

overall

N (%)

1,120 (0.23%)

\<=60

overall

N (%)

1,120 (0.23%)

overall

Male

N (%)

588 (0.12%)

Female

N (%)

532 (0.11%)

\<=60

Male

N (%)

588 (0.12%)

Female

N (%)

532 (0.11%)

1999-03-01 to 1999-03-31

overall

overall

N (%)

1,240 (0.25%)

\<=60

overall

N (%)

1,240 (0.25%)

overall

Male

N (%)

651 (0.13%)

Female

N (%)

589 (0.12%)

\<=60

Male

N (%)

651 (0.13%)

Female

N (%)

589 (0.12%)

1999-04-01 to 1999-04-30

overall

overall

N (%)

1,200 (0.24%)

\<=60

overall

N (%)

1,200 (0.24%)

overall

Male

N (%)

630 (0.13%)

Female

N (%)

570 (0.12%)

\<=60

Male

N (%)

630 (0.13%)

Female

N (%)

570 (0.12%)

1999-05-01 to 1999-05-31

overall

overall

N (%)

1,225 (0.25%)

\<=60

overall

N (%)

1,225 (0.25%)

overall

Male

N (%)

636 (0.13%)

Female

N (%)

589 (0.12%)

\<=60

Male

N (%)

636 (0.13%)

Female

N (%)

589 (0.12%)

1999-06-01 to 1999-06-30

overall

overall

N (%)

1,180 (0.24%)

\<=60

overall

N (%)

1,180 (0.24%)

overall

Male

N (%)

610 (0.12%)

Female

N (%)

570 (0.12%)

\<=60

Male

N (%)

610 (0.12%)

Female

N (%)

570 (0.12%)

1999-07-01 to 1999-07-31

overall

overall

N (%)

1,240 (0.25%)

\<=60

overall

N (%)

1,240 (0.25%)

overall

Male

N (%)

651 (0.13%)

Female

N (%)

589 (0.12%)

\<=60

Male

N (%)

651 (0.13%)

Female

N (%)

589 (0.12%)

1999-08-01 to 1999-08-31

overall

overall

N (%)

1,240 (0.25%)

\<=60

overall

N (%)

1,240 (0.25%)

overall

Male

N (%)

651 (0.13%)

Female

N (%)

589 (0.12%)

\<=60

Male

N (%)

651 (0.13%)

Female

N (%)

589 (0.12%)

1999-09-01 to 1999-09-30

overall

overall

N (%)

1,200 (0.24%)

\<=60

overall

N (%)

1,200 (0.24%)

overall

Male

N (%)

630 (0.13%)

Female

N (%)

570 (0.12%)

\<=60

Male

N (%)

630 (0.13%)

Female

N (%)

570 (0.12%)

1999-10-01 to 1999-10-31

overall

overall

N (%)

1,255 (0.25%)

\<=60

overall

N (%)

1,255 (0.25%)

overall

Male

N (%)

651 (0.13%)

Female

N (%)

604 (0.12%)

\<=60

Male

N (%)

651 (0.13%)

Female

N (%)

604 (0.12%)

1999-11-01 to 1999-11-30

overall

overall

N (%)

1,230 (0.25%)

\<=60

overall

N (%)

1,230 (0.25%)

overall

Male

N (%)

630 (0.13%)

Female

N (%)

600 (0.12%)

\<=60

Male

N (%)

630 (0.13%)

Female

N (%)

600 (0.12%)

1999-12-01 to 1999-12-31

overall

overall

N (%)

1,271 (0.26%)

\<=60

overall

N (%)

1,271 (0.26%)

overall

Male

N (%)

651 (0.13%)

Female

N (%)

620 (0.13%)

\<=60

Male

N (%)

651 (0.13%)

Female

N (%)

620 (0.13%)

2000-01-01 to 2000-01-31

overall

overall

N (%)

1,284 (0.26%)

\<=60

overall

N (%)

1,284 (0.26%)

overall

Male

N (%)

651 (0.13%)

Female

N (%)

633 (0.13%)

\<=60

Male

N (%)

651 (0.13%)

Female

N (%)

633 (0.13%)

2000-02-01 to 2000-02-29

overall

overall

N (%)

1,217 (0.25%)

\<=60

overall

N (%)

1,217 (0.25%)

overall

Male

N (%)

608 (0.12%)

Female

N (%)

609 (0.12%)

\<=60

Male

N (%)

608 (0.12%)

Female

N (%)

609 (0.12%)

2000-03-01 to 2000-03-31

overall

overall

N (%)

1,291 (0.26%)

\<=60

overall

N (%)

1,291 (0.26%)

overall

Male

N (%)

620 (0.13%)

Female

N (%)

671 (0.14%)

\<=60

Male

N (%)

620 (0.13%)

Female

N (%)

671 (0.14%)

2000-04-01 to 2000-04-30

overall

overall

N (%)

1,231 (0.25%)

\<=60

overall

N (%)

1,231 (0.25%)

overall

Male

N (%)

571 (0.12%)

Female

N (%)

660 (0.13%)

\<=60

Male

N (%)

571 (0.12%)

Female

N (%)

660 (0.13%)

2000-05-01 to 2000-05-31

overall

overall

N (%)

1,271 (0.26%)

\<=60

overall

N (%)

1,271 (0.26%)

overall

Male

N (%)

589 (0.12%)

Female

N (%)

682 (0.14%)

\<=60

Male

N (%)

589 (0.12%)

Female

N (%)

682 (0.14%)

2000-06-01 to 2000-06-30

overall

overall

N (%)

1,230 (0.25%)

\<=60

overall

N (%)

1,230 (0.25%)

overall

Male

N (%)

570 (0.12%)

Female

N (%)

660 (0.13%)

\<=60

Male

N (%)

570 (0.12%)

Female

N (%)

660 (0.13%)

2000-07-01 to 2000-07-31

overall

overall

N (%)

1,283 (0.26%)

\<=60

overall

N (%)

1,283 (0.26%)

overall

Male

N (%)

601 (0.12%)

Female

N (%)

682 (0.14%)

\<=60

Male

N (%)

601 (0.12%)

Female

N (%)

682 (0.14%)

2000-08-01 to 2000-08-31

overall

overall

N (%)

1,302 (0.26%)

\<=60

overall

N (%)

1,302 (0.26%)

overall

Male

N (%)

620 (0.13%)

Female

N (%)

682 (0.14%)

\<=60

Male

N (%)

620 (0.13%)

Female

N (%)

682 (0.14%)

2000-09-01 to 2000-09-30

overall

overall

N (%)

1,242 (0.25%)

\<=60

overall

N (%)

1,242 (0.25%)

overall

Male

N (%)

600 (0.12%)

Female

N (%)

642 (0.13%)

\<=60

Male

N (%)

600 (0.12%)

Female

N (%)

642 (0.13%)

2000-10-01 to 2000-10-31

overall

overall

N (%)

1,271 (0.26%)

\<=60

overall

N (%)

1,271 (0.26%)

overall

Male

N (%)

620 (0.13%)

Female

N (%)

651 (0.13%)

\<=60

Male

N (%)

620 (0.13%)

Female

N (%)

651 (0.13%)

2000-11-01 to 2000-11-30

overall

overall

N (%)

1,230 (0.25%)

\<=60

overall

N (%)

1,230 (0.25%)

overall

Male

N (%)

600 (0.12%)

Female

N (%)

630 (0.13%)

\<=60

Male

N (%)

600 (0.12%)

Female

N (%)

630 (0.13%)

2000-12-01 to 2000-12-31

overall

overall

N (%)

1,271 (0.26%)

\<=60

overall

N (%)

1,271 (0.26%)

overall

Male

N (%)

620 (0.13%)

Female

N (%)

651 (0.13%)

\<=60

Male

N (%)

620 (0.13%)

Female

N (%)

651 (0.13%)

2001-01-01 to 2001-01-31

overall

overall

N (%)

1,271 (0.26%)

\<=60

overall

N (%)

1,271 (0.26%)

overall

Male

N (%)

620 (0.13%)

Female

N (%)

651 (0.13%)

\<=60

Male

N (%)

620 (0.13%)

Female

N (%)

651 (0.13%)

2001-02-01 to 2001-02-28

overall

overall

N (%)

1,148 (0.23%)

\<=60

overall

N (%)

1,148 (0.23%)

overall

Male

N (%)

560 (0.11%)

Female

N (%)

588 (0.12%)

\<=60

Male

N (%)

560 (0.11%)

Female

N (%)

588 (0.12%)

2001-03-01 to 2001-03-31

overall

overall

N (%)

1,271 (0.26%)

\<=60

overall

N (%)

1,271 (0.26%)

overall

Male

N (%)

620 (0.13%)

Female

N (%)

651 (0.13%)

\<=60

Male

N (%)

620 (0.13%)

Female

N (%)

651 (0.13%)

2001-04-01 to 2001-04-30

overall

overall

N (%)

1,236 (0.25%)

\<=60

overall

N (%)

1,236 (0.25%)

overall

Male

N (%)

600 (0.12%)

Female

N (%)

636 (0.13%)

\<=60

Male

N (%)

600 (0.12%)

Female

N (%)

636 (0.13%)

2001-05-01 to 2001-05-31

overall

overall

N (%)

1,309 (0.27%)

\<=60

overall

N (%)

1,309 (0.27%)

overall

Male

N (%)

627 (0.13%)

Female

N (%)

682 (0.14%)

\<=60

Male

N (%)

627 (0.13%)

Female

N (%)

682 (0.14%)

2001-06-01 to 2001-06-30

overall

overall

N (%)

1,236 (0.25%)

\<=60

overall

N (%)

1,236 (0.25%)

overall

Male

N (%)

576 (0.12%)

Female

N (%)

660 (0.13%)

\<=60

Male

N (%)

576 (0.12%)

Female

N (%)

660 (0.13%)

2001-07-01 to 2001-07-31

overall

overall

N (%)

1,281 (0.26%)

\<=60

overall

N (%)

1,281 (0.26%)

overall

Male

N (%)

589 (0.12%)

Female

N (%)

692 (0.14%)

\<=60

Male

N (%)

589 (0.12%)

Female

N (%)

692 (0.14%)

2001-08-01 to 2001-08-31

overall

overall

N (%)

1,302 (0.26%)

\<=60

overall

N (%)

1,302 (0.26%)

overall

Male

N (%)

589 (0.12%)

Female

N (%)

713 (0.14%)

\<=60

Male

N (%)

589 (0.12%)

Female

N (%)

713 (0.14%)

2001-09-01 to 2001-09-30

overall

overall

N (%)

1,260 (0.26%)

\<=60

overall

N (%)

1,260 (0.26%)

overall

Male

N (%)

570 (0.12%)

Female

N (%)

690 (0.14%)

\<=60

Male

N (%)

570 (0.12%)

Female

N (%)

690 (0.14%)

2001-10-01 to 2001-10-31

overall

overall

N (%)

1,302 (0.26%)

\<=60

overall

N (%)

1,302 (0.26%)

overall

Male

N (%)

589 (0.12%)

Female

N (%)

713 (0.14%)

\<=60

Male

N (%)

589 (0.12%)

Female

N (%)

713 (0.14%)

2001-11-01 to 2001-11-30

overall

overall

N (%)

1,260 (0.26%)

\<=60

overall

N (%)

1,260 (0.26%)

overall

Male

N (%)

570 (0.12%)

Female

N (%)

690 (0.14%)

\<=60

Male

N (%)

570 (0.12%)

Female

N (%)

690 (0.14%)

2001-12-01 to 2001-12-31

overall

overall

N (%)

1,302 (0.26%)

\<=60

overall

N (%)

1,302 (0.26%)

overall

Male

N (%)

589 (0.12%)

Female

N (%)

713 (0.14%)

\<=60

Male

N (%)

589 (0.12%)

Female

N (%)

713 (0.14%)

2002-01-01 to 2002-01-31

overall

overall

N (%)

1,323 (0.27%)

\<=60

overall

N (%)

1,323 (0.27%)

overall

Male

N (%)

610 (0.12%)

Female

N (%)

713 (0.14%)

\<=60

Male

N (%)

610 (0.12%)

Female

N (%)

713 (0.14%)

2002-02-01 to 2002-02-28

overall

overall

N (%)

1,198 (0.24%)

\<=60

overall

N (%)

1,198 (0.24%)

overall

Male

N (%)

560 (0.11%)

Female

N (%)

638 (0.13%)

\<=60

Male

N (%)

560 (0.11%)

Female

N (%)

638 (0.13%)

2002-03-01 to 2002-03-31

overall

overall

N (%)

1,302 (0.26%)

\<=60

overall

N (%)

1,302 (0.26%)

overall

Male

N (%)

620 (0.13%)

Female

N (%)

682 (0.14%)

\<=60

Male

N (%)

620 (0.13%)

Female

N (%)

682 (0.14%)

2002-04-01 to 2002-04-30

overall

overall

N (%)

1,260 (0.26%)

\<=60

overall

N (%)

1,260 (0.26%)

overall

Male

N (%)

600 (0.12%)

Female

N (%)

660 (0.13%)

\<=60

Male

N (%)

600 (0.12%)

Female

N (%)

660 (0.13%)

2002-05-01 to 2002-05-31

overall

overall

N (%)

1,302 (0.26%)

\<=60

overall

N (%)

1,302 (0.26%)

overall

Male

N (%)

620 (0.13%)

Female

N (%)

682 (0.14%)

\<=60

Male

N (%)

620 (0.13%)

Female

N (%)

682 (0.14%)

2002-06-01 to 2002-06-30

overall

overall

N (%)

1,275 (0.26%)

\<=60

overall

N (%)

1,275 (0.26%)

overall

Male

N (%)

615 (0.12%)

Female

N (%)

660 (0.13%)

\<=60

Male

N (%)

615 (0.12%)

Female

N (%)

660 (0.13%)

2002-07-01 to 2002-07-31

overall

overall

N (%)

1,333 (0.27%)

\<=60

overall

N (%)

1,333 (0.27%)

overall

Male

N (%)

651 (0.13%)

Female

N (%)

682 (0.14%)

\<=60

Male

N (%)

651 (0.13%)

Female

N (%)

682 (0.14%)

2002-08-01 to 2002-08-31

overall

overall

N (%)

1,330 (0.27%)

\<=60

overall

N (%)

1,330 (0.27%)

overall

Male

N (%)

648 (0.13%)

Female

N (%)

682 (0.14%)

\<=60

Male

N (%)

648 (0.13%)

Female

N (%)

682 (0.14%)

2002-09-01 to 2002-09-30

overall

overall

N (%)

1,260 (0.26%)

\<=60

overall

N (%)

1,260 (0.26%)

overall

Male

N (%)

600 (0.12%)

Female

N (%)

660 (0.13%)

\<=60

Male

N (%)

600 (0.12%)

Female

N (%)

660 (0.13%)

2002-10-01 to 2002-10-31

overall

overall

N (%)

1,337 (0.27%)

\<=60

overall

N (%)

1,337 (0.27%)

overall

Male

N (%)

655 (0.13%)

Female

N (%)

682 (0.14%)

\<=60

Male

N (%)

655 (0.13%)

Female

N (%)

682 (0.14%)

2002-11-01 to 2002-11-30

overall

overall

N (%)

1,320 (0.27%)

\<=60

overall

N (%)

1,320 (0.27%)

overall

Male

N (%)

660 (0.13%)

Female

N (%)

660 (0.13%)

\<=60

Male

N (%)

660 (0.13%)

Female

N (%)

660 (0.13%)

2002-12-01 to 2002-12-31

overall

overall

N (%)

1,364 (0.28%)

\<=60

overall

N (%)

1,364 (0.28%)

overall

Male

N (%)

682 (0.14%)

Female

N (%)

682 (0.14%)

\<=60

Male

N (%)

682 (0.14%)

Female

N (%)

682 (0.14%)

2003-01-01 to 2003-01-31

overall

overall

N (%)

1,394 (0.28%)

\<=60

overall

N (%)

1,394 (0.28%)

overall

Male

N (%)

682 (0.14%)

Female

N (%)

712 (0.14%)

\<=60

Male

N (%)

682 (0.14%)

Female

N (%)

712 (0.14%)

2003-02-01 to 2003-02-28

overall

overall

N (%)

1,260 (0.26%)

\<=60

overall

N (%)

1,260 (0.26%)

overall

Male

N (%)

616 (0.12%)

Female

N (%)

644 (0.13%)

\<=60

Male

N (%)

616 (0.12%)

Female

N (%)

644 (0.13%)

2003-03-01 to 2003-03-31

overall

overall

N (%)

1,395 (0.28%)

\<=60

overall

N (%)

1,395 (0.28%)

overall

Male

N (%)

682 (0.14%)

Female

N (%)

713 (0.14%)

\<=60

Male

N (%)

682 (0.14%)

Female

N (%)

713 (0.14%)

2003-04-01 to 2003-04-30

overall

overall

N (%)

1,350 (0.27%)

\<=60

overall

N (%)

1,350 (0.27%)

overall

Male

N (%)

660 (0.13%)

Female

N (%)

690 (0.14%)

\<=60

Male

N (%)

660 (0.13%)

Female

N (%)

690 (0.14%)

2003-05-01 to 2003-05-31

overall

overall

N (%)

1,395 (0.28%)

\<=60

overall

N (%)

1,395 (0.28%)

overall

Male

N (%)

682 (0.14%)

Female

N (%)

713 (0.14%)

\<=60

Male

N (%)

682 (0.14%)

Female

N (%)

713 (0.14%)

2003-06-01 to 2003-06-30

overall

overall

N (%)

1,350 (0.27%)

\<=60

overall

N (%)

1,350 (0.27%)

overall

Male

N (%)

660 (0.13%)

Female

N (%)

690 (0.14%)

\<=60

Male

N (%)

660 (0.13%)

Female

N (%)

690 (0.14%)

2003-07-01 to 2003-07-31

overall

overall

N (%)

1,395 (0.28%)

\<=60

overall

N (%)

1,395 (0.28%)

overall

Male

N (%)

682 (0.14%)

Female

N (%)

713 (0.14%)

\<=60

Male

N (%)

682 (0.14%)

Female

N (%)

713 (0.14%)

2003-08-01 to 2003-08-31

overall

overall

N (%)

1,395 (0.28%)

\<=60

overall

N (%)

1,395 (0.28%)

overall

Male

N (%)

682 (0.14%)

Female

N (%)

713 (0.14%)

\<=60

Male

N (%)

682 (0.14%)

Female

N (%)

713 (0.14%)

2003-09-01 to 2003-09-30

overall

overall

N (%)

1,350 (0.27%)

\<=60

overall

N (%)

1,350 (0.27%)

overall

Male

N (%)

660 (0.13%)

Female

N (%)

690 (0.14%)

\<=60

Male

N (%)

660 (0.13%)

Female

N (%)

690 (0.14%)

2003-10-01 to 2003-10-31

overall

overall

N (%)

1,395 (0.28%)

\<=60

overall

N (%)

1,395 (0.28%)

overall

Male

N (%)

682 (0.14%)

Female

N (%)

713 (0.14%)

\<=60

Male

N (%)

682 (0.14%)

Female

N (%)

713 (0.14%)

2003-11-01 to 2003-11-30

overall

overall

N (%)

1,350 (0.27%)

\<=60

overall

N (%)

1,350 (0.27%)

overall

Male

N (%)

660 (0.13%)

Female

N (%)

690 (0.14%)

\<=60

Male

N (%)

660 (0.13%)

Female

N (%)

690 (0.14%)

2003-12-01 to 2003-12-31

overall

overall

N (%)

1,395 (0.28%)

\<=60

overall

N (%)

1,395 (0.28%)

overall

Male

N (%)

682 (0.14%)

Female

N (%)

713 (0.14%)

\<=60

Male

N (%)

682 (0.14%)

Female

N (%)

713 (0.14%)

2004-01-01 to 2004-01-31

overall

overall

N (%)

1,398 (0.28%)

\<=60

overall

N (%)

1,398 (0.28%)

overall

Male

N (%)

679 (0.14%)

Female

N (%)

719 (0.15%)

\<=60

Male

N (%)

679 (0.14%)

Female

N (%)

719 (0.15%)

2004-02-01 to 2004-02-29

overall

overall

N (%)

1,305 (0.26%)

\<=60

overall

N (%)

1,305 (0.26%)

overall

Male

N (%)

609 (0.12%)

Female

N (%)

696 (0.14%)

\<=60

Male

N (%)

609 (0.12%)

Female

N (%)

696 (0.14%)

2004-03-01 to 2004-03-31

overall

overall

N (%)

1,395 (0.28%)

\<=60

overall

N (%)

1,395 (0.28%)

overall

Male

N (%)

651 (0.13%)

Female

N (%)

744 (0.15%)

\<=60

Male

N (%)

651 (0.13%)

Female

N (%)

744 (0.15%)

2004-04-01 to 2004-04-30

overall

overall

N (%)

1,350 (0.27%)

\<=60

overall

N (%)

1,350 (0.27%)

overall

Male

N (%)

630 (0.13%)

Female

N (%)

720 (0.15%)

\<=60

Male

N (%)

630 (0.13%)

Female

N (%)

720 (0.15%)

2004-05-01 to 2004-05-31

overall

overall

N (%)

1,440 (0.29%)

\<=60

overall

N (%)

1,440 (0.29%)

overall

Male

N (%)

696 (0.14%)

Female

N (%)

744 (0.15%)

\<=60

Male

N (%)

696 (0.14%)

Female

N (%)

744 (0.15%)

2004-06-01 to 2004-06-30

overall

overall

N (%)

1,387 (0.28%)

\<=60

overall

N (%)

1,387 (0.28%)

overall

Male

N (%)

690 (0.14%)

Female

N (%)

697 (0.14%)

\<=60

Male

N (%)

690 (0.14%)

Female

N (%)

697 (0.14%)

2004-07-01 to 2004-07-31

overall

overall

N (%)

1,425 (0.29%)

\<=60

overall

N (%)

1,425 (0.29%)

overall

Male

N (%)

713 (0.14%)

Female

N (%)

712 (0.14%)

\<=60

Male

N (%)

713 (0.14%)

Female

N (%)

712 (0.14%)

2004-08-01 to 2004-08-31

overall

overall

N (%)

1,396 (0.28%)

\<=60

overall

N (%)

1,396 (0.28%)

overall

Male

N (%)

713 (0.14%)

Female

N (%)

683 (0.14%)

\<=60

Male

N (%)

713 (0.14%)

Female

N (%)

683 (0.14%)

2004-09-01 to 2004-09-30

overall

overall

N (%)

1,358 (0.28%)

\<=60

overall

N (%)

1,358 (0.28%)

overall

Male

N (%)

672 (0.14%)

Female

N (%)

686 (0.14%)

\<=60

Male

N (%)

672 (0.14%)

Female

N (%)

686 (0.14%)

2004-10-01 to 2004-10-31

overall

overall

N (%)

1,351 (0.27%)

\<=60

overall

N (%)

1,351 (0.27%)

overall

Male

N (%)

682 (0.14%)

Female

N (%)

669 (0.14%)

\<=60

Male

N (%)

682 (0.14%)

Female

N (%)

669 (0.14%)

2004-11-01 to 2004-11-30

overall

overall

N (%)

1,290 (0.26%)

\<=60

overall

N (%)

1,290 (0.26%)

overall

Male

N (%)

660 (0.13%)

Female

N (%)

630 (0.13%)

\<=60

Male

N (%)

660 (0.13%)

Female

N (%)

630 (0.13%)

2004-12-01 to 2004-12-31

overall

overall

N (%)

1,333 (0.27%)

\<=60

overall

N (%)

1,333 (0.27%)

overall

Male

N (%)

682 (0.14%)

Female

N (%)

651 (0.13%)

\<=60

Male

N (%)

682 (0.14%)

Female

N (%)

651 (0.13%)

2005-01-01 to 2005-01-31

overall

overall

N (%)

1,333 (0.27%)

\<=60

overall

N (%)

1,333 (0.27%)

overall

Male

N (%)

682 (0.14%)

Female

N (%)

651 (0.13%)

\<=60

Male

N (%)

682 (0.14%)

Female

N (%)

651 (0.13%)

2005-02-01 to 2005-02-28

overall

overall

N (%)

1,204 (0.24%)

\<=60

overall

N (%)

1,204 (0.24%)

overall

Male

N (%)

616 (0.12%)

Female

N (%)

588 (0.12%)

\<=60

Male

N (%)

616 (0.12%)

Female

N (%)

588 (0.12%)

2005-03-01 to 2005-03-31

overall

overall

N (%)

1,333 (0.27%)

\<=60

overall

N (%)

1,333 (0.27%)

overall

Male

N (%)

682 (0.14%)

Female

N (%)

651 (0.13%)

\<=60

Male

N (%)

682 (0.14%)

Female

N (%)

651 (0.13%)

2005-04-01 to 2005-04-30

overall

overall

N (%)

1,290 (0.26%)

\<=60

overall

N (%)

1,290 (0.26%)

overall

Male

N (%)

660 (0.13%)

Female

N (%)

630 (0.13%)

\<=60

Male

N (%)

660 (0.13%)

Female

N (%)

630 (0.13%)

2005-05-01 to 2005-05-31

overall

overall

N (%)

1,310 (0.27%)

\<=60

overall

N (%)

1,310 (0.27%)

overall

Male

N (%)

682 (0.14%)

Female

N (%)

628 (0.13%)

\<=60

Male

N (%)

682 (0.14%)

Female

N (%)

628 (0.13%)

2005-06-01 to 2005-06-30

overall

overall

N (%)

1,260 (0.26%)

\<=60

overall

N (%)

1,260 (0.26%)

overall

Male

N (%)

660 (0.13%)

Female

N (%)

600 (0.12%)

\<=60

Male

N (%)

660 (0.13%)

Female

N (%)

600 (0.12%)

2005-07-01 to 2005-07-31

overall

overall

N (%)

1,302 (0.26%)

\<=60

overall

N (%)

1,302 (0.26%)

overall

Male

N (%)

682 (0.14%)

Female

N (%)

620 (0.13%)

\<=60

Male

N (%)

682 (0.14%)

Female

N (%)

620 (0.13%)

2005-08-01 to 2005-08-31

overall

overall

N (%)

1,302 (0.26%)

\<=60

overall

N (%)

1,302 (0.26%)

overall

Male

N (%)

682 (0.14%)

Female

N (%)

620 (0.13%)

\<=60

Male

N (%)

682 (0.14%)

Female

N (%)

620 (0.13%)

2005-09-01 to 2005-09-30

overall

overall

N (%)

1,270 (0.26%)

\<=60

overall

N (%)

1,270 (0.26%)

overall

Male

N (%)

660 (0.13%)

Female

N (%)

610 (0.12%)

\<=60

Male

N (%)

660 (0.13%)

Female

N (%)

610 (0.12%)

2005-10-01 to 2005-10-31

overall

overall

N (%)

1,333 (0.27%)

\<=60

overall

N (%)

1,333 (0.27%)

overall

Male

N (%)

682 (0.14%)

Female

N (%)

651 (0.13%)

\<=60

Male

N (%)

682 (0.14%)

Female

N (%)

651 (0.13%)

2005-11-01 to 2005-11-30

overall

overall

N (%)

1,290 (0.26%)

\<=60

overall

N (%)

1,290 (0.26%)

overall

Male

N (%)

660 (0.13%)

Female

N (%)

630 (0.13%)

\<=60

Male

N (%)

660 (0.13%)

Female

N (%)

630 (0.13%)

2005-12-01 to 2005-12-31

overall

overall

N (%)

1,333 (0.27%)

\<=60

overall

N (%)

1,333 (0.27%)

overall

Male

N (%)

682 (0.14%)

Female

N (%)

651 (0.13%)

\<=60

Male

N (%)

682 (0.14%)

Female

N (%)

651 (0.13%)

2006-01-01 to 2006-01-31

overall

overall

N (%)

1,333 (0.27%)

\<=60

overall

N (%)

1,333 (0.27%)

overall

Male

N (%)

682 (0.14%)

Female

N (%)

651 (0.13%)

\<=60

Male

N (%)

682 (0.14%)

Female

N (%)

651 (0.13%)

2006-02-01 to 2006-02-28

overall

overall

N (%)

1,204 (0.24%)

\<=60

overall

N (%)

1,204 (0.24%)

overall

Male

N (%)

616 (0.12%)

Female

N (%)

588 (0.12%)

\<=60

Male

N (%)

616 (0.12%)

Female

N (%)

588 (0.12%)

2006-03-01 to 2006-03-31

overall

overall

N (%)

1,321 (0.27%)

\<=60

overall

N (%)

1,321 (0.27%)

overall

Male

N (%)

670 (0.14%)

Female

N (%)

651 (0.13%)

\<=60

Male

N (%)

670 (0.14%)

Female

N (%)

651 (0.13%)

2006-04-01 to 2006-04-30

overall

overall

N (%)

1,260 (0.26%)

\<=60

overall

N (%)

1,260 (0.26%)

overall

Male

N (%)

630 (0.13%)

Female

N (%)

630 (0.13%)

\<=60

Male

N (%)

630 (0.13%)

Female

N (%)

630 (0.13%)

2006-05-01 to 2006-05-31

overall

overall

N (%)

1,289 (0.26%)

\<=60

overall

N (%)

1,289 (0.26%)

overall

Male

N (%)

638 (0.13%)

Female

N (%)

651 (0.13%)

\<=60

Male

N (%)

638 (0.13%)

Female

N (%)

651 (0.13%)

2006-06-01 to 2006-06-30

overall

overall

N (%)

1,230 (0.25%)

\<=60

overall

N (%)

1,230 (0.25%)

overall

Male

N (%)

600 (0.12%)

Female

N (%)

630 (0.13%)

\<=60

Male

N (%)

600 (0.12%)

Female

N (%)

630 (0.13%)

2006-07-01 to 2006-07-31

overall

overall

N (%)

1,271 (0.26%)

\<=60

overall

N (%)

1,271 (0.26%)

overall

Male

N (%)

620 (0.13%)

Female

N (%)

651 (0.13%)

\<=60

Male

N (%)

620 (0.13%)

Female

N (%)

651 (0.13%)

2006-08-01 to 2006-08-31

overall

overall

N (%)

1,280 (0.26%)

\<=60

overall

N (%)

1,280 (0.26%)

overall

Male

N (%)

620 (0.13%)

Female

N (%)

660 (0.13%)

\<=60

Male

N (%)

620 (0.13%)

Female

N (%)

660 (0.13%)

2006-09-01 to 2006-09-30

overall

overall

N (%)

1,260 (0.26%)

\<=60

overall

N (%)

1,260 (0.26%)

overall

Male

N (%)

600 (0.12%)

Female

N (%)

660 (0.13%)

\<=60

Male

N (%)

600 (0.12%)

Female

N (%)

660 (0.13%)

2006-10-01 to 2006-10-31

overall

overall

N (%)

1,302 (0.26%)

\<=60

overall

N (%)

1,302 (0.26%)

overall

Male

N (%)

620 (0.13%)

Female

N (%)

682 (0.14%)

\<=60

Male

N (%)

620 (0.13%)

Female

N (%)

682 (0.14%)

2006-11-01 to 2006-11-30

overall

overall

N (%)

1,260 (0.26%)

\<=60

overall

N (%)

1,260 (0.26%)

overall

Male

N (%)

600 (0.12%)

Female

N (%)

660 (0.13%)

\<=60

Male

N (%)

600 (0.12%)

Female

N (%)

660 (0.13%)

2006-12-01 to 2006-12-31

overall

overall

N (%)

1,302 (0.26%)

\<=60

overall

N (%)

1,302 (0.26%)

overall

Male

N (%)

620 (0.13%)

Female

N (%)

682 (0.14%)

\<=60

Male

N (%)

620 (0.13%)

Female

N (%)

682 (0.14%)

2007-01-01 to 2007-01-31

overall

overall

N (%)

1,277 (0.26%)

\<=60

overall

N (%)

1,277 (0.26%)

overall

Male

N (%)

595 (0.12%)

Female

N (%)

682 (0.14%)

\<=60

Male

N (%)

595 (0.12%)

Female

N (%)

682 (0.14%)

2007-02-01 to 2007-02-28

overall

overall

N (%)

1,148 (0.23%)

\<=60

overall

N (%)

1,148 (0.23%)

overall

Male

N (%)

532 (0.11%)

Female

N (%)

616 (0.12%)

\<=60

Male

N (%)

532 (0.11%)

Female

N (%)

616 (0.12%)

2007-03-01 to 2007-03-31

overall

overall

N (%)

1,271 (0.26%)

\<=60

overall

N (%)

1,271 (0.26%)

overall

Male

N (%)

589 (0.12%)

Female

N (%)

682 (0.14%)

\<=60

Male

N (%)

589 (0.12%)

Female

N (%)

682 (0.14%)

2007-04-01 to 2007-04-30

overall

overall

N (%)

1,202 (0.24%)

\<=60

overall

N (%)

1,202 (0.24%)

overall

Male

N (%)

542 (0.11%)

Female

N (%)

660 (0.13%)

\<=60

Male

N (%)

542 (0.11%)

Female

N (%)

660 (0.13%)

2007-05-01 to 2007-05-31

overall

overall

N (%)

1,240 (0.25%)

\<=60

overall

N (%)

1,240 (0.25%)

overall

Male

N (%)

558 (0.11%)

Female

N (%)

682 (0.14%)

\<=60

Male

N (%)

558 (0.11%)

Female

N (%)

682 (0.14%)

2007-06-01 to 2007-06-30

overall

overall

N (%)

1,200 (0.24%)

\<=60

overall

N (%)

1,200 (0.24%)

overall

Male

N (%)

540 (0.11%)

Female

N (%)

660 (0.13%)

\<=60

Male

N (%)

540 (0.11%)

Female

N (%)

660 (0.13%)

2007-07-01 to 2007-07-31

overall

overall

N (%)

1,240 (0.25%)

\<=60

overall

N (%)

1,240 (0.25%)

overall

Male

N (%)

558 (0.11%)

Female

N (%)

682 (0.14%)

\<=60

Male

N (%)

558 (0.11%)

Female

N (%)

682 (0.14%)

2007-08-01 to 2007-08-31

overall

overall

N (%)

1,254 (0.25%)

\<=60

overall

N (%)

1,254 (0.25%)

overall

Male

N (%)

572 (0.12%)

Female

N (%)

682 (0.14%)

\<=60

Male

N (%)

572 (0.12%)

Female

N (%)

682 (0.14%)

2007-09-01 to 2007-09-30

overall

overall

N (%)

1,230 (0.25%)

\<=60

overall

N (%)

1,230 (0.25%)

overall

Male

N (%)

570 (0.12%)

Female

N (%)

660 (0.13%)

\<=60

Male

N (%)

570 (0.12%)

Female

N (%)

660 (0.13%)

2007-10-01 to 2007-10-31

overall

overall

N (%)

1,271 (0.26%)

\<=60

overall

N (%)

1,271 (0.26%)

overall

Male

N (%)

589 (0.12%)

Female

N (%)

682 (0.14%)

\<=60

Male

N (%)

589 (0.12%)

Female

N (%)

682 (0.14%)

2007-11-01 to 2007-11-30

overall

overall

N (%)

1,257 (0.25%)

\<=60

overall

N (%)

1,257 (0.25%)

overall

Male

N (%)

570 (0.12%)

Female

N (%)

687 (0.14%)

\<=60

Male

N (%)

570 (0.12%)

Female

N (%)

687 (0.14%)

2007-12-01 to 2007-12-31

overall

overall

N (%)

1,302 (0.26%)

\<=60

overall

N (%)

1,302 (0.26%)

overall

Male

N (%)

589 (0.12%)

Female

N (%)

713 (0.14%)

\<=60

Male

N (%)

589 (0.12%)

Female

N (%)

713 (0.14%)

2008-01-01 to 2008-01-31

overall

overall

N (%)

1,285 (0.26%)

\<=60

overall

N (%)

1,285 (0.26%)

overall

Male

N (%)

572 (0.12%)

Female

N (%)

713 (0.14%)

\<=60

Male

N (%)

572 (0.12%)

Female

N (%)

713 (0.14%)

2008-02-01 to 2008-02-29

overall

overall

N (%)

1,189 (0.24%)

\<=60

overall

N (%)

1,189 (0.24%)

overall

Male

N (%)

522 (0.11%)

Female

N (%)

667 (0.14%)

\<=60

Male

N (%)

522 (0.11%)

Female

N (%)

667 (0.14%)

2008-03-01 to 2008-03-31

overall

overall

N (%)

1,228 (0.25%)

\<=60

overall

N (%)

1,228 (0.25%)

overall

Male

N (%)

558 (0.11%)

Female

N (%)

670 (0.14%)

\<=60

Male

N (%)

558 (0.11%)

Female

N (%)

670 (0.14%)

2008-04-01 to 2008-04-30

overall

overall

N (%)

1,098 (0.22%)

\<=60

overall

N (%)

1,098 (0.22%)

overall

Male

N (%)

540 (0.11%)

Female

N (%)

558 (0.11%)

\<=60

Male

N (%)

540 (0.11%)

Female

N (%)

558 (0.11%)

2008-05-01 to 2008-05-31

overall

overall

N (%)

1,116 (0.23%)

\<=60

overall

N (%)

1,116 (0.23%)

overall

Male

N (%)

558 (0.11%)

Female

N (%)

558 (0.11%)

\<=60

Male

N (%)

558 (0.11%)

Female

N (%)

558 (0.11%)

2008-06-01 to 2008-06-30

overall

overall

N (%)

1,065 (0.22%)

\<=60

overall

N (%)

1,065 (0.22%)

overall

Male

N (%)

525 (0.11%)

Female

N (%)

540 (0.11%)

\<=60

Male

N (%)

525 (0.11%)

Female

N (%)

540 (0.11%)

2008-07-01 to 2008-07-31

overall

overall

N (%)

1,085 (0.22%)

\<=60

overall

N (%)

1,085 (0.22%)

overall

Male

N (%)

527 (0.11%)

Female

N (%)

558 (0.11%)

\<=60

Male

N (%)

527 (0.11%)

Female

N (%)

558 (0.11%)

2008-08-01 to 2008-08-31

overall

overall

N (%)

1,063 (0.22%)

\<=60

overall

N (%)

1,063 (0.22%)

overall

Male

N (%)

505 (0.10%)

Female

N (%)

558 (0.11%)

\<=60

Male

N (%)

505 (0.10%)

Female

N (%)

558 (0.11%)

2008-09-01 to 2008-09-30

overall

overall

N (%)

1,019 (0.21%)

\<=60

overall

N (%)

1,019 (0.21%)

overall

Male

N (%)

479 (0.10%)

Female

N (%)

540 (0.11%)

\<=60

Male

N (%)

479 (0.10%)

Female

N (%)

540 (0.11%)

2008-10-01 to 2008-10-31

overall

overall

N (%)

1,023 (0.21%)

\<=60

overall

N (%)

1,023 (0.21%)

overall

Male

N (%)

465 (0.09%)

Female

N (%)

558 (0.11%)

\<=60

Male

N (%)

465 (0.09%)

Female

N (%)

558 (0.11%)

2008-11-01 to 2008-11-30

overall

overall

N (%)

990 (0.20%)

\<=60

overall

N (%)

990 (0.20%)

overall

Male

N (%)

450 (0.09%)

Female

N (%)

540 (0.11%)

\<=60

Male

N (%)

450 (0.09%)

Female

N (%)

540 (0.11%)

2008-12-01 to 2008-12-31

overall

overall

N (%)

991 (0.20%)

\<=60

overall

N (%)

991 (0.20%)

overall

Male

N (%)

465 (0.09%)

Female

N (%)

526 (0.11%)

\<=60

Male

N (%)

465 (0.09%)

Female

N (%)

526 (0.11%)

2009-01-01 to 2009-01-31

overall

overall

N (%)

961 (0.19%)

\<=60

overall

N (%)

961 (0.19%)

overall

Male

N (%)

465 (0.09%)

Female

N (%)

496 (0.10%)

\<=60

Male

N (%)

465 (0.09%)

Female

N (%)

496 (0.10%)

2009-02-01 to 2009-02-28

overall

overall

N (%)

868 (0.18%)

\<=60

overall

N (%)

868 (0.18%)

overall

Male

N (%)

420 (0.09%)

Female

N (%)

448 (0.09%)

\<=60

Male

N (%)

420 (0.09%)

Female

N (%)

448 (0.09%)

2009-03-01 to 2009-03-31

overall

overall

N (%)

961 (0.19%)

\<=60

overall

N (%)

961 (0.19%)

overall

Male

N (%)

465 (0.09%)

Female

N (%)

496 (0.10%)

\<=60

Male

N (%)

465 (0.09%)

Female

N (%)

496 (0.10%)

2009-04-01 to 2009-04-30

overall

overall

N (%)

904 (0.18%)

\<=60

overall

N (%)

904 (0.18%)

overall

Male

N (%)

424 (0.09%)

Female

N (%)

480 (0.10%)

\<=60

Male

N (%)

424 (0.09%)

Female

N (%)

480 (0.10%)

2009-05-01 to 2009-05-31

overall

overall

N (%)

930 (0.19%)

\<=60

overall

N (%)

930 (0.19%)

overall

Male

N (%)

434 (0.09%)

Female

N (%)

496 (0.10%)

\<=60

Male

N (%)

434 (0.09%)

Female

N (%)

496 (0.10%)

2009-06-01 to 2009-06-30

overall

overall

N (%)

917 (0.19%)

\<=60

overall

N (%)

917 (0.19%)

overall

Male

N (%)

437 (0.09%)

Female

N (%)

480 (0.10%)

\<=60

Male

N (%)

437 (0.09%)

Female

N (%)

480 (0.10%)

2009-07-01 to 2009-07-31

overall

overall

N (%)

961 (0.19%)

\<=60

overall

N (%)

961 (0.19%)

overall

Male

N (%)

465 (0.09%)

Female

N (%)

496 (0.10%)

\<=60

Male

N (%)

465 (0.09%)

Female

N (%)

496 (0.10%)

2009-08-01 to 2009-08-31

overall

overall

N (%)

961 (0.19%)

\<=60

overall

N (%)

961 (0.19%)

overall

Male

N (%)

465 (0.09%)

Female

N (%)

496 (0.10%)

\<=60

Male

N (%)

465 (0.09%)

Female

N (%)

496 (0.10%)

2009-09-01 to 2009-09-30

overall

overall

N (%)

930 (0.19%)

\<=60

overall

N (%)

930 (0.19%)

overall

Male

N (%)

450 (0.09%)

Female

N (%)

480 (0.10%)

\<=60

Male

N (%)

450 (0.09%)

Female

N (%)

480 (0.10%)

2009-10-01 to 2009-10-31

overall

overall

N (%)

961 (0.19%)

\<=60

overall

N (%)

961 (0.19%)

overall

Male

N (%)

465 (0.09%)

Female

N (%)

496 (0.10%)

\<=60

Male

N (%)

465 (0.09%)

Female

N (%)

496 (0.10%)

2009-11-01 to 2009-11-30

overall

overall

N (%)

946 (0.19%)

\<=60

overall

N (%)

946 (0.19%)

overall

Male

N (%)

462 (0.09%)

Female

N (%)

484 (0.10%)

\<=60

Male

N (%)

462 (0.09%)

Female

N (%)

484 (0.10%)

2009-12-01 to 2009-12-31

overall

overall

N (%)

997 (0.20%)

\<=60

overall

N (%)

997 (0.20%)

overall

Male

N (%)

496 (0.10%)

Female

N (%)

501 (0.10%)

\<=60

Male

N (%)

496 (0.10%)

Female

N (%)

501 (0.10%)

2010-01-01 to 2010-01-31

overall

overall

N (%)

992 (0.20%)

\<=60

overall

N (%)

992 (0.20%)

overall

Male

N (%)

496 (0.10%)

Female

N (%)

496 (0.10%)

\<=60

Male

N (%)

496 (0.10%)

Female

N (%)

496 (0.10%)

2010-02-01 to 2010-02-28

overall

overall

N (%)

896 (0.18%)

\<=60

overall

N (%)

896 (0.18%)

overall

Male

N (%)

448 (0.09%)

Female

N (%)

448 (0.09%)

\<=60

Male

N (%)

448 (0.09%)

Female

N (%)

448 (0.09%)

2010-03-01 to 2010-03-31

overall

overall

N (%)

964 (0.20%)

\<=60

overall

N (%)

964 (0.20%)

overall

Male

N (%)

468 (0.09%)

Female

N (%)

496 (0.10%)

\<=60

Male

N (%)

468 (0.09%)

Female

N (%)

496 (0.10%)

2010-04-01 to 2010-04-30

overall

overall

N (%)

930 (0.19%)

\<=60

overall

N (%)

930 (0.19%)

overall

Male

N (%)

450 (0.09%)

Female

N (%)

480 (0.10%)

\<=60

Male

N (%)

450 (0.09%)

Female

N (%)

480 (0.10%)

2010-05-01 to 2010-05-31

overall

overall

N (%)

960 (0.19%)

\<=60

overall

N (%)

960 (0.19%)

overall

Male

N (%)

465 (0.09%)

Female

N (%)

495 (0.10%)

\<=60

Male

N (%)

465 (0.09%)

Female

N (%)

495 (0.10%)

2010-06-01 to 2010-06-30

overall

overall

N (%)

900 (0.18%)

\<=60

overall

N (%)

900 (0.18%)

overall

Male

N (%)

450 (0.09%)

Female

N (%)

450 (0.09%)

\<=60

Male

N (%)

450 (0.09%)

Female

N (%)

450 (0.09%)

2010-07-01 to 2010-07-31

overall

overall

N (%)

930 (0.19%)

\<=60

overall

N (%)

930 (0.19%)

overall

Male

N (%)

465 (0.09%)

Female

N (%)

465 (0.09%)

\<=60

Male

N (%)

465 (0.09%)

Female

N (%)

465 (0.09%)

2010-08-01 to 2010-08-31

overall

overall

N (%)

924 (0.19%)

\<=60

overall

N (%)

924 (0.19%)

overall

Male

N (%)

459 (0.09%)

Female

N (%)

465 (0.09%)

\<=60

Male

N (%)

459 (0.09%)

Female

N (%)

465 (0.09%)

2010-09-01 to 2010-09-30

overall

overall

N (%)

870 (0.18%)

\<=60

overall

N (%)

870 (0.18%)

overall

Male

N (%)

420 (0.09%)

Female

N (%)

450 (0.09%)

\<=60

Male

N (%)

420 (0.09%)

Female

N (%)

450 (0.09%)

2010-10-01 to 2010-10-31

overall

overall

N (%)

929 (0.19%)

\<=60

overall

N (%)

929 (0.19%)

overall

Male

N (%)

434 (0.09%)

Female

N (%)

495 (0.10%)

\<=60

Male

N (%)

434 (0.09%)

Female

N (%)

495 (0.10%)

2010-11-01 to 2010-11-30

overall

overall

N (%)

911 (0.18%)

\<=60

overall

N (%)

911 (0.18%)

overall

Male

N (%)

445 (0.09%)

Female

N (%)

466 (0.09%)

\<=60

Male

N (%)

445 (0.09%)

Female

N (%)

466 (0.09%)

2010-12-01 to 2010-12-31

overall

overall

N (%)

930 (0.19%)

\<=60

overall

N (%)

930 (0.19%)

overall

Male

N (%)

465 (0.09%)

Female

N (%)

465 (0.09%)

\<=60

Male

N (%)

465 (0.09%)

Female

N (%)

465 (0.09%)

2011-01-01 to 2011-01-31

overall

overall

N (%)

930 (0.19%)

\<=60

overall

N (%)

930 (0.19%)

overall

Male

N (%)

465 (0.09%)

Female

N (%)

465 (0.09%)

\<=60

Male

N (%)

465 (0.09%)

Female

N (%)

465 (0.09%)

2011-02-01 to 2011-02-28

overall

overall

N (%)

840 (0.17%)

\<=60

overall

N (%)

840 (0.17%)

overall

Male

N (%)

420 (0.09%)

Female

N (%)

420 (0.09%)

\<=60

Male

N (%)

420 (0.09%)

Female

N (%)

420 (0.09%)

2011-03-01 to 2011-03-31

overall

overall

N (%)

930 (0.19%)

\<=60

overall

N (%)

930 (0.19%)

overall

Male

N (%)

465 (0.09%)

Female

N (%)

465 (0.09%)

\<=60

Male

N (%)

465 (0.09%)

Female

N (%)

465 (0.09%)

2011-04-01 to 2011-04-30

overall

overall

N (%)

900 (0.18%)

\<=60

overall

N (%)

900 (0.18%)

overall

Male

N (%)

450 (0.09%)

Female

N (%)

450 (0.09%)

\<=60

Male

N (%)

450 (0.09%)

Female

N (%)

450 (0.09%)

2011-05-01 to 2011-05-31

overall

overall

N (%)

930 (0.19%)

\<=60

overall

N (%)

930 (0.19%)

overall

Male

N (%)

465 (0.09%)

Female

N (%)

465 (0.09%)

\<=60

Male

N (%)

465 (0.09%)

Female

N (%)

465 (0.09%)

2011-06-01 to 2011-06-30

overall

overall

N (%)

900 (0.18%)

\<=60

overall

N (%)

900 (0.18%)

overall

Male

N (%)

450 (0.09%)

Female

N (%)

450 (0.09%)

\<=60

Male

N (%)

450 (0.09%)

Female

N (%)

450 (0.09%)

2011-07-01 to 2011-07-31

overall

overall

N (%)

952 (0.19%)

\<=60

overall

N (%)

952 (0.19%)

overall

Male

N (%)

487 (0.10%)

Female

N (%)

465 (0.09%)

\<=60

Male

N (%)

487 (0.10%)

Female

N (%)

465 (0.09%)

2011-08-01 to 2011-08-31

overall

overall

N (%)

961 (0.19%)

\<=60

overall

N (%)

961 (0.19%)

overall

Male

N (%)

496 (0.10%)

Female

N (%)

465 (0.09%)

\<=60

Male

N (%)

496 (0.10%)

Female

N (%)

465 (0.09%)

2011-09-01 to 2011-09-30

overall

overall

N (%)

930 (0.19%)

\<=60

overall

N (%)

930 (0.19%)

overall

Male

N (%)

480 (0.10%)

Female

N (%)

450 (0.09%)

\<=60

Male

N (%)

480 (0.10%)

Female

N (%)

450 (0.09%)

2011-10-01 to 2011-10-31

overall

overall

N (%)

961 (0.19%)

\<=60

overall

N (%)

961 (0.19%)

overall

Male

N (%)

496 (0.10%)

Female

N (%)

465 (0.09%)

\<=60

Male

N (%)

496 (0.10%)

Female

N (%)

465 (0.09%)

2011-11-01 to 2011-11-30

overall

overall

N (%)

930 (0.19%)

\<=60

overall

N (%)

930 (0.19%)

overall

Male

N (%)

480 (0.10%)

Female

N (%)

450 (0.09%)

\<=60

Male

N (%)

480 (0.10%)

Female

N (%)

450 (0.09%)

2011-12-01 to 2011-12-31

overall

overall

N (%)

961 (0.19%)

\<=60

overall

N (%)

961 (0.19%)

overall

Male

N (%)

496 (0.10%)

Female

N (%)

465 (0.09%)

\<=60

Male

N (%)

496 (0.10%)

Female

N (%)

465 (0.09%)

2012-01-01 to 2012-01-31

overall

overall

N (%)

961 (0.19%)

\<=60

overall

N (%)

961 (0.19%)

overall

Male

N (%)

496 (0.10%)

Female

N (%)

465 (0.09%)

\<=60

Male

N (%)

496 (0.10%)

Female

N (%)

465 (0.09%)

2012-02-01 to 2012-02-29

overall

overall

N (%)

899 (0.18%)

\<=60

overall

N (%)

899 (0.18%)

overall

Male

N (%)

464 (0.09%)

Female

N (%)

435 (0.09%)

\<=60

Male

N (%)

464 (0.09%)

Female

N (%)

435 (0.09%)

2012-03-01 to 2012-03-31

overall

overall

N (%)

961 (0.19%)

\<=60

overall

N (%)

961 (0.19%)

overall

Male

N (%)

496 (0.10%)

Female

N (%)

465 (0.09%)

\<=60

Male

N (%)

496 (0.10%)

Female

N (%)

465 (0.09%)

2012-04-01 to 2012-04-30

overall

overall

N (%)

921 (0.19%)

\<=60

overall

N (%)

921 (0.19%)

overall

Male

N (%)

480 (0.10%)

Female

N (%)

441 (0.09%)

\<=60

Male

N (%)

480 (0.10%)

Female

N (%)

441 (0.09%)

2012-05-01 to 2012-05-31

overall

overall

N (%)

961 (0.19%)

\<=60

overall

N (%)

961 (0.19%)

overall

Male

N (%)

496 (0.10%)

Female

N (%)

465 (0.09%)

\<=60

Male

N (%)

496 (0.10%)

Female

N (%)

465 (0.09%)

2012-06-01 to 2012-06-30

overall

overall

N (%)

915 (0.19%)

\<=60

overall

N (%)

915 (0.19%)

overall

Male

N (%)

465 (0.09%)

Female

N (%)

450 (0.09%)

\<=60

Male

N (%)

465 (0.09%)

Female

N (%)

450 (0.09%)

2012-07-01 to 2012-07-31

overall

overall

N (%)

930 (0.19%)

\<=60

overall

N (%)

930 (0.19%)

overall

Male

N (%)

465 (0.09%)

Female

N (%)

465 (0.09%)

\<=60

Male

N (%)

465 (0.09%)

Female

N (%)

465 (0.09%)

2012-08-01 to 2012-08-31

overall

overall

N (%)

911 (0.18%)

\<=60

overall

N (%)

911 (0.18%)

overall

Male

N (%)

446 (0.09%)

Female

N (%)

465 (0.09%)

\<=60

Male

N (%)

446 (0.09%)

Female

N (%)

465 (0.09%)

2012-09-01 to 2012-09-30

overall

overall

N (%)

852 (0.17%)

\<=60

overall

N (%)

852 (0.17%)

overall

Male

N (%)

402 (0.08%)

Female

N (%)

450 (0.09%)

\<=60

Male

N (%)

402 (0.08%)

Female

N (%)

450 (0.09%)

2012-10-01 to 2012-10-31

overall

overall

N (%)

841 (0.17%)

\<=60

overall

N (%)

841 (0.17%)

overall

Male

N (%)

403 (0.08%)

Female

N (%)

438 (0.09%)

\<=60

Male

N (%)

403 (0.08%)

Female

N (%)

438 (0.09%)

2012-11-01 to 2012-11-30

overall

overall

N (%)

780 (0.16%)

\<=60

overall

N (%)

780 (0.16%)

overall

Male

N (%)

390 (0.08%)

Female

N (%)

390 (0.08%)

\<=60

Male

N (%)

390 (0.08%)

Female

N (%)

390 (0.08%)

2012-12-01 to 2012-12-31

overall

overall

N (%)

831 (0.17%)

\<=60

overall

N (%)

831 (0.17%)

overall

Male

N (%)

403 (0.08%)

Female

N (%)

428 (0.09%)

\<=60

Male

N (%)

403 (0.08%)

Female

N (%)

428 (0.09%)

2013-01-01 to 2013-01-31

overall

overall

N (%)

837 (0.17%)

\<=60

overall

N (%)

837 (0.17%)

overall

Male

N (%)

403 (0.08%)

Female

N (%)

434 (0.09%)

\<=60

Male

N (%)

403 (0.08%)

Female

N (%)

434 (0.09%)

2013-02-01 to 2013-02-28

overall

overall

N (%)

738 (0.15%)

\<=60

overall

N (%)

738 (0.15%)

overall

Male

N (%)

364 (0.07%)

Female

N (%)

374 (0.08%)

\<=60

Male

N (%)

364 (0.07%)

Female

N (%)

374 (0.08%)

2013-03-01 to 2013-03-31

overall

overall

N (%)

806 (0.16%)

\<=60

overall

N (%)

806 (0.16%)

overall

Male

N (%)

403 (0.08%)

Female

N (%)

403 (0.08%)

\<=60

Male

N (%)

403 (0.08%)

Female

N (%)

403 (0.08%)

2013-04-01 to 2013-04-30

overall

overall

N (%)

780 (0.16%)

\<=60

overall

N (%)

780 (0.16%)

overall

Male

N (%)

390 (0.08%)

Female

N (%)

390 (0.08%)

\<=60

Male

N (%)

390 (0.08%)

Female

N (%)

390 (0.08%)

2013-05-01 to 2013-05-31

overall

overall

N (%)

806 (0.16%)

\<=60

overall

N (%)

806 (0.16%)

overall

Male

N (%)

403 (0.08%)

Female

N (%)

403 (0.08%)

\<=60

Male

N (%)

403 (0.08%)

Female

N (%)

403 (0.08%)

2013-06-01 to 2013-06-30

overall

overall

N (%)

780 (0.16%)

\<=60

overall

N (%)

780 (0.16%)

overall

Male

N (%)

372 (0.08%)

Female

N (%)

408 (0.08%)

\<=60

Male

N (%)

372 (0.08%)

Female

N (%)

408 (0.08%)

2013-07-01 to 2013-07-31

overall

overall

N (%)

806 (0.16%)

\<=60

overall

N (%)

806 (0.16%)

overall

Male

N (%)

372 (0.08%)

Female

N (%)

434 (0.09%)

\<=60

Male

N (%)

372 (0.08%)

Female

N (%)

434 (0.09%)

2013-08-01 to 2013-08-31

overall

overall

N (%)

804 (0.16%)

\<=60

overall

N (%)

804 (0.16%)

overall

Male

N (%)

372 (0.08%)

Female

N (%)

432 (0.09%)

\<=60

Male

N (%)

372 (0.08%)

Female

N (%)

432 (0.09%)

2013-09-01 to 2013-09-30

overall

overall

N (%)

750 (0.15%)

\<=60

overall

N (%)

750 (0.15%)

overall

Male

N (%)

360 (0.07%)

Female

N (%)

390 (0.08%)

\<=60

Male

N (%)

360 (0.07%)

Female

N (%)

390 (0.08%)

2013-10-01 to 2013-10-31

overall

overall

N (%)

775 (0.16%)

\<=60

overall

N (%)

775 (0.16%)

overall

Male

N (%)

372 (0.08%)

Female

N (%)

403 (0.08%)

\<=60

Male

N (%)

372 (0.08%)

Female

N (%)

403 (0.08%)

2013-11-01 to 2013-11-30

overall

overall

N (%)

750 (0.15%)

\<=60

overall

N (%)

750 (0.15%)

overall

Male

N (%)

360 (0.07%)

Female

N (%)

390 (0.08%)

\<=60

Male

N (%)

360 (0.07%)

Female

N (%)

390 (0.08%)

2013-12-01 to 2013-12-31

overall

overall

N (%)

775 (0.16%)

\<=60

overall

N (%)

775 (0.16%)

overall

Male

N (%)

372 (0.08%)

Female

N (%)

403 (0.08%)

\<=60

Male

N (%)

372 (0.08%)

Female

N (%)

403 (0.08%)

2014-01-01 to 2014-01-31

overall

overall

N (%)

775 (0.16%)

\<=60

overall

N (%)

775 (0.16%)

overall

Male

N (%)

372 (0.08%)

Female

N (%)

403 (0.08%)

\<=60

Male

N (%)

372 (0.08%)

Female

N (%)

403 (0.08%)

2014-02-01 to 2014-02-28

overall

overall

N (%)

700 (0.14%)

\<=60

overall

N (%)

700 (0.14%)

overall

Male

N (%)

336 (0.07%)

Female

N (%)

364 (0.07%)

\<=60

Male

N (%)

336 (0.07%)

Female

N (%)

364 (0.07%)

2014-03-01 to 2014-03-31

overall

overall

N (%)

775 (0.16%)

\<=60

overall

N (%)

775 (0.16%)

overall

Male

N (%)

372 (0.08%)

Female

N (%)

403 (0.08%)

\<=60

Male

N (%)

372 (0.08%)

Female

N (%)

403 (0.08%)

2014-04-01 to 2014-04-30

overall

overall

N (%)

732 (0.15%)

\<=60

overall

N (%)

732 (0.15%)

overall

Male

N (%)

366 (0.07%)

Female

N (%)

366 (0.07%)

\<=60

Male

N (%)

366 (0.07%)

Female

N (%)

366 (0.07%)

2014-05-01 to 2014-05-31

overall

overall

N (%)

767 (0.16%)

\<=60

overall

N (%)

767 (0.16%)

overall

Male

N (%)

403 (0.08%)

Female

N (%)

364 (0.07%)

\<=60

Male

N (%)

403 (0.08%)

Female

N (%)

364 (0.07%)

2014-06-01 to 2014-06-30

overall

overall

N (%)

720 (0.15%)

\<=60

overall

N (%)

720 (0.15%)

overall

Male

N (%)

390 (0.08%)

Female

N (%)

330 (0.07%)

\<=60

Male

N (%)

390 (0.08%)

Female

N (%)

330 (0.07%)

2014-07-01 to 2014-07-31

overall

overall

N (%)

744 (0.15%)

\<=60

overall

N (%)

744 (0.15%)

overall

Male

N (%)

403 (0.08%)

Female

N (%)

341 (0.07%)

\<=60

Male

N (%)

403 (0.08%)

Female

N (%)

341 (0.07%)

2014-08-01 to 2014-08-31

overall

overall

N (%)

751 (0.15%)

\<=60

overall

N (%)

751 (0.15%)

overall

Male

N (%)

403 (0.08%)

Female

N (%)

348 (0.07%)

\<=60

Male

N (%)

403 (0.08%)

Female

N (%)

348 (0.07%)

2014-09-01 to 2014-09-30

overall

overall

N (%)

720 (0.15%)

\<=60

overall

N (%)

720 (0.15%)

overall

Male

N (%)

390 (0.08%)

Female

N (%)

330 (0.07%)

\<=60

Male

N (%)

390 (0.08%)

Female

N (%)

330 (0.07%)

2014-10-01 to 2014-10-31

overall

overall

N (%)

744 (0.15%)

\<=60

overall

N (%)

744 (0.15%)

overall

Male

N (%)

403 (0.08%)

Female

N (%)

341 (0.07%)

\<=60

Male

N (%)

403 (0.08%)

Female

N (%)

341 (0.07%)

2014-11-01 to 2014-11-30

overall

overall

N (%)

720 (0.15%)

\<=60

overall

N (%)

720 (0.15%)

overall

Male

N (%)

390 (0.08%)

Female

N (%)

330 (0.07%)

\<=60

Male

N (%)

390 (0.08%)

Female

N (%)

330 (0.07%)

2014-12-01 to 2014-12-31

overall

overall

N (%)

744 (0.15%)

\<=60

overall

N (%)

744 (0.15%)

overall

Male

N (%)

403 (0.08%)

Female

N (%)

341 (0.07%)

\<=60

Male

N (%)

403 (0.08%)

Female

N (%)

341 (0.07%)

2015-01-01 to 2015-01-31

overall

overall

N (%)

744 (0.15%)

\<=60

overall

N (%)

744 (0.15%)

overall

Male

N (%)

403 (0.08%)

Female

N (%)

341 (0.07%)

\<=60

Male

N (%)

403 (0.08%)

Female

N (%)

341 (0.07%)

2015-02-01 to 2015-02-28

overall

overall

N (%)

672 (0.14%)

\<=60

overall

N (%)

672 (0.14%)

overall

Male

N (%)

364 (0.07%)

Female

N (%)

308 (0.06%)

\<=60

Male

N (%)

364 (0.07%)

Female

N (%)

308 (0.06%)

2015-03-01 to 2015-03-31

overall

overall

N (%)

744 (0.15%)

\<=60

overall

N (%)

744 (0.15%)

overall

Male

N (%)

403 (0.08%)

Female

N (%)

341 (0.07%)

\<=60

Male

N (%)

403 (0.08%)

Female

N (%)

341 (0.07%)

2015-04-01 to 2015-04-30

overall

overall

N (%)

720 (0.15%)

\<=60

overall

N (%)

720 (0.15%)

overall

Male

N (%)

390 (0.08%)

Female

N (%)

330 (0.07%)

\<=60

Male

N (%)

390 (0.08%)

Female

N (%)

330 (0.07%)

2015-05-01 to 2015-05-31

overall

overall

N (%)

721 (0.15%)

\<=60

overall

N (%)

721 (0.15%)

overall

Male

N (%)

403 (0.08%)

Female

N (%)

318 (0.06%)

\<=60

Male

N (%)

403 (0.08%)

Female

N (%)

318 (0.06%)

2015-06-01 to 2015-06-30

overall

overall

N (%)

690 (0.14%)

\<=60

overall

N (%)

690 (0.14%)

overall

Male

N (%)

390 (0.08%)

Female

N (%)

300 (0.06%)

\<=60

Male

N (%)

390 (0.08%)

Female

N (%)

300 (0.06%)

2015-07-01 to 2015-07-31

overall

overall

N (%)

713 (0.14%)

\<=60

overall

N (%)

713 (0.14%)

overall

Male

N (%)

403 (0.08%)

Female

N (%)

310 (0.06%)

\<=60

Male

N (%)

403 (0.08%)

Female

N (%)

310 (0.06%)

2015-08-01 to 2015-08-31

overall

overall

N (%)

690 (0.14%)

\<=60

overall

N (%)

690 (0.14%)

overall

Male

N (%)

403 (0.08%)

Female

N (%)

287 (0.06%)

\<=60

Male

N (%)

403 (0.08%)

Female

N (%)

287 (0.06%)

2015-09-01 to 2015-09-30

overall

overall

N (%)

660 (0.13%)

\<=60

overall

N (%)

660 (0.13%)

overall

Male

N (%)

390 (0.08%)

Female

N (%)

270 (0.05%)

\<=60

Male

N (%)

390 (0.08%)

Female

N (%)

270 (0.05%)

2015-10-01 to 2015-10-31

overall

overall

N (%)

682 (0.14%)

\<=60

overall

N (%)

682 (0.14%)

overall

Male

N (%)

403 (0.08%)

Female

N (%)

279 (0.06%)

\<=60

Male

N (%)

403 (0.08%)

Female

N (%)

279 (0.06%)

2015-11-01 to 2015-11-30

overall

overall

N (%)

660 (0.13%)

\<=60

overall

N (%)

660 (0.13%)

overall

Male

N (%)

390 (0.08%)

Female

N (%)

270 (0.05%)

\<=60

Male

N (%)

390 (0.08%)

Female

N (%)

270 (0.05%)

2015-12-01 to 2015-12-31

overall

overall

N (%)

694 (0.14%)

\<=60

overall

N (%)

694 (0.14%)

overall

Male

N (%)

400 (0.08%)

Female

N (%)

294 (0.06%)

\<=60

Male

N (%)

400 (0.08%)

Female

N (%)

294 (0.06%)

2016-01-01 to 2016-01-31

overall

overall

N (%)

682 (0.14%)

\<=60

overall

N (%)

682 (0.14%)

overall

Male

N (%)

372 (0.08%)

Female

N (%)

310 (0.06%)

\<=60

Male

N (%)

372 (0.08%)

Female

N (%)

310 (0.06%)

2016-02-01 to 2016-02-29

overall

overall

N (%)

605 (0.12%)

\<=60

overall

N (%)

576 (0.12%)

\>60

overall

N (%)

29 (0.01%)

overall

Male

N (%)

315 (0.06%)

Female

N (%)

290 (0.06%)

\<=60

Male

N (%)

315 (0.06%)

Female

N (%)

261 (0.05%)

\>60

Female

N (%)

29 (0.01%)

2016-03-01 to 2016-03-31

overall

overall

N (%)

640 (0.13%)

\<=60

overall

N (%)

609 (0.12%)

\>60

overall

N (%)

31 (0.01%)

overall

Male

N (%)

310 (0.06%)

Female

N (%)

330 (0.07%)

\>60

Female

N (%)

31 (0.01%)

\<=60

Male

N (%)

310 (0.06%)

Female

N (%)

299 (0.06%)

2016-04-01 to 2016-04-30

overall

overall

N (%)

660 (0.13%)

\<=60

overall

N (%)

630 (0.13%)

\>60

overall

N (%)

30 (0.01%)

overall

Male

N (%)

300 (0.06%)

Female

N (%)

360 (0.07%)

\<=60

Male

N (%)

300 (0.06%)

Female

N (%)

330 (0.07%)

\>60

Female

N (%)

30 (0.01%)

2016-05-01 to 2016-05-31

overall

overall

N (%)

692 (0.14%)

\<=60

overall

N (%)

661 (0.13%)

\>60

overall

N (%)

31 (0.01%)

overall

Male

N (%)

302 (0.06%)

Female

N (%)

390 (0.08%)

\<=60

Male

N (%)

302 (0.06%)

Female

N (%)

359 (0.07%)

\>60

Female

N (%)

31 (0.01%)

2016-06-01 to 2016-06-30

overall

overall

N (%)

642 (0.13%)

\>60

overall

N (%)

30 (0.01%)

\<=60

overall

N (%)

612 (0.12%)

overall

Male

N (%)

252 (0.05%)

Female

N (%)

390 (0.08%)

\>60

Female

N (%)

30 (0.01%)

\<=60

Male

N (%)

252 (0.05%)

Female

N (%)

360 (0.07%)

2016-07-01 to 2016-07-31

overall

overall

N (%)

671 (0.14%)

\<=60

overall

N (%)

640 (0.13%)

\>60

overall

N (%)

31 (0.01%)

overall

Male

N (%)

248 (0.05%)

Female

N (%)

423 (0.09%)

\>60

Female

N (%)

31 (0.01%)

\<=60

Male

N (%)

248 (0.05%)

Female

N (%)

392 (0.08%)

2016-08-01 to 2016-08-31

overall

overall

N (%)

701 (0.14%)

\>60

overall

N (%)

31 (0.01%)

\<=60

overall

N (%)

670 (0.14%)

overall

Male

N (%)

248 (0.05%)

Female

N (%)

453 (0.09%)

\>60

Female

N (%)

31 (0.01%)

\<=60

Male

N (%)

248 (0.05%)

Female

N (%)

422 (0.09%)

2016-09-01 to 2016-09-30

overall

overall

N (%)

690 (0.14%)

\>60

overall

N (%)

30 (0.01%)

\<=60

overall

N (%)

660 (0.13%)

overall

Male

N (%)

240 (0.05%)

Female

N (%)

450 (0.09%)

\<=60

Male

N (%)

240 (0.05%)

Female

N (%)

420 (0.09%)

\>60

Female

N (%)

30 (0.01%)

2016-10-01 to 2016-10-31

overall

overall

N (%)

713 (0.14%)

\>60

overall

N (%)

31 (0.01%)

\<=60

overall

N (%)

682 (0.14%)

overall

Male

N (%)

248 (0.05%)

Female

N (%)

465 (0.09%)

\<=60

Male

N (%)

248 (0.05%)

Female

N (%)

434 (0.09%)

\>60

Female

N (%)

31 (0.01%)

2016-11-01 to 2016-11-30

overall

overall

N (%)

718 (0.15%)

\<=60

overall

N (%)

688 (0.14%)

\>60

overall

N (%)

30 (0.01%)

overall

Male

N (%)

268 (0.05%)

Female

N (%)

450 (0.09%)

\>60

Female

N (%)

30 (0.01%)

\<=60

Male

N (%)

268 (0.05%)

Female

N (%)

420 (0.09%)

2016-12-01 to 2016-12-31

overall

overall

N (%)

744 (0.15%)

\<=60

overall

N (%)

713 (0.14%)

\>60

overall

N (%)

31 (0.01%)

overall

Male

N (%)

279 (0.06%)

Female

N (%)

465 (0.09%)

\<=60

Male

N (%)

279 (0.06%)

Female

N (%)

434 (0.09%)

\>60

Female

N (%)

31 (0.01%)

2017-01-01 to 2017-01-31

overall

overall

N (%)

744 (0.15%)

\>60

overall

N (%)

31 (0.01%)

\<=60

overall

N (%)

713 (0.14%)

overall

Male

N (%)

279 (0.06%)

Female

N (%)

465 (0.09%)

\>60

Female

N (%)

31 (0.01%)

\<=60

Male

N (%)

279 (0.06%)

Female

N (%)

434 (0.09%)

2017-02-01 to 2017-02-28

overall

overall

N (%)

672 (0.14%)

\<=60

overall

N (%)

644 (0.13%)

\>60

overall

N (%)

28 (0.01%)

overall

Male

N (%)

252 (0.05%)

Female

N (%)

420 (0.09%)

\<=60

Male

N (%)

252 (0.05%)

Female

N (%)

392 (0.08%)

\>60

Female

N (%)

28 (0.01%)

2017-03-01 to 2017-03-31

overall

overall

N (%)

763 (0.15%)

\>60

overall

N (%)

31 (0.01%)

\<=60

overall

N (%)

732 (0.15%)

overall

Male

N (%)

279 (0.06%)

Female

N (%)

484 (0.10%)

\>60

Female

N (%)

31 (0.01%)

\<=60

Male

N (%)

279 (0.06%)

Female

N (%)

453 (0.09%)

2017-04-01 to 2017-04-30

overall

overall

N (%)

750 (0.15%)

\<=60

overall

N (%)

720 (0.15%)

\>60

overall

N (%)

30 (0.01%)

overall

Male

N (%)

270 (0.05%)

Female

N (%)

480 (0.10%)

\>60

Female

N (%)

30 (0.01%)

\<=60

Male

N (%)

270 (0.05%)

Female

N (%)

450 (0.09%)

2017-05-01 to 2017-05-31

overall

overall

N (%)

756 (0.15%)

\<=60

overall

N (%)

725 (0.15%)

\>60

overall

N (%)

31 (0.01%)

overall

Male

N (%)

279 (0.06%)

Female

N (%)

477 (0.10%)

\>60

Female

N (%)

31 (0.01%)

\<=60

Male

N (%)

279 (0.06%)

Female

N (%)

446 (0.09%)

2017-06-01 to 2017-06-30

overall

overall

N (%)

720 (0.15%)

\>60

overall

N (%)

30 (0.01%)

\<=60

overall

N (%)

690 (0.14%)

overall

Male

N (%)

270 (0.05%)

Female

N (%)

450 (0.09%)

\<=60

Male

N (%)

270 (0.05%)

Female

N (%)

420 (0.09%)

\>60

Female

N (%)

30 (0.01%)

2017-07-01 to 2017-07-31

overall

overall

N (%)

751 (0.15%)

\<=60

overall

N (%)

720 (0.15%)

\>60

overall

N (%)

31 (0.01%)

overall

Male

N (%)

310 (0.06%)

Female

N (%)

441 (0.09%)

\>60

Female

N (%)

31 (0.01%)

\<=60

Male

N (%)

310 (0.06%)

Female

N (%)

410 (0.08%)

2017-08-01 to 2017-08-31

overall

overall

N (%)

692 (0.14%)

\<=60

overall

N (%)

661 (0.13%)

\>60

overall

N (%)

31 (0.01%)

overall

Male

N (%)

310 (0.06%)

Female

N (%)

382 (0.08%)

\<=60

Male

N (%)

310 (0.06%)

Female

N (%)

351 (0.07%)

\>60

Female

N (%)

31 (0.01%)

2017-09-01 to 2017-09-30

overall

overall

N (%)

618 (0.13%)

\<=60

overall

N (%)

588 (0.12%)

\>60

overall

N (%)

30 (0.01%)

overall

Male

N (%)

271 (0.05%)

Female

N (%)

347 (0.07%)

\<=60

Male

N (%)

271 (0.05%)

Female

N (%)

317 (0.06%)

\>60

Female

N (%)

30 (0.01%)

2017-10-01 to 2017-10-31

overall

overall

N (%)

620 (0.13%)

\>60

overall

N (%)

31 (0.01%)

\<=60

overall

N (%)

589 (0.12%)

overall

Male

N (%)

279 (0.06%)

Female

N (%)

341 (0.07%)

\<=60

Male

N (%)

279 (0.06%)

Female

N (%)

310 (0.06%)

\>60

Female

N (%)

31 (0.01%)

2017-11-01 to 2017-11-30

overall

overall

N (%)

600 (0.12%)

\<=60

overall

N (%)

570 (0.12%)

\>60

overall

N (%)

30 (0.01%)

overall

Male

N (%)

270 (0.05%)

Female

N (%)

330 (0.07%)

\>60

Female

N (%)

30 (0.01%)

\<=60

Male

N (%)

270 (0.05%)

Female

N (%)

300 (0.06%)

2017-12-01 to 2017-12-31

overall

overall

N (%)

596 (0.12%)

\<=60

overall

N (%)

565 (0.11%)

\>60

overall

N (%)

31 (0.01%)

overall

Male

N (%)

279 (0.06%)

Female

N (%)

317 (0.06%)

\>60

Female

N (%)

31 (0.01%)

\<=60

Male

N (%)

279 (0.06%)

Female

N (%)

286 (0.06%)

2018-01-01 to 2018-01-31

overall

overall

N (%)

543 (0.11%)

\>60

overall

N (%)

62 (0.01%)

\<=60

overall

N (%)

481 (0.10%)

overall

Male

N (%)

235 (0.05%)

Female

N (%)

308 (0.06%)

\>60

Female

N (%)

62 (0.01%)

\<=60

Male

N (%)

235 (0.05%)

Female

N (%)

246 (0.05%)

2018-02-01 to 2018-02-28

overall

overall

N (%)

448 (0.09%)

\>60

overall

N (%)

56 (0.01%)

\<=60

overall

N (%)

392 (0.08%)

overall

Male

N (%)

196 (0.04%)

Female

N (%)

252 (0.05%)

\>60

Female

N (%)

56 (0.01%)

\<=60

Male

N (%)

196 (0.04%)

Female

N (%)

196 (0.04%)

2018-03-01 to 2018-03-31

overall

overall

N (%)

475 (0.10%)

\>60

overall

N (%)

62 (0.01%)

\<=60

overall

N (%)

413 (0.08%)

overall

Male

N (%)

217 (0.04%)

Female

N (%)

258 (0.05%)

\<=60

Male

N (%)

217 (0.04%)

Female

N (%)

196 (0.04%)

\>60

Female

N (%)

62 (0.01%)

2018-04-01 to 2018-04-30

overall

overall

N (%)

466 (0.09%)

\<=60

overall

N (%)

406 (0.08%)

\>60

overall

N (%)

60 (0.01%)

overall

Male

N (%)

210 (0.04%)

Female

N (%)

256 (0.05%)

\>60

Female

N (%)

60 (0.01%)

\<=60

Male

N (%)

210 (0.04%)

Female

N (%)

196 (0.04%)

2018-05-01 to 2018-05-31

overall

overall

N (%)

496 (0.10%)

\<=60

overall

N (%)

434 (0.09%)

\>60

overall

N (%)

62 (0.01%)

overall

Male

N (%)

217 (0.04%)

Female

N (%)

279 (0.06%)

\<=60

Male

N (%)

217 (0.04%)

Female

N (%)

217 (0.04%)

\>60

Female

N (%)

62 (0.01%)

2018-06-01 to 2018-06-30

overall

overall

N (%)

465 (0.09%)

\>60

overall

N (%)

60 (0.01%)

\<=60

overall

N (%)

405 (0.08%)

overall

Male

N (%)

185 (0.04%)

Female

N (%)

280 (0.06%)

\<=60

Male

N (%)

185 (0.04%)

Female

N (%)

220 (0.04%)

\>60

Female

N (%)

60 (0.01%)

2018-07-01 to 2018-07-31

overall

overall

N (%)

464 (0.09%)

\<=60

overall

N (%)

402 (0.08%)

\>60

overall

N (%)

62 (0.01%)

overall

Male

N (%)

155 (0.03%)

Female

N (%)

309 (0.06%)

\>60

Female

N (%)

62 (0.01%)

\<=60

Male

N (%)

155 (0.03%)

Female

N (%)

247 (0.05%)

2018-08-01 to 2018-08-31

overall

overall

N (%)

430 (0.09%)

\>60

overall

N (%)

62 (0.01%)

\<=60

overall

N (%)

368 (0.07%)

overall

Male

N (%)

155 (0.03%)

Female

N (%)

275 (0.06%)

\<=60

Male

N (%)

155 (0.03%)

Female

N (%)

213 (0.04%)

\>60

Female

N (%)

62 (0.01%)

2018-09-01 to 2018-09-30

overall

overall

N (%)

357 (0.07%)

\<=60

overall

N (%)

297 (0.06%)

\>60

overall

N (%)

60 (0.01%)

overall

Male

N (%)

140 (0.03%)

Female

N (%)

217 (0.04%)

\<=60

Male

N (%)

140 (0.03%)

Female

N (%)

157 (0.03%)

\>60

Female

N (%)

60 (0.01%)

2018-10-01 to 2018-10-31

overall

overall

N (%)

350 (0.07%)

\<=60

overall

N (%)

288 (0.06%)

\>60

overall

N (%)

62 (0.01%)

overall

Male

N (%)

133 (0.03%)

Female

N (%)

217 (0.04%)

\<=60

Male

N (%)

133 (0.03%)

Female

N (%)

155 (0.03%)

\>60

Female

N (%)

62 (0.01%)

2018-11-01 to 2018-11-30

overall

overall

N (%)

288 (0.06%)

\>60

overall

N (%)

60 (0.01%)

\<=60

overall

N (%)

228 (0.05%)

overall

Male

N (%)

103 (0.02%)

Female

N (%)

185 (0.04%)

\<=60

Male

N (%)

103 (0.02%)

Female

N (%)

125 (0.03%)

\>60

Female

N (%)

60 (0.01%)

2018-12-01 to 2018-12-31

overall

overall

N (%)

279 (0.06%)

\<=60

overall

N (%)

217 (0.04%)

\>60

overall

N (%)

62 (0.01%)

overall

Female

N (%)

186 (0.04%)

Male

N (%)

93 (0.02%)

\<=60

Female

N (%)

124 (0.03%)

Male

N (%)

93 (0.02%)

\>60

Female

N (%)

62 (0.01%)

2019-01-01 to 2019-01-31

overall

overall

N (%)

268 (0.05%)

\>60

overall

N (%)

62 (0.01%)

\<=60

overall

N (%)

206 (0.04%)

overall

Female

N (%)

201 (0.04%)

Male

N (%)

67 (0.01%)

\>60

Female

N (%)

62 (0.01%)

\<=60

Female

N (%)

139 (0.03%)

Male

N (%)

67 (0.01%)

2019-02-01 to 2019-02-28

overall

overall

N (%)

144 (0.03%)

\>60

overall

N (%)

32 (0.01%)

\<=60

overall

N (%)

112 (0.02%)

overall

Female

N (%)

144 (0.03%)

\<=60

Female

N (%)

112 (0.02%)

\>60

Female

N (%)

32 (0.01%)

2019-03-01 to 2019-03-31

overall

overall

N (%)

155 (0.03%)

\<=60

overall

N (%)

124 (0.03%)

\>60

overall

N (%)

31 (0.01%)

overall

Female

N (%)

155 (0.03%)

\<=60

Female

N (%)

124 (0.03%)

\>60

Female

N (%)

31 (0.01%)

2019-04-01 to 2019-04-30

overall

overall

N (%)

150 (0.03%)

\<=60

overall

N (%)

120 (0.02%)

\>60

overall

N (%)

30 (0.01%)

overall

Female

N (%)

150 (0.03%)

\<=60

Female

N (%)

120 (0.02%)

\>60

Female

N (%)

30 (0.01%)

2019-05-01 to 2019-05-31

overall

overall

N (%)

152 (0.03%)

\<=60

overall

N (%)

123 (0.02%)

\>60

overall

N (%)

29 (0.01%)

overall

Female

N (%)

152 (0.03%)

\<=60

Female

N (%)

123 (0.02%)

\>60

Female

N (%)

29 (0.01%)

2019-06-01 to 2019-06-30

overall

overall

N (%)

91 (0.02%)

\<=60

overall

N (%)

91 (0.02%)

overall

Female

N (%)

91 (0.02%)

\<=60

Female

N (%)

91 (0.02%)

2019-07-01 to 2019-07-31

overall

overall

N (%)

95 (0.02%)

\<=60

overall

N (%)

95 (0.02%)

overall

Female

N (%)

95 (0.02%)

\<=60

Female

N (%)

95 (0.02%)

2019-08-01 to 2019-08-31

overall

overall

N (%)

93 (0.02%)

\<=60

overall

N (%)

93 (0.02%)

overall

Female

N (%)

93 (0.02%)

\<=60

Female

N (%)

93 (0.02%)

2019-09-01 to 2019-09-30

overall

overall

N (%)

90 (0.02%)

\<=60

overall

N (%)

90 (0.02%)

overall

Female

N (%)

90 (0.02%)

\<=60

Female

N (%)

90 (0.02%)

2019-10-01 to 2019-10-31

overall

overall

N (%)

69 (0.01%)

\<=60

overall

N (%)

69 (0.01%)

overall

Female

N (%)

69 (0.01%)

\<=60

Female

N (%)

69 (0.01%)

2019-11-01 to 2019-11-30

overall

overall

N (%)

44 (0.01%)

\<=60

overall

N (%)

44 (0.01%)

overall

Female

N (%)

44 (0.01%)

\<=60

Female

N (%)

44 (0.01%)

2019-12-01 to 2019-12-31

overall

overall

N (%)

3 (0.00%)

\<=60

overall

N (%)

3 (0.00%)

overall

Female

N (%)

3 (0.00%)

\<=60

Female

N (%)

3 (0.00%)

overall

overall

overall

N (%)

493,027 (100.00%)

\<=60

overall

N (%)

493,027 (100.00%)

overall

Male

N (%)

248,378 (50.38%)

Female

N (%)

244,649 (49.62%)

\<=60

Male

N (%)

248,378 (50.38%)

Female

N (%)

244,649 (49.62%)

PatientProfiles::[mockDisconnect](https://darwin-eu.github.io/PatientProfiles/reference/mockDisconnect.html)(cdm)
\# }
