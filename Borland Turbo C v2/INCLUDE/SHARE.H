/* 	share.h

	File sharing mode for use with sopen.
	See DOS function 3Dh for definition.

	Copyright (c) Borland International 1987,1988
	All Rights Reserved.
*/
#if __STDC__
#define _Cdecl
#else
#define _Cdecl	cdecl
#endif

#define SH_COMPAT	0x0000
#define SH_DENYRW	0x0010
#define SH_DENYWR	0x0020
#define SH_DENYRD	0x0030
#define SH_DENYNONE	0x0040

#define SH_DENYNO	SH_DENYNONE	/* MS documentation uses both */
