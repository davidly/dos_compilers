/* Copyright 1992 Manx Software Systems, Inc. All rights reserved */

#ifndef __ALLOC_H
#define	__ALLOC_H

int 			brk(void *ptr);
void *			sbrk(int _size);

huge void *		lcalloc(long _nelem, long _size);
huge void *		lfree(huge void *_ptr);
huge void *		lmalloc(long _size);
huge void *		lrealloc(huge void *_ptr, long _size);

unsigned int	rsvstk(int _size);

#endif	/* __ALLOC_H */


