/*_ strings2.c   Sun Apr 16 1989   Modified by: Walter Bright */
/* Copyright (C) 1985-1989 by Northwest Software	*/
/* All Rights Reserved					*/
/* Written by Walter Bright				*/

/* More obscure string functions		*/

#include	<stdio.h>
#include	<ctype.h>
#include	<stddef.h>
#include	<string.h>
#include	<stdlib.h>

/**************************
 * Search for char c in first n bytes pointed to by p.
 * Returns:
 *	pointer to char found, else NULL.
 */

#if Amemchr

void *memchr(p,c,n)
int c;
const void *p;
size_t n;
{
	while (n--)
	{	if (*(const char *)p == c)
			return (void *) p;
		p++;
	}
	return NULL;			/* didn't find it		*/
}

#endif /* MEMCHR */


/**************************
 */

#if Astrcspn

size_t strcspn(p1,p2)
const char *p1,*p2;
{	const char *p1start = p1;
	const char *p2start = p2;

	while (*p1)
	{	while (*p2)
		{	if (*p2 == *p1)
				goto L1;
			p2++;
		}
		p2 = p2start;
		p1++;
	}
    L1:
	return p1 - p1start;
}

#endif

/***********************
 * Return pointer to first occurrence in string p1 of any of the characters
 * in the string p2. Return NULL if no occurrences are found.
 */

#if Astrpbrk

char *strpbrk(p1,p2)
const char *p1,*p2;
{	const char *p2start = p2;

	while (*p1)
	{	while (*p2)
		{	if (*p2 == *p1)
				return (void *) p1;
			p2++;
		}
		p2 = p2start;
		p1++;
	}
	return NULL;
}

#endif

/***********************
 * Find last occurrence of char c in string p.
 * Returns:
 *	pointer to last occurrence
 *	NULL if not found
 */

#if Astrrchr

char *strrchr(p,c)
register const char *p;
int c;
{	register const char *pstart = p;

	p += strlen(p) - 1;		/* don't point at terminating 0	*/
	while (p >= pstart)
	{	if (*p == c)
			return (void *) p;
		p--;
	}
	return (char *) NULL;
}

#endif

/**************************
 */

#if Astrspn

size_t strspn(p1,p2)
const char *p1,*p2;
{	const char *p1start = p1;
	const char *p2start = p2;

	while (*p1)
	{	while (*p2)
		{	if (*p2 == *p1)
				goto L1;;
			p2++;
		}
		break;			/* it's not in p2		*/
	    L1:
		p2 = p2start;
		p1++;
	}
	return p1 - p1start;
}

#endif

/************************
 */

#if Astrtok

char *strtok(p1,p2)
char *p1;
const char *p2;
{	static char *s = NULL;
	const char *p2start = p2;

	if (!p1)
	{	p1 = s;			/* use old value		*/
		if (!p1)
			return (char *) NULL;
	}
	p1 += strspn(p1,p2);		/* find first char of token	*/
	if (!*p1)
		return (char *) NULL;
	s = strpbrk(p1,p2);		/* find end of token		*/
	if (s)				/* if there was an end		*/
	{	*s = 0;			/* terminate the token		*/
		s++;			/* start of next token		*/
	}
	return p1;
}

#endif

/************************
 */

#if Astrdup

char *strdup(p)
const char *p;
{	char *pnew;

	pnew = malloc(strlen(p) + 1);
	if (pnew)
		strcpy(pnew,p);
	return pnew;
}

#endif

/*************************
 * Compare strings, ignoring differences in case.
 */

#if 0 /* redone in assembly in strings.asm */
int strcmpl(p1,p2)
register const char *p1,*p2;
{
	while (*p1 && *p2)
	{	if (*p1 != *p2)
		{	if (isalpha(*p1) && isalpha(*p2))
			{	int i;

				i = toupper(*p1) - toupper(*p2);
				if (i)
					return i;
			}
			else
				break;
		}
		p1++;
		p2++;
	}
	return *p1 - *p2;
}
#endif

/******************************
 * Convert string p to lower case.
 * Returns:
 *	p
 */

#if Astrlwr

char *strlwr(char *p)
{	char *pold = p;

	while (*p)
	{	*p = tolower(*p);
		p++;
	}
	return pold;
}

#endif

/*************************
 * Convert string p to upper case.
 * Returns:
 *	p
 */

#if Astrupr

char *strupr(char *p)
{	char *pold = p;

	while (*p)
	{	*p = toupper(*p);
		p++;
	}
	return pold;
}

#endif

/***********************
 */

#if Astrnset

char *strnset(char *p,int c,size_t n)
{	char *pstart = p;

	while (n-- && *p)
		*p++ = c;
	return pstart;
}

#endif

/**********************
 * Reverse the characters in the string p.
 * Returns:
 *	p
 */

#if Astrrev

char *strrev(char *p)
{	char *pend,*pstart = p;

	pend = p + strlen(p) - 1;
	while (p < pend)
	{	*p ^= *pend;
		*pend ^= *p;
		*p++ ^= *pend--;	/* swap *p and *pend		*/
	}
	return pstart;
}

#endif

/********************
 * Set all the characters in string p to c.
 */

#if Astrset

char *strset(char *p,int c)
{	char *pstart = p;

	while (*p)
		*p++ = c;
	return pstart;
}

#endif

/*********************
 */

#if Aswab

void swab(char *src,char *dst,size_t n)
{	char c;

	n >>= 1;
	while (n--)
	{	c = src[0];	/* in case src and dst are the same	*/
		dst[0] = src[1];
		dst[1] = c;
		dst += 2;
		src += 2;
	}
}

#endif

/**********************************
 * Return pointer to first occurrence of string s2 in s1.
 * Return NULL if s1 is not in s2.
 */

#if Astrstr

char *strstr(const char *s1,const char *s2)
{	size_t len1;

	len1 = strlen(s2);
	if (len1 == 0)
	    return (void *) s1;
	while (*s1)
	{
	    if (*s2 == *s1)
		if (strncmp(s2,s1,len1) == 0)
		    return (void *) s1;
	    s1++;
	}
	return NULL;
}

#endif

/********************************
 * Convert integer i to ascii, and store in string pointed to by a.
 * Input:
 *	a	pointer to string of sufficient length, 17 is always sufficient
 *	base	radix, between 2 and 36 inclusive
 * Returns:
 *	a
 */

#if Aitoa

char *itoa(int i,char *a,int base)
{	unsigned u;
	char *p,buf[sizeof(i) * 8 + 1];
	int sign;

	sign = 0;
	u = i;				/* assume positive		*/
	buf[sizeof(buf) - 1] = 0;
	p = &buf[sizeof(buf) - 2];	/* last character position	*/
	if (base == 10 && i < 0)
	{   sign++;
	    u = -i;
	}
	if (u)
	{	while (1)
		{	*p = (u % base) + '0';
			if (*p > '9')
			    *p += 'A'-'0'-10;
			if ((u /= base) == 0)
				break;
			p--;
		}
	}
	else
		*p = '0';
	*a = '-';
	memcpy(a + sign,p,&buf[sizeof(buf)] - p);
	return a;
}

#endif
