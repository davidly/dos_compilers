#define NOCCARGC  /* no argument count passing */
#include stdio.h
#include clib.def
/*
** Close all open files and exit to CP/M. 
** Entry: errcode = Character to be sent to stderr.
** Returns to CP/M rather than the caller.
*/
exit(errcode) char errcode; {
  int fd;
  if(errcode) Uconout(errcode);
/* Following code not needed for MS-DOS (given that we
** are using function 4C to terminate -- it closes
** active handles for us).
*/

/*  for(fd=0; fd < MAXFILES; fclose(fd++)); */

  Umsdos(0,0,0,19456);  /* 19456 = 4C00H, 4C in AH terminates */
  }
#asm
_abort: JMP    _exit
       PUBLIC  _abort
#endasm

