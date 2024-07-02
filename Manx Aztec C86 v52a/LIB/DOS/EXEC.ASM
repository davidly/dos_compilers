; Copyright (C) 1984 by Manx Software Systems
; :ts=8
	include	lmacros.h

ifdef FARPROC
	extrn	_sigfix_:far
else
	extrn	_sigfix_:near
endif
;
e_magic	equ	0
e_used	equ	2	;number of bytes used in final sector of file
e_pages	equ	4	;size of file in 512-byte pages
e_nreloc equ	6	;number relocation table items
e_hsize	equ	8	;size of header in 16-byte paragraphs
e_min	equ	10	;minimum # of para required above program
e_max	equ	12	;maximum # of para    "       "      "
e_ss	equ	14	;offset of stack segment in load module
e_sp	equ	16	;initial SP value
e_csum	equ	18	;negative sum of all words in the file
e_ip	equ	20	;starting IP for program
e_cs	equ	22	;   "     CS    "
e_freloc equ	24	;offset of first relocation item
e_ovly	equ	26	;overlay number

;
ldrsize	equ	1024
header	equ	ldrsize-30
reloc	equ	26
startad	equ	0
;
dataseg segment word public 'data'
	extrn _PSP_:word
dataseg ends
;
;exec(fd,cline,fcb1,fcb2,header)
;	NOTE: This function never returns, even if the exec
;	fails.
;
	procdef exec,<<fd,word>,<cline,ptr>,<fcb1,ptr>,<fcb2,ptr>,<head,ptr>>
;
;	copy cmd line and fcb's into PSP
;
load	proc far		;so returns are far
	push	ds
	call	_sigfix_		;restore int 22,23 vectors
	mov	es,ds:_PSP_		;fetch segment of PSP
	ldptr	si,cline,ds
	mov	di,80h
	mov	cx,64
rep	movsw				;copy command line
	ldptr	si,fcb1,ds
	mov	di,5ch
	mov	cx,8
rep	movsw				;copy fcb1
	ldptr	si,fcb2,ds
	mov	cx,8
rep	movsw				;copy fcb2
;
	mov	bx,0ffffh		;ask for all of memory
	mov	ah,4ah
	int	21h
	mov	ah,4ah			;then ask for what we can get
	int	21h
;
	mov	dx,fd		;file handle
	ldptr	si,head,ds	;exe header from file
	cmp	ds:word ptr [si+e_magic],5a4dh	;check magic #
	je	exefile

	mov	bp,bx			;compute new SP
	cmp	bp,4096			;check size of segment
	jbe	smallstk
	mov	bp,4096
smallstk:
	mov	cx,4
	shl	bp,cl			;new SP
;
	mov	cx,es
	add	bx,cx		;end of our segment
	sub	bx,8		;get 128 bytes for loader and stack
	mov	es,bx
	pop	si		; get old ds value back
	mov	ss,bx
	mov	sp,128
	push	si		; push old ds on stack for later use
;
	mov	cx,cs
	mov	ds,cx
	mov	si,offset com_loader
	sub	di,di
	mov	cx,offset com_ldend
	sub	cx,si
rep	movsb
;
	mov	bx,dx		;handle into bx for io calls
	sub	cx,cx
	sub	dx,dx
	mov	ax,4200H
	int	21H		;rewind file
;
	mov	dx,100H		;address to read data into
	lea	cx,[bp-256]	;byte count to read in
	pop	ds
	mov	ax,ds:_PSP_	;segment of PSP
	mov	ds,ax
	mov	es,ax
	push	ss
	sub	ax,ax
	push	ax
	mov	ah,3fH
	ret
;
;	this block of code is moved to the top of available memory
;	and jumped to with the registers for a read call setup
;
com_loader:
	int	21h
	jnc	ok
	mov	ax,4cfeh
	int	21h
ok:
	mov	ah,3eH
	int	21h		;close the file
	mov	ax,ds
	mov	ss,ax
	mov	sp,bp
	push	ax		;push new cs
	mov	ax,100h
	push	ax		;push new ip
	ret
com_ldend:
;
;
exefile:
	mov	cx,es
	add	bx,cx		;end of our segment
	sub	bx,ldrsize/16	;get mem for loader, header, and stack
	mov	es,bx
	mov	di,header
	mov	cx,13
rep	movsw				;copy 26 byte file header
;
	pop	si		; get old ds value
	mov	ss,bx
	mov	sp,header
	push	si		; push old ds value on new stack for later use
;
	mov	cx,cs
	mov	ds,cx
	mov	si,offset exe_loader
	sub	di,di
	mov	cx,offset exe_ldend
	sub	cx,si
rep	movsb
;
	pop	ds	
	mov	ax,ds:_PSP_	;segment of PSP
	push	ax		;ES, DS value for program
	add	ax,10h
	mov	ds,ax		;place to load program
	mov	bp,ax
	mov	bx,dx		;get handle into bx for int 21h
;
	mov	di,header
	mov	dx,ss:e_hsize[di]	;compute offset of program
	sub	ax,ax
	mov	cl,4
lshift:
	shl	dx,1
	rcl	ax,1
	loop	lshift
	mov	cx,ax
	mov	ax,4200H
	int	21h		;lseek to load module
	jc	punt
;
	mov	si,ss:e_pages[di]
	mov	cl,5
	shl	si,cl		;# paragraphs in file
	sub	si,ss:e_hsize[di]	;now, # para in program
;
	push	ss		;CS for loader
	sub	ax,ax
	push	ax		;IP for loader
	ret			;far return to code at top of mem
;
;	this code is moved to the top of our segment and jumped to
;	with the following registers setup:
;		bx - file handle of program
;		ds, bp - where to load the program
;		di - points to the exe header
;		si - # para to read in
;		PSP address pushed onto stack
;
exe_loader:
	mov	ah,3fH
	mov	cx,0fff0h	;read as much as possible at once
	cmp	si,0fffh	;check how much is left to read
	ja	cx_ok
	mov	cl,4		;if less, then compute remaining
	shl	si,cl
	mov	cx,si
	mov	si,0fffh
cx_ok:
	sub	dx,dx
	int	21h
	jnc	read_ok
punt:
	mov	ax,4cfeh
	int	21h
read_ok:
	test	ax,ax
	jz	load_done
	mov	ax,ds
	add	ax,0fffh
	mov	ds,ax
	sub	si,0fffh
	ja	exe_loader
;
load_done:
	mov	ax,cs
	mov	ds,ax
	cmp	word ptr e_nreloc[di],0
	jz	reloc_done
	mov	dx,e_freloc[di]
	sub	cx,cx
	mov	ax,4200H
	int	21H		;lseek to relocation info
	jc	punt
relocate:
	lea	dx,reloc[di]
	mov	cx,4
	mov	ah,3fH
	int	21H
	jc	punt
	cmp	ax,4
	jne	punt
	mov	si,reloc[di]
	mov	ax,reloc+2[di]
	add	ax,bp
	mov	es,ax
	add	es:[si],bp
	dec	word ptr e_nreloc[di]
	jnz	relocate
reloc_done:
	mov	ah,3eH
	int	21h		;close file
	add	e_ss[di],bp	;relocate stack segment
	add	e_cs[di],bp	;relocate starting CS
	pop	ax		;get PSP address before changing stack
	mov	ss,e_ss[di]
	mov	sp,e_sp[di]
	mov	ds,ax
	mov	es,ax
	jmp	cs:dword ptr e_ip[di]
exe_ldend:
load	endp
	pend	exec
	finish
	end
