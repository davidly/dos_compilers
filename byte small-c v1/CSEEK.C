
#define NOCCARGC  /* no argument count passing */
#include stdio.h
#include clib.def
/*
** Position fd to the byte indicated by
** "offset" relative to the point indicated by "base."
** 
** offset is given by offstlo which defines bits 
** 0-15 of the true offset and offsthi, which defines
** bits 16-31 of the true offset.  I.e., true offset is
** offstlo + offsthi>>16.  Note that this will require
** some creative programming, since this version of
** Small C uses 16-bit signed integers.
**
**     BASE     OFFSET-RELATIVE-TO
**       0      first record
**       1      current record
**       2      end of file (last record + 1)
**
** Returns NULL on success, else EOF.
*/
extern int Ufd[];
seek(fd, offstlo, offsthi, base) int fd, offstlo, offsthi, base; {
  if(!Umode(fd) || isatty(fd)) return (EOF);

  /* Gotta set up offstlo and offsthi up to move */
  /* into the registers.                         */
  if(Umsdos(offstlo,offsthi,Ufd[fd],base+POSFIL)==ERR) return(ERR);
  return (NULL);
  }

