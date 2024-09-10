#define NOCCARGC  /* no argument count passing */
#include stdio.h
#include clib.def
/*
** Rename a file.
**  from = address of old filename.
**    to = address of new filename.
**  Returns NULL on success, else ERR.
*/
rename(from,to) char *from, *to; {
return(Urename(from,to));
}

Urename(from, to) char *from, *to; {
#asm
  POP SI  ;Return address
  POP DI  ;New name address
  POP DX  ;Current name address
  PUSH DX  ;Restore
  PUSH DI
  PUSH SI
  MOV AX,DS
  MOV ES,AX ;Set extra segment as our own
  MOV AH,56H ;Rename
  INT 21H
  JNC URENAM1
  MOV _ERRNO,AX
  MOV AX,-2
Urenam1:
  MOV BX,AX
  XOR CX,CX  ;Zero in CX
  EXTRN _ERRNO:WORD
#endasm
}

