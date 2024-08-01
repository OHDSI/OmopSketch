#' @noRd
internalPlot <- function(summarisedResult, facet = NULL, call = parent.frame()){
  # Initial checks ----
  assertClass(summarisedResult, "summarised_result", call = call)

  if(summarisedResult |> dplyr::tally() |> dplyr::pull("n") == 0){
    cli::cli_warn("summarisedOmopTable is empty.")
    return(
      summarisedResult |>
        ggplot2::ggplot()
    )
  }

  summarisedResult <- summarisedResult |>
    dplyr::filter(.data$estimate_name == "count")

  if(summarisedResult |> dplyr::select("variable_name") |> dplyr::distinct() |> dplyr::pull("variable_name") |> length() > 1){
    cli::cli_abort("The summarised result can only contain one type of variable_name. Please, filter variable_name.", call = call)
  }

  # Determine color variables ----
  Strata <- c("cdm_name", "group_level","strata_level")

  # If facet has variables, remove that ones from the strata variable
  if(!is.null(facet)){
    x <- facetFunction(facet, summarisedResult)
    facetVarX <- x$facetVarX
    facetVarY <- x$facetVarY

    if(!is.null(facetVarX)){Strata <- Strata[Strata != facetVarX]}
    if(!is.null(facetVarY)){Strata <- Strata[Strata != facetVarY]}
  }

  # If all the variables have been selected to facet by, do not use any strata
  if(length(Strata) == 0){
    Strata <- "black"
  }else{
    # Create strata variable with the remaining variables in strata
    summarisedResult <- summarisedResult |> dplyr::mutate(strata_col = "")
    for(i in 1:length(Strata)){
      summarisedResult <- summarisedResult |>
        dplyr::mutate(strata_col = paste0(.data$strata_col,"; ",.data[[Strata[i]]]))
    }

    summarisedResult <- summarisedResult |>
      dplyr::mutate(strata_col = sub("; ","",.data$strata_col)) |>
      dplyr::rename("Strata" = "strata_col")
  }

  # Plot ----
  p1 <- summarisedResult |>
    dplyr::mutate(count = as.numeric(.data$estimate_value),
                  time = as.Date(.data$variable_level))

  if(TRUE %in% c(Strata == "black")){
    p1 <- ggplot2::ggplot(p1, ggplot2::aes(x = .data$time,
                                           y = .data$count))
  }else{
    p1 <- ggplot2::ggplot(p1, ggplot2::aes(x = .data$time,
                                           y = .data$count,
                                           group = .data$Strata,
                                           color = .data$Strata))
  }

  p1 +
    ggplot2::geom_point() +
    ggplot2::geom_line(show.legend = dplyr::if_else(Strata == "black",FALSE, TRUE)) +
    ggplot2::facet_grid(facets = facet) +
    ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 90, vjust = 0.5, hjust=1)) +
    ggplot2::xlab("Dates") +
    ggplot2::ylab(stringr::str_to_sentence(gsub("_"," ",summarisedResult |> dplyr::pull("variable_name") |> unique()))) +
    ggplot2::theme() +
    ggplot2::theme_bw()
}

facetFunction <- function(facet, summarisedResult) {
  if (!is.null(facet)) {
    checkmate::assertTRUE(inherits(facet, c("formula", "character")))

    if (inherits(facet, "formula")) {
      facet <- Reduce(paste, deparse(facet))
    }

    # Extract facet names
    x <- extractFacetVar(facet)
    facetVarX <- x$facetVarX
    facetVarY <- x$facetVarY

    # Check facet names validity
    facetVarX <- checkFacetNames(facetVarX, summarisedResult)
    facetVarY <- checkFacetNames(facetVarY, summarisedResult)
  } else {
    facetVarX <- NULL
    facetVarY <- NULL
  }

  # Add table_name column
  return(list("facetVarX" = facetVarX, "facetVarY" = facetVarY))
}

checkFacetNames <- function(facetVar, summarisedResult) {
  if (!is.null(facetVar)) {
    # Remove spaces at the beginning or at the end
    facetVar <- gsub(" $", "", facetVar)
    facetVar <- gsub("^ ", "", facetVar)

    # Replace empty spaces with "_"
    facetVar <- gsub(" ", "_", facetVar)

    # Turn to lower case
    facetVar <- tolower(facetVar)

    facetVar[facetVar == "cohort_name"] <- "group_level"
    facetVar[facetVar == "window_name"] <- "variable_level"
    facetVar[facetVar == "strata"] <- "strata_level"

    # Replace empty or "." facet by NULL
    if (TRUE %in% (facetVar %in% c("", ".", as.character()))) {
      facetVar <- NULL
    }

    # Check correct column names
    if(FALSE %in% c(facetVar %in% c("cdm_name", "group_level", "strata_level"))){
      cli::cli_abort("Only the following columns are allowed to be facet by: 'cdm_name', 'group_level', 'strata_level')")
    }
  }
  return(facetVar)
}

extractFacetVar <- function(facet) {
  if (unique(stringr::str_detect(facet, "~"))) {
    # Separate x and y from the formula
    facetVarX <- gsub("~.*", "", facet)
    facetVarY <- gsub(".*~", "", facet)

    # Remove
    facetVarX <- stringr::str_split(facetVarX, pattern = "\\+")[[1]]
    facetVarY <- stringr::str_split(facetVarY, pattern = "\\+")[[1]]
  } else {
    if (length(facet) == 1) {
      facetVarX <- facet
      facetVarY <- NULL
    } else {
      # Assign "randomly" the positions
      horizontal <- 1:round(length(facet) / 2)
      vertical <- (round(length(facet) / 2) + 1):length(facet)

      facetVarX <- facet[horizontal]
      facetVarY <- facet[vertical]
    }
  }

  return(list("facetVarX" = facetVarX, "facetVarY" = facetVarY))
}
