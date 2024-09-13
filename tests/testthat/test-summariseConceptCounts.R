test_that("summarise code use - eunomia", {
  cdm <- cdmEunomia()
  acetiminophen <- c(1125315,  1127433, 40229134,
                     40231925, 40162522, 19133768,  1127078)
  poliovirus_vaccine <- c(40213160)
  cs <- list(acetiminophen = acetiminophen,
             poliovirus_vaccine = poliovirus_vaccine)
  startNames <- CDMConnector::listSourceTables(cdm)
  results <- summariseConceptCounts(cdm = cdm,
                                    conceptId = cs,
                                    year = TRUE,
                                    sex = TRUE,
                                    ageGroup = list(c(0,17),
                                                    c(18,65),
                                                    c(66, 100)))
  endNames <- CDMConnector::listSourceTables(cdm)
  expect_true(length(setdiff(endNames, startNames)) == 0)

  # min cell counts:
  expect_true(
    all(is.na(
      omopgenerics::suppress(results) |>
        dplyr::filter(
          variable_name == "overall",
          strata_level == "1909",
          group_level == "acetiminophen"
        ) |>
        dplyr::pull("estimate_value")
    ))
  )

  # check is a summarised result
  expect_true("summarised_result" %in%  class(results))
  expect_equal(omopgenerics::resultColumns(),
               colnames(results))

  # overall record count
  expect_true(results %>%
                dplyr::filter(group_name == "codelist_name" &
                                strata_name == "overall" &
                                strata_level == "overall" &
                                group_level == "acetiminophen" &
                                estimate_name == "record_count",
                              variable_name == "overall") %>%
                dplyr::pull("estimate_value") |>
                as.numeric() ==
                cdm$drug_exposure %>%
                dplyr::filter(drug_concept_id %in%  acetiminophen) %>%
                dplyr::tally() %>%
                dplyr::pull("n"))

  # overall person count
  expect_true(results %>%
                dplyr::filter(group_name == "codelist_name" &
                                strata_name == "overall" &
                                strata_level == "overall" &
                                group_level == "acetiminophen" &
                                estimate_name == "person_count",
                              variable_name == "overall") %>%
                dplyr::pull("estimate_value") |>
                as.numeric()  ==
                cdm$drug_exposure %>%
                dplyr::filter(drug_concept_id %in% acetiminophen) %>%
                dplyr::select("person_id") %>%
                dplyr::distinct() %>%
                dplyr::tally() %>%
                dplyr::pull("n"))

  # by year
  # overall record count
  expect_true(results %>%
                dplyr::filter(group_name == "codelist_name" &
                                strata_name == "year" &
                                strata_level == "2008" &
                                group_level == "acetiminophen" &
                                estimate_name == "record_count",
                              variable_name == "overall") %>%
                dplyr::pull("estimate_value") |>
                as.numeric()  ==
                cdm$drug_exposure %>%
                dplyr::filter(drug_concept_id %in% acetiminophen) %>%
                dplyr::filter(year(drug_exposure_start_date) == 2008) %>%
                dplyr::tally() %>%
                dplyr::pull("n"))

  # overall person count
  expect_true(results %>%
                dplyr::filter(group_name == "codelist_name" &
                                strata_name == "year" &
                                strata_level == "2008" &
                                group_level == "acetiminophen" &
                                estimate_name == "person_count",
                              variable_name == "overall") %>%
                dplyr::pull("estimate_value") |>
                as.numeric() ==
                cdm$drug_exposure %>%
                dplyr::filter(drug_concept_id %in% acetiminophen) %>%
                dplyr::filter(year(drug_exposure_start_date) == 2008) %>%
                dplyr::select("person_id") %>%
                dplyr::distinct() %>%
                dplyr::tally() %>%
                dplyr::pull("n"))

  # by age group and sex
  # overall record count
  expect_true(results %>%
                dplyr::filter(group_name == "codelist_name" &
                                strata_name == "sex" &
                                strata_level == "Male" &
                                group_level == "acetiminophen" &
                                estimate_name == "record_count",
                              variable_name == "overall") %>%
                dplyr::pull("estimate_value") |>
                as.numeric() ==
                cdm$drug_exposure %>%
                dplyr::filter(drug_concept_id %in% acetiminophen) %>%
                PatientProfiles::addSex() %>%
                dplyr::filter(sex == "Male") %>%
                dplyr::tally() %>%
                dplyr::pull("n"))

  expect_true(results %>%
                dplyr::filter(group_name == "codelist_name" &
                                strata_name == "age_group &&& sex" &
                                strata_level == "18 to 65 &&& Male" &
                                group_level == "acetiminophen" &
                                estimate_name == "record_count",
                              variable_name == "overall") %>%
                dplyr::pull("estimate_value") |>
                as.numeric() ==
                cdm$drug_exposure %>%
                dplyr::filter(drug_concept_id %in% acetiminophen) %>%
                PatientProfiles::addAge(indexDate = "drug_exposure_start_date") %>%
                PatientProfiles::addSex() %>%
                dplyr::filter(sex == "Male" &
                                age >= "18" &
                                age <= "65") %>%
                dplyr::tally() %>%
                dplyr::pull("n"))

  # overall person count
  expect_true(results %>%
                dplyr::filter(group_name == "codelist_name" &
                                strata_name == "age_group &&& sex" &
                                strata_level == "18 to 65 &&& Male" &
                                group_level == "acetiminophen" &
                                estimate_name == "person_count",
                              variable_name == "overall") %>%
                dplyr::pull("estimate_value") |>
                as.numeric() ==
                cdm$drug_exposure %>%
                dplyr::filter(drug_concept_id %in% acetiminophen) %>%
                PatientProfiles::addAge(indexDate = "drug_exposure_start_date") %>%
                PatientProfiles::addSex() %>%
                dplyr::filter(sex == "Male" &
                                age >= "18" &
                                age <= "65") %>%
                dplyr::select("person_id") %>%
                dplyr::distinct() %>%
                dplyr::tally() %>%
                dplyr::pull("n"))

  results <- summariseConceptCounts(list("acetiminophen" = acetiminophen),
                              cdm = cdm, countBy = "person",
                              year = FALSE,
                              sex = FALSE,
                              ageGroup = NULL)
  expect_true(nrow(results %>%
                     dplyr::filter(estimate_name == "person_count")) > 0)
  expect_true(nrow(results %>%
                     dplyr::filter(estimate_name == "record_count")) == 0)

  results <- summariseConceptCounts(list("acetiminophen" = acetiminophen),
                              cdm = cdm, countBy = "record",
                              year = FALSE,
                              sex = FALSE,
                              ageGroup = NULL)
  expect_true(nrow(results %>%
                     dplyr::filter(estimate_name == "person_count")) == 0)
  expect_true(nrow(results %>%
                     dplyr::filter(estimate_name == "record_count")) > 0)

  # domains covered
  # condition
  expect_true(nrow(summariseConceptCounts(list(cs= c(4112343)),
                                    cdm = cdm,
                                    year = FALSE,
                                    sex = FALSE,
                                    ageGroup = NULL))>1)

  # visit
  expect_true(nrow(summariseConceptCounts(list(cs= c(9201)),
                                    cdm = cdm,
                                    year = FALSE,
                                    sex = FALSE,
                                    ageGroup = NULL))>1)

  # drug
  expect_true(nrow(summariseConceptCounts(list(cs= c(40213160)),
                                    cdm = cdm,
                                    year = FALSE,
                                    sex = FALSE,
                                    ageGroup = NULL))>1)

  # measurement
  expect_true(nrow(summariseConceptCounts(list(cs= c(3006322)),
                                    cdm = cdm,
                                    year = FALSE,
                                    sex = FALSE,
                                    ageGroup = NULL))>1)

  # procedure and condition
  expect_true(nrow(summariseConceptCounts(list(cs= c(4107731,4112343)),
                                    cdm = cdm,
                                    year = FALSE,
                                    sex = FALSE,
                                    ageGroup = NULL))>1)

  # no records
  expect_message(results <- summariseConceptCounts(list(cs= c(999999)),
                                             cdm = cdm,
                                             year = FALSE,
                                             sex = FALSE,
                                             ageGroup = NULL))
  expect_true(nrow(results) == 0)

  # conceptId NULL (but reduce the computational time by filtering concepts first)
  cdm$concept <- cdm$concept |>
    dplyr::filter(grepl("k", concept_name))

  results <- summariseConceptCounts(cdm = cdm,
                                    year = FALSE,
                                    sex = FALSE,
                                    ageGroup = NULL)

  results_concepts <- results |>
    dplyr::select(variable_name) |>
    dplyr::distinct() |>
    dplyr::pull()
  concepts <- cdm$concept |>
    dplyr::select(concept_name) |>
    dplyr::distinct() |>
    dplyr::pull()

  expect_true(all(results_concepts %in% c("overall",concepts)))

  # check attributes
  expect_true(omopgenerics::settings(results)$package_name == "OmopSketch")
  expect_true(omopgenerics::settings(results)$result_type == "code_use")
  expect_true(omopgenerics::settings(results)$package_version == packageVersion("OmopSketch"))

  # expected errors# expected errors
  expect_error(summariseConceptCounts("not a concept",
                                cdm = cdm,
                                year = FALSE,
                                sex = FALSE,
                                ageGroup = NULL))
  expect_error(summariseConceptCounts("123",
                                cdm = cdm,
                                year = FALSE,
                                sex = FALSE,
                                ageGroup = NULL))
  expect_error(summariseConceptCounts(list("123"), # not named
                                cdm = cdm,
                                year = FALSE,
                                sex = FALSE,
                                ageGroup = NULL))
  expect_error(summariseConceptCounts(list(a = 123),
                                cdm = "not a cdm",
                                year = FALSE,
                                sex = FALSE,
                                ageGroup = NULL))
  expect_error(summariseConceptCounts(list(a = 123),
                                cdm = cdm,
                                year = "Maybe",
                                sex = FALSE,
                                ageGroup = NULL))
  expect_error(summariseConceptCounts(list(a = 123),
                                cdm = cdm,
                                year = FALSE,
                                sex = "Maybe",
                                ageGroup = NULL))
  expect_error(summariseConceptCounts(list(a = 123),
                                cdm = cdm,
                                year = FALSE,
                                sex = FALSE,
                                ageGroup = 25))
  expect_error(summariseConceptCounts(list(a = 123),
                                cdm = cdm,
                                year = FALSE,
                                sex = FALSE,
                                ageGroup = list(c(18,17))))
  expect_error(summariseConceptCounts(list(a = 123),
                                cdm = cdm,
                                year = FALSE,
                                sex = FALSE,
                                ageGroup = list(c(0,17),
                                                c(15,20))))

  CDMConnector::cdmDisconnect(cdm)
})

