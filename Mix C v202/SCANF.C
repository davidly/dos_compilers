#include "stdio"

scanf(fs)                           /* standard routine */
char     *fs;
{
    int    getc();
    int    ungetc();
    return _input(stdin, &fs, getc, ungetc);
}

fscanf(fp, fs)                      /* standard routine */
char     *fp, *fs;
{
    int    getc();
    int    ungetc();
    return _input(fp, &fs, getc, ungetc);
}

sscanf(s,fs)                        /* standard routine */
char    *s, *fs;
{
    int     _mread();
    int     _mungetc();
    return _input(&s, &fs, _mread, _mungetc);
}

_input(fp, parms, read, ungetc)     /* input routine for */
                                    /* scanf, sscanf, fscanf */
char    *fp;                        /* pointer to input */
char    **parms;                    /* pointer to addr of parameters */
int     (*read)();                  /* character read function */
int     (*ungetc)();                /* character unget function */
{
    union {                         /* buffer for numeric & string storage */
      int   integer;
      char  string[81];
    } buffer;
    char    *format;                /* format string pointer */
    char    c;                      /* format string character */
    char    **ptr;                  /* pointer to pointer */
    int     base;                   /* number base */
    int     value;                  /* binary value of digit */
    int     pflag;                  /* real precision flag */
    int     asflag;                 /* assignment supression flag */
    int     sflag;                  /* sign flag */
    int     ch;                     /* input character */
    int     temp;                   /* temporary storage */
    int     i;                      /* loop counter */
    int     count;                  /* character count */
    int     width;                  /* maximum field width */
    int     status;                 /* status returned from the read */
    int     valid;                  /* valid real number format */
    int     (*acc)();               /* pointer to accumulate function */
    int     (*neg)();               /* pointer to negate function */
    int     (*asn)();               /* pointer to assign function */
    int     _digit();               /* decode digit function */
    int     _dint();                /* decode integer function */
    int     _dlong();               /* decode long function */
    int     _negint();              /* negate integer function */
    int     _neglong();             /* negate long function */
    int     _aint();                /* assign integer function */
    int     _along();               /* assign long function */
    int     _atoi();                /* convert string to integer */
    int     isspace();              /* whitespace function */
    int     isdigit();              /* digit function */
    STRING  *stods();               /* convert string to dynamic string */

    format = *parms--;              /* format points to format string */
    count = 0;                      /* number of parameters read */
    while (c = *format++) {
        if (isspace(c)) continue;   /* skip white space */
        if (c != '%') {
            while (isspace(ch = (*read)(fp)));
            if (ch == c) continue;
            else return (ch == EOF) ? EOF : count;
        }
        pflag = sflag = asflag = 0;
        if ((*format) == '*') {     /* check for assignment suppression */
            ++asflag;
            ++format;
        }
        acc = _dint;
        neg = _negint;
        asn = _aint;
        width = isdigit(*format) ? _atoi(&format) : -1;
        if (toupper(*format) == 'L') {  /* check for double precision */
            ++pflag;
            ++format;
            acc = _dlong;
            neg = _neglong;
            asn = _along;
        }
        c = *format++;
        switch (toupper(c)) {

            case 'H':                   /* signed decimal */
                    pflag++;
            case 'D':
            case 'U':
                    base = 10;
                    goto decode;

            case 'O':                   /* unsigned octal */
                    base = 8;
                    goto decode;

            case 'X':                   /* unsigned hexadecimal */
                    base = 16;
            decode:
                    for (i=0; i<5; ++i) buffer.string[i] = '\0';
                    while ((ch=(*read)(fp))==' ' || ch == '\t'
                            || ch == '\n');
                    if (ch == EOF) return EOF;
                    if (width && (ch == '+' || ch == '-')) {
                       if (ch == '-') ++sflag;
                       ch = (*read)(fp);
                       --width;
                    }
                    if (width && base == 16 && ch == '0') {
                       temp = (*read)(fp);
                       --width;
                       if (toupper(temp) == 'X' && width) {
                          ch = (*read)(fp);
                          --width;
                       }
                       else {
                          (*ungetc)(temp, fp);
                          ++width;
                       }
                    }
                    if ((value = _digit(ch, base)) == -1) return count;
                    while (width && (value != -1)) {
                       (*acc)(&buffer.integer, value, base);
                       ch = (*read)(fp);
                       --width;
                       value = _digit(ch,base);
                    }
                    (*ungetc)(ch, fp);
                    if (sflag) (*neg)(&buffer.integer);
                    if (!asflag) {
                       (*asn)(&buffer.integer, *parms, pflag);
                       ++count;
                       --parms;
                    }
                    break;

            case 'S':                   /* string */
                    while ((ch=(*read)(fp))==' ' || ch == '\t'
                            || ch == '\n');
                    if (ch == EOF) return EOF;
                    while (width && ch != ' ' && ch != '\t'
                           && ch != '\n' && ch != EOF) {
                       if (!asflag) *(*parms)++ = ch;
                       ch = (*read)(fp);
                       --width;
                       }
                    (*ungetc)(ch, fp);
                    if (!asflag) {
                       *(*parms) = '\0';
                       ++count;
                       --parms;
                    }
                    break;

            case 'C':                   /* character */
                    if ((ch = (*read)(fp)) == EOF) return EOF;
                    else
                       if (!asflag) {
                          *(*parms) = ch;
                          ++count;
                          --parms;
                        }
                    break;

            case 'E':
            case 'F':                   /* floating point */
                    while ((ch=(*read)(fp))==' ' || ch == '\t'
                            || ch == '\n');
                    if (ch == EOF) return EOF;
                    i = 0;
                    valid = 0;
                    if (width && (ch == '+' || ch == '-')) {
                        buffer.string[i++] = ch;
                        ch = (*read)(fp);
                        --width;
                    }
                    while (width && ch >= '0' && ch <= '9') {
                        buffer.string[i++] = ch;
                        ch = (*read)(fp);
                        --width;
                        ++valid;
                    }
                    if (width && ch == '.') {
                       buffer.string[i++] = ch;
                       ch = (*read)(fp);
                       --width;
                       while (width && ch >= '0' && ch <= '9') {
                          buffer.string[i++] = ch;
                          ch = (*read)(fp);
                          --width;
                          ++valid;
                       }
                    }
                    if (width && (ch == 'E' || ch == 'e' || ch == 'D')) {
                       if (!valid) return count;
                       valid = 0;
                       buffer.string[i++] = 'E';
                       ch = (*read)(fp);
                       --width;
                       if (width && (ch == '+' || ch == '-')) {
                          buffer.string[i++] = ch;
                          ch = (*read)(fp);
                          --width;
                       }
                       while (width && isdigit(ch)) {
                          buffer.string[i++] = ch;
                          ch = (*read)(fp);
                          --width;
                          ++valid;
                       }
                    }
                    (*ungetc)(ch, fp);
                    if (!valid) return count;
                    buffer.string[i] = '\0';
                    if (!asflag) {
                        _dreal(buffer.string, *parms, pflag);
                        ++count;
                        --parms;
                    }
                    break;

            case 'Y':               /* dynamic string */
                    while ((ch=(*read)(fp))==' ' || ch == '\t'
                            || ch == '\n');
                    if (ch == EOF) return EOF;
                    i = 0;
                    while (width && ch != ' ' && ch != '\t'
                           && ch != '\n' && ch != EOF) {
                       if (i < 80) buffer.string[i++] = ch;
                       ch = (*read)(fp);
                       --width;
                       }
                    buffer.string[i] = '\0';
                    (*ungetc)(ch,fp);
                    if (!asflag) {
                       ptr = *parms;
                       *ptr = stods(buffer.string);
                       ++count;
                       --parms;
                    }
                    break;

            default :
                    return count;
        }
    }
    return count;
}

