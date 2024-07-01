/*
 *	Let's C Version 4.0.C.
 *	Copyright (c) 1982-1987 by Mark Williams Company, Chicago.
 *	All rights reserved. May not be copied or disclosed without permission.
 */

/*
 * example.c
 * This program demonstrates the use of MS-DOS interrupt routines.
 * It works in either LARGE or SMALL model.
 * See also:  int.c, intdis.m.
 * To compile:  cc example.c int.c intdis.m -ns -na
 */

#define	INT_BREAK	0x1B	/* Keyboard ctrl-break interrupt	*/
#define INT_TICK	0x1C	/* System timer tick interrupt		*/
#define STACKSIZE	0x100	/* Small stack for locals		*/

#define	TRUE	1
#define	FALSE	0

int	breakflag = FALSE;
int	timerflag = FALSE;

main()
{
	int breaktrp(), timertrp();
	int breakid, timerid;


	/* Initialize the interrupts. */
	if ( (breakid=setint(INT_BREAK, breaktrp, STACKSIZE, 1)) == -1 )
		fatal("Cannot set Ctrl-Break interrupt.");
	else
		puts("Ctrl-Break interrupt set.");
	if ( (timerid=setint(INT_TICK, timertrp, STACKSIZE, 1)) == -1 )
		fatal("Cannot set timer tick interrupt.");
	else
		puts("Timer tick interrupt set.");

	/* Wait for Ctrl-Break key. */
	puts("Type Ctrl-Break to exit.");
	for (;;) {
		if ( breakflag == TRUE )
			break;
		if ( timerflag == FALSE )
			continue;
		puts("Five seconds have passed.");
		timerflag = FALSE;
	}
	puts("Got the Ctrl-Break key.");

	/* Reset the interrupts. */
	if ( clearint(breakid) != 0 )
		fatal("Cannot reset Ctrl-Break interrupt.");
	else
		puts("Ctrl-Break interrupt reset.");
	if ( clearint(timerid) != 0 )
		fatal("Cannot reset timer tick interrupt.");
	else
		puts("Timer tick interrupt reset.");

	exit(0);
}

/*
 * Fatal error routine.
 */
fatal(s) register char *s;
{
	puts(s);
	exit(1);
}

/*
 * Service routine for the Ctrl-Break interrupt (0x1B).
 * Simply sets the breakflag to TRUE.
 */
breaktrp()
{
	breakflag = TRUE;
	return(0);
}

/*
 * Service routine for timer tick interrupt (0x1C).
 * This comes from the 8253-5 programmable interval timer at a rate of 18.2 Hz.
 * Every 91 (=18.2*5 ) interrupts (five seconds), set the timerflag to TRUE.
 */
timertrp()
{
	static counter = 0;

	if ( ++counter == 91 ) {
		timerflag = TRUE;
		counter = 0;
	}
	return(1);	/* Link in case interrupt 0x1C did something already */
}
