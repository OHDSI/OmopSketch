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

#' Helper for consistent documentation of `interval`.
#'
#' @param interval Time interval to stratify by. It can either be "years", "quarters", "months" or "overall".
#'
#'
#' @name interval
#' @keywords internal
NULL

#' Helper for consistent documentation of `style`.
#'
#' @param style Defines the visual formatting of the table. This argument can be
#' provided in one of the following ways:
#' 1. **Pre-defined style**: Use the name of a built-in style (e.g., "darwin").
#' See `tableStyle()` for available options.
#' 2. **YAML file path**: Provide the path to an existing `.yml` file defining
#' a new style.
#' 3. **List of custome R code**: Supply a block of custom R code or a named
#' list describing styles for each table section. This code must be specific to
#' the selected table type.
#'
#' If `style = NULL`, the function will use global options (see
#' `setGlobalTableOptions()`) or an existing `⁠_brand.yml`⁠ file (if found);
#' otherwise, the default style is applied. For more details, see the Styles
#' vignette on the package website.
#'
#' @name style-table
#' @keywords internal
NULL


#' Helper for consistent documentation of `style`.
#'
#' @param style Visual theme to apply. Character, or `NULL`. If a character,
#' this may be either the name of a built-in style (see `plotStyle()`), or a
#' path to a `.yml` file that defines a custom style. If `NULL`, the function
#' will use the explicit default style, unless a global style option is set (see
#' `setGlobalPlotOptions()`), or a `⁠_brand.yml`⁠ file is present (in that order).
#' Refer to the package vignette on styles to learn more.
#'
#' @name style-plot
#' @keywords internal
NULL



#' Helper for consistent documentation of `sample`.
#'
#' @param sample Either an integer or a character string.
#'   If an integer (n > 0), the function will first sample `n` distinct
#'   `person_id`s from the `person` table and then subset the input tables to
#'   those subjects.
#'   If a character string, it must be the name of a cohort in the `cdm`; in
#'   this case, the input tables are subset to subjects (`subject_id`) belonging
#'   to that cohort.
#'   Use `NULL` to disable subsetting (default value).
#'
#'
#' @name sample
#' @keywords internal
NULL


