;                         Version 2.2
;                            AUG 89
;
;          TSR for Zortech C/C++ Toolkit Assembler Module
;           (c)1989 Walter Bright, written by Kevin Powis.

ifdef I8086S

public	__tsrdisk,_tsr_initialize,_tsr_dta_on,_tsr_dta_off,_tsr_no_pop
public	_tsr_service
public	__tsr_bypass,__tsr_debug

extrn _tsr_dosseg:word
extrn _tsr_dosoff:word
extrn _tsr_running:word
extrn _tsr_reqflag:word
extrn __tsr_timeslice:word
extrn _TSR_HOTSHIFT:word
extrn _TSR_HOTSCAN:byte

dgroup  group _data
_data   segment word public 'DATA'
__tsrdisk	db	0
		db	0
__tsr_bypass	dw	0
__tsr_debug	dw	0	;set this to 1 for debug & 0 for none
dtaes		dw	0
dtabx		dw	0
localdta	db	130	dup(0)
_data   ends

_text   segment byte public 'CODE'
        assume cs:_text,ds:dgroup

mpointer	dw	?

critms		db '     Critical Error',0
		db '  Press a key to retry.',26

below_od	db '   DOS function < 0dh',0
		db '      Press a key.',26

close_std	db '  Attempt to close std',0
		db '    handle..press key',26

memory_fn	db '   Memory allocation?',0
		db '     Not inside TSR!',26

quitit		db '     EXIT detected!!',0
		db '   use RETURN instead',26

critbuff	db 200 dup(?)

_tsr_initialize proc near
	push	bp
	mov	bp,sp
	push	bx
	push	cx
	push	dx
	push	es
	push	ds

	push	cs
	pop	ds

	mov	ax,3513h
	int	21h
	mov	cs:olddisk,bx
	mov	cs:olddisk[2],es

	mov	ax,3508h
	int	21h
	mov	cs:tsrold8,bx
	mov	cs:tsrold8[2],es

	mov	ax,3509h
	int	21h
	mov	cs:tsrold9,bx
	mov	cs:tsrold9[2],es

	mov	dx,offset cs:tsr_newint13
	mov	ah,25h
	mov	al,13h
	int	21h

	cli
	mov	dx,offset cs:tsr_newint8
	mov	ah,25h
	mov	al,08h
	int	21h
	sti

	mov	dx,offset cs:tsr_newint9
	mov	ah,25h
	mov	al,09h
	int	21h

	mov	ah,34h
	int	21h

	pop	ds
	mov	ds:_tsr_dosseg,es
	mov	ds:_tsr_dosoff,bx

	pop	es
	pop	dx
	pop	cx
	pop	bx
	pop	bp
        ret
_tsr_initialize endp

tsr_newint8 proc far
	pushf
	db	09ah
tsrold8	dw	?,?

	push	bp
	push	ds
	push	ax
	pushf

	mov	ax,dgroup
	mov	ds,ax

	cmp	ds:_tsr_running,0
	je	tsrn8_0

	mov	ax,ds:__tsr_bypass
	and	ds:_tsr_reqflag,ax
	jmp	tsrn8_8

tsrn8_0:
	cmp	ds:_tsr_reqflag,0
	jne	tsrn8_1

	cmp	ds:__tsr_bypass,0
	je	@F

tsrn8_1:
	push	di
	push	ds
	mov	di,ds:_tsr_dosoff
	mov	ax,ds:_tsr_dosseg
	mov	ds,ax
	mov	ax,0
	mov	al,ds:[di]
	pop	ds
	pop	di

	or	al,ds:__tsrdisk
	cmp	al,0
	je	tsr_go

	call	_tsr_no_pop
	jmp	@F

tsr_go:
	int	28h

@@:
	mov	ds:_tsr_reqflag,0
tsrn8_8:
	popf
	pop	ax
	pop	ds
	pop	bp
	iret
tsr_newint8 endp

tsr_newint9 proc 
	sti
	pushf
	db	09ah
