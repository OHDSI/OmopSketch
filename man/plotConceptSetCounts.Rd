% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plotConceptSetCounts.R
\name{plotConceptSetCounts}
\alias{plotConceptSetCounts}
\title{Plot the concept counts of a summariseConceptSetCounts output.}
\usage{
plotConceptSetCounts(result, facet = NULL, colour = NULL)
}
\arguments{
\item{result}{A summarised_result object (output of summariseConceptSetCounts).}

\item{facet}{Columns to face by. Formula format can be provided. See possible
columns to face by with: \code{visOmopResults::tidyColumns()}.}

\item{colour}{Columns to colour by. See possible columns to colour by with:
\code{visOmopResults::tidyColumns()}.}
}
\value{
A ggplot2 object showing the concept counts.
}
\description{
Plot the concept counts of a summariseConceptSetCounts output.
}
\examples{
\donttest{
library(dplyr)

cdm <- mockOmopSketch()

result <- cdm |>
  summariseConceptSetCounts(
    conceptSet = list(
      "Renal agenesis" = 194152,
      "Manic mood" = c(4226696, 4304866, 37110496, 40371897)
    )
  )

result |>
  filter(variable_name == "Number subjects") |>
  plotConceptSetCounts(facet = "codelist_name", colour = "standard_concept_name")

PatientProfiles::mockDisconnect(cdm)
}
}
