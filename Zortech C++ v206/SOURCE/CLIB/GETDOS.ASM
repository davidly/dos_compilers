;_ getdos.asm   Mon Jun 12 1989   Modified by: Walter Bright */
; $Header$
;Copyright (C) 1984-1989 by Walter Bright
;All rights reserved.
;Written by Walter Bright

include	macros.asm

	begdata
	c_extrn	errno,word
    ifdef __OS2__
	extchar		db	0	;extended character waiting
	EDOM		equ	1002

	CharData	label	byte
	CharCode	db	?
	ScanCode	db	?
	Status		db	?
	NLSShift	db	?
	ShiftState	dw	?
	TimeStamp	dd	?

	FSInfoBuf	label	byte
	FSID		dd	?
	SecsPerCluster	dd	?
	NoOfClusters	dd	?
	AvailClusters	dd	?
	BytesPerSector	dw	?

	FileHandle	dw	?
	Action		dw	?
	NewPos		dd	?

    endif
	enddata

    if LCODE
	c_extrn	_flushterm,far
    else
	c_extrn	_flushterm,near
    endif

    ifdef __OS2__

    if LCODE
	c_extrn	_LMUL@,far
    else
	c_extrn	_LMUL@,near
    endif

	extrn	KBDCHARIN:far
	extrn	KBDPEEK:far
	extrn	VIOWRTTTY:far
	extrn	DOSSETVERIFY:far
	extrn	DOSQVERIFY:far
	extrn	DOSQFSINFO:far
	extrn	DOSOPEN:far
	extrn	DOSCLOSE:far
	extrn	DOSREAD:far
	extrn	DOSWRITE:far
	extrn	DOSCHGFILEPTR:far
	extrn	DOSCHDIR:far
	extrn	DOSMKDIR:far
	extrn	DOSRMDIR:far
    endif

	begcode	getdos

	c_public dos_set_verify,dos_get_verify
	c_public dos_set_ctrl_break,dos_get_ctrl_break
	c_public dos_getdiskfreespace
	c_public dos_abs_disk_read,dos_abs_disk_write
	c_public kbhit,getch,getche
	c_public mkdir,rmdir,chdir

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Return 1 if key is available from console, else 0

func	kbhit
    ifdef __OS2__
	cmp	extchar,0
	jnz	kbhok
	push	ds
	push	offset DGROUP:CharData
	push	0		;KbdHandle
	call	KBDPEEK
	test	ax,ax
	mov	ax,0
	jnz	kbhret		;error peeking keyboard
	mov	bl,Status
	and	bl,011000000b	;bits 6 or 7 set if character returned
	jz	kbhret
kbhok:
	mov	ax,1
    else
	bdos	0Bh	;check standard input status
	cbw		;clear AX is now 0 or -1
	neg	AX	;0 or 1
    endif
kbhret:
	ret
c_endp	kbhit

;;;;;;;;;;;;;;;;;;;;;;;;;
; Get character from keyboard, don't echo it.

func	getch
    ifdef __OS2__
	mov	al,extchar
	test	al,al
	jz	gch1
	mov	extchar,0
	xor	ah,ah
	jmp short gchret

gch1:	push	ds
	push	offset DGROUP:CharData
	xor	ax,ax
	push	ax		;wait for character
	push	ax		;KbdHandle
	call	KBDCHARIN
	test	ax,ax
	mov	ax,-1
	jnz	gchret		;error reading keyboard
	mov	al,CharCode
	xor	ah,ah
	test	al,al
	jz	gchext		;extended character
	cmp	al,224		;extra cursor pad ?
	jnz	gchret
gchext:
	mov	bh,ScanCode
	mov	extchar,bh	;save extended char for later
gchret:
	ret
    else
	call	_flushterm
	mov	AH,8			;get char from kbd, no echo
	jmp short G1
    endif
c_endp	getch

;;;;;;;;;;;;;;;;;;;;;;;;;
; Get character from keyboard, echo it.

func	getche
	call	_flushterm
    ifdef __OS2__
	call	_getch
	test	ax,ax
	js	gceret		;error reading keyboard
	push	ax		;save character for later
	mov	ax,sp		;pointer to it
	push	ss
	push	ax		;string to print
	push	1		;Length to print
	push	0		;VioHandle
	call	VIOWRTTTY
	pop	ax		;get back character
    else
	mov	AH,1
