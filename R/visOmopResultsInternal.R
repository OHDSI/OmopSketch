# addSettings.R -----
addSettings <- function(result,
                        settingsColumns = colnames(settings(result))) {
  # checks
  set <- validateSettingsAttribute(result)
  settingsColumns <- validateSettingsColumns(settingsColumns, result)
  if (length(settingsColumns) == 0) {return(result)}
  # add settings
  toJoin <- settingsColumns[settingsColumns %in% colnames(result)]
  result <- result |>
    dplyr::left_join(
      set |> dplyr::select(dplyr::any_of(c("result_id", settingsColumns))),
      by = c("result_id", toJoin)
    )
  return(result)
}

# columns.R -----
groupColumns <- function(result) {
  getColumns(result = result, col = "group_name")
}
strataColumns <- function(result) {
  getColumns(result = result, col = "strata_name")
}
additionalColumns <- function(result) {
  getColumns(result = result, col = "additional_name")
}
settingsColumns <- function(result) {
  cols <- result |>
    validateSettingsAttribute() |>
    colnames()
  cols[cols != "result_id"]
}
tidyColumns <- function(result) {
  omopgenerics::validateResultArgument(result)
  colsSet <- colnames(settings(result))
  c("cdm_name", groupColumns(result), strataColumns(result), "variable_name",
    "variable_level", unique(result$estimate_name), additionalColumns(result),
    colsSet[colsSet != "result_id"])
}
getColumns <- function(result, col) {
  # initial checks
  omopgenerics::assertTable(result, columns = col)
  omopgenerics::assertCharacter(col, length = 1)
  # extract columns
  x <- result |>
    dplyr::select(dplyr::all_of(col)) |>
    dplyr::distinct() |>
    dplyr::pull() |>
    lapply(strsplit, split = " &&& ") |>
    unlist() |>
    unique()
  # eliminate overall
  x <- x[x != "overall"]
  return(x)
}

