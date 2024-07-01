#include "stdio"

printf(fs)                          /* standard routine */
char     *fs;
{
    int     putc();
    int     _write();
    return _output(stdout, &fs, putc, _write);
}

fprintf(fp, fs)                     /* standard routine */
FILE     *fp;
char     *fs;
{
    int     putc();
    int     _write();
    return _output(fp, &fs, putc, _write);
}

sprintf(s,fs)                       /* standard routine */
char    *s;
char    *fs;
{
    int     _mputc();
    int     _mwrite();
    int     status;
    status = _output(&s, &fs, _mputc, _mwrite);
    *s = '\0';
    return status;
}

_output(fp, parms, putc, write)     /* output routine for */
                                    /* printf, sprintf, fprintf */
char    *fp;                        /* pointer to destination */
char    **parms;                    /* pointer to addr of parameters */
int     (*putc)();                  /* pointer to output function */
int     (*write)();                 /* pointer to output function */
{
    char    buffer[80];             /* encode buffer */
    char    *bufptr;                /* pointer into buffer */
    char    *format;                /* format string pointer */
    char    *cptr;                  /* pointer to character */
    char    c;                      /* current character */
    char    padchar;                /* pad character */
    int     ljflag;                 /* left justify flag */
    int     length;                 /* length of output string */
    int     precision;              /* precision for reals */
    int     flag;                   /* ftoa edit flag */
    int     left;                   /* number digits left of decimal */
    int     right;                  /* number digits right of decimal */
    int     width;                  /* mimimum field width */
    int     (*enc)();               /* pointer to encode function */
    int     _eint();                /* encode integer function */
    int     _elong();               /* encode long function */
    int     _edouble();             /* encode double function */
    int     _atoi();                /* convert string to integer */
    int     _getformat();           /* get format flag */
    int     strlen();               /* determine length of string */
    STRING  *dynamic;               /* dynamic string pointer */

    format = *parms--;              /* format points to format string */
    while (c = *format++) {
        if (c != '%') {
            if ((*putc)(c,fp) != EOF) continue;
            else return EOF;
        }
        precision = -1;
        bufptr = buffer;
        ljflag = 0;
        if (*format == '-') {
            ++format;
            ++ljflag;
        }
        padchar = (*format == '0') ? '0' : ' ';
        width = (isdigit(*format)) ? _atoi(&format) : 0;
        if ((*format) == '.') {
            ++format;
            if (isdigit(*format)) precision = _atoi(&format);
        }
        enc = _eint;
        if (toupper(c = *format++) == 'L') {
            c = *format++;
            enc = _elong;
            --parms;
        }
        switch(toupper(c)) {

            case 'D':                   /* signed decimal */
                    (*enc)(parms, buffer, 10, 1);
                    length = strlen(bufptr);
                    break;

            case 'U':                   /* unsigned decimal */
                    (*enc)(parms, buffer, 10, 0);
                    length = strlen(bufptr);
                    break;

            case 'O':                   /* unsigned octal */
                    (*enc)(parms, buffer, 8, 0);
                    length = strlen(bufptr);
                    break;

            case 'X':                   /* unsigned hexadecimal */
                    (*enc)(parms, buffer, 16, 0);
                    length = strlen(bufptr);
                    break;

            case 'S':                   /* string */
                    bufptr = *parms;
                    length = strlen(bufptr);
                    break;

            case 'C':                   /* character */
                    cptr = parms;
                    buffer[0] = *cptr;
                    buffer[1] = '\0';
                    length = 1;
                    break;

            case 'E':                   /* exponential */
                    flag = 1;
                    goto reals;

            case 'F':                   /* fixed point */
                    flag = 0;
                    goto reals;

            case 'G':                   /* no trailing 0's */
                    /* fixed or exponential? */
                    flag = _getformat(parms-3);

               reals:
                    left = 1;
                    parms = parms - 3;
                    if (precision == -1) right = 6;
                    else right = precision;
                    _edouble(parms, buffer, flag, left, right);
                    precision = -1;
                    length = 0;
                    while (c=buffer[length]) {
                       if (c == 'D') buffer[length] = 'E';
                       ++length;
                    }
                    break;

            case 'Y':                   /* dynamic string */
                    dynamic = *parms;
                    length = dynamic->length;
                    bufptr = dynamic->string;
                    break;

            default :                   /* format string character */
                    if ((*putc)(c, fp) != EOF) continue;
                    else return EOF;
        }
        if (precision >= 0 && length > precision) length = precision;
        width = width - length;
        if (!ljflag) {
            if (padchar == '0' && *bufptr == '-') {
                --length;
                if ((*putc)(*bufptr++, fp) == EOF) return EOF;
            }
            while (width-- > 0)
                if ((*putc)(padchar, fp) == EOF) return EOF;
        }
        if ((*write)(fp,bufptr,length) == EOF) return EOF;
        while (width-- > 0)
            if ((*putc)(padchar,fp) == EOF) return EOF;
        --parms;
    }
    return 0;
}

