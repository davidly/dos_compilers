/*
 * conio.h
 *
 * This include file contains the function declarations for the MS C V2.03
 * compatable console and port IO routines
 *
 * Copyright (C) Microsoft Corporation, 1984, 1985, 1986
 *
 */

/* function declarations for those who want strong type checking
 * on arguments to library function calls
 */

#ifdef LINT_ARGS	/* argument checking enabled */

#ifndef NO_EXT_KEYS	/* extended keywords are enabled */
char * cdecl cgets(char *);
int cdecl cprintf(char *, ...);
void cdecl cputs(char *);
int cdecl cscanf(char *, ...);
int cdecl getch(void);
int cdecl getche(void);
int cdecl inp(unsigned int);
int cdecl kbhit(void);
int cdecl outp(unsigned int, int);
void cdecl putch(int);
int cdecl ungetch(int);
#else			/* extended keywords not enabled */
char *cgets(char *);
int cprintf(char *, ...);
void cputs(char *);
int cscanf(char *, ...);
int getch(void);
int getche(void);
int inp(unsigned int);
int kbhit(void);
int outp(unsigned int, int);
void putch(int);
int ungetch(int);
#endif	/* NO_EXT_KEYS */

#else

#ifndef NO_EXT_KEYS	/* extended keywords are enabled */
char * cdecl cgets();
int cdecl cprintf();
void cdecl cputs();
int cdecl cscanf();
int cdecl getch();
int cdecl getche();
int cdecl inp();
int cdecl kbhit();
int cdecl outp();
void cdecl putch();
int cdecl ungetch();
#else			/* extended keywords not enabled */
char *cgets();
void cputs();
void putch();
#endif	/* NO_EXT_KEYS */

#endif	/* LINT_ARGS */
