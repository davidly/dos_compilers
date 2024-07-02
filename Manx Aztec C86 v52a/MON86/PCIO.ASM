; Copyright (C) 1989 by Manx Software Systems, Inc. 
;:ts=8
;------------------------------------------------------------
; Module:
;   pcio.asm
;
; Description:
;   PCIO, which is linked into both RDB and the monitor,
;   accesses the serial port on behalf of the packet routines.
;
;   These routines assume that both programs are running on IBM PC-type 
;   systems. The routines can be initialized to access either COM1 or COM2,
;   and can drive the serial line at any rate up to the maximum 115k baud.
;
;   The PCIO routines usually access the serial port using "sense-status"
;   loops instead of interrupts. The only time serial interrupts are enabled
;   is on the target system, when the user program is executing. Then the
;   serial interrupt allows the host system's operator to break into the
;   execution of the user program.
;
;   During receipt of a packet, interrupts are disabled. This is needed
;   to achieve high data transmission rates. 
;   A disadvantage is that all interrupts, 
;   including those of the clock and keyboard, are disabled on the receiving
;   system during receipt of a packet.
;
;   PCIO can be used in both small code and large code programs.
;
; Special equates:
;	MODEL	Defines pcio's memory model (used by procdef macro).
;	ALLOW_INT	1=Allow break into executing program.
;			0=Don't allow break.
;
;------------------------------------------------------------
	include	lmacros.h
dataseg	segment	word public 'data'
BASE	equ	3f8H		;COM1's base port address
; Serial port registers:
; These are stored as DW's rather than EQU's, so that they can be
; changed to use COM2's addresses during syytem startup, if desired.
DATA	dw	BASE+0		;data register
INTENAB	dw	BASE+1		;interrupt enable register
DIVLAT	dw	BASE+0		;divisor latch (least sig. byte)
INTID	dw	BASE+2		;interrupt identification register
LINECTL	dw	BASE+3		;line control register
MODCTL	dw	BASE+4		;modem control register
LINSTAT	dw	BASE+5		;line status register
MODSTAT	dw	BASE+6		;modem status register
;
; 8259 Interrupt controller information:
;
INTNUM  db	12		;COM1 interrupt vector #
INTMASK db	10H		;bit mask for 8259.
INTCTL	equ	20h		;8259 control register
INTCHIP equ	21h		;8259 mask register

i	db	0
vec_save dd	?
intr_reg db	?
intr_chp db	?
dataseg ends


	assume	cs:codeseg, ds:dataseg
codeseg	segment
;---------------------------------------------------------
; Procedure:
;   FirstThing_
;
; Purpose:
;   Do special initialization, after reset and before any other system
;   initialization. When FirstThing is entered, no other initialization
;   has yet been done. In particular, the dataseg segment hasn't been 
;   initialized, bss segment hasn't been cleared, and the DS, ES, SS segment
;   registers haven't been set up.
;
; Input:
;   None.
;
; Output:
;   None.
;
; Changes:
;   AX, DX, DS
;---------------------------------------------------------
	procdef	FirstThing
	pret
	pend	FirstThing

;---------------------------------------------------------
; Procedure:
;   comPutChar_
;
; Purpose:
;   Output one byte.
;
; Input:
;   The byte to be sent is on the stack.
;
; Output:
;   The byte is sent to the serial port.
;
; Changes:
;   AX.
;---------------------------------------------------------
	procdef	comPutChar,<<outvalue,word>>
	push	dx
	mov	dx,LINSTAT
comput1:				;wait until transmitter is ready
	in	al,dx
	and	ax,20H
	jz	comput1
	mov	ax,outvalue		;get caller's char.
	mov	dx,DATA
	out	dx,al			;output the data
	pop	dx
	pret
	pend	comPutChar
;---------------------------------------------------------
; Procedure:
;   comGetChar_
;
; Purpose:
;   Input one byte.
;
; Input:
;   None.
;
; Return values:
;   Carry flag:	Set if error occurred, reset if not.
;   AH:		-1 if an error occurred, 0 if not.
;   AL:		Line status if error occurred, input byte if not.
;
; Changes:
;   AX, DX.
;---------------------------------------------------------
	procdef	comGetChar
	mov	dx,LINSTAT
comGC1:
	in	al,dx
	and	al,15			;check for data avail & errors
	jz	comGC1			;loop until something happens
	test	al,14			;check for errors
	jnz	comGC_err
	mov	dx,DATA
	in	al,dx			;get the character
	xor	ah,ah			;Make result positive to report
					;no error to C callers.
	clc				;Clear carry to report no error
					;to asm callers.
	pret
comGC_err:
	mov	ah,-1			;Make AX negative to report an error
					;to C callers.
	stc				;Set carry to report an error 
					;to asm callers.
	pret
	pend	comGetChar
