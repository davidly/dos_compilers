/* string.h - string function prototypes
 * $Version: 1.28 $
 * Copyright (c) 1984,85,86,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
 * Copyright (c) 1988,89, 90 Intel Corporation, ALL RIGHTS RESERVED.
 */

#ifndef _stringh
#define _stringh
/*lint -library */

#pragma fixedparams("memchr",   "memcmp",   "memcpy",  "memset",  "memmove")
#pragma fixedparams("strcat",   "strchr",   "strcmp",  "strcpy",  "strcspn")
#pragma fixedparams("strlen",   "strncat",  "strncmp", "strncpy", "strpbrk")
#pragma fixedparams("strrchr",  "strspn",   "strstr",  "strtok",  "strcoll")
#pragma fixedparams("strxfrm")
#pragma fixedparams("movedata", "strerror")
#pragma fixedparams("memccpy",  "memicmp",  "strcmpi", "strdup",  "stricmp")
#pragma fixedparams("strlwr",   "strnicmp", "strnset", "strrev",  "strset")
#pragma fixedparams("strupr",   "udistr")
#pragma fixedparams("cstr") 

#ifndef NULL
#define NULL ((void *)0)
#endif

#ifndef _size_t
#define _size_t
typedef unsigned size_t;
#endif

/*
 * Function prototypes:
 */
char *cstr(char *, const char *);
void  *memccpy(void *, const void *, int, int);
void  *memchr(const void *, int, size_t);
int    memcmp(const void*, const void*, size_t);
void  *memcpy(void*, const void*, size_t);
int    memicmp(const void *, const void *, unsigned);
void  *memmove(void *, const void *, size_t);
void  *memset(void*, int, size_t);
void   movedata(unsigned, unsigned, unsigned, unsigned, unsigned);
char  *strcat(char *, const char *);
char  *strchr(const char *, int);
int    strcmp(const char *, const char *);
int    strcmpi(const char *, const char *);
int    strcoll(const char *, const char *);
char  *strcpy(char*, const char*);
size_t strcspn(const char *, const char *);
char  *strdup(const char *);
char  *strerror(int);
int    stricmp(const char *, const char *);
size_t strlen(const char *);
char  *strlwr(char *);
char  *strncat(char *, const char *, size_t);
int    strncmp(const char *, const char *, size_t);
char  *strncpy(char *, const char *, size_t);
int    strnicmp(const char *, const char *, size_t);
char  *strnset(char *, int, size_t);
char  *strpbrk(const char *, const char *);
char  *strrchr(const char *, int);
char  *strrev(char *);
char  *strset(char *, int);
size_t strspn(const char *, const char *);
char  *strstr(const char *, const char *);
char  *strtok(char *, const char *);
char  *strupr(char *);
size_t strxfrm(char *, const char *, size_t);
char *udistr(char *, const char *);

/*
 * Compiler built-in functions:
 */
#ifndef _stringh_builtin
#define _stringh_builtin

#pragma _builtin_("_memcpy_"==64)
void *_memcpy_(void*, const void*, size_t);
#define memcpy(x,y,z) _memcpy_(x,y,z)

#pragma _builtin_("_memset_"==65)
void *_memset_(void*, int, size_t);
#define memset(x,y,z) _memset_(x,y,z)

#pragma _builtin_("_strcpy_"==71)
char *_strcpy_(char*, const char*);
#define strcpy(x,y)  _strcpy_(x,y)

#endif /* _stringh_builtin */

#endif /* _stringh */
