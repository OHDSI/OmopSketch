
<!-- README.md is generated from README.Rmd. Please edit that file -->

# OmopSketch <a href="https://OHDSI.github.io/OmopSketch/"><img src="man/figures/logo.png" alt="OmopSketch website" align="right" height="138"/></a>

<!-- badges: start -->

[![Lifecycle:
stable](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)
[![R-CMD-check](https://github.com/OHDSI/OmopSketch/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/OHDSI/OmopSketch/actions/workflows/R-CMD-check.yaml)
[![CRAN
status](https://www.r-pkg.org/badges/version/OmopSketch)](https://CRAN.R-project.org/package=OmopSketch)
[![Codecov test
coverage](https://codecov.io/gh/OHDSI/OmopSketch/branch/main/graph/badge.svg)](https://app.codecov.io/gh/OHDSI/OmopSketch?branch=main)

<!-- badges: end -->

The goal of OmopSketch is to characterise and visualise an OMOP CDM
instance to asses if it meets the necessary criteria to answer a
specific clinical question and conduct a certain study.

## Installation

You can install the development version of OmopSketch from
[GitHub](https://github.com/) with:

``` r
# install.packages("remotes")
remotes::install_github("OHDSI/OmopSketch")
```

## Example

Let’s start by creating a cdm object using the Eunomia GiBleed mock
dataset:

``` r
library(duckdb)
#> Loading required package: DBI
library(dplyr, warn.conflicts = FALSE)
library(OmopSketch)

cdm <- omock::mockCdmFromDataset(datasetName = "GiBleed", source = "duckdb")
#> ℹ Reading GiBleed tables.
#> ℹ Adding drug_strength table.
#> ℹ Creating local <cdm_reference> object.
#> ℹ Inserting <cdm_reference> into duckdb.
cdm
#> 
#> ── # OMOP CDM reference (duckdb) of GiBleed ────────────────────────────────────
#> • omop tables: care_site, cdm_source, concept, concept_ancestor, concept_class,
#> concept_relationship, concept_synonym, condition_era, condition_occurrence,
#> cost, death, device_exposure, domain, dose_era, drug_era, drug_exposure,
#> drug_strength, fact_relationship, location, measurement, metadata, note,
#> note_nlp, observation, observation_period, payer_plan_period, person,
#> procedure_occurrence, provider, relationship, source_to_concept_map, specimen,
#> visit_detail, visit_occurrence, vocabulary
#> • cohort tables: -
#> • achilles tables: -
#> • other tables: -
```

### Snapshot

We first create a snapshot of our database. This will allow us to track
when the analysis has been conducted and capture details about the CDM
version or the data release.

``` r
summariseOmopSnapshot(cdm) |>
  tableOmopSnapshot(type = "flextable")
```

<img src="man/figures/README-unnamed-chunk-3-1.png" width="100%" />

### Characterise the clinical tables

Once we have collected the snapshot information, we can start
characterising the clinical tables of the CDM. By using
`summariseClinicalRecords()` and `tableClinicalRecords()`, we can easily
visualise the main characteristics of specific clinical tables.

``` r
summariseClinicalRecords(cdm, c("condition_occurrence", "drug_exposure")) |>
  tableClinicalRecords(type = "flextable")
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
#> ℹ Summarising missing data in drug_exposure.
```

<img src="man/figures/README-unnamed-chunk-4-1.png" width="100%" />

### Characterise the observation period

After visualising the main characteristics of our clinical tables, we
can explore the observation period details. You can visualise and
explore the characteristics of the observation period per each
individual in the database using `summariseObservationPeriod()`.

``` r
summariseObservationPeriod(cdm) |>
  tableObservationPeriod(type = "flextable")
#> Warning: ! There are 2649 individuals not included in the person table.
```

<img src="man/figures/README-unnamed-chunk-5-1.png" width="100%" />

Or if visualisation is preferred, you can easily build a histogram to
explore how many participants have more than one observation period.

``` r
summariseObservationPeriod(cdm) |>
  plotObservationPeriod(colour = "observation_period_ordinal")
#> Warning: ! There are 2649 individuals not included in the person table.
```

<img src="man/figures/README-unnamed-chunk-6-1.png" width="100%" />

### Explore trends over time

We can also explore trends over time using `summariseTrend()`.

``` r
summariseTrend(cdm, event = c("condition_occurrence", "drug_exposure"), output = "record",  interval = "years") |>
  plotTrend(facet = "omop_table", colour = "cdm_name")
```

<img src="man/figures/README-unnamed-chunk-7-1.png" width="100%" />

### Characterise the concepts

OmopSketch also provides functions to explore the concepts in the
dataset.

``` r
summariseConceptIdCounts(cdm, omopTableName = "drug_exposure") |>
  tableTopConceptCounts()
```

<div id="njgqiwnfel" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
<style>#njgqiwnfel table {
  font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}
&#10;#njgqiwnfel thead, #njgqiwnfel tbody, #njgqiwnfel tfoot, #njgqiwnfel tr, #njgqiwnfel td, #njgqiwnfel th {
  border-style: none;
}
&#10;#njgqiwnfel p {
  margin: 0;
  padding: 0;
}
&#10;#njgqiwnfel .gt_table {
  display: table;
  border-collapse: collapse;
  line-height: normal;
  margin-left: auto;
  margin-right: auto;
  color: #333333;
  font-size: 16px;
  font-weight: normal;
  font-style: normal;
  background-color: #FFFFFF;
  width: auto;
  border-top-style: solid;
  border-top-width: 3px;
  border-top-color: #D9D9D9;
  border-right-style: solid;
  border-right-width: 3px;
  border-right-color: #D9D9D9;
  border-bottom-style: solid;
  border-bottom-width: 3px;
  border-bottom-color: #D9D9D9;
  border-left-style: solid;
  border-left-width: 3px;
  border-left-color: #D9D9D9;
}
&#10;#njgqiwnfel .gt_caption {
  padding-top: 4px;
  padding-bottom: 4px;
}
&#10;#njgqiwnfel .gt_title {
  color: #333333;
  font-size: 125%;
  font-weight: initial;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-color: #FFFFFF;
  border-bottom-width: 0;
}
&#10;#njgqiwnfel .gt_subtitle {
  color: #333333;
  font-size: 85%;
  font-weight: initial;
  padding-top: 3px;
  padding-bottom: 5px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-color: #FFFFFF;
  border-top-width: 0;
}
&#10;#njgqiwnfel .gt_heading {
  background-color: #FFFFFF;
  text-align: center;
  border-bottom-color: #FFFFFF;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}
&#10;#njgqiwnfel .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#njgqiwnfel .gt_col_headings {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}
&#10;#njgqiwnfel .gt_col_heading {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  overflow-x: hidden;
}
&#10;#njgqiwnfel .gt_column_spanner_outer {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  padding-top: 0;
  padding-bottom: 0;
  padding-left: 4px;
  padding-right: 4px;
}
&#10;#njgqiwnfel .gt_column_spanner_outer:first-child {
  padding-left: 0;
}
&#10;#njgqiwnfel .gt_column_spanner_outer:last-child {
  padding-right: 0;
}
&#10;#njgqiwnfel .gt_column_spanner {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 5px;
  overflow-x: hidden;
  display: inline-block;
  width: 100%;
}
&#10;#njgqiwnfel .gt_spanner_row {
  border-bottom-style: hidden;
}
&#10;#njgqiwnfel .gt_group_heading {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  text-align: left;
}
&#10;#njgqiwnfel .gt_empty_group_heading {
  padding: 0.5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: middle;
}
&#10;#njgqiwnfel .gt_from_md > :first-child {
  margin-top: 0;
}
&#10;#njgqiwnfel .gt_from_md > :last-child {
  margin-bottom: 0;
}
&#10;#njgqiwnfel .gt_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  margin: 10px;
  border-top-style: solid;
  border-top-width: 1px;
  border-top-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  overflow-x: hidden;
}
&#10;#njgqiwnfel .gt_stub {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#njgqiwnfel .gt_stub_row_group {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
  vertical-align: top;
}
&#10;#njgqiwnfel .gt_row_group_first td {
  border-top-width: 2px;
}
&#10;#njgqiwnfel .gt_row_group_first th {
  border-top-width: 2px;
}
&#10;#njgqiwnfel .gt_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#njgqiwnfel .gt_first_summary_row {
  border-top-style: solid;
  border-top-color: #D3D3D3;
}
&#10;#njgqiwnfel .gt_first_summary_row.thick {
  border-top-width: 2px;
}
&#10;#njgqiwnfel .gt_last_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#njgqiwnfel .gt_grand_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#njgqiwnfel .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}
&#10;#njgqiwnfel .gt_last_grand_summary_row_top {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: double;
  border-bottom-width: 6px;
  border-bottom-color: #D3D3D3;
}
&#10;#njgqiwnfel .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}
&#10;#njgqiwnfel .gt_table_body {
  border-top-style: solid;
  border-top-width: 3px;
  border-top-color: #D9D9D9;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#njgqiwnfel .gt_footnotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}
