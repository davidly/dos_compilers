/*
 * v2tov3.h
 *
 * Defines a group of macros which can be used to ease the problems of
 * porting MS C version 2.0 programs to MS C versions 3.0 and later.
 *
 * Copyright (C) Microsoft Corporation, 1984, 1985, 1986
 *
 */

/* macro to translate the names used to force binary mode for files */

#define O_RAW	O_BINARY

/* macro to translate setnbuf calls to the equivalent setbuf call */

#define setnbuf(stream)	setbuf(stream, NULL)

/* macro to translate stclen calls to the equivalent strlen call */

#define stclen(s)	strlen(s)

/* macro to translate stscmp calls to the equivalent strcmp call */

#define stscmp(s,t)	strcmp(s,t)

/* macro to translate stpchr calls to the equivalent strchr call */

#define stpchr(s,c)	strchr(s,c)

/* macro to translate stpbrk calls to the equivalent strpbrk call */

#define stpbrk(s,b)	strpbrk(s,b)

/* macro to translate stcis calls to the equivalent strspn call */

#define stcis(s1,s2)	strspn(s1,s2)

/* macro to translate stcisn calls to the equivalent strcspn call */

#define stcisn(s1,s2)	strcspn(s1,s2)

/* macro to translate setmem calls to the equivalent memset call */

#define setmem(p, n, c)	memset(p, c, n)

/* macro to translate movmem calls to the equivalent memcpy call */

#define movmem(s, d, n)	memcpy(d, s, n)

/* MS C version 2.0 min, max, and abs macros */

#define max(a,b)	(((a) > (b)) ? (a) : (b))
#define min(a,b)	(((a) < (b)) ? (a) : (b))
#define abs(a)		(((a) < 0) ? -(a) : (a))

/* macros which implement MS C version 2.0's extended ctype macros, iscym and
 * iscysmf
 */
 
#define iscsymf(c)	(isalpha(c) || ((c) == '_'))
#define iscsym(c)	(isalnum(c) || ((c) == '_'))
