
dbToTest <- Sys.getenv("DB_TO_TEST", "duckdb-CDMConnector")

# prepare eunomia and save it in temp directory
cdmLocal <- omock::mockCdmFromDataset(datasetName = "GiBleed")
tabs <- c(
  "observation_period", "visit_occurrence", "visit_detail", "specimen",
  "note", "condition_occurrence", "drug_exposure", "procedure_occurrence",
  "device_exposure", "measurement", "observation", "death"
)
personIds <- cdmLocal$person |>
  dplyr::distinct(.data$person_id) |>
  dplyr::pull()
for (tab in tabs) {
  start <- omopgenerics::omopColumns(table = tab, field = "start_date")
  id <- omopgenerics::omopColumns(table = tab, field = "unique_id")
  cdmLocal[[tab]] <- cdmLocal[[tab]] |>
    dplyr::filter(.data$person_id %in% .env$personIds)
  if (nrow(cdmLocal[[tab]]) > 0) {
    cdmLocal[[tab]] <- cdmLocal[[tab]] |>
      dplyr::group_by(dplyr::across(dplyr::all_of(id))) |>
      dplyr::filter(.data[[start]] == min(.data[[start]], na.rm = TRUE)) |>
      dplyr::ungroup()
  }
}
pathEunomia <- file.path(tempdir(), "OmopSketchEunomia.RDS")
saveRDS(object = cdmLocal, file = pathEunomia)

