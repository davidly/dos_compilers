	NAME	c0
	PAGE	60,132
;[]------------------------------------------------------------[]
;|	C0.ASM -- Start Up Code					|
;|								|
;|	Turbo-C Run Time Library	version 1.0		|
;|								|
;|	Copyright (c) 1987 by Borland International Inc.	|
;|	All Rights Reserved.					|
;[]------------------------------------------------------------[]

	INCLUDE RULES.ASI

;	Segment and Group declarations

_TEXT	SEGMENT BYTE PUBLIC 'CODE'
_TEXT	ENDS
_DATA	SEGMENT PARA PUBLIC 'DATA'
_DATA	ENDS
_EMUSEG SEGMENT WORD PUBLIC 'DATA'
_EMUSEG ENDS
_CVTSEG SEGMENT WORD PUBLIC 'DATA'
_CVTSEG ENDS
_SCNSEG SEGMENT WORD PUBLIC 'DATA'
_SCNSEG ENDS
_BSS	SEGMENT WORD PUBLIC 'BSS'
_BSS	ENDS
_BSSEND SEGMENT BYTE PUBLIC 'BSSEND'
_BSSEND ENDS
IFNDEF __TINY__
_STACK	SEGMENT STACK 'STACK'
_STACK	ENDS
ENDIF

IF	LDATA
DGROUP	GROUP	_DATA, _EMUSEG, _CVTSEG, _SCNSEG, _BSS, _BSSEND
ELSE
IFNDEF	__TINY__
DGROUP	GROUP	_DATA, _EMUSEG, _CVTSEG, _SCNSEG, _BSS, _BSSEND, _STACK
ELSE
DGROUP	GROUP	_TEXT, _DATA, _EMUSEG, _CVTSEG, _SCNSEG, _BSS, _BSSEND
ENDIF
ENDIF
	ASSUME	CS:_TEXT, DS:DGROUP

;	External References

ExtProc@	main,	__CDECL__
ExtProc@	_setargv, __CDECL__
ExtProc@	_setenvp, __CDECL__
ExtProc@	exit,	__CDECL__

ExtSym@ _stklen, WORD,	__CDECL__
ExtSym@ _emufak, ABS,	__CDECL__

	SUBTTL	Start Up Code
	PAGE
;/*							*/
;/*-----------------------------------------------------*/
;/*							*/
;/*	Start Up Code					*/
;/*	-------------					*/
;/*							*/
;/*-----------------------------------------------------*/
;/*							*/
PSPHigh		equ	00002h
PSPEnv		equ	0002ch
PSPCmd		equ	00080h
MINSTACK	equ	128
;
;	At the start, DS and ES both point to the segment prefix.
;	SS points to the stack segment except in TINY model where
;	SS is equal to CS
;
_TEXT	SEGMENT
IFDEF	__TINY__
	ORG	100h
ENDIF
STARTX		PROC	NEAR

;	Sometimes the compiler needs to load the DS register with the
;	DGROUP value. In TINY model the DGROUP symbol cannot appear,
;	otherwise it becomes impossible to EXE2BIN the .EXE file. For this
;	reason, the DGROUP is saved in a variable of the code segment.

IFDEF	__TINY__
		mov	dx, cs		; DX = GROUP Segment address
ELSE
		mov	dx, DGROUP	; DX = GROUP Segment address
ENDIF
		mov	cs:DGROUP@@, dx

;	Save general information, such as :
;		DOS version number
;		Program Segment Prefix
;		Environment address
;		Top of far heap

		mov	ah, 30h
		int	21h
		mov	bp, ds:[PSPHigh]; BP = Highest Memory Segment Addr
		mov	bx, ds:[PSPEnv] ; BX = Environment Segment address
		mov	ds, dx
		mov	_version@, ax	; Keep major and minor version number
		mov	_psp@, es	; Keep Program Segment Prefix address
		mov	_envseg@, bx	; Keep Environment Segment address
		mov	word ptr _heaptop@ + 2, bp
		mov	_8087@, -1

;	Look for a '87' environment variable, and use this loop to
;	count the number of environment variables and to compute the
;	environment size.
;	Each variable is ended by a 0 and a zero-length variable stops
;	the environment. The environment can NOT be greater than 32k.

		mov	es, bx
		xor	ax, ax
		mov	cx, 07FFFh	; Environment cannot be > 32 Kbytes
		mov	di, ax
		mov	bx, ax
IsIt87Var	label	near
		cmp	word ptr es:[di], '78'
		jne	GetEnvLng
		mov	dx, es:[di+2]
		cmp	dl, '='
		jne	GetEnvLng
		and	dh, not ' '
		inc	_8087@
		cmp	dh, 'Y'
		jne	GetEnvLng
		inc	_8087@
