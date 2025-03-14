# Start
start_time <- Sys.time()
outputFolder <-  here::here("Results")

logfile <- file.path( paste0(outputFolder,
  "/log_", dbName, "_", format(Sys.time(), "%d_%m_%Y_%H_%M_%S"),".txt"
))

log_message <- function(message) {
  cat(paste(Sys.time(), "-", message, "\n"), file = logfile, append = TRUE)
  cli::cli_inform(paste(Sys.time(), "-", message, "\n"))
}

log_message("Start time recorded")

tableName <- c("observation_period", "visit_occurrence", "condition_occurrence", "drug_exposure", "procedure_occurrence",
               "device_exposure", "measurement" , "observation", "death")
sex <- TRUE # FALSE
ageGroup <- list(c(0, 59), c(60, Inf) )
ageGroup <- omopgenerics::validateAgeGroupArgument(ageGroup, ageGroupName = "")[[1]]
dateRange <- as.Date(c("2004-01-01", NA))

# Snapshot
log_message("Getting cdm snapshot")
snapshot <- OmopSketch::summariseOmopSnapshot(cdm)


# Summarise missing data
log_message("Summarising missing data")
result_missingData <- OmopSketch::summariseMissingData(cdm ,
                                                       omopTableName = tableName,
                                                       sex = sex,
                                                       ageGroup = ageGroup,
                                                       interval = "years",
                                                       dateRange = dateRange
                                                       )




# Summarise concept counts
log_message("Summarising concept id counts")
result_conceptIdCount <- OmopSketch::summariseConceptIdCounts(cdm,
                                                              omopTableName = tableName,
                                                              sex = sex,
                                                              ageGroup = ageGroup,
                                                              interval = "years",
                                                              dateRange = dateRange)

# Summarise clinical records
log_message("Summarising clinical records")
result_clinicalRecords<- OmopSketch::summariseClinicalRecords(cdm,
                                                  omopTableName = tableName,
                                                  sex = sex,
                                                  ageGroup = ageGroup,
                                                  dateRange = dateRange)

# Summarize record counts
log_message("Summarising record counts")
result_recordCounts <- OmopSketch::summariseRecordCount(cdm,  tableName,
                                                   sex = sex,
                                                   ageGroup = ageGroup,
                                                   interval = "years",
                                                   dateRange = dateRange)




# Summarize in observation records
log_message("Summarising in observation records and person-days")
result_inObservation <- OmopSketch::summariseInObservation(cdm$observation_period,
                                                           output = c("records","person-days"),
                                                           interval = "years",
                                                           sex = sex,
                                                           ageGroup = ageGroup,
                                                           dateRange = dateRange)




# Summarise observation period
log_message("Summarising observation period")
result_observationPeriod <- OmopSketch::summariseObservationPeriod(cdm$observation_period,
                                                                   sex = sex,
                                                                   ageGroup = ageGroup,
                                                                   dateRange = dateRange)

log_message("Summarising missing data - person table")

result_missingDataPerson <- OmopSketch::summariseMissingData(cdm,
                                                             omopTableName = "person")
# Combine results and export
result <- omopgenerics::bind(snapshot, result_missingData, result_conceptIdCount, result_clinicalRecords, result_recordCounts, result_inObservation, result_observationPeriod, result_missingDataPerson)|>
  dplyr::mutate(cdm_name = dbName)
omopgenerics::exportSummarisedResult(result, minCellCount = minCellCount, path = outputFolder, fileName = paste0(
  "result_characterisation_", dbName, ".csv"))



# Calculate duration and log
dur <- abs(as.numeric(Sys.time() - start_time, units = "secs"))
log_message(paste("Study code finished. Code ran in", floor(dur / 60), "min and", dur %% 60 %/% 1, "sec"))

# Close connection
CDMConnector::cdmDisconnect(cdm)
log_message("Database connection closed")



