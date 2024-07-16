/***
*math.h - definitions and declarations for math library
*
*	Copyright (c) 1985-1990, Microsoft Corporation.  All rights reserved.
*
*Purpose:
*	This file contains constant definitions and external subroutine
*	declarations for the math subroutine library.
*	[ANSI/System V]
*
****/

#if defined(_DLL) && !defined(_MT)
#error Cannot define _DLL without _MT
#endif

#ifdef _MT
#define _FAR_ _far
#else
#define _FAR_
#endif


/* definition of exception struct - this struct is passed to the matherr
 * routine when a floating point exception is detected
 */

#ifndef _EXCEPTION_DEFINED
struct exception {
	int type;		/* exception type - see below */
	char _FAR_ *name;	/* name of function where error occured */
	double arg1;		/* first argument to function */
	double arg2;		/* second argument (if any) to function */
	double retval;		/* value to be returned by function */
	} ;
#define _EXCEPTION_DEFINED
#endif


/* definition of a complex struct to be used by those who use cabs and
 * want type checking on their argument
 */

#ifndef _COMPLEX_DEFINED
struct complex {
	double x,y;	/* real and imaginary parts */
	} ;
#define _COMPLEX_DEFINED
#endif


/* Constant definitions for the exception type passed in the exception struct
 */

#define DOMAIN		1	/* argument domain error */
#define SING		2	/* argument singularity */
#define OVERFLOW	3	/* overflow range error */
#define UNDERFLOW	4	/* underflow range error */
#define TLOSS		5	/* total loss of precision */
#define PLOSS		6	/* partial loss of precision */

#define EDOM		33
#define ERANGE		34


/* definitions of HUGE and HUGE_VAL - respectively the XENIX and ANSI names
 * for a value returned in case of error by a number of the floating point
 * math routines
 */

#ifndef _DLL
extern double _near _cdecl HUGE;
#define HUGE_VAL HUGE

#else	/* _DLL */
extern double _FAR_ _cdecl HUGE;
#define HUGE_VAL HUGE

#endif	/* _DLL */


/* function prototypes */

#ifdef	_MT     /* function prototypes for _MT version */
int	_FAR_ _cdecl  abs(int);
double	_FAR_ _pascal acos(double);
double	_FAR_ _pascal asin(double);
double	_FAR_ _pascal atan(double);
double	_FAR_ _pascal atan2(double, double);
double	_FAR_ _pascal atof(const char _FAR_ *);
double	_FAR_ _pascal cabs(struct complex);
double	_FAR_ _pascal ceil(double);
double	_FAR_ _pascal cos(double);
double	_FAR_ _pascal cosh(double);
int	_FAR_ _cdecl  dieeetomsbin(double _FAR_ *, double _FAR_ *);
int	_FAR_ _cdecl  dmsbintoieee(double _FAR_ *, double _FAR_ *);
double	_FAR_ _pascal exp(double);
double	_FAR_ _pascal fabs(double);
int	_FAR_ _cdecl  fieeetomsbin(float _FAR_ *, float _FAR_ *);
double	_FAR_ _pascal floor(double);
double	_FAR_ _pascal fmod(double, double);
int	_FAR_ _cdecl  fmsbintoieee(float _FAR_ *, float _FAR_ *);
double	_FAR_ _pascal frexp(double, int _FAR_ *);
double	_FAR_ _pascal hypot(double, double);
double	_FAR_ _pascal j0(double);
double	_FAR_ _pascal j1(double);
double	_FAR_ _pascal jn(int, double);
long	_FAR_ _cdecl  labs(long);
double	_FAR_ _pascal ldexp(double, int);
double	_FAR_ _pascal log(double);
double	_FAR_ _pascal log10(double);
int	_FAR_ _cdecl  matherr(struct exception _FAR_ *);
double	_FAR_ _pascal modf(double, double _FAR_ *);
double	_FAR_ _pascal pow(double, double);
double	_FAR_ _pascal sin(double);
double	_FAR_ _pascal sinh(double);
double	_FAR_ _pascal sqrt(double);
double	_FAR_ _pascal tan(double);
double	_FAR_ _pascal tanh(double);
double	_FAR_ _pascal y0(double);
double	_FAR_ _pascal y1(double);
double	_FAR_ _pascal yn(int, double);

