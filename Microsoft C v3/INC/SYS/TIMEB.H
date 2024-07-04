/*
 * Copyright (C) Microsoft Corporation, 1982
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

#ifdef LINT_ARGS		/* arg. checking enabled */

void ftime(struct timeb *);

#endif	/* LINT_ARGS */
