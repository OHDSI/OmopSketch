# Create a visual table from a summariseMissingData() result.

Create a visual table from a summariseMissingData() result.

## Usage

``` r
tableMissingData(result, type = "gt", style = "default")
```

## Arguments

- result:

  A summarised_result object.

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
cdm <- mockOmopSketch(numberIndividuals = 100)
#> ℹ Reading GiBleed tables.

result <- summariseMissingData(
  cdm = cdm,
  omopTableName = c("condition_occurrence", "visit_occurrence")
)
#> The person table has ≤ 1e+05 subjects; skipping sampling of the CDM.
#> The person table has ≤ 1e+05 subjects; skipping sampling of the CDM.

tableMissingData(result = result)


  
Summary of missingness in condition_occurrence, visit_occurrence tables

  

Column name
```

Estimate name

Database name

mockOmopSketch

visit_occurrence

admitting_source_concept_id

N missing data (%)

37,102 (100.00%)

N zeros (%)

0 (0.00%)

admitting_source_value

N missing data (%)

37,102 (100.00%)

care_site_id

N missing data (%)

37,102 (100.00%)

N zeros (%)

0 (0.00%)

discharge_to_concept_id

N missing data (%)

37,102 (100.00%)

N zeros (%)

0 (0.00%)

discharge_to_source_value

N missing data (%)

37,102 (100.00%)

person_id

N missing data (%)

0 (0.00%)

N zeros (%)

0 (0.00%)

preceding_visit_occurrence_id

N missing data (%)

37,102 (100.00%)

N zeros (%)

0 (0.00%)

provider_id

N missing data (%)

37,102 (100.00%)

N zeros (%)

0 (0.00%)

visit_concept_id

N missing data (%)

0 (0.00%)

N zeros (%)

0 (0.00%)

visit_end_date

N missing data (%)

0 (0.00%)

visit_end_datetime

N missing data (%)

37,102 (100.00%)

visit_occurrence_id

N missing data (%)

0 (0.00%)

N zeros (%)

0 (0.00%)

visit_source_concept_id

N missing data (%)

37,102 (100.00%)

N zeros (%)

0 (0.00%)

visit_source_value

N missing data (%)

37,102 (100.00%)

visit_start_date

N missing data (%)

0 (0.00%)

visit_start_datetime

N missing data (%)

37,102 (100.00%)

visit_type_concept_id

N missing data (%)

0 (0.00%)

N zeros (%)

37,102 (100.00%)

condition_occurrence

condition_concept_id

N missing data (%)

0 (0.00%)

N zeros (%)

0 (0.00%)

condition_end_date

N missing data (%)

0 (0.00%)

condition_end_datetime

N missing data (%)

8,400 (100.00%)

condition_occurrence_id

N missing data (%)

0 (0.00%)

N zeros (%)

0 (0.00%)

condition_source_concept_id

N missing data (%)

8,400 (100.00%)

N zeros (%)

0 (0.00%)

condition_source_value

N missing data (%)

8,400 (100.00%)

condition_start_date

N missing data (%)

0 (0.00%)

condition_start_datetime

N missing data (%)

8,400 (100.00%)

condition_status_concept_id

N missing data (%)

8,400 (100.00%)

N zeros (%)

0 (0.00%)

condition_status_source_value

N missing data (%)

8,400 (100.00%)

condition_type_concept_id

N missing data (%)

0 (0.00%)

N zeros (%)

8,400 (100.00%)

person_id

N missing data (%)

0 (0.00%)

N zeros (%)

0 (0.00%)

provider_id

N missing data (%)

8,400 (100.00%)

N zeros (%)

0 (0.00%)

stop_reason

N missing data (%)

8,400 (100.00%)

visit_detail_id

N missing data (%)

8,400 (100.00%)

N zeros (%)

0 (0.00%)

visit_occurrence_id

N missing data (%)

0 (0.00%)

N zeros (%)

0 (0.00%)

CDMConnector::[cdmDisconnect](https://darwin-eu.github.io/omopgenerics/reference/cdmDisconnect.html)(cdm
= cdm) \# }
