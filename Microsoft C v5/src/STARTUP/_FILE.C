/***
*_file.c - perprocess file and buffer data declarations
*
*   Copyright (c) 1985-1988, Microsoft Corporation.  All rights reserved.
*
*Purpose:
*   file and buffer data declarations
*
*******************************************************************************/

#include <stdio.h>
#include <file2.h>

#define _NEAR_ near

/* Number of files */

#define _NFILE_ 20

/*
 * buffers for stdin, stdout, and stderr
 */

#if defined(OS2) || defined(M_I86SM) || defined(M_I86MM)
char    _bufin[BUFSIZ];
char    _bufout[BUFSIZ];
char    _buferr[BUFSIZ];
#else
char    _bufin[BUFSIZ] = "";
char    _bufout[BUFSIZ] = "";
char    _buferr[BUFSIZ] = "";
#endif


/*
 * FILE descriptors; preset for stdin/out/err/aux/prn
 */

FILE _NEAR_ _iob[ _NFILE_ ] = {
    /* ptr,     cnt,    base,   flag,   file */
    {
        _bufin, 0,  _bufin, _IOREAD,    0       }
    ,
    {
        NULL,   0,  NULL,   _IOWRT,     1       }
    ,
    {
        NULL,   0,  NULL,   _IOWRT,     2       }
    ,
#ifndef OS2
    {
        NULL,   0,  NULL,   _IORW|_IONBF,   3       }
    ,
    {
        NULL,   0,  NULL,   _IOWRT,     4       }
    ,
#endif
};


/*
 * FILE2 descriptors; preset for stdin/out/err/aux/prn
 */

FILE2 _NEAR_ _iob2[ _NFILE_ ] = {
    /* flag2,   charbuf */
    {
        _IOYOURBUF, '\0', BUFSIZ        }
    ,
    {
        0,      '\0', 0         }
    ,
    {
        0,      '\0', 0         }
    ,
#ifndef OS2
    {
        0,      '\0', 0         }
    ,
    {
        0,      '\0', 0         }
    ,
#endif
};

/* pointer to end of descriptors */
FILE * _NEAR_ _lastiob = &_iob[ _NFILE_ -1];
