#define NOCCARGC  /* no arg count passing */
#include stdio.h
#include clib.def
/*
** Write a string to fd. 
** Entry: string = Pointer to null-terminated string.
**        fd     = File descriptor of pertinent file.
*/
fputs(string,fd) char *string; int fd; {
  while(*string)
	if(fputc(*string++,fd)==EOF) return(EOF);
  return(0);
  }

