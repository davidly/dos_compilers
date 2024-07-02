/* Copyright (C) 1984 by Manx Software Systems, Inc. */
/*
 * 	Deletes  line at lin, blank lines at bottom
 */

extern int _attrib;

scr_ldelete()
{
	int lin, col;

	scr_loc(&lin, &col);
	scr_call(0x600 | 1, _attrib<<8, lin<<8, (24<<8) | 79);
	scr_curs(lin, 0);
	return(0);
}
