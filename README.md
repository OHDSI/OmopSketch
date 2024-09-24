
<!-- README.md is generated from README.Rmd. Please edit that file -->

# OmopSketch <a href="https://oxford-pharmacoepi.github.io/OmopSketch/"><img src="man/figures/logo.png" align="right" height="138" alt="OmopSketch website" /></a>

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![R-CMD-check](https://github.com/oxford-pharmacoepi/OmopSketch/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/oxford-pharmacoepi/OmopSketch/actions/workflows/R-CMD-check.yaml)
[![CRAN
status](https://www.r-pkg.org/badges/version/OmopSketch)](https://CRAN.R-project.org/package=OmopSketch)
[![Codecov test
coverage](https://codecov.io/gh/oxford-pharmacoepi/OmopSketch/branch/main/graph/badge.svg)](https://app.codecov.io/gh/oxford-pharmacoepi/OmopSketch?branch=main)
<!-- badges: end -->

### WARNING: this package is under-development and has only been tested using mock data

The goal of OmopSketch is to characterise and visualise an OMOP CDM
instance to asses if it meets the necessary criteria to answer a
specific clinical question and conduct a certain study.

## Installation

You can install the development version of OmopSketch from
[GitHub](https://github.com/) with:

``` r
# install.packages("remotes")
remotes::install_github("oxford-pharmacoepi/OmopSketch")
```

## Example

Let’s start by creating a cdm object using the Eunomia mock dataset:

``` r
library(duckdb)
#> Loading required package: DBI
library(CDMConnector)
library(dplyr, warn.conflicts = FALSE)
library(OmopSketch)
con <- dbConnect(duckdb(), eunomia_dir())
cdm <- cdmFromCon(con = con, cdmSchema = "main", writeSchema = "main")
#> Note: method with signature 'DBIConnection#Id' chosen for function 'dbExistsTable',
#>  target signature 'duckdb_connection#Id'.
#>  "duckdb_connection#ANY" would also be valid
cdm
#> 
#> ── # OMOP CDM reference (duckdb) of Synthea synthetic health database ──────────
#> • omop tables: person, observation_period, visit_occurrence, visit_detail,
#> condition_occurrence, drug_exposure, procedure_occurrence, device_exposure,
#> measurement, observation, death, note, note_nlp, specimen, fact_relationship,
#> location, care_site, provider, payer_plan_period, cost, drug_era, dose_era,
#> condition_era, metadata, cdm_source, concept, vocabulary, domain,
#> concept_class, concept_relationship, relationship, concept_synonym,
#> concept_ancestor, source_to_concept_map, drug_strength
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
  tableOmopSnapshot()
#> ! Results have not been suppressed.
```

<div id="xqbckkubve" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
<style>#xqbckkubve table {
  font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}
&#10;#xqbckkubve thead, #xqbckkubve tbody, #xqbckkubve tfoot, #xqbckkubve tr, #xqbckkubve td, #xqbckkubve th {
  border-style: none;
}
&#10;#xqbckkubve p {
  margin: 0;
  padding: 0;
}
&#10;#xqbckkubve .gt_table {
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
  border-top-width: 2px;
  border-top-color: #A8A8A8;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #A8A8A8;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
}
&#10;#xqbckkubve .gt_caption {
  padding-top: 4px;
  padding-bottom: 4px;
}
&#10;#xqbckkubve .gt_title {
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
&#10;#xqbckkubve .gt_subtitle {
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
&#10;#xqbckkubve .gt_heading {
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
&#10;#xqbckkubve .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#xqbckkubve .gt_col_headings {
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
&#10;#xqbckkubve .gt_col_heading {
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
&#10;#xqbckkubve .gt_column_spanner_outer {
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
&#10;#xqbckkubve .gt_column_spanner_outer:first-child {
  padding-left: 0;
}
&#10;#xqbckkubve .gt_column_spanner_outer:last-child {
  padding-right: 0;
}
&#10;#xqbckkubve .gt_column_spanner {
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
&#10;#xqbckkubve .gt_spanner_row {
  border-bottom-style: hidden;
}
&#10;#xqbckkubve .gt_group_heading {
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
&#10;#xqbckkubve .gt_empty_group_heading {
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
&#10;#xqbckkubve .gt_from_md > :first-child {
  margin-top: 0;
}
&#10;#xqbckkubve .gt_from_md > :last-child {
  margin-bottom: 0;
}
&#10;#xqbckkubve .gt_row {
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
&#10;#xqbckkubve .gt_stub {
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
&#10;#xqbckkubve .gt_stub_row_group {
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
&#10;#xqbckkubve .gt_row_group_first td {
  border-top-width: 2px;
}
&#10;#xqbckkubve .gt_row_group_first th {
  border-top-width: 2px;
}
&#10;#xqbckkubve .gt_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#xqbckkubve .gt_first_summary_row {
  border-top-style: solid;
  border-top-color: #D3D3D3;
}
&#10;#xqbckkubve .gt_first_summary_row.thick {
  border-top-width: 2px;
}
&#10;#xqbckkubve .gt_last_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#xqbckkubve .gt_grand_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#xqbckkubve .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}
&#10;#xqbckkubve .gt_last_grand_summary_row_top {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: double;
  border-bottom-width: 6px;
  border-bottom-color: #D3D3D3;
}
&#10;#xqbckkubve .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}
&#10;#xqbckkubve .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#xqbckkubve .gt_footnotes {
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
&#10;#xqbckkubve .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#xqbckkubve .gt_sourcenotes {
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
&#10;#xqbckkubve .gt_sourcenote {
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#xqbckkubve .gt_left {
  text-align: left;
}
&#10;#xqbckkubve .gt_center {
  text-align: center;
}
&#10;#xqbckkubve .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}
&#10;#xqbckkubve .gt_font_normal {
  font-weight: normal;
}
&#10;#xqbckkubve .gt_font_bold {
  font-weight: bold;
}
&#10;#xqbckkubve .gt_font_italic {
  font-style: italic;
}
&#10;#xqbckkubve .gt_super {
  font-size: 65%;
}
&#10;#xqbckkubve .gt_footnote_marks {
  font-size: 75%;
  vertical-align: 0.4em;
  position: initial;
}
&#10;#xqbckkubve .gt_asterisk {
  font-size: 100%;
  vertical-align: 0;
}
&#10;#xqbckkubve .gt_indent_1 {
  text-indent: 5px;
}
&#10;#xqbckkubve .gt_indent_2 {
  text-indent: 10px;
}
&#10;#xqbckkubve .gt_indent_3 {
  text-indent: 15px;
}
&#10;#xqbckkubve .gt_indent_4 {
  text-indent: 20px;
}
&#10;#xqbckkubve .gt_indent_5 {
  text-indent: 25px;
}
&#10;#xqbckkubve .katex-display {
  display: inline-flex !important;
  margin-bottom: 0.75em !important;
}
&#10;#xqbckkubve div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
  height: 0px !important;
}
</style>
<table class="gt_table" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
  <thead>
    <tr class="gt_col_headings gt_spanner_row">
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="2" colspan="1" style="text-align: center; font-weight: bold;" scope="col" id="Estimate">Estimate</th>
      <th class="gt_center gt_columns_top_border gt_column_spanner_outer" rowspan="1" colspan="1" style="background-color: #D9D9D9; text-align: center; font-weight: bold;" scope="col" id="Database name">
        <span class="gt_column_spanner">Database name</span>
      </th>
    </tr>
    <tr class="gt_col_headings">
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="background-color: #E1E1E1; text-align: center; font-weight: bold;" scope="col" id="Synthea synthetic health database">Synthea synthetic health database</th>
    </tr>
  </thead>
  <tbody class="gt_table_body">
    <tr class="gt_group_heading_row">
      <th colspan="2" class="gt_group_heading" style="background-color: #E9E9E9; font-weight: bold;" scope="colgroup" id="General">General</th>
    </tr>
    <tr class="gt_row_group_first"><td headers="General  Estimate" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">Snapshot date</td>
<td headers="General  [header_name]Database name
[header_level]Synthea synthetic health database" class="gt_row gt_left" style="text-align: right;">2024-09-23</td></tr>
    <tr><td headers="General  Estimate" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">Person count</td>
<td headers="General  [header_name]Database name
[header_level]Synthea synthetic health database" class="gt_row gt_left" style="text-align: right;">2,694</td></tr>
    <tr><td headers="General  Estimate" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">Vocabulary version</td>
