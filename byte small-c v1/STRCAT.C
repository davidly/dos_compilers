/*
** concatenate t to end of s 
** s must be large enough
*/
strcat(s, t) char *s, *t; {
  char *d;
  d = s;
  --s;
  while (*++s) ;
  while (*s++ = *t++) ;
  return(d);
  }
