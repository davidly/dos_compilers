/***
*file2.h - auxiliary file structure used internally by file run-time routines
*
*	Copyright (c) 1985-1990, Microsoft Corporation.  All rights reserved.
*
*Purpose:
*	This file defines the auxiliary file structure used internally by
*	the file run time routines.
*	[Internal]
*
****/

/*
   Define the FILE2 structure.

   [Note that we depend on the FILE2 structure being the same size as a
   FILE structure (see macro definitions).]
*/

#define FILE2  struct _iobuf2

extern FILE2 {
	char  _flag2;
	char  _charbuf;
	int   _bufsiz;
	int   __tmpnum;
#if (defined(M_I86SM) || defined(M_I86MM))
	char  _padding[2];		/* pad out to size of FILE structure */
#else
	char  _padding[6];		/* pad out to size of FILE structure */
#endif
    } near _iob2[];

#define _IOYOURBUF	0x01
#define _IOFEOF 	0x08
#define _IOFLRTN	0x10
#define _IOCTRLZ	0x20

/* Macros for getting _iob[] index and translating (FILE *) to (FILE2 *) */

#define _iob2_(s)  (*((FILE2 near *) ((char near *)_iob2 + ((char *)s - (char *)_iob))))
#define _iob_index(s)	( (FILE *) s - (FILE *)_iob)

/* General use macros */

#define inuse(s)	((s)->_flag & (_IOREAD|_IOWRT|_IORW))
#define mbuf(s) 	((s)->_flag & _IOMYBUF)
#define nbuf(s) 	((s)->_flag & _IONBF)
#define ybuf(s) 	(_iob2_(s)._flag2 & _IOYOURBUF)
#define bigbuf(s)	(mbuf(s) || ybuf(s))
#define anybuf(s)	((s)->_flag & (_IOMYBUF|_IONBF) || ybuf(s))
#define _tmpnum(s)	_iob2_(s).__tmpnum

/* Optimized macros for use when the (FILE2 *) pointer is already known */

#define ybuf2(s2)	((s2)->_flag2 & _IOYOURBUF)
#define bigbuf2(s,s2)	(mbuf(s) || ybuf2(s2))
#define anybuf2(s,s2)	((s)->_flag & (_IOMYBUF|_IONBF) || ybuf2(s2))
