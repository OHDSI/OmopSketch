
#' Visualise the output of `summarisePerson()`
#'
#' @param result A summarised_result object (output of `summarisePerson()`).
#' @param variableName The variable to plot, a choice between
#' `unique(result$variable_name)`. If `NULL` it will only work if only one
#' variable is present in the result object.
#' @inheritParams plot-doc
#'
#' @return A plot visualisation.
#' @export
#'
#' @examples
#' \donttest{
#' library(OmopSketch)
#' library(dplyr, warn.conflicts = FALSE)
#' library(omock)
#'
#' cdm <- mockCdmFromDataset(datasetName = "GiBleed", source = "duckdb")
#'
#' result <- summarisePerson(cdm = cdm)
#'
#' tablePerson(result = result)
#'
#' cdmDisconnect(cdm = cdm)
#' }
#'
plotPerson <- function(result,
                       variableName = NULL,
                       style = NULL,
                       type = NULL) {
  # check input
  style <- validateStyle(style = style, obj = "plot")
  omopgenerics::assertChoice(type, choices = visOmopResults::plotType(), length = 1, null = TRUE)

  result <- validateResult(
    result = result,
    resultType = "summarise_person",
    variableName = variableName %||% TRUE
  )
  if (is.character(result)) {
    return(visOmopResults::emptyPlot(subtitle = "`result` does not contain any `summarise_person` data.", type = type, style = style))
  }

  # variable name
  variableName <- unique(result$variable_name)
  opts <- plotPersonOpts()
  if (!variableName %in% opts$variable_name) {
    mes <- paste0(
      "variableName must be a choice between: `",
      paste0(opts$variable_name, collapse = "`, `"),
      "`."
    )
    return(visOmopResults::emptyPlot(subtitle = mes, type = type, style = style))
  }
  pt <- opts$plot_type[opts$variable_name == variableName]

  if (pt == "barPlot") {
    if (all(is.na(result$variable_level))) {
      colour <- "variable_name"
    } else {
      colour <- "variable_level"
    }
    if ("percentage" %in% unique(result$estimate_name)) {
      y <- "percentage"
    } else {
      y <- "count"
    }
    p <- visOmopResults::barPlot(
      result = result,
      x = "cdm_name",
      y = y,
      position = "stack",
      style = style,
      type = type,
      colour = colour
    )
  } else {
    p <- visOmopResults::boxPlot(
      result = result,
      x = "cdm_name",
      colour = "cdm_name",
      style = style,
      type = type
    )
  }

  return(p)
}

plotPersonOpts <- function() {
  dplyr::tribble(
    ~variable_name, ~plot_type,
    "Number subjects", "barPlot",
    "Number subjects not in observation", "barPlot",
    "Sex", "barPlot",
    "Sex source", "barPlot",
    "Race", "barPlot",
    "Race source", "barPlot",
    "Ethnicity", "barPlot",
    "Ethnicity source", "barPlot",
    "Year of birth", "boxPlot",
    "Month of birth", "boxPlot",
    "Day of birth", "boxPlot"
  )
}

validateResult <- function(result,
                           resultType = NULL,
                           variableName = NULL,
                           call = parent.frame()) {
  result <- omopgenerics::validateResultArgument(result = result, call = call)

  if (!is.null(resultType)) {
    result <- result |>
      omopgenerics::filterSettings(.data$result_type == .env$resultType)
    if (nrow(result) == 0) {
      return(warnEmpty(resultType = resultType))
    }
  }

  if (!is.null(variableName)) {
    if (isTRUE(variableName)) {
      len <- length(unique(result$variable_name))
      if (len > 1) {
        mes <- "Result should contain data from only one variable, please filter the result."
        cli::cli_warn(message = mes)
        return(mes)
      }
    } else if (!is.character(variableName) || length(variableName) != 1) {
      mes <- "Please provide a valid `variableName` to filter the result."
      cli::cli_warn(message = mes)
      return(mes)
    } else {
      variableNames <- unique(result$variable_name)
      if (!variableName %in% variableNames) {
        mes <- "`{variableName}` is not present in `result$variable_name`"
        cli::cli_warn(message = mes)
        return(mes)
      } else {
        result <- result |>
          dplyr::filter(.data$variable_name == .env$variableName)
      }
    }
  }

  return(result)
}
