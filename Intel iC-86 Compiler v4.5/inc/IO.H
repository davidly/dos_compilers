/* io.h - file access function prototypes
 * $Version: 1.33 $
 * Copyright (c) 1988-91 Intel Corporation, ALL RIGHTS RESERVED.
 */

#ifndef _ioh
#define _ioh
/*lint -library */

#ifndef _timeh
#include <time.h>
#endif
#ifndef _typesh
#include <sys/types.h>
#endif

#pragma fixedparams("access", "chmod", "chown",   "chsize", "close")
#pragma fixedparams("creat",  "dup",   "dup2",    "eof",    "filelength")
#pragma fixedparams("isatty", "link",  "locking", "lseek",  "ltell")
#pragma fixedparams("mktemp", "read",  "setmode", "umask", "unlink")
#pragma fixedparams("write",  "tell",  "_open")
#pragma fixedparams("_stdio_stdopen",  "_map_length")
#pragma varparams("open", "sopen")


/*
 * Function prototypes:
 */
int    access(const char *, int);
int    chmod(const char *, mode_t);
int    chown(const char *, uid_t, gid_t);
int    chsize(int, long);
int    close(int);
int    creat(const char *, mode_t);
int    dup(int);
int    dup2(int, int);
int    eof(int);
long   filelength(int);
int    isatty(int);
int    link(const char *, const char *);
int    locking(int, int, long);
off_t  lseek(int, off_t, int);
long   ltell(int);
int   _map_length(int, const void *, size_t);
char  *mktemp(char *);
int    open(const char *, int, ...);
int   _open(const char *, unsigned int, unsigned int, unsigned int);
int    read(int, char *, unsigned int);
int    setmode(int, int);
int    sopen(const char *, unsigned int, unsigned int, ...);
int   _stdio_stdopen(int);
long   tell(int);
mode_t umask(mode_t);
int    unlink(const char *);
int    write(int, const char *, unsigned int);

#ifdef _CLIB
#endif

#endif /* _ioh */

