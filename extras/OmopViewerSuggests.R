
pkg <- "OmopViewer"

# Get suggested packages
suggests <- tools::package_dependencies(pkg, which = "Suggests", recursive = FALSE)[[1]]

# Remove already installed packages
suggests_to_install <- setdiff(suggests, rownames(installed.packages()))

# Install them
if (length(suggests_to_install) > 0) {
  install.packages(suggests_to_install)
} else {
  message("All suggested packages are already installed.")
}
