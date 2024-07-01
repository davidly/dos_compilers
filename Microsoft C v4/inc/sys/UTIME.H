/*
 * sys/utime.h
 *
 * defines the structure used by the utime routine to set new file access and
 * modification times.  NOTE - MS-DOS 2.0 does not recognize access time, so
 * this field will always be ignored and the modification time field will be
 * used to set the new time from.
 *
 * Copyright (C) Microsoft Corporation, 1984, 1985, 1986
 *
 */

struct utimbuf {
	time_t actime;		/* access time */
	time_t modtime;		/* modification time */
	};

/* function declarations for those who want strong type checking
 * on arguments to library function calls
 */

#ifdef LINT_ARGS	/* argument checking enabled */

#ifndef NO_EXT_KEYS	/* extended keywords are enabled */
int cdecl utime(char *, struct utimbuf *);
#else			/* extended keywords not enabled */
int utime(char *, struct utimbuf *);
#endif	/* NO_EXT_KEYS */

#else

#ifndef NO_EXT_KEYS	/* extended keywords are enabled */
int cdecl utime();
#endif	/* NO_EXT_KEYS */

#endif	/* LINT_ARGS */
