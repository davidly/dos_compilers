; Copyright (C) 1984, 1985 by Manx Software Systems
; :ts=8
	include lmacros.h
;
;	If you want your stack at a fixed place, you may remove the
;	"bss cstack..." statement below and change the "mov sp,cstack..."
;	to load SP with the value you desire.  Note that the setup of
;	SS may need to be changed also.  If the program is small data
;	model, then SS must be equal to DS or pointers to automatic
;	variables won't work.
;
;	Otherwise, stacksize should be set according to your program's
;	requirements.
stacksize equ	2048
;
;	dataseg is the data segment address (as a paragraph #)
;	this is picked from the -D option of the linker
;
;Dseg	equ	040H	;physical addr 0x400, just above the int vectors

dataseg	segment	word public 'data'

;	bss	cstack:byte,stacksize
	global	cstack:byte,stacksize
	public	$MEMRY
$MEMRY	dw	-1
	dw	-1
	public	errno_
errno_	dw	0
	public	_dsval_,_csval_
_dsval_	dw	0
_csval_	dw	0
	public	_mbot_, _sbot_
_mbot_	dw	0
	dw	0
_sbot_	dw	0
	dw	0
;
; The variable is used with csav and cret only.  Therefore if you do not 
; compile the the +c option or +b option you do not need this.
;
	public	_lowwater_
_lowwater_	dw	-1
	extrn	_Dorg_:byte,_Dend_:byte
	extrn	_Uorg_:byte,_Uend_:byte
dataseg	ends
	extrn	_Corg_:byte,_Cend_:byte

ifdef	FARPROC
	extrn main_:far, $fltinit:far
else
	extrn main_:near, $fltinit:near
endif

	public	$begin
$begin	proc	far
	cli
	cld
;
;	Compute where initialzed data starts (@ next para after code)
;
	mov	ax,offset _Cend_+15
	mov	cl,4
	shr	ax,cl
	add	ax,seg _Cend_
	mov	ds,ax		;place where data is in rom
	mov	bx,dataseg	;place where data is to go in ram
	mov	es,bx
;
;	Note: For hardware reasons the instruction which loads SS should
;		be immediatly followed by the load of SP.
;
	mov	ss,bx
	mov	sp,offset cstack+stacksize
;
;		copy Init data from rom to ram
	mov	di,0
	mov	cx,offset _Dend_
	inc	cx
	shr	cx,1
	jcxz	nocopy
	mov	si,0
rep	movsw
nocopy:
;
;		clear uninitialized data
	mov	di,offset _Uorg_
	mov	cx,offset _Uend_
	sub	cx,di
	inc	cx
	shr	cx,1
	jcxz	noclear
	sub	ax,ax
rep	stosw
noclear:
;
	assume	ds:dataseg,es:dataseg

	mov	ds,bx			;set DS, now DS, SS, ES are equal
	mov	di,$MEMRY
	inc	di
	and	di,0fffeH	;adjust to word boundary
	mov	$MEMRY,di	;save memory allocation info for sbrk()
	mov	$MEMRY+2,ds
	mov	_mbot_,di
	mov	_mbot_+2,ds
	mov	_sbot_,0ffffH	;this is the heap limit for sbrk()
	mov	_sbot_+2,0fff0h
	mov	_dsval_,ds
	mov	_csval_,cs	;this is of dubious value in large code
	sti
	call	$fltinit	;setup floating point software/hardware
	jnc	flt_ok
	hlt			;program needs 8087 and one wasn't found
flt_ok:
	jmp	main_		;main shouldn't return in ROM based system
$begin	endp
codeseg	ends
	end	$begin
