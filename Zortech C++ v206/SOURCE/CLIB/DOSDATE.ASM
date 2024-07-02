;_ dosdate.asm   Tue Oct 10 1989   Modified by: Walter Bright */
; $Header$
;Copyright (C) 1989 by Walter Bright
;All rights reserved.
;Written by Dave Mansell

include	macros.asm

DATE STRUC
	day		db	?
	month		db	?
	year		dw	?
	dofw		db	?
DATE ENDS

TIME STRUC
	hour		db	?
 	minutes		db	?
	seconds		db	?
	hseconds	db	?
TIME ENDS

DATETIME STRUC
	Ohour		db	?
 	Ominutes	db	?
	Oseconds	db	?
	Ohseconds	db	?
	Oday		db	?
	Omonth		db	?
	Oyear		dw	?
	Ozone		dw	?
	Odofw		db	?
DATETIME ENDS

DATETIMESIZE equ 11

	begdata
	c_extrn	errno,word
	enddata

    ifdef __OS2__
	extrn	DOSGETDATETIME:far
	extrn	DOSSETDATETIME:far
    endif

	begcode	dosdate

	c_public dos_setdate, dos_getdate, dos_settime, dos_gettime

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; set dos date information
;	int dos_setdate(date)

func	dos_setdate
	push	BP
	mov	BP,SP
ifdef __OS2__
	sub	SP,DATETIMESIZE
	mov	BX,SP		;local time and date structure
	push	SS
	push	BX
	call	DOSGETDATETIME
	push	DI
    if SPTR
	mov	DI,P[BP]	;where to get the information
    else
	push	DS
	lds	DI,P[BP]	;where to get the information
    endif
	mov	AL,day[DI]
	mov	SS:Oday[BX],AL
	mov	AL,month[DI]
	mov	SS:Omonth[BX],AL
	mov	AX,year[DI]
	mov	SS:Oyear[BX],AX
	push	SS
	push	BX
	call	DOSSETDATETIME
else
	push	DI
    if SPTR
	mov	DI,P[BP]	;where to get the information
    else
	push	DS
	lds	DI,P[BP]	;where to get the information
    endif
	mov	DL,day[DI]
	mov	DH,month[DI]
	mov	CX,year[DI]
	bdos	2bh			;set system date
endif
ex1:	clr	AH
    if LPTR
	pop	DS
    endif
	pop	DI
	mov	SP,BP
	pop	BP
	ret
c_endp	dos_setdate

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; get dos date information
;	void dos_getdate(date)

func	dos_getdate
	push	BP
	mov	BP,SP
ifdef __OS2__
	sub	SP,DATETIMESIZE
	mov	BX,SP		;local time and date structure
	push	SS
	push	BX
	call	DOSGETDATETIME
	push	DI
    if SPTR
	mov	DI,P[BP]	;where to get the information
    else
	push	DS
	lds	DI,P[BP]	;where to get the information
    endif
	mov	AL,SS:Oday[BX]
	mov	day[DI],AL
	mov	AL,SS:Omonth[BX]
	mov	month[DI],AL
	mov	AX,SS:Oyear[BX]
	mov	year[DI],AX
	mov	AL,SS:Odofw[BX]
	mov	dofw[DI],AL
else
	push	DI
	bdos	2ah		;get system date
    if SPTR
	mov	DI,P[BP]	;where to store the information
    else
	push	DS
	lds	DI,P[BP]	;where to store the information
    endif
	mov	day[DI],DL
	mov	month[DI],DH
	mov	year[DI],CX
	mov	dofw[DI],AL
endif
	jmps	ex1
c_endp	dos_getdate

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; set dos time information
;	int dos_settime(time)

func	dos_settime
	push	BP
	mov	BP,SP
ifdef __OS2__
	sub	SP,DATETIMESIZE
	mov	BX,SP		;local time and date structure
	push	SS
	push	BX
	call	DOSGETDATETIME
	push	DI
    if SPTR
	mov	DI,P[BP]	;where to get the information
    else
	push	DS
	lds	DI,P[BP]	;where to get the information
    endif
	mov	AL,hour[DI]
	mov	SS:Ohour[BX],AL
	mov	AL,minutes[DI]
	mov	SS:Ominutes[BX],AL
	mov	AL,seconds[DI]
	mov	SS:Oseconds[BX],AL
	mov	AL,hseconds[DI]
	mov	SS:Ohseconds[BX],AL
	push	SS
	push	BX
	call	DOSSETDATETIME
else
	push	DI
    if SPTR
	mov	DI,P[BP]	;where to get the information
    else
	push	DS
	lds	DI,P[BP]	;where to get the information
    endif
	mov	CH,hour[DI]
	mov	CL,minutes[DI]
	mov	DH,seconds[DI]
	mov	DL,hseconds[DI]
	bdos	2dh			;set system time
endif
	jmps	ex1
c_endp	dos_settime

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; get dos time information
;	void dos_gettime(time)

func	dos_gettime
	push	BP
	mov	BP,SP
ifdef __OS2__
	sub	SP,DATETIMESIZE
	mov	BX,SP		;local time and date structure
	push	SS
	push	BX
	call	DOSGETDATETIME
	push	DI
    if SPTR
	mov	DI,P[BP]	;where to get the information
    else
	push	DS
	lds	DI,P[BP]	;where to get the information
    endif
	mov	AL,SS:Ohour[BX]
	mov	hour[DI],AL
	mov	AL,SS:Ominutes[BX]
	mov	minutes[DI],AL
	mov	AL,SS:Oseconds[BX]
	mov	seconds[DI],AL
	mov	AL,SS:Ohseconds[BX]
	mov	hseconds[DI],AL
else
	push	DI
	bdos	2ch		;get system time
    if SPTR
	mov	DI,P[BP]	;where to store the information
    else
	push	DS
	lds	DI,P[BP]	;where to store the information
    endif
	mov	hour[DI],CH
	mov	minutes[DI],CL
	mov	seconds[DI],DH
	mov	hseconds[DI],DL
endif
	jmp	ex1
c_endp	dos_gettime

	endcode	dosdate

	end

