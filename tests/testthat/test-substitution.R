start_app()
on.exit(stop_app(), add = TRUE)

test_that("glue errors", {
  expect_snapshot(error = TRUE, {
    cli_h1("foo { asdfasdfasdf } bar")
    cli_text("foo {cmd {dsfsdf()}}")
  })
})
