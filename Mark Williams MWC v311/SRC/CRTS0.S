/
/	MWC86 CPS Version 3.1.1.
/	Copyright (c) 1982-1986 by Mark Williams Company, Chicago.
/	All rights reserved. May not be copied or disclosed without permission.
/

////////
/
/ PC DOS runtime startoff.
/ Set up data segment registers.
/ Clear the block segment.
/ Make sure the stack is word aligned.
/ Call the second level of run time startoff to
/ chop up the command line, open files and call the
/ user's main routine.
/ This routine is the first file in the load.
/
////////

	.globl	_pspbase_
	.globl	_exit_

	.globl	edata_
	.globl	end_
	.globl	__end_;
	.globl	_main_

	mov	ax, ss
	mov	ds, ax			/ DS = SS
	mov	es, ax			/ ES = DS

	mov	di, $edata_		/ Get base address of BSS.
	mov	cx, $end_		/ Get top of load.
	sub	cx, di			/ Figure out BSS size.
	subb	al, al			/ Get a 0.
	cld				/ Incrementing.
	rep
	stosb				/ Clear segment.

	sub	bp, bp			/ For setjmp and longjmp.
	test	sp, $01 		/ Is the stack word aligned?
	jz	1f			/ Yep, ok.
	dec	sp			/ Nope, make it word aligned.

1:	mov	ax, $end_		/ For sbrk.
	inc	ax
	and	ax, $-2			/ Align on word boundary.
	mov	__end_, ax
	mov	_pspbase_, cs		/ Save CS.
	call	_main_			/ Call _main which calls main.
	push	ax			/ Save return status,
	push	ax			/ push phoney return address
					/ and fall through to _exit.

////////
/
/ void
/ _exit(s);
/ int s;
/
/ Low level exit.
/ Return to caller.
/ Status in AX.
/
////////

_exit_: cld				/ For DOS.
	pop	ax			/ Discard return address and
	pop	ax			/ get return status in AL.
	movb	ah, $0x4C		/ Load return exit status function code
	int	0x21			/ and do it.
	
