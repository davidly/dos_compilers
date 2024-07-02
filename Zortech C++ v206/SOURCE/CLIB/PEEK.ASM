;_ peek.asm   Sun Jan 24 1988   Modified by: Walter Bright */
; Copyright (C) 1985-1988 by Walter Bright
; All Rights Reserved
; Written by Walter Bright

	include	macros.asm

	begcode	peek

	c_public peek,poke

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Transfer numbytes from seg:offset to DS:buf
; Use:
;	void peek(unsigned seg,unsigned offset,void *buf,size_t numbytes);

func	peek
	push	BP
	mov	BP,SP
	mov	CX,P+4+SIZEPTR[BP]	;number of bytes to move
	jcxz	P1
	.save	<SI,DI>
	mov	AX,DS
	mov	DS,P[BP]	;source segment
	mov	SI,P+2[BP]	;source pointer in DS:SI
    if LPTR
	les	DI,P+4[BP]	;get pointer to buf in ES:DI
    else
	mov	ES,AX
	mov	DI,P+4[BP]	;get pointer to buf in ES:DI
    endif
	rep	movsb
	mov	DS,AX
	.restore <DI,SI>
P1:
	pop	BP
	ret
c_endp	peek

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Transfer numbytes from DS:buf to seg:offset
; Use:
;	void poke(unsigned seg,unsigned offset,void *buf,size_t numbytes);

func	poke
	push	BP
	mov	BP,SP
	mov	CX,P+4+SIZEPTR[BP]	;# of bytes to move
	jcxz	P2
	.save	<SI,DI>
	mov	ES,P[BP]	;segment of destination
	mov	DI,P+2[BP]	;ES:DI -> destination
    if LPTR
	mov	AX,DS
	lds	SI,P+4[BP]	;DS:SI -> buf (source pointer)
	rep	movsb
	mov	DS,AX
    else
	mov	SI,P+4[BP]	;buf (source offset)
	rep	movsb
    endif
	.restore <DI,SI>
P2:
	pop	BP
	ret
c_endp	poke

	endcode	peek

	end
