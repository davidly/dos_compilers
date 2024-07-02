/* Copyright (C) 1984 by Manx Software Systems, Inc. */
/*
 *	if flg is zero disable echoing of characters
 */

extern int _echo;

scr_echo(flg)
int flg;
{
	_echo = flg;
	return(0);
}
