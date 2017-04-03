#' Safe Evaluation
#'
#' Version of [eval()] which evaluates expression in a temporary fork so that it has no side
#' effects on the main R session. For [eval_safe()] the expression is wrapped in additional R 
#' code to set [rlimits][rlimit], catch errors, close graphics devices, etc.
#'
#' @export
#' @rdname eval_fork
#' @param expr expression to evaluate
#' @param std_out if and where to direct child process `STDOUT`. Must be one of
#' `TRUE`, `FALSE`, filename, connection object or callback function. See also [sys::exec_wait()].
#' @param std_err if and where to direct child process `STDERR`. Must be one of
#' `TRUE`, `FALSE`, filename, connection object or callback function. See also [sys::exec_wait()].
#' @param tmp the value of [tempdir()] inside the forked process
#' @param timeout maximum time in seconds to allow for call to return
#' @examples # works like regular eval:
#' eval_safe(rnorm(5))
#'
#' # Exceptions get propagated
#' test <- function() { doesnotexit() }
#' tryCatch(eval_safe(test()), error = function(e){
#'   cat("oh no!", e$message, "\n")
#' })
#'
#' # Honor interrupt and timeout, even inside C evaluations
#' try(eval_safe(svd(matrix(rnorm(1e8), 1e4)), timeout = 2))
#'
#' # Capture output
#' outcon <- rawConnection(raw(0), "r+")
#' eval_safe(print(sessionInfo()), std_out = outcon)
#' rawToChar(rawConnectionValue(outcon))
eval_fork <- function(expr, tmp = tempfile("fork"), timeout = 60,
                      std_out = stdout(), std_err = stderr()){
  # Convert TRUE or filepath into connection objects
  std_out <- if(isTRUE(std_out) || identical(std_out, "")){
    stdout()
  } else if(is.character(std_out)){
    file(normalizePath(std_out, mustWork = FALSE))
  } else std_out

  std_err <- if(isTRUE(std_err) || identical(std_err, "")){
    stderr()
  } else if(is.character(std_err)){
    std_err <- file(normalizePath(std_err, mustWork = FALSE))
  } else std_err

  # Define the callbacks
  outfun <- if(inherits(std_out, "connection")){
    if(!isOpen(std_out)){
      open(std_out, "wb")
      on.exit(close(std_out), add = TRUE)
    }
    if(identical(summary(std_out)$text, "text")){
      function(x){
        cat(rawToChar(x), file = std_out)
        flush(std_out)
      }
    } else {
      function(x){
        writeBin(x, con = std_out)
        flush(std_out)
      }
    }
  }
  errfun <- if(inherits(std_err, "connection")){
    if(!isOpen(std_err)){
      open(std_err, "wb")
      on.exit(close(std_err), add = TRUE)
    }
    if(identical(summary(std_err)$text, "text")){
      function(x){
        cat(rawToChar(x), file = std_err)
        flush(std_err)
      }
    } else {
      function(x){
        writeBin(x, con = std_err)
        flush(std_err)
      }
    }
  }
  if(!file.exists(tmp))
    dir.create(tmp)
  clenv <- force(parent.frame())
  clexpr <- substitute(expr)
  eval_fork_internal(clexpr, clenv, tmp, timeout, outfun, errfun)
}

#' @rdname eval_fork
#' @export
#' @importFrom grDevices pdf dev.cur dev.off
#' @param device graphics device to use in the fork, see [dev.new()]
#' @param rlimits named list of [rlimit] values, for example: `list(cpu = 60, fsize = 1e6)`.
#' @param uid evaluate as given user (uid or name). See [setuid()], only for root.
#' @param gid evaluate as given group (gid or name). See [setgid()] only for root.
eval_safe <- function(expr, tmp = tempfile("fork"), timeout = 60,
        std_out = stdout(), std_err = stderr(), device = pdf, rlimits = list(), uid = NULL,
        gid = NULL){
  orig_expr <- substitute(expr)
  out <- eval_fork(expr = tryCatch({
    if(length(uid))
      setuid(uid = uid)
    if(length(gid))
      setgid(gid = gid)
    if(length(device))
      options(device = device)
    if(length(rlimits))
      do.call(set_hard_limits, as.list(rlimits))
    while(dev.cur() > 1) dev.off()
    options(menu.graphics = FALSE)
    withVisible(eval(orig_expr, parent.frame()))    
  }, error = function(e){
    old_class <- attr(e, "class")
    structure(e, class = c(old_class, "eval_fork_error"))
  }, finally = substitute(while(dev.cur() > 1) dev.off())), 
    tmp = tmp, timeout = timeout, std_out = std_out, std_err = std_err)
  if(inherits(out, "eval_fork_error"))
    base::stop(out)
  if(out$visible)
    out$value
  else
    invisible(out$value)
}

#' @useDynLib unix R_eval_fork
eval_fork_internal <- function(expr, envir, tmp, timeout, outfun, errfun){
  timeout <- as.numeric(timeout)
  tmp <- normalizePath(tmp)
  .Call(R_eval_fork, expr, envir, tmp, timeout, outfun, errfun)
}

set_hard_limits <- function(as = NULL, core = NULL, cpu = NULL, data = NULL, fsize = NULL,
                            memlock = NULL, nofile = NULL, nproc = NULL, stack = NULL){
  rlimit_as(as, as)
  rlimit_core(core, core)
  rlimit_cpu(cpu, cpu)
  rlimit_data(data, data)
  rlimit_fsize(fsize, fsize)
  rlimit_memlock(memlock, memlock)
  rlimit_nofile(nofile, nofile)
  rlimit_nproc(nproc, nproc)
  rlimit_stack(stack, stack)
}

#' @useDynLib unix R_freeze
freeze <- function(interrupt = TRUE){
  .Call(R_freeze, as.logical(interrupt))
}
