/*	string.h

	Definitions for memory and string functions.

	Copyright (c) Borland International 1987,1988
	All Rights Reserved.
*/
#if __STDC__
#define _Cdecl
#else
#define _Cdecl	cdecl
#endif

#ifndef _SIZE_T
#define _SIZE_T
typedef unsigned size_t;
#endif

void	*_Cdecl memccpy	(void *dest, const void *src, int c, size_t n);
void	*_Cdecl memchr	(const void *s, int c, size_t n);
int	 _Cdecl memcmp	(const void *s1, const void *s2, size_t n);
void	*_Cdecl memcpy	(void *dest, const void *src, size_t n);
int	 _Cdecl memicmp	(const void *s1, const void *s2, size_t n);
void	*_Cdecl memmove	(void *dest, const void *src, size_t n);
void	*_Cdecl memset	(void *s, int c, size_t n);
void	 _Cdecl movedata(unsigned srcseg, unsigned srcoff, unsigned dstseg,
			 unsigned dstoff, size_t n);
char	*_Cdecl stpcpy	(char *dest, const char *src);
char	*_Cdecl strcat	(char *dest, const char *src);
char	*_Cdecl strchr	(const char *s, int c);
int	 _Cdecl strcmp	(const char *s1, const char *s2);
char	*_Cdecl strcpy	(char *dest, const char *src);
size_t	 _Cdecl strcspn	(const char *s1, const char *s2);
char	*_Cdecl strdup	(const char *s);
char	*_Cdecl strerror(int errnum);
int	 _Cdecl stricmp	(const char *s1, const char *s2);
size_t	 _Cdecl strlen	(const char *s);
char	*_Cdecl strlwr	(char *s);
char	*_Cdecl strncat	(char *dest, const char *src, size_t maxlen);
int	 _Cdecl strncmp	(const char *s1, const char *s2, size_t maxlen);
char	*_Cdecl strncpy	(char *dest, const char *src, size_t maxlen);
int	 _Cdecl strnicmp(const char *s1, const char *s2, size_t maxlen);
char	*_Cdecl strnset	(char *s, int ch, size_t n);
char	*_Cdecl strpbrk	(const char *s1, const char *s2);
char	*_Cdecl strrchr	(const char *s, int c);
char	*_Cdecl strrev	(char *s);
char	*_Cdecl strset	(char *s, int ch);
size_t	 _Cdecl strspn	(const char *s1, const char *s2);
char	*_Cdecl strstr	(const char *s1, const char *s2);
char	*_Cdecl strtok	(char *s1, const char *s2);
char	*_Cdecl strupr	(char *s);

/* compatibility with other compilers */

#define strcmpi(s1,s2)		stricmp(s1,s2)
#define strncmpi(s1,s2,n)	strnicmp(s1,s2,n)

#if !__STDC__
char	*_Cdecl _strerror (const char *s);
#endif