_negint(iptr)                       /* negate integer */
int         *iptr;                  /* pointer to integer */
{
    *iptr = -*iptr;
}

_aint(iptr1, iptr2, pflag)         /* assign integer */
int     *iptr1;                    /* pointer to fp */
int     *iptr2;                    /* pointer to destination */
int     pflag;                     /* short integer flag */
{
    short *sptr;
    if (pflag) {
        sptr = iptr2;
        *sptr = *iptr1;
    }
    else *iptr2 = *iptr1;
}

_neglong(lptr)                      /* negate long */
long        *lptr;                  /* pointer to long integer */
{
    *lptr = -*lptr;
}

_along(lptr1, lptr2)               /* assign long */
long    *lptr1;                    /* pointer to fp */
long    *lptr2;                    /* pointer to destination */
{
    *lptr2 = *lptr1;
}

_digit(ch, base)                   /* decode ch to binary */
int     ch;                        /* character to decode */
int     base;                      /* number base */
{
    if (ch >= '0' && ch <= '9') ch -= 48;
    else
       if  (isalpha(ch = toupper(ch))) ch -= 55;
       else
          return -1;
    if (ch < base) return ch;
    else return -1;
}

_dint(iptr, digit, base)                    /* decode an integer */
int      *iptr;                             /* pointer to integer */
int      digit;                             /* digit to add to integer */
int      base;                              /* number base */
{
    *iptr = *iptr * base + digit;
}

_dlong(lptr, digit, base)           /* decode a long */
long    *lptr;                      /* pointer to long */
int     digit;                      /* digit to add to long */
int     base;                       /* number base */
{
    *lptr = *lptr * base + digit;
}

_dreal(s, fptr, pflag)              /* decode a real */
char    *s;                         /* pointer to decode string */
float   *fptr;                      /* pointer to float */
int     pflag;                      /* precision flag */
{
    double  atof();                 /* string to double function */
    double  *dptr;                  /* pointer to double */
    if (pflag) {
       dptr = fptr;
       *dptr = atof(s);
    }
    else
        *fptr = (float) atof(s);
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
    --(*s);
    return c;
}

