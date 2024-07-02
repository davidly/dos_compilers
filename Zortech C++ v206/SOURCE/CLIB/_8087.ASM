;_ _8087.asm   Tue Jul 11 1989   Modified by: Walter Bright */
; Copyright (C) 1985-1989 by Walter Bright
; All rights reserved.
; Written by Walter Bright

; This code is linked if _8087 is referenced.

	.286C		;disable automatic FWAIT generation

include	macros.asm

    ifdef __OS2__
	extrn	DOSDEVCONFIG:far
    endif

	public	__8087

	begdata
;__8087	dw	-1			;1 means we have an 8087 on board
__8087	dw	0			;1 means we have an 8087 on board
	enddata

	begcode	_8087

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Determine if we have and which version of 8087 we have installed.

	c_public	_8087_init
func	_8087_init

   ifdef __OS2__
; test for presence of 8087
	push	ds
	push	offset DGROUP:__8087	;where to put returned 8087 info
	push	3		;get 8087 info
	push	0		;reserved 0
	call	DOSDEVCONFIG
	test	ax,ax		;error?
	jnz	L10		;yes, use our own test for 8087
	cmp	byte ptr __8087,0
	jz	L15		;coprocessor is not present, return
L10:
    endif
	fninit			;initialize 8087 (no WAIT)
	mov	CX,20
L1:	loop	L1		;wait for it to complete
	fnstcw	__8087		;store control word
	mov	CX,10
L2:	loop	L2		;wait for it to complete

	;Determine if we have an 8087, 80287, or 80387
	xor	BX,BX		;assume no NDP
;	test	__8087,0B8BFh	;all these bits must be cleared
;	jnz	L6			;no 8087
	mov	AX,__8087
	and	AH,0Fh			;look at rounding control & precision
	.if	AH ne 3, L6		;if no 80x87
	fstcw	__8087
	inc	BX			;could be 8087, 80287 or 80387
	fwait
	and	byte ptr __8087,07Fh	;turn off interrupt mask bit
	fldcw	__8087
	fdisi				;disable interrupts (works on 8087 only)
	fstcw	__8087
	fwait
	test	byte ptr __8087,80h	;see if bit is back on
	jnz	L6			;yes, then 8087
	inc	BX			;287 or 387
	or	byte ptr __8087,0BFh	;disable interrupts, mask exceptions
	and	__8087,0EFFFh		;turn off infinity bit
	fldcw	__8087
	fld1
	fldz
	fdivp	ST(1),ST	;divide by 0 to get infinity
	fld	ST
	fchs			;create +infinity and -infinity
	fcompp			;and see if they're the same
	fstsw	AX
	or	__8087,08000h	;turn on infinity bit
	fldcw	__8087
	sahf
	jz	L6		;equal, so it's a 287
	inc	BX		;BX = 3 for 80387
L6:	mov	__8087,BX	;set flag
L15:	ret
c_endp	_8087_init

	endcode	_8087

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Setup function pointers for initialization as
; static constructors.

	static_ctor	__8087_init

	end
