
#' Summarise the observation period table getting some overall statistics in a
#' summarised_result object.
#'
#' @param observationPeriod observation_period omop table.
#' @param estimates Estimates to summarise the variables of interest (
#' `records per person`, `duration` and `days to next observation period`).
#' @param density Whether to export density data for time between observation
#' periods.
#'
#' @return A summarised_result object with the summarised data.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' library(CDMConnector)
#' library(duckdb)
#'
#' con <- dbConnect(duckdb(), eunomiaDir())
#' cdm <- cdmFromCon(con = con, cdmSchema = "main", writeSchema = "main")
#'
#' result <- summariseObservationPeriod(cdm$observation_period)
#'
#' result |>
#'   dplyr::glimpse()
#' }
#'
summariseObservationPeriod <- function(observationPeriod,
                                       estimates = c(
                                         "mean", "sd", "min", "q05", "q25",
                                         "median", "q75", "q95", "max"),
                                       density = FALSE){
  # input checks
  omopgenerics::assertClass(observationPeriod, class = "omop_table")
  omopgenerics::assertTrue(
    omopgenerics::tableName(observationPeriod) == "observation_period")
  cdm <- omopgenerics::cdmReference(observationPeriod)
  omopgenerics::assertLogical(density, length = 1)
  opts <- PatientProfiles::availableEstimates(
    variableType = "numeric", fullQuantiles = TRUE) |>
    dplyr::pull("estimate_name")
  omopgenerics::assertChoice(estimates, opts, unique = TRUE)

  # prepare
  obs <- observationPeriod |>
    dplyr::select(
      "person_id",
      "obs_start" = "observation_period_start_date",
      "obs_end" = "observation_period_end_date") |>
    dplyr::group_by(.data$person_id) |>
    dplyr::arrange(.data$obs_start) |>
    dplyr::mutate("next_start" = dplyr::lead(.data$obs_start)) %>%
    dplyr::mutate(
      "duration" = as.integer(!!CDMConnector::datediff("obs_start", "obs_end")) + 1L,
      "next_obs" = as.integer(!!CDMConnector::datediff("obs_end", "next_start")),
      "id" = as.integer(dplyr::row_number())
    ) |>
    dplyr::ungroup() |>
    dplyr::select("person_id", "id", "duration", "next_obs") |>
    dplyr::collect()

  obsSr <- obs |>
    PatientProfiles::summariseResult(
      strata = "id",
      variables = c("duration", "next_obs"),
      estimates = estimates
    ) |>
    suppressMessages() |>
    dplyr::union_all(
      obs |>
        dplyr::group_by(.data$person_id) |>
        dplyr::tally(name = "n") |>
        PatientProfiles::summariseResult(
          variables = c("n"),
          estimates = estimates,
          counts = F
        ) |>
        suppressMessages()
    ) |>
    dplyr::filter(
      .data$variable_name != "number records" | .data$strata_level == "overall") |>
    addOrdinalLevels() |>
    arrangeSr(estimates) |>
    dplyr::union_all(
      obs |>
        densitySummary(density) |>
        dplyr::mutate(
          result_id = 1L, cdm_name = "unknown", group_name = "overall",
          group_level = "overall", estimate_type = "numeric",
          additional_name = "overall", additional_level = "overall"
        )
    ) |>
    dplyr::mutate(
      "cdm_name" = omopgenerics::cdmName(cdm),
      "strata_name" = dplyr::if_else(
        .data$strata_name == "id", "observation_period_ordinal", "overall"
      ),
      "variable_name" = dplyr::case_when(
        .data$variable_name == "n" ~ "records per person",
        .data$variable_name == "next_obs" ~ "days to next observation period",
        .default = .data$variable_name
      )
    ) |>
    omopgenerics::newSummarisedResult(settings = dplyr::tibble(
      "result_id" = 1L,
      "result_type" = "summarise_observation_period",
      "package_name" = "OmopSketch",
      "package_version" = as.character(utils::packageVersion("OmopSketch")),
      "density" = density
    ))
  return(obsSr)
}

