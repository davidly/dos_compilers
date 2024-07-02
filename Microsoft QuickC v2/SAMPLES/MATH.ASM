	.MODEL small, c
	INCLUDE demo.inc
	.CODE

;* AddLong - Adds two double-word (long) integers.
;*
;* Shows:   Instructions - add	   adc
;*
;* Params:  long1 - First integer
;*	    long2 - Second integer
;*
;* Return:  Sum as long integer

AddLong PROC \
	long1:DWORD, long2:DWORD

	mov	ax, WORD PTR long1[0]	; AX = low word, long1
	mov	dx, WORD PTR long1[2]	; DX = high word, long1
	add	ax, WORD PTR long2[0]	; Add low word, long2
	adc	dx, WORD PTR long2[2]	; Add high word, long2
	ret				; Result returned as DX:AX

AddLong ENDP




;* SubLong - Subtracts a double-word (long) integer from another.
;*
;* Shows:   Instructions -  sub     sbb
;*
;* Params:  long1 - First integer
;*	    long2 - Second integer
;*
;* Return:  Difference as long integer

SubLong PROC \
	long1:DWORD, long2:DWORD

	mov	ax, WORD PTR long1[0]	; AX = low word, long1
	mov	dx, WORD PTR long1[2]	; DX = high word, long1
	sub	ax, WORD PTR long2[0]	; Subtract low word, long2
	sbb	dx, WORD PTR long2[2]	; Subtract high word, long2
	ret				; Result returned as DX:AX

SubLong ENDP


;* MulLong - Multiplies two unsigned double-word (long) integers. The
;* procedure allows for a product of twice the length of the multipliers,
;* thus preventing overflows. The result is copied into a 4-word data area
;* and a pointer to the data area is returned.
;*
;* Shows:   Instruction - mul
;*
;* Params:  long1 - First integer (multiplicand)
;*	    long2 - Second integer (multiplier)
;*
;* Return:  Pointer to quadword result

	.DATA
	PUBLIC result
result	DQ	WORD PTR ?		; Result from MulLong 

	.CODE
MulLong PROC \
	long1:DWORD, long2:DWORD

	mov	ax, WORD PTR long2[2]	; Multiply long2 high word
	mul	WORD PTR long1[2]	;   by long1 high word
	mov	WORD PTR result[4], ax
	mov	WORD PTR result[6], dx

	mov	ax, WORD PTR long2[2]	; Multiply long2 high word
	mul	WORD PTR long1[0]	;   by long1 low word
	mov	WORD PTR result[2], ax
	add	WORD PTR result[4], dx
	adc	WORD PTR result[6], 0	; Add any remnant carry

	mov	ax, WORD PTR long2[0]	; Multiply long2 low word
	mul	WORD PTR long1[2]	;   by long1 high word
	add	WORD PTR result[2], ax
	adc	WORD PTR result[4], dx
	adc	WORD PTR result[6], 0	; Add any remnant carry

	mov	ax, WORD PTR long2[0]	; Multiply long2 low word
	mul	WORD PTR long1[0]	;   by long1 low word
	mov	WORD PTR result[0], ax
	add	WORD PTR result[2], dx
	adc	WORD PTR result[4], 0	; Add any remnant carry

	mov	ax, OFFSET result	; Return pointer
	mov	dx, @data		;   to result
	ret

MulLong ENDP


;* ImulLong - Multiplies two signed double-word integers. Because the imul
;* instruction (illustrated here) treats each word as a signed number, its
;* use is impractical when multiplying multi-word values. Thus the technique
;* used in the MulLong procedure can't be adopted here. Instead, ImulLong
;* is broken into three sections arranged in ascending order of computational
;* overhead. The procedure tests the values of the two integers and selects
;* the section that involves the minimum required effort to multiply them.
;*
;* Shows:   Instruction - imul
;*
;* Params:  long1 - First integer (multiplicand)
;*	    long2 - Second integer (multiplier)
;*
;* Return:  Result as long integer

ImulLong PROC \
	USES si, \
	long1:DWORD, long2:DWORD

; Section 1 tests for integers in the range of 0 to 65,535. If both
; numbers are within these limits, they're treated as unsigned short
; integers.

