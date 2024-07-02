;Copyright (C) 1983, 1985 by Manx Software Systems
; :ts=8
	include	lmacros.h
	procdef peekw,<<addr,dword>>
	push	ds
	lds	bx,addr
	mov	ax,ds:[bx]
	pop	ds
	pret
	pend	peekw
;
	entrdef peekb
	procdef peek,<<addr1,dword>>
	push	ds
	lds	bx,addr1
	mov	al,ds:[bx]
	and	ax,0ffH
	pop	ds
	pret
	pend	peek
;
	procdef pokew,<<addr2,dword>,<val,word>>
	push	ds
	mov	ax,val
	lds	bx,addr2
	mov	ds:[bx],ax
	pop	ds
	pret
	pend	pokew
;
	entrdef poke
	procdef pokeb,<<addr3,dword>,<val1,byte>>
	push	ds
	mov	al,val1
	lds	bx,addr3
	mov	ds:[bx],al
	pop	ds
	pret
	pend	pokeb
	finish
	end
