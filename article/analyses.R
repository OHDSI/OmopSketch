
createLogFile(logFile = here("article", "results", "log_{date}_{time}.txt"))

logMessage("Create cdm object")
cdm <- cdmFromCon(
  con = con,
  cdmSchema = cdmSchema,
  writeSchema = writeSchema,
  writePrefix = writePrefix,
  cdmName = dbName
)

results <- list()

logMessage("Summarise person table")
results$person <- summarisePerson(cdm = cdm)

logMessage("Summarise observation period")
results$observation_period <- summariseObservationPeriod(
  cdm = cdm,
  byOrdinal = FALSE,
  ageGroup = list(c(0, 17), c(18, 64), c(65, Inf)),
  sex = TRUE
)

logMessage("Summarise drug exposure table")
results$drug_exposure <- summariseClinicalRecords(
  cdm = cdm,
  omopTableName = "drug_exposure"
)

logMessage("Summarise median age trend")
results$trend <- summariseTrend(
  cdm = cdm,
  event = c("drug_exposure", "condition_occurrence", "measurement"),
  episode = "observation_period",
  interval = "years",
  dateRange = as.Date(c("2010-01-01", "2024-12-31")),
  output = "age"
)

logMessage("Bind results")
results <- bind(results)

exportSummarisedResult(
  results,
  minCellCount = minCellCount,
  path = here("article", "results")
)
