;	Copyright Manx Software Systems, Inc. 1983, 1987
; :ts=8
	include lmacros.h

dataseg	segment word public 'data'
ifdef STATRES
result	db 8 dup (?)
endif
dataseg	ends
	assume	ds:dataseg

	procdef	fmod, <<doub,cdouble>,<denom,cdouble>>
;
;		double fmod(doud,denom)
;
	sub	sp,2
	fld	qword ptr denom
	ftst
	fstsw	word ptr -2[bp]
	fwait
	mov	ah,byte ptr -1[bp]
	sahf
	jnz	divok
	fstp	st(0)
	fld	qword ptr doub
	jmp	exit
divok:
	fabs
	fld	qword ptr doub
	ftst
	fstsw	word ptr -2[bp]
	fwait
	mov	ah,byte ptr -1[bp]
	xor	bx,bx
	sahf
	jnc	notneg
	mov	bx,1
	fabs
notneg:
	fprem
	ftst
	fstsw	word ptr -2[bp]
	fwait
	mov	ah,byte ptr -1[bp]
	sahf
	jz	done
	fcom	st(1)
	fstsw	word ptr -2[bp]
	fwait
	mov	ah,byte ptr -1[bp]
	sahf
	ja	notneg
done:
	fxch
	fstp	st(0)
	test	bx,bx
	jz	exit
	fchs
exit:
ifdef STATRES
	fstp	qword ptr result
	mov	ax,offset result
ifdef LONGPTR
	mov	dx,ds
endif
	fwait
endif
	add	sp,2
	pret
	pend	fmod
	finish
	end
