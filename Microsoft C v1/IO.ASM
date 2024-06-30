; This module defines subroutines to input and output bytes from
; an auxiliary port.
;
; name		inp -- input byte from port
;
; synopsis	c = inp(port);
;		int c;		returned byte
;		int port;	port address
;
; description	This function inputs a byte from the specified port
;		address and returns it as the function value.
;
PGROUP	GROUP	PROG
PROG	SEGMENT	BYTE PUBLIC 'PROG'
	PUBLIC	INP,OUTP
	ASSUME	CS:PGROUP
INP	PROC	NEAR
	PUSH	BP		;SAVE BP
	MOV	BP,SP
	MOV	DX,[BP+4]	;GET PORT ADDRESS
	IN	AL,DX		;GET INPUT BYTE
	XOR	AH,AH		;CLEAR HIGH BYTE
	POP	BP
	RET
INP	ENDP
;
; name		outp -- output byte to port
;
; synopsis	outp(port,c);
;		int port;	port address
;		int c;		byte to send
;
; description	This function sends the specified character to
;		the specified port.
;
OUTP	PROC	NEAR
	PUSH	BP		;SAVE BP
	MOV	BP,SP
	MOV	DX,[BP+4]	;GET PORT ADDRESS
	MOV	AX,[BP+6]	;GET OUTPUT BYTE
	OUT	DX,AL
	POP	BP
	RET
OUTP	ENDP
PROG	ENDS
	END
,SP
	MOV	DX,[BP+4]	;GET PORT ADDRESS
	MOV	AX,[BP+6]