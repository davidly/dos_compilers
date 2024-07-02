/*_ far.c   Mon Apr  3 1989   Modified by: Walter Bright */
/* OS2 support added by Nikki Locke May 1989 */
/* Copyright (C) 1987-1989 by Walter Bright	*/
/* Written by Walter Bright				*/
/* All Rights Reserved					*/
/* Storage allocation for far pointers			*/

#include	<stdio.h>
#include	<stdlib.h>
#include	<dos.h>

#if SPTR
extern unsigned _datapar;
static filled = 0;

/*******************************
 * Fill near storage out to 64k
 */

static void near fillto64k(void)
{   unsigned size;
    char *ptr;

    if (filled == 0)
    {	size = (0xFFF - _datapar) * 16;
	if (size)
	{	ptr = sbrk(size);
		if (ptr)
			free(ptr - 2);
	}
	filled = 1;
    }
}
#else
#define fillto64k()
#endif

/*****************************
 * Allocate memory accessible by far pointer.
 */

void far *farmalloc(unsigned long size)
{   unsigned segment;

    fillto64k();
#ifdef __OS2__
    if (size == 0 || size >= 0x10000)	/* no support for HUGE pointers */
#else
    if (size == 0 || size >= 0x100000)
#endif
	segment = 0;
    else
	segment = dos_alloc((unsigned)((size + 15) >> 4));
    return MK_FP(segment,0);
}

/*****************************
 * Allocate memory accessible by far pointer.
 * Clear the memory allcocated.
 */

void far *farcalloc(unsigned long size,unsigned long elem)
{   unsigned segment;

    fillto64k();
    size *= elem;
#ifdef __OS2__
    if (size == 0 || size >= 0x10000)	/* no support for HUGE pointers */
#else
    if (size == 0 || size >= 0x100000)
#endif
	segment = 0;
    else
	segment = dos_calloc((unsigned)((size + 15) >> 4));
    return MK_FP(segment,0);
}

/****************************
 * Free far pointer created by farmalloc(), farcalloc() or farrealloc().
 * Returns:
 *	0	success
 *	-1	failure
 */

int farfree(void far *ptr)
{   unsigned segment;

    if (FP_OFF(ptr))
	return -1;
    segment = FP_SEG(ptr);
    return (segment) ? dos_free(segment) : 0;
}

/***************************
 * Reallocate pointer in same manner as realloc().
 */

void far *farrealloc(void far *oldptr,unsigned long newsize)
{   unsigned oldseg,newseg,newpar,oldpar;
    int errsave;

    fillto64k();
    if (newsize == 0)
    {	farfree(oldptr);
    ret0:
	return 0;
    }
    if (FP_OFF(oldptr))
	goto ret0;			/* oldptr is a bad pointer	*/
    oldseg = FP_SEG(oldptr);
    if (oldseg == 0)			/* if oldptr is NULL		*/
	return farmalloc(newsize);
#ifdef __OS2__
    if (newsize >= 0x10000)		/* no support for HUGE pointers */
#else
    if (newsize >= 0x100000)
#endif
	goto ret0;			/* can't allocate that much	*/
    /* Attempt to just resize the block	*/
    newpar = (newsize + 15) >> 4;	/* # of paragraphs		*/
    errsave = errno;
    errno = 0;
    dos_setblock(newpar,oldseg);
    if (errno == 0)			/* if successful		*/
    {	errno = errsave;
	return oldptr;			/* we resized in place		*/
    }
    errno = errsave;
    /* Allocate new block and copy */
    oldpar = *(unsigned far *)MK_FP(oldseg - 1,3);
    newseg = dos_alloc(newpar);
    if (newseg == 0)
	goto ret0;			/* failed to allocate a new one	*/
    _copy(newseg,oldseg,(newpar < oldpar ? newpar : oldpar));
    dos_free(oldseg);
    return MK_FP(newseg,0);
}

/************************
 * Return size of largest available memory block.
 */

unsigned long farcoreleft(void)
{
	fillto64k();
	return dos_avail();
}

