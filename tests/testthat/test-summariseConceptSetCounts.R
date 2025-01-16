test_that("summarise code use - eunomia", {
  skip_on_cran()
  cdm <- cdmEunomia()
  acetiminophen <- c(1125315,  1127433, 40229134,
                     40231925, 40162522, 19133768,  1127078)
  poliovirus_vaccine <- c(40213160)
  cs <- list(acetiminophen = acetiminophen,
             poliovirus_vaccine = poliovirus_vaccine)
  startNames <- CDMConnector::listSourceTables(cdm)
  results <- summariseConceptSetCounts(cdm = cdm,
                                    conceptSet = cs,
                                    interval = "years",
                                    countBy = c("record", "person"),
                                    concept = TRUE,
                                    sex = TRUE,
                                    ageGroup = list(c(0,17),
                                                    c(18,65),
                                                    c(66, 100)))
  endNames <- CDMConnector::listSourceTables(cdm)
  expect_true(length(setdiff(endNames, startNames)) == 0)

  #Check result type
  checkResultType(results, "summarise_concept_set_counts")

  # min cell counts:
  expect_equal(
      omopgenerics::suppress(results, 5) |>
        omopgenerics::splitAdditional() |>
        dplyr::filter(
          strata_level == "overall",
          variable_name == "Number records",
          standard_concept_id == "overall",
          time_interval == "1909-01-01 to 1909-12-31",
          group_level == "acetiminophen") |>
        dplyr::pull("estimate_value"),
     "-"
  )

  # check is a summarised result
  expect_true("summarised_result" %in%  class(results))
  expect_equal(omopgenerics::resultColumns(),
               colnames(results))

  # overall record count
  expect_true(results %>%
                dplyr::filter(group_name == "codelist_name",
                                strata_name == "overall",
                                strata_level == "overall",
                                additional_level == "overall",
                                group_level == "acetiminophen",
                                variable_name == "Number records") %>%
                dplyr::pull("estimate_value") |>
                as.numeric() ==
                cdm$drug_exposure %>%
                dplyr::inner_join(cdm[["person"]] |> dplyr::select("person_id"), by = "person_id") |>
                dplyr::filter(drug_concept_id %in% c(acetiminophen)) %>%
                dplyr::tally() %>%
                dplyr::pull("n"))

  # overall person count
  expect_true(results %>%
                dplyr::filter(group_name == "codelist_name" &
                                strata_name == "overall" &
                                strata_level == "overall" &
                                group_level == "acetiminophen" &
                                variable_name == "Number subjects",
                              additional_name == "overall") %>%
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
                omopgenerics::splitAdditional() |>
                dplyr::filter(group_name == "codelist_name" &
                                strata_name == "overall" &
                                time_interval == "2008-01-01 to 2008-12-31" &
                                group_level == "acetiminophen" &
                                variable_name == "Number records",
                              standard_concept_name == "overall") %>%
                dplyr::pull("estimate_value") |>
                as.numeric()  ==
                cdm$drug_exposure %>%
                dplyr::filter(drug_concept_id %in% acetiminophen) %>%
                dplyr::filter(year(drug_exposure_start_date) == 2008) %>%
                dplyr::tally() %>%
                dplyr::pull("n"))

  # overall person count
  expect_true(results %>%
                omopgenerics::splitAdditional() |>
                dplyr::filter(group_name == "codelist_name" &
                                strata_name == "overall" &
                                time_interval == "2008-01-01 to 2008-12-31" &
                                group_level == "acetiminophen" &
                                variable_name == "Number subjects",
                              standard_concept_name == "overall") %>%
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
                                variable_name == "Number records" &
                              additional_name == "overall") %>%
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
                                variable_name == "Number records",
                              additional_name == "overall") %>%
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
                                variable_name == "Number subjects",
                              additional_name == "overall") %>%
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

  results1 <- summariseConceptSetCounts(cdm = cdm,
                                     conceptSet = cs,
                                     interval = "years",
                                     concept = FALSE,
                                     sex = TRUE,
                                     ageGroup = list(c(0,17),
                                                     c(18,65),
                                                     c(66, 100)))

  expect_equal(
    results1 |>
      omopgenerics::splitAdditional() |>
      dplyr::filter(variable_name == "Number records") |>
      dplyr::arrange(dplyr::across(dplyr::everything())),
    results |>
      omopgenerics::splitAdditional() |>
      dplyr::filter(variable_name == "Number records", standard_concept_name == "overall") |>
      dplyr::select(-c(starts_with("standard_"), starts_with("source_"), "domain_id")) |>
      dplyr::arrange(dplyr::across(dplyr::everything())),
    ignore_attr = TRUE
  )
  expect_true(results1 |>
                omopgenerics::splitAdditional() |>
                dplyr::filter(variable_name  == "Number subjects",
                              group_level == "acetiminophen",
                              time_interval == "1909-01-01 to 1909-12-31",
                              strata_level == "0 to 17")  |>
                dplyr::pull("estimate_value") |>
                as.numeric() ==
                cdm$drug_exposure %>%
                dplyr::filter(drug_concept_id %in% acetiminophen) %>%
                PatientProfiles::addAge(indexDate = "drug_exposure_start_date") %>%
                PatientProfiles::addSex() %>%
                dplyr::filter(age >= "0", age <= "17", clock::get_year(drug_exposure_start_date) == 1909) |>
                dplyr::select("person_id") %>%
                dplyr::distinct() %>%
                dplyr::tally() %>%
                dplyr::pull("n"))
  expect_true(results1$group_level |> unique() |> length() == 2)

  results <- summariseConceptSetCounts(list("acetiminophen" = acetiminophen),
                              cdm = cdm, countBy = "person",
                              interval = "years",
                              sex = FALSE,
                              ageGroup = NULL)
  expect_true(nrow(results %>%
                     dplyr::filter(variable_name == "Number subjects")) > 0)
  expect_true(nrow(results %>%
                     dplyr::filter(variable_name == "Number records")) == 0)


  results <- summariseConceptSetCounts(list("acetiminophen" = acetiminophen),
                              cdm = cdm, countBy = "record",
                              interval = "years",
                              sex = FALSE,
                              ageGroup = NULL)
  expect_true(nrow(results %>%
                     dplyr::filter(variable_name == "Number subjects")) == 0)
  expect_true(nrow(results %>%
                     dplyr::filter(variable_name == "Number records")) > 0)

  # domains covered
  # condition
  expect_true(nrow(summariseConceptSetCounts(list(cs= c(4112343)),
                                    cdm = cdm,
                                    interval = "years",
                                    sex = FALSE,
                                    ageGroup = NULL))>1)

  # visit
  expect_true(nrow(summariseConceptSetCounts(list(cs= c(9201)),
                                    cdm = cdm,
                                    interval = "years",
                                    sex = FALSE,
                                    ageGroup = NULL))>1)

  # drug
  expect_true(nrow(summariseConceptSetCounts(list(cs= c(40213160)),
                                    cdm = cdm,
                                    interval = "years",
                                    sex = FALSE,
                                    ageGroup = NULL))>1)

  # measurement
  expect_true(nrow(summariseConceptSetCounts(list(cs= c(3006322)),
                                    cdm = cdm,
                                    interval = "years",
                                    sex = FALSE,
                                    ageGroup = NULL))>1)

  # procedure and condition
  expect_true(nrow(summariseConceptSetCounts(list(cs= c(4107731,4112343)),
                                    cdm = cdm,
                                    interval = "years",
                                    sex = FALSE,
                                    ageGroup = NULL))>1)

  # no records
  expect_warning(results <- summariseConceptSetCounts(list(cs= c(999999)),
                                             cdm = cdm,
                                             interval = "years",
                                             sex = FALSE,
                                             ageGroup = NULL))
  expect_true(nrow(results) == 0)

  # conceptSet NULL (but reduce the computational time by filtering concepts first)
  # cdm$concept <- cdm$concept |>
  #   dplyr::filter(grepl("k", concept_name))
  #
  # skip("conceptSet = NULL not supported yet")
  # results <- summariseConceptSetCounts(cdm = cdm,
  #                                   year = FALSE,
  #                                   sex = FALSE,
  #                                   ageGroup = NULL)
  #
  # results_concepts <- results |>
  #   dplyr::select(variable_name) |>
  #   dplyr::distinct() |>
  #   dplyr::pull()
  # concepts <- cdm$concept |>
  #   dplyr::select(concept_name) |>
  #   dplyr::distinct() |>
  #   dplyr::pull()
  #
  # expect_true(all(results_concepts %in% c("overall",concepts)))

  # check attributes
  results <- summariseConceptSetCounts(cdm = cdm,
                                    conceptSet = cs,
                                    interval = "years",
                                    sex = TRUE,
                                    ageGroup = list(c(0,17),
                                                    c(18,65),
                                                    c(66, 100)))

  expect_true(omopgenerics::settings(results)$package_name == "OmopSketch")
  expect_true(omopgenerics::settings(results)$result_type == "summarise_concept_set_counts")
  expect_true(omopgenerics::settings(results)$package_version == packageVersion("OmopSketch"))

  # expected errors# expected errors
  expect_error(summariseConceptSetCounts("not a concept",
                                cdm = cdm,
                                interval = "years",
                                sex = FALSE,
                                ageGroup = NULL))
  expect_error(summariseConceptSetCounts("123",
                                cdm = cdm,
                                interval = "years",
                                sex = FALSE,
                                ageGroup = NULL))
  expect_error(summariseConceptSetCounts(list("123"), # not named
                                cdm = cdm,
                                interval = "years",
                                sex = FALSE,
                                ageGroup = NULL))
  expect_error(summariseConceptSetCounts(list(a = 123),
                                cdm = "not a cdm",
                                interval = "years",
                                sex = FALSE,
                                ageGroup = NULL))
  expect_error(summariseConceptSetCounts(list(a = 123),
                                cdm = cdm,
                                interval = "Maybe",
                                sex = FALSE,
                                ageGroup = NULL))
  expect_error(summariseConceptSetCounts(list(a = 123),
                                cdm = cdm,
                                interval = "years",
                                sex = "Maybe",
                                ageGroup = NULL))
  expect_error(summariseConceptSetCounts(list(a = 123),
                                cdm = cdm,
                                interval = "years",
                                sex = FALSE,
                                ageGroup = list(c(18,17))))
  expect_error(summariseConceptSetCounts(list(a = 123),
                                cdm = cdm,
                                interval = "years",
                                sex = FALSE,
                                ageGroup = list(c(0,17),
                                                c(15,20))))





  CDMConnector::cdmDisconnect(cdm)
})

