# Summarise the observation period table getting some overall statistics in a summarised_result object.

Summarise the observation period table getting some overall statistics
in a summarised_result object.

## Usage

``` r
summariseObservationPeriod(
  cdm,
  estimates = c("mean", "sd", "min", "q05", "q25", "median", "q75", "q95", "max",
    "density"),
  missingData = TRUE,
  quality = TRUE,
  byOrdinal = TRUE,
  ageGroup = NULL,
  sex = FALSE,
  dateRange = NULL,
  nameObservationPeriod = NULL,
  observationPeriod = lifecycle::deprecated()
)
```

## Arguments

- cdm:

  A cdm_reference object.

- estimates:

  Estimates to summarise the variables of interest (
  `Records per person`, `Duration in days` and
  `Days to next observation period`).

- missingData:

  Logical. If `TRUE`, includes a summary of missing data for relevant
  fields.

- quality:

  Logical. If `TRUE`, performs basic data quality checks, including:

  - Number of subjects not included in person table

  - Number of records with end date before start date

  - Number of records with start date before the person's birth date

- byOrdinal:

  Boolean variable. Whether to stratify by the ordinal observation
  period (e.g., 1st, 2nd, etc.) (TRUE) or simply analyze overall data
  (FALSE)

- ageGroup:

  A list of age groups to stratify results by.

- sex:

  Boolean variable. Whether to stratify by sex (TRUE) or not (FALSE).

- dateRange:

  A vector of two dates defining the desired study period. Only the
  `start_date` column of the OMOP table is checked to ensure it falls
  within this range. If `dateRange` is `NULL`, no restriction is
  applied.

- nameObservationPeriod:

  character string giving a descriptive name for the observation period.
  This name will be stored in the result settings. If `NULL` (default),
  the name is automatically set to `"Default"`.

- observationPeriod:

  deprecated.

## Value

A summarised_result object with the summarised data.

## Examples

``` r
# \donttest{
library(OmopSketch)
library(dplyr, warn.conflicts = FALSE)

cdm <- mockOmopSketch(numberIndividuals = 100)
#> ℹ Reading GiBleed tables.

result <- summariseObservationPeriod(cdm = cdm)

result |>
  glimpse()
#> Rows: 3,126
#> Columns: 13
#> $ result_id        <int> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,…
#> $ cdm_name         <chr> "mockOmopSketch", "mockOmopSketch", "mockOmopSketch",…
#> $ group_name       <chr> "observation_period_ordinal", "observation_period_ord…
#> $ group_level      <chr> "all", "all", "all", "all", "all", "all", "all", "all…
#> $ strata_name      <chr> "overall", "overall", "overall", "overall", "overall"…
#> $ strata_level     <chr> "overall", "overall", "overall", "overall", "overall"…
#> $ variable_name    <chr> "Records per person", "Records per person", "Records …
#> $ variable_level   <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
#> $ estimate_name    <chr> "mean", "sd", "min", "q05", "q25", "median", "q75", "…
#> $ estimate_type    <chr> "numeric", "numeric", "integer", "integer", "integer"…
#> $ estimate_value   <chr> "1", "0", "1", "1", "1", "1", "1", "1", "1", "3651.12…
#> $ additional_name  <chr> "overall", "overall", "overall", "overall", "overall"…
#> $ additional_level <chr> "overall", "overall", "overall", "overall", "overall"…

PatientProfiles::mockDisconnect(cdm)
# }
```
