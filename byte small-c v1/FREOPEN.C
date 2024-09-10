#define NOCCARGC  /* no argument count passing */
#include stdio.h
/*
** Close previously opened fd and reopen it. 
** Entry: fn   = Null-terminated CP/M file name.
**               May be prefixed by letter of drive.
**               May be just CON:, RDR:, PUN:, or LST:.
**        mode = "a"  - append
**               "r"  - read
**               "w"  - write
**               "u"  -  update
**        fd   = File descriptor of pertinent file.
** Returns the original fd on success, else NULL.
*/
freopen(fn, mode, fd) char *fn, *mode; int fd; {
  if(fclose(fd)) return (NULL);
  if((fd=Uopen(fn, mode, fd))==ERR) return (NULL);
  return (fd);
  }
