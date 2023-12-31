% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/oras_helpers.R
\name{oras_login}
\alias{oras_login}
\title{Log in to a remote registry}
\usage{
oras_login(
  registry = "ghcr.io",
  username = Sys.getenv("GITHUB_TOKEN"),
  password = Sys.getenv("GITHUB_TOKEN"),
  flags = "",
  verbose = TRUE
)
}
\arguments{
\item{registry}{Address of the remote}

\item{username}{username (for GH, may be username or token)}

\item{password}{password or token (e.g. GitHub Token with Packages scope)}

\item{flags}{additional flags, see \code{oras_login(-h)}}

\item{verbose}{show output messages? logical, TRUE}
}
\value{
Returns the list from \code{\link[processx:run]{processx::run()}}, with components \code{status},
\code{stdout}, \code{stderr}, and \code{timeout}; invisibly.
}
\description{
Log in to a remote registry
}
\examples{
\dontshow{if (interactive()) (if (getRversion() >= "3.4") withAutoprint else force)(\{ # examplesIf}

# login to self-hosted system
oras_login("localhost:5000", username = "u", password = "p")

# login to GitHub Container Registry (when GITHUB_TOKEN env var is set)
oras_login()
\dontshow{\}) # examplesIf}
}
