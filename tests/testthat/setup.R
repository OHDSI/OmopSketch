on_cran <- function() {
  !interactive() && !isTRUE(as.logical(Sys.getenv("NOT_CRAN", "false")))
}
if (!on_cran()) {
  withr::local_envvar(
    R_USER_CACHE_DIR = tempfile(),
    .local_envir = testthat::teardown_env(),
    EUNOMIA_DATA_FOLDER = Sys.getenv("EUNOMIA_DATA_FOLDER", unset = tempfile())
  )
  CDMConnector::downloadEunomiaData(overwrite = TRUE)
}