&#10;#njgqiwnfel .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#njgqiwnfel .gt_sourcenotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}
&#10;#njgqiwnfel .gt_sourcenote {
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#njgqiwnfel .gt_left {
  text-align: left;
}
&#10;#njgqiwnfel .gt_center {
  text-align: center;
}
&#10;#njgqiwnfel .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}
&#10;#njgqiwnfel .gt_font_normal {
  font-weight: normal;
}
&#10;#njgqiwnfel .gt_font_bold {
  font-weight: bold;
}
&#10;#njgqiwnfel .gt_font_italic {
  font-style: italic;
}
&#10;#njgqiwnfel .gt_super {
  font-size: 65%;
}
&#10;#njgqiwnfel .gt_footnote_marks {
  font-size: 75%;
  vertical-align: 0.4em;
  position: initial;
}
&#10;#njgqiwnfel .gt_asterisk {
  font-size: 100%;
  vertical-align: 0;
}
&#10;#njgqiwnfel .gt_indent_1 {
  text-indent: 5px;
}
&#10;#njgqiwnfel .gt_indent_2 {
  text-indent: 10px;
}
&#10;#njgqiwnfel .gt_indent_3 {
  text-indent: 15px;
}
&#10;#njgqiwnfel .gt_indent_4 {
  text-indent: 20px;
}
&#10;#njgqiwnfel .gt_indent_5 {
  text-indent: 25px;
}
&#10;#njgqiwnfel .katex-display {
  display: inline-flex !important;
  margin-bottom: 0.75em !important;
}
&#10;#njgqiwnfel div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
  height: 0px !important;
}
</style>
<table class="gt_table" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
  <caption><span class='gt_from_md'>Top 10 concepts in drug_exposure table</span></caption>
  <thead>
    <tr class="gt_col_headings gt_spanner_row">
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="2" colspan="1" style="text-align: center; font-weight: bold;" scope="col" id="Top">Top</th>
      <th class="gt_center gt_columns_top_border gt_column_spanner_outer" rowspan="1" colspan="1" style="background-color: #D9D9D9; text-align: center; font-weight: bold;" scope="col" id="spanner-[header_name]Cdm name&#10;[header_level]GiBleed">
        <div class="gt_column_spanner">Cdm name</div>
      </th>
    </tr>
    <tr class="gt_col_headings">
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="background-color: #E1E1E1; text-align: center; font-weight: bold;" scope="col" id="[header_name]Cdm-name-[header_level]GiBleed">GiBleed</th>
    </tr>
  </thead>
  <tbody class="gt_table_body">
    <tr class="gt_group_heading_row">
      <th colspan="2" class="gt_group_heading" style="background-color: #E9E9E9; font-weight: bold;" scope="colgroup" id="drug_exposure">drug_exposure</th>
    </tr>
    <tr class="gt_row_group_first"><td headers="drug_exposure  Top" class="gt_row gt_right" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;"><span class='gt_from_md'>1</span></td>
