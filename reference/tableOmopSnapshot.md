# Create a visual table from a summarise_omop_snapshot result.

Create a visual table from a summarise_omop_snapshot result.

## Usage

``` r
tableOmopSnapshot(result, type = "gt", style = "default")
```

## Arguments

- result:

  Output from summariseOmopSnapshot().

- type:

  Type of formatting output table. See
  [`visOmopResults::tableType()`](https://darwin-eu.github.io/visOmopResults/reference/tableType.html)
  for allowed options. Default is `"gt"`.

- style:

  Named list that specifies how to style the different parts of the gt
  or flextable table generated. Accepted style entries are: title,
  subtitle, header, header_name, header_level, column_name, group_label,
  and body. Alternatively, use "default" to get visOmopResults style, or
  NULL for gt/flextable style. Keep in mind that styling code is
  different for gt and flextable. Additionally, "datatable" and
  "reactable" have their own style functions. To see style options for
  each table type use
  [`visOmopResults::tableStyle()`](https://darwin-eu.github.io/visOmopResults/reference/tableStyle.html)

## Value

A formatted table object with the summarised data.

## Examples

``` r
# \donttest{
library(OmopSketch)

cdm <- mockOmopSketch(numberIndividuals = 10)
#> ℹ Reading GiBleed tables.

result <- summariseOmopSnapshot(cdm = cdm)

tableOmopSnapshot(result = result)


  
Snapshot of the cdm mockOmopSketch

  

Estimate
```

Database name

mockOmopSketch

General

Snapshot date

2025-11-08

Person count

10

Vocabulary version

v5.0 18-JAN-19

Cdm

Source name

Synthea synthetic health database

Version

5.3

Holder name

OHDSI Community

Release date

2019-05-25

Description

SyntheaTM is a Synthetic Patient Population Simulator. The goal is to
output synthetic, realistic (but not real), patient data and associated
health records in a variety of formats.

Documentation reference

https://synthetichealth.github.io/synthea/

Observation period

N

10

Start date

1976-01-23

End date

2019-11-27

Cdm source

Type

duckdb

Package

CDMConnector

Write schema

main

PatientProfiles::[mockDisconnect](https://darwin-eu.github.io/PatientProfiles/reference/mockDisconnect.html)(cdm)
\# }
