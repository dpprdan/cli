% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ansiex.R
\name{ansi_strtrim}
\alias{ansi_strtrim}
\title{Truncate an ANSI string}
\usage{
ansi_strtrim(x, width = console_width(), ellipsis = symbol$ellipsis)
}
\arguments{
\item{x}{Character vector of ANSI strings.}

\item{width}{The width to truncate to.}

\item{ellipsis}{The string to append to truncated strings. Supply an
empty string if you don't want a marker.}
}
\description{
This function is similar to \code{\link[base:strtrim]{base::strtrim()}}, but works correctly with
ANSI styled strings. It also adds \code{...} (or the corresponding Unicode
character if Unicode characters are allowed) to the end of truncated
strings.
}
\details{
Note: \code{ansi_strtrim()} does not support NA values currently.
}
\examples{
text <- cli::col_red(cli:::lorem_ipsum())
ansi_strtrim(c(text, "foobar"), 40)
}
\seealso{
Other ANSI string operations: 
\code{\link{ansi_align}()},
\code{\link{ansi_columns}()},
\code{\link{ansi_nchar}()},
\code{\link{ansi_strsplit}()},
\code{\link{ansi_strwrap}()},
\code{\link{ansi_substr}()},
\code{\link{ansi_substring}()},
\code{\link{ansi_toupper}()},
\code{\link{ansi_trimws}()}
}
\concept{ANSI string operations}
