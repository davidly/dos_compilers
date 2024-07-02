; :ts=8
;Copyright (C) 1983, 85 by Manx Software Systems
	include	lmacros.h
	procdef farcall, <<where,dword>, <srcregs,ptr>, <dstregs,ptr>>
	push	si
	push	di
	push	ds
	push	es
;
	ldptr	bx,srcregs,ds
	mov	ax,[bx]
	push	2[bx]		;save BX value for later
	mov	cx,4[bx]
	mov	dx,6[bx]
	mov	si,8[bx]
	mov	di,10[bx]
	mov	es,14[bx]
	mov	ds,12[bx]	;trash DS last
	pop	bx		;now get value for BX
	push	bp
	call	where
	pop	bp
	push	ds		;save returned DS
	push	bx		;save returned BX
	mov	ds,-6[bp]	;fetch C's data seg, for small model
	ldptr	bx,dstregs,ds
	mov	[bx],ax
	pop	2[bx]		;value returned in BX
	mov	4[bx],cx
	mov	6[bx],dx
	mov	8[bx],si
	mov	10[bx],di
	pop	12[bx]		;value returned in DS
	mov	14[bx],es
	pop	es
	pop	ds
	pop	di
	pop	si
	pop	bp
	pushf
	pop	ax
	ret
	pend	farcall
	finish
	end
