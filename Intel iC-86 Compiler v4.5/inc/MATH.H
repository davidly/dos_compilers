/* math.h - math and trig definitions
 * $Version: 1.25 $
 * Copyright (c) 1984,85,86,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
 * Copyright (c) 1988,89, 90 Intel Corporation, ALL RIGHTS RESERVED.
 */

#ifndef _mathh
#define _mathh
/*lint -library */

#pragma fixedparams("acos",  "asin",  "atan",  "atan2",   "ceil")
#pragma fixedparams("cos",   "cosh",  "exp",   "fabs",    "floor")
#pragma fixedparams("fmod",  "frexp", "j0",    "j1",      "jn")
#pragma fixedparams("ldexp", "log",   "log10", "matherr", "modf")
#pragma fixedparams("pow",   "sin",   "sinh",  "sqrt",    "square")
#pragma fixedparams("tan",   "tanh",  "y0",    "y1",      "yn")


#ifndef HUGE_VAL
#define HUGE_VAL    1.7976931348623157e+308   /* DBL_MAX */
#endif

/*
 * Exception types for matherr():
 */
#define DOMAIN      1                   /* Argument domain error     */
#define SING        2                   /* Singularity error         */
#define OVERFLOW    3                   /* Function overflow error   */
#define UNDERFLOW   4                   /* Function underflow error  */
#define TLOSS       5                   /* Total loss of precision   */
#define PLOSS       6                   /* Partial loss of precision */

/*
 * Function prototypes:
 */
double acos(double);
double asin(double);
double atan(double);
double atan2(double, double);
double cos(double);
double sin(double);
double tan(double);
double cosh(double);
double sinh(double);
double tanh(double);
double exp(double);
double frexp(double, int *);
double ldexp(double, int);
double log(double);
double log10(double);
double modf(double, double *);
double pow(double, double);
double sqrt(double);
double ceil(double);
double fabs(double);
double floor(double);
double fmod(double, double);

/* non-ANSI declarations */
#pragma align (exception)
struct exception {
    int    type;
    char  *name;
    double arg1;
    double arg2;
    double retval;
};

#pragma align (complex)
struct complex {
    double x;
    double y;
};

double j0(double);
double j1(double);
double jn(int, double);
int    matherr(struct exception *);	/* this is just a stub */
double square(double);
double y0(double);
double y1(double);
double yn(int, double);


/*
 *  Compiler built-in functions:
 */
#ifndef _mathh_builtin
#define _mathh_builtin

#pragma _builtin_("_fabs_"==53)
double _fabs_(double);
#define fabs(x) _fabs_(x)

#pragma _builtin_("_sqrt_"==54)
double _sqrt_(double);
#define sqrt(x) _sqrt_(x)

#if _ARCHITECTURE_ == 386 ||  _ARCHITECTURE_ == 486

/* The following builtins are only valid in a 387/486 environment */

#pragma _builtin_("_log_"==55)
double _log_(double);
#define log(x) _log_(x)

#pragma _builtin_("_log10_"==56)
double _log10_(double);
#define log10(x) _log10_(x)

#pragma _builtin_("_cos_"==57)
double _cos_(double);
#define cos(x) _cos_(x)

#pragma _builtin_("_sin_"==58)
double _sin_(double);
#define sin(x) _sin_(x)

#pragma _builtin_("_tan_"==59)
double _tan_(double);
#define tan(x) _tan_(x)

#pragma _builtin_("_acos_"==60)
double _acos_(double);
#define acos(x) _acos_(x)

#pragma _builtin_("_asin_"==61)
double _asin_(double);
#define asin(x) _asin_(x)

#pragma _builtin_("_atan2_"==62)
double _atan2_(double,double);
#define atan2(x,y) _atan2_(x,y)

#pragma _builtin_("_atan_"==63)
double _atan_(double);
#define atan(x) _atan_(x)

#endif /* _ARCHITECTURE_  */

#endif /* _mathh_builtin */

#endif /* _mathh */
