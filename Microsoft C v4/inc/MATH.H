/*
 * math.h
 *
 * constant definitions and external subroutine declarations for the math
 * subroutine library.
 *
 * Copyright (C) Microsoft Corporation, 1984, 1985, 1986
 */

/* definition of exception struct - this struct is passed to the matherr
 * routine when a floating point exception is detected
 */

struct exception {
	int type;		/* exception type - see below */
	char *name;		/* name of function where error occured */
	double arg1;		/* first argument to function */
	double arg2;		/* second argument (if any) to function */
	double retval;		/* value to be returned by function */
	} ;

/* definition of a complex struct to be used by those who use cabs and
 * want type checking on their argument
 */

struct complex {
	double x,y;		/* real and imaginary parts */
	} ;

/* Constant definitions for the exception type passed in the exception
 * struct.
 */

#define DOMAIN		1	/* argument domain error */
#define SING		2	/* argument singularity */
#define OVERFLOW	3	/* overflow range error */
#define UNDERFLOW	4	/* underflow range error */
#define TLOSS		5	/* total loss of precision */
#define PLOSS		6	/* partial loss of precision */

#define EDOM		33
#define ERANGE		34

/* definition of HUGE - a value return in case of error by a number of
 * the floating point math routines
 */

extern double HUGE;
#define HUGE_VAL HUGE

/* function declarations for those who want strong type checking
 * on arguments to library function calls
 */

#ifdef LINT_ARGS	/* argument checking enabled */

#ifndef NO_EXT_KEYS	/* extended keywords are enabled */
int cdecl abs(int);
double cdecl acos(double);
double cdecl asin(double);
double cdecl atan(double);
double cdecl atan2(double, double);
double cdecl atof(char *);
double cdecl cabs(struct complex);
double cdecl ceil(double);
double cdecl cos(double);
double cdecl cosh(double);
int cdecl dieeetomsbin(double *, double *);
int cdecl dmsbintoieee(double *, double *);
double cdecl exp(double);
double cdecl fabs(double);
int cdecl fieeetomsbin(float *, float *);
double cdecl floor(double);
double cdecl fmod(double, double);
int cdecl fmsbintoieee(float *, float *);
double cdecl frexp(double, int *);
double cdecl hypot(double, double);
double cdecl j0(double);
double cdecl j1(double);
double cdecl jn(int, double);
long cdecl labs(long);
double cdecl ldexp(double, int);
double cdecl log(double);
double cdecl log10(double);
int cdecl matherr(struct exception *);
double cdecl modf(double, double *);
double cdecl pow(double, double);
double cdecl sin(double);
double cdecl sinh(double);
double cdecl sqrt(double);
double cdecl tan(double);
double cdecl tanh(double);
double cdecl y0(double);
double cdecl y1(double);
double cdecl yn(int, double);
#else			/* extended keywords not enabled */
int abs(int);
double acos(double);
double asin(double);
double atan(double);
double atan2(double, double);
double atof(char *);
double cabs(struct complex);
double ceil(double);
double cos(double);
double cosh(double);
int dieeetomsbin(double *, double *);
int dmsbintoieee(double *, double *);
double exp(double);
double fabs(double);
int fieeetomsbin(float *, float *);
double floor(double);
double fmod(double, double);
int fmsbintoieee(float *, float *);
double frexp(double, int *);
double hypot(double, double);
double j0(double);
double j1(double);
double jn(int, double);
long labs(long);
double ldexp(double, int);
double log(double);
double log10(double);
int matherr(struct exception *);
double modf(double, double *);
double pow(double, double);
double sin(double);
double sinh(double);
double sqrt(double);
double tan(double);
double tanh(double);
double y0(double);
double y1(double);
double yn(int, double);
#endif	/* NO_EXT_KEYS */

#else			/* argument checking not enabled */

#ifndef NO_EXT_KEYS	/* extended keywords are enabled */
int cdecl abs();
double cdecl acos();
double cdecl asin();
double cdecl atan();
double cdecl atan2();
double cdecl atof();
double cdecl cabs();
double cdecl ceil();
double cdecl cos();
double cdecl cosh();
int cdecl dieeetomsbin();
int cdecl dmsbintoieee();
double cdecl exp();
double cdecl fabs();
int cdecl fieeetomsbin();
double cdecl floor();
double cdecl fmod();
int cdecl fmsbintoieee();
double cdecl frexp();
double cdecl hypot();
double cdecl j0();
double cdecl j1();
double cdecl jn();
long cdecl labs();
double cdecl ldexp();
double cdecl log();
double cdecl log10();
int cdecl matherr();
double cdecl modf();
double cdecl pow();
double cdecl sin();
double cdecl sinh();
double cdecl sqrt();
double cdecl tan();
double cdecl tanh();
double cdecl y0();
double cdecl y1();
double cdecl yn();
#else			/* extended keywords not enabled */
double acos(), asin(), atan(), atan2();
double cos(), sin(), tan();
double cosh(), sinh(), tanh();
double atof();
double j0(), j1(), jn(), y0(), y1(), yn();
double ceil(), fabs(), floor(), fmod();
double exp(), log(), log10(), pow(), sqrt();
double frexp(), ldexp(), modf();
double hypot(), cabs();
long labs();
#endif	/* NO_EXT_KEYS */

#endif	/* LINT_ARGS */
