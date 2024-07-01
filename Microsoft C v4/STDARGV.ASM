	title	stdargv - standard _setargv routine

;--------------------------------------------------------------------------
;
;	Microsoft C Compiler Runtime for MS-DOS
;
;	(C)Copyright Microsoft Corporation, 1984, 1986
;
;--------------------------------------------------------------------------


?DF =	1		; tell cmacros.inc we want to define our own segments

include version.inc
.xlist
include cmacros.inc
include msdos.inc
include brkctl.inc
.list

createSeg	_TEXT,	code,	byte,	public, CODE,	<>
createSeg	_DATA,	data,	word,	public, DATA,	DGROUP

createSeg	HDR,	nhdr,	byte,	public, MSG,	DGROUP
createSeg	MSG,	nmsg,	byte,	public, MSG,	DGROUP
createSeg	PAD,	npad,	byte,	common, MSG,	DGROUP
createSeg	EPAD,	nepad,	byte,	common, MSG,	DGROUP

defGrp	DGROUP			; define DGROUP

codeOFFSET	equ	offset _TEXT:
dataOFFSET	equ	offset DGROUP:


TAB	=	9			; tab character



sBegin data
assumes ds,data
externW 	_psp			; psp segment #
externB 	_osmajor		; os major version #
externDP	__argv			; argv address
externW 	__argc			; argc
externW 	_abrktb 		; break table
externW 	_asizds 		; break table end
globalW 	__argl,0		; total length of arguments ( expanded )
staticDP	argptr,0
sEnd data


ifdef wildcard
externP _cwild				; the wildcard expander
endif



;msg used by stdargv (wild card version of _setargv)

sBegin	nmsg
assumes ds,data

	dw	8
	db	13,10,'error 2008: Not enough space for arguments',13,10,0

sEnd

sBegin	code
assumes cs,code
assumes ds,data

externNP _myalloc			; allocation routine for arguments

cProc _setargv,<PUBLIC>,<>

cBegin
	mov	ax,1
	mov	[__argc],ax		; start argc at one for this tacky patch
	push	ax
	call	near ptr _wsetargv
	inc	sp
	inc	sp
	mov	ax,2
	push	ax
	call	near ptr _wsetargv
	inc	sp
	inc	sp
cEnd

cProc _wsetargv,<NEAR>,<>

	parmw pass
	localW endarg

cBegin
	push	ds			; save ds, it gets trashed

	assumes ds,data
	assumes ss,data

	cmp	pass,2
	jne	apass1
	push bp				; save bp for endarg
	mov	bp,[__argc]
	inc	bp

if sizeD
	shl	bp,1
endif
	shl	bp,1

	mov	ax,[__argl]
	add	ax,bp

; Register usage at this point:
;	ax = total # bytes needed for argument ptr table and strings
;	bp = # bytes required to store arg ptr table
	
	mov	di,8		; no space for arguments message if death.
	call _myalloc

;	bp points to arg table
;	ax is size of arg table in bytes.

	mov	word ptr [__argv],bp
	mov	word ptr [argptr],bp
if sizeD
	mov	word ptr [__argv+2],ds
	mov	word ptr [argptr+2],ds
endif
	add	ax,bp	
	pop bp			; recover bp for endarg
	push	ax		; Save pointer to string section

apass1:

;	move command line at (psp:80) to memory

	cmp	__osmajor,3
	pushf				; save flags for later if too old to get argv[0]
	mov	ds,[_psp]		; get psp segment
	mov	si,DOS_CMDLINE		; point to command line
	lodsb				; get length
	cbw				;   and convert to word
	mov endarg,ax			; store length of command line in endarg
	add endarg,si			; put last character position of si in
					; endarg to stop scan.
	popf				; recover flags for age test.
	push	ax			; save length

	jae	ageok
	pop	ax
	call	saveargptr

	jmp	tooold			; if < dos 3.0

ageok:

	mov	es,ds:[DOS_ENVP]	; envp seg addr

	xor	ax,ax			; 0
	mov	cx,ax
	not	cx			; -1
	mov	di,ax			; 0

again:
	repne	scasb			; find null
	cmp	es:[di],al		; env null?
	jne	again			;   no

	add	di,3			; to get to argv[0]
	mov	cx,ax
	not	cx			; -1

	push	di
	repne	scasb			; search for argv[0] null & get length
	pop	si			; start of argv[0]
	inc	cx			; cx=-len(argv[0])
	inc	cx			; cx=-len(argv[0])
	neg	cx			; cx=+len(argv[0])

	pop	dx			; len(argv[1]+...+argv[n])
	call	saveargptr

	mov	ax,dx
	add	ax,cx			; +len(argv[0])
	add	ax,3			; account for null,  and rounding
	and	ax,not 1		; rounded even

	cmp	pass,1			; size up the total length of all the argv's
	jne	apass2

	mov	bx,sp			; get old data pointer back
	mov	ds,ss:[bx]

	add	[__argl],ax
	mov	ds,[_psp]
	jmp	short epass1

apass2:
	mov	ds,ds:[DOS_ENVP]
	rep	movsb			; move argv[0]
	xor al,al			; space & null following argv[0]
	stosb
	mov	cx,dx			; len(argv[1]+...+argv[n])
	call	recoverds
	mov	ds,[_psp]
	mov	bx,ax

