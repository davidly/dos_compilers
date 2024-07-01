/
/	Lets C Version 4.0.C.
/	Copyright (c) 1982-1987 by Mark Williams Company, Chicago.
/	All rights reserved. May not be copied or disclosed without permission.
/

/*
 * intdis.m
 * Assembly language interrupt dispatcher.
 * Works in either LARGE or SMALL model.
 * See also: int.c, example.c.
 */

#if	LARGE
#define	LARGECODE	1
#define	LARGEDATA	1
#endif

/*
 * The following byte size parameters are used to determine the
 * actual offsets for the members of the structure INTINFO, which
 * is defined in int.c, independent of the data model LARGE or SMALL.
 */
#define	INTSIZE	2

#if	LARGEDATA
#define	PTRSIZE	4
#else
#define	PTRSIZE	2
#endif

/*
 * The following are used to get the correct 8086 mnemonics, independent
 * of the execution model LARGE or SMALL.
 */
#if	LARGECODE
#define	Gicall	xicall
#define	Gret	xret
#else
#define	Gicall	icall
#define	Gret	ret
#endif


	.shri

	.globl	intdis1_			/ Interrupt entry points
	.globl	intdis2_
	.globl	intdis3_
	.globl	intdis4_
	.globl	intdis5_
	.globl	intdis6_
	.globl	intdis7_
	.globl	intdis8_
	.globl	intdis9_
	.globl	intdis10_
	.globl	intdis11_
	.globl	intdis12_
	.globl	intdis13_
	.globl	intdis14_
	.globl	intdis15_
	.globl	intdis16_

	iisize = 5*PTRSIZE + 4*INTSIZE		/ sizeof(struct INTINFO)
	i_cfunc = 0				/ Member offsets in intinfo
	i_stacksize = PTRSIZE
	i_oldoff = 2*PTRSIZE + 2*INTSIZE
	i_stack = 2*PTRSIZE + 4*INTSIZE
	i_curstack = 3*PTRSIZE + 4*INTSIZE
	i_endstack = 4*PTRSIZE + 4*INTSIZE

	.globl	intinfo_			/ External references
	.globl	isover_

	.globl	cli_				/ External definitions
	.globl	sti_

cli_:
	cli
	Gret
sti_:
	sti
	Gret

intdis1_:					/ Entry points
	push	bx
	mov	bx, $0 * iisize
	jmp	dispatch
intdis2_:
	push	bx
	mov	bx, $1 * iisize
	jmp	dispatch
intdis3_:
	push	bx
	mov	bx, $2 * iisize
	jmp	dispatch
intdis4_:
	push	bx
	mov	bx, $3 * iisize
	jmp	dispatch
intdis5_:
	push	bx
	mov	bx, $4 * iisize
	jmp	dispatch
intdis6_:
	push	bx
	mov	bx, $5 * iisize
	jmp	dispatch
intdis7_:
	push	bx
	mov	bx, $6 * iisize
	jmp	dispatch
intdis8_:
	push	bx
	mov	bx, $7 * iisize
	jmp	dispatch
intdis9_:
	push	bx
	mov	bx, $8 * iisize
	jmp	dispatch
intdis10_:
	push	bx
	mov	bx, $9 * iisize
	jmp	dispatch
intdis11_:
	push	bx
	mov	bx, $10 * iisize
	jmp	dispatch
intdis12_:
	push	bx
	mov	bx, $11 * iisize
	jmp	dispatch
intdis13_:
	push	bx
	mov	bx, $12 * iisize
	jmp	dispatch
intdis14_:
	push	bx
	mov	bx, $13 * iisize
	jmp	dispatch
intdis15_:
	push	bx
	mov	bx, $14 * iisize
	jmp	dispatch
intdis16_:
	push	bx
	mov	bx, $15 * iisize
dispatch:
	push	ax				/ Save machine state
	push	cx
	push	dx
	push	ds
	push	es
	mov	cx, ss
	mov	dx, sp
	mov	ax, $@intinfo_			/ Segment of intinfo[]
	mov	ds, ax				/ for data references
	mov	es, ax

/*
 * The following is used to load the SS and SP registers to the
 * correct value for the interrupt processing routine.  With 
 * LARGEDATA model, we must get SS from the intinfo[]; otherwise,
 * simply set it the same as DS and ES.
 */
#if	LARGEDATA
	mov	ss, intinfo_+INTSIZE+i_curstack(bx)
#else
	mov	ss, ax
#endif
	mov	sp, intinfo_+i_curstack(bx)

	mov	ax, sp
	cmp	ax, intinfo_+i_stack(bx)	/ Nesting overflow check
	je	overflow
	sub	ax, intinfo_+i_stacksize(bx)	/ Make room on stack
	mov	intinfo_+i_curstack(bx), ax
	push	dx
	push	cx
	push	bx
	Gicall	intinfo_+i_cfunc(bx)		/ Call C routine
	pop	bx				/ Pop intinfo offset
	pop	cx				/ Pop old ss, sp
	pop	dx
	test	ax, ax				/ Call old interrupt?
	jz	done				/ No
	pushf					/ Simulate int to old function
	mov	ax, $@intinfo_			/ Segment of intinfo[]
	mov	ds, ax				/ for data reference
	xicall	intinfo_+i_oldoff(bx)		/ Indirect intersegment call
done:
	mov	ax, $@intinfo_			/ Segment of intinfo[]
	mov	ds, ax				/ for data reference
	mov	intinfo_+i_curstack(bx), sp	/ Deallocate stack
	mov	ss, cx				/ Restore machine state
	mov	sp, dx
	pop	es
	pop	ds
	pop	dx
	pop	cx
	pop	ax
	pop	bx
	iret
overflow:
	mov	sp, intinfo_+i_endstack(bx)
	call	isover_				/ Nesting overflow
death:
	jmp	death
