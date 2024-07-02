	NAME	SETENVP
	PAGE	60,132
;[]------------------------------------------------------------[]
;|	SETENVP.ASM -- Prepare Environment			|
;|								|
;|	Turbo-C Run Time Library	version 2.0		|
;|								|
;|	Copyright (c) 1988 by Borland International Inc.	|
;|	All Rights Reserved.					|
;[]------------------------------------------------------------[]

	INCLUDE RULES.ASI

;	Segment and Group declarations

Header@

;	External references

ExtProc@	malloc, __CDECL__
ExtProc@	abort, __CDECL__

ExtSym@		_envseg, WORD, __CDECL__
ExtSym@		_envLng, WORD, __CDECL__
ExtSym@		_envSize, WORD, __CDECL__
dPtrExt@	environ, __CDECL__

	SUBTTL	Prepare Environment
	PAGE
;/*							*/
;/*-----------------------------------------------------*/
;/*							*/
;/*	Prepare Environment				*/
;/*	-------------------				*/
;/*							*/
;/*-----------------------------------------------------*/
;/*							*/

CSeg@

PubProc@	_setenvp, __CDECL__

;	Allocate a buffer to hold environment variables

IF	LDATA EQ 0
		mov	cx, _envLng@
		push	cx
		call	malloc@
		pop	cx
		mov	di, ax
		or	ax, ax
		jz	_Failed		; Memory allocation failed
		push	ds
		push	ds
		pop	es
		mov	ds, _envseg@
		xor	si, si
		cld
		rep	movsb
		pop	ds
		mov	di, ax
ELSE
		mov	es, _envseg@
		xor	di, di
ENDIF

;	Allocate a buffer to hold envp array

		push	es		; Save Environment Segment address
		push	_envSize@
		call	malloc@
		add	sp, 2
		mov	bx, ax
		pop	es		; Restore Environment Segment address
IF	LDATA
		mov	word ptr environ@, ax
		mov	word ptr environ@+2, dx
		push	ds
		mov	ds, dx
		or	ax, dx
ELSE
		mov	word ptr environ@, ax
		or	ax, ax
ENDIF
		jnz	SetEnviron	; Memory allocation failed
_Failed		label	near		; Memory allocation failed
		jmp	abort@


;	Now, store environment variables address

SetEnviron	label	near
		xor	ax, ax
		mov	cx, -1
SetEnviron0	label	near
		mov	[bx], di
IF	LDATA
		mov	[bx+2], es
		add	bx, 4
ELSE
		add	bx, 2
ENDIF
		repnz	scasb
		cmp	es:[di], al
		jne	SetEnviron0	; Set next pointer
IF	LDATA
		mov	[bx], ax
		mov	[bx+2], ax
		pop	ds
ELSE
		mov	[bx], ax
ENDIF
		ret
EndProc@	_setenvp, __CDECL__

CsegEnd@
	END
