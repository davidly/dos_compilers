;_ farptr.asm   Thu Jul  7 1988   Modified by: Walter Bright */
; Copyright (C) 1985-1988 by Walter Bright
; All Rights Reserved

; Far pointer arithmetic routines

include	macros.asm

	begcode	farptr

;;;;;;;;;;;;;;;;;;;;;
; Normalize a far pointer. That is, adjust
; the segment and offset so that the offset is < 16.
;	void far *_farptr_norm(void far *);
; Example:
;	_farptr_norm((void far *)0x11002678) returns 0x13670008

	c_public	_farptr_norm
func	_farptr_norm
	push	BP
	mov	BP,SP
	mov	AX,P[BP]
	mov	DX,P+2[BP]
	pop	BP

    ifndef __OS2__
	mov	CX,AX
	and	AX,0Fh
	shr	CX,1
	shr	CX,1
	shr	CX,1
	shr	CX,1
	add	DX,CX
    endif
	ret
c_endp	_farptr_norm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Convert from long to a normalized far pointer.
; The long is taken to be a linear address from 0.
;	void far *_farptr_fromlong(long);
; Example:
;	_farptr_fromlong(0xB7543) returns 0xB7540003

	c_public _farptr_fromlong
func	_farptr_fromlong
	push	BP
	mov	BP,SP
	mov	AX,P[BP]
	mov	DX,P+2[BP]
	pop	BP

    ifndef __OS2__
	mov	CH,AL		;low 4 bits of AX will form offset
	mov	DH,DL		;upper 4 bits of segment
	shl	DH,1
	shl	DH,1
	shl	DH,1
	shl	DH,1
	shr	AX,1
	shr	AX,1
	shr	AX,1
	shr	AX,1
	clr	DL
	or	DX,AX
	mov	AL,CH		;restore AL
	and	AX,0Fh
    endif
	ret
c_endp	_farptr_fromlong

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Convert from a far pointer to long.
;	long _farptr_tolong(void far *);
; Example:
;	_farptr_tolong((void far *) 0xB7540013) returns 0xB7553

	c_public _farptr_tolong
func	_farptr_tolong
	push	BP
	mov	BP,SP
	mov	AX,P[BP]
	mov	DX,P+2[BP]
	pop	BP

    ifndef __OS2__
	rol	DX,1
	rol	DX,1
	rol	DX,1
	rol	DX,1
	mov	CX,DX
	and	DX,0Fh		;clear top 12 bits of DX
	xor	CX,DX		;clear bottom 4 bits of CX
	add	AX,CX
	adc	DL,DH		;add carry into DX (DH is 0)
    endif
	ret
c_endp	_farptr_tolong

	endcode	farptr

	end
