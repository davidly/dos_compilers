/* Copyright Manx Software Systems, Inc. 1984.  All rights reserved */

#ifndef __NOPROTO__
double sin(double), cos(double), tan(double), cotan(double);
double asin(double), acos(double), atan(double), atan2(double,double);
double ldexp(double,int), frexp(double, int *), modf(double, double *);
double floor(double), ceil(double), fabs(double), fmod(double,double);
double log(double), log10(double), exp(double), sqrt(double);
double pow(double,double), sinh(double), cosh(double), tanh(double);
#else
double sin(), cos(), tan(), cotan();
double asin(), acos(), atan(), atan2();
double ldexp(), frexp(), modf();
double floor(), ceil(), fabs(), fmod();
double log(), log10(), exp(), sqrt();
double pow(), sinh(), cosh(), tanh();
#endif

#ifndef HUGE_VAL
#define HUGE_VAL 1.79e+308
#define LOGHUGE	709.778
#define TINY_VAL 2.2e-308
#define LOGTINY	-708.396
#endif
