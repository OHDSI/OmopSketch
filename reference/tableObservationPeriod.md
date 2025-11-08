# Create a visual table from a summariseObservationPeriod() result.

Create a visual table from a summariseObservationPeriod() result.

## Usage

``` r
tableObservationPeriod(result, type = "gt", style = "default")
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

result <- summariseObservationPeriod(observationPeriod = cdm$observation_period)
#> ℹ retrieving cdm object from cdm_table.

tableObservationPeriod(result = result)


  
Summary of observation_period table

  

Observation period ordinal
```

Variable name

Variable level

Estimate name

CDM name

mockOmopSketch

all

Number records

\-

N

100

Number subjects

\-

N

100

Subjects not in person table

\-

N (%)

0 (0.00%)

Records per person

\-

Mean (SD)

1.00 (0.00)

Median \[Q25 - Q75\]

1 \[1 - 1\]

Range \[min to max\]

\[1 to 1\]

Duration in days

\-

Mean (SD)

4,103.79 (4,051.51)

Median \[Q25 - Q75\]

3,169 \[979 - 5,208\]

Range \[min to max\]

\[3 to 19,583\]

Type concept id

Unknown type concept: 0

N (%)

100 (100.00%)

Start date before birth date

\-

N (%)

0 (0.00%)

End date before start date

\-

N (%)

0 (0.00%)

Column name

Observation period end date

N missing data (%)

0 (0.00%)

Observation period id

N missing data (%)

0 (0.00%)

N zeros (%)

0 (0.00%)

Observation period start date

N missing data (%)

0 (0.00%)

Period type concept id

N missing data (%)

0 (0.00%)

N zeros (%)

100 (100.00%)

Person id

N missing data (%)

0 (0.00%)

N zeros (%)

0 (0.00%)

1st

Number subjects

\-

N

100

Duration in days

\-

Mean (SD)

4,103.79 (4,051.51)

Median \[Q25 - Q75\]

3,169 \[979 - 5,208\]

Range \[min to max\]

\[3 to 19,583\]

CDMConnector::[cdmDisconnect](https://darwin-eu.github.io/omopgenerics/reference/cdmDisconnect.html)(cdm
= cdm) \# }
