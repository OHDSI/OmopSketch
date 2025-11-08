# Package index

### Snapshots

Create snapshots of OMOP databases

- [`summariseOmopSnapshot()`](https://OHDSI.github.io/OmopSketch/reference/summariseOmopSnapshot.md)
  : Summarise a cdm_reference object creating a snapshot with the
  metadata of the cdm_reference object.
- [`tableOmopSnapshot()`](https://OHDSI.github.io/OmopSketch/reference/tableOmopSnapshot.md)
  : Create a visual table from a summarise_omop_snapshot result.

### Clinical Tables

Summarise and plot tables in the OMOP Common Data Model

- [`summariseClinicalRecords()`](https://OHDSI.github.io/OmopSketch/reference/summariseClinicalRecords.md)
  : Summarise an omop table from a cdm object. You will obtain
  information related to the number of records, number of subjects,
  whether the records are in observation, number of present domains,
  number of present concepts, missing data and inconsistencies in start
  date and end date
- [`tableClinicalRecords()`](https://OHDSI.github.io/OmopSketch/reference/tableClinicalRecords.md)
  : Create a visual table from a summariseClinicalRecord() output.
- [`summariseMissingData()`](https://OHDSI.github.io/OmopSketch/reference/summariseMissingData.md)
  : Summarise missing data in omop tables
- [`tableMissingData()`](https://OHDSI.github.io/OmopSketch/reference/tableMissingData.md)
  : Create a visual table from a summariseMissingData() result.

### Observation Periods

Summarise and plot the observation period table in the OMOP Common Data
Model

- [`summarisePerson()`](https://OHDSI.github.io/OmopSketch/reference/summarisePerson.md)
  : Summarise the person table

- [`tablePerson()`](https://OHDSI.github.io/OmopSketch/reference/tablePerson.md)
  :

  Visualise the results of
  [`summarisePerson()`](https://OHDSI.github.io/OmopSketch/reference/summarisePerson.md)
  into a table

- [`summariseObservationPeriod()`](https://OHDSI.github.io/OmopSketch/reference/summariseObservationPeriod.md)
  : Summarise the observation period table getting some overall
  statistics in a summarised_result object.

- [`plotObservationPeriod()`](https://OHDSI.github.io/OmopSketch/reference/plotObservationPeriod.md)
  : Create a plot from the output of summariseObservationPeriod().

- [`tableObservationPeriod()`](https://OHDSI.github.io/OmopSketch/reference/tableObservationPeriod.md)
  : Create a visual table from a summariseObservationPeriod() result.

### Counts

Summarise concept code use in the OMOP Common Data Model

- [`summariseConceptIdCounts()`](https://OHDSI.github.io/OmopSketch/reference/summariseConceptIdCounts.md)
  : Summarise concept use in patient-level data. Only concepts recorded
  during observation period are counted.

- [`tableConceptIdCounts()`](https://OHDSI.github.io/OmopSketch/reference/tableConceptIdCounts.md)
  : Create a visual table from a summariseConceptIdCounts() result.

- [`tableTopConceptCounts()`](https://OHDSI.github.io/OmopSketch/reference/tableTopConceptCounts.md)
  :

  Create a visual table of the most common concepts from
  [`summariseConceptIdCounts()`](https://OHDSI.github.io/OmopSketch/reference/summariseConceptIdCounts.md)
  output. This function takes a `summarised_result` object and generates
  a formatted table highlighting the most frequent concepts.

### Temporal Trends

Summarise and plot temporal trends in tables in the OMOP Common Data
Model

- [`summariseTrend()`](https://OHDSI.github.io/OmopSketch/reference/summariseTrend.md)
  : Summarise temporal trends in OMOP tables
- [`tableTrend()`](https://OHDSI.github.io/OmopSketch/reference/tableTrend.md)
  : Create a visual table from a summariseTrend() result.
- [`plotTrend()`](https://OHDSI.github.io/OmopSketch/reference/plotTrend.md)
  : Create a ggplot2 plot from the output of summariseTrend().

### Mock Database

Create a mock database to test the OmopSketch package

- [`mockOmopSketch()`](https://OHDSI.github.io/OmopSketch/reference/mockOmopSketch.md)
  : Creates a mock database to test OmopSketch package.

### Characterisation

Characterise the database

- [`databaseCharacteristics()`](https://OHDSI.github.io/OmopSketch/reference/databaseCharacteristics.md)
  : Summarise Database Characteristics for OMOP CDM

- [`shinyCharacteristics()`](https://OHDSI.github.io/OmopSketch/reference/shinyCharacteristics.md)
  :

  Generate an interactive Shiny application that visualises the results
  obtained from the
  [`databaseCharacteristics()`](https://OHDSI.github.io/OmopSketch/reference/databaseCharacteristics.md)
  function.

### Helper functions

Functions to help populate and summariseClinicalRecords()

- [`clinicalTables()`](https://OHDSI.github.io/OmopSketch/reference/clinicalTables.md)
  : Tables in the cdm_reference that contain clinical information

### Deprecated functions

These functions have been deprecated

- [`summariseConceptCounts()`](https://OHDSI.github.io/OmopSketch/reference/summariseConceptCounts.md)
  **\[deprecated\]** : Summarise concept counts in patient-level data.
  Only concepts recorded during observation period are counted.

- [`summariseConceptSetCounts()`](https://OHDSI.github.io/OmopSketch/reference/summariseConceptSetCounts.md)
  : Summarise concept counts in patient-level data. Only concepts
  recorded during observation period are counted.

- [`plotConceptSetCounts()`](https://OHDSI.github.io/OmopSketch/reference/plotConceptSetCounts.md)
  **\[deprecated\]** :

  Plot the concept counts of a summariseConceptSetCounts output.
  **\[deprecated\]**

- [`summariseRecordCount()`](https://OHDSI.github.io/OmopSketch/reference/summariseRecordCount.md)
  **\[deprecated\]** : Summarise record counts of an omop_table using a
  specific time interval. Only records that fall within the observation
  period are considered.

- [`plotRecordCount()`](https://OHDSI.github.io/OmopSketch/reference/plotRecordCount.md)
  **\[deprecated\]** :

  Create a ggplot of the records' count trend. **\[deprecated\]**

- [`tableRecordCount()`](https://OHDSI.github.io/OmopSketch/reference/tableRecordCount.md)
  **\[deprecated\]** :

  Create a visual table from a summariseRecordCount() result.
  **\[deprecated\]**

- [`summariseInObservation()`](https://OHDSI.github.io/OmopSketch/reference/summariseInObservation.md)
  **\[deprecated\]** :

  Summarise the number of people in observation during a specific
  interval of time. **\[deprecated\]**

- [`plotInObservation()`](https://OHDSI.github.io/OmopSketch/reference/plotInObservation.md)
  **\[deprecated\]** :

  Create a ggplot2 plot from the output of summariseInObservation().
  **\[deprecated\]**

- [`tableInObservation()`](https://OHDSI.github.io/OmopSketch/reference/tableInObservation.md)
  **\[deprecated\]** :

  Create a visual table from a summariseInObservation() result.
  **\[deprecated\]**
