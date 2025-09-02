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
#' @param style Named list that specifies how to style the different parts of the gt or flextable table generated.
#' Accepted style entries are: title, subtitle, header, header_name, header_level, column_name, group_label, and body.
#' Alternatively, use "default" to get visOmopResults style, or NULL for gt/flextable style.
#' Keep in mind that styling code is different for gt and flextable. Additionally, "datatable" and "reactable" have their own style functions.
#' To see style options for each table type use `visOmopResults::tableStyle()`
#'
#'
#' @name style
#' @keywords internal
NULL