test_that("summarise code use - mock data", {
  skip_on_cran()
  person <- tibble::tibble(
    person_id = c(1L,2L),
    gender_concept_id = c(8532L,8507L),
    year_of_birth = c(1997L,1963L),
    month_of_birth = c(8L,1L),
    day_of_birth = c(22L,27L),
    race_concept_id = c(1L,1L),
    ethnicity_concept_id = c(1L,1L)
  )
  observation_period <- tibble::tibble(
    person_id = c(1L,2L),
    observation_period_id = c(1L,2L),
    observation_period_start_date = c(as.Date("2000-06-03"), as.Date("1999-05-04")),
    observation_period_end_date = c(as.Date("2013-08-03"), as.Date("2004-01-04")),
    period_type_concept_id = c(1L,1L)
  )
  condition_occurrence <- tibble::tibble(
    person_id = c(1L,1L,1L,2L,2L,2L,2L,2L),
    condition_concept_id = c(1L,3L,5L,1L,5L,5L,17L,17L),
    condition_start_date = c(as.Date("2002-06-30"), as.Date("2004-05-29"), as.Date("2001-12-20"),
                             as.Date("2000-03-10"), as.Date("2000-02-25"), as.Date("1999-07-15"),
                             as.Date("1999-06-06"), as.Date("2000-07-17")),
    condition_end_date = c(as.Date("2004-09-30"), as.Date("2009-05-29"), as.Date("2008-12-20"),
                             as.Date("2001-03-10"), as.Date("2001-12-25"), as.Date("2001-07-15"),
                             as.Date("2002-06-06"), as.Date("2000-11-17")),
    condition_occurrence_id = c(1L,2L,3L,4L,5L,6L,7L,8L),
    condition_type_concept_id = c(1L),
    condition_source_concept_id = c(as.integer(NA))
  )
  concept <- tibble::tibble(
    concept_id = c(1L,3L,5L,17L),
    concept_name = c("Musculoskeletal disorder", "Arthritis", "Osteoarthritis of hip", "Arthritis"),
    domain_id = c("Condition"),
    standard_concept = c("S","S","S",NA),
    vocabulary_id = c("SNOMED", "SNOMED", "SNOMED", "ICD10"),
    concept_class_id = c("Clinical Finding", "Clinical Finding", "Clinical Finding", "ICD Code"),
    concept_code = c("1234"),
    valid_start_date = c(as.Date(NA)),
    valid_end_date = c(as.Date(NA))
  )

  cdm <- omopgenerics::cdmFromTables(
    tables = list(
      person = person,
      observation_period = observation_period,
      condition_occurrence = condition_occurrence,
      concept = concept
    ),
    cdmName = "mock data"
  )
  cdm <- CDMConnector::copyCdmTo(
    con = connection(), cdm = cdm, schema = schema())

  conceptSet <- list(
    "Arthritis" = c(17,3),
    "Musculoskeletal disorder" = c(1),
    "Osteoarthritis of hip" = c(5)
  )

  result <- summariseConceptSetCounts(cdm, conceptSet)

  # Arthritis (codes 3 and 17), one record of 17 per ind and one record of 3 ind 1
  expect_equal(result |>
                 omopgenerics::splitAdditional() |>
                 dplyr::filter(standard_concept_name == "Arthritis",
                               strata_level == "overall") |>
                 dplyr::arrange(standard_concept_id, variable_name) |>
                 dplyr::pull(estimate_value),
               c("2", "1", "1", "1"))

  # Osteoarthritis (code 5), two records ind 2, one record ind 1
  expect_equal(result |>
                 omopgenerics::splitAdditional() |>
                 dplyr::filter(standard_concept_name == "Osteoarthritis of hip",
                               strata_level == "overall") |>
                 dplyr::arrange(standard_concept_id, variable_name) |>
                 dplyr::pull(estimate_value),
               c("3","2"))

  # Musculoskeletal disorder (code 1), one record each ind
  expect_equal(result |>
                 omopgenerics::splitAdditional() |>
                 dplyr::filter(standard_concept_name == "Musculoskeletal disorder",
                               strata_level == "overall") |>
                 dplyr::arrange(standard_concept_id, variable_name) |>
                 dplyr::pull(estimate_value),
               c("2","2"))

  result <- summariseConceptSetCounts(cdm, conceptSet, ageGroup = list(c(0,2), c(3,150)), sex = TRUE)
  # Individuals belong to the same age group but to different sex groups

  # Arthritis (codes 3 and 17), one record of each per ind
  expect_equal(result |>
                 omopgenerics::splitAdditional() |>
                 dplyr::filter(standard_concept_name == "Arthritis" & strata_level == "Male") |>
                 dplyr::arrange(standard_concept_id, variable_name) |>
                 dplyr::pull(estimate_value),
               c("2","1"))
  expect_equal(result |>
                 omopgenerics::splitAdditional() |>
                 dplyr::filter(standard_concept_name =="Arthritis" & strata_level == "3 to 150 &&& Male") |>
                 dplyr::arrange(standard_concept_id, variable_name) |>
                 dplyr::pull(estimate_value),
               c("2","1"))
  expect_equal(result |>
                 omopgenerics::splitAdditional() |>
                 dplyr::filter(standard_concept_name == "Arthritis" & strata_level == "3 to 150") |>
                 dplyr::arrange(standard_concept_id, variable_name) |>
                 dplyr::pull(estimate_value),
               c("2","1","1","1"))

  # Osteoarthritis of hip (code 5), two records ind 2 and one ind 1
  expect_equal(result |>
                 omopgenerics::splitAdditional() |>
                 dplyr::filter(standard_concept_name == "Osteoarthritis of hip" & strata_level == "Female") |>
                 dplyr::tally() |>
                 dplyr::pull(),
               2)

  # Musculoskeletal disorder (code 1), one record each ind
  expect_equal(result |>
                 omopgenerics::splitAdditional() |>
                 dplyr::filter(standard_concept_name == "Musculoskeletal disorder" & strata_level == "3 to 150 &&& Female") |>
                 dplyr::arrange(standard_concept_id, variable_name) |>
                 dplyr::pull(estimate_value),
               c("1","1"))
  expect_equal(result |>
                 omopgenerics::splitAdditional() |>
                 dplyr::filter(standard_concept_name == "Musculoskeletal disorder" & strata_level == "3 to 150 &&& Male") |>
                 dplyr::arrange(standard_concept_id, variable_name) |>
                 dplyr::pull(estimate_value),
               c("1","1"))
  expect_equal(result |>
                 omopgenerics::splitAdditional() |>
                 dplyr::filter(standard_concept_name == "Musculoskeletal disorder" & strata_level == "3 to 150") |>
                 dplyr::arrange(standard_concept_id, variable_name) |>
                 dplyr::pull(estimate_value),
               c("2","2"))
  expect_equal(result |>
                 omopgenerics::splitAdditional() |>
                 dplyr::filter(standard_concept_name == "Musculoskeletal disorder" & strata_level == "overall") |>
                 dplyr::arrange(standard_concept_id, variable_name) |>
                 dplyr::pull(estimate_value),
               c("2","2"))

  PatientProfiles::mockDisconnect(cdm)
})

