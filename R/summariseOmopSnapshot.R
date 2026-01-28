
#' Summarise a cdm_reference object creating a snapshot with the metadata of the
#' cdm_reference object
#'
#' @inheritParams consistent-doc
#'
#' @return A `summarised_result` object with the results.
#' @export
#'
#' @examples
#' \donttest{
#' library(OmopSketch)
#' library(omock)
#'
#' cdm <- mockCdmFromDataset(datasetName = "GiBleed", source = "duckdb")
#'
#' result <- summariseOmopSnapshot(cdm = cdm)
#'
#' tableOmopSnapshot(result = result)
#'
#' cdmDisconnect(cdm = cdm)
#' }
#'
summariseOmopSnapshot <- function(cdm) {
  rlang::check_installed(pkg = "omopgenerics", version = "1.3.0")

  # initial checks
  cdm <- omopgenerics::validateCdmArgument(cdm = cdm)

  # cdm source
  cdm_source <- extractCdmSource(cdm = cdm)

  # vocabulary version
  vocab_version <- cdm$vocabulary |>
    dplyr::filter(.data$vocabulary_id == "None") |>
    dplyr::pull("vocabulary_version")
  if (length(vocab_version) == 0 || is.na(vocab_version)) {
    cli::cli_warn(c("!" = "vocabulary version is not recorded in the {.pkg vocabulary} table."))
    vocab_version <- cdm_source$vocabulary_version
  }

  # cdm version
  cdm_version <- omopgenerics::cdmVersion(x = cdm)

  # start formatting result
  result <- list()

  # general
  snapshotDate <- format(Sys.Date(), "%Y-%m-%d")
  personCount <- printInteger(omopgenerics::numberRecords(cdm$person))
  result$general <- dplyr::tibble(
    estimate_name = c("snapshot_date", "person_count", "vocabulary_version"),
    estimate_type = c("date", "integer", "character"),
    estimate_value = c(snapshotDate, personCount, vocab_version)
  )

  # cdm data
  result$cdm <- cdm_source |>
    dplyr::select(
      "source_name", "version", "holder_name", "release_date", "description",
      "documentation_reference"
    ) |>
    dplyr::mutate(version = .env$cdm_version) |>
    tidyr::pivot_longer(
      cols = dplyr::everything(),
      names_to = "estimate_name",
      values_to = "estimate_value"
    ) |>
    dplyr::mutate(estimate_type = "character")

  # observation period count
  opCount <- printInteger(omopgenerics::numberRecords(cdm$person))
  if (opCount > 0) {
    x <- cdm$observation_period |>
      dplyr::ungroup() |>
      dplyr::summarise(
        start_date = min(.data$observation_period_start_date, na.rm = TRUE),
        end_date = max(.data$observation_period_end_date, na.rm = TRUE)
      ) |>
      dplyr::collect() |>
      dplyr::mutate(dplyr::across(dplyr::everything(), \(x) format(x, "%Y-%m-%d")))
  } else {
    x <- dplyr::tibble(start_date = NA_character_, end_date = NA_character_)
  }
  result$observation_period <- dplyr::tibble(
    estimate_name = c("count", "start_date", "end_date"),
    estimate_type = c("integer", "date", "date"),
    estimate_value = c(opCount, x$start_date, x$end_date)
  )

  # source
  result$cdm_source <- summary(omopgenerics::cdmSource(x = cdm)) |>
    unclass() |>
    dplyr::as_tibble() |>
    tidyr::pivot_longer(
      cols = dplyr::everything(),
      names_to = "estimate_name",
      values_to = "estimate_value"
    ) |>
    dplyr::mutate(estimate_type = "character")

  # format final result
  result <- result |>
    dplyr::bind_rows(.id = "variable_name") |>
    dplyr::mutate(variable_level = NA_character_) |>
    omopgenerics::uniteGroup() |>
    omopgenerics::uniteStrata() |>
    omopgenerics::uniteAdditional() |>
    dplyr::mutate(
      result_id = 1L,
      cdm_name = omopgenerics::cdmName(x = cdm)
    ) |>
    omopgenerics::newSummarisedResult(settings = createSettings(
      result_type = "summarise_omop_snapshot"
    ))

  # check vocabulary version
  cdmSourceVocabVersion <- cdm_source$vocabulary_version
  if (!is.na(cdmSourceVocabVersion)) {
    if (!identical(cdmSourceVocabVersion, vocab_version)) {
      cli::cli_warn(c("!" = "The vocabulary version recorded in {.pkg cdm_source} table is different than the one recorded in {.pkg vocabulary} table. Verison recorded in {.pkg vocabulary} table will be used."))
    }
  }

  return(result)
}
extractCdmSource <- function(cdm) {
  if ("cdm_source" %in% names(cdm)) {
    if (omopgenerics::numberRecords(cdm$cdm_source) == 1L) {
      cdm_source <- cdm$cdm_source |>
        dplyr::collect() |>
        dplyr::as_tibble()
      q <- colsCdmSource()
      qx <- q[!names(q) %in% colnames(cdm_source)]
      if (length(qx) > 0) {
        cli::cli_warn(c("!" = "{.var {names(qx)}} not found in {.pkg cdm_source} table."))
        cdm_source <- dplyr::mutate(cdm_source, !!!qx)
      }
      cdm_source <- cdm_source |>
        dplyr::select(dplyr::all_of(names(q)))
    } else {
      cli::cli_warn(c("!" = "`cdm_source` table is populated with more than one row, therefore it is ignored."))
      cdm_source <- defaultCdmSource()
    }
  } else {
    cli::cli_warn(c("!" = "`cdm_source` is not populated, please populate to have a more complete {.pkg snapshot}."))
    cdm_source <- defaultCdmSource()
  }

  # rename
  cdm_source |>
    dplyr::rename(
      "source_name" = "cdm_source_name",
      "version" = "cdm_version",
      "holder_name" = "cdm_holder",
      "release_date" = "cdm_release_date",
      "description" = "source_description",
      "documentation_reference" = "source_documentation_reference"
    ) |>
    dplyr::mutate(dplyr::across(dplyr::everything(), as.character))
}
colsCdmSource <- function() {
  c(
    "cdm_source_name" = "NA_character_",
    "cdm_holder" = "NA_character_",
    "source_description" = "NA_character_",
    "cdm_release_date" = "as.Date(NA_character_)",
    "source_documentation_reference" = "NA_character_",
    "cdm_version" = "NA_character_",
    "vocabulary_version" = "NA_character_"
  ) |>
    rlang::parse_exprs()
}
defaultCdmSource <- function() {
  dplyr::tibble(!!!colsCdmSource())
}
