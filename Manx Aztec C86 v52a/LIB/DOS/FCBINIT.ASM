;Copyright (C) 1983 by Manx Software Systems
; :ts=8
	include lmacros.h
	procdef fcbinit, <<jname,ptr>,<fcb,ptr>>
	pushds
	push	di
	push	si
ifndef LONGPTR
	mov	di,ds
	mov	es,di
endif
	ldptr	si,jname
	ldptr	di,fcb
	mov	ax,2900H	; issue parse filename call
	int	21H
	and	ax,0ffH
	cmp	es:byte ptr 1[di],' '
	jne	nameok
	mov	ax,-1
nameok:
	pop	si
	pop	di
	popds
	pret
	pend	fcbinit
	finish
	end
