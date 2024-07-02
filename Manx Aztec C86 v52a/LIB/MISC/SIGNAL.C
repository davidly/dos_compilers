/* Copyright 1989 Manx Software Systems, Inc. All rights reserved */

/*
 *	Synopsis
 *
 *	void (*signal(int sig, void (*func)(int)))(int);
 *
 *
 *	Description
 *
 *		The signal function chooses one of three ways in which receipt of the
 *	signal number sig is to be subsequently handled. If the value of func is
 *	SIG_DFL, default handling for that signal will occur. If the value of func
 *	is SIG_IGN, the signal will be ignored. Otherwise, func shall point to a
 *	function to be called when that signal occurs. Such a function is called a
 *	signal handler.
 *
 *		When a signal occurs, if func points to a function, first the
 *	equivalent of signal(sig, SIG_DFL); is executed or an implementation-
 *	defined blocking of the signal is performed. (If the value of sig is
 *	SIGILL, whether the reset to SIG_DFL occurs is implementation-defined.)
 *	Next, the equivalent of (*func)(sig); is executed. The function func may
 *	terminate by executing a return statement or by calling the abort, exit, or
 *	longjump function. If func executes a return statement and the value of sig
 *	was SIGFPE or any other implementation-defined value corresponding to a
 *	computational exception, the behavior is undefined. Otherwise, the program
 *	will resume execution at the point it was interrupted.
 *
 *		If the signal occurs other than as the result of calling the abort or
 *	raise function, the behavior is undefined if the signal handler calls any
 *	function in the standard library other than the signal function itself or
 *	refers to any object with static storage duration other than by assigning a
 *	value to a static storage duration variable of type volatile sig_atomic_t.
 *	Furthermore, if such a call to the signal function results in a SIG_ERR
 *	return, the value of errno is indeterminate.
 *
 *		At program startup, the equivalent of 
 *
 *			signal(sig, SIG_IGN);
 *
 *	may be executed for some signals selected in an implementation-defined
 *	manner; the equivalent of
 *
 *			signal(sig, SIG_DFL);
 *
 *	is executed for all other signals defined by the implementation.
 *
 *		The implementation shall behave as if no library function calls the
 *	signal function.
 *
 *
 *	Returns
 *
 *		If the request can be honored, the signal function returns the value of
 *	func for the most recent call to signal for the specified signal sig.
 *	Otherwise, a value of SIG_ERR is returned and a positive value is store in
 *	errno.
 */

#include <signal.h>
#include <errno.h>

void (*_sigfuns[_NUMSIG])(int)={0};
static char setup;

int
raise(int sig)
{
	register void (*handler)(int);
	register int tsig = sig - _FSTSIG;

	if (tsig < 0 || tsig >= _NUMSIG)
		return(-1);
	if ((handler = _sigfuns[tsig]) == SIG_DFL)
		_exit(255);
	if (handler != SIG_IGN) {
		_sigfuns[tsig] = SIG_DFL;
		(*handler)(sig);
	}
	return(0);
}

void (*signal(register int sig, void (*func)(int)))(int)
{
	register void (*retval)(int);

	if (!setup) {
		_sig_setup();
		setup = 1;
	}
	if ((sig -= _FSTSIG) < 0 || sig >= _NUMSIG) {
		errno = EINVAL;
		return SIG_ERR;
	}
	retval = _sigfuns[sig];
	_sigfuns[sig] = func;
	return retval;
}