tsrold9 dw	?,?
	push	ax
	push	ds
	mov	ax,dgroup
	mov	ds,ax

	mov	ah,2
	int	16h
	and	ax,15
	cmp	ax,ds:_TSR_HOTSHIFT
	jne	@F

	cmp	ds:_TSR_HOTSCAN,0
	je	tsr_n9_req

	mov	ah,1
	int	16h
	jz	@F

	cmp	ah,ds:_TSR_HOTSCAN
	jne	@F

	mov	ah,0
	int	16h

tsr_n9_req:
	mov	ds:_tsr_reqflag,1
@@:
	pop	ds
	pop	ax
	iret
tsr_newint9 endp

tsr_newint13 proc far
	pushf
	push	ax
	push	ds
	mov	ax,seg __tsrdisk
	mov	ds,ax
	mov	ds:__tsrdisk,1
	pop	ds
	pop	ax
	db	09ah
olddisk dw ?,?
	push	ax
	push	ds
	mov	ax,seg __tsrdisk
	mov	ds,ax
	mov	ds:__tsrdisk,0
	pop	ds
	pop	ax
	ret	2
tsr_newint13 endp

tsr_newint21 proc
;	Attempt to trap and report any functions that could
;	cause problems to a TSR
;	This procedure will not correct any problems, but it
;	will alert the programmer.

	push	ax
	push	dx
	push	ds
	push	ax

	mov	ax,dgroup
	mov	ds,ax
	mov	ax,ds:__tsr_debug	;only provide this service if set
	cmp	ax,1
	pop	ax
	jne	tsr_old21

	push	cs
	pop	ds

	cmp	ah,0dh		;first NO calls below 0D allowed
	ja	@F

	mov	di,offset cs:below_OD
	call	winmess
	jmp	tsr_old21
@@:
	cmp	ah,3eh		;close invalid?
	jne	@F
	cmp	bx,5
	jae	@F

	mov	di,offset cs:close_std
	call	winmess
	jmp	tsr_old21

@@:
	cmp	ah,48h
	jne	@F		;now test memory allocation

	mov	di,offset cs:memory_fn
	call	winmess
	jmp	tsr_old21

@@:
	cmp	ah,4ch		;terminate?
	jne	@F

	mov	di,offset cs:quitit
	call	winmess
	jmp	tsr_old21
@@:
tsr_old21:

	pop	ds
	pop	dx
	pop	ax
		db 0eah
dosfarip	dw 0
dosfarcs	dw 0
tsr_newint21 endp

tsr_newint24 proc far
	jmp	@F
oldcrit		dw ?,?
@@:
	sti
	push	ds
	push	es
	push	bx
	push	cx
	push	dx
	push	si
	push	di
	push	bp

	mov	di,offset cs:critms
	call	winmess
	mov	al,1             ;retry

	pop	bp
	pop	di
	pop	si
	pop	dx
	pop	cx
	pop	bx
	pop	es
	pop	ds
	iret
tsr_newint24 endp

_tsr_dta_on proc near
	push	bp
	push	ax
	push	bx
	push	cx
	push	dx
	push	ds
	push	es

	mov	ah,2fh
	int	21h

	mov	ax,dgroup
	mov	ds,ax
	mov	ds:dtaes,es
	mov	ds:dtabx,bx
	mov	dx,offset ds:localdta
	mov	ah,1ah
	int	21h

	mov	ax,3524h
	int	21h
	mov	cs:oldcrit,bx
	mov	cs:oldcrit[2],es

	push	cs
	pop	ds

	mov	dx,offset cs:tsr_newint24
	mov	ah,25h
	mov	al,24h
	int	21h

	mov	ax,3521h		;get the DOS int 21h vector
	int	21h
	mov	cs:dosfarip,bx		;save the contents
	mov	cs:dosfarcs,es

	push	cs
	pop	ds

	mov	dx,offset tsr_newint21	;and point the vector to our code
	mov	ax,2521h
	int	21h

	pop	es
	pop	ds
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	pop	bp
	ret
_tsr_dta_on endp

