# Summarise database characteristics

## Introduction

In this vignette, we explore how the *OmopSketch* function
[`databaseCharacteristics()`](https://OHDSI.github.io/OmopSketch/reference/databaseCharacteristics.md)
and
[`shinyCharacteristics()`](https://OHDSI.github.io/OmopSketch/reference/shinyCharacteristics.md)
can serve as a valuable tool for characterising databases containing
electronic health records mapped to the OMOP Common Data Model.

### Create a mock CDM

We begin by loading the necessary packages and creating a mock CDM using
the
[`mockOmopSketch()`](https://OHDSI.github.io/OmopSketch/reference/mockOmopSketch.md)
function:

``` r
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union
library(OmopSketch)

cdm <- mockOmopSketch()
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
```

## Summarise database characteristics

### Summarise Database Characteristics

The
[`databaseCharacteristics()`](https://OHDSI.github.io/OmopSketch/reference/databaseCharacteristics.md)
function provides a comprehensive overview of the Common Data Model
(CDM). It returns a [summarised
result](https://darwin-eu-dev.github.io/omopgenerics/articles/summarised_result.html)
combining several characterisation components:

- **General database snapshot:**  
  Generated using
  [`summariseOmopSnapshot()`](https://OHDSI.github.io/OmopSketch/reference/summariseOmopSnapshot.md),
  this provides high-level metadata about the CDM, including size of
  person table, time span covered, source type, vocabulary version, etc.

- **Population characterisation:**  
  Describes the demographics of population under observation, built
  using the
  [CohortConstructor](https://ohdsi.github.io/CohortConstructor/) and
  [CohortCharacteristics](https://darwin-eu.github.io/CohortCharacteristics/)
  packages.

- **Person table characterisation:**  
  Produced using
  [`summarisePerson()`](https://OHDSI.github.io/OmopSketch/reference/summarisePerson.md),
  this component summarises the content and missingness of the `person`
  table.

- **Observation period characterisation:**  
  Produced using
  [`summariseObservationPeriod()`](https://OHDSI.github.io/OmopSketch/reference/summariseObservationPeriod.md),
  this component summarises the content and missingness of the
  observation period table.  
  Temporal trends — including changes in the number of records and
  subjects, median age, sex distribution, and total person-days — are
  then derived using
  [`summariseTrend()`](https://OHDSI.github.io/OmopSketch/reference/summariseTrend.md).

- **Clinical tables characterisation:**  
  Produced using
  [`summariseClinicalRecords()`](https://OHDSI.github.io/OmopSketch/reference/summariseClinicalRecords.md),
  this component summarises the content and missingness across all
  clinical tables.  
  Temporal trends in the number of records and subjects, median age, and
  sex distribution are also computed using
  [`summariseTrend()`](https://OHDSI.github.io/OmopSketch/reference/summariseTrend.md).

- **Concept Counts:** Optionally, concept-level summaries can be
  included by computing concept counts with
  [`summariseConceptIdCounts()`](https://OHDSI.github.io/OmopSketch/reference/summariseConceptIdCounts.md).

Together, these outputs provide a holistic view of the CDM’s structure,
data completeness, and temporal behaviour — supporting both data quality
assessment and study feasibility evaluation.

``` r
result <- databaseCharacteristics(cdm)
```

### Selecting tables to characterise

By default, the following OMOP tables are included in the
characterisation: *visit_occurrence*, *visit_detail*,
*condition_occurrence*, *drug_exposure*, *procedure_occurrence*,
*device_exposure*, *measurement*, *observation*, *death*.

You can customise which tables to include in the analysis by specifying
them with the `omopTableName` argument.

``` r
result <- databaseCharacteristics(cdm, omopTableName = c("drug_exposure", "condition_occurrence"))
```

### Stratifying by Sex

To stratify the characterisation results by sex, set the `sex` argument
to `TRUE`:

``` r
result <- databaseCharacteristics(cdm,
  omopTableName = c("drug_exposure", "condition_occurrence"),
  sex = TRUE
)
```

### Stratifying by Age Group

You can choose to characterise the data stratifying by age group by
creating a list defining the age groups you want to use.

``` r
result <- databaseCharacteristics(cdm,
  omopTableName = c("drug_exposure", "condition_occurrence"),
  ageGroup = list(c(0, 50), c(51, 100))
)
```

### Filtering by date range and time interval

Use the `dateRange` argument to limit the analysis to a specific period.
Combine it with the `interval` argument to stratify results by time.
Valid values for interval include “overall” (default), “years”,
“quarters”, and “months”:

``` r
result <- databaseCharacteristics(cdm,
  interval = "years",
  dateRange = as.Date(c("2010-01-01", "2018-12-31"))
)
```

### Sample the CDM

You can use the `sample` argument to limit the characterisation to a
subset of the CDM.  
This can be useful for quickly exploring large datasets or focusing on a
specific cohort already included in the CDM.

The `sample` argument accepts either:

- An **integer**, to randomly sample a specified number of people from
  the person table in the CDM.
- A **string**, corresponding to the name of a cohort within the CDM to
  use for characterisation.

``` r
result <- databaseCharacteristics(cdm,
  sample = 1000L
)

result <- databaseCharacteristics(cdm,
  sample = "my_cohort"
)
```

### Including Concept Counts

To include concept counts in the characterisation, set
`conceptIdCounts = TRUE`:

``` r
result <- databaseCharacteristics(cdm,
  conceptIdCounts = TRUE
)
```

### Other arguments

It is possible to pass arguments from any of the underlying functions to
[`databaseCharacteristics()`](https://OHDSI.github.io/OmopSketch/reference/databaseCharacteristics.md)
in order to customise the output. For example, to stratify trends and
concept counts by records observed in or out of observation, you can
pass the argument `inObservation = TRUE`:

``` r
result <- databaseCharacteristics(cdm,
  conceptIdCounts = TRUE, inObservation = TRUE
)
```

## Visualise the characterisation results

To explore the characterisation results interactively, you can use the
[`shinyCharacteristics()`](https://OHDSI.github.io/OmopSketch/reference/shinyCharacteristics.md)
function. This function generates a Shiny application in the specified
`directory`, allowing you to browse, filter, and visualise the results
through an intuitive user interface.

``` r
shinyCharacteristics(result = result, directory = "path/to/your/shiny")
```

### Customise the Shiny App

You can customise the title, logo, and theme of the Shiny app by setting
the appropriate arguments:

- `title`: The title displayed at the top of the app

- `logo`: Path to a custom logo (must be in SVG format)

- `theme`: A custom Bootstrap theme (e.g., using bslib::bs_theme())

- `background`: A custom background panel for the Shiny app

``` r
shinyCharacteristics(
  result = result, directory = "path/to/my/shiny",
  title = "Characterisation of my data",
  logo = "path/to/my/logo.svg",
  theme = "bslib::bs_theme(bootswatch = 'flatly')", 
  background = "path/to/my/background.md"
)
```

An example of the Shiny application generated by
[`shinyCharacteristics()`](https://OHDSI.github.io/OmopSketch/reference/shinyCharacteristics.md)
can be explored
[here](https://dpa-pde-oxford.shinyapps.io/OmopSketchCharacterisation/),
where the characterisation of several synthetic datasets is available.
