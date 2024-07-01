
/* String input from files */
/*   Copyright (c) Mix Software 1988    */
/* ------------------------------------------------------------ */

char *gets(s)                       /* reads one line from stdin */
char    *s;                         /*      into string s        */
                                    /* newline replaced by '\0'  */
{
    int c;
    char *sp;
    sp = s;
    while ((c = fgetc(stdin)) != EOF && c != NEWLINE) *sp++ = c;
    *sp = NULL;
    if ((c == EOF) && (sp == s)) return NULL;
    return s;
}

/* ------------------------------------------------------------ */

char *fgets(s, n, fp)               /* read a line from fp */
char    *s;                         /*      into s         */
int     n;                          /* maximum characters  */
FILE    *fp;                        /*      is n-1         */
{
    int     c;
    char    *sp;
    sp = s;
    if (n <= 0) return NULL;
    while (--n && (c = fgetc(fp)) != EOF && c != NEWLINE) *sp++ = c;
    if (c == NEWLINE && n) *sp++ = c;
    *sp = NULL;
    if ((c == EOF) && (sp == s)) return NULL;
    return s;
    }

/* ------------------------------------------------------------ */

char *cgets(s)                      /* reads one line from console */
char    *s;                         /*      into string s          */
                                    /* newline replaced by '\0'    */
{
    int status;
    int _sys_ad();

    _sys_ad(0x0a00,s,&status);
    *(s + (int)*(s+1)+2) = '\0';
    return s+2;
}

