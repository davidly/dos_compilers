/*-----------------------------------------------------------------------*
 * filename - ssignal.c
 *
 * function(s)
 *        ssignal - implements software signals
 *        gsignal - implements software signals
 *-----------------------------------------------------------------------*/

/*[]---------------------------------------------------[]*/
/*|							|*/
/*|	Turbo C Run Time Library - Version 1.5		|*/
/*|							|*/
/*|							|*/
/*|	Copyright (c) 1987,88 by Borland International	|*/
/*|	All Rights Reserved.				|*/
/*|							|*/
/*[]---------------------------------------------------[]*/


#include <signal.h>

#pragma	warn -sus

static int (*Sigtbl[16])() =
	{
		0,
		SIG_DFL, SIG_DFL, SIG_DFL, SIG_DFL, SIG_DFL,
		SIG_DFL, SIG_DFL, SIG_DFL, SIG_DFL, SIG_DFL,
		SIG_DFL, SIG_DFL, SIG_DFL, SIG_DFL, SIG_DFL,
	};

#pragma	warn .sus

/*---------------------------------------------------------------------*

Name            ssignal - implements software signals

Usage           int (*ssignal(int sig, int (*action)( ))( );

Related
functions usage int gsignal(int sig);

Prototype in    signal.h

Description     ssignal and gsignal implement a software-signalling
                facility. Software signals are associated with integers in the
                range from 1 to 15.

                gsignal raises the signal given by sig and executes the action
                routine.

                ssignal is used to establish an action routine for servicing a
                signal. The first argument to ssignal, sig, is a number
                identifying the type of signal for which an action is
                established.

                The second argument, action, defines the action; it is either
                the name of a user-defined action function or one of the
                constants SIG_DFL (default) or SIG_IGN (ignore). These constants
                are defined in signal.h.

                If an action function has been established for sig, then that
                action is reset to SIG_DFL, and the action function is entered
                with argument sig.

Return value    ssignal returns the action previously established
                or, if the signal number is illegal, returns SIG_DFL.

                gsignal returns the value returned to it by the action
                function. gsignal's return values for actions assigned to sig
                are listed in the following:

                        Action          Return

                        SIG_IGN         1
                        SIG_DFL         0
                    Illegal value or    0
                    no action specified

                In all cases, gsignal takes no action other than returning a
                value.

*---------------------------------------------------------------------*/
int (*ssignal(register int sig, int (*action)()))()
{
	int	(*oldact)();

#pragma	warn -sus
	if (sig < 1 || sig > 15)
		return (SIG_DFL);
#pragma	warn .sus

	oldact = Sigtbl[sig];
	Sigtbl[sig] = action;

	return (oldact);
}


/*---------------------------------------------------------------------*

Name            gsignal - implements software signals

Usage           int gsignal(int sig);

Prototype in    signal.h

Description     see ssignal above

*---------------------------------------------------------------------*/
int gsignal(register int sig)
{
	int	(*action)(int);

	if (sig < 1 || sig > 15)
		return (0);
#pragma	warn -sus
	action = Sigtbl[sig];
	if (action == SIG_IGN)
		return (1);
	if (action == SIG_DFL)
		return (0);
	Sigtbl[sig] = SIG_DFL;
#pragma	warn .sus
	return ((*action)(sig));
}
