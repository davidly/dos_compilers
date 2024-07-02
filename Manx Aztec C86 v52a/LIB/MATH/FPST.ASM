;	Copyright (C) 1983 by Manx Software Systems
	include lmacros.h

	internal $FPSTI

	intrdef $fprds ;preinc or predec a single float using ds:bx
	mov	cx,ds
	mov	es,cx
	jmp	short fpr

	intrdef $fprss ;preinc or predec a single float using ss:bx
	mov	cx,ss
	mov	es,cx
	jmp	short fpr

	intrdef $fpres	;preinc or predec a single float using es:bx
fpr:
	push	bx
	push	es
	call	$itod
	pop	es
	pop	bx
	push	bx
	push	es
	call	$fldses
	call	$dad
	pop	es
	pop	bx
	call	$fstes
	ret

	intrdef $fpsds ;postinc or postdec a single float using ds:bx
	mov	cx,ds
	mov	es,cx
	jmp	short fps

	intrdef $fpsss ;postinc or postdec a single float using ss:bx
	mov	cx,ss
	mov	es,cx
	jmp	short fps

	intrdef $fpses	;postinc or postdec a single float using es:bx
fps:
	push	bx
	push	es
	call	$itod
	pop	es
	pop	bx
	push	bx
	push	es
	call	$fldses
	call	$dswap
	call	$dpsh
	call	$dad
	call	$dpop
	pop	es
	pop	bx
	call	$fstes
	call	$dswap
	ret

	intrdef $dprds ;preinc or predec a double float using ds:bx
	mov	cx,ds
	mov	es,cx
	jmp	short dpr

	intrdef $dprss ;preinc or predec a double float using ss:bx
	mov	cx,ss
	mov	es,cx
	jmp	short dpr

	intrdef $dpres	;preinc or predec a double float using es:bx
dpr:
	push	bx
	push	es
	call	$itod
	pop	es
	pop	bx
	push	bx
	push	es
	call	$dldses
	call	$dad
	pop	es
	pop	bx
	call	$dstes
	ret

	intrdef $dpsds ;postinc or postdec a double float using ds:bx
	mov	cx,ds
	mov	es,cx
	jmp	short dps

	intrdef $dpsss ;postinc or postdec a double float using ss:bx
	mov	cx,ss
	mov	es,cx
	jmp	short dps

	intrdef $dpses	;postinc or postdec a double float using es:bx
dps:
	push	bx
	push	es
	call	$itod
	pop	es
	pop	bx
	push	bx
	push	es
	call	$dldses
	call	$dswap
	call	$dpsh
	call	$dad
	call	$dpop
	pop	es
	pop	bx
	call	$dstes
	call	$dswap
	ret

;
ifdef FARPROC
	extrn $itod:far,$dad:far,$dpsh:far,$dpop:far,$dswap:far
	extrn $fldses:far,$fstes:far,$dldses:far,$dstes:far
else
	extrn $itod:near,$dad:near,$dpsh:near,$dpop:near,$dswap:near
	extrn $fldses:near,$fstes:near,$dldses:near,$dstes:near
endif
$FPSTI endp
	finish
	end
