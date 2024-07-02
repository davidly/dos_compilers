/*_ string.h   Sun Apr	2 1989	 Modified by: Walter Bright */

#ifndef __STRING_H
#define __STRING_H	1

#if __cplusplus
extern "C" {
#endif

typedef unsigned size_t;

#ifndef NULL
#if __COMPACT__ || __LARGE__ || __VCM__
#define NULL 0L
#else
#define NULL 0
#endif
#endif

#ifdef __STDC__
#define __CDECL
#else
#define __CDECL _cdecl
#endif

void *	__CDECL memcpy(void *,const void *,size_t);
void *	__CDECL memmove(void *,const void *,size_t);
char *	__CDECL strcpy(char *,const char *);
char *	__CDECL strncpy(char *,const char *,size_t);
char *	__CDECL strcat(char *,const char *);
char *	__CDECL strncat(char *,const char *,size_t);
int	__CDECL memcmp(const void *,const void *,size_t);
int	__CDECL strcmp(const char *,const char *);
int	__CDECL strcoll(const char *,const char *);
int	__CDECL strncmp(const char *,const char *,size_t);
size_t	__CDECL strxfrm(char *,const char *,size_t);
void *	__CDECL memchr(const void *,int,size_t);
char *	__CDECL strchr(const char *,int);
size_t	__CDECL strcspn(const char *,const char *);
char *	__CDECL strpbrk(const char *,const char *);
char *	__CDECL strrchr(const char *,int);
size_t	__CDECL strspn(const char *,const char *);
char *	__CDECL strstr(const char *,const char *);
char *	__CDECL strtok(char *,const char *);
void *	__CDECL memset(void *,int,size_t);
char *	__CDECL strerror(int);
size_t	__CDECL strlen(const char *);

#if !__STDC__
int	__CDECL *_memintset(int *, int, size_t);
int	__CDECL memicmp(const void *,const void *,size_t);
char *	__CDECL stpcpy(char *,const char *);
int	__CDECL strcmpl(const char *,const char *);
int	__CDECL strnicmp(const char *, const char *, size_t);
char *	__CDECL strdup(const char *);
char *	__CDECL strlwr(char *);
char *	__CDECL strupr(char *);
char *	__CDECL strnset(char *,int,size_t);
char *	__CDECL strrev(char *);
char *	__CDECL strset(char *,int);
void	__CDECL swab(char *,char *,size_t);
void	__CDECL movedata(unsigned short srcseg,unsigned srcoff,unsigned short destseg,unsigned destoff,size_t nbytes);
extern int __CDECL sys_nerr;
extern char * __CDECL sys_errlist[];

#if 0	/* removed, use strchr() instead */
char *	__CDECL index(const char *,int);
#endif

#endif

#if __cplusplus
}
#endif

#endif /* __STRING_H */
