; Copyright (C) 1984, 1985 by Manx Software Systems, Inc.
; :ts=8
	include lmacros.h
	procdef	memcmp,<<dest,ptr>,<src,ptr>,<lim,word>>
	push	si
	push	di
	pushds
	cld
ifndef LONGPTR
	mov	di,ds
	mov	es,di
endif
	ldptr	si,dest
	ldptr	di,src
	mov	cx,lim
	jcxz	done
repe	cmpsb
	mov	ax,0
	ja	greater
	je	done
	dec	ax
done:
	popds
	pop	di
	pop	si
	pret
greater:
	inc	ax
	jmp	done
	pend	memcmp
	finish
	end
