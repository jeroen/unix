#define R_NO_REMAP
#define STRICT_R_HEADERS

#include <Rinternals.h>
#include <sys/types.h>
#include <string.h>
#include <errno.h>
#include <pwd.h>
#include <grp.h>

#define make_string(x) x ? Rf_mkString(x) : Rf_ScalarString(NA_STRING)

/* check for system errors */
void bail_if(int err, const char * what){
  if(err)
    Rf_errorcall(R_NilValue, "System failure for: %s (%s)", what, strerror(errno));
}

SEXP R_user_info(SEXP input){
  errno = 0;
  struct passwd * info = Rf_isInteger(input) ? 
    getpwuid(Rf_asInteger(input)) : 
    getpwnam(CHAR(STRING_ELT(input, 0)));
  bail_if(info == NULL, "getpwuid() / getpwnam()");
  SEXP out = PROTECT(Rf_allocVector(VECSXP, 7));
  SET_VECTOR_ELT(out, 0, make_string(info->pw_name));
  SET_VECTOR_ELT(out, 1, make_string(info->pw_passwd));
  SET_VECTOR_ELT(out, 2, Rf_ScalarInteger(info->pw_uid));
  SET_VECTOR_ELT(out, 3, Rf_ScalarInteger(info->pw_gid));
  SET_VECTOR_ELT(out, 4, make_string(info->pw_gecos));
  SET_VECTOR_ELT(out, 5, make_string(info->pw_dir));
  SET_VECTOR_ELT(out, 6, make_string(info->pw_shell));
  UNPROTECT(1);
  return out;
}

SEXP R_group_info(SEXP input){
  errno = 0;
  struct group * info = Rf_isInteger(input) ? 
    getgrgid(Rf_asInteger(input)) : 
    getgrnam(CHAR(STRING_ELT(input, 0)));
  bail_if(info == NULL, "getgrgid() / getgrnam()");
  SEXP out = PROTECT(Rf_allocVector(VECSXP, 4));
  SET_VECTOR_ELT(out, 0, make_string(info->gr_name));
  SET_VECTOR_ELT(out, 1, make_string(info->gr_passwd));
  SET_VECTOR_ELT(out, 2, Rf_ScalarInteger(info->gr_gid));
  int count = 0;
  while(info->gr_mem[count])
    count++;
  SET_VECTOR_ELT(out, 3, Rf_allocVector(STRSXP, count));
  for(int i = 0; i < count; i++)
    SET_STRING_ELT(VECTOR_ELT(out, 3), i, Rf_mkChar(info->gr_mem[i]));
  UNPROTECT(1);
  return out;
}