;---------------------------------------------------------
; Procedure:
;   comGetBunch_
;
; Purpose:
;   Called by GetPacket() to read some characters from the serial line.
;   
; Input:
;   CX    = number of characters to read.
;   ES:DI = Pointer to location where characters are to be placed.
;
; Output:
;   - The input characters are stored in the place pointed at by ES:DI.
;   - Return values:
;	ES:DI	Address of the byte following the last stored byte.
;	Carry flag
;		Set if an error occurred.
;		Reset if no error.
;	AX	Line status. (0 if no error).
;		
; Changes:
;   AX, DX.
;
; Notes:
;   Interrupts are disabled while in comGetBunch. For low transmission
;   rates (e.g. 9600 and lower) interrupts could be enabled and still
;   not lose data.
;---------------------------------------------------------
	procdef	comGetBunch
	cld
GB0:
	mov	dx,LINSTAT
GB1:
	in	al,dx
	and	al,15			;check for data avail & errors
	jz	GB1			;loop until something happens
	test	al,14			;check for errors
	jnz	GBerr
	mov	dx,DATA
	in	al,dx			;get the character
	stosb				;save the received char
	loop	GB0
	clc				;say no error occurred
	xor	ax,ax
	pret
; Come here if an input error occurs.
GBerr:
	xor	ah,ah			;AX = line status
	stc
	pret				;return error to caller
	pend	comGetBunch

;---------------------------------------------------------
; Procedure:
;   comStatus_
;
; Purpose:
;   Get status of COM port.
;
; Input:
;   None.
;
; Output:
;   The low order four bits of the serial port's line status register
;   are returned in AX.
;
; Changes:
;   AX, DX
;---------------------------------------------------------
	procdef	comStatus
	xor	ah,ah
	mov	dx,LINSTAT
	in	al,dx
	and	al,15
	pret
	pend	comStatus

;---------------------------------------------------------
; Procedure:
;   comInit_
;
; Purpose:
;   Initialize COM port.
;
; Input:
;   baud rate 	 - The word on the stack that's just above the 
;		   return address. This is normally the actual baud rate;
;		   e.g. 9600, 1200. But there are two special values:
;		   0 - Don't send baud rate selection to serial port.
;		   1 - Set baud rate to 115k baud.
;   serial port	 - The serial port to use. 1 signifies COM1, 2 COM2.
;
; Output:
;   None.
;
; Changes:
;   AX, BX, CX, DX
;---------------------------------------------------------
	procdef	comInit, <<speed,word>,<channel,word>>
	cmp	channel,1
	je	skipfix
;
;	we are using SERIAL2, adjust I/O ports, and Int vectors
;
	mov	bx,offset DATA
	mov	al,2
fixloop:
	mov	byte ptr 1[bx],al
	add	bx,2
	cmp	bx,offset MODSTAT
	jbe	fixloop
	dec	INTNUM			;serial2 uses IRQ3
	shr	INTMASK,1

skipfix:
	mov	dx,INTENAB		;get contents of interupt enable reg.
	in	al,dx
	mov	intr_reg,al 		;sav contents of interupt enable reg.
	mov	al,0			;disable interupts 
	out	dx,al
ifdef ROM
; Initialize the 8259 chip for a PC clone-type system
; First send Initialization command words
	mov	al,13h			;ICW1: edge, sngl, icw4
	out	INTCTL,al
	mov	al,8			;ICW2: IRQ0 is interrupt 8
	out	INTCHIP,al
	mov	al,9			;ICW4: buffrd, 8086 mode
	out	INTCHIP,al
; Now send operation control word 1
	mov	al,0ffh			;mask off all but COM1 interrupts
;	mov	al,INTMASK		;mask off all but COM1 interrupts
	out	INTCHIP,al
; The following isn't needed:
;	mov	al,20h			;signal EOI to interrupt controller
;	out	INTCTL,al
endif
	cmp	speed,0
	je	nosetup
	cmp	speed, 1		;special case check for 115200 baud
	jne	cominit1
	mov	al,80H
	mov	dx,LINECTL
	out	dx,al
	mov	ax,1
	jmp	cominit2
cominit1:
	mov	al,80H
	mov	dx,LINECTL
	out	dx,al
	mov	ax,0c200H
	mov	dx,1		;dividend = 0x1c200
	div	speed		;compute baud rate divisor
cominit2:
	mov	dx,DIVLAT
	out	dx,al		;setup com port to given baud rate
	mov	al,ah
	inc	dx		;second byte of divisor latch
	out	dx,al
nosetup:
; clear any pending interrupts
	mov	dx,DATA
	in	al,dx		;just in case one was waiting for us
	mov	dx,LINSTAT
	in	al,dx		;clear status interrupts
	mov	dx,MODSTAT
	in	al,dx
