;_ doserr.asm   Tue Sep  5 1989   Modified by: Walter Bright */
; $Header$
;Copyright (C) 1989 by Walter Bright
;All rights reserved.
;Written by Dave Mansell

include	macros.asm


DOSERROR STRUC
	exterr	dw	?
	eclass	db	?
	action	db	?
	locus	db	?
DOSERROR ENDS

	begcode	doserr

	public dosexterr
dosexterr:

	c_public dos_exterr

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; get dos extended error information

func	dos_exterr
	push	BP
	mov	BP,SP
	push	DI
	clr	BX
	bdos	59h
    if SPTR
	mov	DI,P[BP]	;where to store the information
	tst	DI		;passed a null pointer?
	jz	a1
    else
	push	DS
	lds	DI,P[BP]	;where to store the information
	mov	DX,DS
	or	DX,DI
	je	a1		;passed a null pointer?
    endif
	mov	exterr[DI],AX
	mov	eclass[DI],BH
	mov	action[DI],BL
	mov	locus[DI],CH
a1:
    if LPTR
	pop	DS
    endif
	pop	DI
	pop	BP
	ret
c_endp	dos_exterr

	endcode	doserr

	end

