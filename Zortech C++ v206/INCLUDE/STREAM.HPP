//_ stream.hpp   Fri Apr 28 1989   Modified by: Walter Bright
//               Fri Aug 18 1989   Modified by: Steve Teale

#ifndef __STREAM_H
#define __STREAM_H

extern "C++" {

#ifndef __STDIO_H
#include	<stdio.h>
#endif

#ifndef	BUFSIZE
#define	BUFSIZE	1024
#endif

///////////////////////////// STREAMBUF //////////////////////

// Class for dealing with a stream buffer
class streambuf
{
protected:
    char *base;  // buffer, NULL if no buffer
    char *pptr;  // write pointer (1 past end of data in buffer)
    char *gptr;  // read pointer (next char to read), gptr chases pptr
    char *eptr;  // 1 past end of buffer
    int alloc;   // 1 if base was allocated using new

    int allocate();
    FILE *fp;    // in case streambuf is just a layer over stdio
    streambuf *setbuf(char *buf, int buflen,
            int written = 0);
    friend class ostream;
    friend class istream;
public:


// Functions for buffer full and empty respectively
    virtual int overflow(int c = EOF);
    virtual int underflow() { return EOF; }

// Constructors
    streambuf();
    streambuf(char* buf, int buflen);

// Destructor
    virtual ~streambuf();

// Character by character functions
    int snextc()
    {	return (gptr + 1 < pptr)
        ? (unsigned char) *++gptr
        : underflow();
    }

    int sgetc()
    {	return (gptr < pptr)
        ? (unsigned char) *gptr
        : underflow();
    }

    int sputc(int c = EOF)
    {
        return fp
            ? putc(c,fp)
            : (pptr < eptr)
                ? (unsigned char) (*pptr++ = c)
                : overflow(c);
    }

    void sputbackc(char c)
        { (gptr > base) && (*--gptr = c) != 0; }

// Access to buffer
    char *bufptr() { return base; }
};

/////////////////////// FILEBUF ///////////////////////

extern "C" int close(int);		// should match io.h

// a stream buffer for files

enum open_mode  { input = 0, output = 1, append = 2 };

class filebuf : public streambuf
{
    int fd;
    int opened;
public:

// Functions for buffer full and empty respectively
    int overflow(int c);
    int underflow();

// File manipulations    
    filebuf* open(char *,open_mode);
    int close();

// Constructors
    filebuf()
        { fp = 0; opened = 0; }
    filebuf(int d)
        { fd = d; fp = 0; opened = 1; }
    filebuf(FILE* p)
        { fp = p; opened = 1; }
    filebuf(int d, char *buf, int buflen)
        : (buf,buflen)
        { fd = d; fp = 0; opened = 1; }

// Destructor
    ~filebuf() { close(); }
};

///////////////////// Input and Output ///////////////////

struct whitespace { int dummy; };

// State for each istream or ostream
enum state_value
{	_good = 0,	// previous input operation succeeded. state must
			// be _good for subsequent input operations to succeed
	_eof  = 1,	// reached end of file
	_fail = 2,	// error, no characters lost
	_bad  = 4	// the stream is all messed up
};

// Output formatting routines

extern char *dec(long, int = 0);
extern char *oct(long, int = 0);
extern char *hex(long, int = 0);
extern char *str(const char *, int = 0);
extern char *chr(int, int = 0);
extern char *form(const char * ...);


///////////////////////// OSTREAM //////////////////////

class ostream
{
    streambuf *bp;
    state_value state;
    int alloc;

    friend class istream;

public:

// Overloads of <<
    ostream& operator<<(const streambuf&);
    ostream& operator<<(const whitespace&);
    ostream& operator<<(const char*);
    ostream& operator<<(const signed char *psc)
        { return *this << (const char *) psc; }
    ostream& operator<<(const unsigned char *puc)
        { return *this << (const char *) puc; }
    ostream& operator<<(long);
    ostream& operator<<(unsigned long ul)
        { return *this << (long) ul; }
    ostream& operator<<(int a)
        { return *this << (long) a; }
    ostream& operator<<(unsigned a)
        { return *this << (long) a; }
    ostream& operator<<(char c);
    ostream& operator<<(signed char c)
        { return *this << (char) c; }
    ostream& operator<<(unsigned char c)
        { return *this << (char) c; }
    ostream& operator<<(short s)
        { return *this << (int) s; }
    ostream& operator<<(unsigned short us)
        { return *this << (unsigned) us; }
    ostream& operator<<(double);

// Other output functions
    ostream& flush()
        { bp->overflow(); return *this; }
    ostream& put(char);

// Stream state access functions
    int good() { return state == _good; }
    int eof() { return state & _eof; }
    int fail() { return state & (_fail | _bad); }
    int bad() { return state & _bad; }
    operator void*()
        { return !state? this: 0; }
    int operator !() { return state; }
    int rdstate() { return state; }

// State set function
    void clear(state_value v = _good)
        { state = v; }

// Access to associated buffer
    char *bufptr() { return bp->bufptr(); }

// Constructors
    ostream(streambuf*);
    ostream(int fd);
    ostream(int buflen, char *buf);

// Destructor
    ~ostream() { flush(); if (alloc) delete bp; }
};

///////////////////////// ISTREAM ///////////////////////////

class istream
{
    streambuf *bp;
    ostream *tied_to;
    state_value state;
    char skipws;
    char alloc;
    void eatwhite();
public:

// Overloads of operator>>
    istream& operator>>(streambuf&);
    istream& operator>>(whitespace&);
    istream& operator>>(char&);
    istream& operator>>(char*);
    istream& operator>>(signed char &sc)
        { return *this >> (char ) sc; }
    istream& operator>>(signed char *p)
        { return *this >> (char *) p; }
    istream& operator>>(unsigned char &uc)
        { return *this >> (char ) uc; }
    istream& operator>>(unsigned char *p)
        { return *this >> (char *) p; }
    istream& operator>>(int&);
    istream& operator>>(unsigned &u)
        { return *this >> (int) u; }
    istream& operator>>(short &s)
        { return *this >> (int) s; }
    istream& operator>>(unsigned short &us)
        { return *this >> (int) us; }
    istream& operator>>(long&);
    istream& operator>>(unsigned long &ul)
        { return *this >> (long) ul; }
    istream& operator>>(float&);
    istream& operator>>(double&);

// Other input functions
    istream& get(char *, int, char = '\n');
    istream& get(streambuf&, char = '\n');
    istream& get(char& c);
    istream& putback(char);

// Istream control functions
    ostream* tie(ostream *os);
    int skip(int s);

// Stream state access functions
    int good() { return state == _good; }
    int eof() { return state & _eof; }
    int fail() { return state & (_fail | _bad); }
    int bad() { return state & _bad; }
    int operator!() { return !good(); }
    operator void*() { return good() ? this: 0; }
    int rdstate() { return state; }

// Stream state set function
    void clear(state_value v = _good) { state = v; }

// Constructors
    istream(int len, char *string, int s = 1);
    istream(streambuf *sb, int s = 1, ostream *os = NULL);
    istream(int fd, int s = 1, ostream *os = NULL);

// Destructor
    ~istream();
};


/////////////////////
// Predefined I/O streams.
// These are tied to stdin, stdout, stderr, stdprn, stdaux

extern istream cin;
extern ostream cout;
extern ostream cerr;
extern ostream cprn;
extern ostream caux;

} // extern "C++"

#endif
