/* printf */
/*   Copyright (c) Mix Software 1988    */

#include "stdio.h"
#include "stdarg.h"
#include "dos.h"

static  signflag;                   /* signed value flag */
static  plusflag;                   /* include + sign for positive values */
static  blankflag;                  /* include blank for positive values */
static  poundflag;                  /* numeric format flag */
static  upperflag;                  /* upper case flag for X, E & G formats */
static  precision;                  /* precision of numbers */
static  farflag;                    /* far pointer flag used by _eint */
static  farhalf;                    /* half of a far pointer */
static  va_list parms;              /* pointer to parameters */

printf(fs)                          /* standard routine */
char     *fs;
{
    int     fputc();
    int     _write();
    int     count;
    va_start(parms, fs);
    count = _output(stdout, fs, fputc, _write);
    return ferror(stdout) ?  -1 : count;
}

fprintf(fp, fs)                     /* standard routine */
FILE     *fp;
char     *fs;
{
    int     fputc();
    int     _write();
    int     count;
    va_start(parms, fs);
    count = _output(fp, fs, fputc, _write);
    return ferror(fp) ? -1 : count;
}

sprintf(s,fs)
char    *s;
char    *fs;
{
    int     _mputc();
    int     _mwrite();
    int     count;
    va_start(parms,fs);
    count = _output(&s, fs, _mputc, _mwrite);
    *s = '\0';
    return count;
}

cprintf(fs)
char    *fs;
{
    int    putch();
    int    _cwrite();
    va_start(parms, fs);
    return _output(0, fs, putch, _cwrite);
}

vprintf(fs, argptr)                          /* standard routine */
char     *fs;
char     *argptr;
{
    int     fputc();
    int     _write();
    int     count;
    parms = argptr;
    count = _output(stdout, fs, fputc, _write);
    return ferror(stdout) ?  -1 : count;
}

vfprintf(fp, fs, argptr)                    /* standard routine */
FILE     *fp;
char     *fs;
char     *argptr;
{
    int     fputc();
    int     _write();
    int     count;
    parms = argptr;
    count = _output(fp, fs, fputc, _write);
    return ferror(fp) ? -1 : count;
}

vsprintf(s, fs, argptr)                     /* standard routine */
char    *s;
char    *fs;
char    *argptr;
{
    int     _mputc();
    int     _mwrite();
    int     count;
    parms = argptr;
    count = _output(&s, fs, _mputc, _mwrite);
    *s = '\0';
    return count;
}

_output(fp, format, putc, write)    /* output routine for */
                                    /* printf, sprintf, fprintf */
