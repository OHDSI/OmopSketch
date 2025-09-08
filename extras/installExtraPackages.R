
pak::pkg_install(c(
  "OmopViewer", "ggplot2", "gt", "visOmopResults", "duckdb", "omock", "renv",
  "reactable", "here", "CohortCharacteristics"
))

pkg <- "OmopViewer"

# Get suggested packages
suggests <- tools::package_dependencies(pkg, which = "Suggests", recursive = FALSE)[[1]]

# Remove already installed packages
suggests_to_install <- setdiff(suggests, rownames(installed.packages()))

# Install them
if (length(suggests_to_install) > 0) {
  pak::pkg_install(suggests_to_install)
} else {
  message("All suggested packages are already installed.")
}