GetEnvLng	label	near
	repnz	scasb
		jcxz	InitFailed	; Bad environment !!!
		inc	bx		; BX = Nb environment variables
		cmp	es:[di], al
		jne	IsIt87Var	; Next variable ...
		or	ch, 10000000b
		neg	cx
		mov	_envLng@, cx	 ; Save Environment size
		add	bx, 7
		and	bx, not 3
		shl	bx, 1
IF	LDATA
		shl	bx, 1
ENDIF
		mov	_envSize@, bx	; Save Environment Variables Nb.

;	Capture "Divide overflow" interrupt

		push	ds
		mov	ax, 03500h
		int	021h
		mov	word ptr ZeroDivVector, bx
		mov	word ptr ZeroDivVector+2, es
		mov	ax, 02500h
		push	cs
		pop	ds
		mov	dx, offset ZeroDivision
		int	021h
		pop	ds

;	Install floating point software

IFNDEF	__NOFLOAT
		push	cs
		call	word ptr ds:[__emu1st]
ENDIF

;	Adjust _stklen if necessary


IFDEF	__HUGE__
		mov	di, seg _stklen@
		mov	es, di
		mov	di, es:_stklen@
ELSE
		mov	di, _stklen@
ENDIF
		mov	bx, MINSTACK * 2
		cmp	di, bx
		ja	_stklenOk
		mov	di, bx
_stklenOk	label	near

;	Determine the amount of memory that we need to keep

IF	LDATA
		mov	dx, ss
		mov	cl, 4
		shr	di, cl		; $$$ Do not destroy CL $$$
		inc	di		; DI = Stack size in paragraphs
ELSE
		mov	dx, ds
		add	bx, offset DGROUP: edata@
		jb	InitFailed	; STACK could not be > 64 Kbytes
		mov	di, 1000h	; DI = Stack size in paragraphs
		mov	cl, 4
ENDIF
		shr	bx, cl		; $$$ Do not destroy CL $$$
		inc	bx		; MINIMUM needed
		sub	bp, dx
		cmp	bp, di
		ja	ExcessOfMemory	; Much more available than needed
		xchg	bx, di
		cmp	bp, di
		ja	ExcessOfMemory	; Enough to run the program

;	All initialization errors arrive here

InitFailed	label	near
		jmp	near ptr abort@

;	Return to DOS the amount of memory in excess
;	Set far heap base and pointer

ExcessOfMemory	label	near
		mov	bx, di
		add	bx, dx
		mov	word ptr _heapbase@ + 2, bx
		mov	word ptr _brklvl@ + 2, bx
		mov	ax, _psp@
		sub	bx, ax		; BX = Number of paragraphs to keep
		mov	es, ax		; ES = Program Segment Prefix address
		mov	ah, 04Ah
		int	021h

;	Set the program stack

		shl	di, cl		; $$$ CX is still equal to 4 $$$
IF	LDATA EQ false
		mov	ss, dx
ENDIF
		mov	sp, di

;	Prepare main arguments

		call	_setargv@
		call	_setenvp@

IFNDEF	__HUGE__

;	Reset un-initialized datas

		xor	ax, ax
		mov	es, cs:DGROUP@@
		mov	di, offset DGROUP: bdata@
		mov	cx, offset DGROUP: edata@
		sub	cx, di
	rep	stosb
ENDIF

;	ExitCode = main(argc,argv,envp);

IF	LDATA
		push	word ptr environ@+2
		push	word ptr environ@
		push	word ptr __argv@+2
		push	word ptr __argv@
ELSE
		push	word ptr environ@
		push	word ptr __argv@
ENDIF
		push	__argc@
		call	main@

;	Flush and close streams and files

		push	ax
		call	exit@

;	Restore "Divide overflow" interrupt vector

PubProc@	_exit,	__CDECL__
		mov	ax, 2500h
		lds	dx, ZeroDivVector
		int	021h

;	Set DS to DGROUP

		mov	ds, cs:DGROUP@@

;	Restore interrupt vectors taken by __emu1st

IFNDEF	__NOFLOAT
		push	cs		;Simulation of a FAR call
		call	word ptr ds:[__emuLast]
ENDIF

IF	LDATA EQ false
IFNDEF	__TINY__

;	Check for null pointers before exit

		xor	ax, ax
		mov	si, ax
		mov	cx, lgth_CopyRight
		cld
ComputeChecksum label	near
		add	al, [si]
		adc	ah, 0
		inc	si
		loop	ComputeChecksum
		sub	ax, CheckSum
		jz	ExitToDOS
		mov	cx, lgth_NullCheck
		mov	dx, offset DGROUP: NullCheck
		call	ErrorDisplay