_eint(iptr, bufptr, base, sf)       /* encode an integer*/
int     *iptr;                      /* pointer to integer */
char    *bufptr;                    /* pointer to encode buffer */
int     base;                       /* number base */
int     sf;                         /* signed or unsigned flag */
{
    if (*iptr < 0 && sf) {
        *bufptr++ = '-';
        *iptr = -*iptr;
    }
    _itoa(*iptr, &bufptr, base);   /* convert integer to string */
    *bufptr = '\0';
}

_elong(lptr, bufptr, base, sf)      /* encode a long */
long    *lptr;                      /* pointer to long */
char    *bufptr;                    /* pointer to encode buffer */
int     base;                       /* number base */
int     sf;                         /* sign flag */
{
    if (*lptr < 0 && sf) {
        *bufptr++ = '-';
        *lptr = -*lptr;
    }
    _ltostr(*lptr, &bufptr, base);  /* convert long to string */
    *bufptr = '\0';
}

_itoa(n, bufptr, base)              /* integer encode routine */
unsigned    n;                      /* unsigned integer */
char        **bufptr;               /* pointer to the buffer pointer */
int         base;                   /* number base */
{
    if (n < base) {
        *(*bufptr)++ = (n < 10) ? n + 48 : n + 55;
        return;
    }
    _itoa(n/base, bufptr, base);
    _itoa(n%base, bufptr, base);
}

_ltostr(lptr, bufptr, base)         /* long encode routine */
long        lptr;                   /* long integer */
char        **bufptr;               /* pointer to the buffer pointer */
int         base;                   /* number base */
{
    if (lptr < base) {
        *(*bufptr)++ = (lptr < 10) ? lptr + '0' : lptr + 55;
        return;
    }
    _ltostr(lptr/base, bufptr, base);
    _ltostr(lptr%base, bufptr, base);
}

_edouble(dptr, bufptr, flag, left, right) /* encode a double */
double  *dptr;                            /* pointer to double */
char    *bufptr;                          /* pointer to encode buffer */
int     flag;                             /* encode format flag */
int     left;                             /* # of digits left of decimal */
int     right;                            /* # of digits right of decimal */
{
    ftoa(*dptr, bufptr, flag, left, right);
}

_mputc(c, fp)                             /* write c to fp */
int     c;
char    **fp;
{
   *(*fp)++ = c;
   return c;
}

_mwrite(fp, s, n)
char    **fp;
char    *s;
int     n;
{
    int  i;
    for (i=0; i < n; i++) *(*fp)++ = *s++;
    return n;
}

_getformat(dptr)                        /* get format flag */
double  *dptr;                          /*  for _edouble   */
{
   if (*dptr < 100000.0) return 2;     /* fixed format */
   else return 3;                      /* exponential format */
}

