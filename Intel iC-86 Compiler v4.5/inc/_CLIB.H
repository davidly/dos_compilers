/* _clib.h - internal library header file
 * $Version: 1.3 $
 * Copyright (c) 91 Intel Corporation, ALL RIGHTS RESERVED.
 */

#ifndef _clibh
#define _clibh

#ifndef _stdioh
#include <stdio.h>
#endif

#pragma fixedparams("_doprnt", "_doscan",    "_dtobcd",  "_dtos",    "_filbuf")
#pragma fixedparams("_fflush", "_flsbuf",    "_fltprnt", "_fltscan", "_fopen")
#pragma fixedparams("_getch",  "_modeparse", "_pow_10",  "_putch")

#define STREAM_IO      0                                  /* Used by _doscan */
#define CONSOLE_IO     1

/*
 * Function prototypes:
 */
int      _doprnt(const char *, char* *, FILE *, int (*)());
int      _doscan(const char *, char* *, FILE *, int (*)(), int (*)(), int);
int      _dtobcd(double, char *);
int      _dtos(double, char *);
size_t   _filbuf(char *, size_t, FILE *);
int      _fflush(FILE *);
size_t   _flsbuf(char *, size_t, FILE *);
int      _fltprnt(int, va_list, char, int, unsigned, int,
                  unsigned, unsigned, FILE *, int (*fp)());
int      _fltscan(FILE *, unsigned, unsigned, va_list *, unsigned,
                  int (*getfp)(), int (*putfp)(), int);
FILE    *_fopen(int, unsigned);
int      _getch(FILE *);
unsigned _modeparse(const char *);
double   _pow_10(int);
int      _putch(int, FILE *);

#endif /* _clibh */
