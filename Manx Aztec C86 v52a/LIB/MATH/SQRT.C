/* Copyright 1987 Manx Software Systems, Inc */

#include <math.h>
#include <errno.h>

double sqrt(register double x)
{
	register double y;
	int n;
	
	if (x <= 0.0) {
		if (x == 0.0) return x;
		errno = EDOM;
		return 0.0;
	}
    y = 0.4173075996388649989089 + 0.59016206709064458299663 * frexp(x, &n);
	if (n&1)
		y *= 1.41421356237309504880;	/* sqrt(2) */
	y = ldexp(y, n >> 1);

	y = ldexp(y + x/y, -1);				/* y = (y + x/y) / 2.0 */
	y = ldexp(y + x/y, -1);				/* y = (y + x/y) / 2.0 */
 return ldexp(y + x/y, -1);				/* y = (y + x/y) / 2.0 */
}
