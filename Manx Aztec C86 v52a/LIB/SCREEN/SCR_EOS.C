/* Copyright (C) 1984 by Manx Software Systems, Inc. */
/*
 *		clear to end of screen
 */

extern int _attrib;

scr_eos()
{
	int lin, col;

	scr_loc(&lin, &col);
	scr_call(0x920, _attrib, (80-col)+((24-lin)*80), 0);
	return(0);
}
