; :ts=8
;Copyright (C) 1984 by Manx Software Systems
codeseg	segment	para public 'code'
dataseg	segment	para public 'data'
save_si	dw	0
save_di	dw	0
save_sp	dw	0
save_bp	dw	0
save_ret dw	0
	extrn	_Uorg_:word, _Uend_:word
dataseg	ends
	assume	cs:codeseg,ds:dataseg
	extrn	ovmain_:near
	public $ovbgn
$ovbgn proc near
	pop	save_ret
	pop	cx		;throw away overlay name
	mov	save_sp,sp
	mov	save_bp,bp
	mov	save_si,si
	mov	save_di,di
	cld
	mov	di,offset _Uorg_	;clear uninitialized data
	mov	cx,offset _Uend_
	sub	cx,di
	shr	cx,1
	jz	nobss
	sub	ax,ax
rep	stosw
nobss:
	call	ovmain_
;
;	fall through into ovexit code
;
	public	ovexit_
ovexit_:
	mov	bp,save_bp
	mov	sp,save_sp
	mov	si,save_si
	mov	di,save_di
	push	cx		;fake argument to replace overlay name
	jmp	save_ret
$ovbgn endp
codeseg	ends
	end	$ovbgn
