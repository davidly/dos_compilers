;_ atoi.asm   Thu Jun 29 1989   Modified by: Walter Bright */
; Copyright (C) 1985-1989 by Walter Bright
; All Rights Reserved
; Written by Walter Bright

	include	macros.asm

	begcode	atoi

;;;;;;;;;;;;;;;;;;;;;;;;;
; Take absolute value of integer.

	c_public abs

func	abs
	push	BP
	mov	BP,SP
	mov	AX,P[BP]
	cwd
	xor	AX,DX		;look, ma, no jumps!
	sub	AX,DX		;betch'a never thought of that!
	pop	BP
	ret
c_endp	abs

;;;;;;;;;;;;;;;;;;;;;;;;;
; Take absolute value of long.

	c_public labs

func	labs
	push	BP
	mov	BP,SP
	mov	AX,P[BP]
	mov	DX,P+2[BP]
	tst	DX
	jns	L2
	neg32	DX,AX
L2:	pop	BP
	ret
c_endp	labs

;;;;;;;;;;;;;;;;;;;;;;;;;
; Convert ascii string to integer.
; Use:
;	i = atoi(p);

	c_public atoi

func	atoi
	push	BP
	mov	BP,SP
	.save	<SI>
    if SPTR
	mov	SI,P[BP]	;get p
    else
	push	DS
	lds	SI,P[BP]	;DS:SI -> string
    endif
	cld
A1:	lodsb
	.if	AL e ' ', A1
	.if	AL b 9, A3
	.if	AL be 0Dh, A1	;skip white space

A3:	clr	CX		;accumulated result
	mov	BX,CX		;assume positive
	clr	AH
	.if	AL e '+', A4
	.if	AL ne '-', A5
	dec	BX		;neg flag (BX = -1)
A4:	lodsb
A5:	sub	AL,'0'		;to binary
	jb	A2		;not a digit
	.if	AL ae 10, A2	;not a digit

	;CX = CX * 10 + AX
	shl	CX,1
	mov	DX,CX
	shl	CX,1
	shl	CX,1
	add	CX,DX
	add	CX,AX

	jmp	A4

A2:	mov	AX,CX
	xor	AX,BX
	sub	AX,BX		;if (BX == -1), negate AX
    if LPTR
	pop	DS
    endif
	.restore <SI>
	pop	BP
	ret
c_endp	atoi

	endcode	atoi

	end
