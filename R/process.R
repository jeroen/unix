#' Process Info
#' 
#' Get or set attributes of the current process. 
#' 
#' Acronyms stand for:
#' 
#'  - `pid` Process ID
#'  - `ppid` Parent-Process ID
#'  - `pgid` Process-Group ID
#'  - `uid` User ID
#'  - `euid` Effective User ID
#'  - `gid` Group ID
#'  - `egid` Effective Group ID
#'  - `prio` Priority level
#' 
#' An unprivileged (non-root) process cannot change it's `uid` and only lower
#' process priority (higher value).
#' 
#' @export
#' @rdname process
#' @useDynLib unix R_getuid
#' @references [GETUID(2)](https://man7.org/linux/man-pages/man2/getuid.2.html)
#' [GETPID(2)](https://man7.org/linux/man-pages/man2/getpid.2.html)
#' [GETPGID(2)](https://man7.org/linux/man-pages/man2/getpgid.2.html)
#' [GETPRIORITY(2)](https://man7.org/linux/man-pages/man2/getpriority.2.html)
#' @examples # Current User:
#' getuid()
getuid <- function(){
  .Call(R_getuid)
} 

#' @export
#' @rdname process
#' @useDynLib unix R_getgid
#' @examples # Current UserGroup:
#' getgid()
getgid <- function(){
  .Call(R_getgid)
} 

#' @export
#' @rdname process
#' @useDynLib unix R_geteuid
#' @examples # Current UserGroup:
#' geteuid()
geteuid <- function(){
  .Call(R_geteuid)
} 

#' @export
#' @rdname process
#' @useDynLib unix R_getegid
#' @examples # Current UserGroup:
#' getegid()
getegid <- function(){
  .Call(R_getegid)
}

#' @export
#' @rdname process
#' @useDynLib unix R_getpid
#' @examples # Process ID
#' getpid()
getpid <- function(){
  .Call(R_getpid)
} 

#' @export
#' @rdname process
#' @useDynLib unix R_getppid
#' @examples # parent PID:
#' getppid()
getppid <- function(){
  .Call(R_getppid)
} 

#' @export
#' @rdname process
#' @useDynLib unix R_getpgid
#' @examples # Process group id:
#' getpgid()
#' 
#' # Detach process group
#' setpgid(0)
#' getpgid()
getpgid <- function(){
  .Call(R_getpgid)
} 

#' @export
#' @rdname process
#' @useDynLib unix R_getpriority
#' @examples # Process priority:
#' getpriority()
getpriority <- function(){
  .Call(R_getpriority)
} 

#' @export
#' @rdname process
#' @useDynLib unix R_setuid
#' @param uid User ID from `/etc/passwd`.
setuid <- function(uid){
  stopifnot(is.numeric(uid))
  .Call(R_setuid, as.integer(uid))
}

#' @export
#' @rdname process
#' @useDynLib unix R_seteuid
seteuid <- function(uid){
  .Call(R_seteuid, uid)
}

#' @export
#' @rdname process
#' @useDynLib unix R_setgid
#' @param gid Group ID from `/etc/group`.
setgid <- function(gid){
  stopifnot(is.numeric(gid))
  .Call(R_setgid, as.integer(gid))
}

#' @export
#' @rdname process
#' @useDynLib unix R_setegid
setegid <- function(gid){
  .Call(R_setegid, gid)
}

#' @export
#' @rdname process
#' @useDynLib unix R_setpgid
#' @param pgid Process Group ID. Default `0` sets pgid to the current pid.
setpgid <- function(pgid = 0){
  .Call(R_setpgid, pgid)
}

#' @export
#' @rdname process
#' @useDynLib unix R_setpriority
#' @param prio Priority level
#' @examples # Decrease priority
#' setpriority(getpriority() + 1)
setpriority <- function(prio){
  stopifnot(is.numeric(prio))
  .Call(R_setpriority, as.integer(prio))
}

#' @export
#' @rdname process
#' @importFrom tools SIGHUP SIGINT SIGQUIT SIGKILL SIGTERM SIGSTOP SIGCHLD SIGUSR1 SIGUSR2
#' @useDynLib unix R_kill
#' @param pid process ID (integer)
#' @param signal a signal number (integer), defaults to [tools::SIGTERM].
kill <- function(pid, signal = SIGTERM){
  stopifnot(is.numeric(pid), is.numeric(signal))
  .Call(R_kill, as.integer(pid), as.integer(signal))
}

