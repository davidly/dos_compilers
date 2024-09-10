#define NOCCARGC  /* no arg count passing */
#include stdio.h
#include clib.def
/*
** Unlink (delete) the named file. 
** Entry: fn = file name.
**             May be prefixed by letter of drive.
** Returns NULL on success, else ERR.
*/
unlink(fn) char *fn; {
  return(Umsdos(fn,0,0,DELFIL));
  }
#asm
_delete  equ    _unlink
        PUBLIC  _delete
#endasm