test_that("plot concept set counts works", {
  skip_on_cran()
  # Load mock database ----
  cdm <- cdmEunomia()

  # summariseInObservationPlot plot ----
  x <- summariseConceptSetCounts(cdm, conceptSet = list(codes = c(40213160)))
  expect_error(plotConceptSetCounts(x))
  x <- x |> dplyr::filter(variable_name == "Number records")
  expect_no_error(plotConceptSetCounts(x))
  expect_true(inherits(plotConceptSetCounts(x), "ggplot"))

  x <- summariseConceptSetCounts(cdm,
                              conceptSet = list("polio" = c(40213160),
                                               "acetaminophen" = c(1125315,  1127433, 40229134, 40231925, 40162522, 19133768,  1127078)))
  expect_error(plotConceptSetCounts(x))
  x <- x |> dplyr::filter(variable_name == "Number records")
  expect_no_error(plotConceptSetCounts(x))
  expect_message(plotConceptSetCounts(x))
  expect_no_error(plotConceptSetCounts(x, facet = "codelist_name"))
  expect_no_error(plotConceptSetCounts(x, colour = "codelist_name"))

  x <-  x |> dplyr::filter(result_id == -1)
  expect_error(plotInObservation(x))

  PatientProfiles::mockDisconnect(cdm = cdm)
})

