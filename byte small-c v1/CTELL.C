#define NOCCARGC  /* no arg count passing */
#include stdio.h
#include clib.def
/*
** Return offset to current location in file
** tell() returns ERR if some error occured, (EOF) for
** non-file devices, 0 otherwise.
** offset is returned in offstlo & offsthi such that
** true offset = offsthi>>16 + offstlo
*/
extern int Ufd[];
tell(fd,offstlo,offsthi) int fd, *offstlo, *offsthi; {
  if(!Umode(fd) || isatty(fd)) return (EOF);
  return (utell(offstlo,offsthi,Ufd[fd]));
  }

/* 
** MSDOS low-level routine for tell
*/
utell(offstlo,offsthi,pfd) int pfd,*offstlo,*offsthi; {
#asm
  POP SI  ;Return address
  POP BX  ;Handle
  PUSH BX ;Restore
  PUSH SI
  XOR DX,DX ;Zero in DX
; Move file pointer 0 from current location
; this will return current location in DX:AX
  MOV AX,4201H
  INT 21H
  JC UTELLC1  ;Jump if error
  MOV BP,SP   ;Get SP
  MOV SI,[BP+6] ;offset lo
  MOV [SI],AX   ;move it in
  MOV SI,[BP+4] ;Offset hi
  MOV [SI],DX   ;Move it in
  XOR AX,AX     ;Return no error
  JMP UTELLC2
 UTELLC1: 
  MOV _ERRNO,AX  ;Return error
  MOV AX,-2
 UTELLC2:
  MOV BX,AX
  XOR CX,CX     ;Zero in CX
  EXTRN _ERRNO:WORD
#endasm
}
