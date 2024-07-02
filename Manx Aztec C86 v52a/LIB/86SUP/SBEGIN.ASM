; Copyright (C) 1983 1984 by Manx Software Systems
; :ts=8
	include lmacros.h
codeseg	segment	word public 'code'
dataseg	segment	word public 'data'
	extrn	$MEMRY:word, _mbot_:word, _mtop_:word, _sbot_:word 
	extrn	_PSP_:word
	extrn	_Uorg_:byte,_Uend_:byte
	public	_dsval_,_csval_
	public	_lowwater_
_dsval_	dw	0
_csval_	dw	0
_lowwater_	dw	-1
	extrn	_STKSIZ_:word,_HEAPSIZ_:word
	extrn	_STKLOW_:word,_STKRED_:word
bad8087	db	"8087/80287 is required!",13,10,'$'
dataseg	ends

	assume	cs:codeseg,ds:dataseg,es:dataseg,ss:dataseg
ifdef FARPROC
	extrn _Croot_:far, $fltinit:far, _exit_:far, _exitinit_:far
else
	extrn _Croot_:near, $fltinit:near, _exit_:near, _exitinit_:near
endif
	public	$begin
$begin	proc	far
	mov	bp,dataseg
	test	bp,bp
	jnz	notcom
	mov	bp,ds
notcom:
	mov	bx,[2]	;get top segment
	sub	bx,bp		;compute size of Data seg
	cmp	bx,4096		;check if greater than 64K
	jbe	smallseg
	lea	bx,[bp+4096]	;end address of segment (paragraphs)
	mov	ax,es
	sub	bx,ax		;compute length of segment
	mov	ah,4aH		;SETBLOCK system call
	int	21H
	mov	bx,4096
smallseg:
	mov	es,bp
	mov	es:_PSP_,ds
	mov	cl,4
	shl	bx,cl
	cmp	es:_STKLOW_,0
	je	setstk 		;stack goes above heap
	mov	ax,es:_STKRED_	;stack goes below heap
	shl	ax,1		;allow at least twice the RED zone size
	mov	bx,es:_STKSIZ_
	shl	bx,cl		;compute requested stack size
	cmp	bx,ax		;but don't allow too little
	ja	sizeok
	mov	bx,ax
sizeok:
	add	bx, offset _Uend_
setstk:
	cli
	mov	ss,bp
	mov	sp,bx
	sti
;
	test	bx,bx
	jnz	oksav
	mov	bx,0ffffh
oksav:
	mov	es:_mtop_,bx
; stack now set up. before doing anything else, save para addr of PSP for _exit
	call	_exitinit_	
;				now adjust heap size if necessary
	cmp	es:_STKLOW_,0	; can't do it unless heap above stack
	je	heapdone
	mov	si,es:_HEAPSIZ_
	mov	ax,bx
	inc	ax
	mov	es:$MEMRY,ax	; start of heap for later
	shl	si,cl
	add	bx,si
	jnc	heapok
	mov	bx,0ffffh
heapok:
	mov	es:_mtop_,bx	; and save as _mtop_
	add	bx,15
	shr	bx,cl		; convert to paragraph form
	mov	ax,es
	add	bx,ax		; calculate paragraph address of last byte
	mov	ax,ds		; now take the paragrph form and
	sub	bx,ax		;compute length of segment
	mov	bp,es		;save ES
	mov	es,ax
	mov	ah,4aH		;SETBLOCK system call
	int	21H
	jnc	heapdone
	mov	ax,254
	push	ax
	call	_exit_
heapdone:
	mov	es,bp		;restore ES
	cld
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
	mov	es,[2cH]		;get enviroment segment
	sub	di,di
	mov	cx,7fffH
arglook:
	mov	ah,es:byte ptr [di]
	cmp	ah,'='			;look for null named env. string
	je	found_args
	test	ah,ah
	jz	no_args
repne	scasb				;look for null byte
	jz	arglook
no_args:
	mov	cl,[80H]
	sub	ch,ch
	mov	si,81H
	mov	ax,1
	jmp	short mov_args
;
found_args:
	sub	ax,ax
	stosb			;zap and skip over '='
	mov	si,di
	mov	di,es
	mov	ds,di
mov_args:
	push	ax			;first arg # for Croot
	mov	es,bp			;reload ES with our real dataseg
	mov	di,es:$MEMRY
	push	di			;argp for Croot
	jcxz	cpy_done
cpy_args:				;copy argument string to work buffer
	lodsb
	test	al,al
	jz	cpy_done
	stosb
	loop	cpy_args
cpy_done:
	sub	al,al
	stosb			;null terminate string
	mov	ds,bp		;set DS, now DS, SS, ES are equal
	inc	di
	and	di,0fffeH	;adjust to word boundary
	mov	$MEMRY,di	;save memory allocation info for sbrk()
	mov	_mbot_,di
	mov	_sbot_,offset _Uend_
	cmp	_STKLOW_,0
	jnz	nostk
	mov	_sbot_,di
nostk:
	mov	ax,_sbot_
	add	ax,_STKRED_
	mov	_sbot_,ax
	mov	_dsval_,ds
	mov	_csval_,cs
	call	$fltinit
	jc	no_8087
	call	_Croot_		;Croot(argp, first)
	xor	ax,ax
	push	ax		;Croot or caller should call _exit
	call	_exit_		;but just in case...
;
no_8087:
	mov	ah,9		;dos print message
	mov	dx,offset bad8087
	int	21h		;tell the user about it
	mov	ax,253
	push	ax
	call	_exit_

$begin	endp

retip	dw	0
retcs	dw	0

	public $dbgentry
$dbgentry proc far
	pop	cs:retip
	pop	cs:retcs	; save return address into debugger
	pop	ds		;set DS
	call	caller
	jmp	dword ptr cs:retip ; return to debugger
$dbgentry endp

caller	proc
	push	di		;CS value of local function
	push	si		;IP value call local function
	db	0cbH		;far return instruction
caller	endp

codeseg	ends
	end	$begin
