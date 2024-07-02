;_ clock.asm   Thu Jul 13 1989   Modified by: Walter Bright */
; OS2 support added by Nikki Locke May 1989
; Copyright (C) 1986-1989 by Walter Bright
; All Rights Reserved
; Written by Walter Bright

include	MACROS.ASM

	begdata
starttime	dw	0,0	;program starting time
	enddata

    ifdef __OS2__
extrn	DOSGETDATETIME:far

; structure returned by DOSGETDATETIME - offsets into stack frame
hour		equ	-12
minute		equ	-11
second		equ	-10
hundr		equ	-9
day		equ	-8
month		equ	-7
year		equ	-6
timez		equ	-4
wday		equ	-2
structsize	equ	12
    endif

	begcode	clock

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Return the time in 1/100ths of a second since midnight.
; Useful for timing various things.
; Use:
;	clock_t clock(void);

	c_public clock
func	clock
    ifdef __OS2__
	push	bp
	mov	bp,sp
	sub	sp,structsize	;reserve space for structure
	push	ss		;segment of structure
	lea	ax,hour[BP]	;offset of structure
	push	ax
	call	DOSGETDATETIME
	mov	dl,hundr[BP]
	mov	dh,second[BP]
	mov	cl,minute[BP]
	mov	ch,hour[BP]
	add	sp,structsize	;tidy up stack
	pop	bp		;and restore BP
    else
	bdos	2Ch		;get system time
	; compute ticks + 100L * (secs + 60L * (mins + 60 * hours))
	;	   DL              DH            CL          CH
    endif
	push	DX
	push	DX
	mov	BX,60
	mov	AL,BL		;60 min/hr
	mul	CH		;AX = 60 * hours
	clr	CH		;CX = minutes
	add	AX,CX		;AX = mins + 60 * hours
	mul	BX		;DXAX = 60 * (mins + 60 * hours)

	pop	BX
	mov	BL,BH
	clr	BH		;BX = seconds
	add	AX,BX
	adc	DX,0		;DXAX = secs + 60L * (mins + 60 * hours)

	mov	BX,AX
	mov	AX,DX

	mov	CX,100
	mul	CX
	xchg	AX,BX
	mul	CX
	add	DX,BX		;DXAX = 100L * (secs + 60L * (mins + 60 * hours))

	pop	BX
	clr	BH
	add	AX,BX
	adc	DL,BH		;DXAX = ticks + ...
				; (will never overflow into DH)
	sub	AX,starttime
	sbb	DX,starttime[2]	;subtract off time that program started
	jc	L1		;rolled past midnight
	ret

L1:	;Add in one day's worth of CLK_TCKs (100 * 60 * 60 * 24)
	add	AX,0D600h
	adc	DX,00083h	;I don't trust MASM and math
	ret
c_endp	clock

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Initializer for clock(), it sets starttime to time that the program
; was started.

func	clock_ctor
	callm	clock
	mov	starttime,AX
	mov	starttime[2],DX
	ret
c_endp	clock_ctor

; Define clock_ctor as a static constructor, so it is called at
; program startup.

static_ctor	clock_ctor

	endcode	clock

	end
