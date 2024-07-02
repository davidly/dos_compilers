;_ dosfil.asm   Tue Oct 10 1989   Modified by: Walter Bright */
; $Header$
;Copyright (C) 1989 by Walter Bright
;All rights reserved.
;Written by Dave Mansell

include	macros.asm

FILEINFO STRUC
	dcreate		dw	?
 	tcreate		dw	?
	daccess		dw	?
	taccess		dw	?
	dwrite		dw	?
	twrite		dw	?
	fsize		dd	?
	falloc		dd	?
	fattr		dw	?
FILEINFO ENDS

FILEINFOSIZE EQU 22

    ifdef __OS2__
	extrn	DOSQCURDISK:far
	extrn	DOSQFILEINFO:far
	extrn	DOSSETFILEINFO:far
    endif

	begdata
	c_extrn	errno,word
	enddata

	begcode	dosfil

	c_public dos_setdrive,dos_getdrive
	c_public dos_setftime,dos_getftime
	c_public dos_setfileattr,dos_getfileattr

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; get default disk drive 
; 1 = A, 2 = B etc.

func	dos_getdrive
	push	BP
	mov	BP,SP
	bdos	19h		;get default disk drive no
	clr	AH
	inc	AX
    if SPTR
	mov	BX,P[BP]	;where to store the drive no
	mov	[BX],AX
    else
	les	BX,P[BP]	;where to store the drive no
	mov	ES:[BX],AX
    endif
	pop	BP
	ret
c_endp	dos_getdrive

;;;;;;;;;;;;;;;;;;;;;;;;;
; set default disk drive

func	dos_setdrive
	push	BP
	mov	BP,SP
	mov	DX,P[BP]	;disk drive number (1 = A)
	dec	DX
	bdos	0Eh		;set default drive to DL
	clr	AH		;AL = total no of logical drives
    if SPTR
	mov	BX,P+2[BP]	;where to store the no of drives
	mov	[BX],AX
    else
	les	BX,P+2[BP]	;where to store the no of drives
	mov	ES:[BX],AX
    endif
	pop	BP
	ret
c_endp	dos_setdrive

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; get the file date/time.
;	int dos_getftime(fd,date,time)

func	dos_getftime
	push	BP
	mov	BP,SP
	mov	BX,P[BP]	;file descriptor
	mov	AX,5700h
	bdos			;get file time
	jc	A2		;if error
    if SPTR
	mov	BX,P+2[BP]	;where to store the date
	mov	[BX],DX
	mov	BX,P+4[BP]	;where to store the time
	mov	[BX],CX
    else
	les	BX,P+2[BP]	;where to store the date
	mov	ES:[BX],DX
	les	BX,P+6[BP]	;where to store the time
	mov	ES:[BX],CX
    endif
A4:	clr	AX
	pop	BP
	ret
c_endp	dos_getftime

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; set the file date/time.
;	int dos_setftime(fd,date,time)

func	dos_setftime
	push	BP
	mov	BP,SP
	mov	BX,P[BP]	;file descriptor
	mov	AX,5701h
	mov	DX,P+2[BP]	;the date
	mov	CX,P+4[BP]	;the time
	bdos 			;set file time
A3:	jnc	A4
A2:	mov	errno,AX
	pop	BP
	ret
c_endp	dos_setftime

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; get the file attribute.
;	unsigned dos_getfileattr(path,attribute)

func	dos_getfileattr
	push	BP
	mov	BP,SP
	mov	AX,4300h
    if SPTR
	mov	DX,P[BP]	;path
	bdos			;get file attribute
	jc	A2
	mov	BX,P+2[BP]	;where to store the attribute
	mov	[BX],CX
    else
	push	DS
	lds	DX,P[BP]	;path
	bdos			;get file attribute
	pop	DS
	jc	A2
	les	BX,P+4[BP]	;where to store the attribute
	mov	ES:[BX],CX
    endif
	jmp	A4
c_endp	dos_getfileattr

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; set the file attribute.
;	unsigned dos_setfileattr(path,attribute)

func	dos_setfileattr
	push	BP
	mov	BP,SP
	mov	AX,4301h
    if SPTR
	mov	DX,P[BP]	;path
	mov	CX,P+2[BP]	;attribute
	bdos			;get file attribute
    else
	push	DS
	lds	DX,P[BP]	;path
	mov	CX,P+4[BP]	;attribute
	bdos			;get file attribute
	pop	DS
    endif
	jmp	A3
c_endp	dos_setfileattr

	endcode	dosfil

	end

