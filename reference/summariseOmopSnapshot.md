# Summarise a cdm_reference object creating a snapshot with the metadata of the cdm_reference object.

Summarise a cdm_reference object creating a snapshot with the metadata
of the cdm_reference object.

## Usage

``` r
summariseOmopSnapshot(cdm)
```

## Arguments

- cdm:

  A cdm_reference object.

## Value

A summarised_result object that contains the OMOP CDM snapshot
information.

## Examples

``` r
# \donttest{
library(OmopSketch)

cdm <- mockOmopSketch(numberIndividuals = 10)
#> ℹ Reading GiBleed tables.

summariseOmopSnapshot(cdm = cdm)
#> # A tibble: 15 × 13
#>    result_id cdm_name       group_name group_level strata_name strata_level
#>        <int> <chr>          <chr>      <chr>       <chr>       <chr>       
#>  1         1 mockOmopSketch overall    overall     overall     overall     
#>  2         1 mockOmopSketch overall    overall     overall     overall     
#>  3         1 mockOmopSketch overall    overall     overall     overall     
#>  4         1 mockOmopSketch overall    overall     overall     overall     
#>  5         1 mockOmopSketch overall    overall     overall     overall     
#>  6         1 mockOmopSketch overall    overall     overall     overall     
#>  7         1 mockOmopSketch overall    overall     overall     overall     
#>  8         1 mockOmopSketch overall    overall     overall     overall     
#>  9         1 mockOmopSketch overall    overall     overall     overall     
#> 10         1 mockOmopSketch overall    overall     overall     overall     
#> 11         1 mockOmopSketch overall    overall     overall     overall     
#> 12         1 mockOmopSketch overall    overall     overall     overall     
#> 13         1 mockOmopSketch overall    overall     overall     overall     
#> 14         1 mockOmopSketch overall    overall     overall     overall     
#> 15         1 mockOmopSketch overall    overall     overall     overall     
#> # ℹ 7 more variables: variable_name <chr>, variable_level <chr>,
#> #   estimate_name <chr>, estimate_type <chr>, estimate_value <chr>,
#> #   additional_name <chr>, additional_level <chr>
# }
```
