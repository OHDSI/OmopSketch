# Argument descriptions repeated > 1:

#' Helper for consistent documentation of `dateRange`.
#'
#' @param dateRange A vector of two dates defining the desired study period.
#' Only the `start_date` column of the OMOP table is checked to ensure it falls within this range.
#' If `dateRange` is `NULL`, no restriction is applied.
#'
#'
#' @name dateRange-startDate
#' @keywords internal
NULL

#' Helper for consistent documentation of table arguments.
#'
#' @param type Character string specifying the desired output table format. See
#' `visOmopResults::tableType()` for supported table types. If `type = NULL`,
#' global options (set via `visOmopResults::setGlobalTableOptions()`) will be
#' used if available; otherwise, a default 'gt' table is created.
#'
#' @param style Defines the visual formatting of the table. This argument can be
#' provided in one of the following ways:
#' 1. **Pre-defined style**: Use the name of a built-in style (e.g., "darwin").
#' See `visOmopResults::tableStyle()` for available options.
#' 2. **YAML file path**: Provide the path to an existing .yml file defining
#' a new style.
#' 3. **List of custome R code**: Supply a block of custom R code or a named
#' list describing styles for each table section. This code must be specific to
#' the selected table type.
#'
#' If `style = NULL`, the function will use global options
#' (see`visOmopResults::setGlobalTableOptions()`) or a _brand.yml file
#' (if found); otherwise, the default style is applied.
#'
#' @name style-table
#' @keywords internal
NULL


#' Helper for consistent documentation for plots.
#'
#' @param style Visual theme to apply. Character, or `NULL`. If a character,
#' this may be either the name of a built-in style (see
#' `visOmopResults::plotStyle()`), or a path to a .yml file that defines a
#' custom style. If `NULL`, the function will use the explicit default style,
#' unless a global style option is set (see `visOmopResults::setGlobalPlotOptions()`)
#' or a _brand.yml file is present (in that order).
#' @param type Character string indicating the output plot format. See
#' `visOmopResults::plotType()` for the list of supported plot types. If
#' `type = NULL`, the function will use the global setting defined via
#' `visOmopResults::setGlobalPlotOptions()` (if available); otherwise, a
#' standard `ggplot2` plot is produced by default.
#'
#' @name plot-doc
#' @keywords internal
NULL

#' Helper for consistent documentation
#'
#' @param cdm A `cdm_reference` object. Use *CDMConnector* to create a reference
#' to a database or *omock* to create a reference to synthetic data.
#' @param omopTableName A character vector of the names of the tables to
#' summarise in the cdm object. Run `clinicalTables()` to check the
#' available options.
#' @param ageGroup A list of age groups to stratify the results by. Each element
#' represents a specific age range. You can give them specific names, e.g.
#' `ageGroup = list(children = c(0, 17), adult = c(18, Inf))`.
#' @param sex Logical; whether to stratify results by sex (`TRUE`) or not
#' (`FALSE`).
#' @param facet Columns to face by. Formula format can be provided. See possible
#' columns to face by with: `visOmopResults::tidyColumns()`.
#' @param colour Columns to colour by. See possible columns to colour by with:
#' `visOmopResults::tidyColumns()`.
#' @param interval Time interval to stratify by. It can either be "years",
#' "quarters", "months" or "overall".
#' @param sample Either an integer or a character string.
#' -  If an integer (n > 0), the function will first sample `n` distinct
#' `person_id`s from the `person` table and then subset the input tables to
#' those subjects.
#' - If a character string, it must be the name of a cohort in the `cdm`; in
#' this case, the input tables are subset to subjects (`subject_id`) belonging
#' to that cohort.
#' - Use `NULL` to disable subsetting (default value).
#'
#' @name consistent-doc
#' @keywords internal
NULL


