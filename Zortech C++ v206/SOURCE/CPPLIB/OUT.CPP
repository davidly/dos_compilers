/*_ out.cpp   Wed Mar 23 1988   Modified by: Walter Bright */
/* Copyright (C) 1988 by Walter Bright		*/
/* All Rights Reserved					*/
/* Written by Walter Bright				*/
/* Stream I/O output routines				*/

#include	<stdarg.h>
#include	<ctype.h>
#include	<stream.hpp>

#if Aout1

filebuf cout_file(stdout);
ostream cout(&cout_file);

filebuf cerr_file(stderr);
ostream cerr(&cerr_file);

filebuf cprn_file(stdprn);
ostream cprn(&cprn_file);

filebuf caux_file(stdaux);
ostream caux(&caux_file);

#endif

/***********************************
 * Output a double.
 */

#if Aout2

ostream& ostream::operator<<(double d)
{
    streambuf *sbp;
    char buf[32];
    char *p;

    if (good())
    {
	p = buf;
	sprintf(p,"%g",d);
	sbp = bp;
	while (*p)
	    if (sbp->sputc(*p++) == EOF)
	    {
		state |= _eof | _fail;
		break;
	    }
    }
    return *this;
}

#endif

/***************************
 * Output a long.
 */

#if Aout3

ostream& ostream::operator<<(long val)
{
    streambuf *sbp;
    char buf[sizeof(long) * 3 + 1];
    char *p;

    if (good())
    {
	sbp = bp;

	if (val < 0)
	{
	    sbp->sputc('-');
	    val = -val;
	}

	/* Stuff chars into buf[] */
	p = &buf[sizeof(buf)];
	do
	{	*--p = val % 10 + '0';
		val /= 10;
	} while (val > 0);

	do
	{
		if (sbp->sputc(*p++) == EOF)
		{	state |= _eof | _fail;
			break;
		}
	} while (p != &buf[sizeof(buf)]);
    }
    return *this;
}

#endif

/***********************************
 * Copy stream buffer to output until EOF.
 */

#if Aout4

ostream& ostream::operator<<(const streambuf& rs)
{
    streambuf *sbp;
    int c;

    if (good())
    {
	sbp = bp;
	c = rs.sgetc();
	while (c != EOF)
	{
	    if (sbp->sputc(c) == EOF)
	    {
		state |= _eof | _fail;
		break;
	    }
	    c = rs.snextc();
	}
    }
    return *this;
}

#endif

/***************************
 * Read chars from *pc (excluding the terminating 0) and send them
 * to output stream.
 */

#if Aout5

ostream& ostream::operator<<(const char *pc)
{
    int c;
    streambuf *sbp;

    if (good() && pc)
    {
	sbp = bp;
	while (*pc)
	{
	    c = *pc++;
	    if (sbp->sputc(c) == EOF)
	    {	state |= _eof | _fail;
		break;
	    }
	}
    }
    return *this;
}

#endif

/////////////////////////////////////////
// Stuff char c into output.
//  - redundant in V2.0 but retained for compatibility

#if Aout6

ostream& ostream::put(char c)
{
    if (good())
    {
        if (bp->sputc(c) == EOF)
        state |= _eof | _fail;
    }
    return *this;
}
#endif

#if Aout7

ostream::ostream(streambuf *sb)
{
    state = _good;
    bp = sb;
    alloc = 0;
}

ostream::ostream(int fd)
{
    state = _good;
    bp = new filebuf(fd);
    alloc = 1;  // streambuf dynamically allocated
}

ostream::ostream(int buflen, char *buf)
{
    state = _good;
    bp = new streambuf();
    alloc = 1;  // streambuf dynamically allocated
    bp->setbuf((buf ? buf : new char[buflen]), buflen);
}

#endif

/////////////////////////////////////////////////////////
// Output a char - just the same as ostream::put in V2.0
//

#if Aout8

ostream& ostream::operator<<(char val)
{
    if (good())
    {

        if (bp->sputc(val) == EOF)
            state |= _eof | _fail;
    }
    return *this;
}

#endif
