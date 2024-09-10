#define NOCCARGC  /* no argument count passing */
#include stdio.h
#include clib.def
/*
** Character-stream input of one character from fd.
** Entry: fd = File descriptor of pertinent file.
** Returns the next character on success, else EOF.
*/
fgetc(fd) int fd; {
  int ch;
  char buff;
  if(Uread(&buff,fd,1)==EOF) {
	Useteof(fd);
        return(EOF);
  }
  ch=buff;
  switch(ch) {
      default:     return (ch);
      case FILEOF:  /* switch(Uchrpos[fd]) {
                     default: --Uchrpos[fd];
                     case 0:
                     case BUFSIZE:
                     }  */
                   Useteof(fd);
                   return (EOF);
      case CR:     return ('\n');
      case LF:    /* NOTE: Uconin() maps LF -> CR */
  }
 }
#asm
_getc EQU   _fgetc
     PUBLIC _getc
#endasm