<td headers="General  [header_name]Database name
[header_level]Synthea synthetic health database" class="gt_row gt_left" style="text-align: right;">v5.0 18-JAN-19</td></tr>
    <tr class="gt_group_heading_row">
      <th colspan="2" class="gt_group_heading" style="background-color: #E9E9E9; font-weight: bold;" scope="colgroup" id="Observation period">Observation period</th>
    </tr>
    <tr class="gt_row_group_first"><td headers="Observation period  Estimate" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">N</td>
<td headers="Observation period  [header_name]Database name
[header_level]Synthea synthetic health database" class="gt_row gt_left" style="text-align: right;">5,343</td></tr>
    <tr><td headers="Observation period  Estimate" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">Start date</td>
<td headers="Observation period  [header_name]Database name
[header_level]Synthea synthetic health database" class="gt_row gt_left" style="text-align: right;">1908-09-22</td></tr>
    <tr><td headers="Observation period  Estimate" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">End date</td>
<td headers="Observation period  [header_name]Database name
[header_level]Synthea synthetic health database" class="gt_row gt_left" style="text-align: right;">2019-07-03</td></tr>
    <tr class="gt_group_heading_row">
      <th colspan="2" class="gt_group_heading" style="background-color: #E9E9E9; font-weight: bold;" scope="colgroup" id="Cdm">Cdm</th>
    </tr>
    <tr class="gt_row_group_first"><td headers="Cdm  Estimate" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">Source name</td>
<td headers="Cdm  [header_name]Database name
[header_level]Synthea synthetic health database" class="gt_row gt_left" style="text-align: right;">Synthea synthetic health database</td></tr>
    <tr><td headers="Cdm  Estimate" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">Version</td>
<td headers="Cdm  [header_name]Database name
[header_level]Synthea synthetic health database" class="gt_row gt_left" style="text-align: right;">v5.3.1</td></tr>
    <tr><td headers="Cdm  Estimate" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">Holder name</td>
<td headers="Cdm  [header_name]Database name
[header_level]Synthea synthetic health database" class="gt_row gt_left" style="text-align: right;">OHDSI Community</td></tr>
    <tr><td headers="Cdm  Estimate" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">Release date</td>
<td headers="Cdm  [header_name]Database name
[header_level]Synthea synthetic health database" class="gt_row gt_left" style="text-align: right;">2019-05-25</td></tr>
    <tr><td headers="Cdm  Estimate" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">Description</td>
<td headers="Cdm  [header_name]Database name
[header_level]Synthea synthetic health database" class="gt_row gt_left" style="text-align: right;">SyntheaTM is a Synthetic Patient Population Simulator. The goal is to output synthetic, realistic (but not real), patient data and associated health records in a variety of formats.</td></tr>
    <tr><td headers="Cdm  Estimate" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">Documentation reference</td>
<td headers="Cdm  [header_name]Database name
[header_level]Synthea synthetic health database" class="gt_row gt_left" style="text-align: right;">https://synthetichealth.github.io/synthea/</td></tr>
    <tr><td headers="Cdm  Estimate" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">Source type</td>
<td headers="Cdm  [header_name]Database name
[header_level]Synthea synthetic health database" class="gt_row gt_left" style="text-align: right;">duckdb</td></tr>
  </tbody>
  &#10;  
</table>
</div>

### Characterise the clinical tables

Once we have collected the snapshot information, we can start
characteristing the clinical tables of the CDM. By using
`summariseClinicalRecords()` and `tableClinicalRecords()`, we can easily
visualise the main characteristics of specific clinical tables.

``` r
summariseClinicalRecords(cdm, c("condition_occurrence", "drug_exposure")) |>
  tableClinicalRecords()
#> ℹ Summarising table counts
#> ℹ The following estimates will be computed:
#> → Start summary of data, at 2024-09-23 21:38:31.36394
#> 
#> ✔ Summary finished, at 2024-09-23 21:38:31.418166
#> ℹ Summarising records per person
#> ℹ The following estimates will be computed:
#> • records_per_person: mean, sd, median, q25, q75, min, max
#> ! Table is collected to memory as not all requested estimates are supported on
#>   the database side
#> → Start summary of data, at 2024-09-23 21:38:31.763101
#> 
#> ✔ Summary finished, at 2024-09-23 21:38:31.780797
#> ℹ Summarising in_observation, standard, domain_id, and type information
#> ℹ Summarising table counts
#> ℹ The following estimates will be computed:
#> → Start summary of data, at 2024-09-23 21:38:33.205371
#> 
#> ✔ Summary finished, at 2024-09-23 21:38:33.259787
#> ℹ Summarising records per person
#> ℹ The following estimates will be computed:
#> • records_per_person: mean, sd, median, q25, q75, min, max
#> ! Table is collected to memory as not all requested estimates are supported on
#>   the database side
#> → Start summary of data, at 2024-09-23 21:38:33.611892
#> 
#> ✔ Summary finished, at 2024-09-23 21:38:33.627355
#> ℹ Summarising in_observation, standard, domain_id, and type information
#> ! Results have not been suppressed.
```

<div id="spqvffjwef" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
<style>#spqvffjwef table {
  font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}
&#10;#spqvffjwef thead, #spqvffjwef tbody, #spqvffjwef tfoot, #spqvffjwef tr, #spqvffjwef td, #spqvffjwef th {
  border-style: none;
}
&#10;#spqvffjwef p {
  margin: 0;
  padding: 0;
}
&#10;#spqvffjwef .gt_table {
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
  border-top-width: 2px;
  border-top-color: #A8A8A8;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #A8A8A8;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
}
&#10;#spqvffjwef .gt_caption {
  padding-top: 4px;
  padding-bottom: 4px;
}
&#10;#spqvffjwef .gt_title {
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
&#10;#spqvffjwef .gt_subtitle {
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
&#10;#spqvffjwef .gt_heading {
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
&#10;#spqvffjwef .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#spqvffjwef .gt_col_headings {
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
&#10;#spqvffjwef .gt_col_heading {
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
&#10;#spqvffjwef .gt_column_spanner_outer {
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
&#10;#spqvffjwef .gt_column_spanner_outer:first-child {
  padding-left: 0;
}
&#10;#spqvffjwef .gt_column_spanner_outer:last-child {
  padding-right: 0;
}
&#10;#spqvffjwef .gt_column_spanner {
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
&#10;#spqvffjwef .gt_spanner_row {
  border-bottom-style: hidden;
}
&#10;#spqvffjwef .gt_group_heading {
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
&#10;#spqvffjwef .gt_empty_group_heading {
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
&#10;#spqvffjwef .gt_from_md > :first-child {
  margin-top: 0;
}
&#10;#spqvffjwef .gt_from_md > :last-child {
  margin-bottom: 0;
}
&#10;#spqvffjwef .gt_row {
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
&#10;#spqvffjwef .gt_stub {
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
&#10;#spqvffjwef .gt_stub_row_group {
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
&#10;#spqvffjwef .gt_row_group_first td {
  border-top-width: 2px;
}
&#10;#spqvffjwef .gt_row_group_first th {
  border-top-width: 2px;
}
&#10;#spqvffjwef .gt_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#spqvffjwef .gt_first_summary_row {
  border-top-style: solid;
  border-top-color: #D3D3D3;
}
&#10;#spqvffjwef .gt_first_summary_row.thick {
  border-top-width: 2px;
}
&#10;#spqvffjwef .gt_last_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#spqvffjwef .gt_grand_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#spqvffjwef .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}
&#10;#spqvffjwef .gt_last_grand_summary_row_top {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: double;
  border-bottom-width: 6px;
  border-bottom-color: #D3D3D3;
}
&#10;#spqvffjwef .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}
&#10;#spqvffjwef .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#spqvffjwef .gt_footnotes {
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
&#10;#spqvffjwef .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#spqvffjwef .gt_sourcenotes {
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
&#10;#spqvffjwef .gt_sourcenote {
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#spqvffjwef .gt_left {
  text-align: left;
}
&#10;#spqvffjwef .gt_center {
  text-align: center;
}
&#10;#spqvffjwef .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}
&#10;#spqvffjwef .gt_font_normal {
  font-weight: normal;
}
&#10;#spqvffjwef .gt_font_bold {
  font-weight: bold;
}
&#10;#spqvffjwef .gt_font_italic {
  font-style: italic;
}
&#10;#spqvffjwef .gt_super {
  font-size: 65%;
}
&#10;#spqvffjwef .gt_footnote_marks {
  font-size: 75%;
  vertical-align: 0.4em;
  position: initial;
}
&#10;#spqvffjwef .gt_asterisk {
  font-size: 100%;
  vertical-align: 0;
}
&#10;#spqvffjwef .gt_indent_1 {
  text-indent: 5px;
}
&#10;#spqvffjwef .gt_indent_2 {
  text-indent: 10px;
}
&#10;#spqvffjwef .gt_indent_3 {
  text-indent: 15px;
}
&#10;#spqvffjwef .gt_indent_4 {
  text-indent: 20px;
}
&#10;#spqvffjwef .gt_indent_5 {
  text-indent: 25px;
}
&#10;#spqvffjwef .katex-display {
  display: inline-flex !important;
  margin-bottom: 0.75em !important;
}
&#10;#spqvffjwef div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
  height: 0px !important;
}
</style>
<table class="gt_table" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
  <thead>
    <tr class="gt_col_headings gt_spanner_row">
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="2" colspan="1" style="text-align: center; font-weight: bold;" scope="col" id="Variable name">Variable name</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="2" colspan="1" style="text-align: center; font-weight: bold;" scope="col" id="Variable level">Variable level</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="2" colspan="1" style="text-align: center; font-weight: bold;" scope="col" id="Estimate name">Estimate name</th>
      <th class="gt_center gt_columns_top_border gt_column_spanner_outer" rowspan="1" colspan="1" style="background-color: #D9D9D9; text-align: center; font-weight: bold;" scope="col" id="Database name">
        <span class="gt_column_spanner">Database name</span>
      </th>
    </tr>
    <tr class="gt_col_headings">
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="background-color: #E1E1E1; text-align: center; font-weight: bold;" scope="col" id="Synthea synthetic health database">Synthea synthetic health database</th>
    </tr>
  </thead>
  <tbody class="gt_table_body">
    <tr class="gt_group_heading_row">
      <th colspan="4" class="gt_group_heading" style="background-color: #E9E9E9; font-weight: bold;" scope="colgroup" id="condition_occurrence">condition_occurrence</th>
    </tr>
    <tr class="gt_row_group_first"><td headers="condition_occurrence  Variable name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">Number records</td>
