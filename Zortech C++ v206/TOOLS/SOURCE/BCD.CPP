#include <bcd.hpp>
#include <string.h>

// The following are assembler functions in BCDLOW.ASM
// they have C linkage
extern "C" {
int bcd_add(int, unsigned char *, unsigned char *);
int bcd_sub(int, unsigned char *, unsigned char *);
int bcd_inc(int, unsigned char *);
int bcd_dec(int, unsigned char *);
int bcd_mul(int, unsigned char *, int);
int bcd_mul10(int, unsigned char *);
int bcd_div10(int, unsigned char *);
int memrcmp(void*, void*, unsigned);
int memtest(void*, unsigned);
}

typedef void (* PFC)(int, char*);
extern void default_error(int,char*);
static PFC bcd_handler = default_error;

void bcd::decode(char *b)
{
    int i;
    unsigned char *p = body;

    if (sign)
        sprintf(b++,"-");           // sign if negative
    char *q = b;
    for (p += nbytes-1, i = nbytes; i--; --p, q += 2)
        sprintf(q,"%d%d", *p >> 4, *p & 0xf);
                                    // print digits 
    q = b;
    while (*q == '0')               // strip leading zeros
        ++q;
    if (!*q)
        --q;
    if (q > b) {
        *b = '\0';
        strcat(b,q);
    }
}

int bcd::test()
{
    if (memtest(body,nbytes))
        return (sign? -1: 1);
    return 0;
}

void bcd::ltobcd(long n)
{
    int digit;
    unsigned char *d = body;

    memset(d,'\0',nbytes);          // make sure nothing there
    if (n < 0) {
        sign = '\xff';              // fill in sign
        n = -n;
    } else
        sign = '\0';
    while (n) {
        digit = n % 10;
        n /= 10;
        *d = digit;                 // fill in low nibble
        if (!n)
            break;                  // nothing left to fill in
        digit = n % 10;
        n /= 10;
        *d += digit << 4;           // then high one
        ++d;
    }
}

int bcd_pow10(int nb, unsigned char * a, int n)
{
    int i, of = 0;
    unsigned char *p;

    if (!n)
        return 0;
    if (n & 1) {                // if odd power * by 10
        of = bcd_mul10(nb,a);
        --n;
        if (!n)                 // no more
            return 0;
    }
    n /= 2;
    for (i = n, p = a+nb-1; i--;)
        if (*p--)
            of = 1;             // check if anything in top n bytes
    memmove(a+n,a,nb-n);
    memset(a,'\0',n);
    return of;
}
    
int bcd::lmul(bcd& s)
{
    unsigned char acc[80], buf[80], *b = s.body;
    int of = 0, i,j, digit;

    memset(acc,'\0',nbytes);
    for (i = nbytes; i--; ++b) {
        if (!memtest(b,i))
            break;                      // rest of multiplier zero
        digit = *b & 0xf;
        if (digit) {
            memmove(buf,body,nbytes);
            of += bcd_mul(nbytes,buf,digit); // mul by low nibble digit
            of += bcd_add(nbytes,acc,buf);   // add to accumulator
        }
        of += bcd_mul10(nbytes,body);        // * 10 for next digit
        digit = *b >> 4;
        if (digit) {
            memmove(buf,body,nbytes);
            of += bcd_mul(nbytes,buf,digit); // mul by high nibble
            of += bcd_add(nbytes,acc,buf);   // add to accumulator
        }
        if (i)                          // don't overflow on limit
            of += bcd_mul10(nbytes,body);    // * 10 for next digit
    }
    memmove(body,acc,nbytes);
    return of;
}

int bcd::ldiv(bcd& b)
{
    unsigned char *p, quot[80], test[80], hold[80];
    int n, m;

    for (m = nbytes*2, p = body+(nbytes-1); !*p && m; --p, m -= 2) ;
    if (!m) return 0;       // dividend 0 - nothing to do
    if (!(*p & 0xf0))
        --m;        // gets number of significant digits in dividend
    for (n = nbytes*2, p = b.body+(nbytes-1); !*p && n; --p, n -= 2) ;
    if (!n) {
        status = -1;        // dividing by zero
        return -1;
    }
    if (!(*p & 0xf0))
        --n;        // gets significant digits in divisor
    if (m < n) {
        memmove(b.body,body,nbytes);    // won't go, fill in remainder
        memset(body,'\0',nbytes);       // and zero quotient
        return 0;
    }
    memset(quot,'\0',nbytes);           // ready quotient
    n = m-n;                            // get iterations required
    bcd_pow10(nbytes,b.body,n++);       // and prepare to subtract
    for (; n--;) {                      // iterate
        memmove(test,b.body,nbytes);    // 1 * divisor
        memset(hold,'\0',nbytes);       // 0 * divisor
        for (; memrcmp(test,body,nbytes) <= 0;) {
            bcd_inc(nbytes,quot);       // will subtract, adjust quotient
            memmove(hold,test,nbytes);  // keep a copy
            if (bcd_add(nbytes,test,b.body))
                break;                  // overflowed
        }
// test is now too big - hold has previous value
        bcd_sub(nbytes,body,hold);      // subtract from dividend
        bcd_div10(nbytes,b.body);       // divisor/10
        if (n)
            bcd_mul10(nbytes,quot);     // quotient*10 if any more
    }
    memmove(b.body,body,nbytes);        // report remainder
    memmove(body,quot,nbytes);          // and quotient
    return 0;
}
    