sect1:	mov	ax, WORD PTR long2[0]	; AX = low word of long2
	mov	dx, WORD PTR long2[2]	; DX = high word of long2
	mov	bx, WORD PTR long1[0]	; BX = low word of long1
	mov	cx, WORD PTR long1[2]	; CX = high word of long1
	or	dx, dx			; Both high words zero?
	jnz	sect2			; No?  Go to section 2
	or	cx, cx
	jnz	sect2
	mul	bx			; Yes?	Multiply the low words
	jmp	SHORT exit		;   and exit section 1

; Section 2 tests for integers in the range of -32,768 to 32,767. If
; both numbers are within these limits, they're treated as signed short
; integers.

sect2:	push	ax			; Save long2 low word
	push	bx			; Save long1 low word
	or	dx, dx			; High word of long2 = 0?
	jnz	@F			; No?  Test for negative
	test	ah, 80h 		; Low word of long2 in range?
	jz	skip1			; Yes?	long2 ok, so test long1
	jmp	SHORT sect3		; No?  Go to section 3
@@:	cmp	dx, 0FFFFh		; Empty with sign flag set?
	jne	sect3			; No?  Go to section 3
	test	ah, 80h 		; High bit set in low word?
	jz	sect3			; No?  Low word is too high

skip1:	or	cx, cx			; High word of long1 = 0?
	jnz	@F			; No?  Test for negative
	test	bh, 80h 		; Low word of long1 in range?
	jz	skip2			; Yes?	long1 ok, so use sect 2
	jmp	SHORT sect3		; No?  Go to section 3
@@:	cmp	cx, 0FFFFh		; Empty with sign flag set?
	jne	sect3			; No?  Go to section 3
	test	bh, 80h 		; High bit set in low word?
	jz	sect3			; No?  Low word is too high

skip2:	imul	bx			; Multiply low words
	pop	bx			; Clean stack
	pop	bx
	jmp	SHORT exit		; Exit section 2

; Section 3 involves the most computational overhead. It treats the two
; numbers as signed long (double-word) integers.

sect3:	pop	bx			; Recover long1 low word
	pop	ax			; Recover long2 low word
	mov	si, dx			; SI = long2 high word
	push	ax			; Save long2 low word
	mul	cx			; long1 high word x long2 low word
	mov	cx, ax			; Accumulate products in CX
	mov	ax, bx			; AX = low word of long1
	mul	si			; Multiply by long2 high word
	add	cx, ax			; Add to previous product
	pop	ax			; Recover long2 low word
	mul	bx			; Multiply by long1 low word
	add	dx, cx			; Add to product high word

exit:	ret				; Return result as DX:AX

ImulLong ENDP


;* DivLong - Divides an unsigned long integer by an unsigned short integer.
;* The procedure does not check for overflow or divide-by-zero.
;*
;* Shows:   Instruction -  div
;*
;* Params:  long1 - First integer (dividend)
;*	    short2 - Second integer (divisor)
;*	    remn - Pointer to remainder
;*
;* Return:  Quotient as short integer

DivLong PROC \
	USES di, \
	long1:DWORD, short2:WORD, remn:PTR WORD

	mov	ax, WORD PTR long1[0]	; AX = low word of dividend
	mov	dx, WORD PTR long1[2]	; DX = high word of dividend
	div	short2			; Divide by short integer
	LoadPtr es, di, remn		; Point ES:DI to remainder
	mov	es:[di], dx		; Copy remainder
	ret				; Return with AX = quotient

DivLong ENDP


;* IdivLong - Divides a signed long integer by a signed short integer.
;* The procedure does not check for overflow or divide-by-zero.
;*
;* Shows:   Instruction - idiv
;*
;* Params:  long1 - First integer (dividend)
;*	    short2 - Second integer (divisor)
;*	    remn - Pointer to remainder
;*
;* Return:  Quotient as short integer

IdivLong PROC \
	USES di, \
	long1:DWORD, short2:WORD, remn:PTR WORD

	mov	ax, WORD PTR long1[0]	; AX = low word of dividend
	mov	dx, WORD PTR long1[2]	; DX = high word of dividend
	idiv	short2			; Divide by short integer
	LoadPtr es, di, remn		; ES:DI = remainder
	mov	es:[di], dx		; Copy remainder
	ret				; Return with AX = quotient

IdivLong ENDP