test_that("summarise code use - mock data", {
  cdm <- mockOmopSketch(con = connection(), writeSchema = "main", numberIndividuals = 2)

  conceptId <- cdm$condition_occurrence |>
    dplyr::inner_join(cdm$concept, by = c("condition_concept_id" ="concept_id")) |>
    dplyr::select(concept_name, "concept_id" = "condition_concept_id") |>
    dplyr::distinct() |>
    dplyr::collect() |>
    dplyr::group_by(.data$concept_name)  |>
    dplyr::summarise(named_vec = list(.data$concept_id)) |>
    tibble::deframe()

  result <- summariseConceptCounts(cdm, conceptId)

  # Arthritis (codes 3 and 17), one record of each per ind
  expect_true(all(result |>
                dplyr::filter(variable_name == "Arthritis") |>
                dplyr::arrange(variable_level, estimate_name) |>
                dplyr::pull(estimate_value) == c(1,2,1,2)))

  # Osteoarthritis (code 5), two records ind 2
  expect_true(all(result |>
                    dplyr::filter(variable_name == "Osteoarthritis of hip") |>
                    dplyr::arrange(variable_level, estimate_name) |>
                    dplyr::pull(estimate_value) == c(1,2)))

  # Musculoskeletal disorder (code 1), one record each ind
  expect_true(all(result |>
                    dplyr::filter(variable_name == "Musculoskeletal disorder") |>
                    dplyr::arrange(variable_level, estimate_name) |>
                    dplyr::pull(estimate_value) == c(2,2)))

  result <- summariseConceptCounts(cdm, conceptId, ageGroup = list(c(0,2), c(3,150)), sex = TRUE)
  # Individuals belong to the same age group but to different sex groups

  # Arthritis (codes 3 and 17), one record of each per ind
  expect_true(all(result |>
                    dplyr::filter(variable_name == "Arthritis" & strata_level == "Male") |>
                    dplyr::arrange(variable_level, estimate_name) |>
                    dplyr::pull(estimate_value) == c(1,2)))
  expect_true(all(result |>
                    dplyr::filter(variable_name == "Arthritis" & strata_level == "3 to 150 &&& Male") |>
                    dplyr::arrange(variable_level, estimate_name) |>
                    dplyr::pull(estimate_value) == c(1,2)))
  expect_true(all(result |>
                    dplyr::filter(variable_name == "Arthritis" & strata_level == "3 to 150") |>
                    dplyr::arrange(variable_level, estimate_name) |>
                    dplyr::pull(estimate_value) == c(1,2,1,2)))

  # Osteoarthritis of hip (code 5), two records ind 2
  expect_true(all(result |>
                    dplyr::filter(variable_name == "Osteoarthritis of hip" & strata_level == "Female") |>
                    dplyr::tally() |>
                    dplyr::pull() == 0))

  # Musculoskeletal disorder (code 1), one record each ind
  expect_true(all(result |>
                    dplyr::filter(variable_name == "Musculoskeletal disorder" & strata_level == "3 to 150 &&& Female") |>
                    dplyr::arrange(variable_level, estimate_name) |>
                    dplyr::pull(estimate_value) == c(1,1)))
  expect_true(all(result |>
                    dplyr::filter(variable_name == "Musculoskeletal disorder" & strata_level == "3 to 150 &&& Male") |>
                    dplyr::arrange(variable_level, estimate_name) |>
                    dplyr::pull(estimate_value) == c(1,1)))
  expect_true(all(result |>
                    dplyr::filter(variable_name == "Musculoskeletal disorder" & strata_level == "3 to 150") |>
                    dplyr::arrange(variable_level, estimate_name) |>
                    dplyr::pull(estimate_value) == c(2,2)))
  expect_true(all(result |>
                    dplyr::filter(variable_name == "Musculoskeletal disorder" & strata_level == "overall") |>
                    dplyr::arrange(variable_level, estimate_name) |>
                    dplyr::pull(estimate_value) == c(2,2)))

  PatientProfiles::mockDisconnect(cdm)
})
