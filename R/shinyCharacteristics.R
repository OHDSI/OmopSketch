#' Generate an interactive Shiny application that visualises the results obtained from the `databaseCharacteristics()` function.
#' @param result A summarised_result object containing the results from the `databaseCharacteristics()` function.
#' This object should include summaries of various OMOP CDM tables, such as population characteristics, clinical records, missing data, and more
#' @param directory A character string specifying the directory where the application
#'                  will be saved.
#' @param title Title of the shiny. Default is "Characterisation"
#' @param background Background panel for the Shiny app.
#' If set to `TRUE` (default), a standard background panel with a general description will be included.
#' If set to `FALSE`, no background panel will be displayed.
#' Alternatively, you can provide a file path (e.g., `"path/to/file.md"`) to include custom background content from a Markdown file.
#' @param logo Name of a logo or path to a logo. If NULL no logo is included. Only svg format allowed for the moment.
#'
#' @param theme A character string specifying the theme for the Shiny application.
#'              Default is `"bslib::bs_theme(bootswatch = 'flatly')"` to use the Flatly theme
#'              from the Bootswatch collection. You can customise this to use other themes.
#'
#'
#' @return This function invisibly returns NULL and generates a static Shiny app in the
#'         specified directory.
#'
#' @examples
#' \dontrun{
#'
#' library(OmopSketch)
#' cdm <- mockOmopSketch()
#' res <- databaseCharacteristics(cdm = cdm)
#' shinyCharacteristics(result = res, directory = here::here())
#' }
#'
#' @export
shinyCharacteristics <- function(result,
                                 directory,
                                 background = TRUE,
                                 title = "Database characterisation",
                                 logo = "ohdsi",
                                 theme = NULL) {
  rlang::check_installed(pkg = "OmopViewer", version = "0.4.0")

  omopgenerics::validateResultArgument(result)
  omopgenerics::assertCharacter(directory, length = 1)
  omopgenerics::assertCharacter(logo, length = 1, null = TRUE)
  omopgenerics::assertCharacter(theme, length = 1, null = TRUE)
  validateBackground(background)

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
      while(!x %in% c("y", "n")) {
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
    "summarise_observation_period", "summarise_in_observation",
    "summarise_missing_data", "summarise_table_quality",
    "summarise_clinical_records", "summarise_concept_id_counts",
    "summarise_record_count"
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

  if ("summarise_omop_snapshot" %in% resultTypes) {
    # customise summarise_omop_snapshot
    panelDetails$summarise_omop_snapshot$icon <- "camera"
    panelDetails$summarise_omop_snapshot$content$tidy <- NULL
  }

  if ("summarise_observation_period" %in% resultTypes) {
    # customise summarise_observation_period
    panelDetails$summarise_observation_period$icon <- NULL
    panelDetails$summarise_observation_period$content$tidy <- NULL
    panelDetails$summarise_observation_period$content$plot$filters$variable$choices <- c("Number subjects", "Records per person", "Duration in days", "Days to next observation period")
    panelDetails$summarise_observation_period$content$plot$filters$variable$selected <- "Number subjects"
    panelDetails$summarise_observation_period$content$plot$filters$variable$label <- "Variable"
  }

  if ("summarise_clinical_records" %in% resultTypes) {
    # customise summarise_clinical_records
    panelDetails$summarise_clinical_records$icon <- NULL
    panelDetails$summarise_clinical_records$content$table$reactive <- "<filtered_data> |>
    dplyr::filter(!(grepl('na',.data$estimate_name) | grepl('zero',.data$estimate_name))) |>
    OmopSketch::tableClinicalRecords()"
    panelDetails$summarise_clinical_records$content$tableMissing <- panelDetails$summarise_clinical_records$content$table
    panelDetails$summarise_clinical_records$content$tableMissing$title <- "Table Missing Data"
    panelDetails$summarise_clinical_records$content$tableMissing$reactive <- "<filtered_data> |>
    OmopSketch::tableMissingData()"
    panelDetails$summarise_clinical_records$content$tableMissing$download$filename <- "paste0(\"table_missing_data_clinical_tables.\", input$format)"
  }

  if ("summarise_record_count" %in% resultTypes) {
    # customise summarise_record_count
    panelDetails$summarise_record_count$icon <- NULL
  }

  if ("summarise_missing_data" %in% resultTypes) {
    # customise summarise_missing_data
    panelDetails$summarise_missing_data$icon <- NULL

  }

  if ("summarise_table_quality" %in% resultTypes) {
    # customise summarise_table_quality
    panelDetails$summarise_table_quality$icon <- NULL
  }

  if ("summarise_characteristics" %in% resultTypes) {
    # customise summarise_characteristics
    variable_names <- result |>
      omopgenerics::filterSettings(.data$result_type == "summarise_characteristics") |>
      dplyr::distinct(.data$variable_name) |>
      dplyr::pull()
    panelDetails$summarise_characteristics$content$tidy <- NULL
    panelDetails$summarise_characteristics$title <- "Population Characteristics"
    panelDetails$summarise_characteristics$content$plot$reactive <- "<filtered_data> |>
    dplyr::filter(.data$variable_name == input$variable) |>
    CohortCharacteristics::plotCharacteristics(
      plotType = input$plot_type,
      facet = input$facet,
      colour = input$colour
    )"
    panelDetails$summarise_characteristics$content$plot$filters$variable <- list(
      button_type = "pickerInput",
      label = "Variable",
      choices = variable_names,
      selected = "Number subjects",
      multiple = FALSE
    )
    panelDetails$summarise_characteristics$content$plot$filters$plot_type$selected <- "barplot"
  }

  if ("summarise_in_observation" %in% resultTypes) {
    # customise summarise_in_observation
    variable_names <- result |>
      omopgenerics::filterSettings(.data$result_type == "summarise_in_observation") |>
      dplyr::distinct(.data$variable_name) |>
      dplyr::pull()
    panelDetails$summarise_in_observation$content$plot$render <- "<filtered_data> |>
    dplyr::filter(.data$variable_name == input$variable) |>
    OmopSketch::plotInObservation(
      facet = input$facet,
      colour = input$colour
    )"
    panelDetails$summarise_in_observation$content$plot$filters$variable <- list(
      button_type = "pickerInput",
      label = "Variable",
      choices = variable_names,
      selected = "Number records in observation",
      multiple = FALSE
    )
    panelDetails$summarise_in_observation$icon <- NULL
  }

  if ("summarise_concept_id_counts" %in% resultTypes) {
    # customise summarise_concept_id_counts
    panelDetails$summarise_concept_id_counts$content$tidy$filters$columns$choices <- c("cdm_name", "<group>", "<strata>", "<additional>", "<settings>")
    panelDetails$summarise_concept_id_counts$content$tidy$filters$columns$selected <- c("cdm_name", "<group>", "<strata>")
    panelDetails$summarise_concept_id_counts$content$formatted <- NULL
  }

  # define structure
  panelStructure <- list(
    "summarise_omop_snapshot",
    "summarise_characteristics",
    "Observation Period" = c("summarise_in_observation", "summarise_observation_period"),
    "Quality" = c("summarise_missing_data", "summarise_table_quality"),
    "Clinical Tables" = c("summarise_clinical_records", "summarise_record_count"),
    "summarise_concept_id_counts"
  ) |>
    # keep only the present result types
    purrr::map(\(x) x[x %in% resultTypes]) |>
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
    "- **Observation Period**: Distribution and length of observation periods, based on [`summariseObservationPeriod()`](https://ohdsi.github.io/OmopSketch/reference/summariseObservationPeriod.html).",
    "- **In Observation**: Yearly counts of individuals in observation, generated from [`summariseInObservation()`](https://ohdsi.github.io/OmopSketch/reference/summariseInObservation.html).",
    "- **Clinical Records**: Summary of clinical tables focused on vocabulary usage and quality checks, from [`summariseClinicalRecords()`](https://ohdsi.github.io/OmopSketch/reference/summariseClinicalRecords.html).",
    "- **Record Count**: Annual record counts for selected OMOP tables, using [`summariseRecordCount()`](https://ohdsi.github.io/OmopSketch/reference/summariseRecordCount.html).",
    "- **Missing Data**: Overview of missing values and zero IDs in OMOP tables, based on [`summariseMissingData()`](https://ohdsi.github.io/OmopSketch/reference/summariseMissingData.html).",
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
