# Summarise concept id counts

## Introduction

In this vignette, we will explore the *OmopSketch* functions designed to
provide information about the number of counts of concepts in tables.
Specifically, there are two key functions that facilitate this,
[`summariseConceptIdCounts()`](https://OHDSI.github.io/OmopSketch/reference/summariseConceptIdCounts.md)
and
[`tableConceptIdCounts()`](https://OHDSI.github.io/OmopSketch/reference/tableConceptIdCounts.md).
The former one creates a summary statistics results with the number of
counts per each concept in the clinical table, and the latter one
displays the result in a table.

### Create a mock cdm

Let’s see an example of the previous functions. To start with, we will
load essential packages and create a mock cdm using
[`mockOmopSketch()`](https://OHDSI.github.io/OmopSketch/reference/mockOmopSketch.md).

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

## Summarise concept id counts

We now use the
[`summariseConceptIdCounts()`](https://OHDSI.github.io/OmopSketch/reference/summariseConceptIdCounts.md)
function from the OmopSketch package to retrieve counts for each concept
id and name, as well as for each source concept id and name, across the
clinical tables.

``` r
summariseConceptIdCounts(cdm, omopTableName = "drug_exposure") |>
  select(group_level, variable_name, variable_level, estimate_name, estimate_value, additional_name, additional_level) |>
  glimpse()
#> Rows: 216
#> Columns: 7
#> $ group_level      <chr> "drug_exposure", "drug_exposure", "drug_exposure", "d…
#> $ variable_name    <chr> "pneumococcal polysaccharide vaccine, 23 valent", "Al…
#> $ variable_level   <chr> "40213201", "1557272", "40213160", "1149380", "402132…
#> $ estimate_name    <chr> "count_records", "count_records", "count_records", "c…
#> $ estimate_value   <chr> "100", "100", "100", "100", "100", "100", "100", "100…
#> $ additional_name  <chr> "source_concept_id &&& source_concept_name", "source_…
#> $ additional_level <chr> "0 &&& No matching concept", "0 &&& No matching conce…
```

By default, the function returns the number of records
(`estimate_name == "count_records"`) for each concept_id. To include
counts by person, you can set the `countBy` argument to `"person"` or to
c`("record", "person")` to obtain both record and person counts.

``` r
summariseConceptIdCounts(cdm,
  omopTableName = "drug_exposure",
  countBy = c("record", "person")
) |>
  select(variable_name, estimate_name, estimate_value)
#> # A tibble: 432 × 3
#>    variable_name                                    estimate_name estimate_value
#>    <chr>                                            <chr>         <chr>         
#>  1 pneumococcal polysaccharide vaccine, 23 valent   count_records 100           
#>  2 pneumococcal polysaccharide vaccine, 23 valent   count_subjec… 62            
#>  3 Alendronate                                      count_records 100           
#>  4 Alendronate                                      count_subjec… 67            
#>  5 poliovirus vaccine, inactivated                  count_records 100           
#>  6 poliovirus vaccine, inactivated                  count_subjec… 66            
#>  7 fluticasone                                      count_records 100           
#>  8 fluticasone                                      count_subjec… 63            
#>  9 diphtheria, tetanus toxoids and acellular pertu… count_records 100           
#> 10 diphtheria, tetanus toxoids and acellular pertu… count_subjec… 58            
#> # ℹ 422 more rows
```

Further stratification can be applied using the `interval`, `sex`, and
`ageGroup` arguments. The interval argument supports “overall” (no time
stratification), “years”, “quarters”, or “months”.

``` r
summariseConceptIdCounts(cdm,
  omopTableName = "condition_occurrence",
  countBy = "person",
  interval = "years",
  sex = TRUE,
  ageGroup = list("<=50" = c(0, 50), ">50" = c(51, Inf))
) |>
  select(group_level, strata_level, variable_name, estimate_name, additional_level) |>
  glimpse()
#> Rows: 16,976
#> Columns: 5
#> $ group_level      <chr> "condition_occurrence", "condition_occurrence", "cond…
#> $ strata_level     <chr> "overall", "overall", "overall", "overall", "overall"…
#> $ variable_name    <chr> "Escherichia coli urinary tract infection", "Childhoo…
#> $ estimate_name    <chr> "count_subjects", "count_subjects", "count_subjects",…
#> $ additional_level <chr> "0 &&& No matching concept", "0 &&& No matching conce…
```

We can also filter the clinical table to a specific time window by
setting the dateRange argument.

``` r
summarisedResult <- summariseConceptIdCounts(cdm,
  omopTableName = "condition_occurrence",
  dateRange = as.Date(c("1990-01-01", "2010-01-01"))
)
summarisedResult |>
  omopgenerics::settings() |>
  glimpse()
#> Rows: 1
#> Columns: 10
#> $ result_id          <int> 1
#> $ result_type        <chr> "summarise_concept_id_counts"
#> $ package_name       <chr> "OmopSketch"
#> $ package_version    <chr> "0.5.1.900"
#> $ group              <chr> "omop_table"
#> $ strata             <chr> ""
#> $ additional         <chr> "source_concept_id &&& source_concept_name"
#> $ min_cell_count     <chr> "0"
#> $ study_period_end   <chr> "2010-01-01"
#> $ study_period_start <chr> "1990-01-01"
```

Finally, you can restrict concept counts to a subset of subjects via the
`sample` argument: provide an integer to randomly select that many
`person_id`s from the `person` table, or a character string naming a
`cohort` table to limit counts to its `subject_id`s.

``` r
summariseConceptIdCounts(cdm,
  omopTableName = "condition_occurrence",
  sample = 50
) |>
  select(group_level, variable_name, estimate_name) |>
  glimpse()
#> Rows: 84
#> Columns: 3
#> $ group_level   <chr> "condition_occurrence", "condition_occurrence", "conditi…
#> $ variable_name <chr> "Escherichia coli urinary tract infection", "Childhood a…
#> $ estimate_name <chr> "count_records", "count_records", "count_records", "coun…
```

### Display the results

Finally, concept counts can be visualised using
[`tableConceptIdCounts()`](https://OHDSI.github.io/OmopSketch/reference/tableConceptIdCounts.md).
By default, it generates an interactive
[reactable](https://glin.github.io/reactable/) table, but
[DT](https://rstudio.github.io/DT/) datatables are also supported.

``` r
result <- summariseConceptIdCounts(cdm,
  omopTableName = "measurement",
  countBy = "record"
)
tableConceptIdCounts(result, type = "reactable")
```

``` r
tableConceptIdCounts(result, type = "datatable")
```

The `display` argument in tableConceptIdCounts() controls which concept
counts are shown. Available options include `display = "overall"`. It is
the default option and it shows both standard and source concept counts.

``` r
tableConceptIdCounts(result, display = "overall")
```

If `display = "standard"` the table shows only **standard** concept_id
and concept_name counts.

``` r
tableConceptIdCounts(result, display = "standard")
```

If `display = "source"` the table shows only **source** concept_id and
concept_name counts.

``` r
tableConceptIdCounts(result, display = "source")
```

If `display = "missing source"` the table shows only counts for concept
ids that are missing a corresponding source concept id.

``` r
tableConceptIdCounts(result, display = "missing source")
```

If `display = "missing standard"` the table shows only counts for source
concept ids that are missing a mapped standard concept id.

``` r
tableConceptIdCounts(result, display = "missing standard")
#> Warning in max(dplyr::pull(dplyr::tally(dplyr::group_by(result,
#> dplyr::across(-c("estimate_value")))), : no non-missing arguments to max;
#> returning -Inf
```

### Display the most frequent concepts

You can use the
[`tableTopConceptCounts()`](https://OHDSI.github.io/OmopSketch/reference/tableTopConceptCounts.md)
function to display the most frequent concepts in a OMOP CDM table in
formatted table. By default, the function returns a
[gt](https://gt.rstudio.com/) table, but you can also choose from other
output formats, including
[flextable](https://davidgohel.github.io/flextable/),
[datatable](https://rstudio.github.io/DT/), and
[reactable](https://glin.github.io/reactable/).

``` r
result <- summariseConceptIdCounts(cdm,
  omopTableName = "drug_exposure",
  countBy = "record"
)
tableTopConceptCounts(result, type = "gt")
```

[TABLE]

Top 10 concepts in drug_exposure table

#### Customising the number of top concepts

By default, the function shows the top 10 concepts. You can change this
using the `top` argument:

``` r
tableTopConceptCounts(result, top = 5)
```

[TABLE]

Top 5 concepts in drug_exposure table

#### Choosing the count type

If your summary includes both record and person counts, you must specify
which type to display using the `countBy` argument:

``` r
result <- summariseConceptIdCounts(cdm,
  omopTableName = "drug_exposure",
  countBy = c("record", "person")
)
tableTopConceptCounts(result, countBy = "person")
```

[TABLE]

Top 10 concepts in drug_exposure table
