#define NOCCARGC  /* no arg count passing */
#include stdio.h
#include clib.def
extern Ustatus[];
/*
** Test for error status on fd.
*/
ferror(fd) int fd; {
  return (Ustatus[fd] & ERRBIT);
  }
