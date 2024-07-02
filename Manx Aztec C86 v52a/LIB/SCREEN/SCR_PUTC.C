/* Copyright (C) 1984 by Manx Software Systems, Inc. */
/*
 *	display the character at the cursor
 */

int _attrib = 0x07;

scr_putc(c)
register int c;
{
	c &= 255;
	if (c >= 0x20)
		scr_call(0x0900 | c, _attrib,1,0);
	scr_call(0x0e00 | c, _attrib);
	return c;
}
