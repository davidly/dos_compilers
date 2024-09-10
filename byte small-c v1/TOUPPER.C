/*
** return upper-case of c if it is lower-case, else c
*/
toupper(c) int c; {
  if(c<='z' && c>='a') return (c-32);
  return (c);
  }
