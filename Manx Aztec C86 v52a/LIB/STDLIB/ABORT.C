/* Copyright 1989 Manx Software Systems, Inc. All rights reserved */

/*
 *	Synopsis
 *
 *	void abort(void);
 *
 *
 *	Description
 *
 *		The abort function causes abnormal program termination to occur, unless
 *	the signal SIGABRT is being caught and the signal handler does not return.
 *	Whether open output streams are flushed or open streams are closed or
 *	temporary files removed is implementation-defined. An implementation-
 *	defined form of the status unsuccessful termination is returned to the host
 *	environment by means of the function call raise(SIGABRT).
 *
 *
 *	Returns
 *
 *		The abort function cannot return to its caller.
 */

#include <stdlib.h>
#include <signal.h>

void
abort(void)
{
	raise(SIGABRT);
}

