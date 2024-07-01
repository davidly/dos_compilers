/*	alloc.h

	memory management functions and variables.

	Copyright (c) Borland International 1987
	All Rights Reserved.
*/
#if __STDC__
#define _Cdecl
#else
#define _Cdecl	cdecl
#endif

int	_Cdecl brk(char *addr);
void	*_Cdecl calloc(unsigned nitems, unsigned size);

#if defined(__COMPACT__) || defined(__LARGE__) || defined(__HUGE__)
unsigned long _Cdecl coreleft(void);
#else
unsigned _Cdecl coreleft(void);
#endif

void	 _Cdecl free(void *block);
void	*_Cdecl malloc(unsigned size);
void	*_Cdecl realloc(void *block, unsigned size);
void	*_Cdecl sbrk(int incr);

#if !__STDC__
void	far * _Cdecl farcalloc(unsigned long nunits, unsigned long unitsz);
unsigned long _Cdecl farcoreleft(void);
void	_Cdecl farfree(void far *block);
void	far* _Cdecl farmalloc(unsigned long nbytes);
void	far* _Cdecl farrealloc(void far* oldblock, unsigned long nbytes);
#endif
