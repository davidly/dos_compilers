/*
 * io.h
 *
 * This include file contains the function declarations for the low level
 * file handling and IO functions
 *
 * Copyright (C) Microsoft Corporation, 1984, 1985, 1986
 *
 */

/* function declarations for those who want strong type checking
 * on arguments to library function calls
 */

#ifdef LINT_ARGS	/* argument checking enabled */

#ifndef NO_EXT_KEYS	/* extended keywords are enabled */
int cdecl access(char *, int);
int cdecl chmod(char *, int);
int cdecl chsize(int, long);
int cdecl close(int);
int cdecl creat(char *, int);
int cdecl dup(int);
int cdecl dup2(int, int);
int cdecl eof(int);
long cdecl filelength(int);
int cdecl isatty(int);
int cdecl locking(int, int, long);
long cdecl lseek(int, long, int);
char * cdecl mktemp(char *);
int cdecl open(char *, int, ...);
int cdecl read(int, char *, unsigned int);
int cdecl remove(char *);
int cdecl rename(char *, char *);
int cdecl setmode(int, int);
int cdecl sopen(char *, int, int, ...);
long cdecl tell(int);
int cdecl umask(int);
int cdecl unlink(char *);
int cdecl write(int, char *, unsigned int);
#else			/* extended keywords not enabled */
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
char * mktemp(char *);
int open(char *, int, ...);
int read(int, char *, unsigned int);
int rename(char *, char *);
int remove(char *);
int setmode(int, int);
int sopen(char *, int, int, ...);
long tell(int);
int umask(int);
int unlink(char *);
int write(int, char *, unsigned int);
#endif	/* NO_EXT_KEYS */

#else

#ifndef NO_EXT_KEYS	/* extended keywords are enabled */
int cdecl access();
int cdecl chmod();
int cdecl chsize();
int cdecl close();
int cdecl creat();
int cdecl dup();
int cdecl dup2();
int cdecl eof();
long cdecl filelength();
int cdecl isatty();
int cdecl locking();
long cdecl lseek();
char * cdecl mktemp();
int cdecl open();
int cdecl read();
int cdecl rename();
int cdecl remove();
int cdecl setmode();
int cdecl sopen();
long cdecl tell();
int cdecl umask();
int cdecl unlink();
int cdecl write();
#else			/* extended keywords not enabled */
long filelength();
long lseek();
char *mktemp();
long tell();
#endif	/* NO_EXT_KEYS */

#endif	/* LINT_ARGS */
