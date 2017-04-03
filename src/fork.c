#define R_INTERFACE_PTRS
#include <Rinterface.h>
#include <Rembedded.h>
#include <Rconfig.h>
#include <unistd.h>
#include <signal.h>
#include <string.h>
#include <fcntl.h>
#include <poll.h>
#include <time.h>
#include <errno.h>
#include <sys/time.h>
#include <sys/wait.h>

static const int R_DefaultSerializeVersion = 2;
static int out = STDOUT_FILENO;
static int err = STDERR_FILENO;

#define r 0
#define w 1

#define waitms 200

extern Rboolean R_isForkedChild;
extern char * Sys_TempDir;

/* check for system errors */
void bail_if(int err, const char * what){
  if(err)
    Rf_errorcall(R_NilValue, "System failure for: %s (%s)", what, strerror(errno));
}

void warn_if(int err, const char * what){
  if(err)
    Rf_warningcall(R_NilValue, "System failure for: %s (%s)", what, strerror(errno));
}

void safe_close(int fd){
  int fdnull = open("/dev/null", O_WRONLY);
  warn_if(dup2(fdnull, fd), "dup2 in safe_close()");
  close(fdnull);
}

void set_pipe(int input, int output[2]){
  bail_if(dup2(output[w], input) < 0, "dup2() stdout/stderr");
  close(output[r]);
  close(output[w]);
}

void pipe_set_read(int pipe[2]){
  close(pipe[w]);
  bail_if(fcntl(pipe[r], F_SETFL, O_NONBLOCK) < 0, "fcntl() in pipe_set_read");
}

/* Check for interrupt without long jumping */
void check_interrupt_fn(void *dummy) {
  R_CheckUserInterrupt();
}

int pending_interrupt() {
  return !(R_ToplevelExec(check_interrupt_fn, NULL));
}

int wait_for_action2(int fd1, int fd2){
  short events = POLLIN | POLLERR | POLLHUP;
  struct pollfd ufds[2] = {
    {fd1, events, events},
    {fd2, events, events}
  };
  return poll(ufds, 2, waitms);
}

static void R_callback(SEXP fun, const char * buf, ssize_t len){
  if(!isFunction(fun)) return;
  int ok;
  SEXP str = PROTECT(allocVector(RAWSXP, len));
  memcpy(RAW(str), buf, len);
  SEXP call = PROTECT(LCONS(fun, LCONS(str, R_NilValue)));
  R_tryEval(call, R_GlobalEnv, &ok);
  UNPROTECT(2);
}

void print_output(int pipe_out[2], SEXP fun){
  static ssize_t len;
  static char buffer[65336];
  while ((len = read(pipe_out[r], buffer, sizeof(buffer))) > 0)
    R_callback(fun, buffer, len);
}

//output callbacks
void write_out_ex(const char * buf, int size, int otype){
  warn_if(write(otype ? err : out, buf, size), "problem writing back to std_out / std_err");
}

static int wait_for_action1(int fd, int ms){
  short events = POLLIN | POLLERR | POLLHUP;
  struct pollfd ufds = {fd, events, 0};
  if(poll(&ufds, 1, ms) > 0)
    return ufds.revents;
  return 0;
}

/*
static int is_alive(pid_t pid){
  return !waitpid(pid, NULL, WNOHANG);
}
*/

/* Callback functions to serialize/unserialize via the pipe */
static void OutBytesCB(R_outpstream_t stream, void * raw, int size){
  int * results = stream->data;
  char * buf = raw;
  ssize_t remaining = size;
  while(remaining > 0){
    ssize_t written = write(results[w], buf, remaining);
    bail_if(written < 0, "write to pipe");
    remaining -= written;
    buf += written;
  }
}

static void InBytesCB(R_inpstream_t stream, void *buf, int length){
  R_CheckUserInterrupt();
  int * results = stream->data;
  bail_if(read(results[r], buf, length) < 0, "read from pipe");
}

/* Not sure if these are ever needed */
static void OutCharCB(R_outpstream_t stream, int c){
  OutBytesCB(stream, &c, sizeof(c));
}

static int InCharCB(R_inpstream_t stream){
  int val;
  InBytesCB(stream, &val, sizeof(val));
  return val;
}

static void serialize_to_pipe(SEXP object, int results[2]){
  //serialize output
  struct R_outpstream_st stream;
  stream.data = results;
  stream.type = R_pstream_xdr_format;
  stream.version = R_DefaultSerializeVersion;
  stream.OutChar = OutCharCB;
  stream.OutBytes = OutBytesCB;
  stream.OutPersistHookFunc = NULL;
  stream.OutPersistHookData = R_NilValue;

  //TODO: this can raise an error so that the process never dies!
  R_Serialize(object, &stream);
}

