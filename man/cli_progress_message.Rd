% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/progress-client.R
\name{cli_progress_message}
\alias{cli_progress_message}
\title{Simplified cli progress messages}
\usage{
cli_progress_message(
  msg,
  current = TRUE,
  .auto_close = TRUE,
  .envir = parent.frame(),
  ...
)
}
\arguments{
\item{msg}{Message to show. It may contain glue substitution and cli
styling. It can be updated via \code{\link[=cli_progress_update]{cli_progress_update()}}, as usual.}

\item{current}{Passed to \code{\link[=cli_progress_bar]{cli_progress_bar()}}.}

\item{.auto_close}{Passed to \code{\link[=cli_progress_bar]{cli_progress_bar()}}.}

\item{.envir}{Passed to \code{\link[=cli_progress_bar]{cli_progress_bar()}}.}

\item{...}{Passed to \code{\link[=cli_progress_bar]{cli_progress_bar()}}.}
}
\value{
The id of the new progress bar.
}
\description{
This is a simplified progress bar, a single (dynamic)
message, without progress units.
}
\details{
\code{cli_progress_message()} always shows the message, even if no
update is due. When the progress message is terminated, it is removed
from the screen by default.

Note that the message can be dynamic: if you update it with
\code{\link[=cli_progress_update]{cli_progress_update()}}, then cli uses the current values in the string
substitutions.

\if{html}{\out{<div class="sourceCode r">}}\preformatted{fun <- function() \{
  cli_progress_message("Task one is running...")
  Sys.sleep(2)

  cli_progress_message("Task two is running...")
  Sys.sleep(2)

  step <- 1L
  cli_progress_message("Task three is underway: step \{step\}")
  for (step in 1:5) \{
    Sys.sleep(0.5)
    cli_progress_update()
  \}
\}
fun()
}\if{html}{\out{</div>}}

\if{html}{\figure{progress-message.svg}}
}
\seealso{
This function supports \link[=inline-markup]{inline markup}.

\code{\link[=cli_progress_bar]{cli_progress_bar()}} for the complete progress bar API.
\code{\link[=cli_progress_step]{cli_progress_step()}} for a similar display that is styled by default.

Other progress bar functions: 
\code{\link{cli_progress_along}()},
\code{\link{cli_progress_bar}()},
\code{\link{cli_progress_builtin_handlers}()},
\code{\link{cli_progress_num}()},
\code{\link{cli_progress_output}()},
\code{\link{cli_progress_step}()},
\code{\link{cli_progress_styles}()},
\code{\link{progress-variables}}

Other functions supporting inline markup: 
\code{\link{cli_abort}()},
\code{\link{cli_alert}()},
\code{\link{cli_blockquote}()},
\code{\link{cli_bullets}()},
\code{\link{cli_bullets_raw}()},
\code{\link{cli_dl}()},
\code{\link{cli_h1}()},
\code{\link{cli_li}()},
\code{\link{cli_ol}()},
\code{\link{cli_process_start}()},
\code{\link{cli_progress_along}()},
\code{\link{cli_progress_bar}()},
\code{\link{cli_progress_output}()},
\code{\link{cli_progress_step}()},
\code{\link{cli_rule}},
\code{\link{cli_status}()},
\code{\link{cli_status_update}()},
\code{\link{cli_text}()},
\code{\link{cli_ul}()},
\code{\link{format_error}()},
\code{\link{format_inline}()}
}
\concept{functions supporting inline markup}
\concept{progress bar functions}
