#define R_NO_REMAP
#define STRICT_R_HEADERS

#include <Rinternals.h>
#include <unistd.h>

void bail_if(int err, const char * what);

SEXP R_chroot(SEXP path){
  bail_if(chroot(CHAR(STRING_ELT(path, 0))), "chroot()");
  return path;
}
