#define R_NO_REMAP
#define STRICT_R_HEADERS

#include <Rinternals.h>
#include <sys/resource.h>

extern void bail_if(int err, const char * what);

SEXP R_rlimit(int resource, SEXP softlim, SEXP hardlim){
  
  //get current limit
  struct rlimit lim;
  bail_if(getrlimit(resource, &lim) < 0, "getrlimit() for current limits");
  
  //update
  if(Rf_length(softlim) || Rf_length(hardlim)){
    if(Rf_length(softlim)){
      lim.rlim_cur = R_finite(Rf_asReal(softlim)) ? (rlim_t) Rf_asReal(softlim) : RLIM_INFINITY;
      
      //If max is too small, we need to try and raise it to at least cur 
      if(lim.rlim_cur > lim.rlim_max)
        lim.rlim_max = lim.rlim_cur;
    }
    if(Rf_length(hardlim))
      lim.rlim_max = R_finite(Rf_asReal(hardlim)) ? (rlim_t) Rf_asReal(hardlim) : RLIM_INFINITY;
    bail_if(setrlimit(resource, &lim) < 0, "setrlimit()");
    bail_if(getrlimit(resource, &lim) < 0, "getrlimit() for new limits");
  }

  //return values
  SEXP out = Rf_allocVector(REALSXP, 2);
  REAL(out)[0] = lim.rlim_cur == RLIM_INFINITY ? R_PosInf : lim.rlim_cur;
  REAL(out)[1] = lim.rlim_max == RLIM_INFINITY ? R_PosInf : lim.rlim_max;
  return out;
}

SEXP R_rlimit_as(SEXP a, SEXP b) {return R_rlimit(RLIMIT_AS, a, b);}
SEXP R_rlimit_core(SEXP a, SEXP b) {return R_rlimit(RLIMIT_CORE, a, b);}
SEXP R_rlimit_cpu(SEXP a, SEXP b) {return R_rlimit(RLIMIT_CPU, a, b);}
SEXP R_rlimit_data(SEXP a, SEXP b) {return R_rlimit(RLIMIT_DATA, a, b);}
SEXP R_rlimit_fsize(SEXP a, SEXP b) {return R_rlimit(RLIMIT_FSIZE, a, b);}
SEXP R_rlimit_nofile(SEXP a, SEXP b) {return R_rlimit(RLIMIT_NOFILE, a, b);}
SEXP R_rlimit_stack(SEXP a, SEXP b) {return R_rlimit(RLIMIT_STACK, a, b);}

/* these are not available on Solaris 10 */

SEXP make_navec(){
  SEXP out = Rf_allocVector(REALSXP, 2);
  REAL(out)[0] = NA_REAL;
  REAL(out)[1] = NA_REAL;
  return(out);
}

SEXP R_rlimit_nproc(SEXP a, SEXP b) {
#ifdef RLIMIT_NPROC
  return R_rlimit(RLIMIT_NPROC, a, b);
#else
  Rf_warning("RLIMIT_NPROC not available on this system");
  return make_navec();
#endif
}

SEXP R_rlimit_memlock(SEXP a, SEXP b) {
#ifdef RLIMIT_MEMLOCK
  return R_rlimit(RLIMIT_MEMLOCK, a, b);
#else
  Rf_warning("RLIMIT_MEMLOCK not available on this system");
  return make_navec();
#endif
}
