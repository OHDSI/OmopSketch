% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/tableMissingData.R
\name{tableMissingData}
\alias{tableMissingData}
\title{Create a visual table from a summariseMissingData() result.}
\usage{
tableMissingData(result, type = "gt")
}
\arguments{
\item{result}{A summarised_result object.}

\item{type}{Type of formatting output table. See \code{visOmopResults::tableType()} for allowed options. Default is \code{"gt"}.}
}
\value{
A formatted table object with the summarised data.
}
\description{
Create a visual table from a summariseMissingData() result.
}
\examples{
\donttest{
cdm <- mockOmopSketch(numberIndividuals = 100)

result <- summariseMissingData(cdm = cdm,
omopTableName = c("condition_occurrence", "visit_occurrence"))

tableMissingData(result = result)

PatientProfiles::mockDisconnect(cdm = cdm)
}
}
