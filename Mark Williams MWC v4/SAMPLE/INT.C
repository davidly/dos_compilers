/*
 *	Let's C Version 4.0.C.
 *	Copyright (c) 1982-1987 by Mark Williams Company, Chicago.
 *	All rights reserved. May not be copied or disclosed without permission.
 */

/*
 * int.c
 * Let's C interface routines for MS-DOS hardware interrupt handling.
 * These work in either LARGE or SMALL model.
 * See also: intdis.m, example.c.
 */
#include <stdio.h>
#include <dos.h>

#define SIZE(x)		(sizeof(x)/sizeof(x[0]))  /* Size in elements */
#define END(x)		(&x[SIZE(x)])		  /* Address of end */

/*
 * The interrupts are set to jump to these assembly entry points first.
 */
extern	 intdis1();
extern	 intdis2();
extern	 intdis3();
extern	 intdis4();
extern	 intdis5();
extern	 intdis6();
extern	 intdis7();
extern	 intdis8();
extern	 intdis9();
extern	 intdis10();
extern	 intdis11();
extern	 intdis12();
extern	 intdis13();
extern	 intdis14();
extern	 intdis15();
extern	 intdis16();

/*
 * Interrupt information.
 * Knowledge of this structure is hardcoded in intdis.m.
 */
struct INTINFO {
	int	 (*i_cfunc)();		/* C function to be called	*/
	int	 i_stacksize;		/* Stack needed by C func	*/
	void	 (*i_intdis)();		/* Assembly dispatch routine	*/
	int	 i_intnum;		/* 8086 int number (-1 if free)	*/
	unsigned i_oldoff;		/* Old vector offset		*/
	unsigned i_oldseg;		/* Old vector segment		*/
	char	 *i_stack;		/* Pointer to start of stack	*/
	char	 *i_curstack;		/* Current sp (grows down)	*/
	char	 *i_endstack;		/* Pointer to end of stack	*/
} intinfo[] = {
	{ NULL, 0, &intdis1,  -1, 0, 0, NULL, NULL, NULL },
	{ NULL, 0, &intdis2,  -1, 0, 0, NULL, NULL, NULL },
	{ NULL, 0, &intdis3,  -1, 0, 0, NULL, NULL, NULL },
	{ NULL, 0, &intdis4,  -1, 0, 0, NULL, NULL, NULL },
	{ NULL, 0, &intdis5,  -1, 0, 0, NULL, NULL, NULL },
	{ NULL, 0, &intdis6,  -1, 0, 0, NULL, NULL, NULL },
	{ NULL, 0, &intdis7,  -1, 0, 0, NULL, NULL, NULL },
	{ NULL, 0, &intdis8,  -1, 0, 0, NULL, NULL, NULL },
	{ NULL, 0, &intdis9,  -1, 0, 0, NULL, NULL, NULL },
	{ NULL, 0, &intdis10, -1, 0, 0, NULL, NULL, NULL },
	{ NULL, 0, &intdis11, -1, 0, 0, NULL, NULL, NULL },
	{ NULL, 0, &intdis12, -1, 0, 0, NULL, NULL, NULL },
	{ NULL, 0, &intdis13, -1, 0, 0, NULL, NULL, NULL },
	{ NULL, 0, &intdis14, -1, 0, 0, NULL, NULL, NULL },
	{ NULL, 0, &intdis15, -1, 0, 0, NULL, NULL, NULL },
	{ NULL, 0, &intdis16, -1, 0, 0, NULL, NULL, NULL }
};
 
static char	iovermsg[] = "Interrupt nesting capacity exceeded\r\n";

