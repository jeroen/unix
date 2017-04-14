#define R_NO_REMAP
#define STRICT_R_HEADERS

#include <Rinternals.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>

/* check for system errors */
void bail_if(int err, const char * what){
  if(err)
    Rf_errorcall(R_NilValue, "System failure for: %s (%s)", what, strerror(errno));
}

void warn_if(int err, const char * what){
  if(err)
    Rf_warningcall(R_NilValue, "System failure for: %s (%s)", what, strerror(errno));
}

SEXP R_chroot(SEXP path){
  bail_if(chroot(CHAR(STRING_ELT(path, 0))), "chroot()");
  return path;
}
