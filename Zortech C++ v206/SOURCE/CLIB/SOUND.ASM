;_ sound.asm   Fri Oct  2 1987   Modified by: Walter Bright */
; Copyright (C) 1985-1989 by Walter Bright
; All rights reserved
; Written by Walter Bright

include	MACROS.ASM

    ifdef __OS2__
extrn	DOSBEEP:far
    endif

	begcode	sound

	c_public	sound_beep,sound_click

    ifdef __OS2__
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Beep the speaker.
; Use:
;	void sound_note(int frequency,int duration);
;	frequency in Hz
;	duration in milliseconds

c_public	sound_note

func	sound_note
	push	BP
	mov	BP,SP
	push	p[bp]		;frequency
	push	p+2[bp]		;duration
	call	DOSBEEP
	pop	bp
	ret
c_endp	sound_note

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Beep the speaker.
; Use:
;	void sound_beep(int freq);
;	freq = frequency (1331 = 1000 Hz)

func	sound_beep
	push	BP
	mov	BP,SP
	mov	ax,p[bp]	;frequency
	mov	cx,1000		;horrible kludge to get frequence back to Hz
	mul	cx
	mov	cx,1331
	div	cx
	mov	bx,500		;half a second
	push	ax
	push	bx
	call	DOSBEEP
	pop	bp
	ret
c_endp	sound_beep

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Generate a click on the speaker.
; Use:
;	void sound_click();
;

func	sound_click
	mov	ax,50
	push	ax
	mov	ax,50
	push	ax
	call	DOSBEEP
	ret
c_endp	sound_click

    else ;__OS2__
ppi_port	equ	61h	;8255A-5 PPI port
timer		equ	40h	;timer 8253-5

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Generate a tone on the speaker
; Use:
;	void sound_tone(int cycles,int uptime,int dntime);
;	cycles =	# of cycles
;	uptime =	one half-cycle time
;	dntime =	other half-cycle time
; BUGS:
;	dependent on clock speed of CPU - should be rewritten to use
;	timer chip.

c_public	sound_tone
func	sound_tone
	push	BP
	mov	BP,SP

;	cli
	in	AL,ppi_port
	push	AX		;save original configuration of port
	mov	BX,P[BP]

L3:	and	AL,0FCh
	out	ppi_port,AL	;turn off speaker
	mov	CX,P+2[BP]
L1:	loop	L1
	or	AL,2
	out	ppi_port,AL	;turn on speaker
	mov	CX,P+4[BP]
L2:	loop	L2
	dec	BX		;for cycles times
	jne	L3
	pop	AX
	out	ppi_port,AL	;restore port to original configuration
;	sti

	pop	BP
	ret
c_endp	sound_tone


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Beep the speaker.
; Use:
;	void sound_beep(int freq);
;	freq = frequency (1331 = 1000 Hz)
; BUGS:
;	The duration of the beep is dependent on the CPU clock speed.

func	sound_beep
	push	BP
	mov	BP,SP

	mov	BL,2		;delay count
	mov	AL,10110110b	;sel tim 2,lsb,msb,binary
	out	timer+3,AL	;write the timer mode reg
	mov	AX,P[BP]	;get freq
	out	timer+2,AL	;write timer 2 count, lsb
	mov	AL,AH
	out	timer+2,AL	;write timer 2 count, msb
	in	AL,ppi_port	;get current setting of port
	mov	AH,AL		;save it
	or	AL,3		;turn speaker on
	out	ppi_port,AL
	clr	CX		;set count to wait 500ms
B1:	loop	B1
	dec	BL		;delay count
	jne	B1
	mov	AL,AH		;original value of port
	out	ppi_port,AL
	pop	BP
	ret
c_endp	sound_beep


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Generate a click on the speaker. This is a degenerate version of sound_tone().
; Use:
;	void sound_click();
;

func	sound_click
	in	AL,ppi_port
	push	AX

	and	AL,0FCh
	out	ppi_port,AL
	mov	CX,40
C1:	loop	C1
	or	AL,2
	out	ppi_port,AL
	mov	CX,40
C2:	loop	C2
	pop	AX
	out	ppi_port,AL
	ret
c_endp	sound_click
    endif ;__OS2__

	endcode	sound

	end

