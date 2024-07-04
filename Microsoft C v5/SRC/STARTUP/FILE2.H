/***
*file2.h - auxiliary file structure used internally by file run-time routines
*
*   Copyright (c) 1985-1988, Microsoft Corporation.  All rights reserved.
*
*Purpose:
*   This file defines the auxiliary file structure used internally by
*   the file run time routines.
*   [Internal]
*
*******************************************************************************/

#define FILE2  struct _iobuf2

extern FILE2 {
    char  _flag2;
    char  _charbuf;
    int   _bufsiz;
    int   __tmpnum;
    } near _iob2[];

#define _IOYOURBUF 0x01
#define _IOUNGETC  0x04
#define _IOFEOF    0x08

#define _iob_index(s)   (s - (FILE *)_iob)

#define inuse(s)   ((s)->_flag & (_IOREAD|_IOWRT|_IORW))

#define mbuf(s)    ((s)->_flag & _IOMYBUF)
#define nbuf(s)    ((s)->_flag & _IONBF)
#define ybuf(s)    (_iob2[_iob_index(s)]._flag2 & _IOYOURBUF)

#define bigbuf(s)  (mbuf(s) || ybuf(s))
#define anybuf(s)  ((s)->_flag & (_IOMYBUF|_IONBF) || ybuf(s))
#define _tmpnum(s)  _iob2[_iob_index(s)].__tmpnum
