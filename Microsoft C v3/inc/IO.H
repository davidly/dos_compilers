/*
 * io.h
 *
 * This include file contains the function declarations for the low level
 * file handling and IO functions
 *
 * Copyright (C) Microsoft Corporation, 1984
 *
 */

/* function declarations for those who want strong type checking
 * on arguments to library function calls
 */

#ifdef LINT_ARGS		/* arg. checking enabled */

int access(char *, int);
int chmod(char *, int);
int chsize(int, long);
int close(int);
int creat(char *, int);
int dup(int);
int dup2(int, int);
int eof(int);
long filelength(int);
int isatty(int);
int locking(int, int, long);
long lseek(int, long, int);
char *mktemp(char *);
int open(char *, int, );
int read(int, char *, unsigned int);
int rename(char *, char *);
int setmode(int, int);
int sopen(char *, int, int, );
long tell(int);
int umask(int);
int unlink(char *);
int write(int, char *, unsigned int);

#else

extern long filelength(), lseek(), tell();
extern char *mktemp();

#endif	/* LINT_ARGS */
