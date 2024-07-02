; Copyright (C) 1983 1984 by Manx Software Systems
; :ts=8
	include lmacros.h
codeseg	segment	para public 'code'
dataseg	segment	para public 'data'
	extrn	$MEMRY:word, errno_:word
	extrn	_mbot_:word, _mtop_:word, _sbot_:word
	extrn	_PSP_:word
	public	_dsval_,_csval_
	public	_lowwater_
_dsval_	dw	0
_csval_	dw	0
_lowwater_	dw	-1
	extrn	_HEAPSIZ_:word,_STKSIZ_:word
	extrn	_STKLOW_:word,_STKRED_:word
	extrn	_Uorg_:byte,_Uend_:byte
bad8087	db	"8087/80287 is required!",13,10,'$'
dataseg	ends

	assume	cs:codeseg,ds:dataseg,es:dataseg,ss:dataseg
ifdef FARPROC
	extrn _Croot_:far, $fltinit:far, _exit_:far, _exitinit_:far
else
	extrn _Croot_:near, $fltinit:near, _exit_:near, _exitinit_:near
endif
	public	$begin
	public	_exit_
$begin	proc	far
	mov	bp,dataseg
	test	bp,bp
	jnz	notcom
	mov	ax,253		; This CAN'T be a com file
	push	ax
	call	_exit_
notcom:
	mov	es,bp
	mov	es:_PSP_,ds
	mov	bp,offset _Uend_ ; stack starts at Uend
	add	bp,15		; round up to next paragraph
	rcr	bp,1
	mov	cl,3		; and convert to paragraph form
	shr	bp,cl
	and	bp,01fffh
	mov	dx,es		; add in datasegment base paragraph
	add	bp,dx
	mov	bx,es:_STKRED_
	shr	bx,cl		;compute (2*STKRED)/16  note: cl==3
	cmp	bx,es:_STKSIZ_	;allocate either 2*STKRED or STKSIZ
	jae	ok1
	mov	bx,es:_STKSIZ_	;whichever is bigger
ok1:
	cmp	bx,1000h	; stack can't be bigger than 64K
	jb	ok2
	mov	bx,1000h
ok2:
	mov	dx,bx
	mov	cl,4
	shl	bx,cl
	cli
	mov	ss,bp
	mov	sp,bx
	sti
;
	add	dx,bp
	inc	dx
	mov	es:$MEMRY+2,dx	; and save as bottom of heap
	mov	es:$MEMRY,0
	mov	es:_mbot_+2,dx	; and save as bottom of heap
	mov	es:_mbot_,0
;				now adjust heap size if necessary
	mov	bx,es:_HEAPSIZ_
	add	bx,es:$MEMRY+2	; add in base paragraph of heap
	mov	es:_mtop_+2,bx	; and save as top of heap
	mov	es:_mtop_,0
; stack now set up. before doing anything else, save para addr of PSP for _exit
	call	_exitinit_	
;
	mov	si,ds
	sub	bx,si		; get size of total program in paragraphs
	mov	bp,es
	mov	es,si		; point es at PSP
	mov	ah,4ah
	int	21h		; SETBLOCK to raise or lower allocation
	jnc	didheap
	mov	ax,254
	push	ax
	call	_exit_
didheap:
	mov	es,bp		; restore es to point at dataseg
;
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
	mov	si,ds
	mov	es,si
	mov	si,081h
	mov	di,080h
	mov	cl,[80h]
	sub	ch,ch
	jcxz	nomov
rep	movsb
nomov:
	sub	al,al
	stosb
	mov	ax,1
	mov	di,080h
	jmp	short mov_args
;
found_args:
	sub	ax,ax
	stosb			;zap and skip over '='
mov_args:
	push	ax		; first arg # for Croot
	push	es
	push	di		; argp argument for Croot
	mov	es,bp
	mov	ds,bp		;set DS, now DS, SS, ES are equal
	mov	_dsval_,ds
	mov	_csval_,cs
	mov	ax,_STKRED_
	mov	_sbot_,ax
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
