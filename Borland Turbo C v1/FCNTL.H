/*	fcntl.h

	Define flag values accessible to open.

	Copyright (c) Borland International 1987
	All Rights Reserved.
*/
#if __STDC__
#define _Cdecl
#else
#define _Cdecl	cdecl
#endif

extern unsigned _Cdecl _fmode;

/* The first three can only be set by open */

#define O_RDONLY	     1
#define O_WRONLY	     2
#define O_RDWR		     4

/* Flag values for open only */

#define O_CREAT		0x0100	/* create and open file */
#define O_TRUNC		0x0200	/* open with truncation */
#define O_EXCL		0x0400	/* exclusive open */
#define O_APPEND	0x0800	/* to end of file */

/* MSDOS special bits */

#define O_CHANGED	0x1000	/* user may read these bits, but	*/
#define O_DEVICE	0x2000	/*   only RTL\io functions may touch.	*/
#define O_TEXT		0x4000	/* CR-LF translation	*/
#define O_BINARY	0x8000	/* no translation	*/

/* DOS 3.x options */

#define O_NOINHERIT	0x80
#define O_DENYALL	0x10
#define O_DENYWRITE	0x20
#define O_DENYREAD	0x30
#define O_DENYNONE	0x40