_tsr_dta_off proc near
	push	bp
	push	ax
	push	bx
	push	dx
	push	es
	push	ds

	mov	ax,dgroup
	mov	ds,ax
	mov	ax,ds:dtaes
	mov	dx,ds:dtabx
	mov	ds,ax
	mov	ah,1ah
	int	21h

	mov	dx,cs:oldcrit[2]
	mov	ds,dx
	mov	dx,cs:oldcrit
	mov	ax,2524h
	int	21h

	mov	dx,cs:dosfarcs
	mov	ds,dx
	mov	dx,cs:dosfarip
	mov	ax,2521h
	int	21h

	pop	ds
	pop	es
	pop	dx
	pop	bx
	pop	ax
	pop	bp
	ret
_tsr_dta_off endp

_tsr_no_pop proc
	push	bp
	push	bx
	push	cx
	push	di
	push	ds

	mov	ax,dgroup
	mov	ds,ax

	cmp	ds:__tsr_bypass,0
	jne	tsr_n99

	mov	cx,10
	mov	bx,1
	mov	di,200
@@:
	call	sound
	add	di,10
	inc	bx
	loop	@B

tsr_n99:
	pop	ds
	pop	di
	pop	cx
	pop	bx
	pop	bp
	ret
_tsr_no_pop endp

_tsr_service proc
	push	ax
	push	bx
	push	cx
	push	dx
	push	si
	push	di
	push	ds
	push	es
	push	bp

	int	28h

	pop	bp
	pop	es
	pop	ds
	pop	di
	pop	si
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	ret
_tsr_service	endp

sound proc
	push	ax
	push	bx
	push	cx
	push	dx
	push	di
	mov	al,0b6h
	out	43h,al
	mov	dx,14h
	mov	ax,4f38h
	div	di
	out	42h,al
	mov	al,ah
	out	42h,al
	in	al,61h
	mov	ah,al
	or	al,3
	out	61h,al
swait:	mov	cx,2801
spkron:	loop	spkron
	dec	bx
	jnz	swait
	mov	al,ah
	out	61h,al
	pop	di
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	ret
sound	endp

winmess proc
;	call with cs:di pointing at message
;       to be placed in window on screen
;       routine will display and wait for keypress

	push	ax
	push	bx
	push	cx
	push	dx
	push	ds
	push	si
	push	di

	mov	cs:mpointer,di

	mov	dx,0b800h
	mov	ah,0fh
	int	10h

	mov	bx,(64*256)+' '
	cmp	al,7
	jne	@F
	mov	dx,0b000h
	mov	bx,(112*256)+' '
@@:
	mov	es,dx
	mov	si,(10*160)+48
	push	si
	mov	di,offset cs:critbuff
	mov	cx,4
wmess_save_row:
	push	cx
	mov	cx,24
@@:
	mov	ax,es:[si]
	mov	es:[si],bx
	mov	cs:[di],ax
	add	si,2
	add	di,2
	loop	@B
	add	si,160-(24*2)
	pop	cx
	loop	wmess_save_row

	pop	si
	add	si,160
	push	si

	mov	di,cs:mpointer

wmess_show_message:
	mov	al,cs:[di]
	inc	di
	cmp	al,26
	je	wmess_getkey
	cmp	al,0
	jne	@F
	pop	si
	add	si,160
	push	si
	jmp	wmess_show_message
@@:
	mov	es:[si],al
	add	si,2
	jmp	wmess_show_message

wmess_getkey:
	pop	si
	mov	ah,0
	int	16h

	mov	di,(10*160)+48
	mov	si,offset cs:critbuff
	mov	cx,4
wmess_rest_row:
	push	cx
	mov	cx,24
@@:
	mov	ax,cs:[si]
	mov	es:[di],ax
	add	si,2
	add	di,2
	loop	@B
	add	di,160-48
	pop	cx
	loop	wmess_rest_row

	pop	di
	pop	si
	pop	ds
	pop	dx
	pop	cx
	pop	bx
	pop	ax

	ret

winmess endp

_text   ends
endif ;I8086S
        end

