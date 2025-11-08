# Creates a mock database to test OmopSketch package.

Creates a mock database to test OmopSketch package.

## Usage

``` r
mockOmopSketch(
  numberIndividuals = 100,
  con = lifecycle::deprecated(),
  writeSchema = lifecycle::deprecated(),
  seed = lifecycle::deprecated()
)
```

## Arguments

- numberIndividuals:

  Number of individuals to create in the cdm reference object.

- con:

  deprecated.

- writeSchema:

  deprecated.

- seed:

  deprecated.

## Value

A mock cdm_reference object.

## Examples

``` r
# \donttest{
library(OmopSketch)

cdm <- mockOmopSketch(numberIndividuals = 100)
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

# to insert into a duck db connection
library(duckdb)
#> Loading required package: DBI
library(CDMConnector)

con <- dbConnect(drv = duckdb())
to <- dbSource(con = con, writeSchema = "main")
cdm <- insertCdmTo(cdm = cdm, to = to)

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
# }
```