<td headers="condition_occurrence  Variable level" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">-</td>
<td headers="condition_occurrence  Estimate name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">N</td>
<td headers="condition_occurrence  [header_name]Database name
[header_level]Synthea synthetic health database" class="gt_row gt_right" style="text-align: right;">65,332</td></tr>
    <tr><td headers="condition_occurrence  Variable name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">Number subjects</td>
<td headers="condition_occurrence  Variable level" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">-</td>
<td headers="condition_occurrence  Estimate name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">N%</td>
<td headers="condition_occurrence  [header_name]Database name
[header_level]Synthea synthetic health database" class="gt_row gt_right" style="text-align: right;">2,694 (100.00)</td></tr>
    <tr><td headers="condition_occurrence  Variable name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">Records per person</td>
<td headers="condition_occurrence  Variable level" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">-</td>
<td headers="condition_occurrence  Estimate name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">Mean (SD)</td>
<td headers="condition_occurrence  [header_name]Database name
[header_level]Synthea synthetic health database" class="gt_row gt_right" style="text-align: right;">24.25 (7.41)</td></tr>
    <tr><td headers="condition_occurrence  Variable name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: hidden; border-top-color: #000000; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;"></td>
<td headers="condition_occurrence  Variable level" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: hidden; border-top-color: #000000; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;"></td>
<td headers="condition_occurrence  Estimate name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">median</td>
<td headers="condition_occurrence  [header_name]Database name
[header_level]Synthea synthetic health database" class="gt_row gt_right" style="text-align: right;">23</td></tr>
    <tr><td headers="condition_occurrence  Variable name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: hidden; border-top-color: #000000; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;"></td>
<td headers="condition_occurrence  Variable level" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: hidden; border-top-color: #000000; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;"></td>
<td headers="condition_occurrence  Estimate name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">q25</td>
<td headers="condition_occurrence  [header_name]Database name
[header_level]Synthea synthetic health database" class="gt_row gt_right" style="text-align: right;">19</td></tr>
    <tr><td headers="condition_occurrence  Variable name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: hidden; border-top-color: #000000; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;"></td>
<td headers="condition_occurrence  Variable level" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: hidden; border-top-color: #000000; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;"></td>
<td headers="condition_occurrence  Estimate name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">q75</td>
<td headers="condition_occurrence  [header_name]Database name
[header_level]Synthea synthetic health database" class="gt_row gt_right" style="text-align: right;">29</td></tr>
    <tr><td headers="condition_occurrence  Variable name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: hidden; border-top-color: #000000; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;"></td>
<td headers="condition_occurrence  Variable level" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: hidden; border-top-color: #000000; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;"></td>
<td headers="condition_occurrence  Estimate name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">min</td>
<td headers="condition_occurrence  [header_name]Database name
[header_level]Synthea synthetic health database" class="gt_row gt_right" style="text-align: right;">5</td></tr>
    <tr><td headers="condition_occurrence  Variable name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: hidden; border-top-color: #000000; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;"></td>
<td headers="condition_occurrence  Variable level" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: hidden; border-top-color: #000000; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;"></td>
<td headers="condition_occurrence  Estimate name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">max</td>
<td headers="condition_occurrence  [header_name]Database name
[header_level]Synthea synthetic health database" class="gt_row gt_right" style="text-align: right;">65</td></tr>
    <tr><td headers="condition_occurrence  Variable name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">In observation</td>
<td headers="condition_occurrence  Variable level" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">No</td>
<td headers="condition_occurrence  Estimate name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">N%</td>
<td headers="condition_occurrence  [header_name]Database name
[header_level]Synthea synthetic health database" class="gt_row gt_right" style="text-align: right;">9,017 (13.80)</td></tr>
    <tr><td headers="condition_occurrence  Variable name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: hidden; border-top-color: #000000; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;"></td>
<td headers="condition_occurrence  Variable level" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">Yes</td>
<td headers="condition_occurrence  Estimate name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">N%</td>
<td headers="condition_occurrence  [header_name]Database name
[header_level]Synthea synthetic health database" class="gt_row gt_right" style="text-align: right;">56,315 (86.20)</td></tr>
    <tr><td headers="condition_occurrence  Variable name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">Standard concept</td>
<td headers="condition_occurrence  Variable level" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">Standard</td>
<td headers="condition_occurrence  Estimate name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">N%</td>
<td headers="condition_occurrence  [header_name]Database name
[header_level]Synthea synthetic health database" class="gt_row gt_right" style="text-align: right;">65,332 (100.00)</td></tr>
    <tr><td headers="condition_occurrence  Variable name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">Domain</td>
<td headers="condition_occurrence  Variable level" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">Condition</td>
<td headers="condition_occurrence  Estimate name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">N%</td>
<td headers="condition_occurrence  [header_name]Database name
[header_level]Synthea synthetic health database" class="gt_row gt_right" style="text-align: right;">65,332 (100.00)</td></tr>
    <tr><td headers="condition_occurrence  Variable name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">Type concept id</td>
<td headers="condition_occurrence  Variable level" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">Ehr encounter diagnosis (32020)</td>
<td headers="condition_occurrence  Estimate name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">N%</td>
<td headers="condition_occurrence  [header_name]Database name
[header_level]Synthea synthetic health database" class="gt_row gt_right" style="text-align: right;">65,332 (100.00)</td></tr>
    <tr class="gt_group_heading_row">
      <th colspan="4" class="gt_group_heading" style="background-color: #E9E9E9; font-weight: bold;" scope="colgroup" id="drug_exposure">drug_exposure</th>
    </tr>
    <tr class="gt_row_group_first"><td headers="drug_exposure  Variable name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">Number records</td>
<td headers="drug_exposure  Variable level" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">-</td>
<td headers="drug_exposure  Estimate name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">N</td>
<td headers="drug_exposure  [header_name]Database name
[header_level]Synthea synthetic health database" class="gt_row gt_right" style="text-align: right;">67,707</td></tr>
    <tr><td headers="drug_exposure  Variable name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">Number subjects</td>
