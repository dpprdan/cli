start_app(.auto_close = TRUE)

test_that_cli("add/remove/list themes", {
  withr::local_rng_version("3.3.0")
  set.seed(24)

  start_app(.auto_close = TRUE)

  id <- default_app()$add_theme(list(".green" = list(color = "green")))
  expect_true(id %in% names(default_app()$list_themes()))

  expect_snapshot({
    cli_par(class = "green")
    cli_text(lorem_ipsum())
    cli_end()
  })

  default_app()$remove_theme(id)
  expect_false(id %in% names(default_app()$list_themes()))
})

test_that("default theme is valid", {
  expect_error(
    {
      id <- default_app()$add_theme(builtin_theme())
      default_app()$remove_theme(id)
    },
    NA
  )
})

test_that("explicit formatter is used, and combined", {
  id <- default_app()$add_theme(list(
    "span.emph" = list(
      fmt = function(x) paste0("(((", x, ")))"),
      before = "<<",
      after = ">>"
    )
  ))
  on.exit(default_app()$remove_theme(id), add = TRUE)
  expect_snapshot(
    cli_text("this is {.emph it}, really")
  )
})

test_that("simple theme", {
  def <- simple_theme()
  expect_true(is.list(def))
  expect_false(is.null(names(def)))
  expect_true(all(names(def) != ""))
  expect_true(all(vlapply(def, is.list)))
})

test_that("user's override", {
  custom <- list(".alert" = list(before = "custom:"))
  override <- list(".alert" = list(after = "override:"))

  expect_snapshot(local({
    start_app(theme = custom, .auto_close = FALSE)
    cli_alert("Alert!")
    stop_app()

    withr::local_options(cli.user_theme = override)
    start_app(theme = custom, .auto_close = FALSE)
    cli_alert("Alert!")
    stop_app()
  }))
})

test_that("theme does not precompute Unicode symbols", {
  withr::local_options(cli.unicode = TRUE, cli.num_colors = 256L)
  start_app()
  msg <- NULL
  withCallingHandlers(
    cli_alert_success("ok"),
    cliMessage = function(m) {
      msg <<- m
      invokeRestart("muffleMessage")
    }
  )
  expect_true(ansi_has_any(msg$message))

  msg2 <- NULL
  withr::local_options(cli.unicode = FALSE, cli.num_colors = 1L)
  withCallingHandlers(
    cli_alert_success("ok2"),
    cliMessage = function(m) {
      msg2 <<- m
      invokeRestart("muffleMessage")
    }
  )
  expect_equal(msg2$message, "v ok2\n")
})

test_that("NULL will undo a style property", {
  expect_snapshot(local({
    cli_alert("this has an arrow")
    cli_div(theme = list(.alert = list(before = NULL)))
    cli_alert("this does not")
  }))
})

test_that_cli(configs = "ansi", "NULL will undo color", {
  expect_snapshot(local({
    cli_alert("{.emph {.val this is blue}}")
    cli_div(theme = list(span.val = list(color = NULL)))
    cli_alert("{.emph {.val this is not}}")
  }))
  expect_snapshot(local({
    cli_alert("{.emph {.val this is blue}}")
    cli_div(theme = list(span.val = list(color = "none")))
    cli_alert("{.emph {.val this is not}}")
  }))
})

withr::local_options(cli.theme = NULL, cli.user_theme = NULL)
withr::local_options(cli.theme_dark = FALSE, cli.num_colors = 256)
start_app()
on.exit(stop_app(), add = TRUE)

test_that_cli(configs = "ansi", "NULL will undo background color", {
  skip_if_not_installed("testthat", "3.1.2")
  expect_snapshot(local({
    cli_alert("{.emph {.code this has bg color}}")
    cli_div(theme = list(span = list("background-color" = NULL)))
    cli_alert("{.emph {.code this does not}}")
  }))
  expect_snapshot(local({
    cli_alert("{.emph {.code this has bg color}}")
    cli_div(theme = list(span = list("background-color" = "none")))
    cli_alert("{.emph {.code this does not}}")
  }))
})
