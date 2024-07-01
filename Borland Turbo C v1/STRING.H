/*	string.h

	Definitions for memory and string functions.

	Copyright (c) Borland International 1987
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

void	*_Cdecl memchr(void *s, unsigned char c, unsigned n);
int	 _Cdecl memcmp(void *s1, void *s2, unsigned n);
void	*_Cdecl memcpy(void *dest, void *src, unsigned n);
void	*_Cdecl memset(void *s, unsigned char c, unsigned n);
void	*_Cdecl memccpy(void *dest, void *src, unsigned char c, unsigned n);
void	*_Cdecl memmove(void *dest, void *src, unsigned n);
void	 _Cdecl movedata(unsigned srcseg, unsigned srcoff, unsigned dstseg,
			unsigned dstoff, unsigned n);
int	 _Cdecl memicmp(void *s1, void *s2, unsigned n);

char	*_Cdecl strcat(char *dest, char *src);
char	*_Cdecl strchr(char *s, char c);
int	 _Cdecl strcmp(char *s1, char *s2);
int	 _Cdecl stricmp(char *s1, char *s2);
char	*_Cdecl strcpy(char *dest, char *src);
char	*_Cdecl stpcpy(char *dest, char *src);
size_t	 _Cdecl strlen(char *s);
char	*_Cdecl strncat(char *dest, char *src, unsigned maxlen);
int	 _Cdecl strncmp(char *s1, char *s2, unsigned maxlen);
int	 _Cdecl strnicmp(char *s1, char *s2, unsigned maxlen);
char	*_Cdecl strncpy(char *dest, char *src, unsigned maxlen);

char	*_Cdecl strlwr(char *s);
char	*_Cdecl strupr(char *s);
char	*_Cdecl strdup(char *s);
char	*_Cdecl strset(char *s, char ch);
char	*_Cdecl strnset(char *s, char ch, unsigned n);
char	*_Cdecl strrev(char *s);

size_t	 _Cdecl strcspn(char *s1, char *s2);
char	*_Cdecl strpbrk(char *s1, char *s2);
char	*_Cdecl strrchr(char *s, char c);
size_t	 _Cdecl strspn(char *s1, char *s2);
char	*_Cdecl strtok(char *s1, char *s2);
char	*_Cdecl strstr(char *s1, char *s2);
char	*_Cdecl strerror(char *s);

/* compatibility with other compilers */

#define strcmpi(s1,s2)		stricmp(s1,s2)
#define strncmpi(s1,s2,n)	strnicmp(s1,s2,n)