<td headers="drug_exposure  Variable level" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">-</td>
<td headers="drug_exposure  Estimate name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">N%</td>
<td headers="drug_exposure  [header_name]Database name
[header_level]Synthea synthetic health database" class="gt_row gt_right" style="text-align: right;">2,694 (100.00)</td></tr>
    <tr><td headers="drug_exposure  Variable name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">Records per person</td>
<td headers="drug_exposure  Variable level" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">-</td>
<td headers="drug_exposure  Estimate name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">Mean (SD)</td>
<td headers="drug_exposure  [header_name]Database name
[header_level]Synthea synthetic health database" class="gt_row gt_right" style="text-align: right;">25.13 (5.25)</td></tr>
    <tr><td headers="drug_exposure  Variable name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: hidden; border-top-color: #000000; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;"></td>
<td headers="drug_exposure  Variable level" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: hidden; border-top-color: #000000; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;"></td>
<td headers="drug_exposure  Estimate name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">median</td>
<td headers="drug_exposure  [header_name]Database name
[header_level]Synthea synthetic health database" class="gt_row gt_right" style="text-align: right;">25</td></tr>
    <tr><td headers="drug_exposure  Variable name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: hidden; border-top-color: #000000; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;"></td>
<td headers="drug_exposure  Variable level" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: hidden; border-top-color: #000000; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;"></td>
<td headers="drug_exposure  Estimate name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">q25</td>
<td headers="drug_exposure  [header_name]Database name
[header_level]Synthea synthetic health database" class="gt_row gt_right" style="text-align: right;">22</td></tr>
    <tr><td headers="drug_exposure  Variable name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: hidden; border-top-color: #000000; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;"></td>
<td headers="drug_exposure  Variable level" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: hidden; border-top-color: #000000; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;"></td>
<td headers="drug_exposure  Estimate name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">q75</td>
<td headers="drug_exposure  [header_name]Database name
[header_level]Synthea synthetic health database" class="gt_row gt_right" style="text-align: right;">28</td></tr>
    <tr><td headers="drug_exposure  Variable name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: hidden; border-top-color: #000000; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;"></td>
<td headers="drug_exposure  Variable level" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: hidden; border-top-color: #000000; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;"></td>
<td headers="drug_exposure  Estimate name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">min</td>
<td headers="drug_exposure  [header_name]Database name
[header_level]Synthea synthetic health database" class="gt_row gt_right" style="text-align: right;">7</td></tr>
    <tr><td headers="drug_exposure  Variable name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: hidden; border-top-color: #000000; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;"></td>
<td headers="drug_exposure  Variable level" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: hidden; border-top-color: #000000; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;"></td>
<td headers="drug_exposure  Estimate name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">max</td>
<td headers="drug_exposure  [header_name]Database name
[header_level]Synthea synthetic health database" class="gt_row gt_right" style="text-align: right;">54</td></tr>
    <tr><td headers="drug_exposure  Variable name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">In observation</td>
<td headers="drug_exposure  Variable level" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">No</td>
<td headers="drug_exposure  Estimate name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">N%</td>
<td headers="drug_exposure  [header_name]Database name
[header_level]Synthea synthetic health database" class="gt_row gt_right" style="text-align: right;">251 (0.37)</td></tr>
    <tr><td headers="drug_exposure  Variable name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: hidden; border-top-color: #000000; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;"></td>
<td headers="drug_exposure  Variable level" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">Yes</td>
<td headers="drug_exposure  Estimate name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">N%</td>
<td headers="drug_exposure  [header_name]Database name
[header_level]Synthea synthetic health database" class="gt_row gt_right" style="text-align: right;">67,456 (99.63)</td></tr>
    <tr><td headers="drug_exposure  Variable name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">Standard concept</td>
<td headers="drug_exposure  Variable level" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">Standard</td>
<td headers="drug_exposure  Estimate name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">N%</td>
<td headers="drug_exposure  [header_name]Database name
[header_level]Synthea synthetic health database" class="gt_row gt_right" style="text-align: right;">67,707 (100.00)</td></tr>
    <tr><td headers="drug_exposure  Variable name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">Domain</td>
<td headers="drug_exposure  Variable level" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">Drug</td>
<td headers="drug_exposure  Estimate name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">N%</td>
<td headers="drug_exposure  [header_name]Database name
[header_level]Synthea synthetic health database" class="gt_row gt_right" style="text-align: right;">67,707 (100.00)</td></tr>
    <tr><td headers="drug_exposure  Variable name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">Type concept id</td>
<td headers="drug_exposure  Variable level" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">Prescription written (38000177)</td>
<td headers="drug_exposure  Estimate name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">N%</td>
<td headers="drug_exposure  [header_name]Database name
[header_level]Synthea synthetic health database" class="gt_row gt_right" style="text-align: right;">41,997 (62.03)</td></tr>
    <tr><td headers="drug_exposure  Variable name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: hidden; border-top-color: #000000; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;"></td>
<td headers="drug_exposure  Variable level" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">Dispensed in outpatient office (581452)</td>
<td headers="drug_exposure  Estimate name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">N%</td>
<td headers="drug_exposure  [header_name]Database name
[header_level]Synthea synthetic health database" class="gt_row gt_right" style="text-align: right;">25,710 (37.97)</td></tr>
  </tbody>
  &#10;  
</table>
</div>

We can also explore trends in the clinical table records over time.

``` r
summariseRecordCount(cdm, c("condition_occurrence", "drug_exposure")) |>
  plotRecordCount(facet = "omop_table")
#> ! The following column type were changed:
#> • variable_level: from double to character
```

<img src="man/figures/README-unnamed-chunk-5-1.png" width="100%" /> \###
Characterise the observation period After visualising the main
characteristics of our clinical tables, we can explore the observation
period details. OmopSketch provides several functions to have an
overwied of the dataset study period.

Using `summariseInObservation()` and `plotInObservation()`, we can
gather information on the number of records per year.

``` r
summariseInObservation(cdm$observation_period, output = "records") |>
  plotInObservation()
#> ! The following column type were changed:
#> • variable_level: from double to character
```

<img src="man/figures/README-unnamed-chunk-6-1.png" width="100%" /> You
can also visualise and explore the characteristics of the observation
period per each individual in the database using
`summariseObservationPeriod()`.

``` r
summariseObservationPeriod(cdm$observation_period) |>
  tableObservationPeriod()
#> ! Results have not been suppressed.
```

<div id="dyjdpcfzdl" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
<style>#dyjdpcfzdl table {
  font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}
