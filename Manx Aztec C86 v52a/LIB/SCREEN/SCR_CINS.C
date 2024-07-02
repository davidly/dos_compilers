/* Copyright (C) 1984 by Manx Software Systems, Inc. */
/*
 *	insert a space at the cursor and delete the char. at end of line
 */

#define max_width 80
extern int _attrib;

scr_cinsert()
{
	register unsigned ch, z;
	int lin, col;

	scr_loc(&lin, &col);
	for (z = max_width - 1 ; z > col ; --z) {
		scr_curs(lin, z-1);
		ch = scr_call(0x0800,0,0,0);	/* read out current char */
		scr_curs(lin, z);
		scr_call(0x0900 | (ch&255), ch>>8, 1, 0); /* and move it right */
	}
	scr_curs(lin, col);
	scr_call(0x920,_attrib,1,0);
	return(0);
}
