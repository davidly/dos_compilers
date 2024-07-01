/*
 * sys/timeb.h
 *
 * defines types used by the ftime fucntion and its function declaration
 *
 * Copyright (C) Microsoft Corporation, 1984, 1985, 1986
 *
 */

/*
 * Structure returned by ftime system call
 */

struct timeb {
	time_t	time;
	unsigned short millitm;
	short	timezone;
	short	dstflag;
	};

/* function declarations for those who want strong type checking
 * on arguments to library function calls
 */

#ifdef LINT_ARGS	/* argument checking enabled */

#ifndef NO_EXT_KEYS	/* extended keywords are enabled */
void cdecl ftime(struct timeb *);
#else			/* extended keywords not enabled */
void ftime(struct timeb *);
#endif	/* NO_EXT_KEYS */

#else

#ifndef NO_EXT_KEYS	/* extended keywords are enabled */
void cdecl ftime();
#else			/* extended keywords not enabled */
void ftime();
#endif	/* NO_EXT_KEYS */

#endif	/* LINT_ARGS */
