#define NOCCARGC  /* no argument count passing */
#include stdio.h
/*
** Write character to standard output. 
*/
putchar(ch) int ch; {
  return (fputc(ch, stdout));
  }
