;
;                   (C) Micro Focus Ltd, 1989
;
;	This routine is called by the cobol program ADD.CBL
;	To assemble and link the routine to a .EXE file simply type:
;
;			MASM ADDEM;
;			LINK ADDEM;
;
public 	addem			;module id

cseg 	segment para public 'CODE'
assume 	cs:cseg

first_param  equ dword ptr [bp+6]       ;pointer to first parameter
second_param equ dword ptr [bp+10]      ;pointer to second parameter
res_ult      equ dword ptr [bp+14]      ;pointer to third parameter

addem proc far
 	push 	bp     		;preserve bp
	mov 	bp,sp  		;put current stack pointer in bp
 	push 	ds     		;preserve ds,si,di,flags
 	push 	si
 	push 	di
 	pushf

	mov 	ax,dseg		;initialize ds
	mov 	ds,ax

	;      THE NEXT 6 STATEMENTS ARE THE VARIABLE PART
	;      OF THIS ROUTINE.  MOST EVERYTHING ELSE IS NEEDED
	;      FOR EVERY ASSEMBLER ROUTINE CALLED BY COBOL.
	les  	di,first_param	;get address of first parameter
	mov 	al,es:[di]	;get value of first parameter
	les 	di,second_param	;get address of second parameter
	add 	al,es:[di]	;add value of 2nd param to first

	les 	di,res_ult	;get address of res_ult
	stosb			;return result to cobol program

	xor	ax,ax		;set return code, 0 in ax = success

 	popf			;restore registers
 	pop di
 	pop si
 	pop ds
 	pop bp

	ret			;far return
addem	endp
cseg	ends

dseg 	segment para public 'DATA'
	your_data	db	'data'
	;	INCLUDE YOUR DATA HERE
dseg 	ends

end

