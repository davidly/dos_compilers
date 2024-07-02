/*_ math.h   Fri Jan 20 1989   Modified by: Walter Bright */
/* Copyright (C) 1985-1989 by Northwest Software	*/
/* All Rights Reserved					*/

#ifndef __MATH_H
#define __MATH_H	1

#if __cplusplus
extern "C" {
#endif

#define HUGE_VAL	1.797693134862315e+308
/*#define HUGE_VAL	DBL_MAX	*/

#ifdef __STDC__
#define __CDECL
#else
#define __CDECL cdecl
#endif

double	__CDECL acos(double);
double	__CDECL asin(double);
double	__CDECL atan(double);
double	__CDECL atan2(double,double);
double	__CDECL cos(double);
double	__CDECL sin(double);
double	__CDECL tan(double);
double	__CDECL cosh(double);
double	__CDECL sinh(double);
double	__CDECL tanh(double);
double	__CDECL exp(double);
double	__CDECL frexp(double,int *);
double	__CDECL ldexp(double,int);
double	__CDECL log(double);
double	__CDECL log10(double);
double	__CDECL modf(double,double *);
double	__CDECL pow(double,double);
double	__CDECL sqrt(double);
double	__CDECL ceil(double);
double	__CDECL fabs(double);
double	__CDECL floor(double);
double	__CDECL fmod(double,double);

#ifndef __STDC__	/* non-ANSI stuff	*/

/* Constants that the 8087 supports directly	*/
#define PI		3.14159265358979323846
#define LOG2		0.30102999566398119521
#define LN2		0.6931471805599453094172321
#define LOG2T		3.32192809488736234787
#define LOG2E		1.4426950408889634074	/* 1/LN2		*/

/* Struct used with matherr() when a floating point exception occurs	*/
struct exception
{	int type;	/* DOMAIN,SING,...				*/
	char *name;	/* pointer to string defining the name of the	*/
			/* function that detected the error		*/
	double arg1;	/* first argument to function			*/
	double arg2;	/* second argument (if defined) to function	*/
	double retval;	/* default return value				*/
};

/* Values for exception.type	*/
#define DOMAIN		1	/* arguments are out of range for the function */
#define SING		2	/* argument is a singularity		*/
#define	OVERFLOW	3
#define UNDERFLOW	4
#define TLOSS		5	/* total loss of significant digits	*/
#define PLOSS		6	/* partial loss of significant digits	*/

int	__CDECL matherr(struct exception *);
double	__CDECL atof(const char *);
double	__CDECL hypot(double,double);
double	__CDECL poly(double,int,double []);

#endif

#undef __CDECL

#if __cplusplus
}
#endif

#endif /* __MATH_H */
