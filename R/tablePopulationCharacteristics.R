tablePopulationCharacteristics <- function(summarisedPopulationCharacteristics){
  summarisedPopulationCharacteristics |>
    visOmopResults::visOmopTable(hide = c("cohort_name"),
                                 formatEstimateName = c("N%" = "<count> (<percentage>)",
                                                        "N" = "<count>",
                                                        "Mean (SD)" = "<mean> (<sd>)"),
                                 renameColumns = c("Database name" = "cdm_name"),
                                 header = c("cdm_name"),
                                 groupColumn = visOmopResults::strataColumns(summarisedPopulationCharacteristics))

}
