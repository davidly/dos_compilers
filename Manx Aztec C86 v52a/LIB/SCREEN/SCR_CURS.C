/* Copyright (C) 1984 by Manx Software Systems, Inc. */
/*
 * 	Moves cursor to line lin, position pos
 */

#define max_width 80

scr_curs(lin, col)
register int lin, col;
{
	if (col >= max_width)
		col = max_width - 1;
	if (lin >= 25)
		lin = 24;
	scr_call(0x200, 0, 0, (lin << 8) | col);
	return(0);
}
