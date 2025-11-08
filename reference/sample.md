# Helper for consistent documentation of `sample`.

Helper for consistent documentation of `sample`.

## Arguments

- sample:

  Either an integer or a character string. If an integer (n \> 0), the
  function will first sample `n` distinct `person_id`s from the `person`
  table and then subset the input tables to those subjects. If a
  character string, it must be the name of a cohort in the `cdm`; in
  this case, the input tables are subset to subjects (`subject_id`)
  belonging to that cohort. Use `NULL` to disable subsetting (default
  value).
