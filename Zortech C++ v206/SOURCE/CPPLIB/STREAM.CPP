//_ stream.cpp   Sun Jan 17 1988   Modified by: Walter Bright
//               Fri Aug 19 1989   Modified by: Steve Teale

#include <stream.hpp>

streambuf::streambuf()
{
    fp = 0;
    base = gptr = eptr = pptr = 0;
    alloc = 0;
}

streambuf::streambuf(char* buf, int buflen)
{
    fp = 0;
    setbuf(buf,buflen);
    alloc = 0;
}

streambuf::~streambuf()
{
    if (alloc)
        delete base;
}

streambuf *streambuf::setbuf(char *buf,
    int buflen, int written)
{
    base = buf;
    gptr = base;
    pptr = base + written;
    eptr = base + buflen;
    return this;
}

int streambuf::overflow(int c)
{
    if (!base) {        // No buffer allocated
        if (allocate() == EOF)
            return EOF;
    } else return EOF;  // Buffer is full - nothing to be done
    if (c != EOF)
        *pptr++ = c;
    return c & 0xFF;
}

int streambuf::allocate()
{
    base = new char[BUFSIZE];
    if (!base)
        return EOF;
    gptr = base;
    pptr = base;
    eptr = base + BUFSIZE;
    alloc = 1;
    return 0;
}