cdmEunomia <- function() {
  cdm <- readRDS(file = pathEunomia)
  if (dbToTest == "duckdb-CDMConnector") {
    cdm <- copyCdm(cdm = cdm)
  } else if (dbToTest != "local-omopgenerics") {
    con <- connection()
    cdmSchema <- schema(pref = "gios_")
    writeSchema <- schema()
    ls <- CDMConnector::listTables(con = con, schema = cdmSchema)
    if (!"person" %in% ls) {
      to <- CDMConnector::dbSource(con = con, writeSchema = cdmSchema)
      cdm$concept_synonym <- NULL
      if (dbToTest == "redshift-CDMConnector") {
        insertInChunks(cdm = cdm, size = 40000, to = to)
      } else {
        omopgenerics::insertCdmTo(cdm = cdm, to = to)
      }
    }
    cdm <- CDMConnector::cdmFromCon(
      con = con,
      cdmSchema = cdmSchema,
      writeSchema = writeSchema,
      cdmName = "eunomia"
    )
  }
  return(cdm)
}
connection <- function() {
  if (dbToTest == "duckdb-CDMConnector") {
    con <- duckdb::dbConnect(drv = duckdb::duckdb(dbdir = ":memory:"))
  } else if (dbToTest == "sqlserver-CDMConnector") {
    con <-  DBI::dbConnect(
      odbc::odbc(),
      Driver = "ODBC Driver 18 for SQL Server",
      Server = Sys.getenv("CDM5_SQL_SERVER_SERVER"),
      Database = "CDMV5",
      UID = Sys.getenv("CDM5_SQL_SERVER_USER"),
      PWD = Sys.getenv("CDM5_SQL_SERVER_PASSWORD"),
      TrustServerCertificate = "yes",
      Port = 1433
    )
  } else if (dbToTest == "redshift-CDMConnector") {
    server <- stringr::str_split_1(Sys.getenv("CDM5_REDSHIFT_SERVER"), "/")
    con <- DBI::dbConnect(
      RPostgres::Redshift(),
      dbname = server[2],
      port = 5439,
      host = server[1],
      user = Sys.getenv("CDM5_REDSHIFT_USER"),
      password = Sys.getenv("CDM5_REDSHIFT_PASSWORD")
    )
  } else if (dbToTest == "postgres-CDMConnector") {
    con <- RPostgres::dbConnect(
      RPostgres::Postgres(),
      dbname = stringr::str_split_1(Sys.getenv("CDM5_POSTGRESQL_SERVER"), "/")[2],
      host = stringr::str_split_1(Sys.getenv("CDM5_POSTGRESQL_SERVER"), "/")[1],
      user = Sys.getenv("CDM5_POSTGRESQL_USER"),
      password = Sys.getenv("CDM5_POSTGRESQL_PASSWORD")
    )
  } else if (dbToTest == "snowflake-CDMConnector") {
    con <- odbc::dbConnect(
      odbc::odbc(),
      SERVER = stringr::str_extract(Sys.getenv("CDM_SNOWFLAKE_CONNECTION_STRING"), "(?<=//)[^?]+(?=\\?)"),
      UID = Sys.getenv("CDM_SNOWFLAKE_USER"),
      PWD = Sys.getenv("CDM_SNOWFLAKE_PASSWORD"),
      DATABASE = "ATLAS",
      WAREHOUSE = stringr::str_extract(Sys.getenv("CDM_SNOWFLAKE_CONNECTION_STRING"), "(?i)(?<=\\bwarehouse=)[^&?#]+"),
      Driver = "SnowflakeDSIIDriver"
    )
  }
  con
}
schema <- function(pref = NULL) {
  if (is.null(pref)) {
    pref <- paste0("os_", paste0(sample(letters, 3), collapse = ""), "_")
  }
  if (dbToTest == "duckdb-CDMConnector") {
    sch <- c(schema = "main", prefix = pref)
  } else if (dbToTest == "sqlserver-CDMConnector") {
    sch <- c(catalog = "tempdb", schema = "dbo", prefix = pref)
  } else if (dbToTest == "redshift-CDMConnector") {
    sch <- c(schema = "public", prefix = pref)
  } else if (dbToTest == "postgres-CDMConnector") {
    sch <- c(schema = "public", prefix = pref)
  } else if (dbToTest == "snowflake-CDMConnector") {
    sch <- c(catalog = "ATLAS", schema = "RESULTS", prefix = pref)
  }
  sch
}
copyCdm <- function(cdm) {
  if (dbToTest == "duckdb-CDMConnector") {
    to <- CDMConnector::dbSource(con = connection(), writeSchema = schema())
  } else if (dbToTest == "sqlserver-CDMConnector") {
    to <- CDMConnector::dbSource(con = connection(), writeSchema = schema())
  } else if (dbToTest == "redshift-CDMConnector") {
    to <- CDMConnector::dbSource(con = connection(), writeSchema = schema())
  } else if (dbToTest == "postgres-CDMConnector") {
    to <- CDMConnector::dbSource(con = connection(), writeSchema = schema())
  } else if (dbToTest == "snowflake-CDMConnector") {
    to <- CDMConnector::dbSource(con = connection(), writeSchema = schema())
  } else if (dbToTest != "local-omopgenerics") {
    cli::cli_abort(c(x = "Not supported dbToTest: {.pkg {dbToTest}}"))
  }

  if (dbToTest %in% c("redshift-CDMConnector", "snowflake-CDMConnector")) {
    cdm$concept_synonym <- NULL
  }

  if (dbToTest != "local-omopgenerics") {
    if (dbToTest == "redshift-CDMConnector") {
      cdm <- insertInChunks(cdm = cdm, size = 40000, to = to)
    } else {
      cdm <- omopgenerics::insertCdmTo(cdm = cdm, to = to)
    }
  }

  return(cdm)
}
checkResultType <- function(result, result_type) {
  expect_true(
    result |>
      omopgenerics::settings() |>
      dplyr::pull("result_type") == result_type
  )
}
sortTibble <- function(x) {
  x |>
    dplyr::arrange(dplyr::across(dplyr::everything()))
}
collectTable <- function(x) {
  x |>
    dplyr::collect() |>
    dplyr::as_tibble() |>
    sortTibble()
}
dropCreatedTables <- function(cdm) {
  omopgenerics::dropSourceTable(cdm = cdm, name = dplyr::everything())
  omopgenerics::cdmDisconnect(cdm = cdm)
}
insertInChunks <- function(cdm, size, to) {
  # split if needed
  toJoin <- list()
  for (nm in names(cdm)) {
    n <- nrow(cdm[[nm]])
    if (n >= size) {
      chucks <- ceiling(n/size)
      tbls <- character()
      for (k in seq_len(chucks)) {
        newName <- paste0(nm, "_badge_", k)
        cdm[[newName]] <- cdm[[nm]] |>
          dplyr::filter(dplyr::row_number() %/% .env$size == (.env$k - 1)) |>
          dplyr::compute(name = newName)
        tbls <- c(tbls, newName)
      }
      cdm[[nm]] <- NULL
      toJoin[[nm]] <- tbls
    }
  }

  # insert
  cdm <- omopgenerics::insertCdmTo(cdm = cdm, to = to)

  # join if needed
  for (nm in names(toJoin)) {
    cdm[[nm]] <- cdm[toJoin[[nm]]] |>
      purrr::reduce(dplyr::union_all) |>
      dplyr::compute(name = nm)
  }

  # drop not needed tables
  nms <- names(cdm)
  nms <- nms[grepl(pattern = "_badge_", x = nms)]
  cdm <- omopgenerics::dropSourceTable(cdm = cdm, name = nms)

  return(cdm)
}
