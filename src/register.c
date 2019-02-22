#include <R.h>
#include <Rinternals.h>
#include <stdlib.h> // for NULL
#include <R_ext/Rdynload.h>
#include <R_ext/Visibility.h>

/* .Call calls */
extern SEXP R_aa_change_profile(SEXP);
extern SEXP R_aa_getcon();
extern SEXP R_aa_is_enabled();
extern SEXP R_chroot(SEXP);
extern SEXP R_eval_fork(SEXP, SEXP, SEXP, SEXP, SEXP, SEXP);
extern SEXP R_freeze(SEXP);
extern SEXP R_getegid();
extern SEXP R_geteuid();
extern SEXP R_getgid();
extern SEXP R_getpgid();
extern SEXP R_getpid();
extern SEXP R_getppid();
extern SEXP R_getpriority();
extern SEXP R_getuid();
extern SEXP R_group_info(SEXP);
extern SEXP R_have_apparmor();
extern SEXP R_kill(SEXP, SEXP);
extern SEXP R_rlimit_as(SEXP, SEXP);
extern SEXP R_rlimit_core(SEXP, SEXP);
extern SEXP R_rlimit_cpu(SEXP, SEXP);
extern SEXP R_rlimit_data(SEXP, SEXP);
extern SEXP R_rlimit_fsize(SEXP, SEXP);
extern SEXP R_rlimit_memlock(SEXP, SEXP);
extern SEXP R_rlimit_nofile(SEXP, SEXP);
extern SEXP R_rlimit_nproc(SEXP, SEXP);
extern SEXP R_rlimit_stack(SEXP, SEXP);
extern SEXP R_safe_build();
extern SEXP R_set_interactive(SEXP);
extern SEXP R_set_rlimits(SEXP);
extern SEXP R_set_tempdir(SEXP);
extern SEXP R_setegid(SEXP);
extern SEXP R_seteuid(SEXP);
extern SEXP R_setgid(SEXP);
extern SEXP R_setpgid(SEXP);
extern SEXP R_setpriority(SEXP);
extern SEXP R_setuid(SEXP);
extern SEXP R_user_info(SEXP);

static const R_CallMethodDef CallEntries[] = {
  {"R_aa_change_profile", (DL_FUNC) &R_aa_change_profile, 1},
  {"R_aa_getcon",         (DL_FUNC) &R_aa_getcon,         0},
  {"R_aa_is_enabled",     (DL_FUNC) &R_aa_is_enabled,     0},
  {"R_chroot",            (DL_FUNC) &R_chroot,            1},
  {"R_eval_fork",         (DL_FUNC) &R_eval_fork,         6},
  {"R_freeze",            (DL_FUNC) &R_freeze,            1},
  {"R_getegid",           (DL_FUNC) &R_getegid,           0},
  {"R_geteuid",           (DL_FUNC) &R_geteuid,           0},
  {"R_getgid",            (DL_FUNC) &R_getgid,            0},
  {"R_getpgid",           (DL_FUNC) &R_getpgid,           0},
  {"R_getpid",            (DL_FUNC) &R_getpid,            0},
  {"R_getppid",           (DL_FUNC) &R_getppid,           0},
  {"R_getpriority",       (DL_FUNC) &R_getpriority,       0},
  {"R_getuid",            (DL_FUNC) &R_getuid,            0},
  {"R_group_info",        (DL_FUNC) &R_group_info,        1},
  {"R_have_apparmor",     (DL_FUNC) &R_have_apparmor,     0},
  {"R_kill",              (DL_FUNC) &R_kill,              2},
  {"R_rlimit_as",         (DL_FUNC) &R_rlimit_as,         2},
  {"R_rlimit_core",       (DL_FUNC) &R_rlimit_core,       2},
  {"R_rlimit_cpu",        (DL_FUNC) &R_rlimit_cpu,        2},
  {"R_rlimit_data",       (DL_FUNC) &R_rlimit_data,       2},
  {"R_rlimit_fsize",      (DL_FUNC) &R_rlimit_fsize,      2},
  {"R_rlimit_memlock",    (DL_FUNC) &R_rlimit_memlock,    2},
  {"R_rlimit_nofile",     (DL_FUNC) &R_rlimit_nofile,     2},
  {"R_rlimit_nproc",      (DL_FUNC) &R_rlimit_nproc,      2},
  {"R_rlimit_stack",      (DL_FUNC) &R_rlimit_stack,      2},
  {"R_safe_build",        (DL_FUNC) &R_safe_build,        0},
  {"R_set_interactive",   (DL_FUNC) &R_set_interactive,   1},
  {"R_set_rlimits",       (DL_FUNC) &R_set_rlimits,       1},
  {"R_set_tempdir",       (DL_FUNC) &R_set_tempdir,       1},
  {"R_setegid",           (DL_FUNC) &R_setegid,           1},
  {"R_seteuid",           (DL_FUNC) &R_seteuid,           1},
  {"R_setgid",            (DL_FUNC) &R_setgid,            1},
  {"R_setpgid",           (DL_FUNC) &R_setpgid,           1},
  {"R_setpriority",       (DL_FUNC) &R_setpriority,       1},
  {"R_setuid",            (DL_FUNC) &R_setuid,            1},
  {"R_user_info",         (DL_FUNC) &R_user_info,         1},
  {NULL, NULL, 0}
};

attribute_visible void R_init_unix(DllInfo *dll) {
  R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
  R_useDynamicSymbols(dll, FALSE);
}
