# Changelog

## OmopSketch 0.5.1.900

- Characterise all mock datasets by
  [@catalamarti](https://github.com/catalamarti)
  [\#430](https://github.com/OHDSI/OmopSketch/issues/430)
- background in shiny by
  [@cecicampanile](https://github.com/cecicampanile)
  [\#431](https://github.com/OHDSI/OmopSketch/issues/431)
- shiny name shiny -\> OmopSketchShiny by
  [@catalamarti](https://github.com/catalamarti)
  [\#432](https://github.com/OHDSI/OmopSketch/issues/432)
- fix plot of characterisation of population in shiny by
  [@cecicampanile](https://github.com/cecicampanile)
  [\#437](https://github.com/OHDSI/OmopSketch/issues/437)
- new function: summariseTrend by
  [@cecicampanile](https://github.com/cecicampanile)
  [\#433](https://github.com/OHDSI/OmopSketch/issues/433)
- add cdm_source in summariseOmopSnapshot by
  [@catalamarti](https://github.com/catalamarti)
  [\#438](https://github.com/OHDSI/OmopSketch/issues/438)
- new function: summarisePerson by
  [@catalamarti](https://github.com/catalamarti)
  [\#440](https://github.com/OHDSI/OmopSketch/issues/440)
- summariseObservationPeriod 1.0.0 by
  [@cecicampanile](https://github.com/cecicampanile)
  [\#446](https://github.com/OHDSI/OmopSketch/issues/446)
- summariseClinicalRecords 1.0 by
  [@cecicampanile](https://github.com/cecicampanile)
  [\#443](https://github.com/OHDSI/OmopSketch/issues/443)
- missingness in shiny characteristics by
  [@cecicampanile](https://github.com/cecicampanile)
  [\#450](https://github.com/OHDSI/OmopSketch/issues/450)
- sql translations by [@catalamarti](https://github.com/catalamarti)
  [\#449](https://github.com/OHDSI/OmopSketch/issues/449)
- style argument in table and plot functions by
  [@cecicampanile](https://github.com/cecicampanile)
  [\#451](https://github.com/OHDSI/OmopSketch/issues/451)
- Fix: Ensure database compatibility for boolean aggregations in
  summariseNumeric2 by [@merqurio](https://github.com/merqurio)
  [\#457](https://github.com/OHDSI/OmopSketch/issues/457)
- Fix documentation for plotObservationPeriod by
  [@cecicampanile](https://github.com/cecicampanile)
  [\#460](https://github.com/OHDSI/OmopSketch/issues/460)
- tableObservationPeriod when byOrder = FALSE by
  [@cecicampanile](https://github.com/cecicampanile)
  [\#459](https://github.com/OHDSI/OmopSketch/issues/459)
- summariseObservationPeriod minor fix by
  [@cecicampanile](https://github.com/cecicampanile)
  [\#463](https://github.com/OHDSI/OmopSketch/issues/463)
- check for person id not in person table in summariseClinicalRecords by
  [@cecicampanile](https://github.com/cecicampanile)
  [\#461](https://github.com/OHDSI/OmopSketch/issues/461)
- fix some test failures by
  [@cecicampanile](https://github.com/cecicampanile)
  [\#469](https://github.com/OHDSI/OmopSketch/issues/469)
- In observation argument by
  [@cecicampanile](https://github.com/cecicampanile)
  [\#470](https://github.com/OHDSI/OmopSketch/issues/470)
- update shinyCharacteristics
  [\#454](https://github.com/OHDSI/OmopSketch/issues/454)
- sample to work on the person level by
  [@cecicampanile](https://github.com/cecicampanile)
  [\#458](https://github.com/OHDSI/OmopSketch/issues/458)
- tableConceptIdCounts update by
  [@cecicampanile](https://github.com/cecicampanile)
  [\#476](https://github.com/OHDSI/OmopSketch/issues/476)
- captions in tables by
  [@cecicampanile](https://github.com/cecicampanile)
  [\#477](https://github.com/OHDSI/OmopSketch/issues/477)
- summarisePerson in databaseCharacteristics and shinyCharacteristics by
  [@cecicampanile](https://github.com/cecicampanile)
  [\#478](https://github.com/OHDSI/OmopSketch/issues/478)

## OmopSketch 0.5.1

CRAN release: 2025-06-19

- removed overall results when plotting trends by
  [@cecicampanile](https://github.com/cecicampanile)
  [\#418](https://github.com/OHDSI/OmopSketch/issues/418)

## OmopSketch 0.5.0

CRAN release: 2025-06-18

- Table top concept counts by
  [@cecicampanile](https://github.com/cecicampanile)
  [@catalamarti](https://github.com/catalamarti)
  [\#392](https://github.com/OHDSI/OmopSketch/issues/392)

- summariseTableQuality function by
  [@cecicampanile](https://github.com/cecicampanile)
  [\#396](https://github.com/OHDSI/OmopSketch/issues/396)

- specify arguments in examples and deprecate summariseConceptSetCounts
  by [@cecicampanile](https://github.com/cecicampanile)
  [\#397](https://github.com/OHDSI/OmopSketch/issues/397)

- In summariseObservationPeriod age computed after trimming to the study
  period by [@cecicampanile](https://github.com/cecicampanile)
  [\#403](https://github.com/OHDSI/OmopSketch/issues/403)

- summariseInObservation refactoring by
  [@cecicampanile](https://github.com/cecicampanile)
  [\#390](https://github.com/OHDSI/OmopSketch/issues/390)

- fixed warnings in tests by
  [@cecicampanile](https://github.com/cecicampanile)
  [\#399](https://github.com/OHDSI/OmopSketch/issues/399)shinyCharacteristics()
  function by [@cecicampanile](https://github.com/cecicampanile)
  [\#401](https://github.com/OHDSI/OmopSketch/issues/401)

- observation period functions to work with temp tables by
  [@cecicampanile](https://github.com/cecicampanile)
  [\#400](https://github.com/OHDSI/OmopSketch/issues/400)

- eunomia vocabulary in mockOmopSketch.R by
  [@cecicampanile](https://github.com/cecicampanile)
  [\#398](https://github.com/OHDSI/OmopSketch/issues/398)

- tableQuality() function by
  [@cecicampanile](https://github.com/cecicampanile)
  [\#406](https://github.com/OHDSI/OmopSketch/issues/406)

- summariseTableQuality in databaseCharacteristics() by
  [@cecicampanile](https://github.com/cecicampanile)
  [\#407](https://github.com/OHDSI/OmopSketch/issues/407)

- use shinyCharacteristics() to generate the shiny deployed in the
  website by [@cecicampanile](https://github.com/cecicampanile)
  [\#415](https://github.com/OHDSI/OmopSketch/issues/415)

- Improve tableClinicalRecords.R by
  [@cecicampanile](https://github.com/cecicampanile)
  [\#417](https://github.com/OHDSI/OmopSketch/issues/417)

- Documentation by [@cecicampanile](https://github.com/cecicampanile)
  [\#416](https://github.com/OHDSI/OmopSketch/issues/416)

## OmopSketch 0.4.0

CRAN release: 2025-05-15

- “sex” and “age” output in summariseInObservation by
  [@cecicampanile](https://github.com/cecicampanile)
  [\#358](https://github.com/OHDSI/OmopSketch/issues/358)

- source concept in summariseConceptIdCount and tableConceptIdCounts by
  [@cecicampanile](https://github.com/cecicampanile)
  [\#362](https://github.com/OHDSI/OmopSketch/issues/362)t

- ableInObservation and tableRecordCount by
  [@cecicampanile](https://github.com/cecicampanile)
  [\#363](https://github.com/OHDSI/OmopSketch/issues/363)

- databaseCharacteristics() function by
  [@cecicampanile](https://github.com/cecicampanile)
  [\#330](https://github.com/OHDSI/OmopSketch/issues/330)

- Table Record Count and In Observation by
  [@cecicampanile](https://github.com/cecicampanile)
  [\#363](https://github.com/OHDSI/OmopSketch/issues/363)

- Add new examples by [@elinrow](https://github.com/elinrow)
  [\#376](https://github.com/OHDSI/OmopSketch/issues/376)Vignette
  explaining missing data functions by
  [@elinrow](https://github.com/elinrow)
  [\#375](https://github.com/OHDSI/OmopSketch/issues/375)

- Update “Summarise observation period” vignette by
  [@cecicampanile](https://github.com/cecicampanile)
  [\#377](https://github.com/OHDSI/OmopSketch/issues/377)

- Update “Summarise clinical tables records” by
  [@cecicampanile](https://github.com/cecicampanile)
  [\#378](https://github.com/OHDSI/OmopSketch/issues/378)

- Create shiny app with characterisation of synthetic data by
  [@catalamarti](https://github.com/catalamarti)
  [\#381](https://github.com/OHDSI/OmopSketch/issues/381)

- “Summarise concept count” vignette by
  [@cecicampanile](https://github.com/cecicampanile)
  [\#379](https://github.com/OHDSI/OmopSketch/issues/379)

- Update vocabulary version in summariseOmopSnapshot() by
  [@cecicampanile](https://github.com/cecicampanile)
  [\#383](https://github.com/OHDSI/OmopSketch/issues/383)

## OmopSketch 0.3.2

CRAN release: 2025-04-14

- remove dplyr::compute() from sampleOmopTable() by
  [@cecicampanile](https://github.com/cecicampanile)
  [\#344](https://github.com/OHDSI/OmopSketch/issues/344)
- option to summarise by person in summariseInObservation by
  [@cecicampanile](https://github.com/cecicampanile)
  [\#345](https://github.com/OHDSI/OmopSketch/issues/345)
- counts of 0 in summariseMissingData by
  [@cecicampanile](https://github.com/cecicampanile)
  [\#346](https://github.com/OHDSI/OmopSketch/issues/346)
- x ax ordered by observation period ordinal in plotObservationPeriod by
  [@cecicampanile](https://github.com/cecicampanile)
  [\#348](https://github.com/OHDSI/OmopSketch/issues/348)
- byOrdinal boolean argument in summariseObservationPeriod by
  [@cecicampanile](https://github.com/cecicampanile)
  [\#349](https://github.com/OHDSI/OmopSketch/issues/349)
- bug that was showing percentages over 100 fixed in
  summariseClinicalRecords by
  [@cecicampanile](https://github.com/cecicampanile)
  [\#350](https://github.com/OHDSI/OmopSketch/issues/350)

## OmopSketch 0.3.1

CRAN release: 2025-03-16

- remove dplyr::collect() from summariseClinicalRecords() by
  [@cecicampanile](https://github.com/cecicampanile)
  [\#328](https://github.com/OHDSI/OmopSketch/issues/328)
- bug with time_interval fixed in summariseMissingData() by
  [@cecicampanile](https://github.com/cecicampanile)
  [\#335](https://github.com/OHDSI/OmopSketch/issues/335)
- improved tableConceptIdCounts by
  [@cecicampanile](https://github.com/cecicampanile)
  [\#336](https://github.com/OHDSI/OmopSketch/issues/336)
- arranged variable_name and variable_level in tableClinicalRecords by
  [@cecicampanile](https://github.com/cecicampanile)
  [\#337](https://github.com/OHDSI/OmopSketch/issues/337)

## OmopSketch 0.3.0

CRAN release: 2025-03-04

- eunomiaIsAvailable instead of the deprecated eunomia_is_available by
  [@cecicampanile](https://github.com/cecicampanile)
  [\#316](https://github.com/OHDSI/OmopSketch/issues/316)
- Account for int64 in summariseInObservation by
  [@cecicampanile](https://github.com/cecicampanile)
  [\#312](https://github.com/OHDSI/OmopSketch/issues/312)
- Add “datatable” as possible table type by
  [@cecicampanile](https://github.com/cecicampanile)
  [\#314](https://github.com/OHDSI/OmopSketch/issues/314)
- Interval argument in summariseMissingData and
  summariseConceptIdCounts, year argument deprecated by
  [@cecicampanile](https://github.com/cecicampanile)
  [\#317](https://github.com/OHDSI/OmopSketch/issues/317)
- Only records in observation are accounted in summariseConceptIdCounts
  and summariseConceptSetCounts by
  [@cecicampanile](https://github.com/cecicampanile)
  [\#319](https://github.com/OHDSI/OmopSketch/issues/319)
- vignette with full characterisation and shiny by
  [@cecicampanile](https://github.com/cecicampanile)
  [\#325](https://github.com/OHDSI/OmopSketch/issues/325)
- in summariseInObservation and summariseObservationPeriod study range
  is now applied with cohortConstructor::trimToDateRange instead of
  requireInDateRange by
  [@cecicampanile](https://github.com/cecicampanile)
  [\#325](https://github.com/OHDSI/OmopSketch/issues/325)