&#10;#dyjdpcfzdl thead, #dyjdpcfzdl tbody, #dyjdpcfzdl tfoot, #dyjdpcfzdl tr, #dyjdpcfzdl td, #dyjdpcfzdl th {
  border-style: none;
}
&#10;#dyjdpcfzdl p {
  margin: 0;
  padding: 0;
}
&#10;#dyjdpcfzdl .gt_table {
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
  border-top-width: 2px;
  border-top-color: #A8A8A8;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #A8A8A8;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
}
&#10;#dyjdpcfzdl .gt_caption {
  padding-top: 4px;
  padding-bottom: 4px;
}
&#10;#dyjdpcfzdl .gt_title {
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
&#10;#dyjdpcfzdl .gt_subtitle {
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
&#10;#dyjdpcfzdl .gt_heading {
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
&#10;#dyjdpcfzdl .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#dyjdpcfzdl .gt_col_headings {
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
&#10;#dyjdpcfzdl .gt_col_heading {
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
&#10;#dyjdpcfzdl .gt_column_spanner_outer {
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
&#10;#dyjdpcfzdl .gt_column_spanner_outer:first-child {
  padding-left: 0;
}
&#10;#dyjdpcfzdl .gt_column_spanner_outer:last-child {
  padding-right: 0;
}
&#10;#dyjdpcfzdl .gt_column_spanner {
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
&#10;#dyjdpcfzdl .gt_spanner_row {
  border-bottom-style: hidden;
}
&#10;#dyjdpcfzdl .gt_group_heading {
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
&#10;#dyjdpcfzdl .gt_empty_group_heading {
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
&#10;#dyjdpcfzdl .gt_from_md > :first-child {
  margin-top: 0;
}
&#10;#dyjdpcfzdl .gt_from_md > :last-child {
  margin-bottom: 0;
}
&#10;#dyjdpcfzdl .gt_row {
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
&#10;#dyjdpcfzdl .gt_stub {
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
&#10;#dyjdpcfzdl .gt_stub_row_group {
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
&#10;#dyjdpcfzdl .gt_row_group_first td {
  border-top-width: 2px;
}
&#10;#dyjdpcfzdl .gt_row_group_first th {
  border-top-width: 2px;
}
&#10;#dyjdpcfzdl .gt_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#dyjdpcfzdl .gt_first_summary_row {
  border-top-style: solid;
  border-top-color: #D3D3D3;
}
&#10;#dyjdpcfzdl .gt_first_summary_row.thick {
  border-top-width: 2px;
}
&#10;#dyjdpcfzdl .gt_last_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#dyjdpcfzdl .gt_grand_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#dyjdpcfzdl .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}
&#10;#dyjdpcfzdl .gt_last_grand_summary_row_top {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: double;
  border-bottom-width: 6px;
  border-bottom-color: #D3D3D3;
}
&#10;#dyjdpcfzdl .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}
&#10;#dyjdpcfzdl .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#dyjdpcfzdl .gt_footnotes {
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
&#10;#dyjdpcfzdl .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#dyjdpcfzdl .gt_sourcenotes {
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
&#10;#dyjdpcfzdl .gt_sourcenote {
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#dyjdpcfzdl .gt_left {
  text-align: left;
}
&#10;#dyjdpcfzdl .gt_center {
  text-align: center;
}
&#10;#dyjdpcfzdl .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}
&#10;#dyjdpcfzdl .gt_font_normal {
  font-weight: normal;
}
&#10;#dyjdpcfzdl .gt_font_bold {
  font-weight: bold;
}
&#10;#dyjdpcfzdl .gt_font_italic {
  font-style: italic;
}
&#10;#dyjdpcfzdl .gt_super {
  font-size: 65%;
}
&#10;#dyjdpcfzdl .gt_footnote_marks {
  font-size: 75%;
  vertical-align: 0.4em;
  position: initial;
}
&#10;#dyjdpcfzdl .gt_asterisk {
  font-size: 100%;
  vertical-align: 0;
}
&#10;#dyjdpcfzdl .gt_indent_1 {
  text-indent: 5px;
}
&#10;#dyjdpcfzdl .gt_indent_2 {
  text-indent: 10px;
}
&#10;#dyjdpcfzdl .gt_indent_3 {
  text-indent: 15px;
}
&#10;#dyjdpcfzdl .gt_indent_4 {
  text-indent: 20px;
}
&#10;#dyjdpcfzdl .gt_indent_5 {
  text-indent: 25px;
}
&#10;#dyjdpcfzdl .katex-display {
  display: inline-flex !important;
  margin-bottom: 0.75em !important;
}
&#10;#dyjdpcfzdl div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
  height: 0px !important;
}
</style>
<table class="gt_table" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
  <thead>
    <tr class="gt_col_headings gt_spanner_row">
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="2" colspan="1" style="text-align: center; font-weight: bold;" scope="col" id="Observation period ordinal">Observation period ordinal</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="2" colspan="1" style="text-align: center; font-weight: bold;" scope="col" id="Variable name">Variable name</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="2" colspan="1" style="text-align: center; font-weight: bold;" scope="col" id="Estimate name">Estimate name</th>
      <th class="gt_center gt_columns_top_border gt_column_spanner_outer" rowspan="1" colspan="1" style="background-color: #D9D9D9; text-align: center; font-weight: bold;" scope="col" id="CDM name">
        <span class="gt_column_spanner">CDM name</span>
      </th>
    </tr>
    <tr class="gt_col_headings">
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="background-color: #E1E1E1; text-align: center; font-weight: bold;" scope="col" id="Synthea synthetic health database">Synthea synthetic health database</th>
    </tr>
  </thead>
  <tbody class="gt_table_body">
    <tr><td headers="Observation period ordinal" class="gt_row gt_left" style="text-align: left;">overall</td>
<td headers="Variable name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">Number records</td>
<td headers="Estimate name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">N</td>
<td headers="[header_name]CDM name
[header_level]Synthea synthetic health database" class="gt_row gt_left" style="text-align: right;">2,694</td></tr>
    <tr><td headers="Observation period ordinal" class="gt_row gt_left" style="text-align: left; border-top-width: 1px; border-top-style: hidden; border-top-color: #000000;"></td>
<td headers="Variable name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">Number subjects</td>
<td headers="Estimate name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">N</td>
<td headers="[header_name]CDM name
[header_level]Synthea synthetic health database" class="gt_row gt_left" style="text-align: right;">2,694</td></tr>
    <tr><td headers="Observation period ordinal" class="gt_row gt_left" style="text-align: left; border-top-width: 1px; border-top-style: hidden; border-top-color: #000000;"></td>
<td headers="Variable name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">Records per person</td>
<td headers="Estimate name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">mean (sd)</td>
<td headers="[header_name]CDM name
[header_level]Synthea synthetic health database" class="gt_row gt_left" style="text-align: right;">1.00 (0.00)</td></tr>
    <tr><td headers="Observation period ordinal" class="gt_row gt_left" style="text-align: left; border-top-width: 1px; border-top-style: hidden; border-top-color: #000000;"></td>
<td headers="Variable name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: hidden; border-top-color: #000000; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;"></td>
<td headers="Estimate name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">median [Q25 - Q75]</td>
<td headers="[header_name]CDM name
[header_level]Synthea synthetic health database" class="gt_row gt_left" style="text-align: right;">1 [1 - 1]</td></tr>
    <tr><td headers="Observation period ordinal" class="gt_row gt_left" style="text-align: left; border-top-width: 1px; border-top-style: hidden; border-top-color: #000000;"></td>
<td headers="Variable name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">Duration in days</td>
<td headers="Estimate name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">mean (sd)</td>
<td headers="[header_name]CDM name
[header_level]Synthea synthetic health database" class="gt_row gt_left" style="text-align: right;">21,602.60 (5,460.69)</td></tr>
    <tr><td headers="Observation period ordinal" class="gt_row gt_left" style="text-align: left; border-top-width: 1px; border-top-style: hidden; border-top-color: #000000;"></td>
<td headers="Variable name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: hidden; border-top-color: #000000; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;"></td>
<td headers="Estimate name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">median [Q25 - Q75]</td>
<td headers="[header_name]CDM name
[header_level]Synthea synthetic health database" class="gt_row gt_left" style="text-align: right;">20,872 [17,495 - 24,702]</td></tr>
    <tr><td headers="Observation period ordinal" class="gt_row gt_left" style="text-align: left; border-top-width: 1px; border-top-style: hidden; border-top-color: #000000;"></td>
<td headers="Variable name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">Days to next observation period</td>
<td headers="Estimate name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">mean (sd)</td>
<td headers="[header_name]CDM name
[header_level]Synthea synthetic health database" class="gt_row gt_left" style="text-align: right;">-</td></tr>
    <tr><td headers="Observation period ordinal" class="gt_row gt_left" style="text-align: left; border-top-width: 1px; border-top-style: hidden; border-top-color: #000000;"></td>
<td headers="Variable name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: hidden; border-top-color: #000000; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;"></td>
<td headers="Estimate name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">median [Q25 - Q75]</td>
<td headers="[header_name]CDM name
[header_level]Synthea synthetic health database" class="gt_row gt_left" style="text-align: right;">-</td></tr>
    <tr><td headers="Observation period ordinal" class="gt_row gt_left" style="text-align: left;">1st</td>
<td headers="Variable name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">Number subjects</td>
<td headers="Estimate name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">N</td>
<td headers="[header_name]CDM name
[header_level]Synthea synthetic health database" class="gt_row gt_left" style="text-align: right;">2,694</td></tr>
    <tr><td headers="Observation period ordinal" class="gt_row gt_left" style="text-align: left; border-top-width: 1px; border-top-style: hidden; border-top-color: #000000;"></td>
<td headers="Variable name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">Duration in days</td>
<td headers="Estimate name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">mean (sd)</td>
<td headers="[header_name]CDM name
[header_level]Synthea synthetic health database" class="gt_row gt_left" style="text-align: right;">21,602.60 (5,460.69)</td></tr>
    <tr><td headers="Observation period ordinal" class="gt_row gt_left" style="text-align: left; border-top-width: 1px; border-top-style: hidden; border-top-color: #000000;"></td>
