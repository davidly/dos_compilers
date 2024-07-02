/* Copyright (C) 1984 by Manx Software Systems, Inc. */
/*
 *		Clear to the end of line
 */

extern int _attrib;

scr_eol()
{
	int lin, col;

	scr_loc(&lin, &col);
	scr_call(0x920, _attrib, 80-col, 0);
	return(0);
}
