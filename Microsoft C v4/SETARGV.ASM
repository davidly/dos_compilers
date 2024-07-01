	title	stdargv - standard _setargv routine

;--------------------------------------------------------------------------
;
;	Microsoft C Compiler Runtime for MS-DOS
;
;	(C)Copyright Microsoft Corporation, 1984,1985,1986
;
;--------------------------------------------------------------------------

include version.inc
.xlist
include cmacros.inc
include msdos.inc
.list



TAB	=	9			; tab character


sBegin	data

	assumes ds,data

externW 	_psp			; psp segment #
externDP	__argv			; argv address
externW 	__argc			; argc
externB 	_osmajor		; os major version #

staticCP	retadr,0		; return address

sEnd	data


sBegin	code

	assumes ds,data
	assumes cs,code


labelP	<PUBLIC,_setargv>

	pop	word ptr [retadr]	; get return address

if sizeC
	pop	word ptr [retadr+2]	; seg part of return address
endif

	mov	ds,[_psp]		; get psp segment
	push	ss			; ss = ds assumption
	pop	es

	assumes ds,nothing
	assumes es,data

;	move command line at (psp:80) to stack

	mov	si,DOS_CMDLINE		; point to command line
	lodsb				; get length
	cbw				;   and convert to word
	;xor	 dx,dx			 ; argv[0] valid? initially no
	cmp	__osmajor,3
	jb	tooold			; if < dos 3.0

	push	ax			; save length
	mov	es,ds:[DOS_ENVP]	; envp seg addr

	assumes es,nothing

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

	push	di			; start of argv[0]
	repne	scasb			; search for argv[0] null & get length
	pop	si			; start of argv[0]
	add	cx,2			; cx=-len(argv[0])
	neg	cx			; cx=+len(argv[0])

	;inc	 dx			 ; valid argv[0]
	pop	bx			; len(argv[1]+...+argv[n])
	mov	ax,bx
	add	ax,cx			; +len(argv[0])
	add	ax,3			; space, null, rounding
	and	ax,not 1		; rounded even
	sub	sp,ax			; allocate space on stack
	mov	di,sp			; di=destination
	push	ds			; save psp
	push	es
	pop	ds			; ds=env seg
	push	ss
	pop	es			; es=stack seg

	assumes es,data

	rep	movsb			; move argv[0]
	mov	al,' '			; space following argv[0]
	stosb
	mov	cx,bx			; len(argv[1]+...+argv[n])
	pop	ds			; psp seg
	mov	si,DOS_CMDLINE+1	; restore si for command line move
	jmp	short moveit

tooold:
	mov	cx,ax			; save length
	add	al,4			; pad for 'C ', term and rounding
	and	al,not 1		; round even
	sub	sp,ax			; allocate space on stack
	mov	di,sp			; di = destination
	mov	ax,'C' + ' ' shl 8
	stosw				; stuff 'C '

moveit:
	rep	movsb			; move command line
	mov	ax,cx			; ax=0
	stosb				; stuff terminating 00
	mov	si,sp			; save command line ptr
	push	ss
	pop	ds

	assumes ds,data

;	crack command line arguments onto stack

	push	ax			; terminating NULL

if sizeD
	push	ax			; seg part for long model
endif

	mov	bx,sp			; remember top of argv (reversed)

nextarg:
	mov	di,si			; resync argument
	lodsb				; get next char
	or	al,al			; check for end of line
	je	endline 		;   yes


	call	iswhite 		; is it white space
	jz	nextarg 		;   yes - keep skipping

	dec	si			; point to 1st character

if sizeD
	push	ds
endif

	push	si			; argv entry is ds:si
	inc	[__argc]		; bump arg count

notspace:
	lodsb				; get next char
	call	isquote
	stosb
	or	al,al			; check for end of line
	je	endline 		;   yes

	call	iswhite 		; is it white space
	jnz	notspace		;   no - keep skipping

	mov	byte ptr [di-1],0	; zero terminate arg
	jmp	short nextarg

endstoreb:
	stosb				; save null terminator

endline:
	mov	si,sp			; si = last arg (reversed)

revloop:

if sizeD
	sub	bx,4
else
	dec	bx
	dec	bx
endif

	cmp	si,bx			; half way up or more
	jae	revdone 		;   yes - return

	lodsw
	xchg	[bx],ax
	mov	[si-2],ax		; swap offsets

if sizeD
	lodsw
	xchg	[bx+2],ax
	mov	[si-2],ax		; swap segments
endif

	jmp	short revloop		; keep looping

revdone:
	mov	bx,sp
	;or	dx,dx			; argv[0] valid?
	;jnz	keepit			;   yes
					;   no, skip it
	;inc	word ptr [bx]		; argv[0] = null - skip past 'C'

keepit:

if sizeD
	mov	word ptr [__argv+2],ss
endif

	mov	word ptr [__argv],sp	; save argv pointer


	jmp	[retadr]		; return

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
	lodsb				; just happening to be a backslash.
	jmp	short isqret

normquote:
	cmp	al, '"' 		; is it a quote
	jne	isqret
ifdef NOEATQUOTE
	stosb
endif

notquote:
	lodsb				; get next char
	cmp	al,13			; check for eol
	je	isqret			;   yes - early termination

	cmp	al,'"'			; ending quote
	jne	storeb			;   no - keep scanning

	cmp	byte ptr ds:[si-2],'\'  ; check for \"

	jne	endquote		;   not \"
ifndef NOEATQUOTE
	dec	di
endif

storeb:
	stosb				; stuff char
	jmp	short notquote

endquote:
ifdef NOEATQUOTE
	stosb
endif
	lodsb
	jmp	short isquote		;   done with quotes

isqret:
	ret				; return


sEnd	code
	end
