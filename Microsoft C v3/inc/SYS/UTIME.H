/*
 * utime.h
 *
 * defines the structure used by the utime routine to set new file access and
 * modification times.  NOTE - MS-DOS 2.0 does not recognize access time, so
 * this field will always be ignored and the modification time field will be
 * used to set the new time from.
 *
 * Copyright (C) Microsoft Corporation, 1984
 */

struct utimbuf {
	time_t actime;		/* access time */
	time_t modtime;		/* modification time */
	};

/* function declarations for those who want strong type checking
 * on arguments to library function calls
 */

#ifdef LINT_ARGS		/* arg. checking enabled */

int utime(char *, struct utimbuf *);

#endif	/* LINT_ARGS */
