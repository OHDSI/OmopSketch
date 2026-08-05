library(omopgenerics)
library(OmopSketch)
library(visOmopResults)
library(here)
library(ggplot2)
library(patchwork)
library(dplyr)
library(gt)
library(paletteer)

results <- importSummarisedResult(path = here("article", "results"))

## Figure 1 ----


pal <- paletteer_d("ggsci::springfield_simpsons")

p1 <- plotPerson(result = results, variableName = "Sex") +
  labs(x = "", fill = "Sex", colour = "Sex") +
  scale_color_manual(values = pal) +
  scale_fill_manual(values = pal)
p2 <- plotPerson(result = results, variableName = "Year of birth") +
  labs(x = "", y = "Year of birth") +
  theme(legend.position = "none") +
  scale_color_manual(values = "#370335") +
  scale_fill_manual(values = "#370335")
p3 <- plotPerson(result = results, variableName = "Race") +
  labs(x = "", fill = "Ethnicity", colour = "Ethnicity") +
  scale_color_manual(values = pal) +
  scale_fill_manual(values = pal)
p4 <- plotPerson(result = results, variableName = "Location") +
  labs(x = "", fill = "Region", colour = "Region") +
  scale_color_manual(values = pal) +
  scale_fill_manual(values = pal)
f1 <- p1 + p2 + p3 + p4 +
  plot_layout(ncol = 4) +
  plot_annotation(
    tag_levels = "A",
    tag_prefix  = "",
    tag_suffix  = ""
  ) &
  theme(plot.tag = element_text(face = "bold", size = 14))

f1 <- p1 + p2 + p3 + p4 +
  plot_layout(ncol = 4)

ggsave(here("article", "results", "figure1.png"), f1, width = 15, height = 4)

## Figure 2 ----
pal <- paletteer_d("ggsci::default_nejm")
f2 <- plotObservationPeriod(results |> filterStrata(sex == "overall"), variableName = "Duration in days", colour = "age_group", plotType = "cumulativeplot")
f2$data$density_x <- f2$data$density_x / 365.25

f2 <- f2 +
  scale_color_manual(values = pal) +
  scale_fill_manual(values = pal) +
  ggplot2::xlab("Duration in years") +
  ggplot2::labs(title = "Duration in years (Cumulativeplot)\nin observation_period by Age group")


ggsave(here("article", "results", "figure2.png"), f2, width = 6, height = 4.5, dpi = 600)

## Figure 3 ----
f3 <- plotTrend(results |> filterGroup(omop_table != "observation_period"), colour = "omop_table", facet = NULL)
f3 <- f3 +
  ggplot2::scale_x_discrete(labels = function(x) substr(x, 1, 4)) +
  ggplot2::labs(
    title = "Yearly trend of median age",
    x = "Year",
    colour = "OMOP CDM table",
    fill = "OMOP CDM table"
  ) +

  ggplot2::guides(colour = ggplot2::guide_legend(nrow = 1)) +
  ggplot2::coord_cartesian(ylim = c(50, 65)) +

  scale_color_manual(values = pal) +
  scale_fill_manual(values = pal)
ggsave(here("article", "results", "figure3.png"), f3, width = 6, height = 4.5, dpi = 600)

## Table 2 ----

res <- results |>
  filterSettings(result_type == "summarise_clinical_records") |>
  filter(
    !estimate_name %in% c("mean", "sd"),
    variable_name != "In observation" | variable_level == "Yes",
    !variable_name %in% c("Column name", "Start date before birth date", "End date before start date", "Subjects not in person table")
  ) |>
  mutate(
    variable_level = if_else(variable_level == "Yes", NA, variable_level),
    new_variable_name = if_else(is.na(variable_level), "General", variable_name),
    variable_level = coalesce(variable_level, variable_name),
    variable_name = new_variable_name
  ) |>
  select(!"new_variable_name")
# subset to concept class with at least 1%
res <- res |>
  left_join(
    res |>
      filter(variable_name == "Concept class") |>
      tidy() |>
      filter(percentage >= 1) |>
      distinct(variable_level) |>
      mutate(keep = 1),
    by = "variable_level"
  ) |>
  filter(variable_name != "Concept class" | keep == 1) |>
  mutate(variable_name = if_else(variable_name == "Concept class", "Concept class*", variable_name)) |>
  select(!"keep")

t2 <- res |>
  visOmopTable(
    header = "cdm_name",
    groupColumn = "variable_name",
    hide = c("omop_table", "is_required", "type_concept_id"),
    estimateName = c(
      `N (%)` = "<count> (<percentage>%)",
      N = "<count>", `Mean (SD)` = "<mean> (<sd>)", `Median [Q25 - Q75]` = "<median> [<q25> - <q75>]",
      `Range [min to max]` = "[<min> to <max>]", `N missing data (%)` = "<na_count> (<na_percentage>%)"
    ),
    style = OmopSketch:::validateStyle(style = NULL, obj = "table")
  )

gtsave(t2, here("article", "results", "table2.docx"))
