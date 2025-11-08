# Create a visual table from a summariseClinicalRecord() output.

Create a visual table from a summariseClinicalRecord() output.

## Usage

``` r
tableClinicalRecords(result, type = "gt", style = "default")
```

## Arguments

- result:

  Output from summariseClinicalRecords().

- type:

  Type of formatting output table. See
  [`visOmopResults::tableType()`](https://darwin-eu.github.io/visOmopResults/reference/tableType.html)
  for allowed options.

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

cdm <- mockOmopSketch()
#> ℹ Reading GiBleed tables.

summarisedResult <- summariseClinicalRecords(
  cdm = cdm,
  omopTableName = c("condition_occurrence", "drug_exposure"),
  recordsPerPerson = c("mean", "sd"),
  inObservation = TRUE,
  standardConcept = TRUE,
  sourceVocabulary = TRUE,
  domainId = TRUE,
  typeConcept = TRUE
)
#> Warning: The `inObservation` argument of `summariseClinicalRecords()` is deprecated as
#> of OmopSketch 1.0.0.
#> ℹ Please use the `quality` argument instead.
#> Warning: The `standardConcept` argument of `summariseClinicalRecords()` is deprecated as
#> of OmopSketch 1.0.0.
#> ℹ Please use the `conceptSummary` argument instead.
#> Warning: The `sourceVocabulary` argument of `summariseClinicalRecords()` is deprecated
#> as of OmopSketch 1.0.0.
#> ℹ Please use the `conceptSummary` argument instead.
#> Warning: The `domainId` argument of `summariseClinicalRecords()` is deprecated as of
#> OmopSketch 1.0.0.
#> ℹ Please use the `conceptSummary` argument instead.
#> Warning: The `typeConcept` argument of `summariseClinicalRecords()` is deprecated as of
#> OmopSketch 1.0.0.
#> ℹ Please use the `conceptSummary` argument instead.
#> ℹ Adding variables of interest to condition_occurrence.
#> ℹ Summarising records per person in condition_occurrence.
#> ℹ Summarising subjects not in person table in condition_occurrence.
#> ℹ Summarising records in observation in condition_occurrence.
#> ℹ Summarising records with start before birth date in condition_occurrence.
#> ℹ Summarising records with end date before start date in condition_occurrence.
#> ℹ Summarising domains in condition_occurrence.
#> ℹ Summarising standard concepts in condition_occurrence.
#> ℹ Summarising source vocabularies in condition_occurrence.
#> ℹ Summarising concept types in condition_occurrence.
#> ℹ Summarising missing data in condition_occurrence.
#> ℹ Adding variables of interest to drug_exposure.
#> ℹ Summarising records per person in drug_exposure.
#> ℹ Summarising subjects not in person table in drug_exposure.
#> ℹ Summarising records in observation in drug_exposure.
#> ℹ Summarising records with start before birth date in drug_exposure.
#> ℹ Summarising records with end date before start date in drug_exposure.
#> ℹ Summarising domains in drug_exposure.
#> ℹ Summarising standard concepts in drug_exposure.
#> ℹ Summarising source vocabularies in drug_exposure.
#> ℹ Summarising concept types in drug_exposure.
#> ℹ Summarising concept class in drug_exposure.
#> ℹ Summarising missing data in drug_exposure.

summarisedResult |>
  suppress(minCellCount = 5) |>
  tableClinicalRecords()


  
Summary of condition_occurrence, drug_exposure tables

  

Variable name
```

Variable level

Estimate name

Database name

mockOmopSketch

condition_occurrence

Number records

\-

N

8,400

Number subjects

\-

N (%)

100 (100.00%)

Subjects not in person table

\-

N (%)

0 (0.00%)

Records per person

\-

Mean (SD)

84.00 (9.85)

In observation

Yes

N (%)

8,400 (100.00%)

Domain

Condition

N (%)

8,400 (100.00%)

Source vocabulary

No matching concept

N (%)

8,400 (100.00%)

Standard concept

S

N (%)

8,400 (100.00%)

Type concept id

Unknown type concept: 0

N (%)

8,400 (100.00%)

Start date before birth date

\-

N (%)

0 (0.00%)

End date before start date

\-

N (%)

0 (0.00%)

Column name

Condition concept id

N missing data (%)

0 (0.00%)

N zeros (%)

0 (0.00%)

Condition end date

N missing data (%)

0 (0.00%)

Condition end datetime

N missing data (%)

8,400 (100.00%)

Condition occurrence id

N missing data (%)

0 (0.00%)

N zeros (%)

0 (0.00%)

Condition source concept id

N missing data (%)

8,400 (100.00%)

N zeros (%)

0 (0.00%)

Condition source value

N missing data (%)

8,400 (100.00%)

Condition start date

N missing data (%)

0 (0.00%)

Condition start datetime

N missing data (%)

8,400 (100.00%)

Condition status concept id

N missing data (%)

8,400 (100.00%)

N zeros (%)

0 (0.00%)

Condition status source value

N missing data (%)

8,400 (100.00%)

Condition type concept id

N missing data (%)

0 (0.00%)

N zeros (%)

8,400 (100.00%)

Person id

N missing data (%)

0 (0.00%)

N zeros (%)

0 (0.00%)

Provider id

N missing data (%)

8,400 (100.00%)

N zeros (%)

0 (0.00%)

Stop reason

N missing data (%)

8,400 (100.00%)

Visit detail id

N missing data (%)

8,400 (100.00%)

N zeros (%)

0 (0.00%)

Visit occurrence id

N missing data (%)

0 (0.00%)

N zeros (%)

0 (0.00%)

drug_exposure

Number records

\-

N

21,600

Number subjects

\-

N (%)

100 (100.00%)

Subjects not in person table

\-

N (%)

0 (0.00%)

Records per person

\-

Mean (SD)

216.00 (15.45)

In observation

Yes

N (%)

21,600 (100.00%)

Domain

Drug

N (%)

21,600 (100.00%)

Source vocabulary

No matching concept

N (%)

21,600 (100.00%)

Standard concept

S

N (%)

21,600 (100.00%)

Type concept id

Unknown type concept: 0

N (%)

21,600 (100.00%)

Concept class

Branded drug

N (%)

700 (3.24%)

Branded drug comp

N (%)

400 (1.85%)

Branded pack

N (%)

1,100 (5.09%)

Clinical drug

N (%)

7,100 (32.87%)

Clinical drug comp

N (%)

100 (0.46%)

Cvx

N (%)

1,600 (7.41%)

Ingredient

N (%)

9,100 (42.13%)

Quant branded drug

N (%)

100 (0.46%)

Quant clinical drug

N (%)

1,400 (6.48%)

Start date before birth date

\-

N (%)

0 (0.00%)

End date before start date

\-

N (%)

0 (0.00%)

Column name

Days supply

N missing data (%)

21,600 (100.00%)

Dose unit source value

N missing data (%)

21,600 (100.00%)

Drug concept id

N missing data (%)

0 (0.00%)

N zeros (%)

0 (0.00%)

Drug exposure end date

N missing data (%)

0 (0.00%)

Drug exposure end datetime

N missing data (%)

21,600 (100.00%)

Drug exposure id

N missing data (%)

0 (0.00%)

N zeros (%)

0 (0.00%)

Drug exposure start date

N missing data (%)

0 (0.00%)

Drug exposure start datetime

N missing data (%)

21,600 (100.00%)

Drug source concept id

N missing data (%)

21,600 (100.00%)

N zeros (%)

0 (0.00%)

Drug source value

N missing data (%)

21,600 (100.00%)

Drug type concept id

N missing data (%)

0 (0.00%)

N zeros (%)

21,600 (100.00%)

Lot number

N missing data (%)

21,600 (100.00%)

Person id

N missing data (%)

0 (0.00%)

N zeros (%)

0 (0.00%)

Provider id

N missing data (%)

21,600 (100.00%)

N zeros (%)

0 (0.00%)

Quantity

N missing data (%)

21,600 (100.00%)

Refills

N missing data (%)

21,600 (100.00%)

Route concept id

N missing data (%)

21,600 (100.00%)

N zeros (%)

0 (0.00%)

Route source value

N missing data (%)

21,600 (100.00%)

Sig

N missing data (%)

21,600 (100.00%)

Stop reason

N missing data (%)

21,600 (100.00%)

Verbatim end date

N missing data (%)

21,600 (100.00%)

Visit detail id

N missing data (%)

21,600 (100.00%)

N zeros (%)

0 (0.00%)

Visit occurrence id

N missing data (%)

0 (0.00%)

N zeros (%)

0 (0.00%)

PatientProfiles::[mockDisconnect](https://darwin-eu.github.io/PatientProfiles/reference/mockDisconnect.html)(cdm)
\# }
