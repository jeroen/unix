#' User / Group Info
#' 
#' Lookup a user or group info via user uid/name or group gid/name.
#' 
#' @export
#' @rdname userinfo
#' @name userinfo
#' @param uid user ID (integer) or name (string)
#' @useDynLib unix R_user_info
#' @references [GETPWNAM(3)](https://man7.org/linux/man-pages/man3/getpwnam.3.html)
#' [GETGRNAM(3)](https://man7.org/linux/man-pages/man3/getgrnam.3.html)
#' @examples # Get info current user
#' user_info()
#' group_info()
user_info <- function(uid = getuid()){
  if(is.numeric(uid))
    uid <- as.integer(uid)
  stopifnot(length(uid) > 0, is.numeric(uid) || is.character(uid))
  out <- .Call(R_user_info, uid)
  structure(out, names = c("name", "passwd", "uid", "gid", "gecos", "dir", "shell"))
}

#' @export
#' @rdname userinfo
#' @param gid group ID (integer) or name (string)
#' @useDynLib unix R_group_info
group_info <- function(gid = getgid()){
  if(is.numeric(gid))
    gid <- as.integer(gid)  
  stopifnot(length(gid) > 0, is.integer(gid) || is.character(gid))
  out <- .Call(R_group_info, gid)
  structure(out, names = c("name", "passwd", "gid", "members"))
}
