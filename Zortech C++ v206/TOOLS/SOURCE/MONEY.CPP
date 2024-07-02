#include <money.hpp>
#include <limits.h>

//. The first constructor with arguments provides for explicit conversion
//. of dollars and cents to money.  It copes sensibly with dollar and
//. cent arguments which are somewhat inconsistent,  e.g. money(10,-101)
money::money(long a, int b)
{
    dollars = a;
    dollars += b/100;
    cents = b%100;
    carry();
}

//. The second argument with a constructor is a conversion from a double
//. to money.  It checks for overflow by comparing the whole part
//. of the double argument with LONG_MAX,  a constant defined as per
//. ANSI C in limits.h.
money::money(double d)
{
    double w, f;
    int negative = d < 0? (d = -d, 1): 0;
                        // Convert to positive
    f = modf(d,&w);     // Separate whole and fractional parts
    if (w > LONG_MAX) { // Check for overflow
        unsafe();
        return;
    }
    int c = f*1000;
    cents = c/10;
    if (c%10 >= 5)      // Round the cents
        ++cents;
    dollars = w;
    if (negative) {     // Adjust signs
        dollars = -dollars; cents = -cents;
    }
}

//. The conversion from a character string also checks for overflow,
//. though rather less precisely.  Numbers with ten digit dollars are
//. accepted if the most significant digit is a one.  Otherwise they are
//. unsafe,  and set the overflow flag.  Cents less than zero are treated
//. as an error and set the error flag.
money::money(char *s)
{
    char *p = s;
    while (isdigit(*p)) ++p;
    int l = p-s;            // Check nuber of digits
    dollars = cents = 0;
    if (!l) return;         // No digits - set to zero.
    if (l > 10 || (l == 10 && *s > '1')) {
        unsafe();           // Check for unsafe numbers
        return;
    }
    sscanf(s,"%ld.%d",&dollars,&cents);
    if (cents < 0) {
        unsafe();
        return;
    }
    if (dollars < 0)        // Match the signs
        cents = -cents;
}

//. Carry is a private function designed to correct the situation where
//. the signs of dollars and cents do not match.  This will arise during
//. several arithmetic operations.  It also deals with the situation
//. when cents are for some reason overflowed.
void money::carry()
{
    while (cents < 0 && dollars > 0) {
        --dollars;
        cents += 100;
    }
    while (cents > 0 && dollars < 0) {
        ++dollars;
        cents -= 100;
    }
    dollars += cents/100;
    cents %= 100;
}

//. The format function just uses sprintf to produce an appropriate
//. string in the specified field width.
char *money::format(char *s, int l)
{
    sprintf(s,"%*ld.%02d",l-3,dollars,cents < 0? -cents: cents);
    return s;
}

//. The binary addition/subtraction operations are trivial once we have
//. function carry.  The parts are added separately, then carry is called
//. to rationalize the money representation.
money operator+(money& a, money& b)
{
    money t;
    t.dollars = a.dollars+b.dollars;
    t.cents = a.cents+b.cents;
    t.carry();
    return t;
}

money operator-(money& a, money& b)
{
    money t;
    t.dollars = a.dollars-b.dollars;
    t.cents = a.cents-b.cents;
    t.carry();
    return t;
}

//. The multiplication operator needs to be provided for both argument
//. combinations,  money& and double, and double and money&.  The
//. computation is identical.  The product is worked out in double
//. floating point,  then coerced back to money.
money operator*(money& a, double b)
{
    b *= a.dollars+a.cents/100.0;
    return money(b);
}

money operator*(double b, money& a)
{
    b *= a.dollars+a.cents/100.0;
    return money(b);
}

//. Division will be unsafe if a large number of dollars is divided by
//. a few cents.  The division is done in double floating point,  and
//. the result checked for overflow.  If overflow occurs,  the result
//. is LONG_MAX,  and the error flag is set.
long operator/(money& a, money& b)
{
    double n = a.dollars+a.cents/100.0;
    double d = b.dollars+b.cents/100.0;
    double q = n/d;
    modf(q,&n);
    if (n > LONG_MAX) {
        money::unsafe();
        return LONG_MAX;
    }
    return long(n);
}

//. Modulo is a little more devious.  It divides in the same way,  setting
//. the error flag and returning zero money if overflow occurs,  but
//. then it multiplies the divisor up by the long result,  and returns
//. the difference between the dividend and the multiplied up divisor.
money operator%(money& a, money& b)
{
    int neg = a.dollars < 0;
    double n = a.dollars+a.cents/100.0;
    double d = b.dollars+b.cents/100.0;
    double q = n/d;
    modf(q,&n);
    if (n > LONG_MAX) {
        money::unsafe();
        return money(0,0);
    }
    long l = n < 0? -n: n;
    long lc = l*abs(b.cents);
    l *= labs(b.dollars);
    l += lc/100;
    int c = lc%100;
    if (neg) {
        l = -l;
        c = -c;
    }
    return a - money(l,c);
}
