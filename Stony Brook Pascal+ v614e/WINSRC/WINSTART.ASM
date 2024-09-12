;***************************************************************************
;*									   *
;*			     Copyright (C) 1989				   *
;*			   by Stony Brook Software			   *
;*									   *
;*			     All rights reserved.			   *
;*									   *
;***************************************************************************

EXTRN SYSTEMP_HINSTANCE:WORD
EXTRN SYSTEMP_HPREVINST:WORD
EXTRN SYSTEMP_CMDLINE:DWORD
EXTRN SYSTEMP_CMDSHOW:WORD
EXTRN SYSTEMP_PREFIXSEG:WORD
EXTRN SYSTEMP_EXITCODE:BYTE

WINSTART_TEXT SEGMENT BYTE 'CODE' PUBLIC
WINSTART_TEXT ENDS

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

EXTRN INITTASK:FAR, WAITEVENT:FAR, INITAPP:FAR, WINMAIN:FAR, LOCALINIT:FAR
EXTRN SYSTEMP_HALT:FAR

DGROUP GROUP NULL, _BSS

ASSUME CS:WINSTART_TEXT, DS:DGROUP

NULL SEGMENT
    DB  16 DUP (0)
NULL ENDS

_BSS SEGMENT
_BSS ENDS

WINSTART_TEXT SEGMENT

PUBLIC WINSTART

WINSTART:
	XOR	BP, BP
	PUSH	BP
	
	PUSH	CX				; save heap size	

	CALL	INITTASK
	
	OR	AX, AX
	JZ	BAD_EXIT
	
	MOV	SYSTEMP_PrefixSeg, ES
	
	MOV	SYSTEMP_HINSTANCE, DI		; save the instance
	MOV	SYSTEMP_HPREVINST, SI		; and the previous instance
	MOV	WORD PTR SYSTEMP_CMDLINE, BX	; and the command line
	MOV	WORD PTR SYSTEMP_CMDLINE+2, ES	;    including segment
	MOV	SYSTEMP_CMDSHOW, DX		; and the window show command
		
	XOR	AX, AX			; push a zero
	PUSH	AX
	CALL	WAITEVENT		; do whatever this does

	PUSH	DI 			; push instance again
	CALL	INITAPP			; and this one too
	OR	AX, AX
	JZ	BAD_EXIT

	POP	CX

; Windows 3.1 programmers reference say this is not necessary	
;	JCXZ	NoHeapInit
;       PUSH	DS
;	XOR	AX, AX
;	PUSH	AX
;	PUSH	CX
;	CALL	LocalInit
;	OR	AX, AX
;	JZ	BAD_EXIT
	
;NoHeapInit:

	PUSH	SYSTEMP_HINSTANCE		; push instance
	PUSH	SYSTEMP_HPREVINST		; push prev instance
	PUSH	WORD PTR SYSTEMP_CMDLINE+2	; command line segment
	PUSH	WORD PTR SYSTEMP_CMDLINE	;   and offset
	PUSH	SYSTEMP_CMDSHOW			; push the show command
		
	CALL	WINMAIN			; now call the main program
	mov	ah, 0
	mov	al, SYSTEMP_EXITCODE
	JMP	SHORT EXIT
    
BAD_EXIT:
	MOV	AX, 0FFH
    
EXIT:
	push	ax
	CALL	SYSTEMP_HALT
    
WINSTART_TEXT ENDS

END WINSTART