void prepare_fork(const char * tmpdir){
#ifndef R_BUILD_CLEAN
  ptr_R_WriteConsole = NULL;
  ptr_R_WriteConsoleEx = write_out_ex;
  R_isForkedChild = 1;
  R_Interactive = 0;
  R_TempDir = strdup(tmpdir);
#ifndef HAVE_VISIBILITY_ATTRIBUTE
  Sys_TempDir = R_TempDir;
#endif
#endif
}

static SEXP unserialize_from_pipe(int results[2]){
  //unserialize stream
  struct R_inpstream_st stream;
  stream.data = results;
  stream.type = R_pstream_xdr_format;
  stream.InPersistHookFunc = NULL;
  stream.InPersistHookData = R_NilValue;
  stream.InBytes = InBytesCB;
  stream.InChar = InCharCB;

  //TODO: this can raise an error!
  return R_Unserialize(&stream);
}

SEXP R_eval_fork(SEXP call, SEXP env, SEXP subtmp, SEXP timeout, SEXP outfun, SEXP errfun){
  int results[2];
  int pipe_out[2];
  int pipe_err[2];
  bail_if(pipe(results), "create results pipe");
  bail_if(pipe(pipe_out) || pipe(pipe_err), "create output pipes");

  //fork the main process
  int fail = -1;
  pid_t pid = fork();
  bail_if(pid < 0, "fork()");

  if(pid == 0){
    //prevents signals from being propagated to fork
    setpgid(0, 0);

    //Linux only: suicide when parent dies
#ifdef PR_SET_PDEATHSIG
    prctl(PR_SET_PDEATHSIG, SIGKILL);
#endif

    //this is the hacky stuff
    out = pipe_out[w];
    err = pipe_err[w];
    prepare_fork(CHAR(STRING_ELT(subtmp, 0)));

    //close read pipe
    close(results[r]);

    //This breaks parallel! See issue #11
    safe_close(STDIN_FILENO);

    //execute
    fail = 99; //not using this yet
    SEXP object = R_tryEval(call, env, &fail);

    //try to send the 'success byte' and then output
    if(write(results[w], &fail, sizeof(fail)) > 0){
      const char * errbuf = R_curErrorBuf();
      serialize_to_pipe(fail || object == NULL ? mkString(errbuf ? errbuf : "unknown error in child") : object, results);
    }

    //suicide
    close(results[w]);
    close(pipe_out[w]);
    close(pipe_err[w]);
    raise(SIGKILL);
  }

  //start timer
  struct timeval start, end;
  gettimeofday(&start, NULL);

  //start listening to child
  close(results[w]);
  pipe_set_read(pipe_out);
  pipe_set_read(pipe_err);
  int status = 0;
  int killcount = 0;
  double elapsed = 0;
  int is_timeout = 0;
  double totaltime = REAL(timeout)[0];
  while(status == 0){ //mabye test for: is_alive(pid) ?
    //wait for pipe to hear from child
    if(is_timeout || pending_interrupt()){
      //looks like rstudio always does SIGKILL, regardless
      warn_if(kill(pid, killcount == 0 ? SIGINT : killcount == 1 ? SIGTERM : SIGKILL), "kill child");
      status = wait_for_action1(results[r], 500);
      killcount++;
    } else {
      wait_for_action2(pipe_out[r], pipe_err[r]);
      status = wait_for_action1(results[r], 0);

      //empty pipes
      print_output(pipe_out, outfun);
      print_output(pipe_err, errfun);
      gettimeofday(&end, NULL);
      elapsed = (end.tv_sec - start.tv_sec) + (end.tv_usec - start.tv_usec) / 1e6;
      is_timeout = (totaltime > 0) && (elapsed > totaltime);
    }
  }
  warn_if(close(pipe_out[r]), "close stdout");
  warn_if(close(pipe_err[r]), "close stderr");
  bail_if(status < 0, "poll() on failure pipe");

  //read the 'success byte'
  SEXP res = R_NilValue;
  if(status > 0){
    int child_is_alive = read(results[r], &fail, sizeof(fail));
    bail_if(child_is_alive < 0, "read pipe");
    if(child_is_alive > 0){
      res = unserialize_from_pipe(results);
    }
  }

  //cleanup
  close(results[r]);
  kill(-pid, SIGKILL); //kills entire process group
  waitpid(pid, NULL, 0); //wait for zombie(s) to die

  //actual R error
  if(status == 0 || fail){
    if(killcount && is_timeout){
      Rf_errorcall(call, "timeout reached (%f sec)", totaltime);
    } else if(killcount) {
      Rf_errorcall(call, "process interrupted by parent");
    } else if(isString(res) && Rf_length(res) && Rf_length(STRING_ELT(res, 0)) > 8){
      Rf_errorcall(R_NilValue, CHAR(STRING_ELT(res, 0)));
    }
    Rf_errorcall(call, "child process has died");
  }

  //add timeout attribute
  return res;
}
