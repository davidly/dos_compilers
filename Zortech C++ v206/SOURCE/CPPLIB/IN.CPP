//_ in.cpp   Sun Jun 26 1988   Modified by: Walter Bright
//           Tue Aug 22 1989   Modified by: Steve Teale
// Copyright (C) 1988 by Walter Bright
// All Rights Reserved
// Written by Walter Bright
// Stream I/O input routines

#include	<stream.hpp>
#include	<ctype.h>
#include	<stdlib.h>
#include	<dos.h>
#include	<string.h>

#if Ain1

filebuf cin_file(stdin);
istream cin(&cin_file,1,&cout);

#endif

/////////////////////////////////////////////
// Skip over any whitespace in the stream is
//

#if Ain2

void istream::eatwhite()
{
    if (tied_to)
                        // If tied to an output stream,
        tied_to->flush();
                        // flush all output before input.
    char c = bp->sgetc();
                        // Look at current character.
    while (isspace(c))
        c = bp->snextc();
                        // Discard current char, get next.
    if (c == EOF)       // We ran out of input.
        state |= _eof;
}

#endif

///////////////////////////////////////////
// Skip over any whitespace in the stream.
//

#if Ain3

istream& istream::operator>>(whitespace& ws)
{
    if (good())
        eatwhite();
    return *this;
}

#endif

///////////////////////////////////////////////////
// Read characters from stream and stuff into *p.
// The string is read until isspace or EOF.
// The string is always 0-terminated unless a fail occurred.
//

#if Ain4

istream& istream::operator>>(char *p)
{
    if (skipws)
        eatwhite();
                        // Ignore any white space,
    else if (tied_to)
        tied_to->flush();
                        // and flush the associated ostream.
    if (state)
        state |= _fail;
    else {
        int c = bp->sgetc();
        if (c == EOF)
            state |= _eof | _fail;
                        // Couldn't read any chars.
        else {
            if (isspace(c)) {
                        // Not skipping, advance the read pointer
                *p++ = c;
                if (bp->snextc() == EOF)
                    state |= _eof;
            } else  {
                while (!isspace(c))
                {
                    if (c == EOF)
                    {       // No more chars.
                        state |= _eof;
                        break;
                    }
                    *p++ = c;
                    c = bp->snextc();
                }
            }
            *p = 0;     // Terminate the string.
        }
    }
    return *this;
}

#endif

/////////////////////////////
// Read the next character.
//

#if Ain5

istream& istream::operator>>(char& rc)
{
    if (skipws)
        eatwhite();
    else if (tied_to)
        tied_to->flush();
                        // As before.
    if (state)
        state |= _fail;
    else {
        int c = bp->sgetc();
        if (c == EOF)
            state |= _eof | _fail;
                        // Couldn't read any chars.
        else {
            if (bp->snextc() == EOF)
                state |= _eof;
            rc = c;
        }
    }
    return *this;
}

#endif

//////////////////////////////////////////////////////
// Read an int, in the same manner as reading a long.
//

#if Ain6

istream& istream::operator>>(int& ri)
{
    eatwhite();     // Eat space regardless if looking for a number
    if (state)
        state |= _fail;
    else
    {
        long v;
        *this >> v;
        if (!fail())
            ri = v;
    }
    return *this;
}

#endif

////////////////////////////////////////////////////////
// Read a long. The long may be preceded by a + or -.
// Terminate on end of file or if a non-digit is read.
// Overflow is ignored.
//

#if Ain7

istream& istream::operator>>(long& rl)
{
    eatwhite();     // Eat space regardless if looking for a number
    if (state)
        state |= _fail;
    else
    {
        char sign = 0;
        int got = 0, c = bp->sgetc();

        switch (c)
        {
        case '-':
            sign++;
        case '+':       // Fall through.
            ++got;
            c = bp->snextc();
                        // Hopefully get first digit.
            break;
        case EOF:
            state |= _eof | _fail;
                        // Couldn't read any chars.
            return *this;
        }
        if (!isdigit(c)) {
            state |= _fail;
                        // Bad input but no characters lost.
            if (got)
                state |= _bad;
                        // Lost a char.
        } else {
            long result = 0;
            do {
                result = result * 10 + (c - '0');
                c = bp->snextc();
                        // Get more digits.
            } while (isdigit(c));
            rl = (sign) ? -result : result;
                        // Adjust sign of result.
        }
        if (c == EOF)
            state |= _eof;
    }
    return *this;
}

#endif

////////////////////////////////////////////
// Same as for double, except it's a float.
//

#if Ain8

istream& istream::operator>>(float& rf)
{
    eatwhite();     // Eat space regardless if looking for a number
    if (state)
        state |= _fail;
    else
    {
        double d;
        *this >> d;
        if (!fail())
            rf = (float) d;
    }
    return *this;
}

#endif

//////////////////////////////////////////////////
// Read a double. The format is the same as for C.
// Overflow, underflow, etc. is not detected.
//

#if Ain9

