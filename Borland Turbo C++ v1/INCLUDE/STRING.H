/*	string.h

	Definitions for memory and string functions.

        Copyright (c) Borland International 1987,1988,1990
	All Rights Reserved.
*/

#ifndef __STRING_H
#define __STRING_H

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

#ifndef NULL
#if defined(__TINY__) || defined(__SMALL__) || defined(__MEDIUM__)
#define	NULL	0
#else
#define	NULL	0L
#endif
#endif

#ifndef _SIZE_T
#define _SIZE_T
typedef unsigned size_t;
#endif

#ifdef __cplusplus
extern "C" {
#endif
void   *_Cdecl memchr	(const void *__s, int __c, size_t __n);
int	    _Cdecl memcmp	(const void *__s1, const void *__s2, size_t __n);
void   *_Cdecl memcpy	(void *__dest, const void *__src, size_t __n);
void   *_CType memmove	(void *__dest, const void *__src, size_t __n);
void   *_CType memset	(void *__s, int __c, size_t __n);
char   *_CType strcat	(char *__dest, const char *__src);
char   *_Cdecl strchr	(const char *__s, int __c);
int	    _CType strcmp	(const char *__s1, const char *__s2);
int	    _Cdecl strcoll	(const char *__s1, const char *__s2);
char   *_CType strcpy	(char *__dest, const char *__src);
size_t  _Cdecl strcspn	(const char *__s1, const char *__s2);
char   *_Cdecl strerror (int __errnum);
size_t  _CType strlen	(const char *__s);
char   *_Cdecl strncat	(char *__dest, const char *__src, size_t __maxlen);
int	    _Cdecl strncmp	(const char *__s1, const char *__s2, size_t __maxlen);
char   *_CType strncpy	(char *__dest, const char *__src, size_t __maxlen);
char   *_Cdecl strpbrk	(const char *__s1, const char *__s2);
char   *_CType strrchr	(const char *__s, int __c);
size_t  _Cdecl strspn	(const char *__s1, const char *__s2);
char   *_Cdecl strstr	(const char *__s1, const char *__s2);
char   *_Cdecl strtok	(char *__s1, const char *__s2);
size_t  _Cdecl strxfrm  (char *__s1, const char *__s2, size_t __n );
char   *_Cdecl _strerror (const char *__s);


#if !__STDC__
/* compatibility with other compilers */
#define strcmpi(s1,s2)		stricmp(s1,s2)
#define strncmpi(s1,s2,n)	strnicmp(s1,s2,n)

void   *_Cdecl memccpy	(void *__dest, const void *__src, int __c, size_t __n);
int	    _Cdecl memicmp	(const void *__s1, const void *__s2, size_t __n);
void    _Cdecl movedata (unsigned __srcseg, unsigned __srcoff, unsigned __dstseg,
	                     unsigned __dstoff, size_t __n);
char   *_Cdecl stpcpy	(char *__dest, const char *__src);
char   *_Cdecl strdup	(const char *__s);
int	    _CType stricmp	(const char *__s1, const char *__s2);
char   *_Cdecl strlwr	(char *__s);
int	    _Cdecl strnicmp (const char *__s1, const char *__s2, size_t __maxlen);
char   *_Cdecl strnset	(char *__s, int __ch, size_t __n);
char   *_Cdecl strrev	(char *__s);
char   *_Cdecl strset	(char *__s, int __ch);
char   *_Cdecl strupr	(char *__s);
#endif

#ifdef __cplusplus
}
#endif

#endif
