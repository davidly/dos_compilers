/*
** return 'true' if c is a control character
** (0-31 or 127)
*/
iscntrl(c) char *c; {
  /* c is a simulated unsigned integer */
  return ((c <= 31) || (c == 127));
  }
