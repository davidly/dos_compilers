/*	bios.h

	Access to bios services.

        Copyright (c) Borland International 1987,1988,1990
	All Rights Reserved.
*/
#if __STDC__
#define _Cdecl
#else
#define _Cdecl	cdecl
#endif

#ifndef __PAS__
#define _CType _Cdecl
#else
#define _CType pascal
#endif

#ifdef __cplusplus
extern "C" {
#endif
int	_Cdecl bioscom(int __cmd, char __abyte, int __port);
int	_Cdecl biosdisk(int __cmd, int __drive, int __head, int __track, int __sector,
			int __nsects, void *__buffer);
int	_Cdecl biosequip(void);
int	_Cdecl bioskey(int __cmd);
int	_Cdecl biosmemory(void);
int	_Cdecl biosprint(int __cmd, int __abyte, int __port);
long	_Cdecl biostime(int __cmd, long __newtime);
#ifdef __cplusplus
}
#endif
