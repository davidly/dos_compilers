;_ bios.asm   Sun May  8 1988   Modified by: Walter Bright */
; These functions are not available under OS/2
; Copyright (C) 1985-1989 by Walter Bright
; All rights reserved
; Written by Walter Bright
include	macros.asm

IF LPTR
DISKINFO STRUC
	drive		DW	?
	head		DW	?
	track		DW	?
	sector		DW	?
	nsectors	DW	?
	buffer		DD	?
DISKINFO ENDS
ELSE
DISKINFO STRUC
	drive		DW	?
	head		DW	?
	track		DW	?
	sector		DW	?
	nsectors	DW	?
	buffer		DW	?
DISKINFO ENDS
ENDIF

	begcode	bios

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Access BIOS keyboard function
;	#include <bios.h>
;	int _bios_keybrd(int flag);
;	int bioskey(int flag);		/* both are the same routine	*/
; Usage:
;	flag = 0	Return ascii value in low byte, scan code in high byte
;	     = 1	Return 0 if no key is available else return ascii
;			value in low byte and scan code in high byte. Key is
;			left unread in BIOS
;	     = 2	Return shift status, bits are:
;			0x01	Right shift key is down
;			0x02	Left shift key is down
;			0x04	Ctrl key is down
;			0x08	Alt key is down
;			0x10	Scroll Lock is toggled
;			0x20	Num Lock is toggled
;			0x40	Caps Lock is toggled
;			0x80	Ins is toggled
;			Other bits are undefined

	public	_bioskey
_bioskey:

	c_public _bios_keybrd
func	_bios_keybrd
	push	BP
	mov	BP,SP
	mov	AH,P[BP]
	int	16h
	jnz	K1
	.if	<byte ptr P[BP]> ne 1, K1
	clr	AX		;if flag is 1 and Z was set
K1:	pop	BP
	ret

c_endp	_bios_keybrd


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Access BIOS equipment list function
;	#include <bios.h>
;	unsigned _bios_equiplist(void);
; Usage:
;	returns the bios equipment list in AX
;
;	bit 0			1if any diskettes
;	bit 1			Not used (set to 0)
;	bits 2 & 3		System board RAM: 11 = 64k (normal)
;	bits 4 & 5		Initial video mode 10 = color, 11 = mono, 01 = 40col
;	bits 6 & 7		Number of disk drives -1
;	bit 8			DMA chip (0 = installed)
;	bits 9,10 & 11	Number of serial ports
;	bit 12			Game adaptor (1 = installed)
;	bit 13			Serial printer installed (=1) PC jnr only.
;	bits 14 & 15	Number of printers installed
;
	c_public _bios_equiplist
func _bios_equiplist
	int	11h
	ret

c_endp	_bios_equiplist

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Access BIOS memory size function
;	#include <bios.h>
;	unsigned _bios_memsize(void)
; Usage:
;	returns the memory size in kilobytes
;	in AX
;	
	c_public _bios_memsize
func	_bios_memsize
	int	12h
	ret

c_endp	_bios_memsize


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Access BIOS printer functions
;	#include <bios.h>
;	int _bios_printer(unsigned service, unsigned printer, unsigned data)
; Usage:
;	service = 0	write the low order byte of data to the printer which
;			was specified in the printer argument.
;			returns the printer status thus
;			0x01	Printer timed out
;			0x02	Not used
;			0x04	Not used
;			0x08	I/O error
;			0x10	Printer selected
;			0x20	Out of paper
;			0x40	Acknowledge
;			0x80	Printer not busy
;	service = 1	Intialize the selected printer. The data argument is
;				ignored. The status is return as above.
;	service = 2	Returns the printer status as defined above
;	
	c_public _bios_printer
func	_bios_printer
	push	BP
	mov	BP,SP
	mov	AH,P[BP]
	mov	DX,P+2[BP]
	mov	AL,P+4[BP]
	int	17h
	mov	AL,AH		;return status byte in AL
	clr	AH
	pop	BP
	ret

c_endp	_bios_printer

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Access BIOS serial comms functions
;	#include <bios.h>
;	int _bios_serialcom(unsigned service, unsigned port, unsigned data)
; Usage:
;	service = 0	Sets the data port up as specified in the data argument	
;	service = 1	Transmits the data character over the port
;	service = 2	Accepts a charcter from the serial port
;	service = 3 Returns the current status of the selected serial port
	c_public _bios_serialcom
func	_bios_serialcom
	push	BP
	mov	BP,SP
	mov	AH,P[BP]
	mov	DX,P+2[BP]
	mov	AL,P+4[BP]
	int	14h
	pop	BP
	ret

c_endp _bios_serialcom

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Access BIOS time of day functions
;	#include <bios.h>
;	int _bios_timeofday(int service, long *timeval)
; Usage:
;	service = 0	copies the current value of the clock count
;				to the location that timeval points to.
;	service = 1	sets the current value of the system clock 
;				to that in the location pointed to by timeval.
	c_public _bios_timeofday
func	_bios_timeofday
	push	BP
	mov	BP,SP
	mov	AH,P[BP]
if LPTR
	push	DS
	lds	BX,P+2[BP]
else
	mov	BX,P+2[BP]
endif
	.if AH ne 1,T1
	mov	DX,[BX]
	mov	CX,[BX+2]
	int	1ah
	jmps	T2
T1:	int	1ah
	mov	[BX],DX
	mov	[BX+2],CX
T2:
if LPTR
	pop	DS
endif
	pop	BP
	ret

c_endp	_bios_timeofday


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Access BIOS disk (int 0x13)  functions
;	#include <bios.h>
;	int _bios_disk(int service, struct diskinfo_t *diskinfo)
; Usage:
;	service = 0	reset the disk system
;	service = 1	get diskette status					
;	service = 2	read diskette sectors					
;	service = 3	write diskette sectors					
;	service = 4	verify diskette sectors					
;	service = 5	format diskette sectors					
	c_public _bios_disk
func	_bios_disk
	push	BP
	mov	BP,SP
	mov	AH,P[BP]
if LPTR
	push	DS
	lds	SI,P+2[BP]
else
	mov	SI,P+2[BP]
endif
	push	AX
	mov	DX,drive[SI]
	mov	AX,head[SI]
	mov	DH,AH
	mov	CX,sector[SI]
	mov	AX,track[SI]
	mov	CH,AH
	mov	AX,nsectors[SI]
if LPTR
	lds	BX,buffer[SI]
else
	mov	BX,buffer[SI]
endif
	pop	AX
	int	13h
	mov	AH,AL
	jmp	T2

c_endp	_bios_disk


	endcode bios

	end