char    *fp;                        /* pointer to destination */
char    *format;                    /* pointer to format string */
int     (*putc)();                  /* pointer to output function */
int     (*write)();                 /* pointer to output function */
{
    char    *bufptr;                /* pointer into buffer */
    char    far  *fbufptr;          /* far pointer into buffer */
    char    c;                      /* current character */
    char    padchar;                /* pad character */
    int     count=0;                /* count of characters output */
    int     ljflag;                 /* left justify flag */
    int     longflag;               /* long ("l") present in format */
    int     Nflag;                  /* near pointer flag */
    int     Fflag;                  /* far pointer flag */
    int     length;                 /* length of output string */
    int     len;                    /* length of output string */
    int     flag;                   /* ftoa edit flag */
    int     left;                   /* number digits left of decimal */
    int     right;                  /* number digits right of decimal */
    int     width;                  /* mimimum field width */
    char    buffer[255];            /* encode buffer */
    char    null[]="(null)";        /* print this for %s with NULL pointer */
    STRING  *dynamic;               /* dynamic string pointer */
    int     (*enc)();               /* pointer to encode function */
    int     _eint();                /* encode integer function */
    int     _elong();               /* encode long function */
    int     _atoi();                /* convert string to integer */
    int     _ftoaflag();            /* get format flag for ftoa function */
    int     strlen();               /* determine length of string */

    while (c = *format) {
        if (c != '%') {
            (*putc)(c,fp);
            count++;
            format++;
            continue;
        }
        precision = -1;
        bufptr = buffer;
        ljflag = signflag = blankflag = poundflag = longflag
               = upperflag = plusflag = Nflag = Fflag = 0;
        flags:  switch (*(++format)) {
            case '-': ++ljflag; goto flags;
            case '+': ++plusflag; goto flags;
            case ' ': ++blankflag; goto flags;
            case '#': ++poundflag; goto flags;
        }
        padchar = (*format == '0') ? '0' : ' ';
        if (*format == '*') {
            ++format;
            if ((width = va_arg(parms, int)) < 0) {
                width = -width;
                ++ljflag;
            }
        }
        else width = _atoi(&format);
        if ((*format) == '.') {
            ++format;
            if (*format == '*') {
                ++format;
                precision = va_arg(parms, int);
            }
            else precision = _atoi(&format);
        }
        enc = _eint;
        if (((c = *format++) == 'l') || c == 'L') {
            c = *format++;
            enc = _elong;
            longflag++;
        }
        else if (c == 'h') c = *format++;
        else if (c == 'N') {
            Nflag++;
            c = *format++;
        }
        else if (c == 'F') {
            Fflag++;
            c = *format++;
        }

        switch(c) {

            case 'i':                   /* signed decimal */
            case 'd':
                    signflag++;
                    (*enc)(buffer, 10);
                    length = strlen(bufptr);
                    break;

            case 'u':                   /* unsigned decimal */
                    (*enc)(buffer, 10);
                    length = strlen(bufptr);
                    break;

            case 'o':                   /* unsigned octal */
                    (*enc)(buffer, 8);
                    length = strlen(bufptr);
                    break;

            case 'X': upperflag++;      /* unsigned hexadecimal */
            case 'x':
                    (*enc)(buffer, 16);
                    length = strlen(bufptr);
                    break;

            case 'p':                   /* pointer */
                    precision = 4;
                    upperflag++;
                    poundflag = 0;
                    #ifdef LARGE
                        if (Nflag) {
                            _eint(buffer, 16);
                            length = 4;
                        }
                        else {
                            farflag++;
                            bufptr = va_arg(parms, char*);
                            farhalf = FP_SEG(bufptr);
                            _eint(buffer, 16);
                            buffer[4] = ':';
                            farhalf = FP_OFF(bufptr);
                            _eint(buffer + 5, 16);
                            length = 9;
                            farflag = 0;
                        }
                    #else
                        if (Fflag) {
                            farflag++;
                            fbufptr = va_arg(parms, char far*);
                            farhalf = FP_SEG(fbufptr);
                            _eint(buffer, 16);
                            buffer[4] = ':';
                            farhalf = FP_OFF(fbufptr);
                            _eint(buffer + 5, 16);
                            length = 9;
                            farflag = 0;
                        }
                        else {
                            _eint(buffer, 16);
                            length = 4;
                        }
                    #endif
                    break;

            case 's':                   /* string */
                #ifdef LARGE
                    if (Nflag) bufptr = va_arg(parms, char near*);
                    else bufptr = va_arg(parms, char*);
                    if (bufptr == NULL) {
                        bufptr = null;
                        length = 6;
                        break;
                    }
                    length = strlen(bufptr);
                    if (precision >= 0 && length > precision)
                        length = precision;
                    break;
                #else
                    if (Fflag) {
                        fbufptr = va_arg(parms, char far*);
                        if (fbufptr == NULL) {
                            bufptr = null;
                            length = 6;
                            break;
                        }
                        length = _fstrlen(fbufptr);
                        if (precision >= 0 && length > precision)
                            length = precision;
                        width = width - length;
                        if (!ljflag) {
                            c = *fbufptr;
                            if (padchar == '0' && (c == '-' || c == '+')) {
                                --length;
                                (*putc)(c, fp);
                                fbufptr++;
                                count++;
                            }
                            while (width-- > 0) (*putc)(padchar, fp);
                        }
                        while (length > 0) {
                            len = length < 256 ? length : 255;
                            _fmemcpy((char far*) buffer, fbufptr, len);
                            (*write)(fp, buffer, len);
                            count += len;
                            fbufptr += len;
                            length -= len;
                        }
                        while (width-- > 0) {
                            (*putc)(padchar,fp);
                            count++;
                        }
                        continue;
                    }
                    else {
                        bufptr = va_arg(parms, char*);
                        if (bufptr == NULL) {
                            bufptr = null;
                            length = 6;
                            break;
                        }
                        length = strlen(bufptr);
                        if (precision >= 0 && length > precision)
                            length = precision;
                        break;
                    }
                #endif

            case 'c':                   /* character */
                    buffer[0] = va_arg(parms, int);
                    buffer[1] = '\0';
                    length = 1;
                    break;

            case 'E': upperflag++;      /* exponential */
            case 'e':
                    flag = 1;
                    goto reals;

            case 'G': upperflag++;      /* no trailing 0's */
            case 'g':
                    /* fixed or exponential? */
                    if (precision < 0) precision = 6;
                    flag = _ftoaflag(parms, poundflag, precision);
                    goto reals;

            case 'f':                   /* fixed point */
                    flag = 0;

               reals:
                    if (plusflag) flag |= 8;
                    else if (blankflag) flag |= 136;
                    if (precision < 0) right = 6;
                    else right = precision;
                    left = 1;
                    ftoa(va_arg(parms, double), bufptr, flag, left, right);
                    length = 0;
                    while (c=buffer[length]) {
                       if (poundflag == 0) {
                           if (c == '.' && precision == 0) {
                               strcpy(&buffer[length], &buffer[length+1]);
                               continue;
                           }
                        }
                        if (c == 'e' && upperflag)  buffer[length] =  'E';
                        else if (c == 'E' && !upperflag) buffer[length] =  'e';
                        ++length;
                    }
                    break;

            case 'n':
                    *(va_arg(parms, int*)) = count;
                    continue;

            case 'y':                   /* dynamic string */
                    dynamic = va_arg(parms, STRING*);
                    length = dynamic->length;
                    bufptr = dynamic->string;
                    break;

            default :                   /* format string character */
                    (*putc)(c, fp);
                    count++;
                    continue;
        }
        width = width - length;
        if (!ljflag) {
            if (padchar == '0' && (*bufptr == '-' || *bufptr == '+')) {
                --length;
                (*putc)(*bufptr++, fp);
                count++;
            }
            while (width-- > 0) {
                (*putc)(padchar, fp);
                count++;
            }
        }
        (*write)(fp,bufptr,length);
        count += length;
        while (width-- > 0) {
            (*putc)(padchar,fp);
            count++;
        }
    }
    return count;
}

