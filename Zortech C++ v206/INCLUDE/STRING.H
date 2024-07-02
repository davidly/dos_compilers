/*_ string.h   Sun Apr  2 1989   Modified by: Walter Bright */

#ifndef __STRING_H
#define __STRING_H	1

#if __cplusplus
extern "C" {
#endif

#define size_t unsigned

#ifdef LPTR
#define NULL 0L
#else
#define NULL 0
#endif

#ifdef __STDC__
#define __CDECL
#else
#define __CDECL cdecl
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
char *  __CDECL index(const char*,int);
int	__CDECL memicmp(const void *,const void *,size_t);
int	__CDECL strcmpl(const char *,const char *);
char *	__CDECL strdup(const char *);
char *	__CDECL strlwr(char *);
char *	__CDECL strupr(char *);
char *	__CDECL strnset(char *,int,size_t);
char *	__CDECL strrev(char *);
char *	__CDECL strset(char *,int);
void	__CDECL swab(char *,char *,size_t);
void	__CDECL movedata(unsigned,unsigned,unsigned,unsigned,size_t);
extern int __CDECL sys_nerr;
extern char * __CDECL sys_errlist[];
#endif

#if __cplusplus
}
#endif

#endif /* __STRING_H */
