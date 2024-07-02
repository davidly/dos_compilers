;Copyright (C) Manx Software Systems, Inc. 1987.  All rights reserved.
; :ts=8
	include	lmacros.h

dataseg	segment word public 'data'
	public	chop_ctl, round_ctl, rdown_ctl
chop_ctl dw	0fbfH		;control word for Chop mode
round_ctl dw	03bfH		;control word for Round nearest mode
rdown_ctl dw	07bfh		;control word for Round Down mode
mess	db	"8087/80287 is absent or not functional!"
	db	10		; newline
MESSLEN	equ	40
dataseg	ends

	public	$maxdigit	; this must be in CODESEG
$maxdigit dw	16		;maximum # of digits for ftoa() to produce.

	assume	ds:dataseg
	public	_chk87_, $fltinit
$fltinit proc
_chk87_:
	push	bp
	mov	bp,sp
	sub	sp,2
	fninit
	fnstcw	word ptr -2[bp]
	mov	cx,50
w1loop:	loop	w1loop			; wait for a while
	and	word ptr -2[bp],01f3fh	; clear unused bits
	cmp	word ptr -2[bp],0033fh	; is 8087 there?
	jnz	notthere		; no, return error to caller
	fstsw	word ptr -2[bp]
	mov	cx,50
w2loop:	loop	w2loop			; wait for a while
	test	word ptr -2[bp],0b8bfh	; all status bits should be off
	jz	ok_8087			; 8087 is there!!
notthere:
	stc			;bad status, no 8087 present
	jmp	short exit
ok_8087:
		;note: the carry is cleared by the test instr. above
	fldcw	word ptr round_ctl	;set initial control
exit:
	mov	sp,bp
	pop	bp
	ret
$fltinit endp

	finish
	end
