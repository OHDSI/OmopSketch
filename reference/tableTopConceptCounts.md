# Create a visual table of the most common concepts from `summariseConceptIdCounts()` output. This function takes a `summarised_result` object and generates a formatted table highlighting the most frequent concepts.

Create a visual table of the most common concepts from
[`summariseConceptIdCounts()`](https://OHDSI.github.io/OmopSketch/reference/summariseConceptIdCounts.md)
output. This function takes a `summarised_result` object and generates a
formatted table highlighting the most frequent concepts.

## Usage

``` r
tableTopConceptCounts(
  result,
  top = 10,
  countBy = NULL,
  type = "gt",
  style = "default"
)
```

## Arguments

- result:

  A `summarised_result` object, typically returned by
  [`summariseConceptIdCounts()`](https://OHDSI.github.io/OmopSketch/reference/summariseConceptIdCounts.md).

- top:

  Integer. The number of top concepts to display. Defaults to `10`.

- countBy:

  Either 'person' or 'record'. If NULL whatever is in the data is used.

- type:

  Character. The output table format. Defaults to `"gt"`. Use
  [`visOmopResults::tableType()`](https://darwin-eu.github.io/visOmopResults/reference/tableType.html)
  to see all supported formats.

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

A formatted table object displaying the top concepts from the summarised
data.

## Examples

``` r
# \donttest{
library(OmopSketch)
library(CDMConnector)
library(duckdb)

requireEunomia()
con <- dbConnect(drv = duckdb(dbdir = eunomiaDir()))
cdm <- cdmFromCon(con = con, cdmSchema = "main", writeSchema = "main")

result <- summariseConceptIdCounts(cdm = cdm, omopTableName = "condition_occurrence")

tableTopConceptCounts(result = result, top = 5)


  
Top 5 concepts in condition_occurrence table

  

Top
```

Cdm name

Synthea

condition_occurrence

1

Standard: Viral sinusitis (40481087)  
Source: Viral sinusitis (40481087)  
17268

2

Standard: Acute viral pharyngitis (4112343)  
Source: Acute viral pharyngitis (4112343)  
10217

3

Standard: Acute bronchitis (260139)  
Source: Acute bronchitis (260139)  
8184

4

Standard: Otitis media (372328)  
Source: Otitis media (372328)  
3605

5

Standard: Osteoarthritis (80180)  
Source: Osteoarthritis (80180)  
2694

\# }