int bcd::signed_add(bcd& b)
// *this must always be >= b in magnitude
{
    int of = 0;

    if (sign) {
        if (b.sign)
            of = bcd_add(nbytes,body,b.body);
        else
            of = bcd_sub(nbytes,body,b.body);
        sign = 0xff;
    } else {
        if (b.sign)
            of = bcd_sub(nbytes,body,b.body);
        else
            of = bcd_add(nbytes,body,b.body);
        sign = 0;
    }
    return of;
}

void bcd::atobcd(char *s)
{
    int i, t;
    char *q;
    unsigned char *p = body;

    t = strlen(s);
    if (!t) {
        status = sign = 0;
        return;
    }
    if (*s == '-') {
        q = s+1;
        sign = '\xff';
    } else {
        q = s;
        sign = '\0';
    }
    s += t-1;           // start with least significant
    for (i = nbytes*2; s >= q && i;) {
        *p = *s-'0';    // low nibble
        --s;
        --i;
        if (!(s >= q && i))
            break;      // no more string or no room
        t = (*s-'0') << 4;
        *p += t;        // add high nibble
        ++p;
        --s;
        --i;
    }
    if (s >= q)         // some string left report overflow
        status = 1;
}

bcd::bcd()
{
    nbytes = 12;
    body = new unsigned char[nbytes];
    if (!body) {
        bcd_handler(ENOMEM,"bcd - not enough memory");
        return;
    }
    sign = '\0';
    memset(body,'\0',nbytes);
}

bcd::bcd(long n, int nd)
{
    nbytes = ((nd+1) & ~1)/2;
    body = new unsigned char[nbytes];
    if (!body) {
        bcd_handler(ENOMEM,"bcd - not enough memory");
        return;
    }
    sign = n < 0L? '\xff': '\0';
    status = 0;
    if (n)
        ltobcd(n);
    else 
        memset(body,'\0',nbytes);
}

bcd::bcd(bcd& a)
{
    body = new unsigned char[a.nbytes];
    if (!body) {
        bcd_handler(ENOMEM,"bcd - not enough memory");
        return;
    }
    nbytes = a.nbytes;
    memmove(body,a.body,nbytes);
    sign = a.sign; status = a.status;
}

bcd::bcd(char *ds, int nd)
{
    nbytes = ((nd+1) & ~1)/2;
    body = new unsigned char[nbytes];
    if (!body) {
        bcd_handler(ENOMEM,"bcd - not enough memory");
        return;
    }
    memset(body,'\0',nbytes);
    atobcd(ds);
}

bcd& bcd::operator=(bcd& a)
{
    if (this == &a)
        return *this;
    delete body;
    body = new unsigned char[a.nbytes];
    if (!body) {
        bcd_handler(ENOMEM,"bcd - not enough memory");
        return *this;
    }
    memmove(body,a.body,a.nbytes);
    nbytes = a.nbytes;
    sign = a.sign;
    status = a.status;
    return *this;
}

bcd& bcd::operator=(long n)
{
    sign = n < 0L? '\xff': '\0';
    status = 0;
    ltobcd(n);
    return *this;
}

bcd& bcd::operator=(char *s)
{
    memset(body,'\0',nbytes);
    atobcd(s);
    return *this;
}

bcd bcd::operator+(bcd& a)
{
    bcd loc(*this);
    if (memrcmp(loc.body,a.body,nbytes) >= 0)
        loc.status = loc.signed_add(a);
    else {
        loc = a;
        loc.status = loc.signed_add(*this);
    }
    return loc;
}

bcd bcd::operator+(long n)
{
    bcd lv(n, 2*this->nbytes);  // must work with copies
    bcd loc(*this);

    if (memrcmp(loc.body,lv.body,nbytes) >= 0) {
        loc.status = loc.signed_add(lv);
        return loc;
    } else {
        lv.status = lv.signed_add(loc);
        return lv;
    }
}