/*
 * Link a C function with an 8086 interrupt.
 * Up to 16 C functions can be linked to interrupts at once.
 *
 * Parameters:
 *
 * 	intnum --	8086 interrupt number.
 * 	func --		C function pointer for interrupt service routine.
 * 	stacksize --	Amount of stack (in bytes) that C function needs.
 * 	level --	Maximum number of levels that interrupt will be nested.
 *
 * Returns:
 *
 * The C function should return 1 if it wants the old interrupt
 * service routine to be called too.  Otherwise, it should return 0.
 * This is useful for trapping an interrupt but not affecting its
 * old functionality.
 * This function returns a number from 0 to 15 on success.  This
 * unique interrupt identifier is passed to clearint when
 * you want to dereference the C routine from the interrupt.
 * Returns -1 on failure (Bad intnum, all available ints in use, bad
 * level value, not enough memory for stack).
 *
 * Notes:
 *
 * (1)	If the interrupt service routine returns 0 and the interrupt
 *	is a real hardware interrupt (e.g., interrupts 0x8 to 0xF on the
 *	IBM-PC), the C service routine must output an EOI to the
 *	interrupt controller.
 *
 * (2)	All C service routines are called with interrupts disabled.  You
 *	may call cli() or sti() to clear or set the interrupt enable bit
 *	respectively.
 *
 * (3)	Most library functions cannot be called by an interrupt service
 *	routine.
 *
 * (4)	The use of floating point arithmetic within
 *	an interrupt service routine is not recommended.
 *
 * (5)	Caution should be exercised when interrupt routine(s)
 *	and the main program access the same writeable data structures.
 *
 * (6)	Interrupts can be linked.  That is, setint may be called
 *	several times with the same interrupt number.  When that
 *	interrupt occurs, if all C service routines for that interrupt
 *	return 1, all such routines will be executed.  When you link
 *	interrupts, it is vital that setint/clearint calls are not crossed.
 *	That is, between a setint and its corresponding clearint, no other
 *	setints on that interrupt should have been performed which
 *	weren't cleared.
 *
 * (7)	No stack checking is performed.  If stacksize is too small, the
 *	system will crash.  If level is too small (the interrupt
 *	nests more than level levels), the system will print
 *	an error message and hang with interrupts disabled.
 *	The stack size (in bytes) needed by one function is equal to
 *	6 + sizeof parameters + sizeof automatics.
 *	Allow at least 256 bytes excess stack for a safety margin.
 *
 * (8)	It's OK to use this system after calling MS-DOS function 0x31
 *	(terminate and remain resident).  The routine termres, provided
 *	here, does this.
 */
setint(intnum, func, stacksize, level)
register int intnum;
int	     (*func)();
unsigned     stacksize;
int	     level;
{
	register struct INTINFO *ip;
	register int 		i = 0;
	register unsigned	totalstack = stacksize * level;
	struct reg 		r;
	char			*malloc();

	if (intnum < 0 || intnum >= 256 || level < 0)
		return(-1);

	for (ip = intinfo; ip < END(intinfo); ++ip, ++i)
		if (ip->i_intnum == -1) {		/* Free spot? */
			if ((ip->i_stack = malloc(totalstack)) == NULL)
				return(-1);
			r.r_ax = GETVEC | intnum;
			intcall(&r, &r, DOSINT);	/* Get old vector */
			ip->i_oldseg = r.r_es;		/* Save it */
			ip->i_oldoff = r.r_bx;
			ip->i_intnum = intnum;
			ip->i_cfunc = func;
			ip->i_stacksize = stacksize;
			ip->i_curstack = ip->i_endstack = ip->i_stack +
				totalstack;
			ptoreg(csreg, r.r_dx, r.r_ds, ip->i_intdis);
			r.r_ax = SETINT | intnum;
			intcall(&r, &r, DOSINT);	/* Set new int */
			return(i);
		}
	return(-1);					/* Table full */
}

/*
 * Clear an interrupt previously set by setint.
 * id -- unique identifier which setint returned.
 * Returns 0 on success.
 * Returns -1 on failure (id out of range, interrupt never set).
 */
clearint(id)
register int id;
{
	if (id < 0 || id >= SIZE(intinfo))
		return(-1);
	return(_clearint(&intinfo[id]));
}

/*
 * Clear all interrupts.
 * You should not call this routine if you have linked several
 * interrupt service routines to the same interrupt with setint.
 */
doneint()
{
	register struct INTINFO *ip;

	for (ip = intinfo; ip < END(intinfo); ++ip)
		_clearint(ip);
}

/*
 * Internal routine to restore an interrupt to its old value.
 * Returns 0 if OK, -1 if interrupt is clear.
 */
static
_clearint(ip)
register struct INTINFO *ip;
{
	struct reg r;

	if (ip->i_intnum != -1) {
		r.r_ax = SETINT | ip->i_intnum;
		r.r_ds = ip->i_oldseg;
		r.r_dx = ip->i_oldoff;
		intcall(&r, &r, DOSINT);
		ip->i_intnum = -1;
		free(ip->i_stack);
		return(0);
	}
	return(-1);
}

/*
 * Internal routine called by the assembly interrupt linkage
 * on interrupt nesting overflow.  Called in interrupt context.
 * At this point, system may be foobared.
 */
isover()
{
	write(1, iovermsg, sizeof(iovermsg) - 1);
}

/*
 * Terminate process and remain resident.
 * This routine exits, but allocates all program and data memory
 * before doing so.  You must call this routine if you want
 * to handle interrupts after normal program exit.
 * Basically figure out the total number of paragraphs that program,
 * data, stack, and malloc arena occupy and pass it to the MS-DOS
 * TERMRES function.
 * status -- Byte exit code.
 */
termres(status)
int status;
{
	struct reg	r;
	extern int	_pspbase;
	extern char	*__end;

	r.r_ax = TERMRES | (status & 0xFF);
	r.r_dx = dsreg() + ((int)__end >> 4) + 1 - _pspbase;
	intcall(&r, &r, DOSINT);
}
