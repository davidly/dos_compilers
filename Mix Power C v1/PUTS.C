
/* String output to files */
/*   Copyright (c) Mix Software 1988    */

/* ------------------------------------------------------------ */

char *puts(s)                   /* write s to stdout */
char    *s;
{
    int     _write();
    int     strlen();
    int     count;
    count = strlen(s);
    if (_write(stdout, s, count) != count) return EOF;
    if (fputc('\n', stdout) != EOF) return s;
    else return EOF;
}

/* ------------------------------------------------------------ */

int _printf_(s)                /* write s to stdout */
char    *s;
{
   int     _write();
   int     strlen();
   int     count = 0;
   if (s == NULL) return 0;
   while (*s != '\0') {
      if (*s == '%') ++s;
      if (fputc(*s,stdout) == EOF) return EOF;
      ++count;
      ++s;
      }
   return count;
}

/* ------------------------------------------------------------ */

char *fputs(s, fp)              /* write s to fp */
char    *s;
FILE    *fp;
{
    int     _write();
    int     strlen();
    int     count;
    count = strlen(s);
    if (_write(fp, s, count) != count) return EOF;
    else return s;
}

/* ------------------------------------------------------------ */

char *cputs(s)           /* write s to console */
char    *s;
{
    int     putch();
    while (*s) putch(*s++);
    return s;
}

