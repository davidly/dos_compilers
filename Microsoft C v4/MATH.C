#define	FALSE	0
#define	TRUE	1

extern char p[];
extern char t[];
extern int q;

arctan(s)
register int s;
{
	register int n;

	t[0] = 1;
	div(s);			/* t[] = 1/s */
	add();
	n = 1;
	do {
		mul(n);
		div(s * s);
		div(n += 2);
		if (((n-1) / 2) % 2 == 0)
			add();
		else
			sub();
	} while (!tiszero());
}	

add()
{
	register int j;

	for (j = q; j >= 0; j--)
		if (t[j] + p[j] > 9) {
			p[j] += t[j] - 10;
			p[j-1] += 1;
		} else
			p[j] += t[j];
}

sub()
{
	register int j;

	for (j = q; j >= 0; j--)
		if (p[j] < t[j]) {
			p[j] -= t[j] - 10;
			p[j-1] -= 1;
		} else
			p[j] -= t[j];
}

mul(multiplier)
register int multiplier;
{
	int b;
	register int i;
	int carry, digit = 0;

	for (i = q; i >= 0; i--) {
		b = (t[i] * multiplier + carry);
		digit = b % 10;
		carry = b / 10;
		t[i] = digit;
	}
}

/* t[] /= l */

div(divisor)
int divisor;
{
	register int i, b;
	int quotient, remainder = 0;

	for (i = 0; i <= q; i++) {
		b = (10 * remainder + t[i]);
		quotient = b / divisor;
		remainder = b % divisor;
		t[i] = quotient;
	}
}

div4()
{
	register int i, c, d = 0;

	for (; i <= q; i++) {
		c = (10 * d + p[i]) / 4;
		d = (10 * d + p[i]) % 4;
		p[i] = c;
	}
}

mul4()
{
	register int i, c, d;

	d = c = 0;

	for (i = q; i >= 0; i--) {
		d = (p[i] * 4 + c) % 10;
		c = (p[i] * 4 + c) / 10;
		p[i] = d;
	}
}

tiszero()
{
	register int k;

	for (k = 0; k <= q; k++)
		if (t[k] != 0)
			return(FALSE);
	return(TRUE);
}

