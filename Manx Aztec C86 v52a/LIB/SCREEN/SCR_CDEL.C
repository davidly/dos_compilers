/* Copyright (C) 1984 by Manx Software Systems, Inc. */
/*
 *	delete the char. at the cursor and put blank at end of line
 */

#define max_width 80

extern int _attrib;

scr_cdelete()
{
	register unsigned ch, x;
	int lin, col;

	scr_loc(&lin, &col);
	for (x = col ; x < max_width-1 ; ++x) {
		scr_curs(lin, x+1);
		ch = scr_call(0x0800,0,0,0);	/* read out current char */
		scr_curs(lin, x);
		scr_call(0x0900 | (ch&255), ch>>8, 1, 0); /* and shift over */
	}
	scr_curs(lin, max_width-1);
	scr_call(0x920, _attrib, 1, 0);	/* put a blank at end of line */
	scr_curs(lin, col);
	return(0);
}
