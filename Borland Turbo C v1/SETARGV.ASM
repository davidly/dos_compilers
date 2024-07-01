	NAME	setargv
	PAGE	60,132
;[]------------------------------------------------------------[]
;|	SETARGV.ASM -- Parse Command Line			|
;|								|
;|	Turbo-C Run Time Library	version 1.0		|
;|								|
;|	Copyright (c) 1987 by Borland International Inc.	|
;|	All Rights Reserved.					|
;[]------------------------------------------------------------[]

	INCLUDE RULES.ASI

;	Segment and Group declarations

Header@

;	External references

ExtSym@		__argc, WORD, __CDECL__
dPtrExt@	__argv, __CDECL__
ExtSym@		_psp, WORD, __CDECL__
ExtSym@		_envseg, WORD, __CDECL__
ExtSym@		_envLng, WORD, __CDECL__
ExtSym@		_osmajor, BYTE, __CDECL__
ExtProc@	abort, __CDECL__

	SUBTTL	Parse Command Line
	PAGE
;/*							*/
;/*-----------------------------------------------------*/
;/*							*/
;/*	Parse Command Line				*/
;/*	------------------				*/
;/*							*/
;/*-----------------------------------------------------*/
;/*							*/
PSPCmd		equ	00080h


CSeg@

IF	LPROG
SavedReturn	dd	?
ELSE
SavedReturn	dw	?
ENDIF
SavedDS		dw	?
SavedBP		dw	?

PubProc@	_setargv, __CDECL__

;	First, save caller context and Return Address

		pop	word ptr SavedReturn
IF	LPROG
		pop	word ptr SavedReturn+2
ENDIF
		mov	SavedDS, ds

;	Then, Process command line

		cld
		mov	es, _psp@
		mov	si, PSPCmd	; ES: SI = Command Line address
		xor	ax, ax
		mov	bx, ax
		mov	dx, ax		; AX = BX = CX = DX = 0
		mov	cx, ax		; AX = BX = CX = DX = 0
		lods	byte ptr es:[si]
		mov	di, si
		xchg	ax, bx
		mov	es:[di+bx], al	; Append a \0 at the end
		inc	bx
		xchg	bx, cx		; CX = Command Line size including \0
Processing	label	near
		call	NextChar
		ja	NotQuote	; Not a quote and there are more
InString	label	near
		jb	GetArg0Lgth	; Command line is empty now
		call	NextChar
		ja	InString	; Not a quote and there are more
NotQuote	label	near
		cmp	al, ' '
		je	EndArgument	; Space is an argument separator
		cmp	al, 9
		jne	Processing	; TAB	is an argument separator
EndArgument	label	near
		xor	al, al		; Space and TAB are argument separators
		jmp	short Processing

;	Character test function used in SetArgs
;		On entry AL holds the previous character
;		On exit	 AL holds the next character
;			 ZF on if the next character is quote (") and AL = 0
;			 CF on if end of command line and AL = 0

NextChar	PROC	NEAR
		or	ax, ax
		jz	NextChar0
		inc	dx		; DX = Actual length of CmdLine
		stosb
		or	al, al
		jnz	NextChar0
		inc	bx		; BX = Number of parameters
NextChar0	label	near
		xchg	ah, al
		xor	al, al
		stc
		jcxz	NextChar2	; End of command line --> CF ON
		lods	byte ptr es:[si]
		dec	cx
		sub	al, '"'
		jz	NextChar2	; Quote found --> AL = 0 and ZF ON
		add	al, '"'
		cmp	al,'\'
		jne	NextChar1	; It is not a \
		cmp	byte ptr es:[si], '"'
		jne	NextChar1	; Only " is transparent after \
		lods	byte ptr es:[si]
		dec	cx
NextChar1	label	near
		or	si, si		; Be sure both CF & ZF are OFF
NextChar2	label	near
		ret
NextChar	ENDP

;	Invalid program name

BadProgName	label	near
		jmp	abort@

;	Now, Compute Argv[0] length

GetArg0Lgth	label	near
		mov	bp, es		; BP = Program Segment Prefix address
		mov	si, _envLng@
		add	si, 2		; SI = Program name offset
		mov	cx, 1		; CX = Filename size (includes \0)
		cmp	_osmajor@, 3
		jb	NoProgramName
		mov	es, _envseg@
		mov	di, si		; SI = argv[0] address
		mov	cl, 07fh
	repnz	scasb
		jcxz	BadProgName
		xor	cl, 07fh	; CX = Filename size (includes \0)
NoProgramName	label	near

;	Now, reserve space for the arguments

ReserveSpace	label	near
		inc	bx		; argv[0] = PgmName
		mov	__argc@, bx
		inc	bx		; argv ends with NULL
		mov	ax, cx		; Size = PgmNameLgth +
		add	ax, dx		;	 CmdLineLgth +
		add	bx, bx		;	 argc * 2	(LDATA = 0)
IF	LDATA
		add	bx, bx		;	 argc * 4	(LDATA = 1)
ENDIF
		add	ax, 1
		and	ax, not 1	; Keep stack word aligned
		add	bx, ax
		mov	di, sp
		sub	di, ax		; SS:DI = DestAddr for PgmName
		sub	sp, bx		; SS:SP = &argv[0]
		xchg	bx, bp		; BX = Program Segment Prefix address
		mov	bp, sp		; BP = &argv[0]
		mov	word ptr __argv@, sp
IF	LDATA
		mov	word ptr __argv@+2, ss
ENDIF
		mov	ax, ss
		mov	es, ax		; ES:DI = Argument's area

;	Copy program name

CopyArg0	label	near
		mov	[bp], di	; Set argv[n]
IF	LDATA
		mov	[bp+2], es
		add	bp, 4
ELSE
		add	bp, 2
ENDIF
		mov	ds, _envseg@
		dec	cx
	rep	movsb
		xor	al, al
		stosb

;	Copy the command line

		mov	ds, bx
		xchg	cx, dx		; CX	 = Command Line size
		mov	si, PSPCmd + 1	; DS: SI = Command Line address
CopyArgs	label	near
		jcxz	SetLastArg
		mov	[bp], di	; Set argv[n]
IF	LDATA
		mov	[bp+2], es
		add	bp, 4
ELSE
		add	bp, 2
ENDIF
CopyArg		label	near
		lodsb
		or	al, al
		stosb
		loopnz	CopyArg
		jz	CopyArgs
SetLastArg	label	near
		xor	ax, ax
		mov	[bp], ax
IF	LDATA
		mov	[bp+2], ax
ENDIF

;	Restore caller context and exit

		mov	ds, SavedDS
IF	LPROG
		jmp	dword ptr SavedReturn
ELSE
		jmp	word ptr SavedReturn
ENDIF
EndProc@	_setargv, __CDECL__
CSegEnd@
	END
