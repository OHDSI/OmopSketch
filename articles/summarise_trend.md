# Summarise temporal trends in OMOP tables

## Introduction

In this vignette, we will explore the *OmopSketch* function
[`summariseTrend()`](https://OHDSI.github.io/OmopSketch/reference/summariseTrend.md),
which summarises temporal trends from OMOP CDM tables. This function
allows you to visualise how key measures (such as number of records,
number of persons, person-days, age, or sex distribution) change over
time.

### Create a mock cdm

Let’s start by loading essential packages and creating a mock CDM using
[`mockOmopSketch()`](https://OHDSI.github.io/OmopSketch/reference/mockOmopSketch.md)

``` r
library(duckdb)
#> Loading required package: DBI
library(OmopSketch)
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union


cdm <- mockOmopSketch()
#> ℹ Reading GiBleed tables.

cdm
#> 
#> ── # OMOP CDM reference (duckdb) of mockOmopSketch ─────────────────────────────
#> • omop tables: cdm_source, concept, concept_ancestor, concept_relationship,
#> concept_synonym, condition_occurrence, death, device_exposure, drug_exposure,
#> drug_strength, measurement, observation, observation_period, person,
#> procedure_occurrence, visit_occurrence, vocabulary
#> • cohort tables: -
#> • achilles tables: -
#> • other tables: -
```

## Summarise temporal trends

Let’s use
[`summariseTrend()`](https://OHDSI.github.io/OmopSketch/reference/summariseTrend.md)
to get an overview of the content of the table over time. In this
example, we’ll summarise yearly trends for *condition_occurrence* and
*drug_exposure* tables, and also include *observation_period* as an
episode table.

``` r
summarisedResult <- summariseTrend(
  cdm = cdm,
  event = c("condition_occurrence", "drug_exposure"),
  episode = "observation_period",
  interval = "years",
)

summarisedResult |> glimpse()
#> Rows: 396
#> Columns: 13
#> $ result_id        <int> 1, 1, 1, 1, 2, 2, 1, 1, 1, 1, 2, 2, 1, 1, 1, 1, 2, 2,…
#> $ cdm_name         <chr> "mockOmopSketch", "mockOmopSketch", "mockOmopSketch",…
#> $ group_name       <chr> "omop_table", "omop_table", "omop_table", "omop_table…
#> $ group_level      <chr> "condition_occurrence", "condition_occurrence", "drug…
#> $ strata_name      <chr> "overall", "overall", "overall", "overall", "overall"…
#> $ strata_level     <chr> "overall", "overall", "overall", "overall", "overall"…
#> $ variable_name    <chr> "Number of records", "Number of records", "Number of …
#> $ variable_level   <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
#> $ estimate_name    <chr> "count", "percentage", "count", "percentage", "count"…
#> $ estimate_type    <chr> "integer", "percentage", "integer", "percentage", "in…
#> $ estimate_value   <chr> "4", "0.05", "14", "0.06", "1", "1.00", "12", "0.14",…
#> $ additional_name  <chr> "time_interval", "time_interval", "time_interval", "t…
#> $ additional_level <chr> "1955-01-01 to 1955-12-31", "1955-01-01 to 1955-12-31…
```

Notice that the output is in the [summarised
result](https://darwin-eu.github.io/omopgenerics/articles/summarised_result.html)
format.

### What are Event and Episode tables?

- **Event** tables capture occurrences that happen at a single point in
  time (for example, a diagnosis, a prescription, or a measurement). For
  these tables, each record is linked to a time interval based only on
  its **start date**.

- **Episode** describe periods that span over time (for example,
  observation periods or treatment eras). Each record contributes to
  every time interval between its start and end dates, reflecting its
  entire duration within the study period.

You can check whether a table was treated as an event or an episode
table in the settings of the summarised result:

``` r
summarisedResult |>
  omopgenerics::addSettings(settingsColumn = "type") |>
  glimpse()
#> Rows: 396
#> Columns: 14
#> $ result_id        <int> 1, 1, 1, 1, 2, 2, 1, 1, 1, 1, 2, 2, 1, 1, 1, 1, 2, 2,…
#> $ cdm_name         <chr> "mockOmopSketch", "mockOmopSketch", "mockOmopSketch",…
#> $ group_name       <chr> "omop_table", "omop_table", "omop_table", "omop_table…
#> $ group_level      <chr> "condition_occurrence", "condition_occurrence", "drug…
#> $ strata_name      <chr> "overall", "overall", "overall", "overall", "overall"…
#> $ strata_level     <chr> "overall", "overall", "overall", "overall", "overall"…
#> $ variable_name    <chr> "Number of records", "Number of records", "Number of …
#> $ variable_level   <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
#> $ estimate_name    <chr> "count", "percentage", "count", "percentage", "count"…
#> $ estimate_type    <chr> "integer", "percentage", "integer", "percentage", "in…
#> $ estimate_value   <chr> "4", "0.05", "14", "0.06", "1", "1.00", "12", "0.14",…
#> $ additional_name  <chr> "time_interval", "time_interval", "time_interval", "t…
#> $ additional_level <chr> "1955-01-01 to 1955-12-31", "1955-01-01 to 1955-12-31…
#> $ type             <chr> "event", "event", "event", "event", "episode", "episo…
```

### Outputs

You can choose what to summarise using the `output` argument. Options
include:

- “record”: Number of records (default value)

- “person”: Number of distinct persons

- “person-days”: Number of person-days (episode tables only)

- “age”: Median age at start date of each interval

- “sex”: Number of females \### Records and subjects per year

For each time interval the results will include the number of records
and number of individuals observed during that period. In addition to
absolute counts, the function also reports the percentage of records and
individuals within each interval relative to the total counts in the
entire table.

``` r
summarisedResult <- summariseTrend(
  cdm = cdm,
  event = "condition_occurrence",
  output = c("record", "person"),
  interval = "years"
)


summarisedResult |>
  select(group_level, variable_name, additional_level, estimate_name, estimate_value)
#> # A tibble: 264 × 5
#>    group_level       variable_name additional_level estimate_name estimate_value
#>    <chr>             <chr>         <chr>            <chr>         <chr>         
#>  1 condition_occurr… Number of re… 1955-01-01 to 1… count         4             
#>  2 condition_occurr… Number of su… 1955-01-01 to 1… count         1             
#>  3 condition_occurr… Number of re… 1955-01-01 to 1… percentage    0.05          
#>  4 condition_occurr… Number of su… 1955-01-01 to 1… percentage    1.00          
#>  5 condition_occurr… Number of re… 1956-01-01 to 1… count         12            
#>  6 condition_occurr… Number of su… 1956-01-01 to 1… count         2             
#>  7 condition_occurr… Number of re… 1956-01-01 to 1… percentage    0.14          
#>  8 condition_occurr… Number of su… 1956-01-01 to 1… percentage    2.00          
#>  9 condition_occurr… Number of re… 1957-01-01 to 1… count         19            
#> 10 condition_occurr… Number of su… 1957-01-01 to 1… count         3             
#> # ℹ 254 more rows
```

#### Person-days

When an episode table is specified, you can include “person-days” in the
output to summarise total follow-up time across intervals. The results
will show both the number of person-days in each interval and the
percentage of person-days relative to the total accumulated across the
entire table.

``` r
summarisedResult <- summariseTrend(
  cdm = cdm,
  episode = "observation_period",
  output = "person-days",
  interval = "years"
)

summarisedResult |>
  select(group_level, variable_name, additional_level, estimate_name, estimate_value)
#> # A tibble: 132 × 5
#>    group_level       variable_name additional_level estimate_name estimate_value
#>    <chr>             <chr>         <chr>            <chr>         <chr>         
#>  1 observation_peri… Person-days   1955-01-01 to 1… count         181           
#>  2 observation_peri… Person-days   1955-01-01 to 1… percentage    0.05          
#>  3 observation_peri… Person-days   1956-01-01 to 1… count         507           
#>  4 observation_peri… Person-days   1956-01-01 to 1… percentage    0.15          
#>  5 observation_peri… Person-days   1957-01-01 to 1… count         825           
#>  6 observation_peri… Person-days   1957-01-01 to 1… percentage    0.24          
#>  7 observation_peri… Person-days   1958-01-01 to 1… count         1099          
#>  8 observation_peri… Person-days   1958-01-01 to 1… percentage    0.32          
#>  9 observation_peri… Person-days   1959-01-01 to 1… count         1124          
#> 10 observation_peri… Person-days   1959-01-01 to 1… percentage    0.32          
#> # ℹ 122 more rows
```

Note: The function will automatically skip “person-days” for event
tables.

``` r
summarisedResult <- summariseTrend(
  cdm = cdm,
  event = "visit_occurrence",
  output = "person-days",
  interval = "years"
)
#> → The number of person-days is not computed for event tables
summarisedResult |> print()
#> # A tibble: 0 × 13
#> # ℹ 13 variables: result_id <int>, cdm_name <chr>, group_name <chr>,
#> #   group_level <chr>, strata_name <chr>, strata_level <chr>,
#> #   variable_name <chr>, variable_level <chr>, estimate_name <chr>,
#> #   estimate_type <chr>, estimate_value <chr>, additional_name <chr>,
#> #   additional_level <chr>
```

#### Age

When “age” is included in the output argument, the function reports the
median age of individuals for each time interval. For every record, age
is calculated either at the start of the time interval or at the
record’s start date, whichever comes first. This allows you to examine
how the age distribution of individuals evolves over time for a given
event or episode table.

``` r
summarisedResult <- summariseTrend(
  cdm = cdm,
  event = "condition_occurrence",
  output = "age",
  interval = "years"
)

summarisedResult |>
  select(variable_name, additional_level, estimate_name, estimate_value)
#> # A tibble: 66 × 4
#>    variable_name additional_level         estimate_name estimate_value
#>    <chr>         <chr>                    <chr>         <chr>         
#>  1 Age           1955-01-01 to 1955-12-31 median        1             
#>  2 Age           1956-01-01 to 1956-12-31 median        2             
#>  3 Age           1957-01-01 to 1957-12-31 median        2             
#>  4 Age           1958-01-01 to 1958-12-31 median        1             
#>  5 Age           1959-01-01 to 1959-12-31 median        4             
#>  6 Age           1960-01-01 to 1960-12-31 median        4             
#>  7 Age           1961-01-01 to 1961-12-31 median        3             
#>  8 Age           1962-01-01 to 1962-12-31 median        4             
#>  9 Age           1963-01-01 to 1963-12-31 median        7             
#> 10 Age           1964-01-01 to 1964-12-31 median        8             
#> # ℹ 56 more rows
```

#### Sex output

When “sex” is included in the output argument, the function counts the
number of females in each time interval. It also provides the percentage
of females relative to the total number of individuals in the entire
table. This output is particularly useful for exploring changes in the
sex distribution of records over time.

``` r
summarisedResult <- summariseTrend(
  cdm = cdm,
  event = "condition_occurrence",
  output = "sex",
  interval = "years"
)
summarisedResult |>
  select(variable_name, additional_level, estimate_name, estimate_value)
#> # A tibble: 124 × 4
#>    variable_name     additional_level         estimate_name estimate_value
#>    <chr>             <chr>                    <chr>         <chr>         
#>  1 Number of females 1959-01-01 to 1959-12-31 count         1             
#>  2 Number of females 1959-01-01 to 1959-12-31 percentage    1.00          
#>  3 Number of females 1960-01-01 to 1960-12-31 count         1             
#>  4 Number of females 1960-01-01 to 1960-12-31 percentage    1.00          
#>  5 Number of females 1961-01-01 to 1961-12-31 count         1             
#>  6 Number of females 1961-01-01 to 1961-12-31 percentage    1.00          
#>  7 Number of females 1962-01-01 to 1962-12-31 count         1             
#>  8 Number of females 1962-01-01 to 1962-12-31 percentage    1.00          
#>  9 Number of females 1963-01-01 to 1963-12-31 count         1             
#> 10 Number of females 1963-01-01 to 1963-12-31 percentage    1.00          
#> # ℹ 114 more rows
```

### Intervals

The argument \`interval\`\` controls the temporal granularity of the
results. Possible values are “overall” (default, no stratification by
time), “years”, “quarters”, and “months”.

For example, to see quarterly trends:

``` r
summarisedResult <- summariseTrend(
  cdm = cdm,
  event = "condition_occurrence",
  interval = "quarters",
  output = "record"
)

summarisedResult |>
  select(additional_level, estimate_value)
#> # A tibble: 518 × 2
#>    additional_level         estimate_value
#>    <chr>                    <chr>         
#>  1 1955-07-01 to 1955-09-30 2             
#>  2 1955-07-01 to 1955-09-30 0.02          
#>  3 1955-10-01 to 1955-12-31 2             
#>  4 1955-10-01 to 1955-12-31 0.02          
#>  5 1956-01-01 to 1956-03-31 3             
#>  6 1956-01-01 to 1956-03-31 0.04          
#>  7 1956-04-01 to 1956-06-30 3             
#>  8 1956-04-01 to 1956-06-30 0.04          
#>  9 1956-07-01 to 1956-09-30 3             
#> 10 1956-07-01 to 1956-09-30 0.04          
#> # ℹ 508 more rows
```

### Stratify by age and sex

You can use the arguments `ageGroup` and `sex` to stratify the results.

``` r
summarisedResult <- summariseTrend(
  cdm = cdm,
  event = "condition_occurrence",
  interval = "years",
  output = c("record", "age", "sex"),
  ageGroup = list("<35" = c(0, 34), ">=35" = c(35, Inf)),
  sex = TRUE
)

summarisedResult |>
  select(variable_name, strata_level, estimate_name, estimate_value)
#> # A tibble: 1,774 × 4
#>    variable_name     strata_level estimate_name estimate_value
#>    <chr>             <chr>        <chr>         <chr>         
#>  1 Number of records overall      count         4             
#>  2 Number of records <35          count         4             
#>  3 Number of records Male         count         4             
#>  4 Number of records Male &&& <35 count         4             
#>  5 Age               overall      median        1             
#>  6 Age               <35          median        1             
#>  7 Age               Male         median        1             
#>  8 Age               Male &&& <35 median        1             
#>  9 Number of records overall      percentage    0.05          
#> 10 Number of records <35          percentage    0.05          
#> # ℹ 1,764 more rows
```

By default, the output includes the “overall” group as well as combined
strata (e.g., Female and \>=35). Note that for `output = "sex"`, sex
stratification is not applied because a single estimate summarising the
female population is returned.

### In-observation stratification

When `inObservation = TRUE`, the results will indicate whether each
record occurred within the subject’s observation period. This can be
useful for identifying data quality issues or assessing completeness.

``` r
summarisedResult <- summariseTrend(
  cdm = cdm,
  event = "condition_occurrence",
  interval = "overall",
  output = "record",
  inObservation = TRUE
)

summarisedResult |>
  select(variable_name, strata_name, strata_level, estimate_name, estimate_value)
#> # A tibble: 4 × 5
#>   variable_name     strata_name    strata_level estimate_name estimate_value
#>   <chr>             <chr>          <chr>        <chr>         <chr>         
#> 1 Number of records overall        overall      count         8400          
#> 2 Number of records in_observation TRUE         count         8400          
#> 3 Number of records overall        overall      percentage    100.00        
#> 4 Number of records in_observation TRUE         percentage    100.00
```

### Date Range

You can restrict the study period using the `dateRange` argument.

``` r
summarisedResult <- summariseTrend(
  cdm = cdm,
  event = "drug_exposure",
  dateRange = as.Date(c("1990-01-01", "2010-01-01"))
)

summarisedResult |>
  omopgenerics::settings() |>
  glimpse()
#> Rows: 1
#> Columns: 12
#> $ result_id          <int> 1
#> $ result_type        <chr> "summarise_trend"
#> $ package_name       <chr> "OmopSketch"
#> $ package_version    <chr> "0.5.1.900"
#> $ group              <chr> "omop_table"
#> $ strata             <chr> ""
#> $ additional         <chr> ""
#> $ min_cell_count     <chr> "0"
#> $ interval           <chr> "overall"
#> $ study_period_end   <chr> "2010-01-01"
#> $ study_period_start <chr> "1990-01-01"
#> $ type               <chr> "event"
```

## Tidy the summarised object with tableTrend

[`tableTrend()`](https://OHDSI.github.io/OmopSketch/reference/tableTrend.md)
helps you convert a summarised result into a nicely formatted table for
reporting or inspection (for example
[gt](https://OHDSI.github.io/OmopSketch/articles/) (default),
[flextable](https://OHDSI.github.io/OmopSketch/articles/)
[reactable](https://OHDSI.github.io/OmopSketch/articles/), or
[DT::datatable](https://OHDSI.github.io/OmopSketch/articles/)). It
formats time intervals, strata and estimate columns so the results are
easy to read and export.

``` r
result <- summariseTrend(
  cdm = cdm,
  event = "condition_occurrence",
  episode = "drug_exposure",
  output = "age",
  interval = "years"
)
tableTrend(result = result)
```

[TABLE]

Summary of Age by years in condition_occurrence, drug_exposure tables

## Visualise trends with plotTrend

[`plotTrend()`](https://OHDSI.github.io/OmopSketch/reference/plotTrend.md)
builds a ggplot2 visualisation from a summarised result.

``` r
result <- summariseTrend(cdm,
  event = "measurement", interval = "quarters", sex = TRUE, ageGroup = list(c(0, 17), c(18, Inf)),
  dateRange = as.Date(c("2010-01-01", "2019-12-31"))
)
#> → The observation period in the cdm ends in 2019-12-26
plotTrend(
  result,
  colour = "sex",
  facet = "age_group"
)
```

![](summarise_trend_files/figure-html/unnamed-chunk-15-1.png) When the
result includes several outputs (for example, records, persons, or
person-days), the function defaults to plotting the number of records.
You can override this by setting the output argument to the measure you
want to visualise.

``` r
result <- summariseTrend(cdm,
  event = "measurement",
  interval = "quarters",
  output = c("sex", "record"),
  dateRange = as.Date(c("2010-01-01", "2019-12-31"))
)
#> → The observation period in the cdm ends in 2019-12-26
plotTrend(
  result,
  output = "sex"
)
```

![](summarise_trend_files/figure-html/unnamed-chunk-16-1.png)

You can also specify facet (formula or column) and colour. Valid column
names are the tidied result columns (see visOmopResults::tidyColumns())

``` r
result <- summariseTrend(cdm,
  event = "measurement",
  interval = "quarters",
  sex = TRUE,
  inObservation = TRUE,
  dateRange = as.Date(c("2010-01-01", "2019-12-31"))
)
#> → The observation period in the cdm ends in 2019-12-26
plotTrend(
  result,
  facet = omop_table ~ sex,
  colour = "in_observation"
)
```

![](summarise_trend_files/figure-html/unnamed-chunk-17-1.png)

## Disconnect from CDM

Finally, disconnect from the mock CDM.

``` r
CDMConnector::cdmDisconnect(cdm = cdm)
```
