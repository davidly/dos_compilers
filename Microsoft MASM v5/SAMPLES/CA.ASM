
.MODEL SMALL
.CODE
	PUBLIC	_Power2
_Power2 PROC
	push	bp	;Entry sequence
	mov	bp,sp

	mov	ax,[bp+4]	; Load Arg1 into AX
	mov	cx,[bp+6]	; Load Arg2 into CX
	shl	ax,cl		; AX = AX * (2 to power of CX)
				; Leave return value in AX

	pop	bp		; Exit sequence
	ret
_Power2 ENDP
	END