<td headers="Variable name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: hidden; border-top-color: #000000; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;"></td>
<td headers="Estimate name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">median [Q25 - Q75]</td>
<td headers="[header_name]CDM name
[header_level]Synthea synthetic health database" class="gt_row gt_left" style="text-align: right;">20,872 [17,495 - 24,702]</td></tr>
    <tr><td headers="Observation period ordinal" class="gt_row gt_left" style="text-align: left; border-top-width: 1px; border-top-style: hidden; border-top-color: #000000;"></td>
<td headers="Variable name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">Days to next observation period</td>
<td headers="Estimate name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">mean (sd)</td>
<td headers="[header_name]CDM name
[header_level]Synthea synthetic health database" class="gt_row gt_left" style="text-align: right;">-</td></tr>
    <tr><td headers="Observation period ordinal" class="gt_row gt_left" style="text-align: left; border-top-width: 1px; border-top-style: hidden; border-top-color: #000000;"></td>
<td headers="Variable name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: hidden; border-top-color: #000000; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;"></td>
<td headers="Estimate name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">median [Q25 - Q75]</td>
<td headers="[header_name]CDM name
[header_level]Synthea synthetic health database" class="gt_row gt_left" style="text-align: right;">-</td></tr>
  </tbody>
  &#10;  
</table>
</div>

Or if visualisation is prefered, you can easily build a histogram to
explore how many participants have more than one observation period.

``` r
summariseObservationPeriod(cdm$observation_period) |>
  plotObservationPeriod()
```

<img src="man/figures/README-unnamed-chunk-8-1.png" width="100%" />

### Characterise the concepts

OmopSketch also provides functions to explore some of (or all) the
concepts in the dataset.

``` r
acetaminophen <- c(1125315,  1127433, 1127078)

summariseConceptCounts(cdm, conceptId = list("acetaminophen" = acetaminophen)) |>
  filter(estimate_name == "record_count") |> 
  plotConceptCounts()
#> ℹ Getting use of codes from acetaminophen
#> ! The following column type were changed:
#> • variable_name: from integer to character
```

<img src="man/figures/README-unnamed-chunk-9-1.png" width="100%" />

### Characterise the population

Finally, OmopSketch can also help us to characterise the population at
the start and end of the observation period.

``` r
summarisePopulationCharacteristics(cdm) |>
  tablePopulationCharacteristics()
#> Warning: ! 1 casted column in og_015_1727120322 (cohort_set) as do not match expected
#>   column type:
#> • `cohort_definition_id` from numeric to integer
#> Warning: ! 1 column in og_015_1727120322 do not match expected column type:
#> • `cohort_definition_id` is numeric but expected integer
#> ! cohort columns will be reordered to match the expected order:
#>   cohort_definition_id, subject_id, cohort_start_date, and cohort_end_date.
#> ℹ Building new trimmed cohort
#> Warning: ! 1 column in tmp_011_og_017_1727120322 do not match expected column type:
#> • `cohort_definition_id` is numeric but expected integer
#> Creating initial cohort
#> ! cohort columns will be reordered to match the expected order:
#>   cohort_definition_id, subject_id, cohort_start_date, and cohort_end_date.
#> ! cohort columns will be reordered to match the expected order:
#>   cohort_definition_id, subject_id, cohort_start_date, and cohort_end_date.
#> ✔ Cohort trimmed
#> ℹ adding demographics columns
#> 
#> ℹ summarising data
#> 
#> ✔ summariseCharacteristics finished!
#> 
#> ! The following column type were changed:
#> • variable_name: from integer to character
#> ! Results have not been suppressed.
```

<div id="wynepvuhcj" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
<style>#wynepvuhcj table {
  font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}
&#10;#wynepvuhcj thead, #wynepvuhcj tbody, #wynepvuhcj tfoot, #wynepvuhcj tr, #wynepvuhcj td, #wynepvuhcj th {
  border-style: none;
}
&#10;#wynepvuhcj p {
  margin: 0;
  padding: 0;
}
&#10;#wynepvuhcj .gt_table {
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
  border-top-width: 2px;
  border-top-color: #A8A8A8;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #A8A8A8;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
}
&#10;#wynepvuhcj .gt_caption {
  padding-top: 4px;
  padding-bottom: 4px;
}
&#10;#wynepvuhcj .gt_title {
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
&#10;#wynepvuhcj .gt_subtitle {
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
&#10;#wynepvuhcj .gt_heading {
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
&#10;#wynepvuhcj .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#wynepvuhcj .gt_col_headings {
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
&#10;#wynepvuhcj .gt_col_heading {
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
&#10;#wynepvuhcj .gt_column_spanner_outer {
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
&#10;#wynepvuhcj .gt_column_spanner_outer:first-child {
  padding-left: 0;
}
&#10;#wynepvuhcj .gt_column_spanner_outer:last-child {
  padding-right: 0;
}
&#10;#wynepvuhcj .gt_column_spanner {
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
&#10;#wynepvuhcj .gt_spanner_row {
  border-bottom-style: hidden;
}
&#10;#wynepvuhcj .gt_group_heading {
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
&#10;#wynepvuhcj .gt_empty_group_heading {
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
&#10;#wynepvuhcj .gt_from_md > :first-child {
  margin-top: 0;
}
&#10;#wynepvuhcj .gt_from_md > :last-child {
  margin-bottom: 0;
}
&#10;#wynepvuhcj .gt_row {
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
&#10;#wynepvuhcj .gt_stub {
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
&#10;#wynepvuhcj .gt_stub_row_group {
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
&#10;#wynepvuhcj .gt_row_group_first td {
  border-top-width: 2px;
}
&#10;#wynepvuhcj .gt_row_group_first th {
  border-top-width: 2px;
}
&#10;#wynepvuhcj .gt_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#wynepvuhcj .gt_first_summary_row {
  border-top-style: solid;
  border-top-color: #D3D3D3;
}
&#10;#wynepvuhcj .gt_first_summary_row.thick {
  border-top-width: 2px;
}
&#10;#wynepvuhcj .gt_last_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#wynepvuhcj .gt_grand_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#wynepvuhcj .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}
&#10;#wynepvuhcj .gt_last_grand_summary_row_top {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: double;
  border-bottom-width: 6px;
  border-bottom-color: #D3D3D3;
}
&#10;#wynepvuhcj .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}
&#10;#wynepvuhcj .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#wynepvuhcj .gt_footnotes {
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
&#10;#wynepvuhcj .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#wynepvuhcj .gt_sourcenotes {
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
&#10;#wynepvuhcj .gt_sourcenote {
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#wynepvuhcj .gt_left {
  text-align: left;
}
&#10;#wynepvuhcj .gt_center {
  text-align: center;
}
&#10;#wynepvuhcj .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}
&#10;#wynepvuhcj .gt_font_normal {
  font-weight: normal;
}
&#10;#wynepvuhcj .gt_font_bold {
  font-weight: bold;
}
&#10;#wynepvuhcj .gt_font_italic {
  font-style: italic;
}
&#10;#wynepvuhcj .gt_super {
  font-size: 65%;
}
&#10;#wynepvuhcj .gt_footnote_marks {
  font-size: 75%;
  vertical-align: 0.4em;
  position: initial;
}
&#10;#wynepvuhcj .gt_asterisk {
  font-size: 100%;
  vertical-align: 0;
}
&#10;#wynepvuhcj .gt_indent_1 {
  text-indent: 5px;
}
&#10;#wynepvuhcj .gt_indent_2 {
  text-indent: 10px;
}
&#10;#wynepvuhcj .gt_indent_3 {
  text-indent: 15px;
}
&#10;#wynepvuhcj .gt_indent_4 {
  text-indent: 20px;
}
&#10;#wynepvuhcj .gt_indent_5 {
  text-indent: 25px;
}
&#10;#wynepvuhcj .katex-display {
  display: inline-flex !important;
  margin-bottom: 0.75em !important;
}
&#10;#wynepvuhcj div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
  height: 0px !important;
}
</style>
<table class="gt_table" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
  <thead>
    <tr class="gt_col_headings gt_spanner_row">
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="2" colspan="1" style="text-align: center; font-weight: bold;" scope="col" id="Variable name">Variable name</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="2" colspan="1" style="text-align: center; font-weight: bold;" scope="col" id="Variable level">Variable level</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="2" colspan="1" style="text-align: center; font-weight: bold;" scope="col" id="Estimate name">Estimate name</th>
      <th class="gt_center gt_columns_top_border gt_column_spanner_outer" rowspan="1" colspan="1" style="background-color: #D9D9D9; text-align: center; font-weight: bold;" scope="col" id="Database name">
        <span class="gt_column_spanner">Database name</span>
      </th>
    </tr>
    <tr class="gt_col_headings">
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="background-color: #E1E1E1; text-align: center; font-weight: bold;" scope="col" id="Synthea synthetic health database">Synthea synthetic health database</th>
    </tr>
  </thead>
  <tbody class="gt_table_body">
    <tr><td headers="Variable name" class="gt_row gt_left" style="text-align: left;">Number records</td>
