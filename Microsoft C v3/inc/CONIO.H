/*
 * conio.h
 *
 * This include file contains the function declarations for the MS C V2.03
 * compatable console and port IO routines
 *
 * Copyright (C) Microsoft Corporation, 1984
 *
 */

/* function declarations for those who want strong type checking
 * on arguments to library function calls
 */

#ifdef LINT_ARGS		/* arg. checking enabled */

char *cgets(char *);
int cprintf(char *, );
void cputs(char *);
int cscanf(char *, );
int getch(void);
int getche(void);
int inp(unsigned int);
int kbhit(void);
int outp(unsigned int, int);
void putch(int);
int ungetch(int);

#else

extern char *cgets();

#endif	/* LINT_ARGS */
