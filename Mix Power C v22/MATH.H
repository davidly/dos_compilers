/*$no list*//*$no trace <<< math.h >>> */
/*   Copyright (c) Mix Software 1988   */

extern double HUGE;
#define HUGE_VAL HUGE

#define EDOM      33
#define ERANGE    34

double acos(double x);
double asin(double x);
double atan(double x);
double atan2(double y, double x);
double ceil(double x);
double cos(double x);
double cosh(double x);
double exp(double x);
double fabs(double x);
double floor(double x);
double fmod(double x, double y);
double frexp(double x, int *exp);
double hypot(double x, double y);
double ldexp(double x, int exp);
double log(double x);
double log10(double x);
double modf(double x, double *wholepart);
double pow(double x, double y);
double sin(double x);
double sinh(double x);
double sqrt(double x);
double tan(double x);
double tanh(double x);

#if !defined(ANSI)
extern int errno;
extern char _mathmsg;

#if !Defined(struct complex)
struct complex {
    double x;
    double y;
};
#endif

#if !Defined(struct exception)
struct exception {
    int type;      /* type of exception */
    char *name;    /* name of function */
    double arg1;   /* first argument to function */
    double arg2;   /* second argument to function */
    double retval; /* value to be returned if error is not fatal */
};
#endif

/* exception types */

#define DOMAIN    1   /* not in domain of function */
#define SING      2   /* singularity (function not defined) */
#define OVERFLOW  3   /* result too large */
#define UNDERFLOW 4   /* result too small */
#define TLOSS     5   /* total loss of precision */
#define PLOSS     6   /* partial loss of precision */

double cabs(struct complex z);
double j0(double x);
double j1(double x);
double jn(int n, double x);
int    matherr(struct exception *err);
double poly(double x, int degree, double coeff[]);
double pow10(int n);
double y0(double x);
double y1(double x);
double yn(int n, double x);
#endif /* ANSI */

/*$list*//*$trace       <<< math.h >>> */
