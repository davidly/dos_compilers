/* Copyright 1989 Manx Software Systems, Inc. All rights reserved */

/*
 *	Synopsis
 *
 *	int atexit(void (*func)(void));
 *
 *
 *	Description
 *
 *		The atexit function registers the function pointed to by func, to be
 *	called without arguments at normal program termination.
 *
 *
 *	Implementation Limits
 *
 *		The implementation shall support the registration of at least 32
 *	functions.
 *
 *
 *	Returns
 *
 *		The atexit function returns zero if the registration succeeds, nonzero
 *	if it fails.
 */

#include <stdlib.h>

typedef void (*PFV)(void);

struct _exfunc {
	struct _exfunc *next;
	PFV func;
};

extern struct _exfunc *_exit_funcs;

int
atexit(void (*func)(void))
{
	register struct _exfunc *ep;

	if ((ep = malloc(sizeof(struct _exfunc))) == 0)
		return(-1);
	ep->next = _exit_funcs;
	_exit_funcs = ep;
	ep->func = func;
	return(0);
}

