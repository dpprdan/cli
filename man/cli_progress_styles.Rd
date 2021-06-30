% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/progress-bar.R
\name{cli_progress_styles}
\alias{cli_progress_styles}
\title{List of built-in cli progress styles}
\usage{
cli_progress_styles()
}
\value{
A named list with sublists containing elements
\code{complete}, \code{incomplete} and potentially \code{current}.
}
\description{
The following options are used to select a style:
\itemize{
\item \code{cli_progress_bar_style}
\item \code{cli_progress_bar_style_ascii}
\item \code{cli_progress_bar_style_unicode}
}
}
\details{
On Unicode terminals (if \code{\link[=is_utf8_output]{is_utf8_output()}} is \code{TRUE}), the
\code{cli_progress_bar_style_unicode} and \code{cli_progress_bar_style}
options are used.

On ASCII terminals (if \code{\link[=is_utf8_output]{is_utf8_output()}} is \code{FALSE}), the
\code{cli_pgoress_bar_style_ascii} and \code{cli_progress_bar_style} options
are are used.
}
\examples{
cli_progress_styles()
}