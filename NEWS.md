# OmopSketch 0.3.0

-   eunomiaIsAvailable instead of the deprecated eunomia_is_available by @cecicampanile #316
-   Account for int64 in summariseInObservation by @cecicampanile #312
-   Add "datatable" as possible table type by @cecicampanile #314
-   Interval argument in summariseMissingData and summariseConceptIdCounts, year argument deprecated by @cecicampanile #317
-   Only records in observation are accounted in summariseConceptIdCounts and summariseConceptSetCounts by @cecicampanile #319
-   vignette with full characterisation and shiny by @cecicampanile #325
-   in summariseInObservation and summariseObservationPeriod study range is now applied wih cohortConstructor::trimToDateRange instead of requireInDateRange by @cecicampanile #325
