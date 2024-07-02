/*	MAIN.C

	Alternate, standalone main() file.  Demonstrates
	linking to the startup code without having to link
	to any of the Turbo C library routines.

	Copyright (c) 1987,88 Borland International.  All rights reserved.
*/

/*

Compile and link with:

	tcc -c -ms main
	tasm c0 /D__SMALL__ /D__NOFLOAT /t/mx;
	tasm setargv /D__SMALL__ /t/mx;
	tlink c0 main setargv /c/m,main

For another memory model, replace __SMALL__ with one of
	__MEDIUM__, __COMPACT__, __LARGE__, __HUGE__

If using tiny model, replace __SMALL__ with __TINY__ and run
	exe2bin main.exe main.com
	del main.exe

Resulting main.exe has no references to the library.
Caution: This example works only with no floating point code.
*/

#include <dos.h>
#include <stdlib.h>

void exit(int c)
{ _exit(c);}

void _setenvp(void){}		/* dummy out _setenvp */

unsigned _stklen = 0x200;
unsigned _heaplen = 0;

void main()
{
	/* print Hello, world using int 21, function 9 */
	_DX = (unsigned) "Hello, world.\r\n$";
	_AX = 0x900;
	__int__(0x21);		/* use built-in, inline function */
	exit(0);
}
