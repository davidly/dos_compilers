/*	limits.h

	Defines implementation specific limits on type values.

	Copyright (c) Borland International 1987,1988
	All Rights Reserved.
*/
#if __STDC__
#define _Cdecl
#else
#define _Cdecl	cdecl
#endif

#define CHAR_BIT			8

#if (((int)((char)0x80)) < 0)
#define CHAR_MAX			0x7F
#define CHAR_MIN			0x80
#else
#define CHAR_MAX			0xFFU
#define CHAR_MIN			0x00
#endif

#define SCHAR_MAX			0x7F
#define SCHAR_MIN			-128
#define UCHAR_MAX			0xFFU

#define SHRT_MAX			0x7FFF
#define SHRT_MIN			((int)0x8000)
#define USHRT_MAX			0xFFFFU

#define INT_MAX				0x7FFF
#define INT_MIN				((int)0x8000)
#define UINT_MAX			0xFFFFU

#define LONG_MAX			0x7FFFFFFFL
#define LONG_MIN			((long)0x80000000L)
#define ULONG_MAX			0xFFFFFFFFUL
