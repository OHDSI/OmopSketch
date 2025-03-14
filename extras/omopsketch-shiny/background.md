# Characterisation

This Shiny app presents the results of a characterisation don ewith the R package `OmopSketch` conducted on the Eunomia mock database.



The analyses include:

-   A `snapshot` of the CDM containing general info like person count and vocabulary version.


-   Characterisation of the `clinical tables`, stratified by age groups 0-59 and 60+, sex and year:

    -   `Missing data`: counts of missing data points.

    -   `Record count`: counts of records in observation within the OMOP tables.

    -   `Clinical records`: distribution of records per person in the OMOP tables.
    
    -   `Concept_id counts`: numbers of records and subjects for each concept.

-   Characterisation of the `observation period` table, stratified by age, sex:

    -   `In observation`: counts of person-days and records in observation for each year in the study period.

    -   `Observation periods`: distribution of observation durations (in days) and days to the next observation for each ordinal observation period.

The focus of the analysis is the study period 01/01/2012 - present.

<div style="display: flex; justify-content: center; align-items: center; height: 50vh;">
  <img src="hds_logo.svg" style="max-width: 200px; height: auto;">
</div>