istream& istream::operator>>(double& rd)
{
    eatwhite();     // Eat space regardless if looking for a number
    if (state)
        state |= _fail;
    else
    {

// The strategy is to read the characters forming the double
// into a temporary streambuf, and then use atof() to do
// the conversion.  This protects against overflowing the buffer.
// Note atof() does not check floating point overflow,  and
// truncation by the streambuf is not detected.

        char buf[81];
        streambuf tsb(buf,80);
        buf[80] = '\0';
        int got = 0,digits = 0, c = bp->sgetc();

        switch (c)
        {
            case '+':
            case '-':
                ++got;
                tsb.sputc(c);
                c = bp->snextc();
                break;
            case EOF:
                state = _eof | _fail;
                        // Fail - no characters available.
                return *this;
        }
        if (!isdigit(c) && c != '.') {
            state |= _fail;
                        // Bad input, but no chars lost
            if (got)
                state |= _bad;
                        // Lost a char!
            return *this;
        }
        while (isdigit(c))
                        // If it was a digit, look for more.
        {
            ++digits;
            tsb.sputc(c);
            c = bp->snextc();
        }
        if (c == '.')
        {
                        // Keep the decimal point and look for more digits
            --digits;
            ++got;
            do
            {
                ++digits;
                tsb.sputc(c);
                c = bp->snextc();
            } while (isdigit(c));
        }
        if (c == 'e' || c == 'E')
        {
            if (digits < 1) {
                state |= _fail;
                        // Fail because incomplete.
                if (got)
                    state |= _bad;
                        // Have -E - characters lost!
                return *this;
            }
            tsb.sputc(c);
                        // Remember the E,
            c = bp->snextc();
            switch (c)
            {
                        // then look for a signed integer.
                case '+':
                case '-':
                    tsb.sputc(c);
                    c = bp->snextc();
                    break;
                case EOF:
                    state = _eof | _fail | _bad;
                        // Fail because incomplete, and bad - chars lost!
                    return *this;
            }
            if (!isdigit(c)) {
                state = _fail | _bad;
                        // Fail because incomplete and chars lost.
                return *this;
            }
            do {        // Take digits while any more.
                tsb.sputc(c);
                c = bp->snextc();
            } while (isdigit(c));
        }
        tsb.sputc(0);   // Terminate for atof.
        rd = atof(buf); // Do the conversion
        if (c == EOF)
            state |= _eof;
    }
    return *this;
}

#endif

/////////////////////////////////
// Copy istream to sb until EOF.
// whitespace and all.

#if Ain10

istream& istream::operator>>(streambuf& sb)
{
    if (tied_to)
        tied_to->flush();
    if (!good())
        state |= _fail;
    else
    {
        int c = bp->sgetc();
        if (c == EOF)
            state |= _eof | _fail;
        else {
            while (c != EOF && sb.sputc(c) != EOF)
                c = bp->snextc();
            if (c == EOF)
                state |= _eof;
        }
    }
    return *this;
}

#endif

//////////////////////////////////////////////
// Read string.
// Input:
//    Pointer to string to be filled in, it will get a terminating 0,
//    unless fail(). If stream is EOF at the start, get() will fail().
//    len - Max length of string, including terminating string
//    tc - Character that terminates the input, which is then
//         left unread (and isn't put in *p).
//         EOF also terminates the input
//

#if Ain11

istream& istream::get(char *p,int len,char tc)
{
    if (tied_to)
        tied_to->flush();

    if (!good())
        state |= _fail;
    else
    {
        int c = bp->sgetc();
        if (c == EOF)
            state |= _eof | _fail;
        else {
            while (tc != c && c != EOF && len > 1)
            {
                *p++ = c;
                c = bp->snextc();
                --len;
            }
            *p = 0;
            if (c == EOF)
                state |= _eof;
        }
    }
    return *this;
}

#endif

////////////////////////////////////////
// Stuff character back into the input.
// Doesn't work for EOFs.
//

#if Ain12

istream& istream::putback(char c)
{
    bp->sputbackc(c);
    return *this;
}

#endif

/*****************************
 * Read from istream and put the results into sb until EOF or
 * char c is seen.
 */

#if Ain13

istream& istream::get(streambuf& sb, char c)
{
    if (tied_to)
        tied_to->flush();

    if (!good())
        state |= _fail;
    else {
        int xc = bp->sgetc();
        if (xc == EOF)
            state |= _eof | _fail;
        else {
            while (c != xc && xc != EOF && sb.sputc(xc) != EOF)
                xc = bp->snextc();
            if (xc == EOF)
                state |= _eof;
        }
    }
    return *this;
}

#endif

#if Ain14

istream& istream::get(char& c)
{
    int os = skipws;
    skipws = 0;
    *this >> c;
    skipws = os;
    return *this;
}

#endif

#if Ain15

ostream* istream::tie(ostream *os)
{
    ostream *old = tied_to;
    tied_to = os;
    return old;
}
#endif

#if Ain16

istream::istream(int len, char *string, int s)
{
    state = _good;
    skipws = s;
    tied_to = NULL;
    bp = new streambuf();
    alloc = 1;
    if (string) {
        len = len? len: strlen(string);
          // If no length use length of string.
        bp->setbuf(string, len, len);
    } // else just leave the streambuf with NULL pointers
}
#endif

#if Ain17

istream::istream(streambuf *sb, int s, ostream *os)
{
    state = _good;
    skipws = s;
    tied_to = os;
    bp = sb;
    alloc = 0;
}
#endif

#if Ain18

istream::istream(int fd, int s, ostream *os)
{
    state = _good;
    skipws = s;
    tied_to = os;
    bp = new filebuf(fd);
    alloc = 1;
}
#endif

#if Ain19

int istream::skip(int s)
{
    int oldval = skipws;
    skipws = s;
    return oldval;
}
#endif

#if Ain20

istream::~istream()
{
    if (alloc)
        delete bp;
}
#endif
