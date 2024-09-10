#define NOCCARGC  /* no arg count passing */
#include stdio.h
#include clib.def
extern int Ustatus[];
/*
** Clear error status for fd.
*/
clearerr(fd) int fd; {
  if(Umode(fd)) Ustatus[fd] &= ~ERRBIT;
  }