G1:	bdos			;get char from kbd, echo it
    endif
	clr	AH
gceret:
	ret
c_endp	getche

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Set/reset verify switch for disk writes.
; Use:
;	dos_set_verify(TRUE);	/* turn on verify	*/
;	dos_set_verify(FALSE);	/* turn off verify	*/

func	dos_set_verify
	push	BP
	mov	BP,SP
    ifdef __OS2__
	mov	ax,P[bp]
	push	ax
	call	DOSSETVERIFY
    else
	mov	AL,P[BP]	;get verify flag
	clr	DL		;must be 0 for some reason
	bdos	2Eh
    endif
	pop	BP
	ret
c_endp	dos_set_verify

;;;;;;;;;;;;;;;;;;;;;;;;;
; Get disk verify state.
; Returns:
;	TRUE if disk verify is on

func	dos_get_verify
    ifdef __OS2__
	push	ax		;place to put verify setting
	mov	ax,sp		;pointer to it
	push	ss
	push	ax
	call	DOSQVERIFY
	pop	ax		;get back verify setting
    else
	bdos	54h
	cbw			;clear AH
    endif
	ret
c_endp	dos_get_verify

;;;;;;;;;;;;;;;;;;;;;;;;
; Set/reset Ctrl-Break check.
; Use:
;	dos_set_ctrl_break(TRUE);	/* turn on cntrl-break check	*/
;	dos_set_ctrl_break(FALSE);	/* turn off cntrl-break check	*/

func	dos_set_ctrl_break
	push	BP
	mov	BP,SP
    ifdef __OS2__
	mov	ax,P[bp]
	dec	ax		;can't turn ctrl-break off, so return error
	neg	ax
    else
	mov	DX,P[BP]
	mov	AL,1
	bdos	33h
    endif
	pop	BP
	ret
c_endp	dos_set_ctrl_break

;;;;;;;;;;;;;;;;;;;;;;;;;
; Get state of Ctrl-Break checking.
; Returns:
;	TRUE	on
;	FALSE	off

func	dos_get_ctrl_break
    ifdef __OS2__
	mov	ax,1		;always on under OS/2
    else
	mov	AX,03300h
	bdos
	mov	AL,DL
	cbw			;clear	AH
    endif
	ret
c_endp	dos_get_ctrl_break

;;;;;;;;;;;;;;;;;;;;;;;;;
; Get disk free space in bytes.
; Use:
;	long = dos_getdiskfreespace(drive);
; Input:
;	drive == 0:	default drive
;	drive == 1:	drive = A:, etc.
; Returns:
;	a long
;	-1L if drive was invalid

func	dos_getdiskfreespace
	push	BP
	mov	BP,SP
    ifdef __OS2__
	mov	ax,P[bp]	;drive
	call	getfsinfo
	test	ax,ax
	jz	gdf1
	mov	ax,-1
	cwd
	pop	bp
	ret			;return -1l on error
gdf1:
	mov	ax,word ptr SecsPerCluster
	mov	dx,word ptr (SecsPerCluster + 2)
	mov	bx,word ptr AvailClusters
	mov	cx,word ptr (AvailClusters + 2)
	call	_LMUL@		;multiply to get Available Sectors
	mov	bx,BytesPerSector
	xor	cx,cx
	call	_LMUL@		;multiply to get Available Bytes
    else
	mov	DX,P[BP]	;DL = drive
	bdos	36h
	.if	AX ne -1, L1
	cwd
	pop	BP
	ret			;return -1L

	;Compute DX,AX = AX*BX*CX
L1:
	mul	BX
	mov	BX,DX
	mul	CX
	add	DX,BX
    endif
	pop	BP
	ret
c_endp	dos_getdiskfreespace

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Absolute disk read.
;	int dos_abs_disk_read(drive,numsec,startsec,buffer)
;	int drive;	/* drive number 0=A, 1=B, ...			*/
;	int numsec;	/* number of sectors to read			*/
;	int startsec;	/* starting logical sector number		*/
;	char *buffer;	/* where the result will be stored		*/
; Returns:
;	0		/* success					*/
;	!= 0		/* failure (the value is what is described in	*/
;			/* the DOS manual)				*/

