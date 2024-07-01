/*
 * math.h
 *
 * constant definitions and external subroutine declarations for the math
 * subroutine library.
 *
 * Copyright (C) Microsoft Corporation, 1984
 */

/* definition of exception struct - this struct is passed to the matherr
 * routine when a floating point exception is detected 
 */

struct exception {
	int type;			/* exception type - see below */
	char *name;			/* name of function where error occured */
	double arg1;		/* first argument to function */
	double arg2;		/* second argument (if any) to function */
	double retval;		/* value to be returned by function */
	} ;

/* definition of a complex struct to be used by those who use cabs and
 * want type checking on their argument
 */

struct complex {
	double x,y;			/* real and imaginary parts */
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

/* definition of HUGE - a value return in case of error by a number of
 * the floating point math routines
 */

extern double HUGE;

/* function declarations for those who want strong type checking
 * on arguments to library function calls
 */

#ifdef LINT_ARGS		/* arg. checking enabled */

double acos(double);
double asin(double);
double atan(double);
double atan2(double, double);
double atof(char *);
double cabs(struct complex);
double ceil(double);
double cos(double);
double cosh(double);
double exp(double);
double fabs(double);
double floor(double);
double fmod(double, double);
double frexp(double, int *);
double hypot(double, double);
double j0(double);
double j1(double);
double jn(int, double);
double ldexp(double, double);
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

#else					/* arg. checking disabled, define return type */

extern double acos(), asin(), atan(), atan2();
extern double cos(), sin(), tan();
extern double cosh(), sinh(), tanh();
extern double atof();
extern double j0(), j1(), jn(), y0(), y1(), yn();
extern double ceil(), fabs(), floor(), fmod();
extern double exp(), log(), log10(), pow(), sqrt();
extern double frexp(), ldexp(), modf();
extern double hypot(), cabs();

#endif	/* LINT_ARGS */
