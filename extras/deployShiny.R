
rsconnect::setAccountInfo(
  name = "dpa-pde-oxford",
  token = Sys.getenv("SHINYAPPS_TOKEN"),
  secret = Sys.getenv("SHINYAPPS_SECRET")
)
rsconnect::deployApp(
  appDir = here::here("extras", "OmopSketchShiny"),
  appName = "OmopSketchCharacterisation",
  forceUpdate = TRUE,
  logLevel = "verbose",
  account = "dpa-pde-oxford"
)
