% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/shinyCharacteristics.R
\name{shinyCharacteristics}
\alias{shinyCharacteristics}
\title{Generate an interactive Shiny application that visualises the results obtained from the \code{databaseCharacteristics()} function.}
\usage{
shinyCharacteristics(
  result,
  directory,
  background = TRUE,
  title = "Database characterisation",
  logo = "ohdsi",
  theme = NULL
)
}
\arguments{
\item{result}{A summarised_result object containing the results from the \code{databaseCharacteristics()} function.
This object should include summaries of various OMOP CDM tables, such as population characteristics, clinical records, missing data, and more}

\item{directory}{A character string specifying the directory where the application
will be saved.}

\item{background}{Background panel for the Shiny app.
If set to \code{TRUE} (default), a standard background panel with a general description will be included.
If set to \code{FALSE}, no background panel will be displayed.
Alternatively, you can provide a file path (e.g., \code{"path/to/file.md"}) to include custom background content from a Markdown file.}

\item{title}{Title of the shiny. Default is "Characterisation"}

\item{logo}{Name of a logo or path to a logo. If NULL no logo is included. Only svg format allowed for the moment.}

\item{theme}{A character string specifying the theme for the Shiny application.
Default is \code{"bslib::bs_theme(bootswatch = 'flatly')"} to use the Flatly theme
from the Bootswatch collection. You can customise this to use other themes.}
}
\value{
This function invisibly returns NULL and generates a static Shiny app in the
specified directory.
}
\description{
Generate an interactive Shiny application that visualises the results obtained from the \code{databaseCharacteristics()} function.
}
\examples{
\dontrun{

library(OmopSketch)
cdm <- mockOmopSketch()
res <- databaseCharacteristics(cdm = cdm)
shinyCharacteristics(result = res, directory = here::here())
}

}
