/* Copyright 1989 Manx Software Systems, Inc. All rights reserved */

/*
 *	Synopsis
 *
 *	void exit(int status);
 *
 *
 *	Description
 *
 *		The exit function causes normal program termination to occur. If more
 *	than one call to the exit functions is executed by a program, the behavior
 *	is undefined.
 *
 *		First, all functions registered by the atexit function are called, in
 *	the reverse order of their registration.
 *
 *		Next, all open output streams are flushed, all open streams are closed,
 *	and all files created by the tmpfile function are removed.
 *
 *		Finally, control is returned to the host environment. If the value of
 *	status is zero or EXIT_SUCCESS, an implementation-defined form of the
 *	status "successful termination" is returned. If the value of the status is
 *	EXIT_FAILURE, an implementation-defined form of the status "unsuccessful
 *	termination" is returned. Otherwise the status returned is implementation-
 *	defined.
 *
 *
 *	Returns
 *
 *		The exit function cannot return to its caller.
 */

typedef void (*PFV)(void);

struct _exfunc {
	struct _exfunc *next;
	PFV func;
};

struct _exfunc *_exit_funcs;

PFV _close_stdio;
extern void _exit(int status);


void
exit(int status)
{
	while (_exit_funcs) {
		(*_exit_funcs->func)();
		_exit_funcs = _exit_funcs->next;
	}

	if (_close_stdio)
		(*_close_stdio)();

	_exit(status);
}

