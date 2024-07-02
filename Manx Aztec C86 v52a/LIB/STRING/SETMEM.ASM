; :ts=8
;Copyright (C) 1983 by Manx Software Systems
	include	lmacros.h
	procdef _setmem,<<src,ptr>,<len,word>,<val,byte>>
	pushf
	cld
	push	di
ifndef LONGPTR
	mov	di,ds
	mov	es,di
endif
	ldptr	di,src,es
	mov	cx,len
	mov	al,val
	mov	ah,al
	mov	dx,cx
	shr	cx,1
	jz	skip
rep	stosw
skip:
	test	dl,1
	jz	done
	stosb
done:
	pop	di
	popf
	pret
	pend	_setmem
	finish
	end
