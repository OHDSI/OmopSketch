#' @noRd
checkAgeGroup <- function(ageGroup, overlap = FALSE) {
  checkmate::assertList(ageGroup, min.len = 1, null.ok = TRUE)
  if (!is.null(ageGroup)) {
    if (is.numeric(ageGroup[[1]])) {
      ageGroup <- list("age_group" = ageGroup)
    }
    for (k in seq_along(ageGroup)) {
      invisible(checkCategory(ageGroup[[k]], overlap))
      if (any(ageGroup[[k]] |> unlist() |> unique() < 0)) {
        cli::cli_abort("ageGroup can't contain negative values")
      }
    }
    if (is.null(names(ageGroup))) {
      names(ageGroup) <- paste0("age_group_", 1:length(ageGroup))
    }
    if ("" %in% names(ageGroup)) {
      id <- which(names(ageGroup) == "")
      names(ageGroup)[id] <- paste0("age_group_", id)
    }
  }
  return(invisible(ageGroup))
}

#' @noRd
checkOmopTable <- function(omopTable){
  assertClass(omopTable, "omop_table")
  omopTable |>
    omopgenerics::tableName() |>
    assertChoice(choices = tables$table_name)
}

#' @noRd
checkUnit <- function(unit){
  inherits(unit, "character")
  assertLength(unit, 1)
  if(!unit %in% c("year","month")){
    cli::cli_abort("units value is not valid. Valid options are year or month.")
  }
}

#' @noRd
checkUnitInterval <- function(unitInterval){
  inherits(unitInterval, c("numeric", "integer"))
  assertLength(unitInterval, 1)
  if(unitInterval < 1){
    cli::cli_abort("unitInterval input has to be equal or greater than 1.")
  }
  if(!(unitInterval%%1 == 0)){
    cli::cli_abort("unitInterval has to be an integer.")
  }
}


#' @noRd
checkCategory <- function(category, overlap = FALSE, type = "numeric") {
  checkmate::assertList(
    category,
    types = type, any.missing = FALSE, unique = TRUE,
    min.len = 1
  )

  if (is.null(names(category))) {
    names(category) <- rep("", length(category))
  }

  # check length
  category <- lapply(category, function(x) {
    if (length(x) == 1) {
      x <- c(x, x)
    } else if (length(x) > 2) {
      cli::cli_abort(
        paste0(
          "Categories should be formed by a lower bound and an upper bound, ",
          "no more than two elements should be provided."
        ),
        call. = FALSE
      )
    }
    invisible(x)
  })

  # check lower bound is smaller than upper bound
  checkLower <- unlist(lapply(category, function(x) {
    x[1] <= x[2]
  }))
  if (!(all(checkLower))) {
    cli::cli_abort("Lower bound should be equal or smaller than upper bound")
  }

  # built tibble
  result <- lapply(category, function(x) {
    dplyr::tibble(lower_bound = x[1], upper_bound = x[2])
  }) |>
    dplyr::bind_rows() |>
    dplyr::mutate(category_label = names(.env$category)) |>
    dplyr::mutate(category_label = dplyr::if_else(
      .data$category_label == "",
      dplyr::case_when(
        is.infinite(.data$lower_bound) & is.infinite(.data$upper_bound) ~ "any",
        is.infinite(.data$lower_bound) ~ paste(.data$upper_bound, "or below"),
        is.infinite(.data$upper_bound) ~ paste(.data$lower_bound, "or above"),
        TRUE ~ paste(.data$lower_bound, "to", .data$upper_bound)
      ),
      .data$category_label
    )) |>
    dplyr::arrange(.data$lower_bound)

  # check overlap
  if (!overlap) {
    if (nrow(result) > 1) {
      lower <- result$lower_bound[2:nrow(result)]
      upper <- result$upper_bound[1:(nrow(result) - 1)]
      if (!all(lower > upper)) {
        cli::cli_abort("There can not be overlap between categories")
      }
    }
  }

  invisible(result)
}
