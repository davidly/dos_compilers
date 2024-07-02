/*_ signal.c   Sun Apr 16 1989   Modified by: Walter Bright */
/* Copyright (c) 1987-1989 by Walter Bright	*/
/* All Rights Reserved					*/
/* Written by Walter Bright				*/

/* Signal handling routines			*/

#include	<signal.h>
#include	<errno.h>
#include	<dos.h>
#include	<int.h>
#include	<process.h>

#ifndef NULL
#if LPTR
#define NULL 0L
#else
#define NULL 0
#endif
#endif

static void (*sighandler[])(int) =
{	SIG_DFL,SIG_DFL,SIG_DFL,
	SIG_DFL,SIG_DFL,SIG_DFL,
};

static void (*cb_handler)(int) = NULL;

static int ctrl_break_handler(struct INT_DATA *id)
{	void (*handler)(int);

	handler = cb_handler;
	signal(SIGTERM,SIG_IGN);	/* reset to default		*/
	if (handler)
	    (*handler)(SIGTERM);
	return 1;			/* return from interrupt	*/
}

/****************************
 * Set handler for a signal.
 */

void (*signal(sig,func))(int)
int sig;
void (*func)(int);
{	void (*previous)(int);

	if ((unsigned) sig > sizeof(sighandler)/sizeof(sighandler[0]))
	{	errno = ENOMEM;		/* need to use a better value here */
		return SIG_ERR;		/* unsuccessful			*/
	}
	previous = sighandler[sig];
	if (sig == SIGTERM)		/* if control-break		*/
	{
	    if (cb_handler != NULL)	/* if already a handler		*/
		int_restore(0x23);	/* restore previous handler	*/
	    cb_handler = NULL;
	    if (func != SIG_DFL && func != SIG_IGN)
	    {	if (int_intercept(0x23,ctrl_break_handler,1000) != 0)
		{   /* failed to intercept the interrupt	*/
		    errno = ENOMEM;	/* probably out of memory	*/
		    return SIG_ERR;
		}
		cb_handler = func;
	    }
	}
	sighandler[sig] = func;
	return previous;
}

/***********************
 * Raise signal sig.
 * Input:
 *	sig	SIGXXXX
 * Returns:
 *	0	successful
 *	!= 0	unsuccessful
 */

int raise(sig)
int sig;
{	void (*func)(int);

	if ((unsigned) sig > sizeof(sighandler)/sizeof(sighandler[0]))
		return 1;		/* unsuccessful			*/
	func = sighandler[sig];
	sighandler[sig] = SIG_DFL;	/* reset to default		*/
	if (func == SIG_DFL)		/* if default			*/
	{   switch (sig)
	    {
		case SIGFPE:
		    break;		/* ignore			*/
		case SIGABRT:
		case SIGILL:
		case SIGINT:
		case SIGSEGV:
		case SIGTERM:
		    _exit(1);		/* abort with error		*/
	    }
	}
	else if (func != SIG_IGN)	/* else if not ignored		*/
	    (*func)(sig);
	return 0;
}

/**********************
 * Exit with an error level of 1.
 */

void abort()
{
	raise(SIGABRT);
}


