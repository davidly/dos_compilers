;_ rot.asm   Thu Sep  8 1988   Modified by: Walter Bright */
; Copyright (C) 1988 by Walter Bright
; All Rights Reserved
; Written by Walter Bright

	include	macros.asm

	begcode	rot

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	#include <stdlib.h>
;	unsigned _rotl(unsigned i,unsigned count);
;
;	i is rotated left by count bits. 0 < count < 16
;	The rotated result is returned.

	public	__rotl
func	_rotl
	push	BP
	mov	BP,SP
	mov	AX,P[BP]
	mov	CX,P+2[BP]
;	and	CL,0Fh		;rotate modulo 16
	rol	AX,CL
	pop	BP
	ret
c_endp	_rotl

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	#include <stdlib.h>
;	unsigned _rotr(unsigned i,unsigned count);
;
;	i is rotated right by count bits. 0 < count < 16
;	The rotated result is returned.

	public	__rotr
func	_rotr
	push	BP
	mov	BP,SP
	mov	AX,P[BP]
	mov	CX,P+2[BP]
;	and	CL,0Fh		;rotate modulo 16
	ror	AX,CL
	pop	BP
	ret
c_endp	_rotr

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	#include <stdlib.h>
;	unsigned long _lrotl(unsigned long l,unsigned count);
;
;	l is rotated left by count bits.
;	The rotated result is returned.

	public	__lrotl
func	_lrotl
	push	BP
	mov	BP,SP
	mov	AX,P[BP]
	mov	DX,P+2[BP]
	mov	CX,P+4[BP]
	and	CX,01Fh		;rotate modulo 32
	jcxz	R1
R2:	shl	AX,1
	rcl	DX,1
	adc	AL,CH		;OR carry bit into bit 0
	loop	R2
R1:	pop	BP
	ret
c_endp	_lrotl

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	#include <stdlib.h>
;	unsigned long _lrotr(unsigned long l,unsigned count);
;
;	l is rotated right by count bits.
;	The rotated result is returned.

	public	__lrotr
func	_lrotr
	push	BP
	mov	BP,SP
	mov	AX,P[BP]
	mov	DX,P+2[BP]
	mov	CX,P+4[BP]
	and	CX,01Fh		;rotate modulo 32
	jcxz	R3
	mov	BX,DX
R4:	shr	BX,1
	rcr	AX,1
	rcr	DX,1
	loop	R4
R3:	pop	BP
	ret
c_endp	_lrotr

	endcode	rot

	end
