
.MODEL medium
.CODE
	PUBLIC	Power2
Power2	PROC
	push	bp		; Entry sequence - save old BP
	mov 	bp,sp		; Set stack framepointer

	mov	ax,[bp+8]	; Load Arg1 into AX
	mov	cx,[bp+6]	; Load Arg2 into CX
	shl	ax,cl		; AX = AX * (2 to power of CX)
				; Leave return value in AX

	pop	bp		; Restore old framepointer
	ret	4		; Exit, and restore 4 bytes of args
Power2  ENDP
	END
