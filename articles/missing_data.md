# Summarise missing data

## Introduction

In this vignette, we explore how *OmopSketch* functions can serve as a
valuable tool for summarising missingness in databases containing
electronic health records mapped to the OMOP Common Data Model.

### Create a mock cdm

To illustrate the package’s functionality, we begin by loading the
required packages and connecting to a test CDM using the Eunomia
dataset.

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
library(DBI)
library(duckdb)
library(OmopSketch)


# Connect to Eunomia database
con <- dbConnect(drv = duckdb(dbdir = eunomiaDir()))
cdm <- cdmFromCon(
  con = con, cdmSchema = "main", writeSchema = "main", cdmName = "Eunomia"
)

cdm
#> 
#> ── # OMOP CDM reference (duckdb) of Eunomia ────────────────────────────────────
#> • omop tables: care_site, cdm_source, concept, concept_ancestor, concept_class,
#> concept_relationship, concept_synonym, condition_era, condition_occurrence,
#> cost, death, device_exposure, domain, dose_era, drug_era, drug_exposure,
#> drug_strength, fact_relationship, location, measurement, metadata, note,
#> note_nlp, observation, observation_period, payer_plan_period, person,
#> procedure_occurrence, provider, relationship, source_to_concept_map, specimen,
#> visit_detail, visit_occurrence, vocabulary
#> • cohort tables: -
#> • achilles tables: -
#> • other tables: -
```

### Summary of missing data

A common first step in data quality assessment is to identify missing
values. In this contest, missing data are defined as either NA values or
concept IDs equal to 0.

You can use the
[`summariseMissingData()`](https://OHDSI.github.io/OmopSketch/reference/summariseMissingData.md)
function to summarise missingness across the clinical tables in the CDM:

``` r
result_missingData <- summariseMissingData(cdm,
  omopTableName = "observation_period"
)
#> The person table has ≤ 1e+05 subjects; skipping sampling
#> of the CDM.

