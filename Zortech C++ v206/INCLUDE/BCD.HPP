#ifndef BCDHPP
#define BCDHPP
#include <stream.hpp>
#include "errn.hpp"

extern int _allocerr;

class bcd {
    unsigned char nbytes, sign, status;
    unsigned char *body;
    int signed_add(bcd&);
    int lmul(bcd&);
    int ldiv(bcd&);
    void ltobcd(long);
    void atobcd(char *);
public:
    bcd();
    bcd(long, int = 24);    // Conversion from a long
    bcd(bcd&);              // Copy constructor
    bcd(char *, int = 24);  // Conversion from a digit string
    ~bcd() { delete body; }
    bcd& operator=(bcd&);
    bcd& operator=(long);
    bcd& operator=(char *);
    bcd operator+(bcd&);
    bcd operator+(long);
    bcd operator-(bcd&);
    bcd operator-(long);
    bcd operator*(bcd&);
    bcd operator*(long);
    bcd operator/(bcd);
    bcd operator/(long);
    bcd operator%(bcd);
    bcd operator%(long);
    bcd& operator++();
    bcd& operator--();
    long tolong();
    operator double();      // Provide one implicit conversion
                            // to a built in type
    int test(void);         // and an explicit one to avoid
                            // ambiguity
    int cmp(bcd&);
    int cmp(long);
    int cmp(double);
    int state() { return(status); }
    void decode(char *);
};

ostream& operator<<(ostream&, bcd&);

#endif
