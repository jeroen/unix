#' Resource Limits
#' 
#' Get and set process resource limits. Each function returns the current limits, and
#' can optionally update the limit by passing argument values.
#' 
#' Each resource has an associated soft and  hard limit. The soft limit is the value
#' that the kernel enforces for the corresponding resource.  The hard limit acts as a
#' ceiling for the soft limit: an unprivileged process may set only its soft limit to 
#' a value in the range from 0 up to the hard limit, and (irreversibly) lower its hard 
#' limit.
#' 
#' Definitons from the [Linux manual page](http://man7.org/linux/man-pages/man2/setrlimit.2.html)
#' are as follows:
#' 
#'  - `RLIMIT_AS` : the maximum size of the process's virtual memory (address space) in bytes.
#'  - `RLIMIT_CORE` : the maximum size of a core file that the process may dump.
#'  - `RLIMIT_CPU` : a limit in seconds on the amount of CPU time (**not** elapsed time) that
#'  the process may consume. When the process reaches the soft limit, it is sent a `SIGXCPU` signal.
#'  - `RLIMIT_DATA` : the maximum size of the process's data segment (initialized data, uninitialized
#'  data, and heap).
#'  - `RLIMIT_FSIZE` : the maximum size of files that the process may create. Attempts to extend a 
#'  file beyond this limit result in delivery of a SIGXFSZ signal.
#'  - `RLIMIT_MEMLOCK` : the maximum number of bytes of memory that may be locked into RAM.
#'  - `RLIMIT_NOFILE` : a value one greater than the maximum file descriptor number that can be opened
#'  by this process.
#'  - `RLIMIT_NPROC` : the maximum number of processes that can be created for the real user ID of the
#'  calling process.  Upon encountering this limit, fork fails with the error EAGAIN. Not enforced for 
#'  root user.
#'  - `RLIMIT_STACK` : the maximum size of the process stack, in bytes.
#' 
#' Note that the support for enforcing limits very widely by system. In particular
#' `RLIMIT_AS` has a different meaning depending on how memory allocation is managed
#' by the operating system (and doesn't work at all on MacOS).
#' 
#' 
#' @rdname rlimit
#' @name rlimit
#' @useDynLib unix R_rlimit_as
#' @export
#' @param cur set the current (soft) limit for this resource. See details.
#' @param max set the max (hard) limit for this resource. See details.
#' @references [GETRLIMIT(2)](http://man7.org/linux/man-pages/man2/setrlimit.2.html)
#' @examples # Get current limit
#' rlimit_as()
#' 
#' # Set a soft limit
#' rlimit_as(1e9)
#'
#' # Set a hard limit
#' rlimit_as(max = 1e10)
rlimit_as <- function(cur = NULL, max = NULL){
  if(length(cur)) stopifnot(is.numeric(cur))
  if(length(max)) stopifnot(is.numeric(max))
  out <- .Call(R_rlimit_as, as.numeric(cur), as.numeric(max))
  structure(as.list(out), names = c("cur", "max"))
}

#' @rdname rlimit
#' @useDynLib unix R_rlimit_core
#' @export
rlimit_core <- function(cur = NULL, max = NULL){
  if(length(cur)) stopifnot(is.numeric(cur))
  if(length(max)) stopifnot(is.numeric(max))
  out <- .Call(R_rlimit_core, as.numeric(cur), as.numeric(max))
  structure(as.list(out), names = c("cur", "max"))
}

#' @rdname rlimit
#' @useDynLib unix R_rlimit_cpu
#' @export
rlimit_cpu <- function(cur = NULL, max = NULL){
  if(length(cur)) stopifnot(is.numeric(cur))
  if(length(max)) stopifnot(is.numeric(max))
  out <- .Call(R_rlimit_cpu, as.numeric(cur), as.numeric(max))
  structure(as.list(out), names = c("cur", "max"))
}

#' @rdname rlimit
#' @useDynLib unix R_rlimit_data
#' @export
rlimit_data <- function(cur = NULL, max = NULL){
  if(length(cur)) stopifnot(is.numeric(cur))
  if(length(max)) stopifnot(is.numeric(max))
  out <- .Call(R_rlimit_data, as.numeric(cur), as.numeric(max))
  structure(as.list(out), names = c("cur", "max"))
}

#' @rdname rlimit
#' @useDynLib unix R_rlimit_fsize
#' @export
rlimit_fsize <- function(cur = NULL, max = NULL){
  if(length(cur)) stopifnot(is.numeric(cur))
  if(length(max)) stopifnot(is.numeric(max))
  out <- .Call(R_rlimit_fsize, as.numeric(cur), as.numeric(max))
  structure(as.list(out), names = c("cur", "max"))
}

#' @rdname rlimit
#' @useDynLib unix R_rlimit_memlock
#' @export
rlimit_memlock <- function(cur = NULL, max = NULL){
  if(length(cur)) stopifnot(is.numeric(cur))
  if(length(max)) stopifnot(is.numeric(max))
  out <- .Call(R_rlimit_memlock, as.numeric(cur), as.numeric(max))
  structure(as.list(out), names = c("cur", "max"))
}

#' @rdname rlimit
#' @useDynLib unix R_rlimit_nofile
#' @export
rlimit_nofile <- function(cur = NULL, max = NULL){
  if(length(cur)) stopifnot(is.numeric(cur))
  if(length(max)) stopifnot(is.numeric(max))
  out <- .Call(R_rlimit_nofile, as.numeric(cur), as.numeric(max))
  structure(as.list(out), names = c("cur", "max"))
}

#' @rdname rlimit
#' @useDynLib unix R_rlimit_nproc
#' @export
rlimit_nproc <- function(cur = NULL, max = NULL){
  if(length(cur)) stopifnot(is.numeric(cur))
  if(length(max)) stopifnot(is.numeric(max))
  out <- .Call(R_rlimit_nproc, as.numeric(cur), as.numeric(max))
  structure(as.list(out), names = c("cur", "max"))
}

#' @rdname rlimit
#' @useDynLib unix R_rlimit_stack
#' @export
rlimit_stack <- function(cur = NULL, max = NULL){
  if(length(cur)) stopifnot(is.numeric(cur))
  if(length(max)) stopifnot(is.numeric(max))
  out <- .Call(R_rlimit_stack, as.numeric(cur), as.numeric(max))
  structure(as.list(out), names = c("cur", "max"))
}