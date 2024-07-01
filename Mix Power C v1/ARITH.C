
/* Arithmetic functions */
/*   Copyright (c) Mix Software 1988    */

abs(i)
int i;
{
   return i < 0 ? -i : i;
}

/* ------------------------------------------------------------ */

double cabs(z)
struct complex z;
{     /* complex absolute value */
   double sqrt();
   return sqrt(z.x*z.x + z.y*z.y);
}

/* ------------------------------------------------------------ */

double acos(x)
double x;
{     /* inverse cosine */
   double asin();
   double value;
   static double piover2 = 1.5707963267948966;
   if (x > 1.0 || x < -1.0) return _domerr("acos",x,x);
   value = asin(x);
   return piover2 - value;
}

/* ------------------------------------------------------------ */

double asin(x)
double x;
{     /* inverse sine */
   double _domerr(), fabs(), atan(), sqrt();
   static double piover2 = 1.5707963267948966;
   double absx = fabs(x);
   double value;
   if (x > 1.0 || x < -1.0) return _domerr("asin",x,x);
   if (absx == 0.0) value = 0.0;
   else value = piover2 - atan(sqrt(1-x*x)/absx);
   if (x < 0) return -value; else return value;
}

/* ------------------------------------------------------------ */

double atan2(x,y)
   double x,y;
{
   /* return arc tangent of y/x
      atan2 is useful when converting rectangular to polar coordinates
      */
   extern double (far *$0DATN)();
   static double piover2 = 1.5707963267948966;
   static double pi = 3.141592653589793;
   double atan(), _domerr();
   double value;
   if (x == 0.0) {
      if (y == 0.0) return _domerr("atan2",x,y);
      if (y < 0.0) return pi; else return 0.0;
      }
   value = $0DATN(y/x);
   if (x < 0.0) return -value-piover2;
   return piover2 - value;
}

/* ------------------------------------------------------------ */

double atan(x)
double x;
{     /* inverse tangent */
   extern double (far *$0DATN)();
   return $0DATN(x);
}

/* ------------------------------------------------------------ */

double ceil(x)
double x;
{
    extern double (far *$0DFIXR)();
    double r;
    r = $0DFIXR(x);
    if (r == x) return r;
    return r + 1.0;
}

/* ------------------------------------------------------------ */

double tan(x)
   double x;
{
   double cos(), sin(), _domerr();
   double c;
   c = cos(x);
   if (c == 0.0) return _domerr("tan",x,x);
   return sin(x)/c;
   } /* tan */

/* ------------------------------------------------------------ */

double cos(x)
   double x;
{
   extern double (far *$0DCOS)();
   double _tloss(), _ploss(), fabs();
   static char name[] = "cos";
   double a;
   a = fabs(x);
   if (a > 6.283185307179586e10) {
      if (a > 6.283185307179586e16)  return _tloss(name,x,x);
      _ploss(name,x,x);
      return $0DCOS(x);
      }
   return $0DCOS(x);
} /* cos */

/* ------------------------------------------------------------ */

double cosh(x)
   double x;
{
   extern double exp();
   return (exp(x) + exp(-x)) / 2.0;
} /* cosh */

/* ------------------------------------------------------------ */

double sinh(x)
   double x;
{
   extern double exp();
   return (exp(x) - exp(-x)) / 2.0;
} /* sinh */

/* ------------------------------------------------------------ */

double tanh(x)
   double x;
{
   extern double exp();
   double xplus, xminus;
   xplus = exp(x);
   xminus = exp(-x);
   return (xplus - xminus) / (xplus + xminus);
} /* tanh */

/* ------------------------------------------------------------ */

double exp(x)
   double x;
{
   extern double (far *$0DEXP)();
   double _rangerr();
   extern double _EXPMAX, _EXPMIN, HUGE;
   static char name[] = "exp";
   if (x > _EXPMAX) {
      _rangerr(name,x,x);
      return HUGE;
      }
   if (x < _EXPMIN) return _rangerr(name,x,x);
   return $0DEXP(x);
} /* exp */

/* ------------------------------------------------------------ */

double floor(x)
double x;
{
    extern double (far *$0DFIXR)();
    return $0DFIXR(x);
}

/* ------------------------------------------------------------ */

double fmod(x, y)
double x,y;
{
   extern double (far *$0DFIXR)();
   if (y == 0.0) return _domerr("fmod",x,y);
   return x - y*$0DFIXR(x/y);
}

/* ------------------------------------------------------------ */

double hypot(x, y)
double x,y;
{
    double sqrt();
    return (sqrt(x*x + y*y));
}

/* ------------------------------------------------------------ */

double log10(x)
double x;
{
    double log();
    return log(x) / 2.3025850929940457;
}

/* ------------------------------------------------------------ */

double log(x)
   double x;
{
   extern double (far *$0DLN)();
   double _domerr(), _singerr();
   extern double HUGE;
   static char name[] = "log";
   if (x <= 0.0) {
      if (x == 0.0) { _singerr(name,x,x); return -HUGE; }
      _domerr(name,x,x); return -HUGE;
      }
   return $0DLN(x);
} /* log */

/* ------------------------------------------------------------ */

double pow(x,y)
double x;
double y;
{
   extern double (far *$0DXTOY)();
   static char name[] = "pow";
   double _domerr(), modf();
   double intval;
   if (x > 0.0) return $0DXTOY(x,y);
   if (x == 0.0) {
      if (y >= 0.0) return 0.0;
      return _domerr(name,x,y);
      }
   if (modf(x,&intval) != 0.0) return _domerr(name,x,y);
   if (modf(intval/2.0,&intval) != 0) return -($0DXTOY(x,y));
   return $0DXTOY(x,y);
}  /* pow */

