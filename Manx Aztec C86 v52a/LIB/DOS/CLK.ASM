;:ts=8
;Copyright (C) 1985 by Manx Software Systems, Inc.
;
;	IBM PC Clock Support routines
;
	include lmacros.h
;
;	divsor for 121 Hz clock is 9861 dec.
;	hex value 0x4DE0 will give exactly 60 inters. per second
	codemacro killtime
	db 0EBH
	db 0
	endm

INTVEC  	equ	20h	;location of interrupt vector for clock
TIMER		equ	40h
CNTRL		equ	43h
EXITVEC 	equ	88h
TIME_LOW	equ	61
TIME_HIGH	equ	98
TIMES		equ	6

dataseg	segment	para public 'data'

reset_ct db	TIMES
scale	 dw	0
ifdef LONGPTR
buff_add dd	0
else
buff_add dw	0
endif
buf_size dw	0
ifdef FARPROC
ofset	 dd	0
else
ofset	 dw	0
endif
	public	_mon_off_, _speed_, _ticks_
_mon_off_	dw	0
_speed_	dw	0
_ticks_	dd	0
	extrn _PSP_:word

dataseg ends

data_add  dw   	?	;codesegment variable for location of dataseg in 'C'
clk_ipvec dw	?	;memory location of the stored clock int vector's ip
clk_csvec dw	?	;memory location of the stored clock int vector's cs

;memory location of all the int vectors on how to exit a program
int22_ip  dw	?	;memory location of the stored int 22 vector's ip
int22_cs  dw	?	;memory location of the stored int 22 vector's cs

;memory location of all the int vectors in the  PSP
PSP_ip  dw	?	;memory location of the stored PSP int 22 vector's ip
PSP_cs  dw	?	;memory location of the stored PSP int 22 vector's cs

	assume	cs:codeseg, ds:dataseg

	procdef _clkinit,<<ibufad,ptr>,<ibufsz,word>,<iofset,fptr>,<iscl,word>>
	push	es			;get args. off stack for later use
	mov 	ax,word ptr ibufad
	mov 	word ptr buff_add,ax
ifdef LONGPTR
	mov	ax,word ptr ibufad+2
	mov	word ptr buff_add+2,ax
endif
	mov 	ax,ibufsz
	mov 	buf_size,ax
ifndef FARPROC
	mov 	ax,word ptr iofset
	mov 	ofset,ax
else
	push	cx
	mov	cx,4
	mov	ax,word ptr iofset
	mov	dx,word ptr 2+iofset	;convert to physical address
	rol	dx,cl
	mov	bx,dx
	and	dx,0fh
	and	bx,0fff0h
	add	ax,bx
	adc	dx,0
	mov	word ptr ofset,ax
	mov	word ptr ofset+2,dx
	pop	cx
endif
	mov 	ax,iscl
	mov 	scale,ax

	sub	ax,ax
	mov	es,ax
	mov 	ax, es:[INTVEC]  ;save contents of interupt table
	mov 	cs:clk_ipvec, ax
	mov	ax,es:[INTVEC+2]  ;ditto
	mov	cs:clk_csvec,ax
	mov 	ax, es:[EXITVEC]  ;save contents of interupt table
	mov 	cs:int22_ip, ax
	mov	ax,es:[EXITVEC+2]  ;ditto
	mov	cs:int22_cs,ax
	mov	es,_PSP_	;save contents of the PSP
	mov 	ax,es:[0ah]
	mov 	cs:PSP_ip,ax
	mov 	ax,es:[0ch]
	mov 	cs:PSP_cs,ax
	cli
	xor	ax,ax
	mov	es,ax
	mov	es:[INTVEC],offset intsr  ;insert the address of int. handler
	mov	es:[INTVEC+2],cs
	mov	cs:data_add,ds		;mov 'C' dataseg address to var.
	mov	es:[EXITVEC],offset int_22  ;insert the address of int. handler
	mov	es:[EXITVEC+2],cs
	mov	es,_PSP_
	mov 	es:[0ah], offset int_22   ;move handler into PSP
	mov	es:[0ch], cs
	sti
	xor 	ax,ax
	mov	al,36h		;use mode 3 for timer 0
	cli
	out	CNTRL,al
	killtime
	mov	ax,word ptr _speed_
	out	TIMER,al	;
	killtime
	mov	al,ah
	out	TIMER,al
	killtime
	sti
	sub	ax,ax
	mov	_speed_,ax
	pop	es
	pret
	pend _clkinit


	procdef _clkrest
	push	es
	sub	ax,ax

	cli
	mov	al,36h		;use mode 3 for timer 0
	out	CNTRL,al
	killtime
	mov	al,0h		;load low byte
	out	TIMER,al	;restore to 18.2 intrs. per second
	killtime
	out	TIMER,al

	sub	ax,ax
	mov	es,ax
	mov	ax, cs:clk_ipvec	  	;restore interupt vec. table
	mov	es:[INTVEC], ax
	mov	ax, cs:clk_csvec	  	;restore interupt vec. table
	mov	es:[INTVEC+2],ax
	mov	ax, cs:int22_ip		  	;restore interupt vec. table
	mov	es:[EXITVEC], ax
	mov	ax, cs:int22_cs		  	;restore interupt vec. table
	mov	es:[EXITVEC+2],ax
	mov	es,_PSP_				;restore the PSP
	mov 	ax,cs:PSP_ip
	mov 	es:[0ah],ax
	mov 	ax,cs:PSP_cs
	mov 	es:[0ch],ax

	sti
	pop	es
	pret
	pend _clkrest

