
.MODEL medium
.CODE

; BASIC	function for QuickBASIC, Version 4 and future versions
;   of Microsoft and IBM BASIC Compilers

	PUBLIC	Power2
Power2	PROC
	push	bp		; Entry	sequence - save	old BP
	mov	bp,sp		; Set stack framepointer

	mov	bx,[bp+8]	; Load Arg1 into
	mov	ax,[bx]		;   AX
	mov	bx,[bp+6]	; Load Arg2 into
	mov	cx,[bx]		;   CX
	shl	ax,cl		; AX = AX * (2 to power	of CX)
				; Leave	return value in	AX

	pop	bp		; Restore old framepointer
	ret	4		; Exit,	and restore 4 bytes of args
Power2	ENDP

; BASIC	subprogram for QuickBASIC, Versions 1, 2, and 3;
;     for the Microsoft	BASIC Compiler through Version 5.36
;     for the IBM BASIC	Compiler through Version 2.02

	PUBLIC	Power2S
Power2S	PROC
	push	bp		; Entry	sequence - save	old BP
	mov	bp,sp		; Set stack framepointer

	mov	bx,[bp+10]	; Load Arg1 into
	mov	ax,[bx]		;   AX
	mov	bx,[bp+8]	; Load Arg2 into
	mov	cx,[bx]		;   CX
	shl	ax,cl		; AX = AX * (2 to power	of CX)
	mov	bx,[bp+6]	; Store	result in
	mov	[bx],ax		;   Arg3

	pop	bp		; Restore old framepointer
	ret	4		; Exit,	and restore 4 bytes of args
Power2S	ENDP
	END

