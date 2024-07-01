
/* Numeric conversions. */
/*   Copyright (c) Mix Software 1988    */

/* ------------------------------------------------------------ */
/*  convert a string to an integer */

atoi(s)                          /* decode an integer */
char    *s;                      /* pointer to integer string */
{
    int     sflag = 1, value = 0;
    while (isspace(*s)) ++s;
    if (*s == '+' || *s == '-')
        if (*s++ == '-') sflag = -1;
    while (*s > 47 && *s < 58) value = 10 * value + (*s++ - 48);
    return value * sflag;
}

/* ------------------------------------------------------------ */
/*  convert a string to a long integer */

long atol(s)                     /* decode a long integer */
char    *s;                      /* pointer to integer string */
{
    int     sflag = 1;
    long    value = 0, base = 10;
    while (isspace(*s)) ++s;
    if (*s == '+' || *s == '-')
        if (*s++ == '-') sflag = -1;
    while (*s > 47 && *s < 58) value = base * value + (*s++ - 48);
    return value * sflag;
}

/* ------------------------------------------------------------ */
/*  convert a string to a long integer */

long strtol(nptr, endptr, base)  /* convert a string to a long */
char    *nptr;                   /* pointer to string */
char    **endptr;
int base;
{
    int     sflag = 0;
    long    value = 0;
    long strtoul();
    int c, v;
    while (isspace(*nptr)) ++nptr;  /* skip white space */
    if (*nptr == '+' || *nptr == '-')
        if (*nptr++ == '-') sflag = -1;
   value = strtoul(nptr, endptr, base);
   if (sflag) return -value; else return value;
}

/* ------------------------------------------------------------ */
/*  convert a string to an unsigned long integer */

long strtoul(nptr, endptr, base)  /* convert a string to a long */
char    *nptr;                   /* pointer to string */
char    **endptr;
int base;
{
    unsigned long value = 0;
    int c, v;
    while (isspace(*nptr)) ++nptr;  /* skip white space */
    if (*nptr == '0') {
       if (toupper(c=*++nptr) == 'X') {
         base = 16;
         ++nptr;
         }
      else {
         if (base == 0) {
            if (c >= '1' && c <= '7') base = 8;
            else base = 10;
            }
         }
      }
    else if (base == 0) base = 10;
    do {
      if (isalnum(c = *nptr++)) {
         if (isdigit(c)) v = c - 48; else v = toupper(c) - 55;
         if (v < base) value = base * value + v; else v = -1;
         }
      else v = -1;
      }
      while (v >= 0);
   if (endptr) *endptr = nptr-1;
   return value;
}

/* ------------------------------------------------------------ */
/*  convert a string to a double */

double strtod(nptr, endptr)
   char *nptr;
   char **endptr;
{
   char bufr[50];
   char *p, *q;
   int  c;
   double atof();
   p = bufr;
   q = p + sizeof(bufr) - 4;
   while (isspace(*nptr)) ++nptr;
   if (*nptr == '+' || *nptr == '-') *p++ = *nptr++;
   while (isdigit(*nptr) && (p < q)) *p++ = *nptr++;
   if (*nptr == '.') {
      *p++ = *nptr++;
      while (isdigit(*nptr) && (p < q)) *p++ = *nptr++;
      }
   if ((c = toupper(*nptr)) == 'D' || c == 'E') {
      *p++ = *nptr++;
      if (*nptr == '+' || *nptr == '-') *p++ = *nptr++;
      while (isdigit(*nptr) && (p < q)) *p++ = *nptr++;
      }
   *p = 0;
   if (endptr != 0) *endptr = nptr;
   return atof(bufr);
}

/* ------------------------------------------------------------ */
/*  convert an integer to a string */

char *itoa(value, string, radix)
int     value;
char    *string;
int     radix;
{
    char *ptr;
    char *utoa();
    int flag = 0;
    if (radix == 10) {
       if (value < 0) {
          if (value == 0x8000) return strcpy(string, "-32768");
          flag = '-';
          value = -value;
          }
       ptr = string;
       do {
          *(ptr++) = value  % 10 + 48;
          } while ((value /= 10) != 0);
       *ptr++ = flag;
       *ptr = 0;
       return strrev(string);
       }
    else return utoa(value,string,radix);
}

/* ------------------------------------------------------------ */
/*  convert an unsigned integer to a string */

utoa(value, string, radix)
unsigned value;
char    *string;
int     radix;
{
    char *ptr, c;
    extern int _hexcaseA;
    ptr = string;
    do {
       c = value % radix;
       if (c > 9) c += _hexcaseA; else c += 48;
       *(ptr++) = c;
    } while ((value /= radix) != 0);
    *ptr = '\0';
    return strrev(string);
}

/* ------------------------------------------------------------ */
/*  convert a long integer to a string */

char *ltoa(value, string, radix)
long    value;
char    *string;
int     radix;
{
    char *ptr;
    char *ultoa();
    int flag = 0;
    if (radix == 10) {
       if (value < 0) {
          if (value == -2147483648) return strcpy(string, "-2147483648");
          flag = '-';
          value = -value;
          }
       ptr = string;
       do {
          *(ptr++) = value  % 10 + 48;
          } while ((value /= 10) != 0);
       *ptr++ = flag;
       *ptr = 0;
       return strrev(string);
       }
    else return ultoa(value,string,radix);
}

/* ------------------------------------------------------------ */
/*  convert an unsigned long integer to a string */

ultoa(value, string, radix)
unsigned long  value;
char    *string;
int     radix;
{
    char *ptr, c;
    extern int _hexcaseA;
    ptr = string;
    do {
       c = value % radix;
       if (c > 9) c += _hexcaseA; else c += 48;
       *(ptr++) = c;
    } while ((value /= radix) != 0);
    *ptr = '\0';
    return strrev(string);
}

_atoi(ptr)                          /* decode an integer */
char    **ptr;                      /* pointer to addr of 1st digit */
{
    int     n = 0;
    while (*(*ptr) > 47 && *(*ptr) < 58) n = 10 * n + *(*ptr)++ - 48;
    return n;
}

int _hexcaseA = 'a'-10;       /* character value of the digit 10 */

