/*	bios.h

	Access to bios services.

	Copyright (c) Borland International 1987,1988
	All Rights Reserved.
*/
#if __STDC__
#define _Cdecl
#else
#define _Cdecl	cdecl
#endif

int	_Cdecl bioscom(int cmd, char abyte, int port);
int	_Cdecl biosdisk(int cmd, int drive, int head, int track, int sector,
			int nsects, void *buffer);
int	_Cdecl biosequip(void);
int	_Cdecl bioskey(int cmd);
int	_Cdecl biosmemory(void);
int	_Cdecl biosprint(int cmd, int abyte, int port);
long	_Cdecl biostime(int cmd, long newtime);