test_that("dateRange argument works", {
  skip_on_cran()
  # Load mock database ----
  cdm <- cdmEunomia()

  expect_no_error(summariseConceptSetCounts(cdm,conceptSet = list("polio" = c(40213160)), dateRange =  as.Date(c("1930-01-01", "2018-01-01"))))
  expect_message(x<-summariseConceptSetCounts(cdm,conceptSet = list("polio" = c(40213160)), dateRange =  as.Date(c("1930-01-01", "2025-01-01"))))
  observationRange <- cdm$observation_period |>
    dplyr::summarise(minobs = min(.data$observation_period_start_date, na.rm = TRUE),
                     maxobs = max(.data$observation_period_end_date, na.rm = TRUE))
  expect_no_error(y<- summariseConceptSetCounts(cdm,conceptSet = list("polio" = c(40213160)), dateRange = as.Date(c("1930-01-01", observationRange |>dplyr::pull("maxobs")))))
  expect_equal(x,y, ignore_attr = TRUE)
  expect_false(settings(x)$study_period_end==settings(y)$study_period_end)
  expect_error(summariseConceptSetCounts(cdm,conceptSet = list("polio" = c(40213160)), dateRange =  as.Date(c("2015-01-01", "2014-01-01"))))
  expect_warning(z<-summariseConceptSetCounts(cdm,conceptSet = list("polio" = c(40213160)), dateRange =  as.Date(c("2020-01-01", "2021-01-01"))))
  expect_equal(z, omopgenerics::emptySummarisedResult(), ignore_attr = TRUE)
  expect_equal(summariseConceptSetCounts(cdm,conceptSet = list("polio" = c(40213160)),dateRange = as.Date(c("1930-01-01",NA))), y, ignore_attr = TRUE)
  checkResultType(z, "summarise_concept_set_counts")
  expect_equal(colnames(settings(z)), colnames(settings(x)))
  PatientProfiles::mockDisconnect(cdm = cdm)
})

