;_ find.asm   Sun Jun 11 1989   Modified by: Walter Bright */
; /* OS2 support added by Nikki Locke May 1989 */
; Copyright (C) 1985-1989 by Walter Bright
; All Rights Reserved
; Written by Walter Bright

include	macros.asm

	begdata

	c_extrn	_doserrno,word

    ifdef __OS2__

	extrn	DOSFINDFIRST:far
	extrn	DOSFINDNEXT:far
	extrn	DOSFINDCLOSE:far

FindHandle	dw	-1		;file find handle
noentries	dw	1		;number of entries to find

FileFindBuf	label	byte
create_date	dw	0		;date of file creation
create_time	dw	0		;time of file creation
access_date	dw	0		;date of last access
access_time	dw	0		;time of last access
write_date	dw	0		;date of last write
write_time	dw	0		;time of last write
file_sizel	dw	0		;file size (end of data)
file_sizeh	dw	0		;file size (end of data)
falloc_size	dd	0		;file allocated size
attributes	dw	0		;attributes of the file
string_len	db	0		;returned length of ascii name str.
file_name	db	13 dup(0)	;name string

    endif ;__OS2__

FIND	label	byte		;struct used by findfirst() and findnext()
reserved	db	21 dup(0)	;reserved by DOS
attribute	db	0		;attribute found (FA_XXXX)
time		dw	0
date		dw	0		;file's time and date
sizel		dw	0		;file's size
sizeh		dw	0		;file's size
fname		db	13 dup(0)	;filename followed by 0 byte
		db	?
	enddata

	begcode	find

;;;;;;;;;;;;;;;;;;;;;;
; Find first matching file.
; Input:
;	name	Drive, path and filename of file to be found. May
;		include global filename characters.
;	attribute	Attribute of file to search for. Attributes
;		are described in the MS-DOS manual. The search strategy
;		is described under DOS call 0x11.
; Returns:
;	Pointer to a static struct FIND.
;	If error, NULL is returned and _doserrno is set to the error #.
;

	c_public findfirst
func	findfirst
	push	BP
	mov	BP,SP
    ifdef __OS2__
	mov	ax,FindHandle
	cmp	ax,-1			;is handle active ?
	jz	ff1
	push	ax			;yes - so close it
	call	DOSFINDCLOSE
	mov	FindHandle,-1
ff1:
	mov	noentries,1
    if SPTR
	push	ds			;name segment
    else
	push	P+2[BP]			;name segment
    endif
	push	P[BP]			;name offset
	push	ds
	push	offset DGROUP:FindHandle	;address of handle
	push	P+SIZEPTR[BP]			;attribute
	push	ds
	push	offset DGROUP:FileFindBuf	;address of buffer
	push	offset FIND - offset FileFindBuf	;size of buffer
	push	ds
	push	offset DGROUP:noentries		;address of number of entries
	xor	ax,ax
	push	ax
	push	ax			;reserved 0l
	call	DOSFINDFIRST
found:
	test	ax,ax
	jnz	FN1

	.if	noentries ne 1, FN3	;no matches

	mov	ax,attributes
	mov	attribute,al
	mov	ax,write_time
	mov	time,ax
	mov	ax,write_date
	mov	date,ax
	mov	ax,file_sizel
	mov	sizel,ax
	mov	ax,file_sizeh
	mov	sizeh,ax
	push	ds
	pop	es
	mov	SI,offset DGROUP:file_name
	mov	DI,offset DGROUP:fname
	mov	cx,13
	rep	movsb
	jmps	FNX
    else ;__OS2__
	mov	DX,offset DGROUP:FIND
	bdos	1Ah			;set DTA
    if LPTR
	push	DS
	mov	DS,P+2[BP]
    endif
	mov	DX,P[BP]		;DS:DX = name
	mov	CX,P+SIZEPTR[BP]	;CX = attribute
	bdos	4Eh			;find first
    if LPTR
	pop	DS
    endif
	jmps	FN2
    endif ;__OS2__
c_endp	findfirst

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Find next matching file.
; Returns:
;	pointer to static struct FIND
;	NULL if no more matching files found

	c_public findnext
func	findnext
	push	BP
	mov	BP,SP

    ifdef __OS2__
	mov	noentries,1
	push	FindHandle			;handle
	push	ds
	push	offset DGROUP:FileFindBuf		;address of buffer
	push	offset FIND - offset FileFindBuf	;size of buffer
	push	ds
	push	offset DGROUP:noentries		;address of number of entries
	call	DOSFINDNEXT
	jmp	found
    else
	mov	DX,offset DGROUP:FIND
	bdos	1Ah			;set DTA
	bdos	4Fh			;findnext
FN2:	jc	FN1			;if error
    endif
FNX:
	mov	AX,offset DGROUP:FIND	;return &FIND
    if LPTR
	mov	DX,DS
    endif
	pop	BP
	ret

FN1:	;error, return NULL
	mov	DGROUP:_doserrno,AX
FN3:	clr	AX
    if LPTR
	cwd
    endif
	pop	BP
	ret
c_endp	findnext

	endcode	find

	end

