/* Copyright (C) 1984 by Manx Software Systems, Inc. */
/*
 * 	if flg is zero turn on inverse
 */

extern int _attrib;

scr_invers(flg)
int flg;
{
	_attrib = flg ? 0x70 : 0x07;
	return(0);
}
