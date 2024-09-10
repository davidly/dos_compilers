#include stdio.h
#include clib.def
extern int Udevice[];
/*
** Determine if fd is the console.
*/
iscons(fd) int fd; {
  return (Udevice[fd] == CONSOL);
  }