/* ------------------------------------------------------------ */

double modf(x, intptr)
double x;
double *intptr;
{
   extern double (far *$0DFIXR)();
   *intptr = $0DFIXR(x);
   return x - (*intptr);
}  /* modf */

/* ------------------------------------------------------------ */

double sin(x)
   double x;
{
   extern double (far *$0DSIN)();
   double _tloss(), _ploss(), fabs();
   static char name[] = "sin";
   double a;
   a = fabs(x);
   if (a > 6.283185307179586e10) {
      if (a > 6.283185307179586e16)  return _tloss(name,x,x);
      _ploss(name,x,x);
      return $0DSIN(x);
      }
   return $0DSIN(x);
} /* sin */

/* ------------------------------------------------------------ */

double sqrt(x)
   double x;
{
   extern double (far *$0DSQRT)();
   double _domerr();
   if (x < 0.0) return _domerr("sqrt",x,x);
   return $0DSQRT(x);
} /* sqrt */

double poly(x, n, c)
   double x;
   int n;         /* highest power of x in polynomial */
   double c[];    /* array of coefficients (n+1 elements) */
{
   double *coef;
   double value;
   coef = &c[n-1];
   value = c[n];
   while (n--) {
      value = value*x + *coef;
      --coef;
      }
   return value;
   }

/* ------------------------------------------------------------ */
/*    error handling for math errors */

double _domerr(name,arg1,arg2)
   char *name;
   double arg1,arg2;
{     /* indicate a domain error
         if matherr returns 0, the answer is 0 */
   extern int errno;
   extern char $$ARTERM;
   extern char _mathmsg;
   struct exception e;
   e.type = DOMAIN;
   e.name = name;
   e.arg1 = arg1;
   e.arg2 = arg2;
   if (matherr(&e)) return e.retval;
   else {
      errno = EDOM;
      if (_mathmsg) {
         fprintf(stderr,"Domain error in %s() at %g, %g\n",name,arg1,arg2);
         if ($$ARTERM) abort();
         }
      return 0.0;
      }
   }  /* _domerr */

/* ------------------------------------------------------------ */

double _singerr(name,arg1,arg2)
   char *name;
   double arg1,arg2;
{     /* indicate a singularity
         if matherr returns 0, the answer is HUGE */
   extern int errno;
   extern char $$ARTERM;
   extern char _mathmsg;
   extern double HUGE;
   struct exception e;
   e.type = SING;
   e.name = name;
   e.arg1 = arg1;
   e.arg2 = arg2;
   if (matherr(&e)) return e.retval;
   else {
      errno = EDOM;
      if (_mathmsg) {
         fprintf(stderr,"Singularity error in %s() at %g, %g\n",name,arg1,arg2);
         if ($$ARTERM) abort();
         }
      return HUGE;
      }
   }  /* _domerr */

/* ------------------------------------------------------------ */

double _tloss(name,arg1,arg2)
   char *name;
   double arg1,arg2;
{     /* indicate total loss of significance
         if matherr returns 0, the answer is 0 */
   extern int errno;
   extern char $$ARTERM;
   extern char _mathmsg;
   struct exception e;
   e.type = TLOSS;
   e.name = name;
   e.arg1 = arg1;
   e.arg2 = arg2;
   if (matherr(&e)) return e.retval;
   else {
      errno = ERANGE;
      if (_mathmsg) {
         fprintf(stderr,"Total loss of signifcance in %s() at %g, %g\n",name,arg1,arg2);
         if ($$ARTERM) abort();
         }
      return 0.0;
      }
   }  /* _tloss */

/* ------------------------------------------------------------ */

double _ploss(name,arg1,arg2)
   char *name;
   double arg1,arg2;
{     /* indicate partial loss of significance
         if matherr returns 0, the answer is 0 */
   extern int errno;
   struct exception e;
   e.type = PLOSS;
   e.name = name;
   e.arg1 = arg1;
   e.arg2 = arg2;
   if (matherr(&e)) return e.retval;
   return 0.0;
   }  /* _ploss */

/* ------------------------------------------------------------ */

double _rangerr(name,arg1,arg2)
   char *name;
   double arg1,arg2;
{     /* indicate a range error - result of function
         is too large or too small to be represented as a double */
   extern int errno;
   extern char $$ARTERM;
   extern char _mathmsg;
   struct exception e;
   e.type = OVERFLOW;
   e.name = name;
   e.arg1 = arg1;
   e.arg2 = arg2;
   if (matherr(&e)) return e.retval;
   else {
      errno = ERANGE;
      if (_mathmsg) {
         fprintf(stderr,"Argument out of range in %s() at %g, %g\n",name,arg1,arg2);
         if ($$ARTERM) abort();
         }
      return 0.0;
      }
   }  /* _rangerr */

/* ------------------------------------------------------------ */

int matherr(x)
struct exception *x;
{
   return 0;
   }

/* ------------------------------------------------------------ */

void _fpreset()
{
   _clear87();
   }

/* ------------------------------------------------------------ */

unsigned int _clear87()
{
    extern unsigned int (far *$0clr87)();
    return $0clr87();
}

/* ------------------------------------------------------------ */

unsigned int _control87(new, mask)
   unsigned int new;
   unsigned int mask;
{
    extern unsigned int (far *$0ctl87)();
    return $0ctl87(new,mask);
}

/* ------------------------------------------------------------ */

unsigned int _status87()
{
    extern unsigned int (far *$0sta87)();
    return $0sta87();
}

