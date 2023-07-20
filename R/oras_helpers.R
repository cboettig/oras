
#' copy artifacts from one target to another
#' @param from artifact address
#' @param to artifact destination
#' @param verbose show output messages? logical, TRUE
#' @param flags see `oras_cp("-h")` for list of flags
#' @inherit oras return
#' @examplesIf FALSE
#' oras_cp("localhost:5000/hello:v1", "localhost:5001/hello:v1")
oras_cp <- function(from, to, flags="", verbose = TRUE) {
  
  cmd <- paste("cp", flags, from, to)
  cmd <- gsub("\\s+", " ", cmd)
  oras(cmd, verbose = verbose)
}

#' Push files to remote registry
#' @param name of file in registry (optionally with tag or hash)
#' @param file local file to push
#' @param flags additional flags, see `oras_push("-h")`
#' @inheritParams oras_cp
#' @inherit oras return
#' @examplesIf FALSE
#' oras_push("localhost:5000/hello:v1", "hi.txt")
#' @export
oras_push <- function(name, file, flags="", verbose = TRUE) {
  
  cmd <- paste("push", flags, name, file)
  cmd <- gsub("\\s+", " ", cmd)
  oras(cmd, verbose = verbose)
}

#' Pull files from remote registry
#' @param name name (with tag or digest optional) of registry to pull from
#' @param flags additional flags, see `oras_pull("-h")`
#' @inheritParams oras_cp
#' @inherit oras return
#' @examplesIf FALSE
#' oras_pull("localhost:5000/hello:v1")
#' @export
oras_pull <- function(name, flags="", verbose = TRUE) {
  cmd <- paste("pull", flags, name)
  cmd <- gsub("\\s+", " ", cmd)
  oras(cmd, verbose = verbose)
}

#' Log in to a remote registry
#'
#' @param username username (for GH, may be username or token)
#' @param password password or token (e.g. GitHub Token with Packages scope)
#' @param flags additional flags, see `oras_login(-h)`
#' @param registry Address of the remote
#' @inheritParams oras_cp
#' @inherit oras return
#' @examplesIf FALSE
#' 
#' # login to self-hosted system
#' oras_login("localhost:5000", username = "u", password = "p")
#' 
#' # login to GitHub Container Registry (when GITHUB_TOKEN env var is set)
#' oras_login()
#' 
#' @export
oras_login <- function(registry = "ghcr.io", 
                       username = Sys.getenv("GITHUB_TOKEN"), 
                       password = Sys.getenv("GITHUB_TOKEN"),  
                       flags="", 
                       verbose = TRUE) {
  
  if(nchar(username) > 0) {
    flags <- paste("-u", username, flags)
  }
  if(nchar(password) > 0) {
    flags <- paste("-p", password, flags)
  }
  cmd <- paste("login", flags, registry)
  cmd <- gsub("\\s+", " ", cmd)
  oras(cmd, verbose = verbose)
}

#' Log out from a remote registry
#'
#' @param registry Address of the remote
#' @inheritParams oras_login
#' @inherit oras return
#' @examplesIf FALSE
#' oras_logout()
#' 
#' @export
oras_logout <- function(registry, verbose = TRUE) {
  cmd <- paste("logout", registry)
  oras(cmd, verbose = verbose)
  
}

#' Tag a manifest in the remote registry
#' 
#' @inheritParams oras_push
#' @param new_tag additional tag to add 
#' @inherit oras return
#' 
oras_tag <- function(name, new_tag, flags, verbose = TRUE) {
  
  cmd <- paste("tag", flags, name, new_tag)
  cmd <- gsub("\\s+", " ", cmd)
  oras(cmd, verbose = verbose)
}

#' display the current version of the oras client
#' @export
#' @inherit oras return
oras_version <- function() {
  oras("version")
}

## Consider:

# oras_discover
# oras_manifest
# oras_help
# oras_attach
# oras_blob_push
# oras_blob_pull

