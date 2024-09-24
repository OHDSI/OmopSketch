
visOmopResults.filterSettings <- function(result, ...) {
  # initial check
  set <- validateSettingsAttribute(result)

  # filter settings (try if error)
  result <- tryCatch(
    {
      attr(result, "settings") <- set |>
        dplyr::filter(...)

      # filter id from settings
      resId <- settings(result) |> dplyr::pull("result_id")
      result |> dplyr::filter(.data$result_id %in% .env$resId)
    },
    error = function(e) {
      cli::cli_warn(c(
        "!" = "Variable filtering does not exist, returning empty result: ",
        e$message))
      omopgenerics::emptySummarisedResult()  # return empty result here
    }
  )

  return(result)
}
visOmopResults.filterStrata <- function(result, ...) {
  filterNameLevel(result, "strata", ...)
}
#' Get the tidy columns of a dataset
#'
#' @param result A summarised_result object.
#'
#' @return A caharacter vector with the tidy columns.
#' @export
#'
#' @examples
#' \donttest{
#' cdm <- mockOmopSketch()
#' result <- summariseOmopSnapshot(cdm)
#' visOmopResults.tidyColumns(result)
#' }
#'
visOmopResults.tidyColumns <- function(result) {
  omopgenerics::validateResultArgument(result)
  colsSet <- colnames(settings(result))
  c("cdm_name", groupColumns(result), strataColumns(result), "variable_name",
    "variable_level", unique(result$estimate_name), additionalColumns(result),
    colsSet[colsSet != "result_id"])
}
visOmopResults.strataColumns <- function(result) {
  getColumns(result = result, col = "strata_name")
}
visOmopResults.scatterPlot <- function(result,
                        x,
                        y,
                        line,
                        point,
                        ribbon,
                        ymin = NULL,
                        ymax = NULL,
                        facet = NULL,
                        colour = NULL,
                        group = colour) {

  rlang::check_installed("ggplot2")

  # check and prepare input
  omopgenerics::assertTable(result)
  omopgenerics::assertLogical(line, length = 1, call = call)
  omopgenerics::assertLogical(point, length = 1, call = call)
  omopgenerics::assertLogical(ribbon, length = 1, call = call)
  omopgenerics::assertCharacter(x)
  omopgenerics::assertCharacter(y, length = 1)
  omopgenerics::assertCharacter(ymin, length = 1, null = TRUE)
  omopgenerics::assertCharacter(ymax, length = 1, null = TRUE)
  validateFacet(facet)
  omopgenerics::assertCharacter(colour, null = TRUE)
  omopgenerics::assertCharacter(group, null = TRUE)

  # empty
  if (nrow(result) == 0) {
    cli::cli_warn(c("!" = "result object is empty, returning empty plot."))
    return(ggplot2::ggplot())
  }

  est <- c(x, y, ymin, ymax, asCharacterFacet(facet), colour, group)

  # check that all data is present
  checkInData(result, est)

  # get estimates
  result <- cleanEstimates(result, est)

  # tidy result
  result <- tidyResult(result)

  # warn multiple values
  result |>
    warnMultipleValues(cols = list(
      x = x, facet = asCharacterFacet(facet), colour = colour, group = group))

  # prepare result
  cols = list(
    x = x, y = y, ymin = ymin, ymax = ymax, colour = colour, group = group,
    fill = colour)
  result <- prepareColumns(result = result, cols = cols, facet = facet)

  # get aes
  aes <- getAes(cols)
  yminymax <- !is.null(ymin) & !is.null(ymax)

  # make plot
  p <- ggplot2::ggplot(data = result, mapping = aes)
  if (line) p <- p + ggplot2::geom_line()
  if (yminymax) p <- p + ggplot2::geom_errorbar()
  if (point) p <- p + ggplot2::geom_point()
  if (ribbon & yminymax) {
    p <- p +
      ggplot2::geom_ribbon(alpha = .3, color = NA, show.legend = FALSE)
  }
  p <- plotFacet(p, facet) +
    ggplot2::labs(
      x = styleLabel(x),
      fill = styleLabel(colour),
      colour = styleLabel(colour),
      y = styleLabel(y)
    ) +
    ggplot2::theme(
      legend.position = hideLegend(colour)
    )

  return(p)
}
visOmopResults.barPlot <- function(result,
                    x,
                    y,
                    facet = NULL,
                    colour = NULL) {

  rlang::check_installed("ggplot2")

  # initial checks
  omopgenerics::assertTable(result)
  omopgenerics::assertCharacter(x)
  omopgenerics::assertCharacter(y, length = 1)
  validateFacet(facet)
  omopgenerics::assertCharacter(colour, null = TRUE)

  # empty
  if (nrow(result) == 0) {
    cli::cli_warn(c("!" = "result object is empty, returning empty plot."))
    return(ggplot2::ggplot())
  }

  est <- c(x, y, asCharacterFacet(facet), colour)

  # check that all data is present
  checkInData(result, est)

  # subset to estimates of use
  result <- cleanEstimates(result, est)

  # tidy result
  result <- tidyResult(result)

  # warn multiple values
  result |>
    warnMultipleValues(cols = list(
      x = x, facet = asCharacterFacet(facet), colour = colour))

  # prepare result
  cols = list(x = x, y = y, colour = colour, fill = colour)
  result <- prepareColumns(result = result, cols = cols, facet = facet)

  # get aes
  aes <- getAes(cols)

  # create plot
  p <- ggplot2::ggplot(data = result, mapping = aes) +
    ggplot2::geom_col()

  p <- plotFacet(p, facet) +
    ggplot2::labs(
      x = styleLabel(x),
      fill = styleLabel(colour),
      colour = styleLabel(colour),
      y = styleLabel(y)
    ) +
    ggplot2::theme(
      legend.position =  hideLegend(colour)
    )

  return(p)
}
visOmopResults.splitGroup <- function(result,
                       keep = FALSE,
                       fill = "overall") {
  splitNameLevelInternal(
    result = result,
    name = "group_name",
    level = "group_level",
    keep = keep,
    fill = fill
  )
}
visOmopResults.splitStrata <- function(result,
                        keep = FALSE,
                        fill = "overall") {
  splitNameLevelInternal(
    result = result,
    name = "strata_name",
    level = "strata_level",
    keep = keep,
    fill = fill
  )
}
visOmopResults.splitAll <- function(result,
                     keep = FALSE,
                     fill = "overall",
                     exclude = "variable") {
  omopgenerics::assertTable(result, class = "data.frame")
  omopgenerics::assertLogical(keep, length = 1)
  omopgenerics::assertCharacter(fill, length = 1)
  omopgenerics::assertCharacter(exclude, null = TRUE)

  cols <- colnames(result)
  cols <- intersect(
    cols[stringr::str_ends(cols, "_name")] |>
      stringr::str_replace("_name$", ""),
    cols[stringr::str_ends(cols, "_level")] |>
      stringr::str_replace("_level$", "")
  )
  cols <- cols[!cols %in% exclude]

  for (col in cols) {
    result <- tryCatch(
      expr = {
        result |>
          splitNameLevelInternal(
            name = paste0(col, "_name"),
            level = paste0(col, "_level"),
            keep = keep,
            fill = fill
          )
      },
      error = function(e) {
        cli::cli_warn(c(
          "!" = "Couldn't split pair: {.var {col}_name}-{.var {col}_level}: {e$message}"
        ))
        return(result)
      }
    )
  }

  return(result)
}
visOmopResults.uniteGroup <- function(x,
                       cols = character(0),
                       keep = FALSE,
                       ignore = c(NA, "overall")) {
  uniteNameLevelInternal(
    x = x, cols = cols, name = "group_name", level = "group_level", keep = keep,
    ignore = ignore
  )
}
visOmopResults.uniteStrata <- function(x,
                        cols = character(0),
                        keep = FALSE,
                        ignore = c(NA, "overall")) {
  uniteNameLevelInternal(
    x = x, cols = cols, name = "strata_name", level = "strata_level",
    keep = keep, ignore = ignore
  )
}
visOmopResults.uniteAdditional <- function(x,
                            cols = character(0),
                            keep = FALSE,
                            ignore = c(NA, "overall")) {
  uniteNameLevelInternal(
    x = x, cols = cols, name = "additional_name", level = "additional_level",
    keep = keep, ignore = ignore
  )
}
visOmopResults.visOmopTable <- function(result,
                         estimateName = character(),
                         header = character(),
                         settingsColumns = character(),
                         groupColumn = character(),
                         rename = character(),
                         type = "gt",
                         hide = character(),
                         showMinCellCount = TRUE,
                         .options = list()) {
  # Tidy results
  result <- omopgenerics::validateResultArgument(result)
  resultTidy <- tidySummarisedResult(result, settingsColumns = settingsColumns, pivotEstimatesBy = NULL)

  # .options
  .options <- defaultTableOptions(.options)

  # Backward compatibility ---> to be deleted in the future
  omopgenerics::assertCharacter(header, null = TRUE)
  omopgenerics::assertCharacter(hide, null = TRUE)
  settingsColumns <- validateSettingsColumns(settingsColumns, result)
  bc <- backwardCompatibility(header, hide, result, settingsColumns, groupColumn)
  header <- bc$header
  hide <- bc$hide
  groupColumn <- bc$groupColumn
  if ("variable_level" %in% header) {
    resultTidy <- resultTidy |>
      dplyr::mutate(dplyr::across(dplyr::starts_with("variable"), ~ dplyr::if_else(is.na(.x), .options$na, .x)))
  }

  # initial checks and preparation
  rename <- validateRename(rename, result)
  if (!"cdm_name" %in% rename) rename <- c(rename, "CDM name" = "cdm_name")
  groupColumn <- validateGroupColumn(groupColumn, colnames(resultTidy), sr = result, rename = rename)
  showMinCellCount <- validateShowMinCellCount(showMinCellCount, settings(result))
  # default SR hide columns
  hide <- c(hide, "result_id", "estimate_type") |> unique()
  checkVisTableInputs(header, groupColumn, hide)

  # showMinCellCount
  if (showMinCellCount) {
    if ("min_cell_count" %in% settingsColumns) {
      resultTidy <- resultTidy |>
        dplyr::mutate(estimate_value = dplyr::if_else(
          is.na(.data$estimate_value), paste0("<", base::format(.data$min_cell_count, big.mark = ",")), .data$estimate_value
        ))
    } else {
      resultTidy <- resultTidy |>
        dplyr::left_join(
          settings(result) |> dplyr::select("result_id", "min_cell_count"),
          by = "result_id"
        ) |>
        dplyr::mutate(estimate_value = dplyr::if_else(
          is.na(.data$estimate_value), paste0("<", base::format(.data$min_cell_count, big.mark = ",")), .data$estimate_value
        )) |>
        dplyr::select(!"min_cell_count")
    }
  }

  tableOut <- visTable(
    result = resultTidy,
    estimateName = estimateName,
    header = header,
    groupColumn = groupColumn,
    type = type,
    rename = rename,
    hide = hide,
    .options = .options
  )

  return(tableOut)
}
visOmopResults.boxPlot <- function(result,
                    x = NULL,
                    lower = "q25",
                    middle = "median",
                    upper = "q75",
                    ymin = "min",
                    ymax = "max",
                    facet = NULL,
                    colour = NULL) {
  rlang::check_installed("ggplot2")
  # initial checks
  omopgenerics::assertTable(result)
  omopgenerics::assertCharacter(x, null = TRUE)
  omopgenerics::assertCharacter(lower, length = 1)
  omopgenerics::assertCharacter(middle, length = 1)
  omopgenerics::assertCharacter(upper, length = 1)
  omopgenerics::assertCharacter(ymin, length = 1)
  omopgenerics::assertCharacter(ymax, length = 1)
  validateFacet(facet)
  omopgenerics::assertCharacter(colour, null = TRUE)
  # empty
  if (nrow(result) == 0) {
    cli::cli_warn(c("!" = "result object is empty, returning empty plot."))
    return(ggplot2::ggplot())
  }
  est <- c(x, lower, middle, upper, ymin, ymax, asCharacterFacet(facet), colour)
  # check that all data is present
  checkInData(result, est)
  # subset to estimates of use
  result <- cleanEstimates(result, est)
  ylab <- styleLabel(unique(suppressWarnings(result$variable_name)))
  # tidy result
  result <- tidyResult(result)
  # warn multiple values
  result |>
    warnMultipleValues(cols = list(
      x = x, facet = asCharacterFacet(facet), colour = colour))
  # prepare result
  col <- omopgenerics::uniqueId(exclude = colnames(result))
  result <- result |>
    dplyr::mutate(!!col := dplyr::row_number())
  cols = list(
    x = x, lower = lower, middle = middle, upper = upper, ymin = ymin,
    ymax = ymax, colour = colour, group = col)
  result <- prepareColumns(result = result, cols = cols, facet = facet)
  # get aes
  aes <- getAes(cols)
  yminymax <- !is.null(ymin) & !is.null(ymax)
  clab <- styleLabel(colour)
  xlab <- styleLabel(x)
  p <- ggplot2::ggplot(data = result, mapping = aes) +
    ggplot2::geom_boxplot(stat = "identity")
  p <- plotFacet(p, facet) +
    ggplot2::labs(y = ylab, colour = clab, x = xlab) +
    ggplot2::theme(
      legend.position =  hideLegend(colour)
    )
  return(p)
}
