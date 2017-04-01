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
#'  - `gid` Group ID
#'  - `prio` Priority level
#' 
#' An unprivileged (non-root) process cannot change it's `uid` and only lower
#' process priority (higher value).
#' 
#' @export
#' @rdname process
#' @useDynLib unix R_getuid
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
#' getprio()
getprio <- function(){
  .Call(R_getpriority)
} 

#' @export
#' @rdname process
#' @useDynLib unix R_setuid
#' @param uid User ID from `/etc/passwd`.
setuid <- function(uid){
  .Call(R_setuid, uid)
}

#' @export
#' @rdname process
#' @useDynLib unix R_setgid
#' @param gid Group ID from `/etc/group`.
setgid <- function(gid){
  .Call(R_setgid, gid)
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
#' setprio(getprio() + 1)
setprio <- function(prio){
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

