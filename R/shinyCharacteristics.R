
#' Generate an interactive Shiny application that visualises the results
#' obtained from the `databaseCharacteristics()` function
#'
#' @param result A summarised_result object (output of
#' `databaseCharacteristics()`).
#' @param directory A character string specifying the directory where the
#' application will be saved.
#' @param title Title of the shiny. Default is "Characterisation".
#' @param background Background panel for the Shiny app.
#' - If set to `TRUE` (default), a standard background panel with a general
#' description will be included.
#' - If set to `FALSE`, no background panel will be displayed.
#' - If it is a path (e.g., `"path/to/file.md"`) tha file will be used as
#' background panel of your shiny App.
#' @param logo Name of a logo or path to a logo. If NULL no logo is included.
#' Only svg format allowed for the moment.
#' @param theme A character string specifying the theme for the Shiny
#' application. It can be any of the OmopViewer supported themes.
#'
#' @return This function invisibly returns NULL and generates a static Shiny app
#' in the specified directory.
#' @export
#'
#' @examples
#' \dontrun{
#' library(OmopSketch)
#' library(omock)
#' library(here)
#'
#' cdm <- mockCdmFromDataset(datasetName = "GiBleed", source = "duckdb")
#'
#' res <- databaseCharacteristics(cdm = cdm)
#'
#' shinyCharacteristics(result = res, directory = here())
#'
#' cdmDisconnect(cdm = cdm)
#' }
#'
shinyCharacteristics <- function(result,
                                 directory,
                                 background = TRUE,
                                 title = "Database characterisation",
                                 logo = "ohdsi",
                                 theme = NULL) {
  rlang::check_installed(pkg = "OmopViewer", version = "0.5.0") # change to 0.5.0 when released

  result <- omopgenerics::validateResultArgument(result)
  omopgenerics::assertCharacter(directory, length = 1)
  omopgenerics::assertCharacter(logo, length = 1, null = TRUE)
  omopgenerics::assertCharacter(theme, length = 1, null = TRUE)
  background <- validateBackground(background)

  if (is.null(theme)){
    theme <- system.file("brand", "scarlet.yml", package = "OmopSketch")
  }

  # check directory
  correct <- function(x) {
    x <- tolower(x)
    x[x == "yes"] <- "y"
    x[x == "no"] <- "n"
    x
  }
  directory <- file.path(directory, "OmopSketchShiny")
  if (dir.exists(directory)) {
    if (rlang::is_interactive()) {
      cli::cli_inform(c("!" = "directory already exists: {.path {directory}}"))
      msg <- c(i = "Do you want to overwrite it? Y/n")
      cli::cli_inform(message = msg)
      x <- correct(readline())
      while (!x %in% c("y", "n")) {
        cli::cli_inform(message = c("!" = "Please answer 'yes' or 'no'.", msg))
        x <- correct(readline())
      }
      if (x == "n") {
        cli::cli_abort(c(x = "Shiny is not created as it already exists"))
      }
      cli::cli_inform(c("!" = "Deleting prior existing directory: {.path {directory}}"))
    } else {
      cli::cli_warn(c("!" = "Deleting prior existing directory: {.path {directory}}"))
    }
    unlink(x = directory, recursive = TRUE)
  }
  dir.create(path = directory)

  # create background if needed
  if (isTRUE(background)) {
    background <- tempfile(fileext = ".md")
    writeLines(text = createOmopSketchBackground(), con = background)
    deleteBackground <- TRUE
  } else {
    deleteBackground <- FALSE
  }

  # result types of interest
  result_types <- c(
    "summarise_omop_snapshot", "summarise_characteristics",
    "summarise_person",
    "summarise_observation_period", "summarise_trend",
    "summarise_clinical_records", "summarise_concept_id_counts"
  )

  # subset to result_type of interest
  result <- result |>
    omopgenerics::filterSettings(
      .data$result_type %in% .env$result_types
    )

  # message if empty
  if (nrow(result) == 0) {
    cli::cli_inform(c("!" = "No results provided, shiny will be empty."))
  }

  # get current resultTypes
  resultTypes <- unique(omopgenerics::settings(result)$result_type)

  # default panelDetails
  panelDetails <- OmopViewer::panelDetailsFromResult(result = result)



  if ("summarise_observation_period" %in% resultTypes) {
    # customise summarise_observation_period
    panelDetails$summarise_observation_period$icon <- NULL
    panelDetails$summarise_observation_period$content$table$reactive <- "<filtered_data> |>
    dplyr::filter(!(grepl('na',.data$estimate_name) | grepl('zero',.data$estimate_name))) |>
    OmopSketch::tableObservationPeriod()"
    panelDetails$summarise_observation_period$content$tableMissing <- panelDetails$summarise_observation_period$content$table
    panelDetails$summarise_observation_period$content$tableMissing$title <- "Table Missing Data"
    panelDetails$summarise_observation_period$content$tableMissing$reactive <- "<filtered_data> |>
    OmopSketch::tableMissingData()"
    panelDetails$summarise_observation_period$content$tableMissing$download$filename <- "paste0(\"table_missing_data_observation_period.\", input$format)"
  }

  if ("summarise_clinical_records" %in% resultTypes) {
    # customise summarise_clinical_records
    panelDetails$summarise_clinical_records$icon <- NULL
    panelDetails$summarise_clinical_records$title <- "Clinical Tables Summary"
    panelDetails$summarise_clinical_records$content$table$reactive <- "<filtered_data> |>
    dplyr::filter(!(grepl('na',.data$estimate_name) | grepl('zero',.data$estimate_name))) |>
    OmopSketch::tableClinicalRecords()"
    panelDetails$summarise_clinical_records$content$tableMissing <- panelDetails$summarise_clinical_records$content$table
    panelDetails$summarise_clinical_records$content$tableMissing$title <- "Table Missing Data"
    panelDetails$summarise_clinical_records$content$tableMissing$reactive <- "<filtered_data> |>
    OmopSketch::tableMissingData()"
    panelDetails$summarise_clinical_records$content$tableMissing$download$filename <- "paste0(\"table_missing_data_clinical_records.\", input$format)"

  }

  if ("summarise_characteristics" %in% resultTypes) {

    panelDetails$summarise_characteristics$title <- "Population Characteristics"

  }

  if ("summarise_trend" %in% resultTypes) {
    panelDetails$summarise_trend_episode <- panelDetails$summarise_trend
    panelDetails$summarise_trend_episode$icon <- NULL
    panelDetails$summarise_trend_episode$title <- "Observation Period Trends"
    panelDetails$summarise_trend_episode$data$type <- "episode"

    panelDetails$summarise_trend_episode$content$plot$reactive <- "<filtered_data> |>
    OmopSketch::plotTrend(
      facet = input$facet,
      colour = input$colour
    )"

    panelDetails$summarise_trend_event <- panelDetails$summarise_trend
    panelDetails$summarise_trend_event$icon <- NULL
    panelDetails$summarise_trend_event$title <- "Clinical Tables Trends"
    panelDetails$summarise_trend_event$data$type <- "event"


    panelDetails$summarise_trend_event$content$plot$reactive <- "<filtered_data> |>
    OmopSketch::plotTrend(
      facet = input$facet,
      colour = input$colour
    )"

    panelDetails$summarise_trend <- NULL

  }

  # define structure
  panelStructure <- list(
    "summarise_omop_snapshot",
    "summarise_characteristics",
    "summarise_person",
    "Observation Period" = c("summarise_observation_period", "summarise_trend_episode"),
    "Clinical Tables" = c("summarise_clinical_records", "summarise_trend_event"),
    "summarise_concept_id_counts"
  ) |>
    # keep only the present result types
    purrr::map(\(x) x[x %in% names(panelDetails)]) |>
    purrr::compact()

  # temporary folder
  tmpDir <- file.path(tempdir(), "omopviewer_test")
  if (dir.exists(tmpDir)) {
    unlink(x = tmpDir, recursive = TRUE)
  }
  dir.create(path = tmpDir)

  # create temporary shiny
  cli::cli_inform(c("i" = "Creating shiny from provided results."))
  OmopViewer::exportStaticApp(
    result = result,
    directory = tmpDir,
    logo = logo,
    title = title,
    background = background,
    summary = FALSE,
    panelDetails = panelDetails,
    panelStructure = panelStructure,
    theme = theme,
    open = FALSE
  ) |>
    suppressMessages()

  # move shiny
  moveDirectory(from = file.path(tmpDir, "shiny"), to = directory)

  if (deleteBackground) {
    file.remove(background)
  }

  if (rlang::is_interactive()) {
    cli::cli_inform(c(i = "Launching shiny"))
    usethis::proj_activate(path = directory)
  }

  return(invisible())
}
createOmopSketchBackground <- function() {
  c(
    "## OmopSketch Database Characterisation",
    "-----",
    "### Shiny App Overview",
    "",
    "This Shiny App presents the results of a database characterisation performed using the [**OmopSketch**](https://cran.r-project.org/package=OmopSketch) R package. It provides summaries and visualisations to support exploration of OMOP CDM-compliant datasets.",
    "",
    "The app includes the following components:",
    "",
    "- **Snapshot**: Metadata extracted from the `cdm_source` table, using the output of [`summariseOmopSnapshot()`](https://ohdsi.github.io/OmopSketch/reference/summariseOmopSnapshot.html).",
    "- **Population Characteristics**: Summary of the demographics of the population in observation, generated using [**CohortConstructor**](https://ohdsi.github.io/CohortConstructor/) and [**CohortCharacteristics**](https://darwin-eu.github.io/CohortCharacteristics/).",
    "- **Person**: Summary of person table, from [`summarisePerson()`]()",
    "- **Observation Period**: Distribution and length of observation periods, based on [`summariseObservationPeriod()`](https://ohdsi.github.io/OmopSketch/reference/summariseObservationPeriod.html).",
    "- **Trends**: Temporal trends of individuals and records in observation, including changes in median age, proportion of females, and number of person-days, generated from [`summariseTrend()`](https://ohdsi.github.io/OmopSketch/reference/summariseTrend.html).",
    "- **Clinical Records**: Summary of clinical tables focused on vocabulary usage and quality checks, from [`summariseClinicalRecords()`](https://ohdsi.github.io/OmopSketch/reference/summariseClinicalRecords.html).",
    "- **Concept Counts** *(optional)*: Counts of `concept_id`s across tables, generated by [`summariseConceptIdCounts()`](https://ohdsi.github.io/OmopSketch/reference/summariseConceptIdCounts.html)."
  )
}
moveDirectory <- function(from, to) {
  files <- list.files(path = from, full.names = TRUE, recursive = TRUE)
  newFiles <- files |>
    purrr::map_chr(\(x) {
      nm <- stringr::str_replace(
        string = x,
        pattern = paste0("^", from),
        replacement = to
      )
      dir <- dirname(nm)
      if (!dir.exists(dir)) {
        dir.create(path = dir)
      }
      nm
    })
  file.copy(from = files, to = newFiles)
  unlink(x = from, recursive = TRUE)
}
