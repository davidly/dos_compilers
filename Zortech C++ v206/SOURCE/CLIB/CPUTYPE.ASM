;_ cputype.asm   Sat Jan 14 1989   Modified by: Walter Bright */
; Copyright (C) 1987-1989 by Walter Bright
; All rights reserved

include	macros.asm

	begcode	CPUTYPE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Determine which CPU is running.
; Placed into public domain by Compaq Computers.
; Do not call from protected mode.
;	int cputype(void);
; Returns:
;	0	8088/8086/V20
;	1	80186
;	2	80286
;	3	80386

	c_public cputype
func	cputype
	pushf
	clr	AX
	push	AX
	popf		;try forcing flag word to all 0
	pushf
	pop	AX	;retrieve them for testing
	and	AH,0F0h
	.if	AH ne 0F0h, L2	;it's a 286 or 386
	;Distinguish between 8088/8086 and 80186
	clr	AX
	push	SP		;is SP pushed before or after it's decremented?
	pop	BX
	.if	BX ne SP,L1	;it's an 8088/8086
	jmps	L3		;it's an 80186

L2:	mov	AX,0F000h
	push	AX		;try to force high bits on in flags
	popf
	pushf
	pop	AX		;AX = what was actually stored
	and	AH,0F0h
	mov	AX,2
	jz	L1		;no, it's a 286
L3:	inc	AX		;it's a 186 or 386
L1:	popf			;original flags
	ret
c_endp	cputype

	endcode	CPUTYPE

	end
