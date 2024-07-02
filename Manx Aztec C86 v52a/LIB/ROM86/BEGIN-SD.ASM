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
stacksize equ	80h		;# paras in stack area
heapsize  equ	80h		;# paras in heap area

dataseg	segment	word public 'data'
	bss	cstack:byte,stacksize shl 4
	global	errno_:word,2
	global	_dsval_:word,2
	global	_csval_:word,2
	global	_mbot_:word,2
	global	_mcur_:word,2
	global	_mtop_:word,2
	global	_sbot_:word,2
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
; A copy of the program's initialized data follows the program's code in ROM.
; Figure out where that is.
;
	mov	ax,offset _Cend_+15
	mov	cl,4
	shr	ax,cl
	add	ax,seg _Cend_
	mov	ds,ax		;place where data is in rom
	mov	bx,dataseg	;place where data is to go in ram
	mov	es,bx
;
; Set up SS & SP
; Note: For hardware reasons the instruction which loads SS should
; be immediatly followed by the load of SP.
;
	mov	ss,bx
	mov	sp,offset cstack+stacksize shl 4
;
; Copy initialized data from rom to ram
;
	mov	di,0
	mov	cx,offset _Dend_
	inc	cx
	shr	cx,1
	jcxz	nocopy
	mov	si,0
rep	movsw
nocopy:
;
; Clear uninitialized data area
;
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
	mov	_dsval_,ds
	mov	_csval_,cs		;this is of dubious value in large code
;
; Set up pointers to heap space
;
	mov	di,offset _Uend_
	inc	di
	and	di,0fffeH	;adjust to word boundary
	mov	_mcur_,di	;save memory allocation info for sbrk()
	mov	_mbot_,di
	add	di,heapsize shl 4
	mov	_mtop_,di
	mov	_sbot_,offset cstack
;
; Initialize floating point software/hardware
;
	sti
	call	$fltinit	;setup floating point software/hardware
	jnc	flt_ok
	hlt			;program needs 8087 and one wasn't found
flt_ok:
;
; Call main()
;
	jmp	main_		;main shouldn't return in ROM based system
$begin	endp
codeseg	ends
	end	$begin
