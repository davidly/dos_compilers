; Copyright (C) 1984 by Manx Software Systems
; :ts=8
	include lmacros.h
dataseg segment para public 'data'
param	equ	this word
env	dw	?
cline	dw	?,?
fcb1	dw	?,?
fcb2	dw	?,?
	extrn	errno_:word
dataseg	ends
	assume	ds:dataseg
save_ss	dw	0
save_sp	dw	0
	procdef	fexec,<<filname,ptr>,<enva,word>,<clinea,ptr>,<fcb1a,ptr>,<fcb2a,ptr>>
;			char *fexec(name,env,cline,fcb1,fcb2)
;
	push	si
	push	di
	pushf
	push	[030H]
	push	[02EH]
	push	ds
	push	es
	mov	cs:save_ss,ss
	mov	cs:save_sp,sp
;
;	set up parameter block for exec call
;
	mov	ax,enva
	mov	env,ax
ifndef LONGPTR
	mov	ax,ds
	mov	es,ax
endif
	ldptr	ax,clinea,es
	mov	cline,ax
	mov	cline+2,es
	ldptr	ax,fcb1a,es
	mov	fcb1,ax
	mov	fcb1+2,es
	ldptr	ax,fcb2a,es
	mov	fcb2,ax
	mov	fcb2+2,es
;
	mov	ax,ds
	mov	es,ax
	mov	bx,offset param
	ldptr	dx,filname,ds		;name of file to exec
	mov	ax,04b00H
	int	21h
	mov	ss,cs:save_ss
	mov	sp,cs:save_sp
	pop	es
	pop	ds
	jnc	noerror
	mov	errno_,ax
	mov	ax,-1
	jmp	short done
noerror:
	sub	ax,ax
done:
	pop	[02EH]
	pop	[030H]
	popf
	pop	di
	pop	si
	pret
	pend	fexec
	finish
	end
