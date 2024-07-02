#include <math.h>

double
fmod(double x, double y)
{
	double d;

	return(modf(x/y,&d)*y);
}
