#define NOCCARGC  /* no argument count passing */
#include stdio.h
/*
** Get next character from standard input. 
*/
getchar() {
  return (fgetc(stdin));
  }
