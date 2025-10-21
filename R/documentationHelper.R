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


#' Helper for consistent documentation of `style`.
#'
#' @param style Which style to apply to the plot, options are: "default", "darwin"
#'  and NULL (default ggplot style). Customised styles can be achieved by modifying the returned ggplot object.
#'
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


