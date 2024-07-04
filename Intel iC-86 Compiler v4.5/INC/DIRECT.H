/* direct.h - directory manipulation function prototypes
 * $Version: 1.14 $
 * Copyright (c) 1988-91 Intel Corporation, ALL RIGHTS RESERVED.
 */

#ifndef _directh
#define _directh
/*lint -library */

#pragma fixedparams("chdir",    "_chdrive",  "filedir", "gcdir",    "getcwd")
#pragma fixedparams("_getdcwd", "_getdrive", "mkdir",    "rmdir")

#ifndef _mode_t
#define _mode_t
typedef unsigned long mode_t;
#endif

/*
 * Function prototypes:
 */
int    chdir(const char *);
int   _chdrive(int);
char  *filedir(const char *, unsigned);
char  *gcdir(const char *);
char  *getcwd(char *, int);
char *_getdcwd(int, char *, int);
int   _getdrive(void);
int    mkdir(const char *, mode_t);
int    rmdir(const char *);

#endif /* _directh */
