# Summarise clinical tables records

## Introduction

In this vignette, we will explore the *OmopSketch* functions designed to
provide an overview of the clinical tables within a CDM object
(e.g. *visit_occurrence*, *condition_occurrence*, *drug_exposure*,
*procedure_occurrence*, *device_exposure*, *measurement*, *observation*,
and *death*). Specifically, there are two key functions that facilitate
this:

- [`summariseClinicalRecords()`](https://OHDSI.github.io/OmopSketch/reference/summariseClinicalRecords.md):
  creates a summary statistics with key basic information about the
  clinical table (e.g., number of records, records per person, etc.),
  some quality checks (e.g, missingness, correct filling of date
  columns, etc.) and a summary of the concepts used in the table
  (domains, source vocabularies, etc.)

- [`tableClinicalRecords()`](https://OHDSI.github.io/OmopSketch/reference/tableClinicalRecords.md):
  helps visualising the results in a formatted table.

### Create a mock cdm

Let’s see an example of its functionalities. To start with, we will load
essential packages and create a mock cdm using the
[`mockOmopSketch()`](https://OHDSI.github.io/OmopSketch/reference/mockOmopSketch.md)
function

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

## Summarise clinical tables

Let’s now use `summariseClinicalTables()`from the OmopSketch package to
help us have an overview of one of the clinical tables of the cdm (i.e.,
**condition_occurrence**).

``` r
summarisedResult <- summariseClinicalRecords(cdm, omopTableName = "condition_occurrence")
#> ℹ Adding variables of interest to condition_occurrence.
#> ℹ Summarising records per person in condition_occurrence.
#> ℹ Summarising subjects not in person table in condition_occurrence.
#> ℹ Summarising records in observation in condition_occurrence.
#> ℹ Summarising records with start before birth date in condition_occurrence.
#> ℹ Summarising records with end date before start date in condition_occurrence.
#> ℹ Summarising domains in condition_occurrence.
#> ℹ Summarising standard concepts in condition_occurrence.
#> ℹ Summarising source vocabularies in condition_occurrence.
#> ℹ Summarising concept types in condition_occurrence.
#> ℹ Summarising missing data in condition_occurrence.

summarisedResult |> print()
#> # A tibble: 76 × 13
#>    result_id cdm_name       group_name group_level      strata_name strata_level
#>        <int> <chr>          <chr>      <chr>            <chr>       <chr>       
#>  1         1 mockOmopSketch omop_table condition_occur… overall     overall     
#>  2         1 mockOmopSketch omop_table condition_occur… overall     overall     
#>  3         1 mockOmopSketch omop_table condition_occur… overall     overall     
#>  4         1 mockOmopSketch omop_table condition_occur… overall     overall     
#>  5         1 mockOmopSketch omop_table condition_occur… overall     overall     
#>  6         1 mockOmopSketch omop_table condition_occur… overall     overall     
#>  7         1 mockOmopSketch omop_table condition_occur… overall     overall     
#>  8         1 mockOmopSketch omop_table condition_occur… overall     overall     
#>  9         1 mockOmopSketch omop_table condition_occur… overall     overall     
#> 10         1 mockOmopSketch omop_table condition_occur… overall     overall     
#> # ℹ 66 more rows
#> # ℹ 7 more variables: variable_name <chr>, variable_level <chr>,
#> #   estimate_name <chr>, estimate_type <chr>, estimate_value <chr>,
#> #   additional_name <chr>, additional_level <chr>
```

Notice that the output is in the [summarised
result](https://darwin-eu.github.io/omopgenerics/articles/summarised_result.html)
format. \## Records per person We can use the arguments to specify which
statistics we want to perform. For example, use the argument
`recordsPerPerson` to indicate which estimates you are interested
regarding the number of records per person.

``` r
summarisedResult <- summariseClinicalRecords(cdm,
  omopTableName = "condition_occurrence",
  recordsPerPerson = c("mean", "sd", "q05", "q95")
)
#> ℹ Adding variables of interest to condition_occurrence.
#> ℹ Summarising records per person in condition_occurrence.
#> ℹ Summarising subjects not in person table in condition_occurrence.
#> ℹ Summarising records in observation in condition_occurrence.
#> ℹ Summarising records with start before birth date in condition_occurrence.
#> ℹ Summarising records with end date before start date in condition_occurrence.
#> ℹ Summarising domains in condition_occurrence.
#> ℹ Summarising standard concepts in condition_occurrence.
#> ℹ Summarising source vocabularies in condition_occurrence.
#> ℹ Summarising concept types in condition_occurrence.
#> ℹ Summarising missing data in condition_occurrence.

summarisedResult |>
  filter(variable_name == "records_per_person") |>
  select(variable_name, estimate_name, estimate_value)
#> # A tibble: 0 × 3
#> # ℹ 3 variables: variable_name <chr>, estimate_name <chr>, estimate_value <chr>
```

### Quality

When the argument `quality = TRUE` is set, the results will include a
quality assessment of the data.  
This assessment provides information such as:

- The proportion of records that fall outside the subjects’ observation
  periods.  
- Issues with date columns (e.g., start dates occurring after end dates,
  or dates preceding a subject’s birth date).  
- The presence of `person_id` values that do not exist in the `person`
  table.

``` r
summarisedResult <- summariseClinicalRecords(cdm,
  omopTableName = "condition_occurrence",
  recordsPerPerson = c(), 
  conceptSummary = FALSE,
  missing = FALSE,
  quality = TRUE
)
#> ℹ Adding variables of interest to condition_occurrence.
#> ℹ Summarising records per person in condition_occurrence.
#> ℹ Summarising subjects not in person table in condition_occurrence.
#> ℹ Summarising records in observation in condition_occurrence.
#> ℹ Summarising records with start before birth date in condition_occurrence.
#> ℹ Summarising records with end date before start date in condition_occurrence.

summarisedResult |>
  select(variable_name, estimate_name, estimate_value) 
#> # A tibble: 11 × 3
#>    variable_name                estimate_name estimate_value
#>    <chr>                        <chr>         <chr>         
#>  1 Number subjects              count         100           
#>  2 Number subjects              percentage    100           
#>  3 Number records               count         8400          
#>  4 Subjects not in person table count         0             
#>  5 Subjects not in person table percentage    0.00          
#>  6 In observation               count         8400          
#>  7 Start date before birth date count         0             
#>  8 End date before start date   count         0             
#>  9 In observation               percentage    100.00        
#> 10 Start date before birth date percentage    0.00          
#> 11 End date before start date   percentage    0.00
```

### Concept Summary

When the argument `conceptSummary = TRUE` is set, the results will also
include information about the concepts contained in the table, such as:

- The domain to which each concept belongs.  
- Whether each concept is a standard concept.  
- The type and source vocabulary associated with each concept.

``` r
summarisedResult <- summariseClinicalRecords(cdm,
  omopTableName = "drug_exposure",
  recordsPerPerson = c(), 
  conceptSummary = TRUE,
  missing = FALSE,
  quality = FALSE
)
#> ℹ Adding variables of interest to drug_exposure.
#> ℹ Summarising records per person in drug_exposure.
#> ℹ Summarising domains in drug_exposure.
#> ℹ Summarising standard concepts in drug_exposure.
#> ℹ Summarising source vocabularies in drug_exposure.
#> ℹ Summarising concept types in drug_exposure.
#> ℹ Summarising concept class in drug_exposure.

summarisedResult |>
  select(variable_name, variable_level, estimate_name, estimate_value) 
#> # A tibble: 29 × 4
#>    variable_name     variable_level          estimate_name estimate_value
#>    <chr>             <chr>                   <chr>         <chr>         
#>  1 Number subjects   NA                      count         100           
#>  2 Number subjects   NA                      percentage    100           
#>  3 Number records    NA                      count         21600         
#>  4 Domain            Drug                    count         21600         
#>  5 Standard concept  S                       count         21600         
#>  6 Source vocabulary No matching concept     count         21600         
#>  7 Type concept id   Unknown type concept: 0 count         21600         
#>  8 Concept class     CVX                     count         1600          
#>  9 Concept class     Ingredient              count         9100          
#> 10 Concept class     Branded Pack            count         1100          
#> # ℹ 19 more rows
```

### Missingness

When the argument `missing = TRUE` is set, the results will include a
summary of missing data in the table, including the number of `0`s in
the concept columns.  
This output is analogous to the results produced by the OmopSketch
function
[`summariseMissingData()`](https://OHDSI.github.io/OmopSketch/reference/summariseMissingData.md).

``` r
summarisedResult <- summariseClinicalRecords(cdm,
  omopTableName = "condition_occurrence",
  recordsPerPerson = c(), 
  conceptSummary = FALSE,
  missing = TRUE,
  quality = FALSE
)
#> ℹ Adding variables of interest to condition_occurrence.
#> ℹ Summarising records per person in condition_occurrence.
#> ℹ Summarising missing data in condition_occurrence.

summarisedResult |>
  select(variable_name, variable_level, estimate_name, estimate_value) 
#> # A tibble: 53 × 4
#>    variable_name   variable_level          estimate_name   estimate_value
#>    <chr>           <chr>                   <chr>           <chr>         
#>  1 Number subjects NA                      count           100           
#>  2 Number subjects NA                      percentage      100           
#>  3 Number records  NA                      count           8400          
#>  4 Column name     condition_occurrence_id na_count        0             
#>  5 Column name     condition_occurrence_id na_percentage   0.00          
#>  6 Column name     condition_occurrence_id zero_count      0             
#>  7 Column name     condition_occurrence_id zero_percentage 0.00          
#>  8 Column name     person_id               na_count        0             
#>  9 Column name     person_id               na_percentage   0.00          
#> 10 Column name     person_id               zero_count      0             
#> # ℹ 43 more rows
```

### Strata

It is also possible to stratify the results by sex and age groups:

``` r
summarisedResult <- summariseClinicalRecords(cdm,
  omopTableName = "condition_occurrence",
  recordsPerPerson = c("mean", "sd", "q05", "q95"),
  quality = TRUE,
  conceptSummary = TRUE,
  sex = TRUE,
  ageGroup = list("<35" = c(0, 34), ">=35" = c(35, Inf))
)
#> ℹ Adding variables of interest to condition_occurrence.
#> ℹ Summarising records per person in condition_occurrence.
#> ℹ Summarising subjects not in person table in condition_occurrence.
#> ℹ Summarising records in observation in condition_occurrence.
#> ℹ Summarising records with start before birth date in condition_occurrence.
#> ℹ Summarising records with end date before start date in condition_occurrence.
#> ℹ Summarising domains in condition_occurrence.
#> ℹ Summarising standard concepts in condition_occurrence.
#> ℹ Summarising source vocabularies in condition_occurrence.
#> ℹ Summarising concept types in condition_occurrence.
#> ℹ Summarising missing data in condition_occurrence.

summarisedResult |>
  select(variable_name, strata_level, estimate_name, estimate_value) 
#> # A tibble: 609 × 4
#>    variable_name      strata_level estimate_name estimate_value
#>    <chr>              <chr>        <chr>         <chr>         
#>  1 Number subjects    overall      count         100           
#>  2 Number subjects    overall      percentage    100           
#>  3 Records per person overall      mean          84            
#>  4 Records per person overall      sd            9.9666        
#>  5 Records per person overall      q05           68.9500       
#>  6 Records per person overall      q95           100.1000      
#>  7 Number records     overall      count         8400          
#>  8 Number subjects    <35          count         80            
#>  9 Number subjects    >=35         count         32            
#> 10 Number subjects    <35          percentage    100           
#> # ℹ 599 more rows
```

Notice that, by default, the “overall” group will also be included, as
well as crossed strata (that means, `sex == "Female"` and
`ageGroup == "\>35"`).

Also, see that the analysis can be conducted for multiple OMOP tables at
the same time:

``` r
summarisedResult <- summariseClinicalRecords(cdm,
  omopTableName = c("visit_occurrence", "drug_exposure"),
  recordsPerPerson = c("mean", "sd"),
  quality = FALSE,
  conceptSummary = FALSE,
  missingData = FALSE
)
#> ℹ Adding variables of interest to visit_occurrence.
#> ℹ Summarising records per person in visit_occurrence.
#> ℹ Adding variables of interest to drug_exposure.
#> ℹ Summarising records per person in drug_exposure.

summarisedResult |>
  select(group_level, variable_name, estimate_name, estimate_value)
#> # A tibble: 10 × 4
#>    group_level      variable_name      estimate_name estimate_value
#>    <chr>            <chr>              <chr>         <chr>         
#>  1 visit_occurrence Number subjects    count         100           
#>  2 visit_occurrence Number subjects    percentage    100           
#>  3 visit_occurrence Records per person mean          345.9200      
#>  4 visit_occurrence Records per person sd            116.3114      
#>  5 visit_occurrence Number records     count         34592         
#>  6 drug_exposure    Number subjects    count         100           
#>  7 drug_exposure    Number subjects    percentage    100           
#>  8 drug_exposure    Records per person mean          216           
#>  9 drug_exposure    Records per person sd            15.4292       
#> 10 drug_exposure    Number records     count         21600
```

### Date Range

We can also filter the clinical table to a specific time window by
setting the `dateRange` argument.

``` r

summarisedResult <- summariseClinicalRecords(cdm, 
                                             omopTableName ="drug_exposure",
                                             dateRange = as.Date(c("1990-01-01", "2010-01-01"))) 
#> ℹ Adding variables of interest to drug_exposure.
#> ℹ Summarising records per person in drug_exposure.
#> ℹ Summarising subjects not in person table in drug_exposure.
#> ℹ Summarising records in observation in drug_exposure.
#> ℹ Summarising records with start before birth date in drug_exposure.
#> ℹ Summarising records with end date before start date in drug_exposure.
#> ℹ Summarising domains in drug_exposure.
#> ℹ Summarising standard concepts in drug_exposure.
#> ℹ Summarising source vocabularies in drug_exposure.
#> ℹ Summarising concept types in drug_exposure.
#> ℹ Summarising concept class in drug_exposure.
#> ℹ Summarising missing data in drug_exposure.

summarisedResult |>
  omopgenerics::settings() |>
  glimpse()
#> Rows: 1
#> Columns: 10
#> $ result_id          <int> 1
#> $ result_type        <chr> "summarise_clinical_records"
#> $ package_name       <chr> "OmopSketch"
#> $ package_version    <chr> "0.5.1.900"
#> $ group              <chr> "omop_table"
#> $ strata             <chr> ""
#> $ additional         <chr> ""
#> $ min_cell_count     <chr> "0"
#> $ study_period_end   <chr> "2010-01-01"
#> $ study_period_start <chr> "1990-01-01"
```

## Tidy the summarised object

[`tableClinicalRecords()`](https://OHDSI.github.io/OmopSketch/reference/tableClinicalRecords.md)
will help you to tidy the previous results and create a formatted table
of type [gt](https://gt.rstudio.com/),
[reactable](https://glin.github.io/reactable/) or
[datatable](https://rstudio.github.io/DT/). By default it creates a
[gt](https://gt.rstudio.com/) table.

``` r
summarisedResult <- summariseClinicalRecords(cdm,
  omopTableName = "condition_occurrence",
  recordsPerPerson = c("mean", "sd", "q05", "q95"),
  quality = TRUE, 
  conceptSummary = TRUE,
  sex = TRUE
)
#> ℹ Adding variables of interest to condition_occurrence.
#> ℹ Summarising records per person in condition_occurrence.
#> ℹ Summarising subjects not in person table in condition_occurrence.
#> ℹ Summarising records in observation in condition_occurrence.
#> ℹ Summarising records with start before birth date in condition_occurrence.
#> ℹ Summarising records with end date before start date in condition_occurrence.
#> ℹ Summarising domains in condition_occurrence.
#> ℹ Summarising standard concepts in condition_occurrence.
#> ℹ Summarising source vocabularies in condition_occurrence.
#> ℹ Summarising concept types in condition_occurrence.
#> ℹ Summarising missing data in condition_occurrence.

summarisedResult |>
  tableClinicalRecords(type = "gt")
```

[TABLE]

Summary of condition_occurrence table

Finally, we can disconnect from the cdm.

``` r
CDMConnector::cdmDisconnect(cdm = cdm)
```
