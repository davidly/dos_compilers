/* scanf */
/*   Copyright (c) Mix Software 1988    */

#include "stdio.h"
#include "stdarg.h"

static va_list parms;              /* pointer to parameters */
static int base;                   /* number base */
static int ch;                     /* input character */

scanf(fs)                           /* standard routine */
char     *fs;
{
    int    getc();
    int    ungetc();
    va_start(parms, fs);
    return _input(stdin, fs, getc, ungetc);
}

fscanf(fp, fs)                      /* standard routine */
char     *fp, *fs;
{
    int    getc();
    int    ungetc();
    va_start(parms, fs);
    return _input(fp, fs, getc, ungetc);
}

sscanf(s,fs)                        /* standard routine */
char    *s, *fs;
{
    int     _mread();
    int     _mungetc();
    va_start(parms, fs);
    return _input(&s, fs, _mread, _mungetc);
}

cscanf(fs)
char     *fs;
{
    static int    _getche();
    static int    _un_getche();
    va_start(parms, fs);
    return _input(stdin, fs, _getche, _un_getche);
}


_input(fp, format, read, ungetc)    /* input routine for */
                                    /* scanf, sscanf, fscanf */
char    *fp;                        /* pointer to input */
char    *format;                    /* pointer to format string */
int     (*read)();                  /* character read function */
int     (*ungetc)();                /* character unget function */
{
    char    c;                      /* format string character */
    char    *bufptr;                /* pointer to buffer */
    char    far *fptr;              /* far pointer to character */
    int     value;                  /* value of current digit */
    int     asflag;                 /* assignment supression flag */
    int     sflag;                  /* sign flag */
    int     lflag;                  /* long flag */
    int     iflag;                  /* flag for %i format */
    int     Nflag;                  /* Near pointer flag */
    int     Fflag;                  /* Far pointer flag */
    int     i;                      /* loop counter */
    int     width;                  /* maximum field width */
    int     valid;                  /* valid real number format */
    int     caret;                  /* flag for %[^ format */
    int     count=0;                /* character count */
    int     number=0;               /* number of characters read */
    union {
        int     i;
        long    l;
        char    *ptr;
        char    near *nptr;
        char    far *fptr;
        struct {
            int offset;
            int segment;
        } half;
    } accum;                        /* accumulator */
    char    buffer[256];            /* floating point string buffer */
    int     _digit();               /* decode digit function */
    int     _atoi();                /* convert string to integer */
    int     isspace();              /* isspace function */
    int     isdigit();              /* isdigit function */
    char    *strchr();              /* search for character in string */
    double  atof();                 /* atof function */
    STRING  *stods();               /* convert string to dynamic string */

    while (c = *format++) {
        if (isspace(c)) {
            while (isspace(*format)) format++;
            while (isspace(ch = (*read)(fp))) number++;
            (*ungetc)(ch, fp);
            continue;
        }
        if (c != '%') {
            number++;
            if ((ch = (*read)(fp)) == c) continue;
            else {
                if (ch == EOF) return EOF;
                else {
                    (*ungetc)(ch,fp);
                    return count;
                }
            }
        }
        sflag = asflag = lflag = Nflag = Fflag = iflag = 0;
        if ((*format) == '*') {     /* check for assignment suppression */
            ++asflag;
            ++format;
        }
        if (isdigit(*format)) width = _atoi(&format);
        else width = -1;
        if (*format == 'N') {
            format++;
            Nflag++;
        }
        else if (*format == 'F') {
                format++;
                Fflag++;
             }
        if (*format == 'l' || *format == 'L') { /* check for double precision */
            format++;
            lflag++;
        }
        else if (*format == 'h') format++;
        if (width == 0) {
            format++;
            continue;
        }
        switch (*format++) {
            case 'o':                   /* unsigned octal */
                    base = 8;
                    goto decode;

            case 'X':
            case 'x':                   /* unsigned hexadecimal */
                    base = 16;
                    goto decode;

            case 'i':            /* signed decimal, 0 or 0x prefix OK */
                    iflag++;
                    base = 10;
                    goto decode;

            case 'd':            /* signed decimal */
            case 'u':
                    base = 10;
            decode:
                    while (isspace(ch=(*read)(fp))) number++;
                    if (ch == EOF) return EOF;
                    number++;
                    width--;
                    if (width && (ch == '+' || ch == '-')) {
                       if (ch == '-') ++sflag;
                       if ((ch = (*read)(fp)) == EOF) return EOF;
                       number++;
                       width--;
                    }
                    if (iflag) {
                        if ((ch == '0') && width) {
                            base = 8;
                            if ((ch = (*read)(fp)) == 'x' || ch == 'X') {
                                number++;
                                width--;
                                base = 16;
                                if (width) {
                                    ch = (*read)(fp);
                                    number++;
                                    width--;
                                }
                                if (ch == EOF) return EOF;
                            }
                            else {
                                (*ungetc)(ch, fp);
                                ch = '0';
                            }
                        }
                    }
                    accum.l = _digit();
                    if (accum.i == -1) {
                        (*ungetc)(ch,fp);
                        return count;
                    }
                    while (width) {
                       ch = (*read)(fp);
                       if ((value = _digit()) == -1) {
                           (*ungetc)(ch, fp);
                           break;
                       }
                       width--;
                       number++;
                       if (lflag)
                           accum.l = accum.l * base + value;
                       else
                           accum.i = accum.i * base + value;
                    }
                    if (!asflag) {
                        if (lflag) {
                            if (sflag) accum.l = -accum.l;
                            #ifdef LARGE
                            if (Nflag) *(va_arg(parms, long near*)) = accum.l;
                            #else
                            if (Fflag) *(va_arg(parms, long far*)) = accum.l;
                            #endif
                            else *(va_arg(parms, long*)) = accum.l;
                        }
                        else {
                            if (sflag) accum.i = -accum.i;
                            #ifdef LARGE
                            if (Nflag) *(va_arg(parms, int near*)) = accum.i;
                            #else
                            if (Fflag) *(va_arg(parms, int far*)) = accum.i;
                            #endif
                            else *(va_arg(parms, int*)) = accum.i;
                        }
                        count++;
                    }
                    break;

            case 's':                   /* string */
                    while (isspace(ch=(*read)(fp))) number++;
                    if (ch == EOF) return EOF;
                    if (!asflag) {
                        #ifdef LARGE
                        if (Nflag) fptr = va_arg(parms, char near*);
                        #else
                        if (Fflag) fptr = va_arg(parms, char far*);
                        #endif
                        else fptr = va_arg(parms, char*);
                    }
                    while (!isspace(ch) && ch != EOF && width) {
                        if (!asflag) *fptr++ = ch;
                        ch = (*read)(fp);
                        number++;
                        width--;
                    }
                    (*ungetc)(ch,fp);
                    if (!asflag) {
                        *fptr = '\0';
                        ++count;
                    }
                    break;

            case '[':       /* string delimited by [character set] */
                    if (!asflag) {
                        #ifdef LARGE
                        if (Nflag) fptr = va_arg(parms, char near*);
                        #else
                        if (Fflag) fptr = va_arg(parms, char far*);
                        #endif
                        else fptr = va_arg(parms, char*);
                    }
                    i = caret = 0;
                    if (*format == '^') {
                        caret++;
                        format++;
                    }
                    if (*format == ']' || *format == '-')
                        buffer[i++] = *format++;
                    while (i < 255 && *format != ']') {
                        if (*format == '-') {
                            format++;
                            c = buffer[i-1];
                            if (*format != ']' && *format > c) {
                                for (c++; i < 255 && c <= *format; c++)
                                    buffer[i++] = c;
                                format++;
                            }
                            else buffer[i++] = '-';
                        }
                        else buffer[i++] = *format++;
                    }
                    format++;
                    buffer[i] = '\0';
                    i = number;
                    while (((caret && strchr(buffer, ch=(*read)(fp))==NULL) ||
                           (!caret && strchr(buffer, ch=(*read)(fp))!=NULL)) &&
                            ch != EOF && width) {
                        if (!asflag) *fptr++ = ch;
                        number++;
                        width--;
                    }
                    (*ungetc)(ch,fp);
                    if (number == i) return count;
                    if (!asflag) {
                        *fptr = '\0';
                        ++count;
                    }
                    break;

            case 'c':                   /* character */
                    if ((ch = (*read)(fp)) == EOF) return EOF;
                    number++;
                    if (!asflag) {
                       #ifdef LARGE
                       if (Nflag) fptr = va_arg(parms, char near*);
                       #else
                       if (Fflag) fptr = va_arg(parms, char far*);
                       #endif
                       else fptr = va_arg(parms, char*);
                       *fptr = ch;
                       ++count;
                    }
                    if (width > 0) {
                       width--;
                       while (width > 0) {
                          if ((ch = (*read)(fp)) == EOF) return EOF;
                          number++;
                          width--;
                          if (!asflag) *(++fptr) = ch;
                       }
                    }
                    break;

            case 'n':
                    if (lflag) {
                        #ifdef LARGE
                        if (Nflag) *(va_arg(parms, int near*)) = number;
                        #else
                        if (Fflag) *(va_arg(parms, int far*)) = number;
                        #endif
                        else *(va_arg(parms, int*)) = number;
                    }
                    else {
                        #ifdef LARGE
                        if (Nflag) *(va_arg(parms, long near*)) = number;
                        #else
                        if (Fflag) *(va_arg(parms, long far*)) = number;
                        #endif
                        else *(va_arg(parms, long*)) = number;
                    }
                    break;

            case 'p':
                    while (isspace(ch=(*read)(fp))) number++;
                    if (ch == EOF) return EOF;
                    number++;
                    width--;
                    base = 16;
                    accum.half.segment = 0;
                    accum.i = _digit();
                    if (accum.i == -1) {
                        (*ungetc)(ch,fp);
                        return count;
                    }
                    while (width) {
                       ch = (*read)(fp);
                       if ((value = _digit()) == -1) {
                           (*ungetc)(ch, fp);
                           break;
                       }
                       width--;
                       number++;
                       accum.l = (accum.l << 4) + value;
                    }
                    #ifdef LARGE
                    if (!Nflag && ch == ':') {
                    #else
                    if (Fflag && ch == ':') {
                    #endif
                        (*read)(fp);            /* consume the ':' */
                        accum.half.segment = accum.half.offset;
                        accum.half.offset = 0;
                        while (width) {
                            ch = (*read)(fp);
                            if ((value = _digit()) == -1) {
                                (*ungetc)(ch, fp);
                                break;
                            }
                            width--;
                            number++;
                            accum.half.offset=(accum.half.offset << 4) + value;
                        }
                    }
                    if (!asflag) {
                       #ifdef LARGE
                       if (Nflag) *(va_arg(parms, char near**)) = accum.nptr;
                       #else
                       if (Fflag) *(va_arg(parms, char far**)) = accum.fptr;
                       #endif
                       else *(va_arg(parms, char **)) = accum.ptr;
                       count++;
                    }
                    break;

            case 'e':
            case 'E':
            case 'f':                   /* floating point */
            case 'g':
            case 'G':
                    while (isspace(ch=(*read)(fp))) number++;
                    if (ch == EOF) return EOF;
                    valid = 0;
                    bufptr = buffer;
                    if (ch == '+' || ch == '-') {
                        *bufptr++ = ch;
                        ch = (*read)(fp);
                        number++;
                        width--;
                    }
                    while ((ch >= '0' && ch <= '9') && width) {
                        *bufptr++ = ch;
                        valid++;
                        ch = (*read)(fp);
                        number++;
                        width--;
                    }
                    if (ch == '.' && width) {
                       *bufptr++ = ch;
                       ch = (*read)(fp);
                       number++;
                       width--;
                    }
                    while ((ch >= '0' && ch <= '9') && width) {
                       *bufptr++ = ch;
                       valid++;
                       ch = (*read)(fp);
                       number++;
                       width--;
                    }
                    if ((ch == 'E' || ch == 'e') && valid && width) {
                       *bufptr++ = 'E';
                       ch = (*read)(fp);
                       number++;
                       width--;
                       if ((ch == '+' || ch == '-') && width) {
                          *bufptr++ = ch;
                          ch = (*read)(fp);
                          number++;
                          width--;
                       }
                       while ((ch >= '0' && ch <= '9') && width) {
                          *bufptr++ = ch;
                          ch = (*read)(fp);
                          number++;
                          width--;
                       }
                    }
                    (*ungetc)(ch, fp);
                    if (!valid) return count;
                    *bufptr = '\0';
                    if (!asflag) {
                        if (lflag) {
                        #ifdef LARGE
                            if (Nflag)
                                *(va_arg(parms, double near*)) = atof(buffer);
                        #else
                            if (Fflag)
                                *(va_arg(parms, double far*)) = atof(buffer);
                        #endif
                            else
                                *(va_arg(parms, double*)) = atof(buffer);
                        }
                        else {
                        #ifdef LARGE
                            if (Nflag)
                                *(va_arg(parms, float near*)) = atof(buffer);
                        #else
                            if (Fflag)
                                *(va_arg(parms, float far*)) = atof(buffer);
                        #endif
                            else
                                *(va_arg(parms, float*)) = atof(buffer);
                        }
                        ++count;
                    }
                    break;

#ifdef DYNAMIC
            case 'y':               /* dynamic string */
                    while (isspace(ch=(*read)(fp))) number++;
                    if (ch == EOF) return EOF;
                    i = 0;
                    bufptr = buffer;
                    while (width && !isspace(ch) && ch != EOF) {
                       if (i < 255) *bufptr++ = ch;
                       ch = (*read)(fp);
                       number++;
                       width--;
                    }
                    *bufptr = '\0';
                    (*ungetc)(ch,fp);
                    if (!asflag) {
                       *(va_arg(parms, char**)) = stods(buffer);
                       ++count;
                    }
                    break;
#endif

            default :
                    number++;
                    if ((ch = (*read)(fp)) == *(format-1)) continue;
                    else {
                       if (ch == EOF) return EOF;
                       else {
                           (*ungetc)(ch,fp);
                           return count;
                       }
                    }
        }
    }
    return count;
}

_digit()                           /* decode ch to binary */
{
    int n;
    if (ch >= '0' && ch <= '9') n = ch - 48;
    else if (ch >= 'A' && ch <= 'F') n = ch - 55;
        else if (ch >= 'a' && ch <= 'f') n = ch - 87;
            else return -1;
    if (n < base) return n;
    else return -1;
}

_mread(s)                           /* read character from string */
char    **s;                        /* pointer to string */
{
    if (*(*s) != '\0') return *(*s)++;
    else return EOF;
}

_mungetc(c,s)                       /* unget character to string */
int     c;                          /* dumy parameter */
char    **s;                        /* pointer to string pointer */
{
    if (c != EOF) *(--(*s)) = c;
    return c;
}

static _getche()
{
    extern static int _un_getch;
    int ch = _un_getch;
    if (ch != EOF) {
        _un_getch = EOF;
        return ch;
    }
    else return getche();
}

static _un_getche(ch)
   int ch;
{
    extern static int _un_getch;
    if (_un_getch != EOF) return EOF;
    _un_getch = ch;
    return ch;
}

static int _un_getch = EOF;