;* Quadratic - Solves for the roots of a quadratic equation of form
;*			  A*x*x + B*x + C = 0
;* using floating-point instructions. This procedure requires either a math
;* coprocessor or emulation code. If executing within the QuickAssembler
;* environment, emulation is automatically provided if a coprocessor is not
;* installed. If executing from the QCL command line, the /FPi switch must
;* be specified if a coprocessor is not installed. For example, to create
;* the MATHDEMO.EXE example program with floating-point emulation, enter the
;* following line:
;*		   QCL /Cx mathdemo.c /FPi math.asm common.asm
;*
;* Shows:   Instructions - sahf     fld1     fld     fadd     fmul
;*			   fxch     fsubr    fchs    fsubp    fstp
;*			   fst	    fdivr    fwait   ftst
;*
;* Params:  a - Constant for 2nd-order term
;*	    b - Constant for 1st-order term
;*	    c - Equation constant
;*	    r1 - Pointer to 1st root
;*	    r2 - Pointer to 2nd root
;*
;* Return:  Short integer with return code
;*	    0 if both roots found
;*	    1 if single root (placed in r1)
;*	    2 if indeterminate

Quadratic PROC \
	USES ds di si, \
	a:DWORD, b:DWORD, c:DWORD, r1:PTR DWORD, r2:PTR DWORD

	LOCAL status:WORD		; Intermediate status

	LoadPtr es, di, r1		; ES:DI points to 1st root
	LoadPtr ds, si, r2		; DS:SI points to 2nd root
	sub	bx, bx			; Clear error code
	fld1				; Load top of stack with 1
	fadd	st, st			; Double it to make 2
	fld	st			; Copy to next register
	fmul	a			; ST register = 2a
	ftst				; Test current ST value
	fstsw	status			; Copy status to local word
	fwait				; Ensure coprocessor is done
	mov	ax, status		; Copy status into AX
	sahf				; Load flag register
	jnz	@F			; If C3 set, a = 0, in which case
					;   solution is x = -c / b
	fld	b			; Load b parameter
	ftst				; Test current ST value
	fstsw	status			; Copy status to local word
	fwait				; Ensure coprocessor is done
	mov	ax, status		; Copy status into AX
	sahf				; Load flag register
	jz	exit2			; If C3 set, b = 0, so don't divide
	fld	st			; Copy b to next register
	fld	c			; Load C parameter
	fchs				; Reverse sign
	fxch				; Exchange ST and ST(1)
	fdiv				; Divide c by b
	fst	DWORD PTR es:[di]	; Copy result
	jmp	SHORT exit1		; Return with code = 1

@@:	fmul	st(1), st		; ST(1) register = 4a
	fxch				; Exchange ST and ST(1)
	fmul	c			; ST register = 4ac
	ftst				; Test current ST value
	fstsw	status			; Copy status to local word
	fwait				; Ensure coprocessor is done
	mov	ax, status		; Copy status into AX
	sahf				; Load flag register
	jp	exit2			; If C2 set, 4*a*c is infinite

	fld	b			; Else load b parameter
	fmul	st, st			; Square it; ST register = b*b
	fsubr				; ST register = b*b - 4*a*c
	ftst				; Test current ST value
	fstsw	status			; Copy status to local word
	fwait				; Ensure coprocessor is done
	mov	ax, status		; Copy status into AX
	sahf				; Load flag register
	jc	exit2			; If C0 set, b*b < 4ac
	jnz	@F			; If C3 set, b*b = 4ac, in which
	inc	bx			;   case only 1 root so set flag

@@:	fsqrt				; Get square root
	fld	b			; Load b parameter
	fchs				; Reverse sign
	fxch				; Exchange ST and ST1
	fld	st			; Copy square root to next reg
	fadd	st, st(2)		; ST = -b + sqrt(b*b - 4*a*c)
	fxch				; Exchange ST and ST1
	fsubp	st(2), st		; ST = -b - sqrt(b*b - 4*a*c)

	fdiv	st, st(2)		; Divide 1st dividend by 2*a
	fstp	WORD PTR es:[di]	; Copy result, pop stack
	fdivr				; Divide 2nd dividend by 2*a
	fstp	WORD PTR ds:[si]	; Copy result, pop stack
	jmp	SHORT exit		; Return with code

exit2:	inc	bx			; Error code = 2 for indeterminancy
exit1:	inc	bx			; Error code = 1 for single root
exit:	mov	ax, bx
	ret

Quadratic ENDP

	END
