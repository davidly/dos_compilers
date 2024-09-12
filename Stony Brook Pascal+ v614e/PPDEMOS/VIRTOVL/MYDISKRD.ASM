	TITLE	MYDISKRD - Test code for reading overlays from disk

;(MYDISKREAD can be given as a parameter to OVLSETREADFUNC in a program for
; testing overlay manager's ability to use a custom function for reading over-
; lays from disk)

MYDISKRD_TEXT	segment	byte public 'CODE'
MYDISKRD_TEXT	ends

OVLMGR_DATA	segment para public 'FAR_DATA'
	extrn	OVLFHANDLE:word
OVLMGR_DATA	ends

OMGROUP	group	OVLMGR_DATA

MYDISKRD_TEXT	segment
	assume cs:MYDISKRD_TEXT, ds:OMGROUP

	public	MYDISKREAD

;function MYDISKREAD(OvlyFilePos: Longint; LoadAddr: Pointer;
;						    NumBytes:Word): Word; far;

OvlyFilePos	equ	(dword ptr [bp+0Ch])
LoadAddr	equ	(dword ptr [bp+08h])
NumBytes	equ	(word  ptr [bp+06h])
OvlyFileRdError	equ	209	;from overlay mgr runtime error codes (same
				; code used by TP)

MYDISKREAD:	;far cause it is called via a proc variable from ReadFmOFile,
		; a local proc in OVLSTART.ASM module
	push	bp
	mov	bp,sp
	mov	ax,seg OMGROUP
	mov	ds,ax	;caller saves its own ds value, so we don't have to
	mov	bx,word ptr OVLFHANDLE
	les	dx,OvlyFilePos
	mov	cx,es
	mov	ax,4200h
	int	21h
	jc	@@ErrorOut	;error moving file pointer?
	lds	dx,LoadAddr
	mov	cx,NumBytes
	mov	ah,3Fh
	int	21h
	jc	@@ErrorOut	;error reading overlay file?
	cmp	ax,cx		;did we read enough?
	jc	@@ErrorOut
@@GoodOut:
	xor	ax,ax		;no error
@@Out:
	pop	bp
	retf	000Ah

@@ErrorOut:
	mov	ax,OvlyFileRdError	;overlay file read error
	jmp	short @@Out

MYDISKRD_TEXT	ends

	end
