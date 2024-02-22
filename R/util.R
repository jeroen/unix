#' Package config
#'
#' Shows which features are enabled in the package configuration.
#'
#' @export
#' @rdname config
#' @examples sys_config()
sys_config <- function(){
  list(
    safe = safe_build(),
    apparmor = have_apparmor()
  )
}

#' @rdname config
#' @export
aa_config <- function(){
  status <- aa_getcon()
  list(
    compiled = have_apparmor(),
    enabled = aa_is_enabled(),
    con = status$con,
    mode = status$mode
  )
}

#' @useDynLib unix R_freeze
freeze <- function(interrupt = TRUE){
  .Call(R_freeze, as.logical(interrupt))
}

#' @useDynLib unix R_safe_build
safe_build <- function(){
  .Call(R_safe_build)
}

#' @useDynLib unix R_have_apparmor
have_apparmor <- function(){
  .Call(R_have_apparmor)
}

#' @useDynLib unix R_aa_is_enabled
aa_is_enabled <- function(){
  .Call(R_aa_is_enabled)
}

#' @useDynLib unix R_aa_getcon
aa_getcon <- function(){
  out <- .Call(R_aa_getcon)
  if(!length(out))
    return(out)
  structure(out, names = c("con", "mode"))
}

#' @useDynLib unix R_set_tempdir
set_tempdir <- function(path){
  path <- normalizePath(path)
  if(!file.exists(path))
    dir.create(path)
  .Call(R_set_tempdir, path)
}

#' @useDynLib unix R_set_interactive
set_interactive <- function(set){
  stopifnot(is.logical(set))
  .Call(R_set_interactive, set)
}

#' @useDynLib unix R_aa_change_profile
aa_change_profile <- function(profile){
  stopifnot(is.character(profile))
  .Call(R_aa_change_profile, profile)
}

#' @useDynLib unix R_set_rlimits
set_rlimits <- function(rlimits){
  rlimits <- do.call(parse_limits, as.list(rlimits))
  .Call(R_set_rlimits, rlimits)
}
