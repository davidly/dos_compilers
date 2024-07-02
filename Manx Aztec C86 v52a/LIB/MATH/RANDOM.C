/*
 * Random number generator -
 * adapted from the FORTRAN version 
 * in "Software Manual for the Elementary Functions"
 * by W.J. Cody, Jr and William Waite.
 */

double exp(double), ran(void);

static long int iy = 100001;

void
sran(long seed)
{
	iy = seed;
}

double
ran(void)
{
	iy *= 125;
	iy -= (iy/2796203) * 2796203;
	return (double) iy/ 2796203.0;
}

double
randl(double x)
{

	return exp(x*ran());
}

