#' Generate an interactive Shiny application that visualises the results obtained from the `databaseCharacteristics()` function.
#' @param result A summarised_result object containing the results from the `databaseCharacteristics()` function.
#' This object should include summaries of various OMOP CDM tables, such as population characteristics, clinical records, missing data, and more
#' @param directory A character string specifying the directory where the application
#'                  will be saved.
#' @param title Title of the shiny. Default is "Characterisation"
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
shinyCharacteristics <- function(result, directory, title = "Database characterisation", logo = "ohdsi", theme = "bslib::bs_theme(bootswatch = 'flatly')") {

  rlang::check_installed("OmopViewer")

  omopgenerics::validateResultArgument(result)
  omopgenerics::assertCharacter(directory, length = 1)
  omopgenerics::assertCharacter(logo, length = 1, null = TRUE)
  omopgenerics::assertCharacter(theme, length = 1, null = TRUE)

  result_types <- c("summarise_omop_snapshot", "summarise_characteristics", "summarise_observation_period", "summarise_in_observation", "summarise_missing_data", "summarise_table_quality", "summarise_clinical_records", "summarise_concept_id_counts", "summarise_record_count")

  # subset to result_type of interest
  result <- result |>
    omopgenerics::filterSettings(
      .data$result_type %in% .env$result_types
    )

  # check if it is empty
  if (nrow(result) == 0) {
    warnEmpty(result_types)
    return(emptyPlot())
  }

  conceptIdCounts <- "summarise_concept_id_counts" %in% dplyr::pull(omopgenerics::settings(result), "result_type")

  panelDetails <- OmopViewer::panelDetailsFromResult(result = result)

  panelDetails$summarise_omop_snapshot$icon <- "camera"
  panelDetails$summarise_omop_snapshot$content$tidy <- NULL

  panelDetails$summarise_observation_period$icon <- NULL
  panelDetails$summarise_observation_period$content$tidy <- NULL

  variable_names <- result |>
    omopgenerics::filterSettings(.data$result_type == "summarise_observation_period") |>
    dplyr::distinct(.data$variable_name) |>
    dplyr::pull()

  panelDetails$summarise_observation_period$content$plot$filters$variable$choices <- c("Number subjects", "Records per person", "Duration in days", "Days to next observation period")
  panelDetails$summarise_observation_period$content$plot$filters$variable$selected <- "Number subjects"
  panelDetails$summarise_observation_period$content$plot$filters$variable$label <- "Variable"

  panelDetails$summarise_clinical_records$icon <- NULL
  panelDetails$summarise_record_count$icon <- NULL
  panelDetails$summarise_missing_data$icon <- NULL
  panelDetails$summarise_table_quality$icon <- NULL
  panelDetails$summarise_in_observation$icon <- NULL
  panelDetails$summarise_characteristics$content$tidy <- NULL
  panelDetails$summarise_characteristics$title <- "Population Characteristics"

  variable_names <- result |>
    omopgenerics::filterSettings(.data$result_type == "summarise_characteristics") |>
    dplyr::distinct(.data$variable_name) |>
    dplyr::pull()

  panelDetails$summarise_characteristics$content$plot$render <- "<filtered_data> |>\n dplyr::filter(.data$variable_name == input$variable) |> \n    CohortCharacteristics::plotCharacteristics(\n      plotType = input$plot_type,\n      facet = input$facet,\n      colour = input$colour\n      )"
  panelDetails$summarise_characteristics$content$plot$filters$variable <- list(button_type = "pickerInput", label = "Variable", choices = variable_names, selected = "Number subjects", multiple = FALSE)
  panelDetails$summarise_characteristics$content$plot$filters$plot_type$selected <- "barplot"


  variable_names <- result |>
    omopgenerics::filterSettings(.data$result_type == "summarise_in_observation") |>
    dplyr::distinct(.data$variable_name) |>
    dplyr::pull()

  panelDetails$summarise_in_observation$content$plot$render <- "<filtered_data> |>\n dplyr::filter(.data$variable_name == input$variable) |> \n OmopSketch::plotInObservation(\n facet = input$facet,\n  colour = input$colour\n )"
  panelDetails$summarise_in_observation$content$plot$filters$variable <- list(button_type = "pickerInput", label = "Variable", choices = variable_names, selected = "Number records in observation", multiple = FALSE)


  if (conceptIdCounts) {
    panelDetails$summarise_concept_id_counts$content$tidy$filters$columns$choices <- c("cdm_name", "<group>", "<strata>", "<additional>", "<settings>")
    panelDetails$summarise_concept_id_counts$content$tidy$filters$columns$selected <- c("cdm_name", "<group>", "<strata>")
    panelDetails$summarise_concept_id_counts$content$formatted <- NULL
  }


  panelStructure <- list("summarise_omop_snapshot", "summarise_characteristics",
                         "Observation Period" = c("summarise_in_observation", "summarise_observation_period"),
                         "Quality" = c("summarise_missing_data", "summarise_table_quality"),
                         "Clinical Tables" = c("summarise_clinical_records", "summarise_record_count"), "summarise_concept_id_counts"[conceptIdCounts]
  )

  OmopViewer::exportStaticApp(
    result = result,
    directory = directory,
    logo = logo,
    title = title,
    background = TRUE,
    summary = FALSE,
    panelDetails = panelDetails,
    panelStructure = panelStructure,
    theme = theme,
    open = rlang::is_interactive()
  )
  return(invisible())
}

