; Copyright (C) 1984, 1985 by Manx Software Systems
; :ts=8
	include lmacros.h
;
; stacksize & heapsize define the number of paragraphs in the stack
; and heap areas.
;
stacksize equ	80h		;# paragraphs in stack area
heapsize  equ	80h		;# paragraphs in heap area
;
dataseg	segment	word public 'data'
	global	errno_:word,2
	global	_dsval_:word,2
	global	_csval_:word,2
	global	_mbot_:word,4	;ptr to base of heap area
	global	_mcur_:word,4	;ptr to heap 'high water' mark
	global	_mtop_:word,4	;ptr to top of heap area
;
; _lowwater is used by csav and cret only.  Therefore if you do not 
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
	mov	ax,offset _Uend_ ; stack starts at Uend
	add	ax,15		; round up to next paragraph
	mov	cl,4		; and convert to paragraph form
	shr	ax,cl
	and	ax,0fffh
	mov	dx,es		; add in datasegment base paragraph
	add	ax,dx
	mov	ss,ax
	mov	sp,stacksize shl 4
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
; Clear the uninitialized data area
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
; Set up DS to data segment
;
	assume	ds:dataseg,es:dataseg
	mov	ax,es			; now DS and ES point to data segment
	mov	ds,ax
	mov	_dsval_,bx	;save pointer to bottom of data segment
	mov	_csval_,cs	;save pointer to bottom of code segment
;
; Set up pointers to heap space
;
	mov	ax,stacksize
	mov	ax,ss		;add in stack area base
	mov	_mbot_+2,ax	;set up pointer to bottom of heap area
	mov	_mcur_+2,ax	;set up pointer to bottom of heap area
	add	ax,heapsize	;add in heap size
	mov	_mtop_+2,ax	;set up pointer to top of heap area
;
; Initialize floating point hardware/software
;
	sti
	call	$fltinit	;setup floating point software/hardware
	jnc	flt_ok
	hlt			;program needs 8087 and one wasn't found
flt_ok:
;
; Go to main()
;
	jmp	main_		;main shouldn't return in ROM based system
$begin	endp
codeseg	ends
	end	$begin