bcd bcd::operator-(bcd& a)
{
    bcd loc(*this);

    a.sign = !a.sign;    
    if (memrcmp(loc.body,a.body,nbytes) >= 0) {
        loc.status = loc.signed_add(a);
    } else {
        loc = a;
        loc.status = loc.signed_add(*this);
    }
    a.sign = !a.sign;    
    return loc;
}

bcd bcd::operator-(long n)
{
    bcd lv(n, 2*this->nbytes);  // must work with copies
    bcd loc(*this);

    lv.sign = !lv.sign;
    if (memrcmp(loc.body,lv.body,nbytes) >= 0) {
        loc.status = loc.signed_add(lv);
        return loc;
    } else {
        lv.status = lv.signed_add(loc);
        return lv;
    }
}

bcd& bcd::operator++()
{
    if (!test())
        sign = 0;
    if (sign)
        status = bcd_dec(nbytes,body);
    else
        status = bcd_inc(nbytes,body);
    return *this;
}

bcd& bcd::operator--()
{
    if (!test())
        sign = 1;
    if (sign)
        status = bcd_inc(nbytes,body);
    else
        status = bcd_dec(nbytes,body);
    return *this;
}

bcd bcd::operator*(bcd& a)
{
    bcd loc(*this);

    loc.sign = loc.sign != a.sign? '\xff': '\0';
    loc.status = loc.lmul(a);
    return loc;
}

bcd bcd::operator*(long n)
{
    bcd lv(n, 2*this->nbytes);
    bcd loc(*this);

    loc.sign = loc.sign != lv.sign? '\xff': '\0';
    loc.status = loc.lmul(lv);
    return loc;
}

bcd bcd::operator/(bcd a)   // parameter is a copy
{
    bcd loc(*this);

    loc.sign = loc.sign != a.sign? '\xff': '\0';
    loc.status = loc.ldiv(a);
    return loc;             // gets quotient
}

bcd bcd::operator%(bcd a)   // parameter is a copy
{
    bcd loc(*this);

    a.sign = loc.sign != a.sign? '\xff': '\0';
    a.status = loc.ldiv(a);
    return a;               // gets remainder
}

bcd bcd::operator/(long n)
{
    bcd lv(n, 2*this->nbytes);
    bcd loc(*this);

    loc.sign = loc.sign != lv.sign? '\xff': '\0';
    loc.status = loc.ldiv(lv);
    return loc;
}

bcd bcd::operator%(long n)
{
    bcd lv(n, 2*this->nbytes);
    bcd loc(*this);

    lv.sign = loc.sign != lv.sign? '\xff': '\0';
    lv.status = loc.ldiv(lv);
    return lv;
}

int bcd::cmp(bcd& a)
{
    if (sign && !a.sign)
        return -1;
    if (!sign && a.sign)
        return 1;
    if (!sign && !a.sign)
        return -memrcmp(body,a.body,nbytes);
    return memrcmp(body,a.body,nbytes);
}

int bcd::cmp(long n)
{
    if (sign && n >= 0L)
        return -1;
    if (!sign && n < 0L)
        return 1;
}
    
long bcd::tolong()
{
    long v = 0L;
    unsigned char *p;

    for (p = (nbytes >= 5)? body+4: body+nbytes-1; !*p; --p) ;
 // 5 bytes is maximum for long - skip over zeros
    for (; p >= body; --p) {
        v *= 10;
        v += 10*(*p >> 4) + (*p & 0xf);
    }
    if (sign)
        v = -v;
    return v;
}

bcd::operator double()
{
    unsigned char *p;
    double dval = 0.0, exp = 1.0;
    unsigned long msdec = 0, lsdec = 0;
    unsigned long msscale = 1;

    p = body+nbytes-1;
    while (!*p)
        --p;
    while (p >= body)
    {
        if (msdec < (0x7FFFFFFF-10)/10)
            msdec = msdec*10 + (*p >> 4);
        else if (msscale < (0x7FFFFFFF-10)/10)
        {
            lsdec = lsdec*10 + (*p >> 4);
            msscale *= 10;
        }
        else
            exp *= 10;
        if (msdec < (0x7FFFFFFF-10)/10)
            msdec = msdec*10 + (*p & 0xf);
        else if (msscale < (0x7FFFFFFF-10)/10)
        {
            lsdec = lsdec*10 + (*p & 0xf);
            msscale *= 10;
        }
        else
            exp *= 10;
        --p;
    }
    dval = msdec;
    if (msscale != 1)        /* if stuff was accumulated in lsdec */
        dval = dval * msscale + lsdec;
    dval *= exp;
    return (sign) ? -dval : dval;
}

PFC set_bcd_handler(PFC handler)
{
    PFC loc = bcd_handler;
    bcd_handler = handler;
    return loc;
}

ostream& operator<<(ostream& s, bcd& a)
{
    char buf[80];

    a.decode(buf);
    return s << buf;
}