_eint(bufptr, base)                     /* encode an integer */
char    *bufptr;                        /* pointer to encode buffer */
int     base;                           /* number base */
{
    char buffer[7];
    char *ptr = buffer;
    int  i;
    if (farflag) i = farhalf;
    else i = va_arg(parms, int);
    if (precision == 0 && i == 0) *bufptr = '\0';
    else {
        if (base == 10) {
            if (signflag) {
                if (i < 0) {
                    *bufptr++ = '-';
                    i = -i;
                }
                else if (plusflag) *bufptr++ = '+';
                else if (blankflag) *bufptr++ = ' ';
            }
            _dtoa(i, &ptr);
        }
        else if (base == 16) {
            if (poundflag && i) {
                *bufptr++ = '0';
                *bufptr++ = upperflag ? 'X' : 'x';
             }
             _htoa(i, &ptr);
        }
        else {
            if (poundflag && i) {
                *bufptr++ = '0';
            }
            _otoa(i, &ptr);
        }
        *ptr = '\0';
        for (i=precision-strlen(buffer); i > 0; i--) *bufptr++ = '0';
        strcpy(bufptr, buffer);
    }
}

_dtoa(n, bufptr)                    /* decimal integer encode routine */
unsigned    n;                      /* unsigned integer */
char        **bufptr;               /* pointer to the buffer pointer */
{
    if (n < 10) *(*bufptr)++ = n + 48;
    else {
        _dtoa(n/10, bufptr);
        _dtoa(n%10, bufptr);
    }
}