<td headers="drug_exposure  [header_name]Cdm name
[header_level]GiBleed" class="gt_row gt_left" style="text-align: right;"><span class='gt_from_md'>Standard: Acetaminophen 325 MG Oral Tablet (1127433) <br> Source: Acetaminophen 325 MG Oral Tablet (1127433) <br> 9365</span></td></tr>
    <tr><td headers="drug_exposure  Top" class="gt_row gt_right" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;"><span class='gt_from_md'>2</span></td>
<td headers="drug_exposure  [header_name]Cdm name
[header_level]GiBleed" class="gt_row gt_left" style="text-align: right;"><span class='gt_from_md'>Standard: poliovirus vaccine, inactivated (40213160) <br> Source: poliovirus vaccine, inactivated (40213160) <br> 7977</span></td></tr>
    <tr><td headers="drug_exposure  Top" class="gt_row gt_right" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;"><span class='gt_from_md'>3</span></td>
<td headers="drug_exposure  [header_name]Cdm name
[header_level]GiBleed" class="gt_row gt_left" style="text-align: right;"><span class='gt_from_md'>Standard: tetanus and diphtheria toxoids, adsorbed, preservative free, for adult use (40213227) <br> Source: tetanus and diphtheria toxoids, adsorbed, preservative free, for adult use (40213227) <br> 7430</span></td></tr>
    <tr><td headers="drug_exposure  Top" class="gt_row gt_right" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;"><span class='gt_from_md'>4</span></td>
