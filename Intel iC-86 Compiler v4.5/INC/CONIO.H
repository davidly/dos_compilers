/* conio.h - low level I/O function prototypes
 * $Version: 1.17 $
 * Copyright (C) 1988-91 Intel Corporation, ALL RIGHTS RESERVED
 */

#ifndef _conioh
#define _conioh
/*lint -library */

#pragma fixedparams("cgets", "cputs", "getch", "getche")
#pragma fixedparams("kbhit", "putch", "ungetch")
#pragma varparams("cprintf", "cscanf")

/*
 * Function prototypes:
 */
char *cgets(char *);
int   cprintf(const char *, ...);
int   cputs(const char *);
int   cscanf(const char *, ...);
int   getch(void);
int   getche(void);
int   kbhit(void);
int   putch(int);
int   ungetch(int);

#endif /* _conioh */

