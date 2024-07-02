;_ time2.asm   Sun Jun  4 1989   Modified by: Walter Bright */
; Copyright (C) 1987-1989 by Walter Bright
; OS2 support added by Nikki Locke May 1989
; All Rights Reserved
; Written by Walter Bright

include	macros.asm

;Offsets into struct tm (must match time.h values)
tm_sec	=	0
tm_min	=	2
tm_hour	=	4
tm_mday	=	6
tm_mon	=	8
tm_year	=	10
tm_wday	=	12
tm_yday	=	14
tm_isdst =	16

ifdef Atime2

	c_public	time
	public		__mdays

    ifdef __OS2__
	.286C
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
    endif ;__OS2__

	begdata

;/**************************
; * # of days in year at start of month
; */

__mdays	dw	0,31,31+28,31+28+31,31+28+31+30
	dw	31+28+31+30+31,31+28+31+30+31+30,31+28+31+30+31+30+31
	dw	31+28+31+30+31+30+31+31,31+28+31+30+31+30+31+31+30
	dw	31+28+31+30+31+30+31+31+30+31,31+28+31+30+31+30+31+31+30+31+30
	dw	365

	enddata

;#define SECSPERHOUR	(60*60)
;#define SECSPERDAY	(SECSPERHOUR*24L)

	begcode	time2

;/****************************************
; * Return the number of seconds that have elapsed since the start
; * of 1980.
; *	time_t time(time_t *timer);
; * Input:
; *	timer	pointer to where to store result (or NULL)
; * Output:
; *	*timer = result (unless timer == NULL)
; * Returns:
; *	time
; */

func	time
	push	BP
	mov	BP,SP

	; compute DX,AX = # of seconds since midnight
    ifdef __OS2__
	sub	sp,structsize	;reserve space for structure
	push	ss		;segment of structure
	lea	ax,hour[BP]	;offset of structure
	push	ax
	call	DOSGETDATETIME
	mov	dl,hundr[BP]
	mov	dh,second[BP]
	mov	cl,minute[BP]
	mov	ch,hour[BP]
    else ;__OS2__
	bdos	2Ch		;get time
    endif ;__OS2__
	mov	AL,CH		;hours (0..23)
	mov	BX,60
	mul	BL		;AX = hours * 60
	clr	CH		;CX = minutes
	add	AX,CX		;AX = hours * 60 + minutes	
	mov	CL,DH		;CX = seconds
	mul	BX		;DX,AX = ((hours * 60) + minutes) * 60
	;DX,AX += CX
	add	AX,CX
	adc	DL,CH		;can't overflow into DH
	push	DX
	push	AX		;save for later

    ifdef __OS2__
	mov	cx,year[BP]
	mov	dh,month[BP]
	mov	dl,day[BP]
    else ;__OS2__
	bdos	2Ah		;get date
    endif ;__OS2__
	sub	CX,1980		;CX = years since 1980

	mov	BL,DH
;	clr	BH		;BH is already 0
	dec	BX		;month (0..11)

	clr	DH		;DX = day (1..31)

;  if (month <= 1 || year & 3)	/* if before Feb or not a leap year	*/
	.if	BX be 1, L4E
	test	CL,3
	je	L51
L4E:	dec	DX		; don't add day for leap year
L51:

	shl	BX,1
	mov	BX,__mdays[BX]
	add	BX,DX		;day += __mdays[month];	(day in year)

;  day += (year + 3) >> 2;	/* add a day for each leap year		*/
	mov	AX,CX
	add	AX,3
	shr	AX,1
	shr	AX,1
	add	BX,AX

;  t = clk + ((year * 365L) + day) * SECSPERDAY;
	mov	AX,365
	mul	CX
	add	AX,BX		;AX = year * 365L + day
				;if overflow into DX, we will fail anyway
				;on multiply by SECSPERDAY
	mov	BX,AX
	mov	CX,05180h	;SECSPERDAY - 64k
	mul	CX
	add	DX,BX		;add the 64k

	pop	BX
	pop	CX		;CX,BX is # of seconds since midnight
	add	BX,AX
	adc	DX,CX		;DX,BX = CX,BX + DX,AX
	mov	AX,DX		;AX,BX holds result
	add	BX,00870h
	adc	AX,012CFh	;convert to time since 1970

	.if	<word ptr P[BP]> e 0, LAB	;if timer is NULL
	; *timer = t;
	.save	<SI>
    if SPTR
	mov	SI,P[BP]
	mov	2[SI],AX
	mov	[SI],BX
    else
	les	SI,P[BP]
	mov	ES:2[SI],AX
	mov	ES:[SI],BX
    endif
	.restore <SI>
LAB:
	mov	DX,AX
	mov	AX,BX
    ifdef __OS2__
	mov	SP,BP
    endif
	pop	BP
	ret
c_endp	time

	endcode	time2

endif ;Atime2

ifdef Autime

; variables used by utime
t		equ	-4
    ifdef __OS2__

extrn	DOSSETFILEINFO:far

; structure used by DOSSETFILEINFO - offsets into stack frame
cdate		equ	-16
ctime		equ	-14
adate		equ	-12
atime		equ	-10
wdate		equ	-8
wtime		equ	-6

