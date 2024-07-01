;+
;	Let's C Version 4.0.C.
;	Copyright (c) 1982-1987 by Mark Williams Company, Chicago.
;	All rights reserved. May not be copied or disclosed without permission.
;-

	name	crts0xl

;+
; DOS LARGE model C runtime startoff.
;-

;+
; At compile time:
;	Declare the classes 'code', 'data', 'stack', 'memory' and 'debug'
;	in the right order so that LINK gets it right.
;	Set up a minimal stack of 2048 bytes.
;	Set up public label '_mbase_' in the memory segment
;	so C knows where the program ends.
; At run time:
;	Save the program segment prefix base address in '_pspbase_'
;	so C knows where the program begins.
;	Free all memory past the end of the program for 'malloc_()'.
;	Initialize BP to NULL for 'longjmp_()'.
;	Call '_main_()'.
;	Provide low level C callable '_exit_()'.
;-

	extrn	_main_:far
	extrn	_pspbase_:word
	extrn	__end_:word

code	segment public	'code'
code	ends

data	segment public	'data'
data	ends

stack	segment stack	'stack'
	db	2048	dup	(?)
stack	ends

memory	segment memory	'memory'
	public	_mbase_
_mbase_ label	word
memory	ends

debug	segment	byte	public	'debug'
debug	ends

code	segment public	'code'
	public	_exit_

	assume	cs:code

crts0	proc	far

	mov	ax, seg _pspbase_	; Set DS to map the
	mov	ds, ax			; _pspbase_ segment
	assume	ds:seg _pspbase_	; and tell the assembler.
	mov	_pspbase_, es		; Initialize _pspbase.

	mov	ax, seg __end_		; Set DS to map the
	mov	ds, ax			; __end segment
	assume	ds:seg __end_		; and tell the assembler.
	mov	bx, memory		; BX gets end of memory segment
	sub	ax, ax			; and AX gets offset.
	mov	__end_, ax		; Initialize __end offset
	mov	__end_+2, bx		; and segment.

	sub	bp, bp			; Clear BP for longjmp.
	call	_main_			; Call _main which calls main.
	push	ax			; Save return status,
	push	ax			; push fake far return address
	push	ax			; and fall through to _exit.

;+
; void _exit(s) int s;
;
; Low level exit.
; Return to caller with exit status in AL.
; Since CSD catches end of execution at this label,
; all program terminations should pass through _exit_.
;-

_exit_	label	far

	cld				; For DOS.
	add	sp, 4			; Discard return address and
	pop	ax			; get exit status in AL.
	mov	ah, 4Ch 		; Load return exit status function code
	int	21h			; and do it.

crts0	endp

code	ends

	end	crts0
