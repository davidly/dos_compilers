#define NOCCARGC  /* no arg count passing */
#include stdio.h
#include clib.def
extern int Ustatus[];
/*
** Character-stream output of a character to fd.
** Entry: ch = Character to write.
**        fd = File descriptor of perinent file.
** Returns character written on success, else EOF.
*/
fputc(ch, fd) int ch, fd; {
  char buff;
  switch(ch) {
    case EOF:  buff=FILEOF; break;
    case '\n': buff=CR; Uwrite(&buff, fd, 1); buff=LF; break;
    default:   buff=ch;
    }
  Uwrite(&buff,fd,1);
  if(Ustatus[fd] & ERRBIT) return (EOF);
  return (ch);
  }
#asm
_putc equ   _fputc
     PUBLIC _putc
#endasm
