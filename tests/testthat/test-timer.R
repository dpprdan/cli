test_that("ALTREP methods", {
  expect_equal(length(`__cli_update_due`), 1L)

  expect_silent({
    tim <- `__cli_update_due`
    tim[1] <- FALSE
  })

  expect_silent({
    `__cli_update_due`[1]
  })
})

test_that("cli_tick_set", {
  skip_on_cran()
  expect_silent(cli_tick_set())
})
