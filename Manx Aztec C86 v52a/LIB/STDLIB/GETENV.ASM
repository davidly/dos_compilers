; Copyright (C) 1984 by Manx Software Systems
; :ts=8
	include	lmacros.h
dataseg segment para public 'data'
	ifndef	LONGPTR
retbuf	db	256 dup (?)
	endif
	extrn	_PSP_:word
dataseg	ends
	assume	ds:dataseg
	procdef	getenv, <<jname,ptr>>
;			char *getenv(name)
;			char *name;
;
	push	ds
	push	si
	push	di
ifndef LONGPTR
	mov	bx,ds
	mov	es,bx
endif
	cld
	ldptr	bx,jname,es
	mov	ds,ds:_PSP_	;fetch segment of PSP
	mov	ds,ds:[2cH]	;get environment segment
	sub	si,si
envloop:
	lodsb
	test	al,al
	jz	nostring
	sub	di,di
cmploop:
	cmp	al,'='
	jne	notaneq
	sub	al,al
notaneq:
	cmp	al,es:[bx][di]
	jne	next
	test	al,al
	je	foundit
	inc	di
	lodsb
	test	al,al
	jne	cmploop
	jmp	envloop
next:
	lodsb
	test	al,al
	jne	next
	jmp	envloop
;
foundit:
ifndef LONGPTR
;
; copy string to local buffer, so we can return a 16-bit pointer to it.
;
	mov	di,offset retbuf
	mov	cx,255
cpyloop:
	lodsb
	stosb
	test	al,al
	loopnz	cpyloop
	sub	al,al
	stosb			;guarantee null termination
	mov	ax,offset retbuf
	test	ax,ax
	jmp	short done
;
nostring:
	sub	ax,ax
done:
else
	mov	dx,ds
	mov	ax,si
	jmp	short done

nostring:
	sub	ax,ax
	sub	dx,dx

done:
endif
	pop	di
	pop	si
	pop	ds
	pret
	pend	getenv
	finish
	end
