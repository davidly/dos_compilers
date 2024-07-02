/* Copyright 1987 Manx Software Systems, Inc */

#include <math.h>
#include <errno.h>

#define P0 0.25000000000000000000e+0
#define P1 0.75753180159422776666e-2
#define P2 0.31555192765684646356e-4
#define Q0 0.50000000000000000000e+0
#define Q1 0.56817302698551221787e-1
#define Q2 0.63121894374398503557e-3
#define Q3 0.75104028399870046114e-6

#define P(z) ((P2*z + P1)*z + P0)
#define Q(z) (((Q3*z + Q2)*z + Q1)*z + Q0)

#define EPS	2.710505e-20

double
exp(register double x)
{
#	define g (x)
#	define r (g)
	register double z;
#	define xn (z)
	register int n;
	
	if (x > LOGHUGE) {
		errno = ERANGE;
		return HUGE_VAL;
	}
	if (x < LOGTINY) {
		errno = ERANGE;
		return 0.0;
	}
	if (fabs(x) < EPS)
		return 1.0;
	n = z = x * 1.4426950408889634074;
	if (n < 0)
		--n;
	if (z-n >= 0.5)
		++n;
	xn = n;
	g = ((x - xn*0.693359375)) + xn*2.1219444005469058277e-4;
	z = g*g;
	r = P(z)*g;
	r = 0.5 + r/(Q(z)-r);
	return ldexp(r,n+1);
#undef g
#undef r
#undef xn
}
