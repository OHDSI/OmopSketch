test_that("summarise omop snapshot works", {

  cdm <- cdmEunomia()

  expect_no_error(result <- summariseOmopSnapshot(cdm))

  PatientProfiles::mockDisconnect(cdm = cdm)

})