structsize	equ	12
varsize		equ	16

      if LCODE
	c_extrn	open,far, close,far
      else
	c_extrn	open,near, close,near
      endif
    else ;__OS2__
varsize		equ	4
    endif ;__OS2__
	begdata

	c_extrn	errno,word

	enddata

    if LCODE
	c_extrn	time,far, localtime,far
    else
	c_extrn	time,near, localtime,near
    endif

	begcode	utime

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Set the time stamp on a file.
;	int utime(char *filespec,time_t timep[2]);
; Input:
;	filespec ->	ascii string giving the path and filename
;	timep ->	a 'last accessed' time and 'last modified' time,
;			respectively. MS-DOS has no concept of 'last
;			accessed' time, so that field is ignored, and the
;			time stamp is set to the 'last modified' time.
;			If timep is NULL, the current time is used.
; Returns:
;	0	success
;	-1	failure, errno will have a clue

	c_public utime
func	utime
	push	BP
	mov	BP,SP
	sub	SP,varsize

    if LPTR
	les	BX,P+SIZEPTR[BP]
	mov	AX,ES
	or	AX,BX
	jz	L2
	mov	AX,ES:4[BX]
	mov	DX,ES:6[BX]	;t = timep[1]; get 'last modified' time
    else
	mov	BX,P+SIZEPTR[BP]
	or	BX,BX
	jz	L2
	mov	AX,4[BX]
	mov	DX,6[BX]	;t = timep[1]; get 'last modified' time
    endif
	jmps	L3
L2:
    if LPTR
	push	BX
    endif
	push	BX		;push NULL
	callm	time
	add	SP,SIZEPTR
L3:
	mov	t[BP],AX
	mov	t+2[BP],DX

	;bd = localtime(&t);
    if LPTR
	push	SS
    endif
	lea	BX,t[BP]
	push	BX
	callm	localtime	;localtime(&t)
	add	SP,SIZEPTR

	mov	BX,AX
    if LPTR
	push	DS
	mov	DS,DX
    endif

	;date = ((((bd->tm_year - 80) << 4) + bd->tm_mon + 1) << 5) +
	;	bd->tm_mday;

	mov	AX,tm_year[BX]
	sub	AX,80
	mov	CL,4
	shl	AX,CL
	add	AX,tm_mon[BX]
	inc	AX
	inc	CL
	shl	AX,CL
	add	AX,tm_mday[BX]
    ifdef __OS2__
	mov	t[BP],AX		;date
    else
	mov	DX,AX
    endif

	;tday = (((bd->tm_hour << 6) + bd->tm_min) << 5) + (bd->tm_sec >> 1);
	mov	AX,tm_hour[BX]
	inc	CL
	shl	AX,CL
	add	AX,tm_min[BX]
	dec	CL
	shl	AX,CL
	mov	CX,tm_sec[BX]
	shr	CX,1
	add	CX,AX
    ifdef __OS2__
      if LPTR
	pop	DS
      endif
	mov	t+2[BP],CX		;time

	;fd = open(filename,O_RDWR);
	mov	AX,2			;mode = O_RDWR
	push	AX
      if LPTR
	push	P+2[BP]			;segment of file name
      endif
	push	P[BP]			;offset of file name
	callm	open
	add	SP,SIZEPTR+2		;fix stack
	.if	AX e -1, L1		;-1 = error (errno already set)

	mov	BX,AX			;handle
	mov	CX,t+2[BP]		;time
	mov	DX,t[BP]		;date

	mov	wdate[bp],dx
	mov	wtime[bp],cx
	clr	CX
	; OS2 1.1 demands that the rest of the fields be 0!
	mov	cdate[bp],CX
	mov	ctime[bp],CX
	mov	adate[bp],CX
	mov	atime[bp],CX
	push	ax			;handle
	push	1			;info level 1
	push	ss			;segment of info
	lea	ax,cdate[bp]
	push	ax			;offset of info to set
	push	structsize		;size of info buffer
	call	DOSSETFILEINFO
	test	ax,ax
	jnz	err


	push	BX			;file handle
	callm	close
	add	SP,2			;fix stack
	.if	AX e -1, L1		;-1 = error (errno already set)

    else ;__OS2__
	push	DX
	mov	DX,P[BP]
	mov	AX,03D00h		;open file for reading
    if LPTR
	mov	DS,P+2[BP]
    endif
	bdos
	pop	DX
    if LPTR
	pop	DS
    endif
	jc	err

	mov	BX,AX		;handle
;	mov	CX,tday
;	mov	DX,date
	mov	AX,05701h	;set date/time
	bdos
	jc	err

	bdos	3Eh		;close file
	jc	err
    endif ;__OS2__

	clr	AX
L1:
	mov	SP,BP
	pop	BP
	ret

err:	mov	DGROUP:errno,AX
    ifdef __OS2__
	push	BX			;file handle
	callm	close
	add	SP,2			;fix stack
    else
	bdos	3Eh		;close file
    endif
	mov	AX,-1
	jmp	L1
c_endp	utime

	endcode	utime

endif ;Autime

	end
