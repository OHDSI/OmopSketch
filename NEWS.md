# OmopSketch 0.3.2

- remove dplyr::compute() from sampleOmopTable() by @cecicampanile #344
- option to summarise by person in summariseInObservation by @cecicampanile #345
- counts of 0 in summariseMissingData by @cecicampanile #346
- x ax ordered by observation period ordinal in plotObservationPeriod by @cecicampanile #348
- byOrdinal boolean argument in summariseObservationPeriod by @cecicampanile #349
- bug that was showing percentages over 100 fixed in summariseClinicalRecords by @cecicampanile #350
  
# OmopSketch 0.3.1

-   remove dplyr::collect() from summariseClinicalRecords() by @cecicampanile #328
-   bug with time_interval fixed in summariseMissingData() by @cecicampanile #335
-   improved tableConceptIdCounts by @cecicampanile #336
-   arranged variable_name and variable_level in tableClinicalRecords by @cecicampanile #337

# OmopSketch 0.3.0

-   eunomiaIsAvailable instead of the deprecated eunomia_is_available by @cecicampanile #316
-   Account for int64 in summariseInObservation by @cecicampanile #312
-   Add "datatable" as possible table type by @cecicampanile #314
-   Interval argument in summariseMissingData and summariseConceptIdCounts, year argument deprecated by @cecicampanile #317
-   Only records in observation are accounted in summariseConceptIdCounts and summariseConceptSetCounts by @cecicampanile #319
-   vignette with full characterisation and shiny by @cecicampanile #325
-   in summariseInObservation and summariseObservationPeriod study range is now applied wih cohortConstructor::trimToDateRange instead of requireInDateRange by @cecicampanile #325
