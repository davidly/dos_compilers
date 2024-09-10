#define NOCCARGC  /* no argument count passing */
#include clib.def
extern int Ustatus[];
/*
** Test for end-of-file status.
** Entry: fd = file descriptor
** Returns non-zero if fd is at eof, else zero.
*/
feof(fd) int fd; {
  return (Ustatus[fd] & EOFBIT);
  }

