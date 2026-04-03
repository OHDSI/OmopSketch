
library(omopgenerics)
library(OmopSketch)
library(visOmopResults)
library(here)
library(ggplot2)
library(patchwork)
library(dplyr)

results <- importSummarisedResult(path = here("article", "results"))

## Figure 1 ----

p1 <- plotPerson(result = results, variableName = "Sex") +
  labs(x = "", fill = "Sex", colour = "Sex")
p2 <- plotPerson(result = results, variableName = "Year of birth") +
  labs(x = "", y = "Year of birth") +
  theme(legend.position = "none")
p3 <- plotPerson(result = results, variableName = "Race") +
  labs(x = "", fill = "Ethnicity", colour = "Ethnicity")
# TODO
p4 <- results |>
  filterSettings(result_type == "summarise_person") |>
  filter(variable_name == "Location" & !is.na(variable_level)) |>
  barPlot(x = "cdm_name", y = "percentage", colour = "variable_level", position = "stack") +
  labs(x = "", fill = "Region", colour = "Region")

f1 <- p1 + p2 + p3 + p4 +
  plot_layout(ncol = 4)

ggsave(here("article", "results", "figure1.png"), f1, width = 15, height = 4)

## Figure 2 ----

resultDuration <- results |>
  filterSettings(result_type == "summarise_observation_period") |>
  filter(variable_name == "Duration in days") |>
  filter(estimate_name %in% c("density_x", "density_y")) |>
  tidy() |>
  select("age_group", "sex", "variable_level", "density_x", "density_y")
gaps <- resultDuration |>
  group_by(age_group, sex) |>
  summarise(gap = nth(density_x, 2) - first(density_x ), .groups = "drop")
resultDuration <- resultDuration |>
  left_join(gaps, by = c("age_group", "sex")) |>
  group_by(age_group, sex) |>
  arrange(density_x) |>
  mutate(
    sex = factor(sex, levels = c("overall", "Female", "Male")),
    density_y = 100 * (1 - cumsum(density_y * gap)),
    density_x = density_x / 365.25
  )

f2 <- ggplot(data = resultDuration, mapping = aes(x = density_x, y = density_y, colour = age_group)) +
  geom_line() +
  facet_wrap(. ~ sex) +
  labs(y = "Percenatge", x = "Observation period duration in years", colour = "Age group")

ggsave(here("article", "results", "figure2.png"), f2, width = 6, height = 4.5, dpi = 600)

## Figure 3 ----
f3 <- plotTrend(results, colour = "omop_table", facet = NULL)

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

res |>
  visOmopTable(
    header = "cdm_name",
    groupColumn = "variable_name",
    hide = c("omop_table"),
    estimateName = c(
      `N (%)` = "<count> (<percentage>%)",
      N = "<count>", `Mean (SD)` = "<mean> (<sd>)", `Median [Q25 - Q75]` = "<median> [<q25> - <q75>]",
                     `Range [min to max]` = "[<min> to <max>]", `N missing data (%)` = "<na_count> (<na_percentage>%)"
    ),
    style = OmopSketch:::validateStyle(style = NULL, obj = "table")
  )

