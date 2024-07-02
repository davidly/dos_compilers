#ifndef MONEY_HPP
#define MONEY_HPP
#include <stream.hpp>
#include <math.h>
#include <stdlib.h>
#include <limits.h>
#include <ctype.h>
#include <string.h>

class money {
    long dollars;
    int cents;
    static int errf;
    void carry();
    static void unsafe() { errf = -1; }
public:
    money() { dollars = 0; cents = 0; }
    money(long d, int c);
    money(double);
    money(char *);
    char *format(char *s, int l = 0);
    money& operator-()
    {
        dollars = -dollars; cents = -cents;
        return *this;
    }
    int operator!()
    { return !dollars && !cents; }
    money& operator+=(money&);
    money& operator-=(money&);
    money& operator*=(double);
    operator double()
    { return dollars+((double) cents)/100; }
    int err() { return errf; }
    void clear_err() { errf = 0; }
    friend money operator+(money&, money&);
    friend money operator-(money&, money&);
    friend money operator*(money&, double);
    friend money operator*(double, money&);
    friend long operator/(money&, money&);
    friend money operator%(money&, money&);
    friend int operator==(money&, money&);
    friend int operator!=(money&, money&);
    friend int operator>(money&, money&);
    friend int operator<(money&, money&);
    friend int operator>=(money&, money&);
    friend int operator<=(money&, money&);
};

//. The friend functions implementing the comparison operations are all
//. rather trivial,  and can be inlined for speed.
inline int operator==(money& a, money& b)
{
    return a.dollars == b.dollars && a.cents == b.cents;
}

inline int operator!=(money& a, money& b)
{
    return a.dollars != b.dollars || a.cents != b.cents;
}

inline int operator>(money& a, money& b)
{
    return a.dollars > b.dollars? 1 : a.cents > b.cents;
}

inline int operator<(money& a, money& b)
{
    return a.dollars < b.dollars? 1 : a.cents < b.cents;
}

inline int operator>=(money& a, money& b)
{
    return !(a < b);
}

inline int operator<=(money& a, money& b)
{
    return !(a > b);
}

ostream& operator<<(ostream&, money&);
#endif
