EXTRN LibMain:FAR
EXTRN LocalInit:FAR
EXTRN SYSTEMP_EXITPROC:DWORD
EXTRN SYSTEMP_EXITCODE:BYTE
EXTRN SYSTEMP_HINSTANCE:WORD

PUBLIC WEP
PUBLIC LibEntry

LIBENTRY_TEXT SEGMENT BYTE 'CODE' PUBLIC
LIBENTRY_TEXT ENDS

far_data segment 'far_data' public
far_data ends

NULL SEGMENT WORD 'BEGDATA' PUBLIC
NULL ENDS

data segment 'data' public
data ends

_BSS SEGMENT WORD 'BSS' PUBLIC
_BSS ENDS

far_bss segment 'far_bss' public
far_bss ends

DGROUP GROUP NULL, _BSS

NULL SEGMENT
    DB  16 DUP (0)
NULL ENDS

_BSS SEGMENT
_BSS ENDS

ASSUME CS:LIBENTRY_TEXT, DS:DGROUP

LIBENTRY_TEXT SEGMENT

LibEntry PROC FAR
	push	si
	push	di
	
	mov	SYSTEMP_HINSTANCE, di

	mov	si, cx			; save the heap size
	jcxz	NoHeap	
	
	xor	ax, ax
	push	ds
	push	ax
	push	cx
	CALL	LocalInit
	or	ax, ax
	jz	Exit

NoHeap:	
	push	di			; instance handle
	CALL	LibMain			; call users init routine
	mov	ah, 0
	mov	al, SYSTEMP_EXITCODE
Exit:
	pop	di
	pop	si
	RET				; and return what he did
	
LibEntry ENDP

WEP PROC FAR
	push	ds
	pop	ax
	nop
	push	bp
	mov	bp, sp
	push	ds
	mov	ds, ax
	
	push	si
	push	di
	
	mov	al, [bp+6]
	mov	SYSTEMP_EXITCODE, al
ExitLoop:
	LES     BX, DWORD PTR SYSTEMP_EXITPROC
	MOV     AX, ES
	OR      AX, BX
	JZ      EXITDONE
	PUSH    CS
	MOV     AX, OFFSET EXITLOOP
	PUSH    AX
	XOR     AX, AX
	XCHG    AX, WORD PTR [SYSTEMP_EXITPROC+2]
	PUSH    AX
	XOR     AX, AX
	XCHG    AX, WORD PTR [SYSTEMP_EXITPROC]
	PUSH    AX
	RETF    ;This is not a return it calls user exit code proc}

EXITDONE:	
	mov	ax, 1
	
	pop	di
	pop	si

	pop	ds
	pop	bp
	ret	2
WEP ENDP

LIBENTRY_TEXT ENDS

END LibEntry
