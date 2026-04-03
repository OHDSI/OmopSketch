
library(omopgenerics)
library(CDMConnector)
library(OmopSketch)
library(DBI)
library(here)

# database metadata and connection details
# The name/ acronym for the database
dbName <- "..."

# Database connection details
con <- dbConnect(...)

# The name of the schema that contains the OMOP CDM with patient-level data
cdmSchema <- "..."

# A prefix for all permanent tables in the database
writePrefix <- "..."

# The name of the schema where results tables will be created
writeSchema <- "..."

# minimum counts that can be displayed according to data governance
minCellCount <- 5

# Run analyses
source(here("article", "analyses.R"))