#else		/* function prototypes for non _MT version */
int	_FAR_ _cdecl abs(int);
double	_FAR_ _cdecl acos(double);
double	_FAR_ _cdecl asin(double);
double	_FAR_ _cdecl atan(double);
double	_FAR_ _cdecl atan2(double, double);
double	_FAR_ _cdecl atof(const char _FAR_ *);
double	_FAR_ _cdecl cabs(struct complex);
double	_FAR_ _cdecl ceil(double);
double	_FAR_ _cdecl cos(double);
double	_FAR_ _cdecl cosh(double);
int	_FAR_ _cdecl dieeetomsbin(double _FAR_ *, double _FAR_ *);
int	_FAR_ _cdecl dmsbintoieee(double _FAR_ *, double _FAR_ *);
double	_FAR_ _cdecl exp(double);
double	_FAR_ _cdecl fabs(double);
int	_FAR_ _cdecl fieeetomsbin(float _FAR_ *, float _FAR_ *);
double	_FAR_ _cdecl floor(double);
double	_FAR_ _cdecl fmod(double, double);
int	_FAR_ _cdecl fmsbintoieee(float _FAR_ *, float _FAR_ *);
double	_FAR_ _cdecl frexp(double, int _FAR_ *);
double	_FAR_ _cdecl hypot(double, double);
double	_FAR_ _cdecl j0(double);
double	_FAR_ _cdecl j1(double);
double	_FAR_ _cdecl jn(int, double);
long	_FAR_ _cdecl labs(long);
double	_FAR_ _cdecl ldexp(double, int);
double	_FAR_ _cdecl log(double);
double	_FAR_ _cdecl log10(double);
int	_FAR_ _cdecl matherr(struct exception _FAR_ *);
double	_FAR_ _cdecl modf(double, double _FAR_ *);
double	_FAR_ _cdecl pow(double, double);
double	_FAR_ _cdecl sin(double);
double	_FAR_ _cdecl sinh(double);
double	_FAR_ _cdecl sqrt(double);
double	_FAR_ _cdecl tan(double);
double	_FAR_ _cdecl tanh(double);
double	_FAR_ _cdecl y0(double);
double	_FAR_ _cdecl y1(double);
double	_FAR_ _cdecl yn(int, double);
#endif


/* definition of _exceptionl struct - this struct is passed to the _matherrl
 * routine when a floating point exception is detected in a long double routine
 */

#ifndef _LD_EXCEPTION_DEFINED
struct _exceptionl {
	int type;		/* exception type - see below */
	char _FAR_ *name;	/* name of function where error occured */
	long double arg1;	/* first argument to function */
	long double arg2;	/* second argument (if any) to function */
	long double retval;	/* value to be returned by function */
	} ;
#define _LD_EXCEPTION_DEFINED
#endif


/* definition of a _complexl struct to be used by those who use _cabsl and
 * want type checking on their argument
 */

#ifndef _LD_COMPLEX_DEFINED
struct _complexl {
	long double x,y;    /* real and imaginary parts */
	} ;
#define _LD_COMPLEX_DEFINED
#endif


#ifndef _DLL
extern long double _near _cdecl _LHUGE;
#define _LHUGE_VAL _LHUGE

#else	/* _DLL */
extern long double _FAR_ _cdecl _LHUGE;
#define _LHUGE_VAL _LHUGE

#endif	/* _DLL */

long double  _FAR_ _cdecl acosl(long double);
long double  _FAR_ _cdecl asinl(long double);
long double  _FAR_ _cdecl atanl(long double);
long double  _FAR_ _cdecl atan2l(long double, long double);
long double  _FAR_ _cdecl _atold(const char _FAR_ *);
long double  _FAR_ _cdecl cabsl(struct _complexl);
long double  _FAR_ _cdecl ceill(long double);
long double  _FAR_ _cdecl cosl(long double);
long double  _FAR_ _cdecl coshl(long double);
long double  _FAR_ _cdecl expl(long double);
long double  _FAR_ _cdecl fabsl(long double);
long double  _FAR_ _cdecl floorl(long double);
long double  _FAR_ _cdecl fmodl(long double, long double);
long double  _FAR_ _cdecl frexpl(long double, int _FAR_ *);
long double  _FAR_ _cdecl hypotl(long double, long double);
long double  _FAR_ _cdecl _j0l(long double);
long double  _FAR_ _cdecl _j1l(long double);
long double  _FAR_ _cdecl _jnl(int, long double);
long double  _FAR_ _cdecl ldexpl(long double, int);
long double  _FAR_ _cdecl logl(long double);
long double  _FAR_ _cdecl log10l(long double);
int	     _FAR_ _cdecl _matherrl(struct _exceptionl _FAR_ *);
long double  _FAR_ _cdecl modfl(long double, long double _FAR_ *);
long double  _FAR_ _cdecl powl(long double, long double);
long double  _FAR_ _cdecl sinl(long double);
long double  _FAR_ _cdecl sinhl(long double);
long double  _FAR_ _cdecl sqrtl(long double);
long double  _FAR_ _cdecl tanl(long double);
long double  _FAR_ _cdecl tanhl(long double);
long double  _FAR_ _cdecl _y0l(long double);
long double  _FAR_ _cdecl _y1l(long double);
long double  _FAR_ _cdecl _ynl(int, long double);