; setup line and modem control registers
	mov	al,03H		;set 8 data, 1 stop, no parity
	mov	dx,LINECTL
	out	dx,al
	mov	dx,MODCTL
	mov	al,03h		;turn on DTR, RTS, disable serial interrupts 
	out	dx,al
	pret
	pend	comInit

;---------------------------------------------------------
; Procedure:
;   comRestore
;
; Purpose:
;   Restore com port to original condition.
;   This is done by setting the 8259 registers back to their 
;   initial state.
;
; Input:
;   None.
;
; Output:
;   The 8259 is set back in its original state.
;
; Changes:
;   AX, DX.
;---------------------------------------------------------
	procdef	comRestore
	mov	al,intr_reg
	mov	dx,INTENAB
	out	dx,al
if 0
	mov	al,intr_chp
	mov	dx,INTCHIP
	out	dx,al
endif
	pret
	pend	comRestore
;---------------------------------------------------------
; Procedure:
;   comIsrSet
;
; Purpose:
;   Set the serial interrupt vector.
;   This routine is called by the monitor, before control of the
;   processor is passed to the user program, in order to allow the host
;   operator to break into the user program.
;
; Input:
;   CS:AX - The new serial interrupt vector.
;
; Output:
;   The serial interrupt vector is modified.
;
; Changes:
;   None.
;---------------------------------------------------------
dataseg	segment
saveser	dw	0,0
dataseg	ends
	procdef	comIsrSet
ifdef ALLOW_INT
	push	dx
	push	bx			;save registers
	push	es
	push	ax
	mov	bx,0			;point es:bx at serial vector
	mov	es,bx
	mov	bl,INTNUM
	shl	bx,1
	shl	bx,1
	mov	ax,es:[bx]		;save current vector in saveser
	mov	saveser,ax
	mov	ax,es:[bx+2]
	mov	saveser+2,ax
	mov	ax,cs			;set CS:AX in vector
	mov	es:[bx+2],ax
	pop	ax
	mov	es:[bx],ax
; enable serial interrupts on the 8250
	mov	dx,LINECTL		;clear any pending serial ints
	in	al,dx
	mov	dx,DATA
	in	al,dx	
	mov	dx,MODCTL
	mov	al,0bh			;turn on DTR, RTS, and allow ints
	out	dx,al
	mov	dx,INTENAB		;interrupt on receipt of character
	mov	al,1			
	out	dx,al
; enable serial interrupts on the 8259
	mov	dx,INTCHIP		;get contents of interupt chip
	in	al,dx
	mov	intr_chp,al		;sav contents of interupt chip
	mov	cl,INTMASK
	not	cl
	and	al,cl
	out	dx,al			;turn on interupt chip
; restore registers and return
	pop	es			;restore regs
	pop	bx
	pop	dx
endif
	pret				;return to caller
	pend	comIsrSet
;---------------------------------------------------------
; Procedure:
;   comIsrReset
;
; Purpose:
;   Reset the serial interrupt vector to the value it had before
;   comIsrSet was called.
;
; Input:
;   None.
;
; Output:
;   The serial interrupt vector is restored.
;
; Changes:
;   None.
;---------------------------------------------------------
	procdef	comIsrReset
ifdef ALLOW_INT
	push	es			;save registers
	push	dx
	push	bx
	push	ax
	mov	bx,0			;point es:bx at vector
	mov	es,bx
	mov	bl,INTNUM
	shl	bx,1
	shl	bx,1
	mov	ax,saveser		;restore saved vector
	mov	es:[bx],ax
	mov	ax,saveser+2
	mov	es:[bx+2],ax
; disable serial interrupts on the 8250
	mov	dx,INTENAB
	mov	al,0
	out	dx,al
	mov	dx,MODCTL
	mov	al,3			;turn on just DTR, RTS
	out	dx,al
; disable serial interrupts on the 8259
	mov	al,intr_chp
	mov	dx,INTCHIP
	out	dx,al
; restore registers and return
	pop	ax			;restore registers
	pop	bx
	pop	dx
	pop	es
endif
	pret
	pend	comIsrReset
;---------------------------------------------------------
; Procedure:
;   comIsrClear_
;
; Purpose:
;   Clear the serial input port, after interrupt
;
; Input:
;   None.
;
; Output:
;   None.
;   
;---------------------------------------------------------
	procdef	comIsrClear
ifdef ALLOW_INT
	push	dx
	push	ax
	mov	dx,DATA			;flush the input port
	in	al,dx
	mov	al,20h			;signal EOI to interrupt controller
	out	INTCTL,al
	pop	ax
	pop	dx
endif
	pret
	pend	comIsrClear

codeseg	ends
	end