<td headers="drug_exposure  [header_name]Cdm name
[header_level]GiBleed" class="gt_row gt_left" style="text-align: right;"><span class='gt_from_md'>Standard: Aspirin 81 MG Oral Tablet (19059056) <br> Source: Aspirin 81 MG Oral Tablet (19059056) <br> 4380</span></td></tr>
    <tr><td headers="drug_exposure  Top" class="gt_row gt_right" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;"><span class='gt_from_md'>5</span></td>
<td headers="drug_exposure  [header_name]Cdm name
[header_level]GiBleed" class="gt_row gt_left" style="text-align: right;"><span class='gt_from_md'>Standard: Amoxicillin 250 MG / Clavulanate 125 MG Oral Tablet (1713671) <br> Source: Amoxicillin 250 MG / Clavulanate 125 MG Oral Tablet (1713671) <br> 3851</span></td></tr>
    <tr><td headers="drug_exposure  Top" class="gt_row gt_right" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;"><span class='gt_from_md'>6</span></td>
<td headers="drug_exposure  [header_name]Cdm name
[header_level]GiBleed" class="gt_row gt_left" style="text-align: right;"><span class='gt_from_md'>Standard: hepatitis A vaccine, adult dosage (40213296) <br> Source: hepatitis A vaccine, adult dosage (40213296) <br> 3211</span></td></tr>
    <tr><td headers="drug_exposure  Top" class="gt_row gt_right" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;"><span class='gt_from_md'>7</span></td>
<td headers="drug_exposure  [header_name]Cdm name
[header_level]GiBleed" class="gt_row gt_left" style="text-align: right;"><span class='gt_from_md'>Standard: Acetaminophen 160 MG Oral Tablet (1127078) <br> Source: Acetaminophen 160 MG Oral Tablet (1127078) <br> 2158</span></td></tr>
    <tr><td headers="drug_exposure  Top" class="gt_row gt_right" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;"><span class='gt_from_md'>8</span></td>
<td headers="drug_exposure  [header_name]Cdm name
[header_level]GiBleed" class="gt_row gt_left" style="text-align: right;"><span class='gt_from_md'>Standard: zoster vaccine, live (40213260) <br> Source: zoster vaccine, live (40213260) <br> 2125</span></td></tr>
    <tr><td headers="drug_exposure  Top" class="gt_row gt_right" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;"><span class='gt_from_md'>9</span></td>
<td headers="drug_exposure  [header_name]Cdm name
[header_level]GiBleed" class="gt_row gt_left" style="text-align: right;"><span class='gt_from_md'>Standard: Acetaminophen 21.7 MG/ML / Dextromethorphan Hydrobromide 1 MG/ML / doxylamine succinate 0.417 MG/ML Oral Solution (40229134) <br> Source: Acetaminophen 21.7 MG/ML / Dextromethorphan Hydrobromide 1 MG/ML / doxylamine succinate 0.417 MG/ML Oral Solution (40229134) <br> 1993</span></td></tr>
    <tr><td headers="drug_exposure  Top" class="gt_row gt_right" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;"><span class='gt_from_md'>10</span></td>
<td headers="drug_exposure  [header_name]Cdm name
[header_level]GiBleed" class="gt_row gt_left" style="text-align: right;"><span class='gt_from_md'>Standard: hepatitis B vaccine, adult dosage (40213306) <br> Source: hepatitis B vaccine, adult dosage (40213306) <br> 1916</span></td></tr>
  </tbody>
  &#10;</table>
</div>

### Characterise the cdm

To obtain and explore a complete characterisation of a cdm, you can use
the OmopSketch functions `databaseCharacteristics()` and
`shinyCharacteristics()`. These functions allow you to generate and
interactively explore detailed summaries of your database. To see an
example of the outputs produced, explore the characterisation of several
synthetic datasets
[here](https://dpa-pde-oxford.shinyapps.io/OmopSketchCharacterisation/).

As seen, OmopSketch offers multiple functionalities to provide a general
overview of a database. Additionally, it includes more tools and
arguments that allow for deeper exploration, helping to assess the
database’s suitability for specific research studies. For further
information, please refer to the vignettes.