test_that("interval argument works", {
  skip_on_cran()
  # Load mock database ----
  cdm <- mockOmopSketch()
  expect_no_error(y<-summariseConceptSetCounts(list(ANTIHISTAMINES= c(21603444)),
                         cdm = cdm,
                         interval = "years"))

  expect_no_error(o<-summariseConceptSetCounts(list(ANTIHISTAMINES= c(21603444)),
                                            cdm = cdm,
                                            interval = "overall"))
  expect_no_error(q<-summariseConceptSetCounts(list(ANTIHISTAMINES= c(21603444)),
                                            cdm = cdm,
                                            interval = "quarters"))
  expect_no_error(m<-summariseConceptSetCounts(list(ANTIHISTAMINES= c(21603444)),
                                            cdm = cdm,
                                            interval = "months"))



  m_quarters <- m|>omopgenerics::splitAdditional()|>
    omopgenerics::pivotEstimates() |>
    dplyr::filter(time_interval != "overall" & variable_name == "Number records" & standard_concept_id == 21603444) |>
    dplyr::mutate(
      start_date = as.Date(sub(" to .*", "", time_interval)),
      quarter_start = lubridate::quarter(start_date, type = "date_first"),
      quarter_end = lubridate::quarter(start_date, type = "date_last"),
      quarter = paste(quarter_start, "to", quarter_end)
    ) |>
    dplyr::select(!c("time_interval", "start_date", "quarter_start", "quarter_end")) |>
    dplyr::group_by(quarter,)|>
    dplyr::summarise(count = sum(count), .groups = "drop") |>
    dplyr::rename("time_interval" = quarter) |>
    dplyr::arrange(time_interval)

  q_quarters <- q|>omopgenerics::splitAdditional()|>
   omopgenerics::pivotEstimates()|>
   dplyr::filter(time_interval != "overall" & variable_name == "Number records"& standard_concept_id == 21603444)|>
   dplyr::select(time_interval, count)|>
   dplyr::arrange(time_interval)

  expect_equal(m_quarters, q_quarters)

  m_year <- m|>
   omopgenerics::splitAdditional()|>
   dplyr::filter(time_interval != "overall" & variable_name == "Number records" & standard_concept_id == 21603444)|>
   dplyr::mutate(
     # Extract the start date
     start_date = clock::date_parse(stringr::str_extract(time_interval, "^\\d{4}-\\d{2}-\\d{2}")),
     # Convert start_date to a year-month-day object and extract the year
     year = clock::get_year(clock::as_year_month_day(start_date))
   )|>
   omopgenerics::pivotEstimates()|>
   dplyr::group_by(year) %>%
   dplyr::summarise(
     count = sum(count),
     .groups = "drop"
   )|>
   dplyr::arrange(year)
  y_year <- y|>
   omopgenerics::splitAdditional()|>
   dplyr::filter(time_interval != "overall" & variable_name == "Number records" & standard_concept_id == 21603444)|>
   dplyr::mutate(
     # Extract the start date
     start_date = clock::date_parse(stringr::str_extract(time_interval, "^\\d{4}-\\d{2}-\\d{2}")),
     # Convert start_date to a year-month-day object and extract the year
     year = clock::get_year(clock::as_year_month_day(start_date))
   )|>
   omopgenerics::pivotEstimates()|>
   dplyr::select(year, count)|>
   dplyr::arrange(year)

  expect_equal(m_year, y_year)
  o <- o |> omopgenerics::splitAdditional()|>
   dplyr::filter(variable_name == "Number records" & standard_concept_id == 21603444)|>
   omopgenerics::pivotEstimates()|>
   dplyr::select(count)

  expect_equal(y_year|>dplyr::summarise(count = sum(count)), o)


  q_year <- q|>
   omopgenerics::splitAdditional()|>
   dplyr::filter(time_interval != "overall" & variable_name == "Number records" & standard_concept_id == 21603444)|>
   dplyr::mutate(
     # Extract the start date
     start_date = clock::date_parse(stringr::str_extract(time_interval, "^\\d{4}-\\d{2}-\\d{2}")),
     # Convert start_date to a year-month-day object and extract the year
     year = clock::get_year(clock::as_year_month_day(start_date))
   )|>
   omopgenerics::pivotEstimates()|>
   dplyr::group_by(year) %>%
   dplyr::summarise(
     count = sum(count),
     .groups = "drop"
   )|>
   dplyr::arrange(year)

  expect_equal(q_year, y_year)
  PatientProfiles::mockDisconnect(cdm = cdm)
})
