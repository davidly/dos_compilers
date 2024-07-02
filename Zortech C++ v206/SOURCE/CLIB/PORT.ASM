;_ port.asm   Sun Jan 24 1988   Modified by: Walter Bright */
; Copyright (C) 1985-1988 by Walter Bright
; All Rights Reserved
; Joe Huffman 10/28/85
; I/O port functions.

        include macros.asm

        begcode	port

;;;;;;;;;;;;;;;;;;;;;;;;;
; Read from I/O port.
; Use:
;	int inp(portnumber)
;	unsigned portnumber;
; Returns:
;	byte read from I/O port with high byte cleared

	c_public inp
func	inp
	push	BP
	mov	BP,SP
        mov     DX,P[BP]        ; The port number.
        in      AL,DX
        xor     AH,AH           ; Clear the upper byte.
	pop	BP
        ret
c_endp	inp

;;;;;;;;;;;;;;;;;;;;;;;;;
; Read from I/O port.
; Use:
;	int inpw(portnumber)
;	unsigned portnumber;
; Returns:
;	word read from I/O port

	c_public inpw
func	inpw
	push	BP
	mov	BP,SP
        mov     DX,P[BP]	; The port number.
        in      AX,DX           ; Done.
	pop	BP
        ret
c_endp	inpw

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Output byte to I/O port.
; Use:
;	int outp(portnumber,byte)
;	unsigned portnumber,byte;
; Returns:
;	byte

	c_public outp
func	outp 
	push	BP
	mov	BP,SP
        mov     AX,P+2[BP]
        mov     DX,P[BP]
        out     DX,AL
	pop	BP
        ret
c_endp	outp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Output word to I/O port.
; Use:
;	int outpw(portnumber,word)
;	unsigned portnumber,word;
; Returns:
;	byte

	c_public outpw
func	outpw
	push	BP
	mov	BP,SP
        mov     AX,P+2[BP]
        mov     DX,P[BP]
        out     DX,AX
	pop	BP
        ret
c_endp	outpw

	endcode	port

        end

