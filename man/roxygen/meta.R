if (exists(".knitr_asciicast_process", envir = .GlobalEnv)) {
  rm(list = ".knitr_asciicast_process", envir = .GlobalEnv)
}

asciicast::init_knitr_engine(
  echo = TRUE,
  echo_input = FALSE,
  interactive = TRUE,
  timeout = as.integer(Sys.getenv("ASCIICAST_TIMEOUT", 10)),
  startup = quote({
    options(cli.width = 70)
    options(cli.progress_show_after = 0)
    options(cli.progress_clear = FALSE)
    library(cli)
    set.seed(1)
  })
)

knitr::opts_chunk$set(
  asciicast_knitr_output = "html",
  asciicast_include_style = FALSE,
  asciicast_theme = "pkgdown"
)

list(
  markdown = TRUE,
  knitr_chunk_options = list(
    cache = TRUE,
    cache_lazy = FALSE,
    cache.path = file.path(getwd(), "man/_cache/"),
    fig.path = file.path(getwd(), "man/figures"),
    error = TRUE
  ),
  restrict_image_formats = TRUE
)
