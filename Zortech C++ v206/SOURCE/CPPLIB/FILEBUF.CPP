//_ filebuf.c   Sat Jan  2 1988   Modified by: Walter Bright
//              Fri Aug 18 1989   Modified by: Steve Teale
//  Copyright (C) 1988-1989 by Walter Bright
//  All rights reserved

/* Implementation of member functions for class filebuf	*/

#include	<stream.hpp>
#include	<io.h>
#include	<fcntl.h>
#include	<string.h>

/////////////////////////////
// Open a file.
// Returns:
//	this	success
//	NULL	failure

filebuf *filebuf::open(char *name,open_mode om)
{
    switch (om)
    {
    case input:
        fd = ::open(name,O_RDONLY); // call C standard open()
        break;
    case append:
        fd = ::open(name,O_RDWR);
        if (fd == -1)
            goto L1;                // try creating it
        lseek(fd,0L,SEEK_END);      // to end of file
        break;
    case output:
    L1:
        fd = creat(name,0);
        break;
    }
    if (fd == -1)
        return NULL;
    opened = 1;     // non-zero indicating file is open
    return this;
}

int filebuf::close()
{
    if (fp)
        return 0;
    if (opened) {
        overflow();
        opened = 0;
        return::close(fd);
    }
}

///////////////////////////////
// Empty buffer.
// Returns:
//	0	success
//	EOF	failure

int filebuf::overflow(int c)
{
    if (fp)
        return fflush(fp);
    if (opened == 0)        // if file is not open
        return EOF;
    if (!base)              // if no buffer
        allocate();         // try to allocate one
// if allocate fails we stagger on unbuffered!
    if (base == eptr)       // allocate failed
    {
        if (c != EOF) {
            if (write(fd,&c,1) != 1)
                return EOF;
        }
    } else {
        if (pptr > base) {  // if anything to write
            if (write(fd,base,pptr - base) != pptr - base)
                return EOF;
        }
        gptr = base;
        pptr = base;
        if (c != EOF) {
            pptr++;
            *base = c;
        }
    }
    return (unsigned char) c;
}

////////////////////////////////
// Fill buffer.
// Returns:
//	EOF	failure
//	next char on success

int filebuf::underflow()
{
    if (!base)      // if no buffer try allocate one
        allocate();
// If no buffer available soldier on unbuffered
    unsigned char unbuf;
    char *p = base? base+1: (char *) &unbuf; 
    int len = base? eptr-base-1: 1;
    if (fp) {       // layer over stdio
        if (fgets(p,len,fp) == 0)
                    // input line by line
            return EOF;
        len = strlen(base + 1);
    } else {
        if (opened == 0)    // no file
            return EOF;
        len = read(fd,p,len);
        if (len < 1)        // error or no more input
            return EOF;
    }
    if (base) {             // adjust pointers
        gptr = base + 1;    // leaves room for a 'putback'
        pptr = gptr + len;
        return (unsigned char) *gptr;
    } else
        return unbuf;       // unbuffered
}
