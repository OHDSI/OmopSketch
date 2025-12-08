test_that("test sql translations in each dialect", {
  cdm <- cdmEunomia()

  # datediffYear
  x <- dplyr::tibble(
    date_x = as.Date(c("2015-05-09", "2024-12-01", "2015-05-30")),
    date_y = as.Date(c("2010-05-09", "2000-12-02", "2005-05-29")),
    id = 1:3L
  )
  cdm <- omopgenerics::insertTable(cdm = cdm, name = "x", table = x)
  y <- cdm$x |>
    datediffYear(start = "date_x", end = "date_y", name = "diff") |>
    datediffYear(start = "date_y", end = "date_x", name = "diff2") |>
    dplyr::collect() |>
    dplyr::arrange(.data$id)
  expect_true(all(c("diff", "diff2") %in% colnames(y)))
  expect_identical(y$diff, c(-5L, -23L, -10L))
  expect_identical(y$diff2, c(5L, 23L, 10L))

  # getYear
  x <- dplyr::tibble(
    date_x = as.Date(c("2015-05-09", "2024-12-01", "2015-05-30")),
    date_y = as.Date(c("2010-05-09", "2000-12-02", "2005-05-29")),
    id = 1:3L
  )
  cdm <- omopgenerics::insertTable(cdm = cdm, name = "x", table = x)
  y <- cdm$x |>
    getYear(date = "date_x", name = "y1") |>
    getYear(date = "date_y", name = "y2") |>
    dplyr::collect() |>
    dplyr::arrange(.data$id)
  expect_true(all(c("y1", "y2") %in% colnames(y)))
  expect_identical(y$y1, c(2015L, 2024L, 2015L))
  expect_identical(y$y2, c(2010L, 2000L, 2005L))

  # datediffDays
  x <- dplyr::tibble(
    date_x = as.Date(c("2015-05-09", "2024-12-01", "2015-05-30")),
    date_y = as.Date(c("2010-05-09", "2000-12-02", "2005-05-29")),
    id = 1:3L
  )
  cdm <- omopgenerics::insertTable(cdm = cdm, name = "x", table = x)
  y <- cdm$x |>
    datediffDays(start = "date_x", end = "date_y", name = "diff") |>
    datediffDays(start = "date_y", end = "date_x", name = "diff2") |>
    dplyr::collect() |>
    dplyr::arrange(.data$id)
  expect_true(all(c("diff", "diff2") %in% colnames(y)))
  expect_identical(y$diff, c(-1826, -8765, -3653))
  expect_identical(y$diff2, c(1826, 8765, 3653))

  # datediffDays offset = 123
  x <- dplyr::tibble(
    date_x = as.Date(c("2015-05-09", "2024-12-01", "2015-05-30")),
    date_y = as.Date(c("2010-05-09", "2000-12-02", "2005-05-29")),
    id = 1:3L
  )
  cdm <- omopgenerics::insertTable(cdm = cdm, name = "x", table = x)
  y <- cdm$x |>
    datediffDays(start = "date_x", end = "date_y", name = "diff", offset = 123) |>
    datediffDays(start = "date_y", end = "date_x", name = "diff2", offset = 123) |>
    dplyr::collect() |>
    dplyr::arrange(.data$id)
  expect_true(all(c("diff", "diff2") %in% colnames(y)))
  expect_identical(y$diff, c(-1826, -8765, -3653) + 123)
  expect_identical(y$diff2, c(1826, 8765, 3653) + 123)

  # datediffDays offset = -123
  x <- dplyr::tibble(
    date_x = as.Date(c("2015-05-09", "2024-12-01", "2015-05-30")),
    date_y = as.Date(c("2010-05-09", "2000-12-02", "2005-05-29")),
    id = 1:3L
  )
  cdm <- omopgenerics::insertTable(cdm = cdm, name = "x", table = x)
  y <- cdm$x |>
    datediffDays(start = "date_x", end = "date_y", name = "diff", offset = -123) |>
    datediffDays(start = "date_y", end = "date_x", name = "diff2", offset = -123) |>
    dplyr::collect() |>
    dplyr::arrange(.data$id)
  expect_true(all(c("diff", "diff2") %in% colnames(y)))
  expect_identical(y$diff, c(-1826, -8765, -3653) - 123)
  expect_identical(y$diff2, c(1826, 8765, 3653) - 123)

  dropCreatedTables(cdm = cdm)
})
