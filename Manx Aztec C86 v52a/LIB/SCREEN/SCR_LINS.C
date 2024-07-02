/* Copyright (C) 1984 by Manx Software Systems, Inc. */
/*
 *	Inserts blank lines at lin, pushing rest down
 */

extern int _attrib;

scr_linsert()
{
	int lin, col;

	scr_loc(&lin, &col);
	scr_call(0x700 | 1, _attrib<<8, lin<<8, (24<<8) | 79);
	scr_curs(lin, 0);
	return(0);
}
