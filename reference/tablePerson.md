# Visualise the results of `summarisePerson()` into a table

Visualise the results of
[`summarisePerson()`](https://OHDSI.github.io/OmopSketch/reference/summarisePerson.md)
into a table

Visualise the output of
[`summarisePerson()`](https://OHDSI.github.io/OmopSketch/reference/summarisePerson.md)

## Usage

``` r
tablePerson(result, style = "default", type = "gt")

tablePerson(result, style = "default", type = "gt")
```

## Arguments

- result:

  A summarised_result object.

- style:

  A character string or custom R code to define the visual formatting of
  the table.

- type:

  The desired format of the output table. See
  [`visOmopResults::tableType()`](https://darwin-eu.github.io/visOmopResults/reference/tableType.html)
  for allowed options.

## Value

A table visualisation.

A visualisation of the data summarising the person table.

## Examples

``` r
# \donttest{
library(OmopSketch)

cdm <- mockOmopSketch(numberIndividuals = 100)
#> ℹ Reading GiBleed tables.

result <- summarisePerson(cdm = cdm)

tablePerson(result = result)


  
Summary of person table

  

Variable name
```

Variable level

Estimate name

CDM name

mockOmopSketch

Number subjects

\-

N

100

Number subjects not in observation

\-

N (%)

0 (0.00%)

Sex

Female

N (%)

50 (50.00%)

Male

N (%)

50 (50.00%)

None

N (%)

0 (0.00%)

Sex source

Missing

N (%)

100 (100.00%)

Race

Missing

N (%)

100 (100.00%)

Race source

Missing

N (%)

100 (100.00%)

Ethnicity

Missing

N (%)

100 (100.00%)

Ethnicity source

Missing

N (%)

100 (100.00%)

Year of birth

\-

Missing (%)

0 (0.00%)

Median \[Q25 - Q75\]

1,972 \[1,962 - 1,990\]

90% Range \[Q05 to Q95\]

1,952 to 1,997

Range \[min to max\]

1,950 to 2,000

Month of birth

\-

Missing (%)

0 (0.00%)

Median \[Q25 - Q75\]

7 \[3 - 10\]

90% Range \[Q05 to Q95\]

1 to 12

Range \[min to max\]

1 to 12

Day of birth

\-

Missing (%)

0 (0.00%)

Median \[Q25 - Q75\]

18 \[8 - 23\]

90% Range \[Q05 to Q95\]

2 to 31

Range \[min to max\]

1 to 31

Location

\-

Missing (%)

100 (100.00%)

Zero count (%)

0 (0.00%)

Distinct values

1

Provider

\-

Missing (%)

100 (100.00%)

Zero count (%)

0 (0.00%)

Distinct values

1

Care site

\-

Missing (%)

100 (100.00%)

Zero count (%)

0 (0.00%)

Distinct values

1

\# } \# \donttest{
[library](https://rdrr.io/r/base/library.html)([OmopSketch](https://OHDSI.github.io/OmopSketch/))
cdm \<-
[mockOmopSketch](https://OHDSI.github.io/OmopSketch/reference/mockOmopSketch.md)(numberIndividuals
= 100) \#\> ℹ Reading GiBleed tables. result \<-
[summarisePerson](https://OHDSI.github.io/OmopSketch/reference/summarisePerson.md)(cdm
= cdm) tablePerson(result = result)

[TABLE]

Summary of person table

\# }
