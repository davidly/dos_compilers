#include "math.h"
#include "errno.h"

double pow(double a, double b)
{
	double ans;
	register double answer;
	extern int errno;
	register long count;
	char sign, inverse;
	
	if (a == 0) {
		if (b <= 0)
domain:		errno = EDOM;
		return 0.0;
	}
	if (b == 0)
		return 1.0;		/* anything raised to 0 is 1 */
	inverse = sign = 0;
	if (modf(b,&ans) == 0) {
		if ((answer = ans) < 0)
			inverse = 1, answer = -answer;
		if ((count = answer) == answer) {
			for (answer = 1.0 ; count ; count >>= 1, a *= a)
				if ((int)count & 1)
					answer *= a;
			if (inverse)
				answer = 1.0/answer;
			return answer;
		}
		if (a < 0)
			sign = 1, a = -a;
		if ((count&1) == 0)
			sign = 0;		/* number is even so sign is positive */

	} else if (a < 0)
		goto domain;

	answer = exp(log(a)*b);
	return sign ? -answer : answer;
}
