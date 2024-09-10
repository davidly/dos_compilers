#define NOCCARGC  /* no argument count passing */
extern char *Umemptr;
/*
** Return the number of bytes of available memory.
** In case of a stack overflow condition, if 'abort'
** is non-zero the program aborts with an 'S' clue,
** otherwise zero is returned.
*/
avail(abort) int abort; {
  char x;
  if(&x < Umemptr) {
    if(abort) exit('M');
    return (0);
    }
  return (&x - Umemptr);
  }

