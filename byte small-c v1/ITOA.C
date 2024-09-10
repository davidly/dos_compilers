#define NOCCARGC  /* no argument count passing */
/*
** itoa(n,s) - Convert n to characters in s 
*/
itoa(n, s) char *s; int n; {
  int sign;
  char *ptr;
  ptr = s;
  if ((sign = n) < 0) /* record sign */
    n = -n;     /* make n positive */
  do {          /* generate digits in reverse order */
    *ptr++ = n % 10 + '0';         /* get next digit */
    } while ((n = n / 10) > 0);    /* delete it */
  if (sign < 0) *ptr++ = '-';
  *ptr = '\0';
  reverse(s);
  }