addOrdinalLevels <- function(x) {
  xx <- suppressWarnings(as.integer(x$strata_level))
  desena <- (floor(xx/10)) %% 10
  unitat <- xx %% 10
  val <- rep("overall", length(xx))
  id0 <- !is.na(xx)
  val[id0] <- paste0(xx[id0], "th")
  id <- id0 & desena != 1L & unitat == 1L
  val[id] <- paste0(xx[id], "st")
  id <- id0 & desena != 1L & unitat == 2L
  val[id] <- paste0(xx[id], "nd")
  id <- id0 & desena != 1L & unitat == 3L
  val[id] <- paste0(xx[id], "rd")
  x$strata_level <- val
  return(x)
}
arrangeSr <- function(x, estimates) {
  lev <- x$strata_level |> unique()
  lev <- c("overall", sort(lev[lev != "overall"]))
  order <- dplyr::tibble(
    "variable_name" = c("number records"),
    "strata_level" = "overall",
    "estimate_name" = "count"
  ) |>
    dplyr::union_all(
      tidyr::expand_grid(
        "variable_name" = c("number subjects"),
        "strata_level" = lev,
        "estimate_name" = "count"
      )
    ) |>
    dplyr::union_all(
      tidyr::expand_grid(
        "strata_level" = lev,
        "variable_name" = c("n", "duration", "next"),
        "estimate_name" = estimates
      )
    ) |>
    dplyr::left_join(
      dplyr::tibble("strata_level" = lev) |>
        dplyr::mutate("order_lev" = dplyr::row_number()),
      by = "strata_level"
    ) |>
    dplyr::left_join(
      dplyr::tibble("variable_name" = c(
        "number records", "number subjects", "n", "duration", "next"
      )) |>
        dplyr::mutate("order_var" = dplyr::row_number()),
      by = "variable_name"
    ) |>
    dplyr::arrange(.data$order_lev, .data$order_var) |>
    dplyr::select(!c("order_lev", "order_var")) |>
    dplyr::mutate("order_id" = dplyr::row_number())
  x <- x |>
    dplyr::left_join(
      order, by = c("variable_name", "strata_level", "estimate_name")) |>
    dplyr::arrange(.data$order_id) |>
    dplyr::select(-"order_id")
  return(x)
}
densitySummary <- function(data, density) {
  if (density) {
    densityResult <- data |>
      dplyr::group_by(.data$id) |>
      dplyr::tally() |>
      dplyr::pull("n") |>
      formatDensity() |>
      dplyr::mutate(variable_name = "n") |>
      dplyr::union_all(
        data$duration |>
          formatDensity() |>
          dplyr::mutate(variable_name = "duration")
      ) |>
      dplyr::union_all(
        data$next_obs |>
          formatDensity() |>
          dplyr::mutate(variable_name = "next_obs")
      ) |>
      dplyr::mutate(strata_name = "overall", strata_level = "overall")
    for (id in sort(unique(data$id))) {
      idd <- data$id == id
      densityResult <- densityResult |>
        dplyr::union_all(
          data$duration[idd] |>
            formatDensity() |>
            dplyr::mutate(variable_name = "duration") |>
            dplyr::union_all(
              data$next_obs[idd] |>
                formatDensity() |>
                dplyr::mutate(variable_name = "next_obs")
            ) |>
            dplyr::mutate(strata_name = "id", strata_level = as.character(id))
        )
    }
  } else {
    densityResult <- dplyr::tibble(
      variable_name = character(),
      variable_level = character(),
      estimate_name = character(),
      estimate_value = character(),
      strata_name = character(),
      strata_level = character()
    )
  }
  return(densityResult)
}
formatDensity <- function(x) {
  nPoints <- 512
  nDigits <- ceiling(log(nPoints)/log(10))
  x <- x[!is.na(x)]
  if (length(x) < 2) {
    res <- dplyr::tibble(
      variable_level = character(),
      estimate_name = character(),
      estimate_value = character()
    )
  } else {
    den <- stats::density(x)
    lev <- paste0(
      "density_", stringr::str_pad(seq_along(den$x), nDigits, pad = "0"))
    res <- dplyr::tibble(
      variable_level = lev,
      estimate_name = "x",
      estimate_value = as.character(den$x)
    ) |>
      dplyr::union_all(dplyr::tibble(
        variable_level = lev,
        estimate_name = "y",
        estimate_value = as.character(den$y)
      )) |>
      dplyr::arrange(.data$variable_level, .data$estimate_name)
  }
  return(res)
}

#' Create a table from the output of summariseObservationPeriod().
#'
#' @param result A summarised result object.
#' @param type Type of table either `gt` or `flextable`.
#'
#' @return A gt or flextable table.
#' @export
#'
tableObservationPeriod <- function(result,
                                   type = "gt") {
  omopgenerics::assertClass(result, class = "summarised_result")
  result <- result |>
    visOmopResults::filterSettings(
      .data$result_type == "summarise_observation_period")
  if (nrow(result) == 0) {
    "No results found for `result_type` == 'summarise_observation_period'" |>
      cli::cli_abort()
  }
  omopgenerics::assertChoice(type, c("gt", "flextable"))

  result |>
    dplyr::filter(is.na(.data$variable_level)) |>
    visOmopResults::visOmopTable(
      formatEstimateName = c(
        "N" = "<count>",
        "mean (sd)" = "<mean> (<sd>)",
        "median [Q25 - Q75]" = "<median> [<q25> - <q75>]"),
      header = "cdm_name",
      split = c("group", "additional"),
      groupColumn = "strata_level",
      excludeColumns = c(
        "result_id", "estimate_type", "strata_name", "variable_level"),
      type = type,
      .options = list(keepNotFormatted = FALSE)
    )
}

