/* Copyright Manx Software Systems, Inc. 1990.  All rights reserved */

#ifndef __MATH_H
#define __MATH_H

double atof(const char *);
double frexp(double, int *);
double ldexp(double, int);
double modf(double, double *);
double cotan(double);
double log10(double);
#if 0
#define pow(x,y) power(x,y)
#endif
double log(double);
double pow(double, double);
double sqrt(double);
double fabs(double);
double fmod(double, double);
double sin(double);
double cos(double);
double tan(double);
double exp(double);
double floor(double);
double ceil(double);
double sinh(double);
double cosh(double);
double tanh(double);
double asin(double);
double acos(double);
double atan(double);
double atan2(double, double);

#define HUGE_VAL	1.797693134862316E+308
#define HUGE		HUGE_VAL	
#define LOGHUGE		(709.778)
#define TINY_VAL	(2.2e-308)
#define TINY		TINY_VAL
#define LOGTINY		(-708.396)

#if !__STDC__ /* non ANSI C functions */

double ran(void);
double randl(double _x);
void sran(long _seed);

#endif /* !__STDC__ */

#endif
