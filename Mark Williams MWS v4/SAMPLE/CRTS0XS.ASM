;+
;	Let's C Version 4.0.C.
;	Copyright (c) 1982-1987 by Mark Williams Company, Chicago.
;	All rights reserved. May not be copied or disclosed without permission.
;-

	name	crts0xs

;+
; DOS SMALL model C runtime startoff.
;-

;+
; At compile time:
;	Declare the classes 'CODE', 'DATA', 'CONST', 'STACK', 'MEMORY'
;	and 'DEBUG' in the right order so that LINK gets it right.
;	Set up a minimal stack of 2048 bytes.
;	Set up public label 'end_' in the MEMORY segment
;	so C knows where the program ends.
; At run time:
;	Set up segment registers.
;	Save the program segment prefix base address in '_pspbase_'
;	so C knows where the program begins.
;	Initialize BP to NULL for 'longjmp_()'.
;	Call '_main_()'.
;	Provide low level C callable '_exit_()'.
;-

	extrn	_main_:near

code	segment public	'code'
code	ends

data	segment public	'data'
; The following declaration prevents LINK from putting data at address DS:0.
	dw	0
	extrn	__end_:word
	extrn	_pspbase_:word
data	ends

const	segment public	'const'
const	ends

stack	segment stack	'stack'
	db	2048	dup	(?)
stack	ends

memory	segment memory	'memory'
	public	end_
end_	label	word
memory	ends

debug	segment	byte	public	'debug'
debug	ends

cgroup	group	code
dgroup	group	const, data, stack, memory

code	segment public	'code'
	public	_exit_

	assume	cs:cgroup

crts0	proc	near

	mov	ax, dgroup		; Initialize SS and DS
	mov	ss, ax			; with the
	mov	ds, ax			; base of dgroup
	assume	ds:dgroup		; and tell
	assume	ss:dgroup		; the assembler.

	mov	_pspbase_, es		; Initialize _pspbase.
	mov	es, ax			; Initialize ES
	assume	es:dgroup		; and tell the assembler.
	lea	ax, end_		; Initialize
	mov	__end_, ax		; __end_.
	mov	sp, ax			; Initialize stack pointer.

	sub	bp, bp			; Clear BP for longjmp.
	call	_main_			; Call _main which calls main.
	push	ax			; Save return status,
	push	ax			; push fake return address
					; and fall through to _exit.

;+
; void _exit(s) int s;
;
; Low level exit.
; Return to caller with exit status in AL.
; Since CSD catches end of execution at this label,
; all program terminations should pass through _exit_.
;-

_exit_	label	near

	cld				; For DOS.
	pop	ax			; Discard return address and
	pop	ax			; get exit status in AL.
	mov	ah, 4Ch 		; Load return exit status function code
	int	21h			; and do it.

crts0	endp

code	ends

	end	crts0
