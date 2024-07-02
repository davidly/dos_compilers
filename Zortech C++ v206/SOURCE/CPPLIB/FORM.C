/*_ form.c   Thu Feb  2 1989   Modified by: Walter Bright */
/* Copyright (C) 1988..1989 by Walter Bright	*/
/* All Rights Reserved					*/
/* Written by Walter Bright				*/
/* Output formatting routines				*/

#include	<stdarg.h>
#include	<ctype.h>
#include	<stdio.h>
#include	<string.h>
#include	<process.h>

/*******************************
 * Circular buffer for the formatting routines.
 * Only 256 chars per format are allowed, and there is room
 * for a minimum of 4 formats.
 */

char staticbuf[1024];
char *pin = staticbuf;
char *pout = &staticbuf[sizeof(staticbuf) - 1];


char *form(const char *format,...)
{	char *pstart;
	int len;

	pstart = pin;
	if (pstart + 256 > pout)	/* ensure at least 256 chars avail */
		pstart = staticbuf;
	len = vsprintf(pstart,format,(va_list)&(format) + sizeof(format));
	if (len >= 256)			/* if wrote past end of buffer	*/
		_exit(1);		/* crash!			*/
	pin = len + pstart + 1;
	return pstart;
}

char *str(const char *s,int field)
{	size_t len;
	char *p;

	len = strlen(s);
	if (field <= 0 || field > 256)
		field = len;
	if (len > field)
		len = field;
	p = pin;
	if (p + field >= pout)
		p = staticbuf;
	p[field] = 0;
	pin = p + field + 1;
	field -= len;
	memset(p,' ',field);
	memcpy(p + field,s,len);
	return p;
}

char *dec(long val,int field)
{	char *p;
	/*       -   digits            0 */
	char buf[1 + sizeof(val) * 3 + 1];
	int len;

	if (field < 0 || field > 256)
		field = 0;
	len = sprintf(buf,"%ld",val);
	p = buf;
	if (field && len > field)
	    p += len - field;
	return str(p,field);
}

char *hex(long val,int field)
{	char *p;
	char buf[sizeof(val) * 2 + 1];
	int len;

	if (field < 0 || field > 256)
		field = 0;
	len = sprintf(buf,"%lx",val);
	p = buf;
	if (field && len > field)
	    p += len - field;
	return str(p,field);
}

char *oct(long val,int field)
{	char *p;
	char buf[sizeof(val) * 3 + 1];
	int len;

	if (field < 0 || field > 256)
		field = 0;
	len = sprintf(buf,"%lo",val);
	p = buf;
	if (field && len > field)
	    p += len - field;
	return str(p,field);
}

char *chr(int c,int field)
{
    char *pstart;
    char *p;

    p = pin;
    if (field <= 0 || field > 256)
	field = 1;
    if (p + field >= pout)
	p = staticbuf;
    pin = p + field + 1;
    pstart = p;
    while (--field)
	    *p++ = ' ';
    if (!isascii(c))
	    c = ' ';
    p[0] = c;
    p[1] = 0;
    return pstart;
}

