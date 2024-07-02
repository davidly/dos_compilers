#ifndef __IOMANIP_HPP
#define __IOMANIP_HPP

#include <generic.hpp>
#include <iostream.hpp>

#define SMANIP(T) name2(SMANIP,T)
#define SAPP(T) name2(SAPP,T)
#define IMANIP(T) name2(IMANIP,T)
#define IAPP(T) name2(IAPP,T)
#define OMANIP(T) name2(OMANIP,T)
#define OAPP(T) name2(OAPP,T)
#define IOMANIP(T) name2(IOMANIP,T)
#define IOAPP(T) name2(IOAPP,T)

#define IOMANIPdeclare(T) \
struct SMANIP(T) { \
    SMANIP(T)(ios &(*f)(ios&, T), T v) : func(f), val(v) {} \
    friend istream &operator>>(istream&, SMANIP(T)&); \
    friend ostream &operator<<(ostream&, SMANIP(T)&); \
private: \
    ios &(*func)(ios&, T); \
    T val; \
}; \
struct IMANIP(T) { \
    IMANIP(T)(istream &(*f)(istream&, T), T v) : func(f), val(v) {} \
    friend istream &operator>>(istream&, IMANIP(T)&); \
private: \
    istream &(*func)(istream&, T); \
    T val; \
}; \
struct OMANIP(T) { \
    OMANIP(T)(ostream &(*f)(ostream&, T), T v) : func(f), val(v) {} \
    friend ostream &operator<<(ostream&, OMANIP(T)&); \
private: \
    ostream &(*func)(ostream&, T); \
    T val; \
}; \
struct IOMANIP(T) { \
    IOMANIP(T)(iostream &(*f)(iostream&, T), T v) : func(f), val(v) {} \
    friend istream &operator>>(iostream&, IOMANIP(T)&); \
    friend ostream &operator<<(iostream&, IOMANIP(T)&); \
private: \
    iostream &(*func)(iostream&, T); \
    T val; \
}; \
struct SAPP(T) { \
    SAPP(T)(ios &(*f)(ios&, T)) : func(f) {} \
    SMANIP(T) operator()(T v) { return SMANIP(T)(func, v); } \
private: \
    ios &(*func)(ios&, T); \
}; \
struct IAPP(T) { \
    IAPP(T)(istream &(*f)(istream&, T)) : func(f) {} \
    IMANIP(T) operator()(T v) { return IMANIP(T)(func, v); } \
private: \
    istream &(*func)(istream&, T); \
}; \
struct OAPP(T) { \
    OAPP(T)(ostream &(*f)(ostream&, T)) : func(f) {} \
    OMANIP(T) operator()(T v) { return OMANIP(T)(func, v); } \
private: \
    ostream &(*func)(ostream&, T); \
}; \
struct IOAPP(T) { \
    IOAPP(T)(iostream &(*f)(iostream&, T)) : func(f) {} \
    IOMANIP(T) operator()(T v) { return IOMANIP(T)(func, v); } \
private: \
    iostream &(*func)(iostream&, T); \
}; \
static istream &operator>>(istream &s, SMANIP(T) &m) \
    {  (*m.func)(s, m.val); return s; } \
static ostream &operator<<(ostream &s, SMANIP(T) &m) \
    { (*m.func)(s, m.val); return s; } \
static istream &operator>>(istream &s, IMANIP(T) &m) \
    { return (*m.func)(s, m.val); } \
static ostream &operator<<(ostream &s, OMANIP(T) &m) \
    { return (*m.func)(s, m.val); } \
static istream &operator>>(iostream &s, IOMANIP(T) &m) \
    { return (*m.func)(s, m.val); } \
static ostream &operator<<(iostream &s, IOMANIP(T) &m) \
    { return (*m.func)(s, m.val); }

IOMANIPdeclare(int);
IOMANIPdeclare(long);

SMANIP(long) resetiosflags(long);
SMANIP(int) setfill(int);
SMANIP(long) setiosflags(long);
SMANIP(int) setprecision(int);
SMANIP(int) setw(int);

#endif  // __IOMANIP_HPP