func	dos_abs_disk_read
    ifdef __OS2__
	push	BP
	mov	BP,SP
	mov	ax,P[bp]	;drive number
	inc	ax		;0 is default drive in getfsinfo
	call	getfsinfo
	test	ax,ax
	jnz	adrret		;return error code
	mov	al,P[bp]
	mov	bx,01010000011000000b	;DASD,No inherit,Return errors,
				;Deny none,Read Only
	call	opendrive	;open drive for absolute read
	test	ax,ax
	jnz	adrret		;return error code
	mov	ax,P+4[bp]	;startsec
	call	seekdrive
	test	ax,ax
	jnz	adrclr		;close drive and return error code
	mov	ax,P+2[bp]	;numsec
	mov	bx,BytesPerSector
	mul	bx		;ax = no of bytes requested
	push	ax		;save for later
	push	FileHandle
    if SPTR
	push	ds		;segment of buffer
    else
	push	P+8[bp]		;segment of buffer
    endif
	push	P+6[bp]		;offset of buffer
	push	ax		;bytes requested
	push	ds
	push	offset DGROUP:Action	;pointer to no of bytes read return
	call	DOSREAD
	pop	bx		;restore no of bytes requested
	test	ax,ax
	jnz	adrclr
	cmp	bx,Action	;all bytes read ?
	jz	adrclr
	mov	ax,EDOM		;our own error code
adrclr:
	push	ax		;save return code
	push	FileHandle
	call	DOSCLOSE
	pop	ax		;get back return code

    else
	mov	AH,1
A4:	push	BP
	mov	BP,SP
	.save	<SI,DI>
	mov	AL,P[BP]	;drive
	mov	CX,P+2[BP]	;numsec
	mov	DX,P+4[BP]	;startsec
    if SPTR
	mov	BX,P+6[BP]	;buffer
    else
	push	DS
	lds	BX,P+6[BP]	;buffer
    endif
	tst	AH		;do read or write?
	jz	A3
	int	25h		;read
	jmps	A2

A3:	int	26h		;write
A2:	jc	A1		;error (AX has error code)
	clr	AX		;no error
A1:	popf			;clean stack
    if LPTR
	pop	DS
    endif
	.restore <DI,SI>
    endif
adrret:
	pop	BP
	ret
c_endp	dos_abs_disk_read

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Absolute disk write.
;	int dos_abs_disk_write(drive,numsec,startsec,buffer)
;	int drive;	/* drive number 0=A, 1=B, ...			*/
;	int numsec;	/* number of sectors to write			*/
;	int startsec;	/* starting logical sector number		*/
;	char *buffer;	/* where the result will be read from		*/
; Returns:
;	0		/* success					*/
;	!= 0		/* failure (the value is what is described in	*/
;			/* the DOS manual)				*/

func	dos_abs_disk_write
    ifdef __OS2__
	push	BP
	mov	BP,SP
	mov	ax,P[bp]	;drive number
	inc	ax		;0 is default drive in getfsinfo
	call	getfsinfo
	test	ax,ax
	jnz	adrret		;return error code
	mov	al,P[bp]
	mov	bx,01010000011000001b	;DASD,No inherit,Return errors,
				;Deny none,Write Only
	call	opendrive	;open drive for absolute write
	test	ax,ax
	jnz	adwret		;return error code
	mov	ax,P+4[bp]	;startsec
	call	seekdrive
	test	ax,ax
	jnz	adwclr		;close drive and return error code
	mov	ax,P+2[bp]	;numsec
	mov	bx,BytesPerSector
	mul	bx		;ax = no of bytes requested
	push	ax		;save for later
	push	FileHandle
    if SPTR
	push	ds		;segment of buffer
    else
	push	P+8[bp]		;segment of buffer
    endif
	push	P+6[bp]		;offset of buffer
	push	ax		;bytes requested
	push	ds
	push	offset DGROUP:Action	;pointer to no of bytes written return
	call	DOSWRITE
	pop	bx		;restore no of bytes requested
	test	ax,ax
	jnz	adwclr
	cmp	bx,Action	;all bytes written ?
	jz	adwclr
	mov	ax,EDOM		;our own error code
adwclr:
	push	ax		;save return code
	push	FileHandle
	call	DOSCLOSE
	pop	ax		;get back return code
adwret:
	pop	BP
	ret
    else
	clr	AH
	jmp	A4		;use common code
    endif
