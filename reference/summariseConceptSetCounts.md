# Summarise concept counts in patient-level data. Only concepts recorded during observation period are counted.

Summarise concept counts in patient-level data. Only concepts recorded
during observation period are counted.

## Usage

``` r
summariseConceptSetCounts(
  cdm,
  conceptSet,
  countBy = c("record", "person"),
  concept = TRUE,
  interval = "overall",
  sex = FALSE,
  ageGroup = NULL,
  dateRange = NULL
)
```

## Arguments

- cdm:

  A cdm object

- conceptSet:

  List of concept IDs to summarise.

- countBy:

  Either "record" for record-level counts or "person" for person-level
  counts

- concept:

  TRUE or FALSE. If TRUE code use will be summarised by concept.

- interval:

  Time interval to stratify by. It can either be "years", "quarters",
  "months" or "overall".

- sex:

  TRUE or FALSE. If TRUE code use will be summarised by sex.

- ageGroup:

  A list of ageGroup vectors of length two. Code use will be thus
  summarised by age groups.

- dateRange:

  A vector of two dates defining the desired study period. Only the
  `start_date` column of the OMOP table is checked to ensure it falls
  within this range. If `dateRange` is `NULL`, no restriction is
  applied.

## Value

A summarised_result object with results overall and, if specified, by
strata.

## Examples

``` r
# \donttest{
library(OmopSketch)

cdm <- mockOmopSketch()
#> ℹ Reading GiBleed tables.

cs <- list(sinusitis = c(4283893, 257012, 40481087, 4294548))

results <- summariseConceptSetCounts(cdm, conceptSet = cs)
#> Warning: ! `codelist` casted to integers.
#> ℹ Searching concepts from domain condition in condition_occurrence.
#> ℹ Counting concepts

results
#> # A tibble: 10 × 13
#>    result_id cdm_name       group_name    group_level strata_name strata_level
#>        <int> <chr>          <chr>         <chr>       <chr>       <chr>       
#>  1         1 mockOmopSketch codelist_name sinusitis   overall     overall     
#>  2         1 mockOmopSketch codelist_name sinusitis   overall     overall     
#>  3         1 mockOmopSketch codelist_name sinusitis   overall     overall     
#>  4         1 mockOmopSketch codelist_name sinusitis   overall     overall     
#>  5         1 mockOmopSketch codelist_name sinusitis   overall     overall     
#>  6         1 mockOmopSketch codelist_name sinusitis   overall     overall     
#>  7         1 mockOmopSketch codelist_name sinusitis   overall     overall     
#>  8         1 mockOmopSketch codelist_name sinusitis   overall     overall     
#>  9         1 mockOmopSketch codelist_name sinusitis   overall     overall     
#> 10         1 mockOmopSketch codelist_name sinusitis   overall     overall     
#> # ℹ 7 more variables: variable_name <chr>, variable_level <chr>,
#> #   estimate_name <chr>, estimate_type <chr>, estimate_value <chr>,
#> #   additional_name <chr>, additional_level <chr>

PatientProfiles::mockDisconnect(cdm)
# }
```
