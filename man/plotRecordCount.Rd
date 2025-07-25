% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plotRecordCount.R
\name{plotRecordCount}
\alias{plotRecordCount}
\title{Create a ggplot of the records' count trend.}
\usage{
plotRecordCount(result, facet = NULL, colour = NULL)
}
\arguments{
\item{result}{Output from summariseRecordCount().}

\item{facet}{Columns to face by. Formula format can be provided. See possible
columns to face by with: \code{visOmopResults::tidyColumns()}.}

\item{colour}{Columns to colour by. See possible columns to colour by with:
\code{visOmopResults::tidyColumns()}.}
}
\value{
A ggplot showing the table counts
}
\description{
Create a ggplot of the records' count trend.
}
\examples{
\donttest{
cdm <- mockOmopSketch()

summarisedResult <- summariseRecordCount(
  cdm = cdm,
  omopTableName = "condition_occurrence",
  ageGroup = list("<=20" = c(0, 20), ">20" = c(21, Inf)),
  sex = TRUE
)

plotRecordCount(result = summarisedResult, colour = "age_group", facet = sex ~ .)

PatientProfiles::mockDisconnect(cdm = cdm)
}
}
