/* Copyright 1987 Manx Software Systems, Inc */

#include <math.h>

#define P0 -0.16134119023996228053e+4
#define P1 -0.99225929672236083313e+2
#define P2 -0.96437492777225469787e+0
#define Q0 +0.48402357071988688686e+4
#define Q1 +0.22337720718962312926e+4
#define Q2 +0.11274474380534949335e+3

#define gP(g) (((P2*g P1)*g P0)*g)
#define Q(g) (((g Q2)*g Q1)*g Q0)

double tanh(double x)
{
	register double r;
#	define f (r)
	register double g;
	
	f = fabs(x);
	if (f > 25.3)
		r = 1.0;
	else if (f > 0.54930614433405484570) {
		r = 0.5 - 1.0/(exp(f+f)+1.0);
		r += r;
	} else if (f < 2.3e-10)
		r = f;
	else {
		g = f*f;
		r = f + f*
			(gP(g)
			/Q(g));
	}
	if (x < 0.0)
		r = -r;
	return r;
#undef f
}
