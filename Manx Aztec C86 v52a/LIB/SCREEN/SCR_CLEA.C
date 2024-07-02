/* Copyright (C) 1984 by Manx Software Systems, Inc. */
/*
 *	Clears the screen and homes the cursor
 */

#define max_width  80
#define max_y  25

extern int _attrib;

scr_clear()
{
	scr_home();
	scr_call(0x920,_attrib,(max_width * max_y),0);
	return(0);
}
