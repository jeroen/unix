#' Change Root Dir
#' 
#' Changes the root directory of the calling process to that specified in path.  
#' This directory will be used for pathnames beginning with `/`.
#' **Only a privileged process (i.e. sudo) may call `chroot()`**.
#' 
#' This call changes an ingredient in the pathname resolution process
#' and does nothing else.  In particular, it is not intended to be used
#' for any kind of security purpose, neither to fully sandbox a process
#' nor to restrict filesystem system calls.
#' 
#' @export
#' @param path directory of the new root
#' @useDynLib unix R_chroot
#' @references [CHROOT(2)](https://man7.org/linux/man-pages/man2/chroot.2.html)
chroot <- function(path = getwd()){
  path <- normalizePath(path, mustWork = TRUE)
  .Call(R_chroot, path)
}