ENDIF
ENDIF

;	Exit to DOS

ExitToDOS	label	near
		mov	bp,sp
IF	LPROG
		mov	al,[bp+4]
ELSE
		mov	al,[bp+2]
ENDIF
		mov	ah,4Ch
		int	21h			; Exit to DOS
EndProc@	_exit, __CDECL__
STARTX		ENDP

	SUBTTL	Miscellaneous
	PAGE
;[]------------------------------------------------------------[]
;|								|
;|	Miscellaneous functions					|
;|								|
;[]------------------------------------------------------------[]

ErrorDisplay	PROC	NEAR
		mov	ah, 040h
		mov	bx, 2
		mov	ds, cs: DGROUP@@
		int	021h
		ret
ErrorDisplay	ENDP

PubProc@	abort,	__CDECL__
		mov	cx, lgth_abortMSG
		mov	dx, offset DGROUP: abortMSG
		call	ErrorDisplay
CallExit3	label	near
		mov	ax, 3
		push	ax
		call	_exit@		; _exit(3);
EndProc@	abort, __CDECL__

ZeroDivision	PROC	FAR
		mov	cx, lgth_ZeroDivMSG
		mov	dx, offset DGROUP: ZeroDivMSG
		call	ErrorDisplay
		jmp	short CallExit3
ZeroDivision	ENDP

;	The DGROUP@ variable is used to reaload DS with DGROUP

PubSym@ DGROUP@, <dw	?>, __PASCAL__
_TEXT	ENDS

	SUBTTL	Start Up Datas
	PAGE
;/*							*/
;/*-----------------------------------------------------*/
;/*							*/
;/*	Start Up Data					*/
;/*	--------------					*/
;/*							*/
;/*-----------------------------------------------------*/
;/*							*/
_DATA	SEGMENT

;	The CopyRight string must NOT be moved or changed without
;	changing the null pointer check logic

CopyRight	db	4 dup(0)
		db	'Turbo-C - Copyright (c) 1987 Borland Intl.',0
lgth_CopyRight	equ	$ - CopyRight

IF	LDATA EQ false
IFNDEF	__TINY__
Checksum	equ	00D36h
nullCheck	db	'Null pointer assignment', 13, 10
lgth_nullCheck	equ	$ - nullCheck
ENDIF
ENDIF

ZeroDivMSG	db	'Divide error', 13, 10
lgth_ZeroDivMSG equ	$ - ZeroDivMSG

abortMSG	db	'Abnormal program termination', 13, 10
lgth_abortMSG	equ	$ - abortMSG

;	Miscellaneous variables

ZeroDivVector	dd	0
PubSym@		__argc,		<dw	0>,	__CDECL__
dPtrPub@	__argv,		0,		__CDECL__
dPtrPub@	environ,	0,		__CDECL__
PubSym@		_envLng,	<dw	0>,	__CDECL__
PubSym@		_envseg,	<dw    0>,	__CDECL__
PubSym@		_envSize,	<dw    0>,	__CDECL__
PubSym@		_psp,		<dw    0>,	__CDECL__
PubSym@		_version,	<label word>,	__CDECL__
PubSym@		_osmajor,	<db    0>,	__CDECL__
PubSym@		_osminor,	<db    0>,	__CDECL__
PubSym@		errno,		<dw    0>,	__CDECL__
PubSym@		_8087,		<dw    0>,	__CDECL__

;	Memory management variables

IF	LDATA EQ false
dPtrPub@	__brklvl,	DGROUP:edata@,	__CDECL__
ENDIF
PubSym@		_heapbase,	<dd   0>,	__CDECL__
PubSym@		_brklvl,	<dd   0>,	__CDECL__
PubSym@		_heaptop,	<dd   0>,	__CDECL__
_DATA	ENDS

_EMUSEG SEGMENT
__emu1st	label	word
__emuLast	equ	__emu1st + 2
_EMUSEG ENDS

_CVTSEG SEGMENT
PubSym@ _RealCvtVector, <label	word>,	__CDECL__
_CVTSEG ENDS

_SCNSEG SEGMENT
PubSym@ _ScanTodVector,	 <label word>,	__CDECL__
_SCNSEG ENDS

_BSS	SEGMENT
bdata@	label	byte
_BSS	ENDS

_BSSEND SEGMENT
edata@	label	byte
_BSSEND ENDS

IFNDEF	__TINY__
_STACK	SEGMENT
	dw	64 dup (?)
_STACK	ENDS
ENDIF
	END	STARTX

