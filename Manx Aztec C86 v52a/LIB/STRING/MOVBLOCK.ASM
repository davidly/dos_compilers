;Copyright (C) 1983, 1985 by Manx Software Systems
; :ts=8
	include	lmacros.h
	procdef movblock,<<src,dword>,<dest,dword>,<len,word>>
	push	di
	push	si
	push	ds
	push	es
	pushf
	cld
	mov	cx,len
	mov	dx,cx
	test	cx,cx			; If len==0, nothing to do
	jz	done
	les	di,dest
	lds	si,src
	cmp	cx,4
	jne	not_int
	cli
not_int:
	shr	cx,1
	jz	mv_skip
rep	movsw
mv_skip:
	test	dl,1
	jz	done
	movsb
done:
	popf
	pop	es
	pop	ds
	pop	si
	pop	di
	pret
	pend	movblock
	finish
	end
