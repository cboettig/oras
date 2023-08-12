#' oras
#' 
#' The oras client
#' 
#' @param command space-delimited text string of an mc command
#'  (starting after the mc ...)
#' @param ... additional arguments to [processx::run()]
#' @param path location where oras executable will be installed. By default will
#' use the OS-appropriate storage location.  
#' @param verbose print output?
#' @return Returns the list from [processx::run()], with components `status`, 
#' `stdout`, `stderr`, and `timeout`; invisibly.
#' @export 
#' @details 
#' 
#' This function forms the basis for all other available commands.
#' run `oras("-h")` for help. 
oras <- function(command, ..., path = bin_path(), verbose = TRUE) {
  
  binary <- fs::path(path, "oras")
  
  if (!file.exists(binary) && interactive()) {
    proceed <- utils::askYesNo("Install the oras client?")
    if (proceed) {
      install_oras(path = path)
    }
  }
  
  args <- strsplit(command, split = " ")[[1]]
  p <- processx::run(binary, args, ...)
  
  if (p$timeout & verbose) {
    warning(paste("request", command, "timed out"))
  }
  
  if (p$status != 0) {
    stop(paste(p$stderr))
  }
  
  if (verbose) {
    message(paste0(p$stdout))
  }
  
  invisible(p)
}

