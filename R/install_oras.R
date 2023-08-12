

#' install the oras client
#' 
#' @param os operating system
#' @param arch architecture
#' @param path destination where binary is installed.
#' @param version which version should be installed
#' @param force install even if binary is already found.
#'  Can be used to force upgrade.
#' @return path to the minio binary (invisibly)
#' @details This function is just a convenience wrapper for prebuilt `oras`
#' binaries. Supports Windows, Mac, and Linux on both Intel/AMD (amd64) and ARM
#' architectures. 
#' For details, see official oras docs for your operating system,
#' e.g. <https://oras.land/docs/installation>. 
#' 
#' NOTE: If you want to install to other than the default location, OR if you
#' already have a oras client installed somewhere and want to use that, 
#' simply set the option "oras.bin.dir", to the appropriate location of the 
#' directory containing your "oras" binary, e.g.
#'  `options("oras.bin.dir" = "/usr/local/bin)`.  Note that this package
#'  will not automatically use MINIO available on $PATH (to promote security
#'  and portability in design).
#'  
#' @examplesIf interactive()
#' install_oras()
#' 
#' @export
install_oras <- function(os = system_os(), 
                         arch = system_arch(),
                         version = "1.0.0",
                         path = bin_path(),
                         force = FALSE ) {
  
  os <- switch(os, 
               "mac" = "darwin",
               os)
  arch <- switch(arch, 
                 "x86_64" = "amd64",
                 "aarch64" = "arm64",
                 arch)
  bin <- switch(os,
                "windows" = "oras.exe",
                "oras")
  type <- glue::glue("{os}_{arch}")
  
  binary <- fs::path(path, bin)
  if (file.exists(binary) && !force) {
    return(invisible(binary)) # Already installed
  }
  if (!file.exists(path)) {
    fs::dir_create(path)
  }
  
  
  
  url <- glue::glue("https://github.com/oras-project/oras/releases/download/",
             "v{version}/oras_{version}_{type}.tar.gz")
  tarball <- file.path(path, basename(url))
  utils::download.file(url, dest = tarball, mode = "wb", quiet = TRUE)
  archive::archive_extract(tarball, path)
  fs::file_delete(tarball)
  fs::file_chmod(binary, "+x")
  invisible(binary)
}

bin_path <- function() {
  getOption("oras.bin.dir", 
            tools::R_user_dir("oras", "data")
  )
}

system_os <- function () {
  tolower(Sys.info()[["sysname"]])
}

system_arch <- function () {
  R.version$arch
}

