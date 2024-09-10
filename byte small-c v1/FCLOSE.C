#define NOCCARGC  /* no argument count passing */
#include stdio.h
#include clib.def
/*
** Close fd 
** Entry: fd = File descriptor for file to be closed.
** Returns NULL for success, otherwise ERR
*/
extern int Ustatus[], Udevice[], Ufd[];
fclose(fd) int fd; {
  if(!Umode(fd)) return (ERR);
  if(!isatty(fd)) {
    if(Umsdos(0,0,Ufd[fd],CLOFIL)==ERR)
      return (ERR);
    }
  return (Ustatus[fd]=Udevice[fd]=NULL);
  }

