# Summarise concept counts in patient-level data. Only concepts recorded during observation period are counted.

**\[deprecated\]**

## Usage

``` r
summariseConceptCounts(
  cdm,
  conceptId,
  countBy = c("record", "person"),
  concept = TRUE,
  interval = "overall",
  sex = FALSE,
  ageGroup = NULL,
  dateRange = NULL
)
```

## Arguments

- cdm:

  A cdm object

- conceptId:

  List of concept IDs to summarise.

- countBy:

  Either "record" for record-level counts or "person" for person-level
  counts

- concept:

  TRUE or FALSE. If TRUE code use will be summarised by concept.

- interval:

  Time interval to stratify by. It can either be "years", "quarters",
  "months" or "overall".

- sex:

  TRUE or FALSE. If TRUE code use will be summarised by sex.

- ageGroup:

  A list of ageGroup vectors of length two. Code use will be thus
  summarised by age groups.

- dateRange:

  A vector of two dates defining the desired study period. Only the
  `start_date` column of the OMOP table is checked to ensure it falls
  within this range. If `dateRange` is `NULL`, no restriction is
  applied.

## Value

A summarised_result object with results overall and, if specified, by
strata.