<td headers="Variable level" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">-</td>
<td headers="Estimate name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">N</td>
<td headers="[header_name]Database name
[header_level]Synthea synthetic health database" class="gt_row gt_right" style="text-align: right;">2,694</td></tr>
    <tr><td headers="Variable name" class="gt_row gt_left" style="text-align: left;">Number subjects</td>
<td headers="Variable level" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">-</td>
<td headers="Estimate name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">N</td>
<td headers="[header_name]Database name
[header_level]Synthea synthetic health database" class="gt_row gt_right" style="text-align: right;">2,694</td></tr>
    <tr><td headers="Variable name" class="gt_row gt_left" style="text-align: left;">Cohort start date</td>
<td headers="Variable level" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">-</td>
<td headers="Estimate name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">min</td>
<td headers="[header_name]Database name
[header_level]Synthea synthetic health database" class="gt_row gt_right" style="text-align: right;">1908-09-22</td></tr>
    <tr><td headers="Variable name" class="gt_row gt_left" style="text-align: left; border-top-width: 1px; border-top-style: hidden; border-top-color: #000000;"></td>
<td headers="Variable level" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: hidden; border-top-color: #000000; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;"></td>
<td headers="Estimate name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">q25</td>
<td headers="[header_name]Database name
[header_level]Synthea synthetic health database" class="gt_row gt_right" style="text-align: right;">1950-07-13</td></tr>
    <tr><td headers="Variable name" class="gt_row gt_left" style="text-align: left; border-top-width: 1px; border-top-style: hidden; border-top-color: #000000;"></td>
<td headers="Variable level" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: hidden; border-top-color: #000000; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;"></td>
<td headers="Estimate name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">median</td>
<td headers="[header_name]Database name
[header_level]Synthea synthetic health database" class="gt_row gt_right" style="text-align: right;">1961-03-18</td></tr>
    <tr><td headers="Variable name" class="gt_row gt_left" style="text-align: left; border-top-width: 1px; border-top-style: hidden; border-top-color: #000000;"></td>
<td headers="Variable level" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: hidden; border-top-color: #000000; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;"></td>
<td headers="Estimate name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">q75</td>
<td headers="[header_name]Database name
[header_level]Synthea synthetic health database" class="gt_row gt_right" style="text-align: right;">1970-08-29</td></tr>
    <tr><td headers="Variable name" class="gt_row gt_left" style="text-align: left; border-top-width: 1px; border-top-style: hidden; border-top-color: #000000;"></td>
<td headers="Variable level" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: hidden; border-top-color: #000000; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;"></td>
<td headers="Estimate name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">max</td>
<td headers="[header_name]Database name
[header_level]Synthea synthetic health database" class="gt_row gt_right" style="text-align: right;">1986-11-03</td></tr>
    <tr><td headers="Variable name" class="gt_row gt_left" style="text-align: left;">Cohort end date</td>
<td headers="Variable level" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">-</td>
<td headers="Estimate name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">min</td>
<td headers="[header_name]Database name
[header_level]Synthea synthetic health database" class="gt_row gt_right" style="text-align: right;">1945-07-20</td></tr>
    <tr><td headers="Variable name" class="gt_row gt_left" style="text-align: left; border-top-width: 1px; border-top-style: hidden; border-top-color: #000000;"></td>
<td headers="Variable level" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: hidden; border-top-color: #000000; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;"></td>
<td headers="Estimate name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">q25</td>
<td headers="[header_name]Database name
[header_level]Synthea synthetic health database" class="gt_row gt_right" style="text-align: right;">2018-08-02</td></tr>
    <tr><td headers="Variable name" class="gt_row gt_left" style="text-align: left; border-top-width: 1px; border-top-style: hidden; border-top-color: #000000;"></td>
<td headers="Variable level" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: hidden; border-top-color: #000000; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;"></td>
<td headers="Estimate name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">median</td>
<td headers="[header_name]Database name
[header_level]Synthea synthetic health database" class="gt_row gt_right" style="text-align: right;">2018-12-14</td></tr>
    <tr><td headers="Variable name" class="gt_row gt_left" style="text-align: left; border-top-width: 1px; border-top-style: hidden; border-top-color: #000000;"></td>
<td headers="Variable level" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: hidden; border-top-color: #000000; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;"></td>
<td headers="Estimate name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">q75</td>
<td headers="[header_name]Database name
[header_level]Synthea synthetic health database" class="gt_row gt_right" style="text-align: right;">2019-04-06</td></tr>
    <tr><td headers="Variable name" class="gt_row gt_left" style="text-align: left; border-top-width: 1px; border-top-style: hidden; border-top-color: #000000;"></td>
<td headers="Variable level" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: hidden; border-top-color: #000000; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;"></td>
<td headers="Estimate name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">max</td>
<td headers="[header_name]Database name
[header_level]Synthea synthetic health database" class="gt_row gt_right" style="text-align: right;">2019-07-03</td></tr>
    <tr><td headers="Variable name" class="gt_row gt_left" style="text-align: left;">Age at start</td>
<td headers="Variable level" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">-</td>
<td headers="Estimate name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">Mean (SD)</td>
<td headers="[header_name]Database name
[header_level]Synthea synthetic health database" class="gt_row gt_right" style="text-align: right;">0.00 (0.00)</td></tr>
    <tr><td headers="Variable name" class="gt_row gt_left" style="text-align: left; border-top-width: 1px; border-top-style: hidden; border-top-color: #000000;"></td>
<td headers="Variable level" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: hidden; border-top-color: #000000; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;"></td>
<td headers="Estimate name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">min</td>
<td headers="[header_name]Database name
[header_level]Synthea synthetic health database" class="gt_row gt_right" style="text-align: right;">0</td></tr>
    <tr><td headers="Variable name" class="gt_row gt_left" style="text-align: left; border-top-width: 1px; border-top-style: hidden; border-top-color: #000000;"></td>
<td headers="Variable level" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: hidden; border-top-color: #000000; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;"></td>
<td headers="Estimate name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">q25</td>
<td headers="[header_name]Database name
[header_level]Synthea synthetic health database" class="gt_row gt_right" style="text-align: right;">0</td></tr>
    <tr><td headers="Variable name" class="gt_row gt_left" style="text-align: left; border-top-width: 1px; border-top-style: hidden; border-top-color: #000000;"></td>
<td headers="Variable level" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: hidden; border-top-color: #000000; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;"></td>
<td headers="Estimate name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">median</td>
<td headers="[header_name]Database name
[header_level]Synthea synthetic health database" class="gt_row gt_right" style="text-align: right;">0</td></tr>
    <tr><td headers="Variable name" class="gt_row gt_left" style="text-align: left; border-top-width: 1px; border-top-style: hidden; border-top-color: #000000;"></td>
<td headers="Variable level" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: hidden; border-top-color: #000000; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;"></td>
<td headers="Estimate name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">q75</td>
<td headers="[header_name]Database name
[header_level]Synthea synthetic health database" class="gt_row gt_right" style="text-align: right;">0</td></tr>
    <tr><td headers="Variable name" class="gt_row gt_left" style="text-align: left; border-top-width: 1px; border-top-style: hidden; border-top-color: #000000;"></td>
<td headers="Variable level" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: hidden; border-top-color: #000000; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;"></td>
<td headers="Estimate name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">max</td>
<td headers="[header_name]Database name
[header_level]Synthea synthetic health database" class="gt_row gt_right" style="text-align: right;">0</td></tr>
    <tr><td headers="Variable name" class="gt_row gt_left" style="text-align: left;">Age at end</td>