result_missingData |> glimpse()
#> Rows: 16
#> Columns: 13
#> $ result_id        <int> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
#> $ cdm_name         <chr> "Eunomia", "Eunomia", "Eunomia", "Eunomia", "Eunomia"…
#> $ group_name       <chr> "omop_table", "omop_table", "omop_table", "omop_table…
#> $ group_level      <chr> "observation_period", "observation_period", "observat…
#> $ strata_name      <chr> "overall", "overall", "overall", "overall", "overall"…
#> $ strata_level     <chr> "overall", "overall", "overall", "overall", "overall"…
#> $ variable_name    <chr> "Column name", "Column name", "Column name", "Column …
#> $ variable_level   <chr> "observation_period_id", "observation_period_id", "ob…
#> $ estimate_name    <chr> "na_count", "na_percentage", "zero_count", "zero_perc…
#> $ estimate_type    <chr> "integer", "percentage", "integer", "percentage", "in…
#> $ estimate_value   <chr> "0", "0.00", "0", "0.00", "0", "0.00", "0", "0.00", "…
#> $ additional_name  <chr> "overall", "overall", "overall", "overall", "overall"…
#> $ additional_level <chr> "overall", "overall", "overall", "overall", "overall"…
```

#### Summarise by OMOP CDM table

You can choose to summarise missing data for specific OMOP CDM tables
using the argument `omopTableName`.

``` r
result_missingData <- summariseMissingData(
  cdm = cdm,
  omopTableName = c("observation_period", "visit_occurrence", "condition_occurrence", "drug_exposure", "procedure_occurrence", "device_exposure", "measurement", "observation", "death")
)
```

#### Summarise by sex

You can choose to summarise missing data by sex by setting the argument
`sex` to `TRUE`.

``` r
result_missingData <- summariseMissingData(
  cdm = cdm,
  omopTableName = c("observation_period", "visit_occurrence", "condition_occurrence", "drug_exposure", "procedure_occurrence", "device_exposure", "measurement", "observation", "death"),
  sex = TRUE
)
```

#### Summarise by age group

You can choose to summarise missing data by age group by creating a list
defining the age groups you want to use.

``` r
result_missingData <- summariseMissingData(
  cdm = cdm,
  omopTableName = c("observation_period", "visit_occurrence", "condition_occurrence", "drug_exposure", "procedure_occurrence", "device_exposure", "measurement", "observation", "death"),
  ageGroup = list(c(0, 17), c(18, 64), c(65, 150))
)
```

#### Summarise by date and/or time interval

You can also summarise missing data within a specific date range or
across defined time intervals using the `dateRange` and `interval`
arguments. The `interval` argument supports “overall” (no time
stratification), “years”, “quarters”, or “months”.

``` r
result_missingData <- summariseMissingData(
  cdm = cdm,
  omopTableName = c("observation_period", "visit_occurrence", "condition_occurrence", "drug_exposure", "procedure_occurrence", "device_exposure", "measurement", "observation", "death"),
  interval = "years",
  dateRange = as.Date(c("2012-01-01", "2019-01-01"))
)
```

#### Summarise by column

You can also choose to summarise missing data for specific columns in
the OMOP CDM tables using the argument `col`.

``` r
result_missingData <- summariseMissingData(
  cdm = cdm,
  omopTableName = c("observation_period", "visit_occurrence", "condition_occurrence", "drug_exposure", "procedure_occurrence", "device_exposure", "measurement", "observation", "death"),
  col = c(
    "observation_period_start_date",
    "observation_period_end_date"
  )
)
```

#### Summarise in sample of OMOP CDM

Finally, you can summarise missing data on a subset of subjects via the
`sample` argument: provide an integer to randomly select that many
`person_id`s from the `person` table, or a character string naming a
`cohort` table to limit counts to its `subject_id`s.

``` r
result_missingData <- summariseMissingData(
  cdm = cdm,
  omopTableName = c("observation_period", "visit_occurrence", "condition_occurrence", "drug_exposure", "procedure_occurrence", "device_exposure", "measurement", "observation", "death"),
  sample = 1000
)
```

#### Visualise summary results

You can present these results using the function
[`tableMissingData()`](https://OHDSI.github.io/OmopSketch/reference/tableMissingData.md).

``` r
result_missingData <- summariseMissingData(cdm,
  omopTableName = c("condition_occurrence", "drug_exposure", "procedure_occurrence"),
  sex = TRUE,
  ageGroup = list(c(0, 17), c(18, 64), c(65, 150)),
  interval = "years",
  dateRange = as.Date(c("2012-01-01", "2019-01-01")),
  sample = 1000
)
result_missingData |> tableMissingData()
```

[TABLE]

Summary of missingness in condition_occurrence, drug_exposure,
procedure_occurrence tables

This table can either be of type [gt](https://gt.rstudio.com/) (default)
or [flextable](https://davidgohel.github.io/flextable/).

``` r
result_missingData |> tableMissingData(type = "flextable")
```

| Column name                              | Time interval            | Estimate name      | Database name   |
|------------------------------------------|--------------------------|--------------------|-----------------|
|                                          |                          |                    | Eunomia         |
| condition_occurrence; overall; overall   |                          |                    |                 |
| condition_concept_id                     | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| condition_end_date                       | 2012-01-01 to 2012-12-31 | N missing data (%) | 75 (20.95%)     |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 68 (18.48%)     |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 79 (21.07%)     |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 83 (22.55%)     |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 76 (21.90%)     |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 54 (15.34%)     |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 48 (13.60%)     |
|                                          | overall                  | N missing data (%) | 483 (19.16%)    |
| condition_end_datetime                   | 2012-01-01 to 2012-12-31 | N missing data (%) | 75 (20.95%)     |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 68 (18.48%)     |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 79 (21.07%)     |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 83 (22.55%)     |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 76 (21.90%)     |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 54 (15.34%)     |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 48 (13.60%)     |
|                                          | overall                  | N missing data (%) | 483 (19.16%)    |
| condition_occurrence_id                  | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| condition_source_concept_id              | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| condition_source_value                   | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| condition_start_date                     | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| condition_start_datetime                 | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| condition_status_concept_id              | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 358 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 368 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 375 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 368 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 347 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 352 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 353 (100.00%)   |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 2,521 (100.00%) |
| condition_status_source_value            | 2012-01-01 to 2012-12-31 | N missing data (%) | 358 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 368 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 375 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 368 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 347 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 352 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 353 (100.00%)   |
|                                          | overall                  | N missing data (%) | 2,521 (100.00%) |
| condition_type_concept_id                | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| person_id                                | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| provider_id                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 358 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 368 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 375 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 368 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 347 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 352 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 353 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 2,521 (100.00%) |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| stop_reason                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 358 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 368 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 375 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 368 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 347 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 352 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 353 (100.00%)   |
|                                          | overall                  | N missing data (%) | 2,521 (100.00%) |
| visit_detail_id                          | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 358 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 368 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 375 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 368 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 347 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 352 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 353 (100.00%)   |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 2,521 (100.00%) |
| visit_occurrence_id                      | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 1 (0.27%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 1 (0.28%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 2 (0.08%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| condition_occurrence; 65 to 150; overall |                          |                    |                 |
| condition_concept_id                     | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| condition_end_date                       | 2012-01-01 to 2012-12-31 | N missing data (%) | 10 (14.71%)     |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 9 (12.68%)      |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 11 (16.67%)     |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 12 (15.58%)     |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 17 (21.79%)     |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 15 (15.15%)     |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 8 (8.42%)       |
|                                          | overall                  | N missing data (%) | 82 (14.80%)     |
| condition_end_datetime                   | 2012-01-01 to 2012-12-31 | N missing data (%) | 10 (14.71%)     |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 9 (12.68%)      |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 11 (16.67%)     |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 12 (15.58%)     |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 17 (21.79%)     |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 15 (15.15%)     |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 8 (8.42%)       |
|                                          | overall                  | N missing data (%) | 82 (14.80%)     |
| condition_occurrence_id                  | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| condition_source_concept_id              | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| condition_source_value                   | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| condition_start_date                     | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| condition_start_datetime                 | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| condition_status_concept_id              | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 68 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 71 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 66 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 77 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 78 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 99 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 95 (100.00%)    |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 554 (100.00%)   |
| condition_status_source_value            | 2012-01-01 to 2012-12-31 | N missing data (%) | 68 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 71 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 66 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 77 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 78 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 99 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 95 (100.00%)    |
|                                          | overall                  | N missing data (%) | 554 (100.00%)   |
| condition_type_concept_id                | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| person_id                                | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| provider_id                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 68 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 71 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 66 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 77 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 78 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 99 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 95 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 554 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| stop_reason                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 68 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 71 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 66 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 77 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 78 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 99 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 95 (100.00%)    |
|                                          | overall                  | N missing data (%) | 554 (100.00%)   |
| visit_detail_id                          | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 68 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 71 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 66 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 77 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 78 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 99 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 95 (100.00%)    |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 554 (100.00%)   |
| visit_occurrence_id                      | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| condition_occurrence; 18 to 64; overall  |                          |                    |                 |
| condition_concept_id                     | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| condition_end_date                       | 2012-01-01 to 2012-12-31 | N missing data (%) | 65 (22.41%)     |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 59 (19.87%)     |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 68 (22.01%)     |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 71 (24.40%)     |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 59 (21.93%)     |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 39 (15.42%)     |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 40 (15.50%)     |
|                                          | overall                  | N missing data (%) | 401 (20.39%)    |
| condition_end_datetime                   | 2012-01-01 to 2012-12-31 | N missing data (%) | 65 (22.41%)     |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 59 (19.87%)     |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 68 (22.01%)     |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 71 (24.40%)     |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 59 (21.93%)     |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 39 (15.42%)     |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 40 (15.50%)     |
|                                          | overall                  | N missing data (%) | 401 (20.39%)    |
| condition_occurrence_id                  | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| condition_source_concept_id              | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| condition_source_value                   | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| condition_start_date                     | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| condition_start_datetime                 | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| condition_status_concept_id              | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 290 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 297 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 309 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 291 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 269 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 253 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 258 (100.00%)   |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 1,967 (100.00%) |
| condition_status_source_value            | 2012-01-01 to 2012-12-31 | N missing data (%) | 290 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 297 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 309 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 291 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 269 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 253 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 258 (100.00%)   |
|                                          | overall                  | N missing data (%) | 1,967 (100.00%) |
| condition_type_concept_id                | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| person_id                                | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| provider_id                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 290 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 297 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 309 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 291 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 269 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 253 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 258 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 1,967 (100.00%) |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| stop_reason                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 290 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 297 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 309 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 291 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 269 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 253 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 258 (100.00%)   |
|                                          | overall                  | N missing data (%) | 1,967 (100.00%) |
| visit_detail_id                          | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 290 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 297 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 309 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 291 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 269 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 253 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 258 (100.00%)   |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 1,967 (100.00%) |
| visit_occurrence_id                      | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 1 (0.34%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 1 (0.40%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 2 (0.10%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| condition_occurrence; overall; Male      |                          |                    |                 |
| condition_concept_id                     | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| condition_end_date                       | 2012-01-01 to 2012-12-31 | N missing data (%) | 47 (24.87%)     |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 36 (19.25%)     |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 43 (23.37%)     |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 38 (20.21%)     |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 36 (22.22%)     |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 29 (15.93%)     |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 20 (11.56%)     |
|                                          | overall                  | N missing data (%) | 249 (19.68%)    |
| condition_end_datetime                   | 2012-01-01 to 2012-12-31 | N missing data (%) | 47 (24.87%)     |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 36 (19.25%)     |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 43 (23.37%)     |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 38 (20.21%)     |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 36 (22.22%)     |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 29 (15.93%)     |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 20 (11.56%)     |
|                                          | overall                  | N missing data (%) | 249 (19.68%)    |
| condition_occurrence_id                  | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| condition_source_concept_id              | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| condition_source_value                   | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| condition_start_date                     | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| condition_start_datetime                 | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| condition_status_concept_id              | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 189 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 187 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 184 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 188 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 162 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 182 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 173 (100.00%)   |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 1,265 (100.00%) |
| condition_status_source_value            | 2012-01-01 to 2012-12-31 | N missing data (%) | 189 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 187 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 184 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 188 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 162 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 182 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 173 (100.00%)   |
|                                          | overall                  | N missing data (%) | 1,265 (100.00%) |
| condition_type_concept_id                | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| person_id                                | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| provider_id                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 189 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 187 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 184 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 188 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 162 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 182 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 173 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 1,265 (100.00%) |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| stop_reason                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 189 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 187 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 184 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 188 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 162 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 182 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 173 (100.00%)   |
|                                          | overall                  | N missing data (%) | 1,265 (100.00%) |
| visit_detail_id                          | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 189 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 187 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 184 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 188 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 162 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 182 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 173 (100.00%)   |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 1,265 (100.00%) |
| visit_occurrence_id                      | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 1 (0.55%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 1 (0.08%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| condition_occurrence; overall; Female    |                          |                    |                 |
| condition_concept_id                     | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| condition_end_date                       | 2012-01-01 to 2012-12-31 | N missing data (%) | 28 (16.57%)     |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 32 (17.68%)     |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 36 (18.85%)     |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 45 (25.00%)     |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 40 (21.62%)     |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 25 (14.71%)     |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 28 (15.56%)     |
|                                          | overall                  | N missing data (%) | 234 (18.63%)    |
| condition_end_datetime                   | 2012-01-01 to 2012-12-31 | N missing data (%) | 28 (16.57%)     |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 32 (17.68%)     |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 36 (18.85%)     |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 45 (25.00%)     |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 40 (21.62%)     |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 25 (14.71%)     |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 28 (15.56%)     |
|                                          | overall                  | N missing data (%) | 234 (18.63%)    |
| condition_occurrence_id                  | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| condition_source_concept_id              | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| condition_source_value                   | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| condition_start_date                     | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| condition_start_datetime                 | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| condition_status_concept_id              | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 169 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 181 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 191 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 180 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 185 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 170 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 180 (100.00%)   |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 1,256 (100.00%) |
| condition_status_source_value            | 2012-01-01 to 2012-12-31 | N missing data (%) | 169 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 181 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 191 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 180 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 185 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 170 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 180 (100.00%)   |
|                                          | overall                  | N missing data (%) | 1,256 (100.00%) |
| condition_type_concept_id                | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| person_id                                | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| provider_id                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 169 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 181 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 191 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 180 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 185 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 170 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 180 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 1,256 (100.00%) |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| stop_reason                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 169 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 181 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 191 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 180 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 185 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 170 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 180 (100.00%)   |
|                                          | overall                  | N missing data (%) | 1,256 (100.00%) |
| visit_detail_id                          | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 169 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 181 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 191 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 180 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 185 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 170 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 180 (100.00%)   |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 1,256 (100.00%) |
| visit_occurrence_id                      | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 1 (0.56%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 1 (0.08%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| condition_occurrence; 65 to 150; Male    |                          |                    |                 |
| condition_concept_id                     | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| condition_end_date                       | 2012-01-01 to 2012-12-31 | N missing data (%) | 6 (15.38%)      |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 8 (24.24%)      |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 7 (18.42%)      |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 6 (19.35%)      |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 8 (25.00%)      |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 8 (18.60%)      |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 3 (6.52%)       |
|                                          | overall                  | N missing data (%) | 46 (17.56%)     |
| condition_end_datetime                   | 2012-01-01 to 2012-12-31 | N missing data (%) | 6 (15.38%)      |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 8 (24.24%)      |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 7 (18.42%)      |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 6 (19.35%)      |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 8 (25.00%)      |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 8 (18.60%)      |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 3 (6.52%)       |
|                                          | overall                  | N missing data (%) | 46 (17.56%)     |
| condition_occurrence_id                  | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| condition_source_concept_id              | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| condition_source_value                   | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| condition_start_date                     | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| condition_start_datetime                 | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| condition_status_concept_id              | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 39 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 33 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 38 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 31 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 32 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 43 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 46 (100.00%)    |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 262 (100.00%)   |
| condition_status_source_value            | 2012-01-01 to 2012-12-31 | N missing data (%) | 39 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 33 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 38 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 31 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 32 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 43 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 46 (100.00%)    |
|                                          | overall                  | N missing data (%) | 262 (100.00%)   |
| condition_type_concept_id                | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| person_id                                | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| provider_id                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 39 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 33 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 38 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 31 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 32 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 43 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 46 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 262 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| stop_reason                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 39 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 33 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 38 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 31 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 32 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 43 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 46 (100.00%)    |
|                                          | overall                  | N missing data (%) | 262 (100.00%)   |
| visit_detail_id                          | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 39 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 33 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 38 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 31 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 32 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 43 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 46 (100.00%)    |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 262 (100.00%)   |
| visit_occurrence_id                      | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| condition_occurrence; 65 to 150; Female  |                          |                    |                 |
| condition_concept_id                     | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| condition_end_date                       | 2012-01-01 to 2012-12-31 | N missing data (%) | 4 (13.79%)      |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 1 (2.63%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 4 (14.29%)      |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 6 (13.04%)      |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 9 (19.57%)      |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 7 (12.50%)      |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 5 (10.20%)      |
|                                          | overall                  | N missing data (%) | 36 (12.33%)     |
| condition_end_datetime                   | 2012-01-01 to 2012-12-31 | N missing data (%) | 4 (13.79%)      |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 1 (2.63%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 4 (14.29%)      |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 6 (13.04%)      |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 9 (19.57%)      |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 7 (12.50%)      |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 5 (10.20%)      |
|                                          | overall                  | N missing data (%) | 36 (12.33%)     |
| condition_occurrence_id                  | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| condition_source_concept_id              | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| condition_source_value                   | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| condition_start_date                     | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| condition_start_datetime                 | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| condition_status_concept_id              | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 29 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 38 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 28 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 46 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 46 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 56 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 49 (100.00%)    |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 292 (100.00%)   |
| condition_status_source_value            | 2012-01-01 to 2012-12-31 | N missing data (%) | 29 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 38 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 28 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 46 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 46 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 56 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 49 (100.00%)    |
|                                          | overall                  | N missing data (%) | 292 (100.00%)   |
| condition_type_concept_id                | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| person_id                                | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| provider_id                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 29 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 38 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 28 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 46 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 46 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 56 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 49 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 292 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| stop_reason                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 29 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 38 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 28 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 46 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 46 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 56 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 49 (100.00%)    |
|                                          | overall                  | N missing data (%) | 292 (100.00%)   |
| visit_detail_id                          | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 29 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 38 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 28 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 46 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 46 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 56 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 49 (100.00%)    |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 292 (100.00%)   |
| visit_occurrence_id                      | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| condition_occurrence; 18 to 64; Male     |                          |                    |                 |
| condition_concept_id                     | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| condition_end_date                       | 2012-01-01 to 2012-12-31 | N missing data (%) | 41 (27.33%)     |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 28 (18.18%)     |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 36 (24.66%)     |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 32 (20.38%)     |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 28 (21.54%)     |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 21 (15.11%)     |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 17 (13.39%)     |
|                                          | overall                  | N missing data (%) | 203 (20.24%)    |
| condition_end_datetime                   | 2012-01-01 to 2012-12-31 | N missing data (%) | 41 (27.33%)     |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 28 (18.18%)     |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 36 (24.66%)     |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 32 (20.38%)     |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 28 (21.54%)     |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 21 (15.11%)     |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 17 (13.39%)     |
|                                          | overall                  | N missing data (%) | 203 (20.24%)    |
| condition_occurrence_id                  | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| condition_source_concept_id              | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| condition_source_value                   | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| condition_start_date                     | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| condition_start_datetime                 | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| condition_status_concept_id              | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 150 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 154 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 146 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 157 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 130 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 139 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 127 (100.00%)   |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 1,003 (100.00%) |
| condition_status_source_value            | 2012-01-01 to 2012-12-31 | N missing data (%) | 150 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 154 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 146 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 157 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 130 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 139 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 127 (100.00%)   |
|                                          | overall                  | N missing data (%) | 1,003 (100.00%) |
| condition_type_concept_id                | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| person_id                                | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| provider_id                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 150 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 154 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 146 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 157 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 130 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 139 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 127 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 1,003 (100.00%) |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| stop_reason                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 150 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 154 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 146 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 157 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 130 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 139 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 127 (100.00%)   |
|                                          | overall                  | N missing data (%) | 1,003 (100.00%) |
| visit_detail_id                          | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 150 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 154 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 146 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 157 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 130 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 139 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 127 (100.00%)   |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 1,003 (100.00%) |
| visit_occurrence_id                      | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 1 (0.72%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 1 (0.10%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| condition_occurrence; 18 to 64; Female   |                          |                    |                 |
| condition_concept_id                     | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| condition_end_date                       | 2012-01-01 to 2012-12-31 | N missing data (%) | 24 (17.14%)     |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 31 (21.68%)     |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 32 (19.63%)     |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 39 (29.10%)     |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 31 (22.30%)     |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 18 (15.79%)     |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 23 (17.56%)     |
|                                          | overall                  | N missing data (%) | 198 (20.54%)    |
| condition_end_datetime                   | 2012-01-01 to 2012-12-31 | N missing data (%) | 24 (17.14%)     |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 31 (21.68%)     |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 32 (19.63%)     |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 39 (29.10%)     |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 31 (22.30%)     |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 18 (15.79%)     |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 23 (17.56%)     |
|                                          | overall                  | N missing data (%) | 198 (20.54%)    |
| condition_occurrence_id                  | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| condition_source_concept_id              | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| condition_source_value                   | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| condition_start_date                     | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| condition_start_datetime                 | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| condition_status_concept_id              | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 140 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 143 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 163 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 134 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 139 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 114 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 131 (100.00%)   |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 964 (100.00%)   |
| condition_status_source_value            | 2012-01-01 to 2012-12-31 | N missing data (%) | 140 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 143 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 163 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 134 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 139 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 114 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 131 (100.00%)   |
|                                          | overall                  | N missing data (%) | 964 (100.00%)   |
| condition_type_concept_id                | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| person_id                                | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| provider_id                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 140 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 143 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 163 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 134 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 139 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 114 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 131 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 964 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| stop_reason                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 140 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 143 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 163 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 134 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 139 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 114 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 131 (100.00%)   |
|                                          | overall                  | N missing data (%) | 964 (100.00%)   |
| visit_detail_id                          | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 140 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 143 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 163 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 134 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 139 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 114 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 131 (100.00%)   |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 964 (100.00%)   |
| visit_occurrence_id                      | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 1 (0.75%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 1 (0.10%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| drug_exposure; overall; overall          |                          |                    |                 |
| days_supply                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| dose_unit_source_value                   | 2012-01-01 to 2012-12-31 | N missing data (%) | 469 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 452 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 488 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 439 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 410 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 436 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 414 (100.00%)   |
|                                          | overall                  | N missing data (%) | 3,108 (100.00%) |
| drug_concept_id                          | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| drug_exposure_end_date                   | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| drug_exposure_end_datetime               | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| drug_exposure_id                         | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| drug_exposure_start_date                 | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| drug_exposure_start_datetime             | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| drug_source_concept_id                   | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| drug_source_value                        | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| drug_type_concept_id                     | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| lot_number                               | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| person_id                                | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| provider_id                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 469 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 452 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 488 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 439 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 410 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 436 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 414 (100.00%)   |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 3,108 (100.00%) |
| quantity                                 | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| refills                                  | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| route_concept_id                         | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 469 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 452 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 488 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 439 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 410 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 436 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 414 (100.00%)   |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 3,108 (100.00%) |
| route_source_value                       | 2012-01-01 to 2012-12-31 | N missing data (%) | 469 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 452 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 488 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 439 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 410 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 436 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 414 (100.00%)   |
|                                          | overall                  | N missing data (%) | 3,108 (100.00%) |
| sig                                      | 2012-01-01 to 2012-12-31 | N missing data (%) | 469 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 452 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 488 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 439 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 410 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 436 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 414 (100.00%)   |
|                                          | overall                  | N missing data (%) | 3,108 (100.00%) |
| stop_reason                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 469 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 452 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 488 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 439 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 410 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 436 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 414 (100.00%)   |
|                                          | overall                  | N missing data (%) | 3,108 (100.00%) |
| verbatim_end_date                        | 2012-01-01 to 2012-12-31 | N missing data (%) | 60 (12.79%)     |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 61 (13.50%)     |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 62 (12.70%)     |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 54 (12.30%)     |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 60 (14.63%)     |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 59 (13.53%)     |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 50 (12.08%)     |
|                                          | overall                  | N missing data (%) | 406 (13.06%)    |
| visit_detail_id                          | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 469 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 452 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 488 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 439 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 410 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 436 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 414 (100.00%)   |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 3,108 (100.00%) |
| visit_occurrence_id                      | 2012-01-01 to 2012-12-31 | N missing data (%) | 2 (0.43%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 1 (0.22%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 7 (1.43%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 1 (0.23%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 3 (0.73%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 5 (1.15%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 2 (0.48%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 21 (0.68%)      |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| drug_exposure; 18 to 64; overall         |                          |                    |                 |
| days_supply                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| dose_unit_source_value                   | 2012-01-01 to 2012-12-31 | N missing data (%) | 369 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 370 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 397 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 349 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 298 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 295 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 284 (100.00%)   |
|                                          | overall                  | N missing data (%) | 2,362 (100.00%) |
| drug_concept_id                          | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| drug_exposure_end_date                   | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| drug_exposure_end_datetime               | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| drug_exposure_id                         | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| drug_exposure_start_date                 | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| drug_exposure_start_datetime             | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| drug_source_concept_id                   | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| drug_source_value                        | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| drug_type_concept_id                     | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| lot_number                               | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| person_id                                | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| provider_id                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 369 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 370 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 397 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 349 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 298 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 295 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 284 (100.00%)   |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 2,362 (100.00%) |
| quantity                                 | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| refills                                  | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| route_concept_id                         | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 369 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 370 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 397 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 349 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 298 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 295 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 284 (100.00%)   |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 2,362 (100.00%) |
| route_source_value                       | 2012-01-01 to 2012-12-31 | N missing data (%) | 369 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 370 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 397 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 349 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 298 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 295 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 284 (100.00%)   |
|                                          | overall                  | N missing data (%) | 2,362 (100.00%) |
| sig                                      | 2012-01-01 to 2012-12-31 | N missing data (%) | 369 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 370 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 397 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 349 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 298 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 295 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 284 (100.00%)   |
|                                          | overall                  | N missing data (%) | 2,362 (100.00%) |
| stop_reason                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 369 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 370 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 397 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 349 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 298 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 295 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 284 (100.00%)   |
|                                          | overall                  | N missing data (%) | 2,362 (100.00%) |
| verbatim_end_date                        | 2012-01-01 to 2012-12-31 | N missing data (%) | 45 (12.20%)     |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 42 (11.35%)     |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 47 (11.84%)     |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 39 (11.17%)     |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 41 (13.76%)     |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 32 (10.85%)     |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 31 (10.92%)     |
|                                          | overall                  | N missing data (%) | 277 (11.73%)    |
| visit_detail_id                          | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 369 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 370 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 397 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 349 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 298 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 295 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 284 (100.00%)   |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 2,362 (100.00%) |
| visit_occurrence_id                      | 2012-01-01 to 2012-12-31 | N missing data (%) | 1 (0.27%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 1 (0.27%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 6 (1.51%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 1 (0.29%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 2 (0.67%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 4 (1.36%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 1 (0.35%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 16 (0.68%)      |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| drug_exposure; 65 to 150; overall        |                          |                    |                 |
| days_supply                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| dose_unit_source_value                   | 2012-01-01 to 2012-12-31 | N missing data (%) | 100 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 82 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 91 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 90 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 112 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 141 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 130 (100.00%)   |
|                                          | overall                  | N missing data (%) | 746 (100.00%)   |
| drug_concept_id                          | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| drug_exposure_end_date                   | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| drug_exposure_end_datetime               | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| drug_exposure_id                         | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| drug_exposure_start_date                 | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| drug_exposure_start_datetime             | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| drug_source_concept_id                   | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| drug_source_value                        | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| drug_type_concept_id                     | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| lot_number                               | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| person_id                                | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| provider_id                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 100 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 82 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 91 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 90 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 112 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 141 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 130 (100.00%)   |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 746 (100.00%)   |
| quantity                                 | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| refills                                  | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| route_concept_id                         | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 100 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 82 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 91 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 90 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 112 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 141 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 130 (100.00%)   |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 746 (100.00%)   |
| route_source_value                       | 2012-01-01 to 2012-12-31 | N missing data (%) | 100 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 82 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 91 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 90 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 112 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 141 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 130 (100.00%)   |
|                                          | overall                  | N missing data (%) | 746 (100.00%)   |
| sig                                      | 2012-01-01 to 2012-12-31 | N missing data (%) | 100 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 82 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 91 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 90 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 112 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 141 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 130 (100.00%)   |
|                                          | overall                  | N missing data (%) | 746 (100.00%)   |
| stop_reason                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 100 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 82 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 91 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 90 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 112 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 141 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 130 (100.00%)   |
|                                          | overall                  | N missing data (%) | 746 (100.00%)   |
| verbatim_end_date                        | 2012-01-01 to 2012-12-31 | N missing data (%) | 15 (15.00%)     |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 19 (23.17%)     |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 15 (16.48%)     |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 15 (16.67%)     |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 19 (16.96%)     |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 27 (19.15%)     |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 19 (14.62%)     |
|                                          | overall                  | N missing data (%) | 129 (17.29%)    |
| visit_detail_id                          | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 100 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 82 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 91 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 90 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 112 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 141 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 130 (100.00%)   |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 746 (100.00%)   |
| visit_occurrence_id                      | 2012-01-01 to 2012-12-31 | N missing data (%) | 1 (1.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 1 (1.10%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 1 (0.89%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 1 (0.71%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 1 (0.77%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 5 (0.67%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| drug_exposure; overall; Male             |                          |                    |                 |
| days_supply                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| dose_unit_source_value                   | 2012-01-01 to 2012-12-31 | N missing data (%) | 252 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 228 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 240 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 221 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 192 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 224 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 205 (100.00%)   |
|                                          | overall                  | N missing data (%) | 1,562 (100.00%) |
| drug_concept_id                          | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| drug_exposure_end_date                   | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| drug_exposure_end_datetime               | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| drug_exposure_id                         | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| drug_exposure_start_date                 | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| drug_exposure_start_datetime             | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| drug_source_concept_id                   | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| drug_source_value                        | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| drug_type_concept_id                     | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| lot_number                               | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| person_id                                | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| provider_id                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 252 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 228 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 240 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 221 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 192 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 224 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 205 (100.00%)   |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 1,562 (100.00%) |
| quantity                                 | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| refills                                  | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| route_concept_id                         | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 252 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 228 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 240 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 221 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 192 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 224 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 205 (100.00%)   |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 1,562 (100.00%) |
| route_source_value                       | 2012-01-01 to 2012-12-31 | N missing data (%) | 252 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 228 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 240 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 221 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 192 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 224 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 205 (100.00%)   |
|                                          | overall                  | N missing data (%) | 1,562 (100.00%) |
| sig                                      | 2012-01-01 to 2012-12-31 | N missing data (%) | 252 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 228 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 240 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 221 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 192 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 224 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 205 (100.00%)   |
|                                          | overall                  | N missing data (%) | 1,562 (100.00%) |
| stop_reason                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 252 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 228 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 240 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 221 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 192 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 224 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 205 (100.00%)   |
|                                          | overall                  | N missing data (%) | 1,562 (100.00%) |
| verbatim_end_date                        | 2012-01-01 to 2012-12-31 | N missing data (%) | 40 (15.87%)     |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 40 (17.54%)     |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 35 (14.58%)     |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 26 (11.76%)     |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 28 (14.58%)     |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 34 (15.18%)     |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 26 (12.68%)     |
|                                          | overall                  | N missing data (%) | 229 (14.66%)    |
| visit_detail_id                          | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 252 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 228 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 240 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 221 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 192 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 224 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 205 (100.00%)   |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 1,562 (100.00%) |
| visit_occurrence_id                      | 2012-01-01 to 2012-12-31 | N missing data (%) | 2 (0.79%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 1 (0.44%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 6 (2.50%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 2 (0.89%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 1 (0.49%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 12 (0.77%)      |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| drug_exposure; overall; Female           |                          |                    |                 |
| days_supply                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| dose_unit_source_value                   | 2012-01-01 to 2012-12-31 | N missing data (%) | 217 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 224 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 248 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 218 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 218 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 212 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 209 (100.00%)   |
|                                          | overall                  | N missing data (%) | 1,546 (100.00%) |
| drug_concept_id                          | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| drug_exposure_end_date                   | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| drug_exposure_end_datetime               | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| drug_exposure_id                         | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| drug_exposure_start_date                 | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| drug_exposure_start_datetime             | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| drug_source_concept_id                   | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| drug_source_value                        | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| drug_type_concept_id                     | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| lot_number                               | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| person_id                                | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| provider_id                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 217 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 224 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 248 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 218 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 218 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 212 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 209 (100.00%)   |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 1,546 (100.00%) |
| quantity                                 | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| refills                                  | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| route_concept_id                         | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 217 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 224 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 248 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 218 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 218 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 212 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 209 (100.00%)   |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 1,546 (100.00%) |
| route_source_value                       | 2012-01-01 to 2012-12-31 | N missing data (%) | 217 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 224 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 248 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 218 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 218 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 212 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 209 (100.00%)   |
|                                          | overall                  | N missing data (%) | 1,546 (100.00%) |
| sig                                      | 2012-01-01 to 2012-12-31 | N missing data (%) | 217 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 224 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 248 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 218 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 218 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 212 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 209 (100.00%)   |
|                                          | overall                  | N missing data (%) | 1,546 (100.00%) |
| stop_reason                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 217 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 224 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 248 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 218 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 218 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 212 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 209 (100.00%)   |
|                                          | overall                  | N missing data (%) | 1,546 (100.00%) |
| verbatim_end_date                        | 2012-01-01 to 2012-12-31 | N missing data (%) | 20 (9.22%)      |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 21 (9.38%)      |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 27 (10.89%)     |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 28 (12.84%)     |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 32 (14.68%)     |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 25 (11.79%)     |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 24 (11.48%)     |
|                                          | overall                  | N missing data (%) | 177 (11.45%)    |
| visit_detail_id                          | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 217 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 224 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 248 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 218 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 218 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 212 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 209 (100.00%)   |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 1,546 (100.00%) |
| visit_occurrence_id                      | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 1 (0.40%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 1 (0.46%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 3 (1.38%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 3 (1.42%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 1 (0.48%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 9 (0.58%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| drug_exposure; 65 to 150; Female         |                          |                    |                 |
| days_supply                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| dose_unit_source_value                   | 2012-01-01 to 2012-12-31 | N missing data (%) | 43 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 39 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 43 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 49 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 49 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 71 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 71 (100.00%)    |
|                                          | overall                  | N missing data (%) | 365 (100.00%)   |
| drug_concept_id                          | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| drug_exposure_end_date                   | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| drug_exposure_end_datetime               | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| drug_exposure_id                         | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| drug_exposure_start_date                 | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| drug_exposure_start_datetime             | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| drug_source_concept_id                   | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| drug_source_value                        | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| drug_type_concept_id                     | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| lot_number                               | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| person_id                                | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| provider_id                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 43 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 39 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 43 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 49 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 49 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 71 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 71 (100.00%)    |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 365 (100.00%)   |
| quantity                                 | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| refills                                  | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| route_concept_id                         | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 43 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 39 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 43 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 49 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 49 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 71 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 71 (100.00%)    |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 365 (100.00%)   |
| route_source_value                       | 2012-01-01 to 2012-12-31 | N missing data (%) | 43 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 39 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 43 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 49 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 49 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 71 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 71 (100.00%)    |
|                                          | overall                  | N missing data (%) | 365 (100.00%)   |
| sig                                      | 2012-01-01 to 2012-12-31 | N missing data (%) | 43 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 39 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 43 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 49 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 49 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 71 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 71 (100.00%)    |
|                                          | overall                  | N missing data (%) | 365 (100.00%)   |
| stop_reason                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 43 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 39 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 43 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 49 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 49 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 71 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 71 (100.00%)    |
|                                          | overall                  | N missing data (%) | 365 (100.00%)   |
| verbatim_end_date                        | 2012-01-01 to 2012-12-31 | N missing data (%) | 3 (6.98%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 2 (5.13%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 7 (16.28%)      |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 11 (22.45%)     |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 9 (18.37%)      |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 13 (18.31%)     |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 9 (12.68%)      |
|                                          | overall                  | N missing data (%) | 54 (14.79%)     |
| visit_detail_id                          | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 43 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 39 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 43 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 49 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 49 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 71 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 71 (100.00%)    |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 365 (100.00%)   |
| visit_occurrence_id                      | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 1 (2.04%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 1 (1.41%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 2 (0.55%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| drug_exposure; 65 to 150; Male           |                          |                    |                 |
| days_supply                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| dose_unit_source_value                   | 2012-01-01 to 2012-12-31 | N missing data (%) | 57 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 43 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 48 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 41 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 63 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 70 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 59 (100.00%)    |
|                                          | overall                  | N missing data (%) | 381 (100.00%)   |
| drug_concept_id                          | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| drug_exposure_end_date                   | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| drug_exposure_end_datetime               | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| drug_exposure_id                         | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| drug_exposure_start_date                 | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| drug_exposure_start_datetime             | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| drug_source_concept_id                   | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| drug_source_value                        | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| drug_type_concept_id                     | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| lot_number                               | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| person_id                                | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| provider_id                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 57 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 43 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 48 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 41 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 63 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 70 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 59 (100.00%)    |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 381 (100.00%)   |
| quantity                                 | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| refills                                  | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| route_concept_id                         | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 57 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 43 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 48 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 41 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 63 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 70 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 59 (100.00%)    |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 381 (100.00%)   |
| route_source_value                       | 2012-01-01 to 2012-12-31 | N missing data (%) | 57 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 43 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 48 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 41 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 63 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 70 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 59 (100.00%)    |
|                                          | overall                  | N missing data (%) | 381 (100.00%)   |
| sig                                      | 2012-01-01 to 2012-12-31 | N missing data (%) | 57 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 43 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 48 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 41 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 63 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 70 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 59 (100.00%)    |
|                                          | overall                  | N missing data (%) | 381 (100.00%)   |
| stop_reason                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 57 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 43 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 48 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 41 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 63 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 70 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 59 (100.00%)    |
|                                          | overall                  | N missing data (%) | 381 (100.00%)   |
| verbatim_end_date                        | 2012-01-01 to 2012-12-31 | N missing data (%) | 12 (21.05%)     |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 17 (39.53%)     |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 8 (16.67%)      |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 4 (9.76%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 10 (15.87%)     |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 14 (20.00%)     |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 10 (16.95%)     |
|                                          | overall                  | N missing data (%) | 75 (19.69%)     |
| visit_detail_id                          | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 57 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 43 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 48 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 41 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 63 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 70 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 59 (100.00%)    |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 381 (100.00%)   |
| visit_occurrence_id                      | 2012-01-01 to 2012-12-31 | N missing data (%) | 1 (1.75%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 1 (2.08%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 1 (1.43%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 3 (0.79%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| drug_exposure; 18 to 64; Female          |                          |                    |                 |
| days_supply                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| dose_unit_source_value                   | 2012-01-01 to 2012-12-31 | N missing data (%) | 174 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 185 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 205 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 169 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 169 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 141 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 138 (100.00%)   |
|                                          | overall                  | N missing data (%) | 1,181 (100.00%) |
| drug_concept_id                          | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| drug_exposure_end_date                   | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| drug_exposure_end_datetime               | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| drug_exposure_id                         | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| drug_exposure_start_date                 | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| drug_exposure_start_datetime             | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| drug_source_concept_id                   | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| drug_source_value                        | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| drug_type_concept_id                     | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| lot_number                               | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| person_id                                | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| provider_id                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 174 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 185 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 205 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 169 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 169 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 141 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 138 (100.00%)   |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 1,181 (100.00%) |
| quantity                                 | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| refills                                  | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| route_concept_id                         | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 174 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 185 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 205 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 169 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 169 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 141 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 138 (100.00%)   |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 1,181 (100.00%) |
| route_source_value                       | 2012-01-01 to 2012-12-31 | N missing data (%) | 174 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 185 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 205 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 169 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 169 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 141 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 138 (100.00%)   |
|                                          | overall                  | N missing data (%) | 1,181 (100.00%) |
| sig                                      | 2012-01-01 to 2012-12-31 | N missing data (%) | 174 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 185 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 205 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 169 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 169 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 141 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 138 (100.00%)   |
|                                          | overall                  | N missing data (%) | 1,181 (100.00%) |
| stop_reason                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 174 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 185 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 205 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 169 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 169 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 141 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 138 (100.00%)   |
|                                          | overall                  | N missing data (%) | 1,181 (100.00%) |
| verbatim_end_date                        | 2012-01-01 to 2012-12-31 | N missing data (%) | 17 (9.77%)      |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 19 (10.27%)     |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 20 (9.76%)      |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 17 (10.06%)     |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 23 (13.61%)     |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 12 (8.51%)      |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 15 (10.87%)     |
|                                          | overall                  | N missing data (%) | 123 (10.41%)    |
| visit_detail_id                          | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 174 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 185 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 205 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 169 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 169 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 141 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 138 (100.00%)   |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 1,181 (100.00%) |
| visit_occurrence_id                      | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 1 (0.49%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 1 (0.59%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 2 (1.18%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 3 (2.13%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 7 (0.59%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| drug_exposure; 18 to 64; Male            |                          |                    |                 |
| days_supply                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| dose_unit_source_value                   | 2012-01-01 to 2012-12-31 | N missing data (%) | 195 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 185 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 192 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 180 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 129 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 154 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 146 (100.00%)   |
|                                          | overall                  | N missing data (%) | 1,181 (100.00%) |
| drug_concept_id                          | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| drug_exposure_end_date                   | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| drug_exposure_end_datetime               | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| drug_exposure_id                         | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| drug_exposure_start_date                 | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| drug_exposure_start_datetime             | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| drug_source_concept_id                   | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| drug_source_value                        | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| drug_type_concept_id                     | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| lot_number                               | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| person_id                                | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| provider_id                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 195 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 185 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 192 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 180 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 129 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 154 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 146 (100.00%)   |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 1,181 (100.00%) |
| quantity                                 | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| refills                                  | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| route_concept_id                         | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 195 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 185 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 192 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 180 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 129 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 154 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 146 (100.00%)   |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 1,181 (100.00%) |
| route_source_value                       | 2012-01-01 to 2012-12-31 | N missing data (%) | 195 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 185 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 192 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 180 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 129 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 154 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 146 (100.00%)   |
|                                          | overall                  | N missing data (%) | 1,181 (100.00%) |
| sig                                      | 2012-01-01 to 2012-12-31 | N missing data (%) | 195 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 185 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 192 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 180 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 129 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 154 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 146 (100.00%)   |
|                                          | overall                  | N missing data (%) | 1,181 (100.00%) |
| stop_reason                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 195 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 185 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 192 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 180 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 129 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 154 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 146 (100.00%)   |
|                                          | overall                  | N missing data (%) | 1,181 (100.00%) |
| verbatim_end_date                        | 2012-01-01 to 2012-12-31 | N missing data (%) | 28 (14.36%)     |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 23 (12.43%)     |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 27 (14.06%)     |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 22 (12.22%)     |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 18 (13.95%)     |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 20 (12.99%)     |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 16 (10.96%)     |
|                                          | overall                  | N missing data (%) | 154 (13.04%)    |
| visit_detail_id                          | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 195 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 185 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 192 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 180 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 129 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 154 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 146 (100.00%)   |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 1,181 (100.00%) |
| visit_occurrence_id                      | 2012-01-01 to 2012-12-31 | N missing data (%) | 1 (0.51%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 1 (0.54%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 5 (2.60%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 1 (0.65%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 1 (0.68%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 9 (0.76%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| procedure_occurrence; overall; overall   |                          |                    |                 |
| modifier_concept_id                      | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 146 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 147 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 122 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 131 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 109 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 120 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 132 (100.00%)   |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 907 (100.00%)   |
| modifier_source_value                    | 2012-01-01 to 2012-12-31 | N missing data (%) | 146 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 147 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 122 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 131 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 109 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 120 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 132 (100.00%)   |
|                                          | overall                  | N missing data (%) | 907 (100.00%)   |
| person_id                                | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| procedure_concept_id                     | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| procedure_date                           | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| procedure_datetime                       | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| procedure_occurrence_id                  | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| procedure_source_concept_id              | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| procedure_source_value                   | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| procedure_type_concept_id                | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| provider_id                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 146 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 147 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 122 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 131 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 109 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 120 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 132 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 907 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| quantity                                 | 2012-01-01 to 2012-12-31 | N missing data (%) | 146 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 147 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 122 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 131 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 109 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 120 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 132 (100.00%)   |
|                                          | overall                  | N missing data (%) | 907 (100.00%)   |
| visit_detail_id                          | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 146 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 147 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 122 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 131 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 109 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 120 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 132 (100.00%)   |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 907 (100.00%)   |
| visit_occurrence_id                      | 2012-01-01 to 2012-12-31 | N missing data (%) | 5 (3.42%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 4 (2.72%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 1 (0.82%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 2 (1.67%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 3 (2.27%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 15 (1.65%)      |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| procedure_occurrence; 65 to 150; overall |                          |                    |                 |
| modifier_concept_id                      | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 57 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 48 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 52 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 59 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 50 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 59 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 72 (100.00%)    |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 397 (100.00%)   |
| modifier_source_value                    | 2012-01-01 to 2012-12-31 | N missing data (%) | 57 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 48 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 52 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 59 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 50 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 59 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 72 (100.00%)    |
|                                          | overall                  | N missing data (%) | 397 (100.00%)   |
| person_id                                | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| procedure_concept_id                     | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| procedure_date                           | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| procedure_datetime                       | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| procedure_occurrence_id                  | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| procedure_source_concept_id              | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| procedure_source_value                   | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| procedure_type_concept_id                | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| provider_id                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 57 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 48 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 52 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 59 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 50 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 59 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 72 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 397 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| quantity                                 | 2012-01-01 to 2012-12-31 | N missing data (%) | 57 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 48 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 52 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 59 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 50 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 59 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 72 (100.00%)    |
|                                          | overall                  | N missing data (%) | 397 (100.00%)   |
| visit_detail_id                          | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 57 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 48 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 52 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 59 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 50 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 59 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 72 (100.00%)    |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 397 (100.00%)   |
| visit_occurrence_id                      | 2012-01-01 to 2012-12-31 | N missing data (%) | 5 (8.77%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 3 (6.25%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 1 (1.92%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 2 (3.39%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 2 (2.78%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 13 (3.27%)      |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| procedure_occurrence; 18 to 64; overall  |                          |                    |                 |
| modifier_concept_id                      | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 89 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 99 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 70 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 72 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 59 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 61 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 60 (100.00%)    |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 510 (100.00%)   |
| modifier_source_value                    | 2012-01-01 to 2012-12-31 | N missing data (%) | 89 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 99 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 70 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 72 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 59 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 61 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 60 (100.00%)    |
|                                          | overall                  | N missing data (%) | 510 (100.00%)   |
| person_id                                | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| procedure_concept_id                     | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| procedure_date                           | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| procedure_datetime                       | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| procedure_occurrence_id                  | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| procedure_source_concept_id              | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| procedure_source_value                   | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| procedure_type_concept_id                | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| provider_id                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 89 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 99 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 70 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 72 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 59 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 61 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 60 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 510 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| quantity                                 | 2012-01-01 to 2012-12-31 | N missing data (%) | 89 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 99 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 70 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 72 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 59 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 61 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 60 (100.00%)    |
|                                          | overall                  | N missing data (%) | 510 (100.00%)   |
| visit_detail_id                          | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 89 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 99 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 70 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 72 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 59 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 61 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 60 (100.00%)    |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 510 (100.00%)   |
| visit_occurrence_id                      | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 1 (1.01%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 1 (1.67%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 2 (0.39%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| procedure_occurrence; overall; Male      |                          |                    |                 |
| modifier_concept_id                      | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 66 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 67 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 59 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 65 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 56 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 63 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 66 (100.00%)    |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 442 (100.00%)   |
| modifier_source_value                    | 2012-01-01 to 2012-12-31 | N missing data (%) | 66 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 67 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 59 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 65 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 56 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 63 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 66 (100.00%)    |
|                                          | overall                  | N missing data (%) | 442 (100.00%)   |
| person_id                                | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| procedure_concept_id                     | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| procedure_date                           | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| procedure_datetime                       | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| procedure_occurrence_id                  | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| procedure_source_concept_id              | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| procedure_source_value                   | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| procedure_type_concept_id                | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| provider_id                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 66 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 67 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 59 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 65 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 56 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 63 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 66 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 442 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| quantity                                 | 2012-01-01 to 2012-12-31 | N missing data (%) | 66 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 67 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 59 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 65 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 56 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 63 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 66 (100.00%)    |
|                                          | overall                  | N missing data (%) | 442 (100.00%)   |
| visit_detail_id                          | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 66 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 67 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 59 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 65 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 56 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 63 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 66 (100.00%)    |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 442 (100.00%)   |
| visit_occurrence_id                      | 2012-01-01 to 2012-12-31 | N missing data (%) | 3 (4.55%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 1 (1.69%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 3 (4.55%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 7 (1.58%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| procedure_occurrence; overall; Female    |                          |                    |                 |
| modifier_concept_id                      | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 80 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 80 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 63 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 66 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 53 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 57 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 66 (100.00%)    |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 465 (100.00%)   |
| modifier_source_value                    | 2012-01-01 to 2012-12-31 | N missing data (%) | 80 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 80 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 63 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 66 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 53 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 57 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 66 (100.00%)    |
|                                          | overall                  | N missing data (%) | 465 (100.00%)   |
| person_id                                | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| procedure_concept_id                     | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| procedure_date                           | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| procedure_datetime                       | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| procedure_occurrence_id                  | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| procedure_source_concept_id              | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| procedure_source_value                   | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| procedure_type_concept_id                | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| provider_id                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 80 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 80 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 63 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 66 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 53 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 57 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 66 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 465 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| quantity                                 | 2012-01-01 to 2012-12-31 | N missing data (%) | 80 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 80 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 63 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 66 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 53 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 57 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 66 (100.00%)    |
|                                          | overall                  | N missing data (%) | 465 (100.00%)   |
| visit_detail_id                          | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 80 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 80 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 63 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 66 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 53 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 57 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 66 (100.00%)    |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 465 (100.00%)   |
| visit_occurrence_id                      | 2012-01-01 to 2012-12-31 | N missing data (%) | 2 (2.50%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 4 (5.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 2 (3.51%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 8 (1.72%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| procedure_occurrence; 65 to 150; Female  |                          |                    |                 |
| modifier_concept_id                      | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 20 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 26 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 23 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 27 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 22 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 33 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 35 (100.00%)    |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 186 (100.00%)   |
| modifier_source_value                    | 2012-01-01 to 2012-12-31 | N missing data (%) | 20 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 26 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 23 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 27 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 22 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 33 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 35 (100.00%)    |
|                                          | overall                  | N missing data (%) | 186 (100.00%)   |
| person_id                                | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| procedure_concept_id                     | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| procedure_date                           | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| procedure_datetime                       | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| procedure_occurrence_id                  | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| procedure_source_concept_id              | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| procedure_source_value                   | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| procedure_type_concept_id                | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| provider_id                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 20 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 26 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 23 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 27 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 22 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 33 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 35 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 186 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| quantity                                 | 2012-01-01 to 2012-12-31 | N missing data (%) | 20 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 26 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 23 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 27 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 22 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 33 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 35 (100.00%)    |
|                                          | overall                  | N missing data (%) | 186 (100.00%)   |
| visit_detail_id                          | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 20 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 26 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 23 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 27 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 22 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 33 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 35 (100.00%)    |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 186 (100.00%)   |
| visit_occurrence_id                      | 2012-01-01 to 2012-12-31 | N missing data (%) | 2 (10.00%)      |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 3 (11.54%)      |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 2 (6.06%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 7 (3.76%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| procedure_occurrence; 18 to 64; Female   |                          |                    |                 |
| modifier_concept_id                      | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 60 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 54 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 40 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 39 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 31 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 24 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 31 (100.00%)    |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 279 (100.00%)   |
| modifier_source_value                    | 2012-01-01 to 2012-12-31 | N missing data (%) | 60 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 54 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 40 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 39 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 31 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 24 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 31 (100.00%)    |
|                                          | overall                  | N missing data (%) | 279 (100.00%)   |
| person_id                                | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| procedure_concept_id                     | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| procedure_date                           | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| procedure_datetime                       | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| procedure_occurrence_id                  | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| procedure_source_concept_id              | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| procedure_source_value                   | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| procedure_type_concept_id                | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| provider_id                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 60 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 54 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 40 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 39 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 31 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 24 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 31 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 279 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| quantity                                 | 2012-01-01 to 2012-12-31 | N missing data (%) | 60 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 54 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 40 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 39 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 31 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 24 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 31 (100.00%)    |
|                                          | overall                  | N missing data (%) | 279 (100.00%)   |
| visit_detail_id                          | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 60 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 54 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 40 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 39 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 31 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 24 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 31 (100.00%)    |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 279 (100.00%)   |
| visit_occurrence_id                      | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 1 (1.85%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 1 (0.36%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| procedure_occurrence; 18 to 64; Male     |                          |                    |                 |
| modifier_concept_id                      | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 29 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 45 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 30 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 33 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 28 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 37 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 29 (100.00%)    |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 231 (100.00%)   |
| modifier_source_value                    | 2012-01-01 to 2012-12-31 | N missing data (%) | 29 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 45 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 30 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 33 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 28 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 37 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 29 (100.00%)    |
|                                          | overall                  | N missing data (%) | 231 (100.00%)   |
| person_id                                | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| procedure_concept_id                     | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| procedure_date                           | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| procedure_datetime                       | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| procedure_occurrence_id                  | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| procedure_source_concept_id              | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| procedure_source_value                   | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| procedure_type_concept_id                | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| provider_id                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 29 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 45 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 30 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 33 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 28 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 37 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 29 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 231 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| quantity                                 | 2012-01-01 to 2012-12-31 | N missing data (%) | 29 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 45 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 30 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 33 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 28 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 37 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 29 (100.00%)    |
|                                          | overall                  | N missing data (%) | 231 (100.00%)   |
| visit_detail_id                          | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 29 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 45 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 30 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 33 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 28 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 37 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 29 (100.00%)    |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 231 (100.00%)   |
| visit_occurrence_id                      | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 1 (3.45%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 1 (0.43%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| procedure_occurrence; 65 to 150; Male    |                          |                    |                 |
| modifier_concept_id                      | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 37 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 22 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 29 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 32 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 28 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 26 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 37 (100.00%)    |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 211 (100.00%)   |
| modifier_source_value                    | 2012-01-01 to 2012-12-31 | N missing data (%) | 37 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 22 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 29 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 32 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 28 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 26 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 37 (100.00%)    |
|                                          | overall                  | N missing data (%) | 211 (100.00%)   |
| person_id                                | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| procedure_concept_id                     | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| procedure_date                           | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| procedure_datetime                       | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| procedure_occurrence_id                  | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| procedure_source_concept_id              | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| procedure_source_value                   | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| procedure_type_concept_id                | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| provider_id                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 37 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 22 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 29 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 32 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 28 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 26 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 37 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 211 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| quantity                                 | 2012-01-01 to 2012-12-31 | N missing data (%) | 37 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 22 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 29 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 32 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 28 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 26 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 37 (100.00%)    |
|                                          | overall                  | N missing data (%) | 211 (100.00%)   |
| visit_detail_id                          | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 37 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 22 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 29 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 32 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 28 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 26 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 37 (100.00%)    |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 211 (100.00%)   |
| visit_occurrence_id                      | 2012-01-01 to 2012-12-31 | N missing data (%) | 3 (8.11%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 1 (3.45%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 2 (5.41%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 6 (2.84%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |

Summary of missingness in condition_occurrence, drug_exposure,
procedure_occurrence tables

Finally, disconnect from the cdm

``` r
CDMConnector::cdmDisconnect(cdm = cdm)
```
