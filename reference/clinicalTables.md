# Tables in the cdm_reference that contain clinical information

This function provides a list of allowed inputs for the `omopTableName`
argument in `summariseClinicalRecords`

## Usage

``` r
clinicalTables()
```

## Value

A character vector with table names

## Examples

``` r
library(OmopSketch)

clinicalTables()
#>  [1] "visit_occurrence"     "visit_detail"         "condition_occurrence"
#>  [4] "drug_exposure"        "procedure_occurrence" "device_exposure"     
#>  [7] "measurement"          "observation"          "death"               
#> [10] "note"                 "specimen"             "payer_plan_period"   
#> [13] "drug_era"             "dose_era"             "condition_era"       
```
