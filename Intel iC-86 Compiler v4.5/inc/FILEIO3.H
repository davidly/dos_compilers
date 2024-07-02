/* fileio3.h - internal to I/O source
 * $Version: 1.22 $
 * Copyright (c) 1988-91 Intel Corporation, ALL RIGHTS RESERVED.
 */

#ifndef _fileio3h
#define _fileio3h
/*lint -library */

#ifndef _stdioh 
#include <stdio.h>
#endif
#ifndef _typesh
#include <sys/types.h>
#endif

/* defines for osfile (fd's) not used in streams */
#define  _IOAPPEND  0x2000
#define  _IOASCII   0x100

struct _io_block {
    int    osfile;
    off_t  foffset;
    int    fseekp;
    off_t  fbytes;
    off_t  feofpos;
    dev_t  device;
};

extern struct _io_block *_iocb;

extern int _nfile;

#define _IOCB(n) \
   ((struct _io_block *)((char *)_iocb + (n * sizeof(struct _io_block))))

#define _FD_CHECK  1
#define __READ     1
#define __WRITE    2

#endif /* _fileio3h */

