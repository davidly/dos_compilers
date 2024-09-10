#define NOCCARGC  /* no argument count passing */
/*
** Place n occurrences of ch at dest.
*/
pad(dest, ch, n) char *dest, *n; int ch; {
  /* n is a fake unsigned integer */
  while(n--) *dest++ = ch;
  }