epass1:

	mov	si,DOS_CMDLINE+1	; restore si for command line move
	jmp	short nextarg

tooold:
	cmp	pass,1
	jne	bpass2
	mov	cx,ax			; save length
	add	al,4			; pad for 'C ', term and rounding
	and	al,not 1		; round even
	mov	bx,sp			; get old data pointer back
	mov	ds,ss:[bx]
	mov	es,ss:[bx]

	add	[__argl],ax		; increment length of the string section
	mov	ds,[_psp]		; recover psp segment
	jmp	short nextarg
bpass2:

	mov	ax,'C'shl 8 + ' '
	stosw
	xor	ax,ax
	stosb

;	crack command line arguments onto stack

nextarg:
	xor	cx,cx
	lodsb				; get next char
	cmp si,endarg		; check for eoln
	jbe cont			; eoln not found
	jmp	endline			; eoln found

cont:
	call	iswhite 		; is it white space
	jz	nextarg 		;   yes - keep skipping
	dec	si			; point to 1st character
ifdef wildcard
	mov	dx,si			; save beginning of arg for wildcard
endif

	cmp	pass,2			; put entry in argv array
	jne	gpass1

	mov	es:[bx],di		; argv entry is es:di
	add	bx,2
if sizeD
	mov	es:[bx],es
	add	bx,2
endif
	jmp	short notspace

gpass1:
	call	recoverds
	inc	[__argc]		; bump arg count
	mov	ds,[_psp]		; and ds back again
	mov	bx,ax

notspace:
	lodsb				; get next char

ifdef wildcard
	call	iswild
endif

	call	isquote

	cmp	pass,2
	jne	hpass1
	stosb
hpass1:
	cmp si,endarg		; check for end of line
	ja	eoln			;   yes
	call	iswhite 		; is it white space
	jnz	notspace		;   no - keep skipping
eoln:

	cmp	pass,2
	jne	ipass1
	mov	byte ptr es:[di-1],0   ; zero terminate arg
ipass1:

ifdef wildcard
	cmp	cx,100h 	       ; only valid wildcard expansion
	jne	nowild
	call	recoverds
	mov	bx,ax

	push	ds:[_psp]		; pass [_psp]:si
	push	dx

	push	pass			; pass pass number

if sizeD
	push	ds			; pass char for argv
	sub	bx,4
else
	sub	bx,2
endif
	mov	word ptr [argptr],bx
	push	bx			; ignored for pass 1

	call	_cwild			; wildcard expander

if sizeD				; Clean up stack
	add	sp,10
	mov	es,dx
else
	add	sp,8
endif

	mov	bx,sp			; get old data pointer back
	mov	es,ss:[bx]
	mov	bx,ax			; get next available argument vect.
	mov	di,es:[bx]		; get next available string section
	mov	ds,[_psp]

nowild:
endif
	jmp	nextarg

endline:
	cmp	pass,2
	jne	zpass1
	mov	byte ptr es:[di-1],0	; zero terminate arg
if sizeD				; end argv array with a null
	mov	word ptr es:[bx+2],0000
endif
	mov	word ptr es:[bx],0000
zpass1:
	pop	ds

cEnd

ifdef wildcard
iswild:
	cmp	al,'*'			; is it a star
	je	iswldret			;   yes - exit

	cmp	al,'?'			; is it a question mark
	jne	wldret

iswldret:
	mov	ch,1

wldret:
	ret				; return
endif

iswhite:
	cmp	al,TAB			; is it a TAB
	je	iswret			;   yes - exit

	cmp	al,' '			; is it a space

iswret:
	ret				; return

isquote:
	cmp	al, '\'                 ; is this a backslash
	jne	normquote
	cmp	byte ptr ds:[si],'"'	; check for \" must do this this way to avoid
	jne	normquote		; a first char quote with the byte before it
ifdef wildcard
	mov	cl,1			; disable wildcard
endif
	lodsb				; just happening to be a backslash.
	jmp	short isqret

normquote:
	cmp	al, '"' 		; is it a quote
	jne	isqret

ifdef wildcard
	mov	cl,1			; disable wildcard
endif

notquote:
	lodsb				; get next char
	cmp	al,13			; check for eol
	je	isqret			;   yes - early termination

	cmp	al,'"'			; ending quote
	jne	storeb			;   no - keep scanning

	cmp	byte ptr ds:[si-2],'\'  ; check for \"

	jne	endquote			;   yes
	dec	di

storeb:
	cmp	pass,2
	jne	kpass1
	stosb				; stuff char
kpass1:
	jmp	short notquote

endquote:
	lodsb
	jmp	short isquote		;   done with quotes


isqret:
	ret				; return

saveargptr:
	cmp	pass,2
	jne	vpass1
	mov	bx,sp			; get old data pointer back
	add	bx,4
	mov	ds,ss:[bx]
	pop	es			; save return address
	pop	di
	push	es			; recover return address
	mov	es,ss:[bx]
	mov	bx,word ptr [argptr]
	mov	[bx],di
	add	bx,2

if sizeD
	mov	[bx],ds
	add	bx,2
endif

	mov	ds,[_psp]		; restore ds to _psp
vpass1:
	ret

recoverds:
	mov	ax,bx
	mov	bx,sp			; get old data pointer back
	mov	ds,ss:[bx+2]
	ret

sEnd	code
	end