_htoa(n, bufptr)                    /* hexadecimal integer encode routine */
unsigned    n;                      /* unsigned integer */
char        **bufptr;               /* pointer to the buffer pointer */
{
    if (n < 16) {
        if (n < 10) *(*bufptr)++ = n + 48;
        else *(*bufptr)++ = upperflag ? n + 55 : n + 87;
    }
    else {
        _htoa(n/16, bufptr);
        _htoa(n%16, bufptr);
    }
}

_otoa(n, bufptr)                    /* octal integer encode routine */
unsigned    n;                      /* unsigned integer */
char        **bufptr;               /* pointer to the buffer pointer */
{
    if (n < 8) *(*bufptr)++ = n + 48;
    else {
        _otoa(n/8, bufptr);
        _otoa(n%8, bufptr);
    }
}

_elong(bufptr, base)                /* encode a long */
char    *bufptr;                    /* pointer to encode buffer */
int     base;                       /* number base */
{
    char buffer[12];
    char *ptr = buffer;
    int  i;
    long l;
    l = va_arg(parms, long);
    if (precision == 0 && l == 0) *bufptr = '\0';
    else {
        if (base == 10) {
            if (signflag) {
                if (l < 0) {
                    *bufptr++ = '-';
                    l = -l;
                }
                else if (plusflag) *bufptr++ = '+';
                else if (blankflag) *bufptr++ = ' ';
            }
            _ldtoa(l, &ptr);
        }
        else if (base == 16) {
            if (poundflag && l) {
                *bufptr++ = '0';
                *bufptr++ = upperflag ? 'X' : 'x';
             }
             _lhtoa(l, &ptr);
        }
        else {
            if (poundflag && l) {
                *bufptr++ = '0';
            }
             _lotoa(l, &ptr);
        }
        *ptr = '\0';
        for (i = precision - strlen(buffer); i > 0; i--) *bufptr++ = '0';
        strcpy(bufptr, buffer);
    }
}

_ldtoa(l, bufptr)                   /* long decimal encode routine */
unsigned long l;                    /* long integer */
char        **bufptr;               /* pointer to the buffer pointer */
{
    if (l < 10) *(*bufptr)++ = l + 48;
    else {
        _ldtoa(l/10, bufptr);
        _ldtoa(l%10, bufptr);
    }
}

_lhtoa(l, bufptr)                   /* long hexadecimal encode routine */
long        l;                      /* long integer */
char        **bufptr;               /* pointer to the buffer pointer */
{
  int i, start;
  int digit[9];
  digit[8] = 1;
  for (i = 7; i >= 0; i--) {
      digit[i]  = l & 0xf;
      l = l >> 4;
  }
  start = 0;
  while (digit[start] == 0) start++;
  if (start == 8) *(*bufptr)++ = '0';
  else {
      for (i = start; i < 8; i++) {
         if (digit[i] < 10) *(*bufptr)++ = digit[i] + 48;
         else *(*bufptr)++ = upperflag ? digit[i] + 55 : digit[i] + 87;
      }
  }
}

_lotoa(l, bufptr)                   /* long octal encode routine */
long        l;                      /* long integer */
char        **bufptr;               /* pointer to the buffer pointer */
{
  int i, start;
  int digit[12];
  digit[11] = 1;
  for (i = 10; i > 0; i--) {
      digit[i]  = l & 7;
      l = l >> 3;
  }
  digit[0] = l & 3;
  start = 0;
  while (digit[start] == 0) start++;
  if (start == 11) *(*bufptr)++ = '0';
  else {
      for (i = start; i < 11; i++)
         *(*bufptr)++ = digit[i] + 48;
  }
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

_cwrite(fp, s, n)
int     fp;
char    *s;
int     n;
{
    int  i;
    for (i=0; i < n; i++) putch(*s++);
    return n;
}

