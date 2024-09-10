#define NOCCARGC  /* no argument count passing */
/*
** return 'true' if c is a punctuation character
** (all but control and alphanumeric)
*/
ispunct(c) int c; {
  return (!isalnum(c) && !iscntrl(c));
  }
