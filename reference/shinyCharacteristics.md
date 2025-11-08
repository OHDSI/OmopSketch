# Generate an interactive Shiny application that visualises the results obtained from the `databaseCharacteristics()` function.

Generate an interactive Shiny application that visualises the results
obtained from the
[`databaseCharacteristics()`](https://OHDSI.github.io/OmopSketch/reference/databaseCharacteristics.md)
function.

## Usage

``` r
shinyCharacteristics(
  result,
  directory,
  background = TRUE,
  title = "Database characterisation",
  logo = "ohdsi",
  theme = NULL
)
```

## Arguments

- result:

  A summarised_result object containing the results from the
  [`databaseCharacteristics()`](https://OHDSI.github.io/OmopSketch/reference/databaseCharacteristics.md)
  function. This object should include summaries of various OMOP CDM
  tables, such as population characteristics, clinical records, missing
  data, and more

- directory:

  A character string specifying the directory where the application will
  be saved.

- background:

  Background panel for the Shiny app. If set to `TRUE` (default), a
  standard background panel with a general description will be included.
  If set to `FALSE`, no background panel will be displayed.
  Alternatively, you can provide a file path (e.g., `"path/to/file.md"`)
  to include custom background content from a Markdown file.

- title:

  Title of the shiny. Default is "Characterisation"

- logo:

  Name of a logo or path to a logo. If NULL no logo is included. Only
  svg format allowed for the moment.

- theme:

  A character string specifying the theme for the Shiny application.
  Default is `"bslib::bs_theme(bootswatch = 'flatly')"` to use the
  Flatly theme from the Bootswatch collection. You can customise this to
  use other themes.

## Value

This function invisibly returns NULL and generates a static Shiny app in
the specified directory.

## Examples

``` r
if (FALSE) { # \dontrun{
library(OmopSketch)

cdm <- mockOmopSketch()
res <- databaseCharacteristics(cdm = cdm)
shinyCharacteristics(result = res, directory = here::here())
} # }
```
