# OmopSketch 1.0.1

- Remove deprecated internal functions and add tests by @catalamarti in #525
- Update deprecated function tests for specific DB by @catalamarti in #532
- summarieClinicalRecords to work with all clinical tables by @cecicampanile in #533
- update tables and test tables by @cecicampanile in #535
- Improve tableConceptIdCounts.R by @cecicampanile in #538
- dont test database characteristics with age group when cdm is local by @cecicampanile in #540
- plot functions updated by @cecicampanile in #534
- fix integer overflow in sql server by @cecicampanile in #542
- attempt fix for bigint concept count by @edward-burn in #543
- without grouping by @edward-burn in #548
- Update tablePerson.R by @cecicampanile in #550
- separate standard, non standard and 0 in summariseClinicalRecords by @cecicampanile in #547
- Print big int by @cecicampanile in #553
- hide, header and group arguments in tables by @cecicampanile in #551

# OmopSketch 1.0.0

- Characterise all mock datasets by @catalamarti #430
- background in shiny by @cecicampanile #431
- shiny name shiny -> OmopSketchShiny by @catalamarti #432
- fix plot of characterisation of population in shiny by @cecicampanile #437
- new function: summariseTrend by @cecicampanile #433
- add cdm_source in summariseOmopSnapshot by @catalamarti #438
- new function: summarisePerson by @catalamarti #440
- summariseObservationPeriod 1.0.0 by @cecicampanile #446
- summariseClinicalRecords 1.0 by @cecicampanile #443
- missingness in shiny characteristics by @cecicampanile #450
- sql translations by @catalamarti #449
- style argument in table and plot functions by @cecicampanile #451
- Fix: Ensure database compatibility for boolean aggregations in summariseNumeric2 by @merqurio #457
- Fix documentation for plotObservationPeriod by @cecicampanile #460
- tableObservationPeriod when byOrder = FALSE by @cecicampanile #459
- summariseObservationPeriod minor fix by @cecicampanile #463
- check for person id not in person table in summariseClinicalRecords by @cecicampanile #461
- fix some test failures by @cecicampanile #469
- In observation argument by @cecicampanile #470
- update shinyCharacteristics #454
- sample to work on the person level by @cecicampanile #458
- tableConceptIdCounts update by @cecicampanile #476
- captions in tables by @cecicampanile #477
- summarisePerson in databaseCharacteristics and shinyCharacteristics by @cecicampanile #478
- Reduce imports by @catalamarti #503
- Remove :: from vignettes, readme and examples by @catalamarti #502
- Use default of style and type = NULL by @catalamarti #498
- Tidy vignettes by @catalamarti i#508
- Tidy documentation by @catalamarti #510
- refine readme by @catalamarti #505
- scarlet brand in shiny by @cecicampanile #513
- Test multiple dbms by @catalamarti #514
- add logo to shiny by @catalamarti #516
- reduce size of tables before collecting in summariseTrend by @cecicampanile #518
  
# OmopSketch 0.5.1

-   removed overall results when plotting trends by @cecicampanile #418

# OmopSketch 0.5.0

-   Table top concept counts by \@cecicampanile \@catalamarti #392

-   summariseTableQuality function by \@cecicampanile #396

-   specify arguments in examples and deprecate summariseConceptSetCounts by \@cecicampanile #397

-   In summariseObservationPeriod age computed after trimming to the study period by \@cecicampanile #403

-   summariseInObservation refactoring by \@cecicampanile #390

-   fixed warnings in tests by \@cecicampanile #399shinyCharacteristics() function by \@cecicampanile #401

-   observation period functions to work with temp tables by \@cecicampanile #400

-   eunomia vocabulary in mockOmopSketch.R by \@cecicampanile #398

-   tableQuality() function by \@cecicampanile #406

-   summariseTableQuality in databaseCharacteristics() by \@cecicampanile #407

-   use shinyCharacteristics() to generate the shiny deployed in the website by \@cecicampanile #415

-   Improve tableClinicalRecords.R by \@cecicampanile #417

-   Documentation by \@cecicampanile #416

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
-   in summariseInObservation and summariseObservationPeriod study range is now applied with cohortConstructor::trimToDateRange instead of requireInDateRange by @cecicampanile #325
