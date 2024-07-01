/*	mem.h

	Memory manipulation functions

	Copyright (c) Borland International 1987
	All Rights Reserved.
*/
#if __STDC__
#define _Cdecl
#else
#define _Cdecl	cdecl
#endif

void	*_Cdecl  memchr(void *s, unsigned char c, unsigned n);
int	 _Cdecl  memcmp(void *s1, void *s2, unsigned n);
void	*_Cdecl  memcpy(void *dest, void *src, unsigned n);
void	*_Cdecl  memset(void *s, unsigned char c, unsigned n);
void	*_Cdecl  memccpy(void *dest, void *src, unsigned char c, unsigned n);
void	*_Cdecl  memmove(void *dest, void *src, unsigned n);
int	 _Cdecl  memicmp(void *s1, void *s2, unsigned n);
void	 _Cdecl  movebytes(void *src, void *dst, unsigned n);
void	 _Cdecl  movedata(unsigned srcseg, unsigned srcoff, unsigned dstseg,
			unsigned dstoff, unsigned n);
void	 _Cdecl  movmem(void *src, void *dest, unsigned length);
void	 _Cdecl  setmem(void *dest, unsigned length, char value);