#' Create a plot from the output of summariseObservationPeriod().
#'
#' @param result A summarised_result object.
#' @param variableName The variable to plot it can be: "number subjects",
#' "records per person", "duration" or "days to next observation period".
#' @param plotType The plot type, it can be: "barplor", "boxplot" or
#' "density".
#' @param facet Elements to facet by, it can be "cdm_name",
#' "observation_period_ordinal", both or none.
#' @param colour Elements to color by, it can be "cdm_name",
#' "observation_period_ordinal", both or none.
#'
#' @return A ggplot2 object.
#' @export
#'
plotObservationPeriod <- function(result,
                                  variableName = "number subjects",
                                  plotType = "barplot",
                                  facet = "cdm_name",
                                  colour = "observation_period_ordinal") {
  # initial checks
  omopgenerics::assertClass(result, class = "summarised_result")
  result <- result |>
    visOmopResults::filterSettings(
      .data$result_type == "summarise_observation_period")
  if (nrow(result) == 0) {
    "No results found for `result_type` == 'summarise_observation_period'" |>
      cli::cli_abort()
  }
  variableNames <- availablePlotObservationPeriod() |>
    dplyr::pull("variable_name") |>
    unique()
  omopgenerics::assertChoice(variableName, variableNames, length = 1)
  plotTypes <- availablePlotObservationPeriod() |>
    dplyr::filter(.data$variable_name == .env$variableName) |>
    dplyr::pull("plot_type")
  omopgenerics::assertChoice(plotType, plotTypes, length = 1)
  optFacetColour <- c("cdm_name", "observation_period_ordinal")
  omopgenerics::assertChoice(facet, optFacetColour, unique = TRUE, null = TRUE)
  omopgenerics::assertChoice(colour, optFacetColour, unique = TRUE, null = TRUE)

  neededEstimates <- needEstimates(plotType)
  result <- result |>
    dplyr::filter(
      .data$variable_name == .env$variableName,
      .data$estimate_name %in% .env$neededEstimates)
  allEstimates <- result$estimate_name |> unique()
  missingEstimates <- neededEstimates[!neededEstimates %in% allEstimates]
  if (length(missingEstimates)) {
    cli::cli_warn("estimates not found: {missingEstimates}.")
  }

  result <- result |>
    visOmopResults::pivotEstimates() |>
    visOmopResults::splitAll() |>
    dplyr::select(-c("result_id", "variable_name", "variable_level"))

  for (me in missingEstimates) {
    result <- result |> dplyr::mutate(!!me := NA_real_)
  }

  result <- result |>
    uniteVariable(cols = colour, colname = "colour", def = NA_character_)

  if (plotType != "density") {
    x <- optFacetColour[!optFacetColour %in% facet]
    result <- result |> uniteVariable(cols = x, colname = "x", def = "all")
  }

  if (plotType == "barplot") {
    result <- result |>
      dplyr::filter(.data$observation_period_ordinal != "overall")
    p <- ggplot2::ggplot(
      data = result,
      mapping = ggplot2::aes(
        x = .data$x, y = .data$count, colour = .data$colour,
        fill = .data$colour)
    ) +
      ggplot2::geom_col() +
      ggplot2::xlab("Observation period")
  } else if (plotType == "boxplot") {
    p <- ggplot2::ggplot(
      data = result,
      mapping = ggplot2::aes(
        x = .data$x, ymin = .data$min, lower = .data$q25, middle = .data$median,
        upper = .data$q75, ymax = .data$max, colour = .data$colour)
    ) +
      ggplot2::geom_boxplot(stat = "identity") +
      ggplot2::xlab("Observation period") +
      ggplot2::ylab(stringr::str_to_sentence(variableName))
  } else {
    p <- ggplot2::ggplot(
      data = result,
      mapping = ggplot2::aes(
        x = .data$x, y = .data$y, colour = .data$colour, group = .data$colour)
    ) +
      ggplot2::geom_line() +
      ggplot2::xlab("Time (days)") +
      ggplot2::ylab(stringr::str_to_sentence(variableName))
  }

  p <- p +
    ggplot2::facet_wrap(facet)

  return(p)
}

availablePlotObservationPeriod <- function() {
  dplyr::tribble(
    ~variable_name, ~plot_type,
    "number subjects", "barplot",
    "records per person", "density",
    "records per person", "boxplot",
    "duration", "density",
    "duration", "boxplot",
    "days to next observation period", "density",
    "days to next observation period", "boxplot",
  )
}
needEstimates <- function(plotType) {
  dplyr::tribble(
    ~plot_type, ~estimate_name,
    "barplot", "count",
    "density", "x",
    "density", "y",
    "boxplot", "median",
    "boxplot", "q25",
    "boxplot", "q75",
    "boxplot", "min",
    "boxplot", "max"
  ) |>
    dplyr::filter(.data$plot_type == .env$plotType) |>
    dplyr::pull("estimate_name")
}
uniteVariable <- function(res, cols, colname, def) {
  if (length(cols) > 0) {
    res <- res |>
      tidyr::unite(
        col = !!colname, dplyr::all_of(cols), sep = " - ", remove = FALSE)
  } else {
    res <- res |> dplyr::mutate(!!colname := !!def)
  }
  return(res)
}
