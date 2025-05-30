#' Run TAF Script
#'
#' Run a TAF script and return to the original directory.
#'
#' @param script script filename.
#' @param rm whether to remove all objects from the global environment before
#'        and after the script is run.
#' @param clean whether to \code{\link{clean}} the target directory before
#'        running the script.
#' @param detach whether to detach all non-base packages before running the
#'        script, to ensure that the script is not affected by packages that may
#'        have been attached outside the script.
#' @param taf a convenience flag where \code{taf = TRUE} sets \code{rm},
#'        \code{clean}, and \code{detach} to \code{TRUE}, as is done on the TAF
#'        server. Any other value of \code{taf} is ignored.
#' @param quiet whether to suppress messages reporting progress.
#'
#' @details
#' The default value of \code{rm = FALSE} is to protect users from accidental
#' loss of work, but the TAF server always runs with \code{rm = TRUE} to make
#' sure that only files, not objects in memory, are carried over between
#' scripts.
#'
#' Likewise, the TAF server runs with \code{clean = TRUE} to make sure that the
#' script starts with a clean directory. The target directory of a TAF script
#' has the same filename prefix as the script: \verb{data.R} creates \file{data}
#' etc.
#'
#' @return
#' \code{TRUE} or \code{FALSE}, indicating whether the script ran without
#' errors.
#'
#' @note
#' Commands within a script (such as \code{setwd}) may change the working
#' directory, but \code{source.taf} guarantees that the working directory
#' reported by \code{getwd()} is the same before and after running a script.
#'
#' @seealso
#' \code{\link{source}} is the base function to run R scripts.
#'
#' \code{\link{make.taf}} runs a TAF script if needed.
#'
#' \code{\link{source.all}} runs all TAF scripts in a directory.
#'
#' \code{\link{TAF-package}} gives an overview of the package.
#'
#' @examples
#' \dontrun{
#' write("print(pi)", "script.R")
#' source("script.R")
#' source.taf("script.R")
#' file.remove("script.R")
#' }
#'
#' @importFrom tools file_path_sans_ext
#'
#' @aliases sourceTAF
#'
#' @export

source.taf <- function(script, rm=FALSE, clean=TRUE, detach=FALSE, taf=NULL,
                       quiet=FALSE)
{
  if(isTRUE(taf))
    rm <- clean <- detach <- TRUE
  if(file.exists(paste0(script, ".R")))
    script <- paste0(script, ".R")
  if(rm)
    rm(list=ls(.GlobalEnv), pos=.GlobalEnv)
  if(clean && dir.exists(file_path_sans_ext(script)))
    clean(file_path_sans_ext(script))
  if(detach)
    detach.packages(quiet=quiet)
  if(!quiet)
    msg(script, " running...")

  owd <- getwd()
  on.exit(setwd(owd))  # ensure getwd() is same before and after script
  result <- try(source(script))
  out <- class(result) != "try-error"
  if(!quiet)
    msg("  ", script, if(out) " done" else " failed")

  if(rm)
    rm(list=ls(.GlobalEnv), pos=.GlobalEnv)

  invisible(out)
}

#' @export

# Equivalent spelling

sourceTAF <- function(...)
{
  source.taf(...)
}
