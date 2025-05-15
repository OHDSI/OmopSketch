# OmopSketch 0.4.0

-   "sex" and "age" output in summariseInObservation by @cecicampanile #358
-   source concept in summariseConceptIdCount and tableConceptIdCounts by @cecicampanile #362t
-   ableInObservation and tableRecordCount by @cecicampanile #363
-   databaseCharacteristics() function by @cecicampanile #330
-   Table Record Count and In Observation by @cecicampanile #363
-   Add new examples by @elinrow #376Vignette explaining missing data functions by @elinrow #375
-   Update "Summarise observation period" vignette by @cecicampanile #377
-   Update "Summarise clinical tables records" by @cecicampanile #378
-   Create shiny app with characterisation of synthetic data by @catalamarti #381
-   "Summarise concept count" vignette by @cecicampanile #379
-   Update vocabulary version in summariseOmopSnapshot() by @cecicampanile #383

# OmopSketch 0.3.2

-   remove dplyr::compute() from sampleOmopTable() by @cecicampanile #344
-   option to summarise by person in summariseInObservation by @cecicampanile #345
-   counts of 0 in summariseMissingData by @cecicampanile #346
-   x ax ordered by observation period ordinal in plotObservationPeriod by @cecicampanile #348
-   byOrdinal boolean argument in summariseObservationPeriod by @cecicampanile #349
-   bug that was showing percentages over 100 fixed in summariseClinicalRecords by @cecicampanile #350

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