<td headers="Variable level" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">-</td>
<td headers="Estimate name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">min</td>
<td headers="[header_name]Database name
[header_level]Synthea synthetic health database" class="gt_row gt_right" style="text-align: right;">31</td></tr>
    <tr><td headers="Variable name" class="gt_row gt_left" style="text-align: left; border-top-width: 1px; border-top-style: hidden; border-top-color: #000000;"></td>
<td headers="Variable level" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: hidden; border-top-color: #000000; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;"></td>
<td headers="Estimate name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">q25</td>
<td headers="[header_name]Database name
[header_level]Synthea synthetic health database" class="gt_row gt_right" style="text-align: right;">47</td></tr>
    <tr><td headers="Variable name" class="gt_row gt_left" style="text-align: left; border-top-width: 1px; border-top-style: hidden; border-top-color: #000000;"></td>
<td headers="Variable level" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: hidden; border-top-color: #000000; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;"></td>
<td headers="Estimate name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">median</td>
<td headers="[header_name]Database name
[header_level]Synthea synthetic health database" class="gt_row gt_right" style="text-align: right;">57</td></tr>
    <tr><td headers="Variable name" class="gt_row gt_left" style="text-align: left; border-top-width: 1px; border-top-style: hidden; border-top-color: #000000;"></td>
<td headers="Variable level" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: hidden; border-top-color: #000000; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;"></td>
<td headers="Estimate name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">q75</td>
<td headers="[header_name]Database name
[header_level]Synthea synthetic health database" class="gt_row gt_right" style="text-align: right;">67</td></tr>
    <tr><td headers="Variable name" class="gt_row gt_left" style="text-align: left; border-top-width: 1px; border-top-style: hidden; border-top-color: #000000;"></td>
<td headers="Variable level" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: hidden; border-top-color: #000000; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;"></td>
<td headers="Estimate name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">max</td>
<td headers="[header_name]Database name
[header_level]Synthea synthetic health database" class="gt_row gt_right" style="text-align: right;">110</td></tr>
    <tr><td headers="Variable name" class="gt_row gt_left" style="text-align: left;">Sex</td>
<td headers="Variable level" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">Female</td>
<td headers="Estimate name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">N%</td>
<td headers="[header_name]Database name
[header_level]Synthea synthetic health database" class="gt_row gt_right" style="text-align: right;">1,373 (50.97)</td></tr>
    <tr><td headers="Variable name" class="gt_row gt_left" style="text-align: left; border-top-width: 1px; border-top-style: hidden; border-top-color: #000000;"></td>
<td headers="Variable level" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">Male</td>
<td headers="Estimate name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">N%</td>
<td headers="[header_name]Database name
[header_level]Synthea synthetic health database" class="gt_row gt_right" style="text-align: right;">1,321 (49.03)</td></tr>
    <tr><td headers="Variable name" class="gt_row gt_left" style="text-align: left;">Prior observation</td>
<td headers="Variable level" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">-</td>
<td headers="Estimate name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">Mean (SD)</td>
<td headers="[header_name]Database name
[header_level]Synthea synthetic health database" class="gt_row gt_right" style="text-align: right;">0.00 (0.00)</td></tr>
    <tr><td headers="Variable name" class="gt_row gt_left" style="text-align: left; border-top-width: 1px; border-top-style: hidden; border-top-color: #000000;"></td>
<td headers="Variable level" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: hidden; border-top-color: #000000; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;"></td>
<td headers="Estimate name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">min</td>
<td headers="[header_name]Database name
[header_level]Synthea synthetic health database" class="gt_row gt_right" style="text-align: right;">0</td></tr>
    <tr><td headers="Variable name" class="gt_row gt_left" style="text-align: left; border-top-width: 1px; border-top-style: hidden; border-top-color: #000000;"></td>
<td headers="Variable level" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: hidden; border-top-color: #000000; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;"></td>
<td headers="Estimate name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">q25</td>
<td headers="[header_name]Database name
[header_level]Synthea synthetic health database" class="gt_row gt_right" style="text-align: right;">0</td></tr>
    <tr><td headers="Variable name" class="gt_row gt_left" style="text-align: left; border-top-width: 1px; border-top-style: hidden; border-top-color: #000000;"></td>
<td headers="Variable level" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: hidden; border-top-color: #000000; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;"></td>
<td headers="Estimate name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">median</td>
<td headers="[header_name]Database name
[header_level]Synthea synthetic health database" class="gt_row gt_right" style="text-align: right;">0</td></tr>
    <tr><td headers="Variable name" class="gt_row gt_left" style="text-align: left; border-top-width: 1px; border-top-style: hidden; border-top-color: #000000;"></td>
<td headers="Variable level" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: hidden; border-top-color: #000000; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;"></td>
<td headers="Estimate name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">q75</td>
<td headers="[header_name]Database name
[header_level]Synthea synthetic health database" class="gt_row gt_right" style="text-align: right;">0</td></tr>
    <tr><td headers="Variable name" class="gt_row gt_left" style="text-align: left; border-top-width: 1px; border-top-style: hidden; border-top-color: #000000;"></td>
<td headers="Variable level" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: hidden; border-top-color: #000000; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;"></td>
<td headers="Estimate name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">max</td>
<td headers="[header_name]Database name
[header_level]Synthea synthetic health database" class="gt_row gt_right" style="text-align: right;">0</td></tr>
    <tr><td headers="Variable name" class="gt_row gt_left" style="text-align: left;">Future observation</td>
<td headers="Variable level" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">-</td>
<td headers="Estimate name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">Mean (SD)</td>
<td headers="[header_name]Database name
[header_level]Synthea synthetic health database" class="gt_row gt_right" style="text-align: right;">21,601.60 (5,460.69)</td></tr>
    <tr><td headers="Variable name" class="gt_row gt_left" style="text-align: left; border-top-width: 1px; border-top-style: hidden; border-top-color: #000000;"></td>
<td headers="Variable level" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: hidden; border-top-color: #000000; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;"></td>
<td headers="Estimate name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">min</td>
<td headers="[header_name]Database name
[header_level]Synthea synthetic health database" class="gt_row gt_right" style="text-align: right;">11,396</td></tr>
    <tr><td headers="Variable name" class="gt_row gt_left" style="text-align: left; border-top-width: 1px; border-top-style: hidden; border-top-color: #000000;"></td>
<td headers="Variable level" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: hidden; border-top-color: #000000; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;"></td>
<td headers="Estimate name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">q25</td>
<td headers="[header_name]Database name
[header_level]Synthea synthetic health database" class="gt_row gt_right" style="text-align: right;">17,494</td></tr>
    <tr><td headers="Variable name" class="gt_row gt_left" style="text-align: left; border-top-width: 1px; border-top-style: hidden; border-top-color: #000000;"></td>
<td headers="Variable level" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: hidden; border-top-color: #000000; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;"></td>
<td headers="Estimate name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">median</td>
<td headers="[header_name]Database name
[header_level]Synthea synthetic health database" class="gt_row gt_right" style="text-align: right;">20,870</td></tr>
    <tr><td headers="Variable name" class="gt_row gt_left" style="text-align: left; border-top-width: 1px; border-top-style: hidden; border-top-color: #000000;"></td>
<td headers="Variable level" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: hidden; border-top-color: #000000; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;"></td>
<td headers="Estimate name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">q75</td>
<td headers="[header_name]Database name
[header_level]Synthea synthetic health database" class="gt_row gt_right" style="text-align: right;">24,701</td></tr>
    <tr><td headers="Variable name" class="gt_row gt_left" style="text-align: left; border-top-width: 1px; border-top-style: hidden; border-top-color: #000000;"></td>
<td headers="Variable level" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: hidden; border-top-color: #000000; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;"></td>
<td headers="Estimate name" class="gt_row gt_left" style="text-align: left; border-left-width: 1px; border-left-style: solid; border-left-color: #D3D3D3; border-right-width: 1px; border-right-style: solid; border-right-color: #D3D3D3; border-top-width: 1px; border-top-style: solid; border-top-color: #D3D3D3; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: #D3D3D3;">max</td>
<td headers="[header_name]Database name
[header_level]Synthea synthetic health database" class="gt_row gt_right" style="text-align: right;">40,348</td></tr>
  </tbody>
  &#10;  
</table>
</div>

As seen, OmopSketch offers multiple functionalities to provide a general
overview of a database. Additionally, it includes more tools and
arguments that allow for deeper exploration, helping to assess the
database’s suitability for specific research studies. For further
information, please refer to the vignettes.
