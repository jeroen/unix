#' Lookup UID/GRP info
#' 
#' Lookup user or group info via UID/GID or user/group name
#' 
#' @export
#' @rdname userinfo
#' @param uid user ID (integer) or name (string)
#' @useDynLib unix R_user_info
#' @examples # Get info about root
#' user_info(0)
#' group_info(0)
user_info <- function(uid = me()){
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
group_info <- function(gid = me()){
  if(is.numeric(gid))
    gid <- as.integer(gid)  
  stopifnot(length(gid) > 0, is.integer(gid) || is.character(gid))
  out <- .Call(R_group_info, gid)
  structure(out, names = c("name", "passwd", "gid", "members"))
}

#' @export
#' @rdname userinfo
me <- function(){
  Sys.info()[["effective_user"]]
}