# filter.R -----
filterSettings <- function(result, ...) {
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
filterStrata <- function(result, ...) {
  filterNameLevel(result, "strata", ...)
}
filterGroup <- function(result, ...) {
  filterNameLevel(result, "group", ...)
}
filterAdditional <- function(result, ...) {
  filterNameLevel(result, "additional", ...)
}
filterNameLevel <- function(result, prefix, ..., call = parent.frame()) {
  # initial checks
  cols <- paste0(prefix, c("_name", "_level"))
  omopgenerics::assertTable(result, columns = cols, call = call)
  # splitNameLevelInternal
  labs <- result |>
    dplyr::select(dplyr::all_of(cols)) |>
    dplyr::distinct() |>
    splitNameLevelInternal(name = cols[1], level = cols[2], keep = TRUE)
  # filter
  tryCatch(
    expr = {
      result |>
        dplyr::inner_join(
          labs |>
            dplyr::filter(...) |>
            dplyr::select(dplyr::all_of(cols)),
          by = cols
        )
    },
    error = function(e) {
      cli::cli_warn(c(
        "!" = "Variable filtering does not exist, returning empty result: ",
        e$message))
      omopgenerics::emptySummarisedResult(settings = settings(result))
    }
  )
}

# formatEstimateName.R -----
formatEstimateName <- function(result,
                               estimateName = NULL,
                               keepNotFormatted = TRUE,
                               useFormatOrder = TRUE) {
  # initial checks
  omopgenerics::assertTable(result, columns = c("estimate_name", "estimate_value"))
  estimateName <- validateEstimateName(estimateName)
  omopgenerics::assertLogical(keepNotFormatted, length = 1)
  omopgenerics::assertLogical(useFormatOrder, length = 1)
  # format estimate
  if (!is.null(estimateName)) {
    resultFormatted <- formatEstimateNameInternal(
      result = result, format = estimateName,
      keepNotFormatted = keepNotFormatted, useFormatOrder = useFormatOrder
    )
  } else {
    resultFormatted <- result
  }
  return(resultFormatted)
}
formatEstimateNameInternal <- function(result, format, keepNotFormatted, useFormatOrder) {
  # if no format no action is performed
  if (length(format) == 0) {
    return(result)
  }
  # correct names
  if (is.null(names(format))) {
    nms <- rep("", length(format))
  } else {
    nms <- names(format)
  }
  nms[nms == ""] <- gsub("<|>", "", format[nms == ""])
  # format
  ocols <- colnames(result)
  cols <- ocols[
    !ocols %in% c("estimate_name", "estimate_type", "estimate_value")
  ]
  if (nrow(result) == 0) {
    cli::cli_warn(c("!" = "Empty summarized results provided."))
    return(result)
  } else {
    result <- result |>
      dplyr::mutate("formatted" = FALSE, "id" = dplyr::row_number()) |>
      dplyr::mutate(group_id = min(.data$id), .by = dplyr::all_of(cols))
  }
  resultF <- NULL
  for (k in seq_along(format)) {
    nameK <- nms[k]
    formatK <- format[k] |> unname()
    keys <- result[["estimate_name"]] |> unique()
    keysK <- regmatches(formatK, gregexpr("(?<=\\<).+?(?=\\>)", formatK, perl = T))[[1]]
    format_boolean <- all(keysK %in% keys)
    len <- length(keysK)
    if (len > 0 & format_boolean) {
      formatKNum <- getFormatNum(formatK, keysK)
      res <- result |>
        dplyr::filter(!.data$formatted) |>
        dplyr::filter(.data$estimate_name %in% .env$keysK) |>
        dplyr::filter(dplyr::n() == .env$len, .by = dplyr::all_of(cols))
      if (nrow(res) == 0) {
        if (len > 1) {
          cli::cli_warn("No combined entries in `result` for estimates {.strong {keysK}}")
        } else {
          cli::cli_warn("No entries in `result` for estimate {.strong {keysK}}")
        }
      } else {
        res <- res |> dplyr::mutate("id" = min(.data$id), .by = dplyr::all_of(cols))
        resF <- res |>
          dplyr::select(-"estimate_type") |>
          tidyr::pivot_wider(
            names_from = "estimate_name", values_from = "estimate_value"
          ) |>
          evalName(formatKNum, keysK) |>
          dplyr::mutate(
            "estimate_name" = nameK,
            "formatted" = TRUE,
            "estimate_type" = "character"
          ) |>
          dplyr::select(dplyr::all_of(c(ocols, "id", "group_id", "formatted")))
        result <- result |>
          dplyr::anti_join(
            res |> dplyr::select(dplyr::all_of(c(cols, "estimate_name"))),
            by = c(cols, "estimate_name")
          ) |>
          dplyr::union_all(resF)
      }
    } else {
      if (len > 0) {
        cli::cli_inform(c("i" = "{formatK} has not been formatted."))
      } else {
        cli::cli_inform(c("i" = "{formatK} does not contain an estimate name indicated by <...>."))
      }
    }
  }
  #useFormatOrder
  if (useFormatOrder) {
    new_order <- dplyr::tibble(estimate_name = nms, format_id = 1:length(nms)) |>
      dplyr::union_all(
        result |>
          dplyr::select("estimate_name") |>
          dplyr::distinct() |>
          dplyr::filter(!.data$estimate_name %in% nms) |>
          dplyr::mutate(format_id = length(format) + dplyr::row_number())
      )
    result <- result |>
      dplyr::left_join(new_order, by = "estimate_name")
    result <- result[order(result$group_id, result$format_id, decreasing = FALSE),] |>
      dplyr::select(-c("id", "group_id", "format_id"))
  } else {
    result <- result |>
      dplyr::arrange(.data$id) |>
      dplyr::select(-"id", -"group_id")
  }
  # keepNotFormated
  if (!keepNotFormatted) {
    result <- result |> dplyr::filter(.data$formatted)
  }
  result <- result |> dplyr::select(-"formatted")
  return(result)
}
getFormatNum <- function(format, keys) {
  ik <- 1
  for (k in seq_along(keys)) {
    format <- gsub(
      pattern = paste0("<", keys[k], ">"), replacement = paste0("#", ik, "#"), x = format
    )
    ik <- ik + 1
  }
  return(format)
}
evalName <- function(result, format, keys) {
  for (k in seq_along(keys)) {
    format <- gsub(
      pattern = paste0("#", k, "#"),
      replacement = paste0("#x#.data[[\"", keys[k], "\"]]#x#"),
      x = format
    )
  }
  format <- strsplit(x = format, split = "#x#") |> unlist()
  format <- format[format != ""]
  id <- !startsWith(format, ".data")
  format[id] <- paste0("\"", format[id], "\"")
  format <- paste0(format, collapse = ", ")
  format <- paste0("paste0(", format, ")")
  result <- result |>
    dplyr::mutate(
      "estimate_value" =
        dplyr::if_else(
          dplyr::if_any(dplyr::all_of(keys), ~ is.na(.x)),
          NA_character_,
          eval(parse(text = format))
        )
    )
  return(result)
}

# formatEstimateValue.R -----
formatEstimateValue <- function(result,
                                decimals = c(
                                  integer = 0, numeric = 2, percentage = 1,
                                  proportion = 3
                                ),
                                decimalMark = ".",
                                bigMark = ",") {
  # initial checks
  omopgenerics::assertTable(result, columns = c("estimate_name", "estimate_type", "estimate_value"))
  decimals <- validateDecimals(result, decimals)
  omopgenerics::assertCharacter(decimalMark, length = 1)
  omopgenerics::assertCharacter(bigMark, length = 1, null = TRUE)
  if (is.null(bigMark)) {bigMark <- ""}
  result <- formatEstimateValueInternal(result, decimals, decimalMark, bigMark)
  return(result)
}
formatEstimateValueInternal <- function(result, decimals, decimalMark, bigMark) {
  nms_name <- unique(result[["estimate_name"]])
  if (is.null(decimals)) { # default decimal formatting
    for (nm in nms_name) {
      result$estimate_value[result[["estimate_name"]] == nm] <- result$estimate_value[result[["estimate_name"]] == nm] |>
        as.numeric() |>
        base::format(big.mark = bigMark, decimal.mark = decimalMark,
                     trim = TRUE, justify = "none", scientific = FALSE)
    }
  } else {
    formatted <- rep(FALSE, nrow(result))
    for (nm in names(decimals)) {
      if (nm %in% nms_name) {
        id <- result[["estimate_name"]] == nm & !formatted & !is.na(result$estimate_value) & !grepl("<", result$estimate_value)
      } else {
        id <- result[["estimate_type"]] == nm & !formatted & !is.na(result$estimate_value) & !grepl("<", result$estimate_value)
      }
      n <- decimals[nm] |> unname()
      result$estimate_value[id] <- result$estimate_value[id] |>
        as.numeric() |>
        round(digits = n) |>
        base::format(nsmall = n, big.mark = bigMark, decimal.mark = decimalMark,
                     trim = TRUE, justify = "none", scientific = FALSE)
      formatted[id] <- TRUE
    }
  }
  return(result)
}

# formatHeader.R -----
formatHeader <- function(result,
                         header,
                         delim = "\n",
                         includeHeaderName = TRUE,
                         includeHeaderKey = TRUE) {
  # initial checks
  omopgenerics::assertTable(result, columns = "estimate_value")
  omopgenerics::assertCharacter(header, null = TRUE)
  omopgenerics::assertCharacter(delim, length = 1)
  omopgenerics::assertLogical(includeHeaderName, length = 1)
  originalCols <- colnames(result)
  if (length(header) > 0) {
    # correct names
    nms <- names(header)
    if (is.null(nms)) {
      nms <- rep("", length(header))
    }
    nms[nms  == ""] <- header[nms  == ""]
    # pivot wider
    cols <- header[header %in% colnames(result)] |> unname()
    if (length(cols) > 0) {
      colDetails <- result |>
        dplyr::select(dplyr::all_of(cols)) |>
        dplyr::distinct() |>
        dplyr::mutate("name" = sprintf("column%03i", dplyr::row_number()))
      result <- result |>
        dplyr::inner_join(colDetails, by = cols) |>
        dplyr::select(-dplyr::all_of(cols)) |>
        tidyr::pivot_wider(names_from = "name", values_from = "estimate_value")
      columns <- colDetails$name
      # create column names
      colDetails <- colDetails |> dplyr::mutate(new_name = "")
      for (k in seq_along(header)) {
        if (header[k] %in% cols) { # Header in dataframe
          spanners <- colDetails[[header[k]]] |> unique()
          for (span in spanners) { # loop through column values
            if (!is.na(span)) {
              colsSpanner <- colDetails[[header[k]]] == span
              if (includeHeaderKey) {
                if (includeHeaderName) {
                  colDetails$new_name[colsSpanner] <- paste0(colDetails$new_name[colsSpanner], "[header_name]", nms[k], delim, "[header_level]", span, delim)
                } else {
                  colDetails$new_name[colsSpanner] <- paste0(colDetails$new_name[colsSpanner], "[header_level]", span, delim)
                }
              } else {
                if (includeHeaderName) {
                  colDetails$new_name[colsSpanner] <- paste0(colDetails$new_name[colsSpanner], nms[k], delim, span, delim)
                } else {
                  colDetails$new_name[colsSpanner] <- paste0(colDetails$new_name[colsSpanner], span, delim)
                }
              }
            } else {
              cli::cli_abort(paste0("There are missing levels in '", header[k], "'."))
            }
          }
        } else {
          if (includeHeaderKey) {
            colDetails$new_name <- paste0(colDetails$new_name, "[header]", nms[k], delim)
          } else {
            colDetails$new_name <- paste0(colDetails$new_name, nms[k], delim)
          }
        }
      }
      colDetails <- colDetails |> dplyr::mutate(new_name = base::substring(.data$new_name, 0, nchar(.data$new_name)-1))
      # add column names
      names(result)[names(result) %in% colDetails$name] <- colDetails$new_name
    } else {
      if (includeHeaderKey) {
        new_name <- paste0("[header]", paste(header, collapse = paste0(delim, "[header]")))
      } else {
        new_name <- paste(header, collapse = delim)
      }
      result <- result |> dplyr::rename(!!new_name := "estimate_value")
      class(result) <- c("tbl_df", "tbl", "data.frame")
    }
  }
  newCols <- colnames(result)[!colnames(result) %in% originalCols]
  # send new cols to end
  result <- result |>
    dplyr::relocate(dplyr::any_of(newCols), .after = dplyr::last_col())
  return(result)
}

# formatTable.R -----
formatTable <- function(x,
                        type = "gt",
                        delim = "\n",
                        style = "default",
                        na = "-",
                        title = NULL,
                        subtitle = NULL,
                        caption = NULL,
                        groupColumn = NULL,
                        groupAsColumn = FALSE,
                        groupOrder = NULL,
                        merge = NULL
) {
  # Input checks
  omopgenerics::assertChoice(type, choices = c("gt", "flextable"), length = 1)
  omopgenerics::assertTable(x)
  omopgenerics::assertCharacter(na, length = 1, null = TRUE)
  omopgenerics::assertCharacter(title, length = 1, null = TRUE)
  omopgenerics::assertCharacter(subtitle, length = 1, null = TRUE)
  omopgenerics::assertCharacter(caption, length = 1, null= TRUE)
  omopgenerics::assertLogical(groupAsColumn, length = 1)
  omopgenerics::assertCharacter(groupOrder, null = TRUE)
  delim <- validateDelim(delim)
  groupColumn <- validateGroupColumn(groupColumn, colnames(x))
  merge <- validateMerge(x, merge, groupColumn[[1]])
  style <- validateStyle(style, type)
  if (is.null(title) & !is.null(subtitle)) {
    cli::cli_abort("There must be a title for a subtitle.")
  }
  if (dplyr::is.grouped_df(x)) {
    x <- x |> dplyr::ungroup()
    cli::cli_inform("`x` will be ungrouped.")
  }
  # format
  if (type == "gt") {
    x <- x |>
      gtTableInternal(
        delim = delim,
        style = style,
        na = na,
        title = title,
        subtitle = subtitle,
        caption = caption,
        groupColumn = groupColumn,
        groupAsColumn = groupAsColumn,
        groupOrder = groupOrder,
        merge = merge
      )
  } else if (type == "flextable") {
    x <- x |>
      fxTableInternal(
        delim = delim,
        style = style,
        na = na,
        title = title,
        subtitle = subtitle,
        caption = caption,
        groupColumn = groupColumn,
        groupAsColumn = groupAsColumn,
        groupOrder = groupOrder,
        merge = merge
      )
  }
  return(x)
}

# fxTable.R -----
fxTable <- function(x,
                    delim = "\n",
                    style = "default",
                    na = "-",
                    title = NULL,
                    subtitle = NULL,
                    caption = NULL,
                    groupColumn = NULL,
                    groupAsColumn = FALSE,
                    groupOrder = NULL,
                    colsToMergeRows = NULL) {
  x |>
    formatTable(
      type = "flextable",
      delim = delim,
      style = style,
      na = na,
      title = title,
      subtitle = subtitle,
      caption = caption,
      groupColumn = groupColumn,
      groupAsColumn = groupAsColumn,
      groupOrder = groupOrder,
      merge = colsToMergeRows
    )
}
fxTableInternal <- function(x,
                            delim = "\n",
                            style = "default",
                            na = "-",
                            title = NULL,
                            subtitle = NULL,
                            caption = NULL,
                            groupColumn = NULL,
                            groupAsColumn = FALSE,
                            groupOrder = NULL,
                            merge = NULL) {
  # Package checks
  rlang::check_installed("flextable")
  rlang::check_installed("officer")
  # na
  if (!is.null(na)) {
    x <- x |>
      dplyr::mutate(
        dplyr::across(dplyr::where(~ is.numeric(.x)), ~ as.character(.x)),
        dplyr::across(colnames(x), ~ dplyr::if_else(is.na(.x), na, .x))
      )
  }
  # Flextable
  if (length(groupColumn[[1]]) == 0) {
    # Header id's
    spanCols_ids <- which(grepl("\\[header\\]|\\[header_level\\]|\\[header_name\\]|\\[column_name\\]", colnames(x)))
    spanners <- strsplit(colnames(x)[spanCols_ids[1]], delim) |> unlist()
    header_rows <- which(grepl("\\[header\\]", spanners))
    header_name_rows <- which(grepl("\\[header_name\\]", spanners))
    header_level_rows <- which(grepl("\\[header_level\\]", spanners))
    # Eliminate prefixes
    colnames(x) <- gsub("\\[header\\]|\\[header_level\\]|\\[header_name\\]|\\[column_name\\]", "", colnames(x))
    # flextable
    flex_x <- x |>
      flextable::flextable() |>
      flextable::separate_header(split = delim)
    nameGroup <- NULL
  } else {
    nameGroup <- names(groupColumn)
    x <- x |>
      tidyr::unite(
        !!nameGroup, groupColumn[[1]], sep = "; ", remove = TRUE, na.rm = TRUE
      )
    groupLevel <- unique(x[[nameGroup]])
    if (!is.null(groupOrder)) {
      if (any(!groupLevel %in% groupOrder)) {
        cli::cli_abort(c(
          "x" = "`groupOrder` supplied does not macth the group variable created based on `groupName`.",
          "i" = "Group variables to use in `groupOrder` are the following: {groupLevel}"
        ))
      } else {
        groupLevel <- groupOrder
      }
    }
    x <- x |>
      dplyr::mutate(!!nameGroup := factor(.data[[nameGroup]], levels = groupLevel)) |>
      dplyr::arrange_at(nameGroup) |>
      dplyr::relocate(dplyr::all_of(nameGroup))
    # Header id's
    spanCols_ids <- which(grepl("\\[header\\]|\\[header_level\\]|\\[header_name\\]|\\[column_name\\]", colnames(x)))
    spanners <- strsplit(colnames(x)[spanCols_ids[1]], delim) |> unlist()
    header_rows <- which(grepl("\\[header\\]", spanners))
    header_name_rows <- which(grepl("\\[header_name\\]", spanners))
    header_level_rows <- which(grepl("\\[header_level\\]", spanners))
    # Eliminate prefixes
    colnames(x) <- gsub("\\[header\\]|\\[header_level\\]|\\[header_name\\]|\\[column_name\\]", "", colnames(x))
    if (groupAsColumn) {
      flex_x <- x |>
        flextable::flextable() |>
        flextable::merge_v(j = nameGroup) |>
        flextable::separate_header(split = delim)
    } else {
      flex_x <- x |>
        flextable::as_grouped_data(groups = nameGroup) |>
        flextable::flextable() |>
        flextable::separate_header(split = delim)
      nonNaIndices <- getNonNaIndices(flex_x$body$dataset, nameGroup)
      flex_x <- flex_x |> flextable::merge_h(i = nonNaIndices, part = "body")
    }
  }
  # Headers
  if (length(header_rows) > 0 & "header" %in% names(style)) {
    flex_x <- flex_x |>
      flextable::style(
        part = "header", i = header_rows, j = spanCols_ids, pr_t = style$header$text,
        pr_c = style$header$cell, pr_p = style$header$paragraph
      )
  }
  if (length(header_name_rows) > 0 & "header_name" %in% names(style)) {
    flex_x <- flex_x |>
      flextable::style(
        part = "header", i = header_name_rows, j = spanCols_ids, pr_t = style$header_name$text,
        pr_c = style$header_name$cell, pr_p = style$header_name$paragraph
      )
  }
  if (length(header_level_rows) > 0 & "header_level" %in% names(style)) {
    flex_x <- flex_x |>
      flextable::style(
        part = "header", i = header_level_rows, j = spanCols_ids, pr_t = style$header_level$text,
        pr_c = style$header_level$cell, pr_p = style$header_level$paragraph
      )
  }
  if ("column_name" %in% names(style)) {
    flex_x <- flex_x |>
      flextable::style(
        part = "header", j = which(!1:ncol(x) %in% spanCols_ids),
        pr_t = style$column_name$text, pr_c = style$column_name$cell, pr_p = style$column_name$paragraph
      )
  }
  # Basic default + merge columns
  if (!is.null(merge)) { # style while merging rows
    flex_x <- fxMergeRows(flex_x, merge, nameGroup)
  } else {
    if (!length(groupColumn) == 0) { # style group different
      indRowGroup <- getNonNaIndices(flex_x$body$dataset, nameGroup)
      flex_x <- flex_x |>
        flextable::border(
          j = 1,
          i = indRowGroup,
          border = officer::fp_border(color = "gray"),
          part = "body"
        ) |>
        flextable::border(
          border = officer::fp_border(color = "gray"),
          j = 2:ncol(x),
          part = "body"
        ) |>
        flextable::border(
          j = 1,
          border.left = officer::fp_border(color = "gray"),
          part = "body"
        ) |>
        flextable::border( # correct group level bottom
          i = nrow(flex_x$body$dataset),
          border.bottom = officer::fp_border(color = "gray"),
          part = "body"
        ) |>
        flextable::border( # correct group level right border
          i = which(!is.na(flex_x$body$dataset[[nameGroup]])),
          j = 1,
          border.right = officer::fp_border(color = "transparent"),
          part = "body"
        )
    } else { # style body equally
      flex_x <- flex_x |>
        flextable::border(
          border = officer::fp_border(color = "gray"),
          part = "body"
        )
    }
  }
  flex_x <- flex_x |>
    flextable::border(
      border = officer::fp_border(color = "gray", width = 1.2),
      part = "header",
      i = 1:nrow(flex_x$header$dataset)
    ) |>
    flextable::align(part = "header", align = "center") |>
    flextable::valign(part = "header", valign = "center") |>
    flextable::align(j = spanCols_ids, part = "body", align = "right") |>
    flextable::align(j = which(!1:ncol(x) %in% spanCols_ids), part = "body", align = "left")
  # Other options:
  # caption
  if (!is.null(caption)) {
    flex_x <- flex_x |>
      flextable::set_caption(caption = caption)
  }
  # title + subtitle
  if (!is.null(title) & !is.null(subtitle)) {
    if (!"title" %in% names(style)) {
      style$title <- list(
        "text" = officer::fp_text(bold = TRUE, font.size = 13),
        "paragraph" = officer::fp_par(text.align = "center")
      )
    }
    if (!"subtitle" %in% names(style)) {
      style$subtitle <- list(
        "text" = officer::fp_text(bold = TRUE, font.size = 11),
        "paragraph" = officer::fp_par(text.align = "center")
      )
    }
    flex_x <- flex_x |>
      flextable::add_header_lines(values = subtitle) |>
      flextable::add_header_lines(values = title) |>
      flextable::style(
        part = "header", i = 1, pr_t = style$title$text,
        pr_p = style$title$paragraph, pr_c = style$title$cell
      ) |>
      flextable::style(
        part = "header", i = 2, pr_t = style$subtitle$text,
        pr_p = style$subtitle$paragraph, pr_c = style$subtitle$cell
      )
  }
  # title
  if (!is.null(title) & is.null(subtitle)) {
    if (!"title" %in% names(style)) {
      style$title <- list(
        "text" = officer::fp_text(bold = TRUE, font.size = 13),
        "paragraph" = officer::fp_par(text.align = "center")
      )
    }
    flex_x <- flex_x |>
      flextable::add_header_lines(values = title) |>
      flextable::style(
        part = "header", i = 1, pr_t = style$title$text,
        pr_p = style$title$paragraph, pr_c = style$title$cell
      )
  }
  # body
  flex_x <- flex_x |>
    flextable::style(
      part = "body", pr_t = style$body$text,
      pr_p = style$body$paragraph, pr_c = style$body$cell
    )
  # group label
  if (length(groupColumn[[1]]) != 0) {
    if (!groupAsColumn) {
      nonNaIndices <- getNonNaIndices(flex_x$body$dataset, nameGroup)
      flex_x <- flex_x |>
        flextable::style(
          part = "body",
          i = nonNaIndices,
          pr_t = style$group_label$text, pr_p = style$group_label$paragraph, pr_c = style$group_label$cell
        )
    } else {
      flex_x <- flex_x |>
        flextable::style(
          part = "body", j = which(colnames(flex_x$body$dataset) %in% nameGroup),
          pr_t = style$group_label$text, pr_p = style$group_label$paragraph, pr_c = style$group_label$cell
        )
    }
  }
  return(flex_x)
}
getNonNaIndices <- function(x, nameGroup) {
  which(!is.na(x[[nameGroup]]))
}
flextableStyleInternal <- function(styleName) {
  styles <- list(
    "default" = list(
      "header" = list(
        "cell" = officer::fp_cell(background.color = "#c8c8c8"),
        "text" = officer::fp_text(bold = TRUE)
      ),
      "header_name" = list(
        "cell" = officer::fp_cell(background.color = "#d9d9d9"),
        "text" = officer::fp_text(bold = TRUE)
      ),
      "header_level" = list(
        "cell" = officer::fp_cell(background.color = "#e1e1e1"),
        "text" = officer::fp_text(bold = TRUE)
      ),
      "column_name" = list(
        "text" = officer::fp_text(bold = TRUE)
      ),
      "group_label" = list(
        "cell" = officer::fp_cell(
          background.color = "#e9e9e9",
          border = officer::fp_border(color = "gray")
        ),
        "text" = officer::fp_text(bold = TRUE)
      ),
      "title" = list(
        "text" = officer::fp_text(bold = TRUE, font.size = 15)
      ),
      "subtitle" = list(
        "text" = officer::fp_text(bold = TRUE, font.size = 12)
      ),
      "body" = list()
    )
  )
  if (!styleName %in% names(styles)) {
    cli::cli_inform(c("i" = "{styleName} does not correspon to any of our defined styles. Returning default style."))
    styleName <- "default"
  }
  return(styles[[styleName]])
}
fxMergeRows <- function(fx_x, merge, groupColumn) {
  colNms <- colnames(fx_x$body$dataset)
  if (merge[1] == "all_columns") {
    if (length(groupColumn) == 0) {
      merge <- colNms
    } else {
      merge <- colNms[!colNms %in% groupColumn]
    }
  }
  # Sort columns to merge
  ind <- match(merge, colNms)
  names(ind) <- merge
  merge <- names(sort(ind))
  # Fill group column if necessary
  indColGroup <- NULL
  indRowGroup <- NULL
  if (!length(groupColumn) == 0) {
    groupCol <- fx_x$body$dataset |>
      dplyr::select(dplyr::all_of(groupColumn)) |>
      dplyr::mutate(dplyr::across(dplyr::everything(), as.character))
    groupColsMatrix <- as.matrix(groupCol)
    indRowGroup <- which(rowSums(!is.na(groupColsMatrix)) > 0)
    filledGroupColsList <- lapply(groupColumn, function(col) {
      groupCol <- as.character(fx_x$body$dataset[[col]])
      for (k in 2:length(groupCol)) {
        if (is.na(groupCol[k])) {
          groupCol[k] <- groupCol[k - 1]
        }
      }
      return(groupCol)
    })
    groupColsMatrix <- do.call(cbind, filledGroupColsList)
    groupCol <- as.data.frame(groupColsMatrix, stringsAsFactors = FALSE)
    indColGroup <- which(colnames(fx_x$body$dataset) %in% groupColumn)
  }
  for (k in seq_along(merge)) {
    if (k > 1) {
      prevMerged <- mergeCol
      prevId <- prevMerged == dplyr::lag(prevMerged) & prevId
    } else {
      prevId <- rep(TRUE, nrow(fx_x$body$dataset))
    }
    col <- merge[k]
    mergeCol <- fx_x$body$dataset[[col]]
    mergeCol[is.na(mergeCol)] <- "this is NA"
    if (length(groupColumn) == 0) {
      id <- which(mergeCol == dplyr::lag(mergeCol) & prevId)
    } else {
      id <- which(groupCol == dplyr::lag(groupCol) & mergeCol == dplyr::lag(mergeCol) & prevId)
    }
    # Apply merging and borders
    if (length(id) > 0) {
      fx_x <- fx_x |>
        flextable::compose(i = id, j = ind[k],
                           flextable::as_paragraph(flextable::as_chunk("")))
    }
    fx_x <- fx_x |>
      flextable::border(
        i = which(!1:nrow(fx_x$body$dataset) %in% id),
        j = ind[k],
        border.top = officer::fp_border(color = "gray"),
        part = "body"
      )
  }
  # Style the rest of the table
  fx_x <- fx_x |>
    flextable::border(
      j = which(!1:ncol(fx_x$body$dataset) %in% c(ind, indColGroup)),
      border.top = officer::fp_border(color = "gray"),
      part = "body"
    ) |>
    flextable::border(
      j = 1:ncol(fx_x$body$dataset),
      border.right = officer::fp_border(color = "gray"),
      part = "body"
    ) |>
    flextable::border(
      j = 1,
      border.left = officer::fp_border(color = "gray"),
      part = "body"
    ) |>
    flextable::border( # Correct bottom border
      i = nrow(fx_x$body$dataset),
      border.bottom = officer::fp_border(color = "gray"),
      part = "body"
    )
  if (!length(groupColumn) == 0) {
    fx_x <- fx_x |>
      flextable::border(
        j = indColGroup,
        i = indRowGroup,
        border = officer::fp_border(color = "gray"),
        part = "body"
      ) |>
      flextable::border(
        i = getNonNaIndices(fx_x$body$dataset, groupColumn),
        j = 1,
        border.right = officer::fp_border(color = "transparent"),
        part = "body"
      )
  }
  return(fx_x)
}
flextableStyle <- function(styleName = "default") {
  list(
    "header" = list(
      "cell" = officer::fp_cell(background.color = "#c8c8c8"),
      "text" = officer::fp_text(bold = TRUE)
    ),
    "header_name" = list(
      "cell" = officer::fp_cell(background.color = "#d9d9d9"),
      "text" = officer::fp_text(bold = TRUE)
    ),
    "header_level" = list(
      "cell" = officer::fp_cell(background.color = "#e1e1e1"),
      "text" = officer::fp_text(bold = TRUE)
    ),
    "column_name" = list(
      "text" = officer::fp_text(bold = TRUE)
    ),
    "group_label" = list(
      "cell" = officer::fp_cell(
        background.color = "#e9e9e9",
        border = officer::fp_border(color = "gray")
      ),
      "text" = officer::fp_text(bold = TRUE)
    ),
    "title" = list(
      "text" = officer::fp_text(bold = TRUE, font.size = 15)
    ),
    "subtitle" = list(
      "text" = officer::fp_text(bold = TRUE, font.size = 12)
    ),
    "body" = list()
  ) |>
    rlang::expr()
}

# gtTable.R -----
gtTable <- function(x,
                    delim = "\n",
                    style = "default",
                    na = "-",
                    title = NULL,
                    subtitle = NULL,
                    caption = NULL,
                    groupColumn = NULL,
                    groupAsColumn = FALSE,
                    groupOrder = NULL,
                    colsToMergeRows = NULL) {
  x |>
    formatTable(
      type = "gt",
      delim = delim,
      style = style,
      na = na,
      title = title,
      subtitle = subtitle,
      caption = caption,
      groupColumn = groupColumn,
      groupAsColumn = groupAsColumn,
      groupOrder = groupOrder,
      merge = colsToMergeRows
    )
}
gtTableInternal <- function(x,
                            delim = "\n",
                            style = "default",
                            na = "-",
                            title = NULL,
                            subtitle = NULL,
                            caption = NULL,
                            groupColumn = NULL,
                            groupAsColumn = FALSE,
                            groupOrder = NULL,
                            merge = NULL
) {
  # Package checks
  rlang::check_installed("gt")
  # na
  if (!is.null(na)){
    x <- x |>
      dplyr::mutate(
        dplyr::across(dplyr::where(~is.numeric(.x)), ~as.character(.x)),
        dplyr::across(colnames(x), ~ dplyr::if_else(is.na(.x), na, .x))
      )
  }
  # Spanners
  if (length(groupColumn[[1]]) != 0) {
    nameGroup <- names(groupColumn)
    x <- x |>
      tidyr::unite(
        !!nameGroup, groupColumn[[1]], sep = "; ", remove = TRUE, na.rm = TRUE
      )
    groupLevel <- unique(x[[nameGroup]])
    if (!is.null(groupOrder)) {
      if (any(!groupLevel %in% groupOrder)) {
        cli::cli_abort(c(
          "x" = "`groupOrder` supplied does not macth the group variable created based on `groupName`.",
          "i" = "Group variables to use in `groupOrder` are the following: {groupLevel}"
        ))
      } else {
        groupLevel <- groupOrder
      }
    }
    x <- x |>
      dplyr::mutate(!!nameGroup := factor(.data[[nameGroup]], levels = groupLevel)) |>
      dplyr::arrange_at(nameGroup) |>
      dplyr::relocate(dplyr::all_of(nameGroup))
    gtResult <- x |>
      gt::gt(groupname_col = nameGroup, row_group_as_column = groupAsColumn) |>
      gt::tab_spanner_delim(delim = delim) |>
      gt::row_group_order(groups = groupLevel)
  } else {
    gtResult <- x |> gt::gt() |> gt::tab_spanner_delim(delim = delim)
  }
  # Header style
  spanner_ids <- gtResult$`_spanners`$spanner_id
  style_ids <- lapply(strsplit(spanner_ids, delim), function(vect){vect[[1]]}) |> unlist()
  header_id <- grepl("\\[header\\]", style_ids)
  header_name_id <- grepl("\\[header_name\\]", style_ids)
  header_level_id <- grepl("\\[header_level\\]", style_ids)
  if (length(c(header_id, header_name_id, header_level_id)) == 0) {
    columnHeader <- TRUE
    colum_header_id <-  which(grepl("\\[header\\]|\\[header_level\\]|\\[header_name\\]", colnames(x)))
  } else {
    columnHeader <- FALSE
    colum_header_id <-  numeric()
  }
  # column names in spanner
  header_level <- all(grepl("header_level", lapply(strsplit(colnames(x)[grepl("header", colnames(x))], delim), function(x) {x[length(x)]}) |> unlist()))
  if (sum(header_id) > 0 & "header" %in% names(style)) {
    gtResult <- gtResult |>
      gt::tab_style(
        style = style$header,
        locations = gt::cells_column_spanners(spanners = spanner_ids[header_id])
      )
    if (!header_level) {
      gtResult <- gtResult |>
        gt::tab_style(
          style = style$header,
          locations = gt::cells_column_labels(columns = which(grepl("\\[header\\]", colnames(x))))
        )
    }
  }
  if (sum(header_name_id) > 0 & "header_name" %in% names(style)) {
    gtResult <- gtResult |>
      gt::tab_style(
        style = style$header_name,
        locations = gt::cells_column_spanners(spanners = spanner_ids[header_name_id])
      )
  }
  if ("header_level" %in% names(style)) {
    if (sum(header_level_id) > 0) {
      gtResult <- gtResult |>
        gt::tab_style(
          style = style$header_level,
          locations = gt::cells_column_spanners(spanners = spanner_ids[header_level_id])
        )
    }
    if (header_level) {
      gtResult <- gtResult |>
        gt::tab_style(
          style = style$header_level,
          locations = gt::cells_column_labels(columns = which(grepl("\\[header_level\\]", colnames(x))))
        )
    }
  }
  if ("column_name" %in% names(style)) {
    col_name_ids <- which(!grepl("\\[header\\]|\\[header_level\\]|\\[header_name\\]", colnames(x)))
    gtResult <- gtResult |>
      gt::tab_style(
        style = style$column_name,
        locations = gt::cells_column_labels(columns = col_name_ids)
      )
    if (columnHeader & length(colum_header_id) > 0) {
      gtResult <- gtResult |>
        gt::tab_style(
          style = style$column_name,
          locations = gt::cells_column_labels(columns = colum_header_id)
        )
    }
  }
  # Eliminate prefixes
  gtResult$`_spanners`$spanner_label <- lapply(gtResult$`_spanners`$spanner_label,
                                               function(label){
                                                 gsub("\\[header\\]|\\[header_level\\]|\\[header_name\\]|\\[column_name\\]", "", label)
                                               })
  gtResult <- gtResult |> gt::cols_label_with(columns = tidyr::contains("header"),
                                              fn = ~ gsub("\\[header\\]|\\[header_level\\]", "", .))
  # Our default:
  gtResult <- gtResult |>
    gt::tab_style(
      style = gt::cell_text(align = "right"),
      locations = gt::cells_body(columns = which(grepl("\\[header\\]|\\[header_level\\]|\\[header_name\\]|\\[column_name\\]", colnames(x))))
    ) |>
    gt::tab_style(
      style = gt::cell_text(align = "left"),
      locations = gt::cells_body(columns = which(!grepl("\\[header\\]|\\[header_level\\]|\\[header_name\\]|\\[column_name\\]", colnames(x))))
    ) |>
    gt::tab_style(
      style = list(gt::cell_borders(color = "#D3D3D3")),
      locations = list(gt::cells_body(columns = 2:(ncol(x)-1)))
    )
  # Merge rows
  if (!is.null(merge)) {
    gtResult <- gtMergeRows(gtResult, merge, names(groupColumn), groupOrder)
  }
  # Other options:
  ## na
  # if (!is.null(na)){
  #   # gtResult <- gtResult |> gt::sub_missing(missing_text = na)
  # }
  ## caption
  if(!is.null(caption)){
    gtResult <- gtResult |>
      gt::tab_caption(
        caption = gt::md(caption)
      )
  }
  ## title + subtitle
  if(!is.null(title) & !is.null(subtitle)){
    gtResult <- gtResult |>
      gt::tab_header(
        title = title,
        subtitle = subtitle
      )
    if ("title" %in% names(style)) {
      gtResult <- gtResult |>
        gt::tab_style(
          style = style$title,
          locations = gt::cells_title(groups = "title")
        )
    }
    if ("subtitle" %in% names(style)) {
      gtResult <- gtResult |>
        gt::tab_style(
          style = style$subtitle,
          locations = gt::cells_title(groups = "subtitle")
        )
    }
  }
  ## title
  if(!is.null(title)  & is.null(subtitle)){
    gtResult <- gtResult |>
      gt::tab_header(
        title = title
      )
    if ("title" %in% names(style)) {
      gtResult <- gtResult |>
        gt::tab_style(
          style = style$title,
          locations = gt::cells_title(groups = "title")
        )
    }
  }
  ## body
  if ("body" %in% names(style)) {
    gtResult <- gtResult |>
      gt::tab_style(
        style = style$body,
        locations = gt::cells_body()
      )
  }
  ## group_label
  if ("group_label" %in% names(style)) {
    gtResult <- gtResult |>
      gt::tab_style(
        style = style$group_label,
        locations = gt::cells_row_groups()
      )
  }
  return(gtResult)
}
gtStyleInternal <- function(styleName) {
  styles <- list (
    "default" = list(
      "header" = list(gt::cell_fill(color = "#c8c8c8"),
                      gt::cell_text(weight = "bold", align = "center")),
      "header_name" = list(gt::cell_fill(color = "#d9d9d9"),
                           gt::cell_text(weight = "bold", align = "center")),
      "header_level" = list(gt::cell_fill(color = "#e1e1e1"),
                            gt::cell_text(weight = "bold", align = "center")),
      "column_name" = list(gt::cell_text(weight = "bold", align = "center")),
      "group_label" = list(gt::cell_fill(color = "#e9e9e9"),
                           gt::cell_text(weight = "bold")),
      "title" = list(gt::cell_text(weight = "bold", size = 15, align = "center")),
      "subtitle" = list(gt::cell_text(weight = "bold", size = 12, align = "center")),
      "body" = list()
    )
  )
  if (!styleName %in% names(styles)) {
    cli::cli_inform(c("i" = "{styleName} does not correspon to any of our defined styles. Returning default style."))
    styleName <- "default"
  }
  return(styles[[styleName]])
}
gtMergeRows <- function(gt_x, merge, groupColumn, groupOrder) {
  colNms <- colnames(gt_x$`_data`)
  colsToExclude <- c("group_label", paste(groupColumn, collapse = "_"))
  if (merge[1] == "all_columns") {
    if (length(groupColumn) == 0) {
      merge <- colNms[!colNms %in% colsToExclude]
    } else {
      merge <- colNms[!colNms %in% c(groupColumn, colsToExclude)]
    }
  }
  # sort
  ind <- match(merge, colNms)
  names(ind) <- merge
  merge <- names(sort(ind))
  for (k in seq_along(merge)) {
    if (k > 1) {
      prevMerged <- mergeCol
      prevId <- prevMerged == dplyr::lag(prevMerged) & prevId
    } else {
      prevId <- rep(TRUE, nrow(gt_x$`_data`))
    }
    col <- merge[k]
    mergeCol <- as.character(gt_x$`_data`[[col]])
    mergeCol[is.na(mergeCol)] <- "-"
    if (length(groupColumn) == 0) {
      id <- which(mergeCol == dplyr::lag(mergeCol) & prevId)
    } else {
      groupCol <- apply(gt_x$`_data`[, groupColumn, drop = FALSE], 1, paste, collapse = "_")
      lagGroupCol <- dplyr::lag(groupCol)
      id <- which(groupCol == lagGroupCol & mergeCol == dplyr::lag(mergeCol) & prevId)
    }
    gt_x$`_data`[[col]][id] <- ""
    gt_x <- gt_x |>
      gt::tab_style(
        style = list(gt::cell_borders(style = "hidden", sides = "top")),
        locations = list(gt::cells_body(columns = col, rows = id))
      )
  }
  return(gt_x)
}
gtStyle <- function(styleName = "default") {
  list(
    "header" = list(gt::cell_fill(color = "#c8c8c8"),
                    gt::cell_text(weight = "bold", align = "center")),
    "header_name" = list(gt::cell_fill(color = "#d9d9d9"),
                         gt::cell_text(weight = "bold", align = "center")),
    "header_level" = list(gt::cell_fill(color = "#e1e1e1"),
                          gt::cell_text(weight = "bold", align = "center")),
    "column_name" = list(gt::cell_text(weight = "bold", align = "center")),
    "group_label" = list(gt::cell_fill(color = "#e9e9e9"),
                         gt::cell_text(weight = "bold")),
    "title" = list(gt::cell_text(weight = "bold", size = 15, align = "center")),
    "subtitle" = list(gt::cell_text(weight = "bold", size = 12, align = "center")),
    "body" = list()
  ) |>
    rlang::expr()
}

# mockResults.R -----
mockSummarisedResult <- function() {
  # TO modify when PatientProfiles works with omopgenerics
  # number subjects
  result <- dplyr::tibble(
    "cdm_name" = "mock",
    "group_name" = "cohort_name",
    "group_level" = c(rep("cohort1", 9), rep("cohort2", 9)),
    "strata_name" = rep(c(
      "overall", rep("age_group &&& sex", 4), rep("sex", 2), rep("age_group", 2)
    ), 2),
    "strata_level" = rep(c(
      "overall", "<40 &&& Male", ">=40 &&& Male", "<40 &&& Female",
      ">=40 &&& Female", "Male", "Female", "<40", ">=40"
    ), 2),
    "variable_name" = "number subjects",
    "variable_level" = NA_character_,
    "estimate_name" = "count",
    "estimate_type" = "integer",
    "estimate_value" = round(10000000*stats::runif(18)) |> as.character(),
    "additional_name" = "overall",
    "additional_level" = "overall"
  ) |>
    # age - mean
    dplyr::union_all(
      dplyr::tibble(
        "cdm_name" = "mock",
        "group_name" = "cohort_name",
        "group_level" = c(rep("cohort1", 9), rep("cohort2", 9)),
        "strata_name" = rep(c(
          "overall", rep("age_group &&& sex", 4), rep("sex", 2), rep("age_group", 2)
        ), 2),
        "strata_level" = rep(c(
          "overall", "<40 &&& Male", ">=40 &&& Male", "<40 &&& Female",
          ">=40 &&& Female", "Male", "Female", "<40", ">=40"
        ), 2),
        "variable_name" = "age",
        "variable_level" = NA_character_,
        "estimate_name" = "mean",
        "estimate_type" = "numeric",
        "estimate_value" = c(100*stats::runif(18)) |> as.character(),
        "additional_name" = "overall",
        "additional_level" = "overall"
      )
    )|>
    # age - standard deviation
    dplyr::union_all(
      dplyr::tibble(
        "cdm_name" = "mock",
        "group_name" = "cohort_name",
        "group_level" = c(rep("cohort1", 9), rep("cohort2", 9)),
        "strata_name" = rep(c(
          "overall", rep("age_group &&& sex", 4), rep("sex", 2), rep("age_group", 2)
        ), 2),
        "strata_level" = rep(c(
          "overall", "<40 &&& Male", ">=40 &&& Male", "<40 &&& Female",
          ">=40 &&& Female", "Male", "Female", "<40", ">=40"
        ), 2),
        "variable_name" = "age",
        "variable_level" = NA_character_,
        "estimate_name" = "sd",
        "estimate_type" = "numeric",
        "estimate_value" = c(10*stats::runif(18)) |> as.character(),
        "additional_name" = "overall",
        "additional_level" = "overall"
      )
    ) |>
    # medication - count
    dplyr::union_all(
      dplyr::tibble(
        "cdm_name" = "mock",
        "group_name" = "cohort_name",
        "group_level" = c(rep("cohort1", 9), rep("cohort2", 9)),
        "strata_name" = rep(c(
          "overall", rep("age_group &&& sex", 4), rep("sex", 2), rep("age_group", 2)
        ), 2),
        "strata_level" = rep(c(
          "overall", "<40 &&& Male", ">=40 &&& Male", "<40 &&& Female",
          ">=40 &&& Female", "Male", "Female", "<40", ">=40"
        ), 2),
        "variable_name" = "Medications",
        "variable_level" = "Amoxiciline",
        "estimate_name" = "count",
        "estimate_type" = "integer",
        "estimate_value" = round(100000*stats::runif(18)) |> as.character(),
        "additional_name" = "overall",
        "additional_level" = "overall"
      )
    ) |>
    # medication - percentage
    dplyr::union_all(
      dplyr::tibble(
        "cdm_name" = "mock",
        "group_name" = "cohort_name",
        "group_level" = c(rep("cohort1", 9), rep("cohort2", 9)),
        "strata_name" = rep(c(
          "overall", rep("age_group &&& sex", 4), rep("sex", 2), rep("age_group", 2)
        ), 2),
        "strata_level" = rep(c(
          "overall", "<40 &&& Male", ">=40 &&& Male", "<40 &&& Female",
          ">=40 &&& Female", "Male", "Female", "<40", ">=40"
        ), 2),
        "variable_name" = "Medications",
        "variable_level" = "Amoxiciline",
        "estimate_name" = "percentage",
        "estimate_type" = "percentage",
        "estimate_value" = c(100*stats::runif(18)) |> as.character(),
        "additional_name" = "overall",
        "additional_level" = "overall"
      )
    ) |>
    # medication - count
    dplyr::union_all(
      dplyr::tibble(
        "cdm_name" = "mock",
        "group_name" = "cohort_name",
        "group_level" = c(rep("cohort1", 9), rep("cohort2", 9)),
        "strata_name" = rep(c(
          "overall", rep("age_group &&& sex", 4), rep("sex", 2), rep("age_group", 2)
        ), 2),
        "strata_level" = rep(c(
          "overall", "<40 &&& Male", ">=40 &&& Male", "<40 &&& Female",
          ">=40 &&& Female", "Male", "Female", "<40", ">=40"
        ), 2),
        "variable_name" = "Medications",
        "variable_level" = "Ibuprofen",
        "estimate_name" = "count",
        "estimate_type" = "integer",
        "estimate_value" = round(100000*stats::runif(18)) |> as.character(),
        "additional_name" = "overall",
        "additional_level" = "overall"
      )
    ) |>
    # medication - percentage
    dplyr::union_all(
      dplyr::tibble(
        "cdm_name" = "mock",
        "group_name" = "cohort_name",
        "group_level" = c(rep("cohort1", 9), rep("cohort2", 9)),
        "strata_name" = rep(c(
          "overall", rep("age_group &&& sex", 4), rep("sex", 2), rep("age_group", 2)
        ), 2),
        "strata_level" = rep(c(
          "overall", "<40 &&& Male", ">=40 &&& Male", "<40 &&& Female",
          ">=40 &&& Female", "Male", "Female", "<40", ">=40"
        ), 2),
        "variable_name" = "Medications",
        "variable_level" = "Ibuprofen",
        "estimate_name" = "percentage",
        "estimate_type" = "percentage",
        "estimate_value" = c(100*stats::runif(18)) |> as.character(),
        "additional_name" = "overall",
        "additional_level" = "overall"
      )
    ) |>
    dplyr::mutate(result_id = as.integer(1)) |>
    omopgenerics::newSummarisedResult(
      settings = dplyr::tibble(
        "result_id" = as.integer(1),
        "result_type" = "mock_summarised_result",
        "package_name" = "visOmopResults",
        "package_version" = utils::packageVersion("visOmopResults") |>
          as.character()
      )
    )
  return(result)
}

# pivotEstimates.R -----
pivotEstimates <- function(result,
                           pivotEstimatesBy = "estimate_name",
                           nameStyle = NULL) {
  # initial checks
  pivotEstimatesBy <- validatePivotEstimatesBy(pivotEstimatesBy = pivotEstimatesBy)
  omopgenerics::assertCharacter(nameStyle, null = TRUE, length = 1)
  omopgenerics::assertTable(result, columns = pivotEstimatesBy)
  # pivot estimates
  result_out <- result
  if (length(pivotEstimatesBy) > 0) {
    if (is.null(nameStyle)) {
      nameStyle <- paste0("{", paste0(pivotEstimatesBy, collapse = "}_{"), "}")
    }
    if(grepl("__", nameStyle)){
      cli::cli_warn(c("!" = "Double underscores found in 'nameStyle'. Converting to a single underscore."))
    }
    typeNameConvert <- result |>
      dplyr::distinct(dplyr::across(dplyr::all_of(c("estimate_type", pivotEstimatesBy)))) |>
      dplyr::mutate(
        estimate_type = dplyr::case_when(
          grepl("percentage|proportion", .data$estimate_type) ~ "numeric",
          "date" == .data$estimate_type ~ "Date",
          .default = .data$estimate_type
        ),
        new_name = glue::glue(nameStyle, .na = "") |>
          stringr::str_replace_all("_+", "_") |> #remove multiple _
          stringr::str_replace_all("^_|_$", "") #remove leading/trailing _
      )
    result_out <- result |>
      dplyr::select(-"estimate_type") |>
      tidyr::pivot_wider(
        names_from = dplyr::all_of(pivotEstimatesBy),
        values_from = "estimate_value",
        names_glue = nameStyle
      ) |>
      dplyr::rename_with(~ stringr::str_remove_all(., "_NA|NA_")) |>
      dplyr::mutate(
        dplyr::across(dplyr::all_of(typeNameConvert$new_name),
                      ~ asEstimateType(.x, name = deparse(substitute(.)), dict = typeNameConvert)
        )
      )
  }
  return(result_out)
}
asEstimateType <- function(x, name, dict) {
  type <- dict$estimate_type[dict$new_name == name]
  return(eval(parse(text = paste0("as.", type, "(x)"))))
}
pivotLongerType <- function(result,
                            cols,
                            prefix = "estimate") {
  # initial checks
  omopgenerics::assertCharacter(cols)
  if (length(cols) == 0) {
    cli::cli_abort("{.var cols} must select at least one column.")
  }
  omopgenerics::assertTable(result, class = "data.frame", columns = cols)
  omopgenerics::assertCharacter(prefix, length = 1)
  # new cols
  nms <- paste0(prefix, "_name")
  typ <- paste0(prefix, "_type")
  vls <- paste0(prefix, "_value")
  pos <- which(colnames(result) %in% cols)[1]
  # pivot estimates
  types <- result |>
    dplyr::select(dplyr::all_of(cols)) |>
    purrr::map(\(x) getTypes(x))
  result |>
    dplyr::mutate(dplyr::across(dplyr::all_of(cols), as.character)) |>
    tidyr::pivot_longer(
      cols = dplyr::all_of(cols), names_to = nms, values_to = vls
    ) |>
    dplyr::mutate(!!!typeColumn(prefix, types)) |>
    dplyr::relocate(
      dplyr::all_of(c(paste0(prefix, c("_name", "_type", "_value")))),
      .before = !!pos
    )
}
getTypes <- function(x) {
  dplyr::type_sum(x) # do we want to add any conversion? which types do we want
  # to use?
}
typeColumn <- function(prefix, types) {
  paste0(
    "dplyr::case_when(",
    paste0(
      '.data[["', prefix, '_name"]] == "', names(types), '" ~ "', unlist(types),
      '"', collapse = ", "
    ),
    ")"
  ) |>
    rlang::parse_exprs() |>
    rlang::set_names(paste0(prefix, "_type"))
}

# plot.R -----
scatterPlot <- function(result,
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
boxPlot <- function(result,
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
barPlot <- function(result,
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
tidyResult <- function(result) {
  if (inherits(result, "summarised_result")) {
    result <- tidy(result) |>
      dplyr::select(!dplyr::any_of("result_id"))
  }
  return(result)
}
prepareColumns <- function(result,
                           cols,
                           facet,
                           call = parent.frame()) {
  opts <- colnames(result)
  # prepare columns
  varNames <- names(cols)
  newNames <- omopgenerics::uniqueId(n = length(cols), exclude = opts)
  for (k in seq_along(cols)) {
    result <- prepareColumn(
      result = result, newName = newNames[k], cols = cols[[k]],
      varName = varNames[k], opts = opts, call = call
    )
  }
  # variables to keep
  toSelect <- c(rlang::set_names(newNames, varNames), asCharacterFacet(facet))
  # select variables of interest
  result <- result |>
    dplyr::select(dplyr::all_of(toSelect))
  return(result)
}
prepareColumn <- function(result,
                          newName,
                          cols,
                          varName,
                          opts,
                          call) {
  if (is.null(cols)) {
    return(
      result |>
        dplyr::mutate(!!newName := "")
    )
  }
  if (!is.character(cols) || !all(cols %in% opts)) {
    c("x" = "{varName} ({.var {cols}}) is not a column in result.") |>
      cli::cli_abort(call = call)
  }
  if (length(cols) == 1) {
    result <- result |>
      dplyr::mutate(!!newName := .data[[cols]])
  } else {
    result <- result |>
      tidyr::unite(
        col = !!newName, dplyr::all_of(cols), remove = FALSE, sep = " - ")
  }
  return(result)
}
getAes <- function(cols) {
  if (is.null(cols$ymin)) cols$ymin <- NULL
  if (is.null(cols$ymax)) cols$ymax <- NULL
  vars <- names(cols)
  paste0(
    "ggplot2::aes(",
    glue::glue("{vars} = .data${vars}") |>
      stringr::str_c(collapse = ", "),
    ")"
  ) |>
    rlang::parse_expr() |>
    rlang::eval_tidy()
}
plotFacet <- function(p, facet) {
  if (!is.null(facet)) {
    if (is.character(facet)) {
      p <- p + ggplot2::facet_wrap(facets = facet)
    } else {
      p <- p + ggplot2::facet_grid(facet)
    }
  }
  return(p)
}
styleLabel <- function(x) {
  #length(x) > 0 remove the character(0)
  if (!is.null(x) && all(x != "") && length(x) > 0) {
    x |>
      stringr::str_replace_all(pattern = "_", replacement = " ") |>
      stringr::str_to_sentence() |>
      stringr::str_flatten(collapse = ", ", last = " and ")
  } else {
    NULL
  }
}
hideLegend <- function(x) {
  if (length(x) > 0 && !identical(x, "")) "right" else "none"
}
validateFacet <- function(x, call = parent.frame()) {
  if (rlang::is_formula(x)) return(invisible(NULL))
  omopgenerics::assertCharacter(x, null = TRUE)
  return(invisible(NULL))
}
warnMultipleValues <- function(result, cols) {
  nms <- names(cols)
  cols <- unique(unlist(cols))
  vars <- result |>
    dplyr::group_by(dplyr::across(dplyr::all_of(cols))) |>
    dplyr::group_split() |>
    as.list()
  vars <- vars[purrr::map_int(vars, nrow) > 1] |>
    purrr::map(\(x) {
      x <- purrr::map(x, unique)
      names(x)[lengths(x) > 1]
    }) |>
    unlist() |>
    unique()
  if (length(vars) > 0) {
    cli::cli_inform(c(
      "!" = "Multiple values of {.var {vars}} detected, consider including them
      in either: {.var {nms}}."
    ))
  }
  return(invisible(NULL))
}
asCharacterFacet <- function(facet) {
  if (rlang::is_formula(facet)) {
    facet <- as.character(facet)
    facet <- facet[-1]
    facet <- facet |>
      stringr::str_split(pattern = stringr::fixed(" + ")) |>
      unlist()
    facet <- facet[facet != "."]
  }
  return(facet)
}
cleanEstimates <- function(result, est) {
  if ("estimate_name" %in% colnames(result)) {
    est <- unique(est)
    result <- result |>
      dplyr::filter(.data$estimate_name %in% .env$est)
  }
  return(result)
}
checkInData <- function(result, est, call = parent.frame()) {
  cols <- colnames(result)
  if (inherits(result, "summarised_result") &
      all(omopgenerics::resultColumns("summarised_result") %in% cols)) {
    cols <- tidyColumns(result)
  }
  est <- unique(est)
  notPresent <- est[!est %in% cols]
  if (length(notPresent) > 0) {
    "{.var {notPresent}} {?is/are} not present in data." |>
      cli::cli_abort(call = call)
  }
  return(invisible(NULL))
}

# split.R -----
splitGroup <- function(result,
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
splitStrata <- function(result,
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
splitAdditional <- function(result,
                            keep = FALSE,
                            fill = "overall") {
  splitNameLevelInternal(
    result = result,
    name = "additional_name",
    level = "additional_level",
    keep = keep,
    fill = fill
  )
}
splitAll <- function(result,
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
splitNameLevel <- function(result,
                           name = "group_name",
                           level = "group_level",
                           keep = FALSE,
                           fill = "overall") {
  splitNameLevelInternal(
    result = result,
    name = name,
    level = level,
    keep = keep,
    fill = fill
  )
}
splitNameLevelInternal <- function(result,
                                   name = "group_name",
                                   level = "group_level",
                                   keep = FALSE,
                                   fill = "overall") {
  omopgenerics::assertCharacter(name, length = 1)
  omopgenerics::assertCharacter(level, length = 1)
  omopgenerics::assertLogical(keep, length = 1)
  omopgenerics::assertTable(result, columns = c(name, level))
  omopgenerics:: assertCharacter(fill, length = 1, na = TRUE)
  newCols <- getColumns(result = result, col = name)
  id <- which(name == colnames(result))
  nameValues <- result[[name]] |> strsplit(" &&& ")
  levelValues <- result[[level]] |> strsplit(" &&& ")
  if (!all(lengths(nameValues) == lengths(levelValues))) {
    cli::cli_abort("Column names and levels number does not match")
  }
  present <- newCols[newCols %in% colnames(result)]
  if (length(present) > 0) {
    cli::cli_warn(
      "The following columns will be overwritten:
      {paste0(present, collapse = ', ')}."
    )
  }
  for (k in seq_along(newCols)) {
    col <- newCols[k]
    dat <- lapply(seq_along(nameValues), function(y) {
      res <- levelValues[[y]][nameValues[[y]] == col]
      if (length(res) == 0) {
        return(as.character(NA))
      } else {
        return(res)
      }
    }) |>
      unlist()
    result[[col]] <- dat
  }
  if (!keep) {
    result <- result |> dplyr::select(-dplyr::all_of(c(name, level)))
    colskeep <- character()
  } else {
    colskeep <- c(name, level)
  }
  # move cols
  if (id == 1) {
    result <- result |> dplyr::relocate(dplyr::any_of(newCols))
  } else {
    id <- colnames(result)[id - 1]
    result <- result |>
      dplyr::relocate(
        dplyr::any_of(c(colskeep, newCols)), .after = dplyr::all_of(id)
      )
  }
  # use fill
  if (!is.na(fill)) {
    result <- result |>
      dplyr::mutate(dplyr::across(
        dplyr::any_of(newCols),
        ~ dplyr::if_else(is.na(.x), .env$fill, .x)
      ))
  }
  return(result)
}

# tidy.R -----
tidySummarisedResult <- function(result,
                                 splitGroup = TRUE,
                                 splitStrata = TRUE,
                                 splitAdditional = TRUE,
                                 settingsColumns =colnames(settings(result)),
                                 pivotEstimatesBy = "estimate_name",
                                 nameStyle = NULL) {
  # initial checks
  result <- omopgenerics::validateResultArgument(result = result)
  pivotEstimatesBy <- validatePivotEstimatesBy(pivotEstimatesBy = pivotEstimatesBy)
  settingsColumns <- validateSettingsColumns(settingsColumns = settingsColumns, result = result)
  omopgenerics::assertCharacter(x = nameStyle, null = TRUE)
  omopgenerics::assertLogical(
    x = c(splitGroup, splitStrata, splitAdditional), length = 3
  )
  # split
  if (isTRUE(splitGroup)) result <- result |> splitGroup()
  if (isTRUE(splitStrata)) result <- result |> splitStrata()
  if (isTRUE(splitAdditional)) result <- result |> splitAdditional()
  # pivot estimates and add settings
  result <- result |>
    addSettings(settingsColumns = settingsColumns) |>
    pivotEstimates(pivotEstimatesBy = pivotEstimatesBy, nameStyle = nameStyle) |>
    dplyr::relocate(dplyr::any_of(settingsColumns), .after = dplyr::last_col())
  return(result)
}
tidy <- function(x) {
  setNames <- colnames(settings(x))
  setNames <- setNames[setNames != "result_id"]
  x <- x |>
    addSettings() |>
    pivotEstimates() |>
    splitAll() |>
    dplyr::relocate(dplyr::all_of(setNames), .after = dplyr::last_col()) |>
    dplyr::select(!"result_id")
  return(x)
}

# unite.R -----
uniteNameLevel <- function(x,
                           cols = character(0),
                           name = "group_name",
                           level = "group_level",
                           keep = FALSE,
                           ignore = c(NA, "overall")) {
}
uniteNameLevelInternal <- function(x,
                           cols = character(0),
                           name = "group_name",
                           level = "group_level",
                           keep = FALSE,
                           ignore = c(NA, "overall")) {
  # initial checks
  omopgenerics::assertCharacter(cols)
  omopgenerics::assertCharacter(name, length = 1)
  omopgenerics::assertCharacter(level, length = 1)
  omopgenerics::assertLogical(keep, length = 1)
  omopgenerics::assertCharacter(ignore, na = TRUE)
  omopgenerics::assertTable(x, columns = cols)
  if (name == level) {
    cli::cli_abort("Provide different names for the name and level columns.")
  }
  if("groups" %in% names(attributes(x))) {
    cli::cli_warn("The table will be ungrouped.")
    x <- x |> dplyr::ungroup()
  }
  if (length(cols) > 0) {
    id <- min(which(colnames(x) %in% cols))
    present <- c(name, level)[c(name, level) %in% colnames(x)]
    if (length(present) > 0) {
      cli::cli_warn(
        "The following columns will be overwritten:
      {paste0(present, collapse = ', ')}."
      )
    }
    keyWord <- " &&& "
    containKey <- cols[grepl(keyWord, cols)]
    if (length(containKey) > 0) {
      cli::cli_abort("Column names must not contain '{keyWord}' : `{paste0(containKey, collapse = '`, `')}`")
    }
    containKey <- cols[
      lapply(cols, function(col){any(grepl(keyWord, x[[col]]))}) |> unlist()
    ]
    if (length(containKey) > 0) {
      cli::cli_abort("Column values must not contain '{keyWord}'. Present in: `{paste0(containKey, collapse = '`, `')}`.")
    }
    x <- x |>
      newNameLevel(
        cols = cols, name = name, level = level, ignore = ignore,
        keyWord = keyWord
      )
    if (keep) {
      colskeep <- cols
    } else {
      colskeep <- character()
      x <- x |> dplyr::select(!dplyr::all_of(cols))
    }
    # move cols
    if (id == 1) {
      x <- x |>
        dplyr::relocate(dplyr::all_of(c(colskeep, name, level)))
    } else {
      id <- colnames(x)[id - 1]
      x <- x |>
        dplyr::relocate(
          dplyr::all_of(c(colskeep, name, level)), .after = dplyr::all_of(id)
        )
    }
  } else {
    x <- x |>
      dplyr::mutate(!!name := "overall", !!level := "overall")
  }
  return(x)
}
uniteGroup <- function(x,
                       cols = character(0),
                       keep = FALSE,
                       ignore = c(NA, "overall")) {
  uniteNameLevelInternal(
    x = x, cols = cols, name = "group_name", level = "group_level", keep = keep,
    ignore = ignore
  )
}
uniteStrata <- function(x,
                        cols = character(0),
                        keep = FALSE,
                        ignore = c(NA, "overall")) {
  uniteNameLevelInternal(
    x = x, cols = cols, name = "strata_name", level = "strata_level",
    keep = keep, ignore = ignore
  )
}
uniteAdditional <- function(x,
                            cols = character(0),
                            keep = FALSE,
                            ignore = c(NA, "overall")) {
  uniteNameLevelInternal(
    x = x, cols = cols, name = "additional_name", level = "additional_level",
    keep = keep, ignore = ignore
  )
}
newNameLevel <- function(x, cols, name, level, ignore, keyWord) {
  y <- x |>
    dplyr::select(dplyr::all_of(cols)) |>
    dplyr::distinct()
  nms <- character(nrow(y))
  lvl <- character(nrow(y))
  for (k in seq_len(nrow(y))) {
    lev <- y[k, ] |> as.matrix() |> as.vector()
    ind <- which(!lev %in% ignore)
    if (length(ind) > 0) {
      nms[k] <- paste0(cols[ind], collapse = keyWord)
      lvl[k] <- paste0(lev[ind], collapse = keyWord)
    } else {
      nms[k] <- "overall"
      lvl[k] <- "overall"
    }
  }
  x <- x |>
    dplyr::inner_join(
      y |>
        dplyr::mutate(!!name := .env$nms, !!level := .env$lvl),
      na_matches = "na",
      by = cols
    )
  return(x)
}

# utilities.R -----
validateDecimals <- function(result, decimals) {
  nm_type <- omopgenerics::estimateTypeChoices()
  nm_type <- nm_type[!nm_type %in% c("logical", "date")]
  nm_name <- result[["estimate_name"]] |> unique()
  nm_name <- nm_name[!nm_name %in% c("logical", "date")]
  errorMesssage <- "`decimals` must be named integerish vector. Names refere to estimate_type or estimate_name values."
  if (is.null(decimals)) {
  } else if (any(is.na(decimals))) { # NA
    cli::cli_abort(errorMesssage)
  } else if (!is.numeric(decimals)) { # not numeric
    cli::cli_abort(errorMesssage)
  } else if (!all(decimals == floor(decimals))) { # not integer
    cli::cli_abort(errorMesssage)
  } else if (!all(names(decimals) %in% c(nm_type, nm_name))) { # not correctly named
    conflict_nms <- names(decimals)[!names(decimals) %in% c(nm_type, nm_name)]
    if ("date" %in% conflict_nms) {
      cli::cli_warn("`date` will not be formatted.")
      conflict_nms <- conflict_nms[!conflict_nms %in% "date"]
      decimals <- decimals[!names(decimals) %in% "date"]
    }
    if ("logical" %in% conflict_nms) {
      cli::cli_warn("`logical` will not be formatted.")
      conflict_nms <- conflict_nms[!conflict_nms %in% "logical"]
      decimals <- decimals[!names(decimals) %in% "logical"]
    }
    if (length(conflict_nms) > 0) {
      cli::cli_abort(paste0(paste0(conflict_nms, collapse = ", "), " do not correspond to estimate_type or estimate_name values."))
    }
  } else if (length(decimals) == 1 & is.null(names(decimals))) { # same number to all
    decimals <- rep(decimals, length(nm_type))
    names(decimals) <- nm_type
  } else {
    decimals <- c(decimals[names(decimals) %in% nm_name],
                  decimals[names(decimals) %in% nm_type])
  }
  return(decimals)
}
validateEstimateName <- function(format, call = parent.frame()) {
  omopgenerics::assertCharacter(format, null = TRUE)
  if (!is.null(format)) {
    if (length(format) > 0){
      if (length(regmatches(format, gregexpr("(?<=\\<).+?(?=\\>)", format, perl = T)) |> unlist()) == 0) {
        cli::cli_abort("format input does not contain any estimate name indicated by <...>.")
      }
    } else {
      format <- NULL
    }
  }
  return(invisible(format))
}
validateStyle <- function(style, tableFormatType) {
  if (is.list(style) | is.null(style)) {
    omopgenerics::assertList(style, null = TRUE, named = TRUE)
    if (is.list(style)) {
      notIn <- !names(style) %in% names(gtStyleInternal("default"))
      if (sum(notIn) > 0) {
        cli::cli_abort(c("`style` can only be defined for the following table parts: {gtStyleInternal('default') |> names()}.",
                      "x" =  "{.strong {names(style)[notIn]}} {?is/are} not one of them."))
      }
    }
  } else if (is.character(style)) {
    omopgenerics::assertCharacter(style, null = TRUE)
    eval(parse(text = paste0("style <- ", tableFormatType, "StyleInternal(styleName = style)")))
  } else {
    cli::cli_abort(paste0("Style must be one of 1) a named list of ", tableFormatType, " styling functions,
                   2) the string 'default' for visOmopResults default style, or 3) NULL to indicate no styling."))
  }
  return(style)
}
validatePivotEstimatesBy <- function(pivotEstimatesBy, call = parent.frame()) {
  omopgenerics::assertCharacter(x = pivotEstimatesBy, null = TRUE, call = call)
  notValid <- any(c(
    !pivotEstimatesBy %in% omopgenerics::resultColumns(),
    c("estimate_type", "estimate_value") %in% pivotEstimatesBy
  ))
  if (isTRUE(notValid)) {
    cli::cli_abort(
      c("x" = "`pivotEstimatesBy` must refer to summarised_result columns.
        It cannot include `estimate_value` and `estimate_type`."),
      call = call)
  }
  return(invisible(pivotEstimatesBy))
}
validateSettingsColumns <- function(settingsColumns, result, call = parent.frame()) {
  set <- settings(result)
  omopgenerics::assertCharacter(x = settingsColumns, null = TRUE, call = call)
  if (!is.null(settingsColumns)) {
    omopgenerics::assertTable(set, columns = settingsColumns)
    settingsColumns <- settingsColumns[settingsColumns != "result_id"]
    notPresent <- settingsColumns[!settingsColumns %in% colnames(set)]
    if (length(notPresent) > 0) {
      cli::cli_abort("The following `settingsColumns` are not present in settings: {notPresent}.")
    }
  } else {
    settingsColumns <- character()
  }
  return(invisible(settingsColumns))
}
validateRename <- function(rename, result, call = parent.frame()) {
  omopgenerics::assertCharacter(rename, null = TRUE, named = TRUE, call = call)
  if (!is.null(rename)) {
    notCols <- !rename %in% colnames(result)
    if (sum(notCols) > 0) {
      cli::cli_warn(
        "The following values of `rename` do not refer to column names
        and will be ignored: {rename[notCols]}", call = call
      )
      rename <- rename[!notCols]
    }
  } else {
    rename <- character()
  }
  return(invisible(rename))
}
validateGroupColumn <- function(groupColumn, cols, sr = NULL, rename = NULL, call = parent.frame()) {
  if (!is.null(groupColumn)) {
    if (!is.list(groupColumn)) {
      groupColumn <- list(groupColumn)
    }
    if (length(groupColumn) > 1) {
      cli::cli_abort("`groupColumn` must be a character vector, or a list with just one element (a character vector).", call = call)
    }
    omopgenerics::assertCharacter(groupColumn[[1]], null = TRUE, call = call)
    if (!is.null(sr) & length(groupColumn[[1]]) > 0) {
      settingsColumns <- settingsColumns(sr)
      settingsColumns <- settingsColumns[settingsColumns %in% cols]
      groupColumn[[1]] <- purrr::map(groupColumn[[1]], function(x) {
        if (x %in% c("group", "strata", "additional", "estimate", "settings")) {
          switch(x,
                 group = groupColumns(sr),
                 strata = strataColumns(sr),
                 additional = additionalColumns(sr),
                 estimate = "estimate_name",
                 settings = settingsColumns)
        } else {
          x
        }
      }) |> unlist()
    }
    if (any(!groupColumn[[1]] %in% cols)) {
      set <- character()
      if (!is.null(sr)) set <- "or in the settings stated in `settingsColumns`"
      cli::cli_abort("`groupColumn` must refer to columns in the result table {set}", call = call)
    }
    if (is.null(names(groupColumn)) & length(groupColumn[[1]]) > 0) {
      if (!is.null(rename)) {
        names(groupColumn) <- paste0(renameInternal(groupColumn[[1]], rename), collapse = "; ")
      } else {
        names(groupColumn) <- paste0(groupColumn[[1]], collapse = "_")
      }
    }
  }
  return(invisible(groupColumn))
}
validateMerge <- function(x, merge, groupColumn, call = parent.frame()) {
  if (!is.null(merge)) {
    if (any(merge %in% groupColumn)) {
      cli::cli_abort("groupColumn and merge must have different column names.", call = call)
    }
    ind <- ! merge %in% c(colnames(x), "all_columns")
    if (sum(ind) == 1) {
      cli::cli_inform(c("!" = "{merge[ind]} is not a column in the dataframe.", call = call))
    } else if (sum(ind) > 1) {
      cli::cli_inform(c("!" = "{merge[ind]} are not columns in the dataframe.", call = call))
    }
    omopgenerics::assertCharacter(merge)
  }
  return(invisible(merge))
}
validateDelim <- function(delim, call = parent.frame()) {
  omopgenerics::assertCharacter(delim, length = 1)
  if (nchar(delim) != 1) {
    cli::cli_abort("The value supplied for `delim` must be a single character.", call = call)
  }
  return(invisible(delim))
}
validateShowMinCellCount <- function(showMinCellCount, set) {
  omopgenerics::assertLogical(showMinCellCount, length = 1)
  if ((!"min_cell_count" %in% colnames(set)) & isTRUE(showMinCellCount)) {
    cli::cli_inform(c("!" = "Results have not been suppressed."))
    showMinCellCount <- FALSE
  }
  return(invisible(showMinCellCount))
}
validateSettingsAttribute <- function(result, call = parent.frame()) {
  set <- attr(result, "settings")
  if (is.null(set)) {
    cli::cli_abort("`result` does not have attribute settings", call = call)
  }
  if (!"result_id" %in% colnames(set) | !"result_id" %in% colnames(result)) {
    cli::cli_abort("'result_id' must be part of both `result` and its settings attribute.", call = call)
  }
  return(invisible(set))
}
checkVisTableInputs <- function(header, groupColumn, hide, call = parent.frame()) {
  int1 <- dplyr::intersect(header, groupColumn[[1]])
  int2 <- dplyr::intersect(header, hide)
  int3 <- dplyr::intersect(hide, groupColumn[[1]])
  if (length(c(int1, int2, int3)) > 0) {
    cli::cli_abort("Columns passed to {.strong `header`}, {.strong `groupColumn`}, and {.strong `hide`} must be different.", call = call)
  }
}

# visOmopTable.R -----
visOmopTable <- function(result,
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
formatToSentence <- function(x) {
  stringr::str_to_sentence(gsub("_", " ", gsub("&&&", "and", x)))
}
defaultTableOptions <- function(userOptions) {
  defaultOpts <- list(
    decimals = c(integer = 0, percentage = 2, numeric = 2, proportion = 2),
    decimalMark = ".",
    bigMark = ",",
    keepNotFormatted = TRUE,
    useFormatOrder = TRUE,
    delim = "\n",
    includeHeaderName = TRUE,
    includeHeaderKey = TRUE,
    style = "default",
    na = "-",
    title = NULL,
    subtitle = NULL,
    caption = NULL,
    groupAsColumn = FALSE,
    groupOrder = NULL,
    merge = "all_columns"
  )
  for (opt in names(userOptions)) {
    defaultOpts[[opt]] <- userOptions[[opt]]
  }
  return(defaultOpts)
}
optionsTable <- function() {
  return(defaultTableOptions(NULL))
}
optionsVisOmopTable <- function() {
  optionsTable()
}
backwardCompatibility <- function(header, hide, result, settingsColumns, groupColumn) {
  if (all(is.na(result$variable_level)) & "variable" %in% header) {
    colsVariable <- c("variable_name")
    hide <- c(hide, "variable_level")
  } else {
    colsVariable <- c("variable_name", "variable_level")
  }
  cols <- list(
    "group" = groupColumns(result),
    "strata" = strataColumns(result),
    "additional" = additionalColumns(result),
    "variable" = colsVariable,
    "estimate" = "estimate_name",
    "settings" = settingsColumns,
    "group_name" = character(),
    "strata_name" = character(),
    "additional_name" = character()
  )
  cols$group_level <- cols$group
  cols$strata_level <- cols$strata
  cols$additional_level <- cols$additional
  header <- correctColumnn(header, cols)
  if (is.list(groupColumn)) {
    groupColumn <- purrr::map(groupColumn, \(x) correctColumnn(x, cols))
  } else if (is.character(groupColumn)) {
    groupColumn <- correctColumnn(groupColumn, cols)
  }
  return(list(hide = hide, header = header, groupColumn = groupColumn))
}
correctColumnn <- function(col, cols) {
  purrr::map(col, \(x) if (x %in% names(cols)) cols[[x]] else x) |>
    unlist() |>
    unique()
}

# visTable.R -----
visTable <- function(result,
                     estimateName = character(),
                     header = character(),
                     groupColumn = character(),
                     rename = character(),
                     type = "gt",
                     hide = character(),
                     .options = list()) {
  # initial checks
  omopgenerics::assertTable(result)
  omopgenerics::assertChoice(type, choices = c("gt", "flextable", "tibble"), length = 1)
  omopgenerics::assertCharacter(hide, null = TRUE)
  omopgenerics::assertCharacter(header, null = TRUE)
  rename <- validateRename(rename, result)
  groupColumn <- validateGroupColumn(groupColumn, colnames(result), rename = rename)
  # .options
  .options <- defaultTableOptions(.options)
  # default hide columns
  # hide <- c(hide, "result_id", "estimate_type")
  checkVisTableInputs(header, groupColumn, hide)
  # format estimate values and names
  if (!any(c("estimate_name", "estimate_type", "estimate_value") %in% colnames(result))) {
    cli::cli_inform("`estimate_name`, `estimate_type`, and `estimate_value` must be present in `result` to apply `formatEstimateValue()` and `formatEstimateName()`.")
  } else {
    result <- result |>
      formatEstimateValue(
        decimals = .options$decimals,
        decimalMark = .options$decimalMark,
        bigMark = .options$bigMark
      ) |>
      formatEstimateName(
        estimateName = estimateName,
        keepNotFormatted = .options$keepNotFormatted,
        useFormatOrder = .options$useFormatOrder
      )
  }
  # rename and hide columns
  dontRename <- c("estimate_value")
  dontRename <- dontRename[dontRename %in% colnames(result)]
  estimateValue <- renameInternal("estimate_value", rename)
  rename <- rename[!rename %in% dontRename]
  # rename headers
  header <- purrr::map(header, renameInternal, cols = colnames(result), rename = rename) |> unlist()
  # rename group columns
  if (length(groupColumn[[1]]) > 0) {
    groupColumn[[1]] <- purrr::map(groupColumn[[1]], renameInternal, rename = rename) |> unlist()
  }
  # rename result
  result <- result |>
    dplyr::select(!dplyr::any_of(hide)) |>
    dplyr::rename_with(
      .fn = ~ renameInternal(.x, rename = rename),
      .cols = !dplyr::all_of(c(dontRename))
    )
  # format header
  if (length(header) > 0) {
    result <- result |>
      formatHeader(
        header = header,
        delim = .options$delim,
        includeHeaderName = .options$includeHeaderName,
        includeHeaderKey = .options$includeHeaderKey
      )
  } else if ("estimate_value" %in% colnames(result)) {
    result <- result |> dplyr::rename(!!estimateValue := "estimate_value")
  }
  if (type == "tibble") {
    class(result) <- class(result)[!class(result) %in% c("summarised_result", "omop_result")]
  } else {
    result <- result |>
      formatTable(
        type = type,
        delim = .options$delim,
        style = .options$style,
        na = .options$na,
        title = .options$title,
        subtitle = .options$subtitle,
        caption = .options$caption,
        groupColumn = groupColumn,
        groupAsColumn = .options$groupAsColumn,
        groupOrder = .options$groupOrder,
        merge = .options$merge
      )
  }
  return(result)
}
renameInternal <- function(x, rename, cols = NULL, toSentence = TRUE) {
  newNames <- character()
  for (xx in x) {
    if (isTRUE(xx %in% rename)) {
      newNames <- c(newNames, names(rename[rename == xx]))
    } else if (toSentence & any(xx %in% cols | is.null(cols))) {
      newNames <- c(newNames, formatToSentence(xx))
    } else {
      newNames <- c(newNames, xx)
    }
  }
  return(newNames)
}