int_22:
	sti
	push	ax
	push	dx
	push	es
	push 	ds
	call	_clkrest_
	pop	ds
	pop	es
	pop	dx
	mov	al,020h  		;send EOI to 8259
	out	020h,al
	pop	ax
	jmp	dword ptr cs:int22_ip

intsr:
	sti
	push	bp
	mov	bp,sp
	push 	ds
	push	si
	push	ax
	push	bx
	push	dx
	mov	ds,cs:data_add

	add	word ptr _ticks_,1	;get total number of interupts
	adc	word ptr _ticks_+2,0
ifndef FARPROC
	mov	ax,word ptr 4[bp]	;get cs value in interrupted code
	mov	dx,cs
	cmp	ax,dx			;compare with current cs
	jne	quit			;if not = punt
	mov	ax,word ptr 2[bp]	;get ip value in interrupted code
	sub	ax,ofset		;sub ofset (lowpc) from ip
	jb	quit			;if negative punt
	cmp	scale,1
	jz	nodiv
	xor	dx,dx
	div	scale			;div. by scale factor done in monitor
else
	mov	ax,ss:word ptr 2[bp]	;get ip value in interrupted code
	mov	dx,ss:word ptr 4[bp]	;get cs value in interrupted code
	rol	dx,1
	rol	dx,1
	rol	dx,1
	rol	dx,1
	mov	bx,dx
	and	dx,0fh
	and	bx,0fff0h
	add	ax,bx
	adc	dx,0			;convert to physical address
	sub	ax,word ptr ofset
	sbb	dx,word ptr ofset+2
	jb	quit			;if beyond bottom of range,punt
	cmp	dx,word ptr scale
	jge	quit			;if divide will overflow,punt
	cmp	word ptr scale,1
	jz	nodiv			;skip divide if index is good as is
	div	word ptr scale
endif
nodiv:
	cmp	ax,buf_size		;check to see if out of buff
	ja	quit			;if out of range punt
	shl	ax,1			;shift to get on a word boundary
	mov	si,ax
	ldptr	bx,buff_add,ds
	add	ds:word ptr [bx][si],1		;else increment word
	jnc	quit			;check to see if we overflowed a bucket
	sub	ds:word ptr 0[bx][si],1
ifdef LONGPTR
	mov	ds,cs:data_add
endif
	call	_clkrest_
	sub	ax,ax
	mov	ax,si	
	mov	_mon_off_,ax
quit:
ifdef LONGPTR
	mov	ds,cs:data_add
endif
	dec 	reset_ct
	jz	time_out
	pop	dx
	pop	bx
	pop	ax
	pop	si
	pop	ds
	pop	bp
	push	ax
	mov	al,020h  		;send EOI to 8259
	out	020h,al
	pop	ax
	iret
time_out:
	mov	reset_ct,TIMES
	pop	dx
	pop	bx
	pop	ax
	pop	si
	pop	ds
	pop	bp
	jmp	dword ptr cs:clk_ipvec
	finish
	end
