/
/	MWC86 CPS Version 3.1.1.
/	Copyright (c) 1982-1986 by Mark Williams Company, Chicago.
/	All rights reserved. May not be copied or disclosed without permission.
/

/
/ Assembly language interrupt dispatcher.
/ To be used with int.c.
/
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

	iisize = 18				/ sizeof(struct INTINFO)
	i_cfunc = 0				/ Member offsets in intinfo
	i_stacksize = 2
	i_oldoff = 8
	i_stack = 12
	i_curstack = 14
	i_endstack = 16
	.globl	intinfo_			/ External references
	.globl	isover_

	.globl	cli_				/ External definitions
	.globl	sti_
	.globl	savedsreg_

dsreg:
	.word	0				/ Saved ds goes here
cli_:
	cli
	ret
sti_:
	sti
	ret
savedsreg_:					/ Called by initint()
	mov	cs:dsreg, ds
	ret

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
	mov	ax, cs:dsreg			/ Load seg registers for C
	mov	ss, ax
	mov	ds, ax
	mov	es, ax
	mov	sp, intinfo_+i_curstack(bx)	/ Get interrupt sp
	mov	ax, sp
	cmp	ax, intinfo_+i_stack(bx)	/ Nesting overflow check
	je	overflow
	sub	ax, intinfo_+i_stacksize(bx)	/ Make room on stack
	mov	intinfo_+i_curstack(bx), ax
	push	dx
	push	cx
	push	bx
	icall	intinfo_+i_cfunc(bx)		/ Call C routine
	pop	bx				/ Pop intinfo offset
	pop	cx				/ Pop old ss, sp
	pop	dx
	test	ax, ax				/ Call old interrupt?
	jz	done				/ No
	pushf					/ Simulate int to old function
	xcall	intinfo_+i_oldoff(bx)		/ Indirect intersegment call
done:
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