c_endp	dos_abs_disk_write


    ifdef __OS2__
opendrive	proc	near
	add	al,'A'		;drive letter
	mov	ah,':'
	xor	bx,bx
	push	bx
	push	ax		;push string "D:\0" onto stack
	mov	ax,sp		;take its address
	push	ss
	push	ax
	push	ds
	push	offset DGROUP:FileHandle
	push	ds
	push	offset DGROUP:Action
	xor	ax,ax
	push	ax
	push	ax		;initial allocation
	push	ax		;attribute
	push	1		;open if exists, fail otherwise
	push	bx		;Open Mode
	push	ax
	push	ax		;reserved 0l
	call	DOSOPEN
	pop	bx
	pop	bx		;remove file name string from stack
	ret
opendrive	endp

seekdrive	proc	near
	mov	bx,BytesPerSector
	mul	bx		;dx:ax = start position
	push	ax
	push	dx		;save for later
	push	FileHandle
	push	ax
	push	dx		;seek position
	push	0		;from start of file
	push	ds		;where to put final position
	push	offset DGROUP:NewPos
	call	DOSCHGFILEPTR
	pop	cx
	pop	bx		;restore requested position
	test	ax,ax
	jnz	skdret		;return error code
	mov	ax,EDOM		;our error code
	cmp	bx,word ptr NewPos
	jnz	skdret
	cmp	cx,word ptr (NewPos + 2)
	jnz	skdret
	xor	ax,ax		;no error
skdret:
	ret
seekdrive	endp

getfsinfo	proc	near
	push	ax		;drive number
	push	1		;Level 1 info required
	push	ds
	push	offset DGROUP:FSInfoBuf
	push	18		;sizeof(FSInfoBuf)
	call	DOSQFSINFO
	ret
getfsinfo	endp
    endif


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Change directory to that specified by pathname.
; Usage:
;	int chdir(char *pathname);
; Returns:
;	0	success
;	-1	failure (errno is set to ENOENT)

func	chdir
    ifdef __OS2__
	push	bp
	mov	bp,sp
    if SPTR
	push	ds		;segment of pathname
    else
	push	P+2[bp]		;segment of pathname
    endif
	push	P[bp]		;offset of pathname
	xor	ax,ax
	push	ax
	push	ax		;reserved 0l
	call	DOSCHDIR
C1:	test	ax,ax
	jz	chdret
	mov	errno,ax
	mov	ax,-1
chdret:

    else
	mov	AH,03Bh

_dodir:	push	BP
	mov	BP,SP
    if SPTR
	mov	DX,P[BP]
	bdos
    else
	push	DS
	lds	DX,P[BP]
	bdos
	pop	DS
    endif
	jnc	D1		;no error
	mov	errno,AX
D1:	sbb	AX,AX
    endif
	pop	BP
	ret
c_endp	chdir

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Create subdirectory given by pathname.
; Usage:
;	int mkdir(char *pathname);
; Returns:
;	0	success
;	-1	failure, in which case errno is set to:
;	    ENOENT:	path not found
;	    EACCES:	access denied

func	mkdir
    ifdef __OS2__
	push	bp
	mov	bp,sp
    if SPTR
	push	ds		;segment of pathname
    else
	push	P+2[bp]		;segment of pathname
    endif
	push	P[bp]		;offset of pathname
	xor	ax,ax
	push	ax
	push	ax		;reserved 0l
	call	DOSMKDIR
	jmp	C1
    else
	mov	AH,039h
	jmp	_dodir
    endif
c_endp	mkdir

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Remove subdirectory given by pathname.
; Usage:
;	int rmdir(char *pathname);
; Returns:
;	0	success
;	-1	failure, in which case errno is set to:
;	    ENOENT:	path not found
;	    EACCES:	access denied or directory is not empty

func	rmdir
    ifdef __OS2__
	push	bp
	mov	bp,sp
    if SPTR
	push	ds		;segment of pathname
    else
	push	P+2[bp]		;segment of pathname
    endif
	push	P[bp]		;offset of pathname
	xor	ax,ax
	push	ax
	push	ax		;reserved 0l
	call	DOSRMDIR
	jmp	C1
    else
	mov	AH,03Ah
	jmp	_dodir
    endif
c_endp	rmdir

	endcode	getdos

	end

