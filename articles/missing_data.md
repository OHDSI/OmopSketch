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
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| condition_end_date                       | 2012-01-01 to 2012-12-31 | N missing data (%) | 78 (21.02%)     |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 59 (17.05%)     |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 69 (17.65%)     |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 61 (18.26%)     |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 66 (18.08%)     |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 72 (20.45%)     |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 48 (12.87%)     |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 453 (17.88%)    |
| condition_end_datetime                   | 2012-01-01 to 2012-12-31 | N missing data (%) | 78 (21.02%)     |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 59 (17.05%)     |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 69 (17.65%)     |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 61 (18.26%)     |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 66 (18.08%)     |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 72 (20.45%)     |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 48 (12.87%)     |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 453 (17.88%)    |
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
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
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
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
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
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| condition_start_date                     | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| condition_start_datetime                 | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| condition_status_concept_id              | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 371 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 346 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 391 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 334 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 365 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 352 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 373 (100.00%)   |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 1 (100.00%)     |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 2,533 (100.00%) |
| condition_status_source_value            | 2012-01-01 to 2012-12-31 | N missing data (%) | 371 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 346 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 391 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 334 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 365 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 352 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 373 (100.00%)   |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 1 (100.00%)     |
|                                          | overall                  | N missing data (%) | 2,533 (100.00%) |
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
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
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
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| provider_id                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 371 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 346 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 391 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 334 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 365 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 352 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 373 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 1 (100.00%)     |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 2,533 (100.00%) |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| stop_reason                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 371 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 346 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 391 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 334 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 365 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 352 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 373 (100.00%)   |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 1 (100.00%)     |
|                                          | overall                  | N missing data (%) | 2,533 (100.00%) |
| visit_detail_id                          | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 371 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 346 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 391 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 334 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 365 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 352 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 373 (100.00%)   |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 1 (100.00%)     |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 2,533 (100.00%) |
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
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
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
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| condition_end_date                       | 2012-01-01 to 2012-12-31 | N missing data (%) | 70 (23.81%)     |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 51 (18.41%)     |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 56 (18.60%)     |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 52 (20.23%)     |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 56 (19.79%)     |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 58 (22.22%)     |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 39 (14.50%)     |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 382 (19.66%)    |
| condition_end_datetime                   | 2012-01-01 to 2012-12-31 | N missing data (%) | 70 (23.81%)     |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 51 (18.41%)     |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 56 (18.60%)     |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 52 (20.23%)     |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 56 (19.79%)     |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 58 (22.22%)     |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 39 (14.50%)     |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 382 (19.66%)    |
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
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
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
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
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
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| condition_start_date                     | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| condition_start_datetime                 | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| condition_status_concept_id              | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 294 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 277 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 301 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 257 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 283 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 261 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 269 (100.00%)   |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 1 (100.00%)     |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 1,943 (100.00%) |
| condition_status_source_value            | 2012-01-01 to 2012-12-31 | N missing data (%) | 294 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 277 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 301 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 257 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 283 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 261 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 269 (100.00%)   |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 1 (100.00%)     |
|                                          | overall                  | N missing data (%) | 1,943 (100.00%) |
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
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
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
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| provider_id                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 294 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 277 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 301 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 257 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 283 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 261 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 269 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 1 (100.00%)     |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 1,943 (100.00%) |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| stop_reason                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 294 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 277 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 301 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 257 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 283 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 261 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 269 (100.00%)   |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 1 (100.00%)     |
|                                          | overall                  | N missing data (%) | 1,943 (100.00%) |
| visit_detail_id                          | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 294 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 277 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 301 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 257 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 283 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 261 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 269 (100.00%)   |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 1 (100.00%)     |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 1,943 (100.00%) |
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
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
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
| condition_end_date                       | 2012-01-01 to 2012-12-31 | N missing data (%) | 8 (10.39%)      |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 8 (11.59%)      |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 13 (14.44%)     |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 9 (11.69%)      |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 10 (12.20%)     |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 14 (15.38%)     |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 9 (8.65%)       |
|                                          | overall                  | N missing data (%) | 71 (12.03%)     |
| condition_end_datetime                   | 2012-01-01 to 2012-12-31 | N missing data (%) | 8 (10.39%)      |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 8 (11.59%)      |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 13 (14.44%)     |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 9 (11.69%)      |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 10 (12.20%)     |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 14 (15.38%)     |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 9 (8.65%)       |
|                                          | overall                  | N missing data (%) | 71 (12.03%)     |
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
|                                          |                          | N zeros (%)        | 77 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 69 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 90 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 77 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 82 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 91 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 104 (100.00%)   |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 590 (100.00%)   |
| condition_status_source_value            | 2012-01-01 to 2012-12-31 | N missing data (%) | 77 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 69 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 90 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 77 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 82 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 91 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 104 (100.00%)   |
|                                          | overall                  | N missing data (%) | 590 (100.00%)   |
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
| provider_id                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 77 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 69 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 90 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 77 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 82 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 91 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 104 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 590 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| stop_reason                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 77 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 69 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 90 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 77 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 82 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 91 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 104 (100.00%)   |
|                                          | overall                  | N missing data (%) | 590 (100.00%)   |
| visit_detail_id                          | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 77 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 69 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 90 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 77 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 82 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 91 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 104 (100.00%)   |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 590 (100.00%)   |
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
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| condition_end_date                       | 2012-01-01 to 2012-12-31 | N missing data (%) | 43 (23.37%)     |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 26 (16.56%)     |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 28 (17.28%)     |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 26 (17.45%)     |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 39 (20.63%)     |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 31 (18.67%)     |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 22 (11.83%)     |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 215 (18.01%)    |
| condition_end_datetime                   | 2012-01-01 to 2012-12-31 | N missing data (%) | 43 (23.37%)     |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 26 (16.56%)     |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 28 (17.28%)     |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 26 (17.45%)     |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 39 (20.63%)     |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 31 (18.67%)     |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 22 (11.83%)     |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 215 (18.01%)    |
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
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
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
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
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
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| condition_start_date                     | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| condition_start_datetime                 | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| condition_status_concept_id              | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 184 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 157 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 162 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 149 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 189 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 166 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 186 (100.00%)   |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 1 (100.00%)     |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 1,194 (100.00%) |
| condition_status_source_value            | 2012-01-01 to 2012-12-31 | N missing data (%) | 184 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 157 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 162 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 149 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 189 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 166 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 186 (100.00%)   |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 1 (100.00%)     |
|                                          | overall                  | N missing data (%) | 1,194 (100.00%) |
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
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
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
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| provider_id                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 184 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 157 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 162 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 149 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 189 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 166 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 186 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 1 (100.00%)     |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 1,194 (100.00%) |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| stop_reason                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 184 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 157 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 162 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 149 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 189 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 166 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 186 (100.00%)   |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 1 (100.00%)     |
|                                          | overall                  | N missing data (%) | 1,194 (100.00%) |
| visit_detail_id                          | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 184 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 157 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 162 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 149 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 189 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 166 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 186 (100.00%)   |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 1 (100.00%)     |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 1,194 (100.00%) |
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
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
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
| condition_end_date                       | 2012-01-01 to 2012-12-31 | N missing data (%) | 35 (18.72%)     |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 33 (17.46%)     |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 41 (17.90%)     |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 35 (18.92%)     |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 27 (15.34%)     |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 41 (22.04%)     |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 26 (13.90%)     |
|                                          | overall                  | N missing data (%) | 238 (17.77%)    |
| condition_end_datetime                   | 2012-01-01 to 2012-12-31 | N missing data (%) | 35 (18.72%)     |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 33 (17.46%)     |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 41 (17.90%)     |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 35 (18.92%)     |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 27 (15.34%)     |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 41 (22.04%)     |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 26 (13.90%)     |
|                                          | overall                  | N missing data (%) | 238 (17.77%)    |
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
|                                          |                          | N zeros (%)        | 187 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 189 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 229 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 185 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 176 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 186 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 187 (100.00%)   |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 1,339 (100.00%) |
| condition_status_source_value            | 2012-01-01 to 2012-12-31 | N missing data (%) | 187 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 189 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 229 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 185 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 176 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 186 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 187 (100.00%)   |
|                                          | overall                  | N missing data (%) | 1,339 (100.00%) |
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
| provider_id                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 187 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 189 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 229 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 185 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 176 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 186 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 187 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 1,339 (100.00%) |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| stop_reason                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 187 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 189 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 229 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 185 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 176 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 186 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 187 (100.00%)   |
|                                          | overall                  | N missing data (%) | 1,339 (100.00%) |
| visit_detail_id                          | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 187 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 189 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 229 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 185 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 176 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 186 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 187 (100.00%)   |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 1,339 (100.00%) |
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
| condition_end_date                       | 2012-01-01 to 2012-12-31 | N missing data (%) | 3 (6.98%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 3 (7.50%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 6 (10.91%)      |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 5 (10.64%)      |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 6 (12.77%)      |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 8 (15.38%)      |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 5 (9.26%)       |
|                                          | overall                  | N missing data (%) | 36 (10.65%)     |
| condition_end_datetime                   | 2012-01-01 to 2012-12-31 | N missing data (%) | 3 (6.98%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 3 (7.50%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 6 (10.91%)      |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 5 (10.64%)      |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 6 (12.77%)      |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 8 (15.38%)      |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 5 (9.26%)       |
|                                          | overall                  | N missing data (%) | 36 (10.65%)     |
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
|                                          |                          | N zeros (%)        | 43 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 40 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 55 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 47 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 47 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 52 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 54 (100.00%)    |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 338 (100.00%)   |
| condition_status_source_value            | 2012-01-01 to 2012-12-31 | N missing data (%) | 43 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 40 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 55 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 47 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 47 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 52 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 54 (100.00%)    |
|                                          | overall                  | N missing data (%) | 338 (100.00%)   |
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
| provider_id                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 43 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 40 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 55 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 47 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 47 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 52 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 54 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 338 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| stop_reason                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 43 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 40 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 55 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 47 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 47 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 52 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 54 (100.00%)    |
|                                          | overall                  | N missing data (%) | 338 (100.00%)   |
| visit_detail_id                          | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 43 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 40 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 55 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 47 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 47 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 52 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 54 (100.00%)    |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 338 (100.00%)   |
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
| condition_end_date                       | 2012-01-01 to 2012-12-31 | N missing data (%) | 5 (14.71%)      |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 5 (17.24%)      |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 7 (20.00%)      |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 4 (13.33%)      |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 4 (11.43%)      |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 6 (15.38%)      |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 4 (8.00%)       |
|                                          | overall                  | N missing data (%) | 35 (13.89%)     |
| condition_end_datetime                   | 2012-01-01 to 2012-12-31 | N missing data (%) | 5 (14.71%)      |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 5 (17.24%)      |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 7 (20.00%)      |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 4 (13.33%)      |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 4 (11.43%)      |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 6 (15.38%)      |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 4 (8.00%)       |
|                                          | overall                  | N missing data (%) | 35 (13.89%)     |
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
|                                          |                          | N zeros (%)        | 34 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 29 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 35 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 30 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 35 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 39 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 50 (100.00%)    |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 252 (100.00%)   |
| condition_status_source_value            | 2012-01-01 to 2012-12-31 | N missing data (%) | 34 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 29 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 35 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 30 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 35 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 39 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 50 (100.00%)    |
|                                          | overall                  | N missing data (%) | 252 (100.00%)   |
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
| provider_id                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 34 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 29 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 35 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 30 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 35 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 39 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 50 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 252 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| stop_reason                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 34 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 29 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 35 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 30 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 35 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 39 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 50 (100.00%)    |
|                                          | overall                  | N missing data (%) | 252 (100.00%)   |
| visit_detail_id                          | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 34 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 29 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 35 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 30 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 35 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 39 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 50 (100.00%)    |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 252 (100.00%)   |
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
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| condition_end_date                       | 2012-01-01 to 2012-12-31 | N missing data (%) | 38 (25.33%)     |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 21 (16.41%)     |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 21 (16.54%)     |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 22 (18.49%)     |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 35 (22.73%)     |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 25 (19.69%)     |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 18 (13.24%)     |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 180 (19.11%)    |
| condition_end_datetime                   | 2012-01-01 to 2012-12-31 | N missing data (%) | 38 (25.33%)     |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 21 (16.41%)     |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 21 (16.54%)     |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 22 (18.49%)     |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 35 (22.73%)     |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 25 (19.69%)     |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 18 (13.24%)     |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 180 (19.11%)    |
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
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
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
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
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
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| condition_start_date                     | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| condition_start_datetime                 | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| condition_status_concept_id              | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 150 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 128 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 127 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 119 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 154 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 127 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 136 (100.00%)   |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 1 (100.00%)     |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 942 (100.00%)   |
| condition_status_source_value            | 2012-01-01 to 2012-12-31 | N missing data (%) | 150 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 128 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 127 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 119 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 154 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 127 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 136 (100.00%)   |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 1 (100.00%)     |
|                                          | overall                  | N missing data (%) | 942 (100.00%)   |
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
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
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
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| provider_id                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 150 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 128 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 127 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 119 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 154 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 127 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 136 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 1 (100.00%)     |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 942 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| stop_reason                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 150 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 128 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 127 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 119 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 154 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 127 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 136 (100.00%)   |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 1 (100.00%)     |
|                                          | overall                  | N missing data (%) | 942 (100.00%)   |
| visit_detail_id                          | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 150 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 128 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 127 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 119 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 154 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 127 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 136 (100.00%)   |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 1 (100.00%)     |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 942 (100.00%)   |
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
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
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
| condition_end_date                       | 2012-01-01 to 2012-12-31 | N missing data (%) | 32 (22.22%)     |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 30 (20.13%)     |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 35 (20.11%)     |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 30 (21.74%)     |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 21 (16.28%)     |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 33 (24.63%)     |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 21 (15.79%)     |
|                                          | overall                  | N missing data (%) | 202 (20.18%)    |
| condition_end_datetime                   | 2012-01-01 to 2012-12-31 | N missing data (%) | 32 (22.22%)     |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 30 (20.13%)     |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 35 (20.11%)     |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 30 (21.74%)     |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 21 (16.28%)     |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 33 (24.63%)     |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 21 (15.79%)     |
|                                          | overall                  | N missing data (%) | 202 (20.18%)    |
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
|                                          |                          | N zeros (%)        | 144 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 149 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 174 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 138 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 129 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 134 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 133 (100.00%)   |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 1,001 (100.00%) |
| condition_status_source_value            | 2012-01-01 to 2012-12-31 | N missing data (%) | 144 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 149 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 174 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 138 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 129 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 134 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 133 (100.00%)   |
|                                          | overall                  | N missing data (%) | 1,001 (100.00%) |
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
| provider_id                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 144 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 149 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 174 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 138 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 129 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 134 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 133 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 1,001 (100.00%) |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| stop_reason                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 144 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 149 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 174 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 138 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 129 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 134 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 133 (100.00%)   |
|                                          | overall                  | N missing data (%) | 1,001 (100.00%) |
| visit_detail_id                          | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 144 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 149 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 174 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 138 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 129 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 134 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 133 (100.00%)   |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 1,001 (100.00%) |
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
| drug_exposure; overall; overall          |                          |                    |                 |
| days_supply                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| dose_unit_source_value                   | 2012-01-01 to 2012-12-31 | N missing data (%) | 482 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 428 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 456 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 415 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 421 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 444 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 414 (100.00%)   |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 2 (100.00%)     |
|                                          | overall                  | N missing data (%) | 3,062 (100.00%) |
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
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
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
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| drug_exposure_end_datetime               | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
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
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
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
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| drug_exposure_start_datetime             | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
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
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
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
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
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
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
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
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
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
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| provider_id                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 482 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 428 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 456 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 415 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 421 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 444 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 414 (100.00%)   |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 2 (100.00%)     |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 3,062 (100.00%) |
| quantity                                 | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| refills                                  | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| route_concept_id                         | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 482 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 428 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 456 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 415 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 421 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 444 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 414 (100.00%)   |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 2 (100.00%)     |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 3,062 (100.00%) |
| route_source_value                       | 2012-01-01 to 2012-12-31 | N missing data (%) | 482 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 428 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 456 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 415 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 421 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 444 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 414 (100.00%)   |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 2 (100.00%)     |
|                                          | overall                  | N missing data (%) | 3,062 (100.00%) |
| sig                                      | 2012-01-01 to 2012-12-31 | N missing data (%) | 482 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 428 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 456 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 415 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 421 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 444 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 414 (100.00%)   |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 2 (100.00%)     |
|                                          | overall                  | N missing data (%) | 3,062 (100.00%) |
| stop_reason                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 482 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 428 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 456 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 415 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 421 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 444 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 414 (100.00%)   |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 2 (100.00%)     |
|                                          | overall                  | N missing data (%) | 3,062 (100.00%) |
| verbatim_end_date                        | 2012-01-01 to 2012-12-31 | N missing data (%) | 53 (11.00%)     |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 49 (11.45%)     |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 57 (12.50%)     |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 40 (9.64%)      |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 64 (15.20%)     |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 69 (15.54%)     |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 56 (13.53%)     |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 388 (12.67%)    |
| visit_detail_id                          | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 482 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 428 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 456 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 415 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 421 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 444 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 414 (100.00%)   |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 2 (100.00%)     |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 3,062 (100.00%) |
| visit_occurrence_id                      | 2012-01-01 to 2012-12-31 | N missing data (%) | 1 (0.21%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 3 (0.70%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 5 (1.10%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 3 (0.72%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 4 (0.95%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 2 (0.45%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 6 (1.45%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 24 (0.78%)      |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| drug_exposure; 18 to 64; overall         |                          |                    |                 |
| days_supply                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| dose_unit_source_value                   | 2012-01-01 to 2012-12-31 | N missing data (%) | 393 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 354 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 360 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 344 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 313 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 299 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 294 (100.00%)   |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 2 (100.00%)     |
|                                          | overall                  | N missing data (%) | 2,359 (100.00%) |
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
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
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
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| drug_exposure_end_datetime               | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
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
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
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
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| drug_exposure_start_datetime             | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
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
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
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
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
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
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
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
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
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
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| provider_id                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 393 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 354 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 360 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 344 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 313 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 299 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 294 (100.00%)   |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 2 (100.00%)     |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 2,359 (100.00%) |
| quantity                                 | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| refills                                  | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| route_concept_id                         | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 393 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 354 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 360 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 344 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 313 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 299 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 294 (100.00%)   |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 2 (100.00%)     |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 2,359 (100.00%) |
| route_source_value                       | 2012-01-01 to 2012-12-31 | N missing data (%) | 393 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 354 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 360 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 344 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 313 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 299 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 294 (100.00%)   |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 2 (100.00%)     |
|                                          | overall                  | N missing data (%) | 2,359 (100.00%) |
| sig                                      | 2012-01-01 to 2012-12-31 | N missing data (%) | 393 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 354 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 360 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 344 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 313 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 299 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 294 (100.00%)   |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 2 (100.00%)     |
|                                          | overall                  | N missing data (%) | 2,359 (100.00%) |
| stop_reason                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 393 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 354 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 360 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 344 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 313 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 299 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 294 (100.00%)   |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 2 (100.00%)     |
|                                          | overall                  | N missing data (%) | 2,359 (100.00%) |
| verbatim_end_date                        | 2012-01-01 to 2012-12-31 | N missing data (%) | 32 (8.14%)      |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 32 (9.04%)      |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 43 (11.94%)     |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 32 (9.30%)      |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 49 (15.65%)     |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 41 (13.71%)     |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 48 (16.33%)     |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 277 (11.74%)    |
| visit_detail_id                          | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 393 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 354 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 360 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 344 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 313 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 299 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 294 (100.00%)   |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 2 (100.00%)     |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 2,359 (100.00%) |
| visit_occurrence_id                      | 2012-01-01 to 2012-12-31 | N missing data (%) | 1 (0.25%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 3 (0.85%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 4 (1.11%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 3 (0.87%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 3 (0.96%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 1 (0.33%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 4 (1.36%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 19 (0.81%)      |
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
| dose_unit_source_value                   | 2012-01-01 to 2012-12-31 | N missing data (%) | 89 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 74 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 96 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 71 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 108 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 145 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 120 (100.00%)   |
|                                          | overall                  | N missing data (%) | 703 (100.00%)   |
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
|                                          |                          | N zeros (%)        | 89 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 74 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 96 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 71 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 108 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 145 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 120 (100.00%)   |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 703 (100.00%)   |
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
|                                          |                          | N zeros (%)        | 89 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 74 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 96 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 71 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 108 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 145 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 120 (100.00%)   |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 703 (100.00%)   |
| route_source_value                       | 2012-01-01 to 2012-12-31 | N missing data (%) | 89 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 74 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 96 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 71 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 108 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 145 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 120 (100.00%)   |
|                                          | overall                  | N missing data (%) | 703 (100.00%)   |
| sig                                      | 2012-01-01 to 2012-12-31 | N missing data (%) | 89 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 74 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 96 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 71 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 108 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 145 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 120 (100.00%)   |
|                                          | overall                  | N missing data (%) | 703 (100.00%)   |
| stop_reason                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 89 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 74 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 96 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 71 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 108 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 145 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 120 (100.00%)   |
|                                          | overall                  | N missing data (%) | 703 (100.00%)   |
| verbatim_end_date                        | 2012-01-01 to 2012-12-31 | N missing data (%) | 21 (23.60%)     |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 17 (22.97%)     |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 14 (14.58%)     |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 8 (11.27%)      |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 15 (13.89%)     |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 28 (19.31%)     |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 8 (6.67%)       |
|                                          | overall                  | N missing data (%) | 111 (15.79%)    |
| visit_detail_id                          | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 89 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 74 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 96 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 71 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 108 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 145 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 120 (100.00%)   |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 703 (100.00%)   |
| visit_occurrence_id                      | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 1 (1.04%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 1 (0.93%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 1 (0.69%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 2 (1.67%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 5 (0.71%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| drug_exposure; overall; Female           |                          |                    |                 |
| days_supply                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| dose_unit_source_value                   | 2012-01-01 to 2012-12-31 | N missing data (%) | 246 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 222 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 236 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 223 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 237 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 211 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 198 (100.00%)   |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 2 (100.00%)     |
|                                          | overall                  | N missing data (%) | 1,575 (100.00%) |
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
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
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
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| drug_exposure_end_datetime               | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
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
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
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
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| drug_exposure_start_datetime             | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
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
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
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
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
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
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
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
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
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
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| provider_id                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 246 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 222 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 236 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 223 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 237 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 211 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 198 (100.00%)   |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 2 (100.00%)     |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 1,575 (100.00%) |
| quantity                                 | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| refills                                  | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| route_concept_id                         | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 246 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 222 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 236 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 223 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 237 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 211 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 198 (100.00%)   |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 2 (100.00%)     |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 1,575 (100.00%) |
| route_source_value                       | 2012-01-01 to 2012-12-31 | N missing data (%) | 246 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 222 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 236 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 223 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 237 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 211 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 198 (100.00%)   |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 2 (100.00%)     |
|                                          | overall                  | N missing data (%) | 1,575 (100.00%) |
| sig                                      | 2012-01-01 to 2012-12-31 | N missing data (%) | 246 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 222 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 236 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 223 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 237 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 211 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 198 (100.00%)   |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 2 (100.00%)     |
|                                          | overall                  | N missing data (%) | 1,575 (100.00%) |
| stop_reason                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 246 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 222 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 236 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 223 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 237 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 211 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 198 (100.00%)   |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 2 (100.00%)     |
|                                          | overall                  | N missing data (%) | 1,575 (100.00%) |
| verbatim_end_date                        | 2012-01-01 to 2012-12-31 | N missing data (%) | 24 (9.76%)      |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 20 (9.01%)      |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 33 (13.98%)     |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 21 (9.42%)      |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 35 (14.77%)     |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 36 (17.06%)     |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 27 (13.64%)     |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 196 (12.44%)    |
| visit_detail_id                          | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 246 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 222 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 236 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 223 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 237 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 211 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 198 (100.00%)   |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 2 (100.00%)     |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 1,575 (100.00%) |
| visit_occurrence_id                      | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 2 (0.90%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 2 (0.84%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 1 (0.47%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 6 (3.03%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 11 (0.70%)      |
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
| dose_unit_source_value                   | 2012-01-01 to 2012-12-31 | N missing data (%) | 236 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 206 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 220 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 192 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 184 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 233 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 216 (100.00%)   |
|                                          | overall                  | N missing data (%) | 1,487 (100.00%) |
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
|                                          |                          | N zeros (%)        | 236 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 206 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 220 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 192 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 184 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 233 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 216 (100.00%)   |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 1,487 (100.00%) |
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
|                                          |                          | N zeros (%)        | 236 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 206 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 220 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 192 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 184 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 233 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 216 (100.00%)   |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 1,487 (100.00%) |
| route_source_value                       | 2012-01-01 to 2012-12-31 | N missing data (%) | 236 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 206 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 220 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 192 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 184 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 233 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 216 (100.00%)   |
|                                          | overall                  | N missing data (%) | 1,487 (100.00%) |
| sig                                      | 2012-01-01 to 2012-12-31 | N missing data (%) | 236 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 206 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 220 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 192 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 184 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 233 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 216 (100.00%)   |
|                                          | overall                  | N missing data (%) | 1,487 (100.00%) |
| stop_reason                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 236 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 206 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 220 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 192 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 184 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 233 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 216 (100.00%)   |
|                                          | overall                  | N missing data (%) | 1,487 (100.00%) |
| verbatim_end_date                        | 2012-01-01 to 2012-12-31 | N missing data (%) | 29 (12.29%)     |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 29 (14.08%)     |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 24 (10.91%)     |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 19 (9.90%)      |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 29 (15.76%)     |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 33 (14.16%)     |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 29 (13.43%)     |
|                                          | overall                  | N missing data (%) | 192 (12.91%)    |
| visit_detail_id                          | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 236 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 206 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 220 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 192 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 184 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 233 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 216 (100.00%)   |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 1,487 (100.00%) |
| visit_occurrence_id                      | 2012-01-01 to 2012-12-31 | N missing data (%) | 1 (0.42%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 3 (1.46%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 5 (2.27%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 1 (0.52%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 2 (1.09%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 1 (0.43%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 13 (0.87%)      |
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
| dose_unit_source_value                   | 2012-01-01 to 2012-12-31 | N missing data (%) | 49 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 41 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 43 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 36 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 57 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 69 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 53 (100.00%)    |
|                                          | overall                  | N missing data (%) | 348 (100.00%)   |
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
|                                          |                          | N zeros (%)        | 49 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 41 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 43 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 36 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 57 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 69 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 53 (100.00%)    |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 348 (100.00%)   |
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
|                                          |                          | N zeros (%)        | 49 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 41 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 43 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 36 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 57 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 69 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 53 (100.00%)    |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 348 (100.00%)   |
| route_source_value                       | 2012-01-01 to 2012-12-31 | N missing data (%) | 49 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 41 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 43 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 36 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 57 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 69 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 53 (100.00%)    |
|                                          | overall                  | N missing data (%) | 348 (100.00%)   |
| sig                                      | 2012-01-01 to 2012-12-31 | N missing data (%) | 49 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 41 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 43 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 36 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 57 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 69 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 53 (100.00%)    |
|                                          | overall                  | N missing data (%) | 348 (100.00%)   |
| stop_reason                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 49 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 41 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 43 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 36 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 57 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 69 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 53 (100.00%)    |
|                                          | overall                  | N missing data (%) | 348 (100.00%)   |
| verbatim_end_date                        | 2012-01-01 to 2012-12-31 | N missing data (%) | 11 (22.45%)     |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 7 (17.07%)      |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 8 (18.60%)      |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 6 (16.67%)      |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 8 (14.04%)      |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 17 (24.64%)     |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 4 (7.55%)       |
|                                          | overall                  | N missing data (%) | 61 (17.53%)     |
| visit_detail_id                          | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 49 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 41 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 43 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 36 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 57 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 69 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 53 (100.00%)    |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 348 (100.00%)   |
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
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 2 (3.77%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 2 (0.57%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| drug_exposure; 18 to 64; Female          |                          |                    |                 |
| days_supply                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| dose_unit_source_value                   | 2012-01-01 to 2012-12-31 | N missing data (%) | 197 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 181 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 193 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 187 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 180 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 142 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 145 (100.00%)   |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 2 (100.00%)     |
|                                          | overall                  | N missing data (%) | 1,227 (100.00%) |
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
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
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
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| drug_exposure_end_datetime               | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
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
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
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
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| drug_exposure_start_datetime             | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
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
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
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
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
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
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
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
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
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
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| provider_id                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 197 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 181 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 193 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 187 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 180 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 142 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 145 (100.00%)   |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 2 (100.00%)     |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 1,227 (100.00%) |
| quantity                                 | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| refills                                  | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| route_concept_id                         | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 197 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 181 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 193 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 187 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 180 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 142 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 145 (100.00%)   |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 2 (100.00%)     |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 1,227 (100.00%) |
| route_source_value                       | 2012-01-01 to 2012-12-31 | N missing data (%) | 197 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 181 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 193 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 187 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 180 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 142 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 145 (100.00%)   |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 2 (100.00%)     |
|                                          | overall                  | N missing data (%) | 1,227 (100.00%) |
| sig                                      | 2012-01-01 to 2012-12-31 | N missing data (%) | 197 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 181 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 193 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 187 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 180 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 142 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 145 (100.00%)   |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 2 (100.00%)     |
|                                          | overall                  | N missing data (%) | 1,227 (100.00%) |
| stop_reason                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 197 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 181 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 193 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 187 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 180 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 142 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 145 (100.00%)   |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 2 (100.00%)     |
|                                          | overall                  | N missing data (%) | 1,227 (100.00%) |
| verbatim_end_date                        | 2012-01-01 to 2012-12-31 | N missing data (%) | 13 (6.60%)      |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 13 (7.18%)      |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 25 (12.95%)     |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 15 (8.02%)      |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 27 (15.00%)     |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 19 (13.38%)     |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 23 (15.86%)     |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 135 (11.00%)    |
| visit_detail_id                          | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 197 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 181 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 193 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 187 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 180 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 142 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 145 (100.00%)   |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 2 (100.00%)     |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 1,227 (100.00%) |
| visit_occurrence_id                      | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 2 (1.07%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 2 (1.11%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 1 (0.70%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 4 (2.76%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 9 (0.73%)       |
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
| dose_unit_source_value                   | 2012-01-01 to 2012-12-31 | N missing data (%) | 196 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 173 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 167 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 157 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 133 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 157 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 149 (100.00%)   |
|                                          | overall                  | N missing data (%) | 1,132 (100.00%) |
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
|                                          |                          | N zeros (%)        | 196 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 173 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 167 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 157 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 133 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 157 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 149 (100.00%)   |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 1,132 (100.00%) |
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
|                                          |                          | N zeros (%)        | 196 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 173 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 167 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 157 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 133 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 157 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 149 (100.00%)   |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 1,132 (100.00%) |
| route_source_value                       | 2012-01-01 to 2012-12-31 | N missing data (%) | 196 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 173 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 167 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 157 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 133 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 157 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 149 (100.00%)   |
|                                          | overall                  | N missing data (%) | 1,132 (100.00%) |
| sig                                      | 2012-01-01 to 2012-12-31 | N missing data (%) | 196 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 173 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 167 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 157 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 133 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 157 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 149 (100.00%)   |
|                                          | overall                  | N missing data (%) | 1,132 (100.00%) |
| stop_reason                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 196 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 173 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 167 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 157 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 133 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 157 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 149 (100.00%)   |
|                                          | overall                  | N missing data (%) | 1,132 (100.00%) |
| verbatim_end_date                        | 2012-01-01 to 2012-12-31 | N missing data (%) | 19 (9.69%)      |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 19 (10.98%)     |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 18 (10.78%)     |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 17 (10.83%)     |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 22 (16.54%)     |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 22 (14.01%)     |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 25 (16.78%)     |
|                                          | overall                  | N missing data (%) | 142 (12.54%)    |
| visit_detail_id                          | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 196 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 173 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 167 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 157 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 133 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 157 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 149 (100.00%)   |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 1,132 (100.00%) |
| visit_occurrence_id                      | 2012-01-01 to 2012-12-31 | N missing data (%) | 1 (0.51%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 3 (1.73%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 4 (2.40%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 1 (0.64%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 1 (0.75%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 10 (0.88%)      |
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
| dose_unit_source_value                   | 2012-01-01 to 2012-12-31 | N missing data (%) | 40 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 33 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 53 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 35 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 51 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 76 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 67 (100.00%)    |
|                                          | overall                  | N missing data (%) | 355 (100.00%)   |
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
|                                          |                          | N zeros (%)        | 40 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 33 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 53 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 35 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 51 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 76 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 67 (100.00%)    |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 355 (100.00%)   |
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
|                                          |                          | N zeros (%)        | 40 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 33 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 53 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 35 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 51 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 76 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 67 (100.00%)    |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 355 (100.00%)   |
| route_source_value                       | 2012-01-01 to 2012-12-31 | N missing data (%) | 40 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 33 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 53 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 35 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 51 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 76 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 67 (100.00%)    |
|                                          | overall                  | N missing data (%) | 355 (100.00%)   |
| sig                                      | 2012-01-01 to 2012-12-31 | N missing data (%) | 40 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 33 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 53 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 35 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 51 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 76 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 67 (100.00%)    |
|                                          | overall                  | N missing data (%) | 355 (100.00%)   |
| stop_reason                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 40 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 33 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 53 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 35 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 51 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 76 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 67 (100.00%)    |
|                                          | overall                  | N missing data (%) | 355 (100.00%)   |
| verbatim_end_date                        | 2012-01-01 to 2012-12-31 | N missing data (%) | 10 (25.00%)     |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 10 (30.30%)     |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 6 (11.32%)      |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 2 (5.71%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 7 (13.73%)      |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 11 (14.47%)     |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 4 (5.97%)       |
|                                          | overall                  | N missing data (%) | 50 (14.08%)     |
| visit_detail_id                          | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 40 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 33 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 53 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 35 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 51 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 76 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 67 (100.00%)    |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 355 (100.00%)   |
| visit_occurrence_id                      | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 1 (1.89%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 1 (1.96%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 1 (1.32%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 3 (0.85%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| procedure_occurrence; overall; overall   |                          |                    |                 |
| modifier_concept_id                      | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 184 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 159 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 127 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 132 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 111 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 141 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 139 (100.00%)   |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 1 (100.00%)     |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 994 (100.00%)   |
| modifier_source_value                    | 2012-01-01 to 2012-12-31 | N missing data (%) | 184 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 159 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 127 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 132 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 111 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 141 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 139 (100.00%)   |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 1 (100.00%)     |
|                                          | overall                  | N missing data (%) | 994 (100.00%)   |
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
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
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
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
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
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| procedure_datetime                       | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
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
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
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
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
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
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
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
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| provider_id                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 184 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 159 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 127 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 132 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 111 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 141 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 139 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 1 (100.00%)     |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 994 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| quantity                                 | 2012-01-01 to 2012-12-31 | N missing data (%) | 184 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 159 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 127 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 132 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 111 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 141 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 139 (100.00%)   |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 1 (100.00%)     |
|                                          | overall                  | N missing data (%) | 994 (100.00%)   |
| visit_detail_id                          | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 184 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 159 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 127 (100.00%)   |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 132 (100.00%)   |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 111 (100.00%)   |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 141 (100.00%)   |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 139 (100.00%)   |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 1 (100.00%)     |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 994 (100.00%)   |
| visit_occurrence_id                      | 2012-01-01 to 2012-12-31 | N missing data (%) | 4 (2.17%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 1 (0.76%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 1 (0.90%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 6 (0.60%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| procedure_occurrence; 18 to 64; overall  |                          |                    |                 |
| modifier_concept_id                      | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 125 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 112 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 79 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 70 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 60 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 80 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 66 (100.00%)    |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 1 (100.00%)     |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 593 (100.00%)   |
| modifier_source_value                    | 2012-01-01 to 2012-12-31 | N missing data (%) | 125 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 112 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 79 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 70 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 60 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 80 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 66 (100.00%)    |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 1 (100.00%)     |
|                                          | overall                  | N missing data (%) | 593 (100.00%)   |
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
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
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
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
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
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| procedure_datetime                       | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
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
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
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
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
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
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
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
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| provider_id                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 125 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 112 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 79 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 70 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 60 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 80 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 66 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 1 (100.00%)     |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 593 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| quantity                                 | 2012-01-01 to 2012-12-31 | N missing data (%) | 125 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 112 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 79 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 70 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 60 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 80 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 66 (100.00%)    |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 1 (100.00%)     |
|                                          | overall                  | N missing data (%) | 593 (100.00%)   |
| visit_detail_id                          | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 125 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 112 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 79 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 70 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 60 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 80 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 66 (100.00%)    |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 1 (100.00%)     |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 593 (100.00%)   |
| visit_occurrence_id                      | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 1 (1.67%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 1 (0.17%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| procedure_occurrence; 65 to 150; overall |                          |                    |                 |
| modifier_concept_id                      | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 59 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 47 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 48 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 62 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 51 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 61 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 73 (100.00%)    |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 401 (100.00%)   |
| modifier_source_value                    | 2012-01-01 to 2012-12-31 | N missing data (%) | 59 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 47 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 48 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 62 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 51 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 61 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 73 (100.00%)    |
|                                          | overall                  | N missing data (%) | 401 (100.00%)   |
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
| provider_id                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 59 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 47 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 48 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 62 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 51 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 61 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 73 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 401 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| quantity                                 | 2012-01-01 to 2012-12-31 | N missing data (%) | 59 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 47 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 48 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 62 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 51 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 61 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 73 (100.00%)    |
|                                          | overall                  | N missing data (%) | 401 (100.00%)   |
| visit_detail_id                          | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 59 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 47 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 48 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 62 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 51 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 61 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 73 (100.00%)    |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 401 (100.00%)   |
| visit_occurrence_id                      | 2012-01-01 to 2012-12-31 | N missing data (%) | 4 (6.78%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 1 (1.61%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 5 (1.25%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| procedure_occurrence; overall; Male      |                          |                    |                 |
| modifier_concept_id                      | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 104 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 101 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 71 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 70 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 58 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 86 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 67 (100.00%)    |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 1 (100.00%)     |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 558 (100.00%)   |
| modifier_source_value                    | 2012-01-01 to 2012-12-31 | N missing data (%) | 104 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 101 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 71 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 70 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 58 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 86 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 67 (100.00%)    |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 1 (100.00%)     |
|                                          | overall                  | N missing data (%) | 558 (100.00%)   |
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
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
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
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
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
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| procedure_datetime                       | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
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
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
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
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
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
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
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
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| provider_id                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 104 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 101 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 71 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 70 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 58 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 86 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 67 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 1 (100.00%)     |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 558 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| quantity                                 | 2012-01-01 to 2012-12-31 | N missing data (%) | 104 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 101 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 71 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 70 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 58 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 86 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 67 (100.00%)    |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 1 (100.00%)     |
|                                          | overall                  | N missing data (%) | 558 (100.00%)   |
| visit_detail_id                          | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 104 (100.00%)   |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 101 (100.00%)   |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 71 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 70 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 58 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 86 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 67 (100.00%)    |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 1 (100.00%)     |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 558 (100.00%)   |
| visit_occurrence_id                      | 2012-01-01 to 2012-12-31 | N missing data (%) | 2 (1.92%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 1 (1.43%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 1 (1.72%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 4 (0.72%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| procedure_occurrence; overall; Female    |                          |                    |                 |
| modifier_concept_id                      | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 80 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 58 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 56 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 62 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 53 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 55 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 72 (100.00%)    |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 436 (100.00%)   |
| modifier_source_value                    | 2012-01-01 to 2012-12-31 | N missing data (%) | 80 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 58 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 56 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 62 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 53 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 55 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 72 (100.00%)    |
|                                          | overall                  | N missing data (%) | 436 (100.00%)   |
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
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 58 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 56 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 62 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 53 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 55 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 72 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 436 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| quantity                                 | 2012-01-01 to 2012-12-31 | N missing data (%) | 80 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 58 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 56 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 62 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 53 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 55 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 72 (100.00%)    |
|                                          | overall                  | N missing data (%) | 436 (100.00%)   |
| visit_detail_id                          | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 80 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 58 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 56 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 62 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 53 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 55 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 72 (100.00%)    |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 436 (100.00%)   |
| visit_occurrence_id                      | 2012-01-01 to 2012-12-31 | N missing data (%) | 2 (2.50%)       |
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
|                                          | overall                  | N missing data (%) | 2 (0.46%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| procedure_occurrence; 65 to 150; Female  |                          |                    |                 |
| modifier_concept_id                      | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 24 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 21 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 21 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 28 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 27 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 29 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 39 (100.00%)    |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 189 (100.00%)   |
| modifier_source_value                    | 2012-01-01 to 2012-12-31 | N missing data (%) | 24 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 21 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 21 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 28 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 27 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 29 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 39 (100.00%)    |
|                                          | overall                  | N missing data (%) | 189 (100.00%)   |
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
| provider_id                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 24 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 21 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 21 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 28 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 27 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 29 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 39 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 189 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| quantity                                 | 2012-01-01 to 2012-12-31 | N missing data (%) | 24 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 21 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 21 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 28 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 27 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 29 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 39 (100.00%)    |
|                                          | overall                  | N missing data (%) | 189 (100.00%)   |
| visit_detail_id                          | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 24 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 21 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 21 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 28 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 27 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 29 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 39 (100.00%)    |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 189 (100.00%)   |
| visit_occurrence_id                      | 2012-01-01 to 2012-12-31 | N missing data (%) | 2 (8.33%)       |
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
|                                          | overall                  | N missing data (%) | 2 (1.06%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| procedure_occurrence; 65 to 150; Male    |                          |                    |                 |
| modifier_concept_id                      | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 35 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 26 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 27 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 34 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 24 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 32 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 34 (100.00%)    |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 212 (100.00%)   |
| modifier_source_value                    | 2012-01-01 to 2012-12-31 | N missing data (%) | 35 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 26 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 27 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 34 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 24 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 32 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 34 (100.00%)    |
|                                          | overall                  | N missing data (%) | 212 (100.00%)   |
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
| provider_id                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 35 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 26 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 27 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 34 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 24 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 32 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 34 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 212 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| quantity                                 | 2012-01-01 to 2012-12-31 | N missing data (%) | 35 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 26 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 27 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 34 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 24 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 32 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 34 (100.00%)    |
|                                          | overall                  | N missing data (%) | 212 (100.00%)   |
| visit_detail_id                          | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 35 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 26 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 27 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 34 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 24 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 32 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 34 (100.00%)    |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 212 (100.00%)   |
| visit_occurrence_id                      | 2012-01-01 to 2012-12-31 | N missing data (%) | 2 (5.71%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 1 (2.94%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 3 (1.42%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| procedure_occurrence; 18 to 64; Male     |                          |                    |                 |
| modifier_concept_id                      | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 69 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 75 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 44 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 36 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 34 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 54 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 33 (100.00%)    |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 1 (100.00%)     |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 346 (100.00%)   |
| modifier_source_value                    | 2012-01-01 to 2012-12-31 | N missing data (%) | 69 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 75 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 44 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 36 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 34 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 54 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 33 (100.00%)    |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 1 (100.00%)     |
|                                          | overall                  | N missing data (%) | 346 (100.00%)   |
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
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
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
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
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
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
| procedure_datetime                       | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
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
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
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
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
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
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
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
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| provider_id                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 69 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 75 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 44 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 36 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 34 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 54 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 33 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 1 (100.00%)     |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 346 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| quantity                                 | 2012-01-01 to 2012-12-31 | N missing data (%) | 69 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 75 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 44 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 36 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 34 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 54 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 33 (100.00%)    |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 1 (100.00%)     |
|                                          | overall                  | N missing data (%) | 346 (100.00%)   |
| visit_detail_id                          | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 69 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 75 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 44 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 36 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 34 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 54 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 33 (100.00%)    |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 1 (100.00%)     |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 346 (100.00%)   |
| visit_occurrence_id                      | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 1 (2.94%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2019-01-01 to 2019-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 1 (0.29%)       |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| procedure_occurrence; 18 to 64; Female   |                          |                    |                 |
| modifier_concept_id                      | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 56 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 37 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 35 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 34 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 26 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 26 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 33 (100.00%)    |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 247 (100.00%)   |
| modifier_source_value                    | 2012-01-01 to 2012-12-31 | N missing data (%) | 56 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 37 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 35 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 34 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 26 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 26 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 33 (100.00%)    |
|                                          | overall                  | N missing data (%) | 247 (100.00%)   |
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
| provider_id                              | 2012-01-01 to 2012-12-31 | N missing data (%) | 56 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 37 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 35 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 34 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 26 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 26 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 33 (100.00%)    |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
|                                          | overall                  | N missing data (%) | 247 (100.00%)   |
|                                          |                          | N zeros (%)        | 0 (0.00%)       |
| quantity                                 | 2012-01-01 to 2012-12-31 | N missing data (%) | 56 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 37 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 35 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 34 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 26 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 26 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 33 (100.00%)    |
|                                          | overall                  | N missing data (%) | 247 (100.00%)   |
| visit_detail_id                          | 2012-01-01 to 2012-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 56 (100.00%)    |
|                                          | 2013-01-01 to 2013-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 37 (100.00%)    |
|                                          | 2014-01-01 to 2014-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 35 (100.00%)    |
|                                          | 2015-01-01 to 2015-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 34 (100.00%)    |
|                                          | 2016-01-01 to 2016-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 26 (100.00%)    |
|                                          | 2017-01-01 to 2017-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 26 (100.00%)    |
|                                          | 2018-01-01 to 2018-12-31 | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 33 (100.00%)    |
|                                          | overall                  | N missing data (%) | 0 (0.00%)       |
|                                          |                          | N zeros (%)        | 247 (100.00%)   |
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

Summary of missingness in condition_occurrence, drug_exposure,
procedure_occurrence tables

Finally, disconnect from the cdm

``` r
CDMConnector::cdmDisconnect(cdm = cdm)
```
