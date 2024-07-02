;_ io.asm   Thu Apr 21 1988   Modified by: Walter Bright */
; OS2 support added by Nikki Locke May 1989 */
;Copyright (C) 1985-1988 by Walter Bright
;All Rights Reserved
;Written by Walter Bright

	include	MACROS.ASM

    ifdef __OS2__
extrn	DOSREAD:far
extrn	DOSWRITE:far
extrn	DOSOPEN:far
extrn	DOSCLOSE:far
extrn	DOSMOVE:far
extrn	DOSDELETE:far
extrn	DOSCHGFILEPTR:far
extrn	DOSFINDFIRST:far
extrn	DOSFINDCLOSE:far
extrn	DOSQHANDTYPE:far
    endif

	begdata
	c_extrn	errno,word
	enddata

	begcode	io

	c_public read,write,open,close,creat,unlink,lseek,getDS,filesize,rename
    ifndef __OS2__
	c_public dos_creat
    endif
	c_public isatty,remove
    if SPTR
	c_public _readx,_writex
    endif

    ifdef __OS2__
;;;;;;;;;;;;;;;;;;;;;;;;;
; set up arguments fd,buffer,length for read(), write(), open() etc.
;
setargs	proc	near
	pop	dx			;return address
	push    BP
	mov     BP,SP
	sub	sp,ax			;reserve space for arguments
	push	dx			;put return address back
	mov	ax,p[bp]		;1st argument
	mov	bx,p+2[bp]
	mov	cx,p+4[bp]
	mov	dx,p+6[bp]		;4th argument
	ret
setargs	endp

;;;;;;;;;;;;;;;;;;;;;;;;;
; Read data from a file.
; Use:
;	read(fd,buffer,length)
; Returns:
;	-1	error
;	0	end of file
;	n	number of bytes actually read
;

func	read
	mov	ax,2			;reserve 2 bytes
	call	setargs
	push	ax			;fd = file handle
    if SPTR
	push	ds			;buffer segment
	push	bx			;buffer address
	push	cx			;length
    else
	push	cx			;buffer segment
	push	bx			;buffer offset
	push	dx			;length
    endif
F3:	lea	ax,[bp-2]
	push	ss
	push	ax			;save no of bytes written here
	call	DOSREAD
F2:	mov	bx,ax			;error number
	mov	ax,[bp-2]		;no of bytes written/read
	test	bx,bx
	jz	F1			;no error
	mov	errno,bx		;save DOS error number
	mov	ax,-1			;error
F1:	mov	SP,BP
	pop     BP
	ret
c_endp	read


;;;;;;;;;;;;;;;;;;;;;;;;;
; Read data from a file.
; Use:
;	_readx(fd,buffer,length,segment)
; Returns:
;	-1	error
;	0	end of file
;	n	number of bytes actually read
;

    if SPTR
func	_readx
	mov	ax,2
	call	setargs
	push	ax			;fd = file handle
	push	dx			;buffer segment
	push	bx			;buffer offset
	push	cx			;length
	jmps	F3
c_endp	_readx
    endif


;;;;;;;;;;;;;;;;;;;;;;;;;
; Write data to a file.
; Use:
;	int write(fd,buffer,length)
; Returns:
;	-1	error
;	n	number of bytes actually written
;

func	write
	mov	ax,2
	call	setargs
	push	ax			;fd = file handle
    if SPTR
	push	ds			;buffer segment
	push	bx			;buffer address
	push	cx			;length
    else
	push	cx			;buffer segment
	push	bx			;buffer offset
	push	dx			;length
    endif
F4:	lea	ax,[bp-2]
	push	ss
	push	ax			;save no of bytes written here
	call	DOSWRITE
	jmps	F2
c_endp	write

;;;;;;;;;;;;;;;;;;;;;;;;;
; Write data to a file.
; Use:
;	int _writex(fd,buffer,length,segment)
; Returns:
;	-1	error
;	n	number of bytes actually written
;

    if SPTR
func	_writex
	mov	ax,2
	call	setargs
	push	ax			;fd = file handle
	push	dx			;buffer segment
	push	bx			;buffer offset
	push	cx			;length
	jmps	F4
c_endp	_writex
    endif

;;;;;;;;;;;;;;;;;;;;;;;;;
; Return data segment.

func	getDS
	mov	AX,DS
	ret
c_endp	getDS

;;;;;;;;;;;;;;;;;;;;;;;;;
; Open a file
; Use:
;	int open(name,rwmode,crmode)
; Returns:
;	-1	error
;	fd	file handle
;

func	open
	mov	ax,4
	call	setargs
O1:
if SPTR
	push	ds			;name segment
	push	ax			;name offset
else
	push	bx			;name segment
	push	ax			;name offset
	mov	bx,cx			;rwmode in bx
	mov	cx,dx			;crmode in cx
endif
	test	bx,01f00h		;CREATE etc. bits set ?
	jz	O2
	xor	dh,dh
	mov	dl,bh			;copy CREATE etc. bits to OpenFlag
	and	dl,013h			;reset any illegal bits
	and	bh,0e0h			;remove bits from mode flag
; following lines are commented out so that PMODE argument is ignored (0)
;	test	cx,092h			;any WRITE permissions set ?
	mov	cx,0			;normal attribute
;	jnz	O4
;	inc	cx			;read only attribute
	jmp short O4
O2:
	xor	cx,cx			;attribute = 0
	mov	dx,00000001b		;open if exists, fail if not

O4:
	lea	ax,[bp-2]
	push	ss
	push	ax			;address of file handle
	dec	ax
	dec	ax
	push	ss
	push	ax			;address of action taken
	xor	ax,ax
	push	ax
	push	ax			;primary allocation = 0
	push	cx			;attribute
	push	dx			;open flag
	test	bl,1110000b
	jnz	O3
	or	bl,0010000b		;Deny Read/Write access
O3:	push	bx			;open mode
	push	ax
	push	ax			;Reserved 0l
	call	DOSOPEN
	jmp	F2
c_endp	open

;;;;;;;;;;;;;;;;;;;;;;;;;
; Create a file
; Use:
;	int creat(name,pmode)
; Returns:
;	-1	error
;	fd	file handle
;

func	creat
	mov	ax,4
	call	setargs
    if	SPTR
	mov	cx,bx			;attribute
	mov	bx,0001001000000010b	;replace if exists, create if not
    else
	mov	dx,cx			;attribute
	mov	cx,0001001000000010b	;replace if exists, create if not
    endif
	jmps	O1
c_endp	creat

;;;;;;;;;;;;;;;;;;;;;;;;;
; Close a file
; Use:
;	int close(fd)
; Returns:
;	-1	error
;	0	successful
;

func	close
	push    BP
	mov     BP,SP
	push	P[BP]			;file handle
	call	DOSCLOSE
C1:	test	ax,ax
	jz	C2
	mov	errno,ax
	mov	ax,-1
C2:
	pop	BP
	ret
c_endp	close

;;;;;;;;;;;;;;;;;;;;;;;;
; Rename a file.                J.K.H. 2/15/86
; Use:
;	int rename (from, to)
; Returns:
;       -1      error
;       0       successful
;

func	rename
	push    BP
	mov	BP,SP
if SPTR
	push	ds			;old path segment
	push	p[bp]			;old path offset
	push	ds			;new path segment
	push	p+2[bp]			;new path offset
else
	push	p+2[bp]			;old path segment
	push	p[bp]			;old path offset
	push	p+6[bp]			;new path segment
	push	p+4[bp]			;new path offset
endif
	xor	ax,ax
	push	ax
	push	ax			;Reserved 0l
	call	DOSMOVE
	jmp	C1
c_endp	rename

;;;;;;;;;;;;;;;;;;;;;;;;;
; Delete a file
; Use:
;	int unlink(name)
; Returns:
;	-1	error
;	0	successful
;

func	remove
c_endp	remove

func	unlink
	push    BP
	mov	BP,SP
if SPTR
	push	ds			;name segment
else
	push	p+2[bp]			;name segment
endif
	push	p[bp]			;name offset
	xor	ax,ax
	push	ax
	push	ax			;Reserved 0l
	call	DOSDELETE
	jmp	C1
c_endp	unlink

;;;;;;;;;;;;;;;;;;;;;;;;;
; Seek to specified file position.
; Use:
;	long lseek(int fd,long offset,int mode)
; Input:
;	mode =	SEEK_SET or SEEK_CUR or SEEK_END
; Returns:
;	-1L	error
;	n	new file position
;

func	lseek
	mov	ax,4
	call	setargs
	push	ax			;file handle
	push	cx
	push	bx			;new position
	push	dx			;mode
	lea	ax,[bp-4]
	push	ss
	push	ax			;where to put new position
	call	DOSCHGFILEPTR
	mov	bx,ax			;save error number
	mov	ax,[bp-4]
	mov	dx,[bp-2]		;new position
	test	bx,bx
	jz	L1
	mov	errno,BX		;save DOS error number
	mov	ax,-1
	cwd
L1:	mov	SP,BP
	pop     BP
	ret
c_endp	lseek

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Get and return the size of a file.
; Use:
;	long filesize(filename)
;	char *filename;
; Returns:
;	-1L	error

func	filesize
	push	BP
	mov	BP,SP
	sub	SP,40		;36 bytes for FileFindBuf
	mov	word ptr [bp-4],1	;no of entries to find
	mov	[bp-2],0ffffh	;dir handle
if SPTR
	push	ds		;name segment
else
	push	p+2[bp]		;name segment
endif
	push	p[bp]		;name offset
	lea	ax,[bp-2]
	push	ss
	push	ax		;address of dir handle
	push	6		;find all normal files, plus system and hidden
	lea	bx,[bp-40]	;FileFindBuf
	push	ss
	push	bx
	push	36		;buffer length
	push	ss
	dec	ax
	dec	ax
	push	ax		;address of search count
	xor	ax,ax
	push	ax
	push	ax		;reserved 0l
	call	DOSFINDFIRST
	push	ax		;save error code
	mov	ax,[bp-2]
	push	ax		;directory handle
	call	DOSFINDCLOSE
	pop	bx		;get back previous error code
	mov	ax,[bp-40+12]
	mov	dx,[bp-40+14]	;file size
	test	bx,bx
	jz	S1		;error
	mov	errno,bx
	mov	ax,-1
	cwd			;error return = -1l
S1:	mov	SP,BP
	pop	BP
	ret

c_endp	filesize

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Determine if handle is a tty.
; Use:
;	int isatty(int fd)
; Returns:
;	!=0	character device
;	0	not a character device or error

func	isatty

	push	BP
	mov	BP,SP
	sub	SP,4
	push	p[bp]		;file handle
	lea	ax,[bp-4]
	push	ss
	push	ax		;address of handle type
	inc	ax
	inc	ax
	push	ss
	push	ax		;address of FlagWord
	call	DOSQHANDTYPE
	test	ax,ax
	jz	F9		;error
	mov	errno,ax
	xor	ax,ax
	jmps	F8

F9:	mov	bx,[bp-4]
	cmp	bx,1
	jnz	F8		;not a tty
	test	ax,00000011b
	jnz	F8		;not screen or keyboard
	inc	ax		;now ax = 1
F8:	mov	SP,BP
	pop	BP
	ret
c_endp	isatty

    else ;__OS2__
;;;;;;;;;;;;;;;;;;;;;;;;;
; Read data from a file.
; Use:
;	read(fd,buffer,length)
; Returns:
;	-1	error
;	0	end of file
;	n	number of bytes actually read
;

func	read
	mov	AH,3Fh			;read from file or device
F4:	push    BP
	mov     BP,SP
	mov	BX,P[BP]		;BX = fd (file handle)
    if SPTR
	mov	DX,P+2[BP]		;DX = buffer address
	mov	CX,P+2+SIZEPTR[BP]	;CX = number of bytes to read/write
	bdos				;read/write from/to file or device
    else
	push	DS
	lds	DX,P+2[BP]		;DS:DX = buffer address
	mov	CX,P+2+SIZEPTR[BP]	;CX = number of bytes to read
	bdos				;read from file or device
	pop	DS
    endif
F2:	jnc	F1			;no error
	mov	errno,AX		;save DOS error number
	sbb	AX,AX			;error
F1:	pop     BP
	ret
c_endp	read


;;;;;;;;;;;;;;;;;;;;;;;;;
; Read data from a file.
; Use:
;	_readx(fd,buffer,length,segment)
; Returns:
;	-1	error
;	0	end of file
;	n	number of bytes actually read
;

    if SPTR
func	_readx
	mov	AH,3Fh			;read from file or device
F3:	push    BP
	mov     BP,SP
	mov	BX,P[BP]		;BX = fd (file handle)
	mov	DX,P+2[BP]		;DX = buffer address
	mov	CX,P+4[BP]		;CX = number of bytes to read/write
	push	DS
	mov	DS,P+6[BP]		;DS = segment of buffer
	bdos				;read/write from file or device
	pop	DS
	jmps	F2
c_endp	_readx
    endif


;;;;;;;;;;;;;;;;;;;;;;;;;
; Write data to a file.
; Use:
;	int write(fd,buffer,length)
; Returns:
;	-1	error
;	n	number of bytes actually written
;

func	write
	mov	AH,40h			;write to file or device
	jmps	F4
c_endp	write

;;;;;;;;;;;;;;;;;;;;;;;;;
; Write data to a file.
; Use:
;	int _writex(fd,buffer,length,segment)
; Returns:
;	-1	error
;	n	number of bytes actually written
;

    if SPTR
func	_writex
	mov	AH,40h			;write to file or device
	jmps	F3
c_endp	_writex
    endif

;;;;;;;;;;;;;;;;;;;;;;;;;
; Return data segment.

func	getDS
	mov	AX,DS
	ret
c_endp	getDS

;;;;;;;;;;;;;;;;;;;;;;;;;
; Open a file
; Use:
;	int open(name,rwmode)
; Returns:
;	-1	error
;	fd	file handle
;

func	open
	push    BP
	mov     BP,SP
	mov	AH,3Dh			;open file
	mov	AL,P+SIZEPTR[BP]	;AL = rwmode (0,1,2)
OPEN1:
    if SPTR
	mov	DX,P[BP]		;DX -> name
	bdos
    else
	push	DS
	lds	DX,P[BP]		;DS:DX -> name
	bdos
	pop	DS
    endif
	jmp	F2
c_endp	open

;;;;;;;;;;;;;;;;;;;;;;;;;
; Create a file
; Use:
;	int creat(name,pmode)
; Returns:
;	-1	error
;	fd	file handle
;

func	creat
	push    BP
	mov     BP,SP
	clr	CX			;always ignore file attribute
	jmps	creat1
c_endp	creat

func	dos_creat
	push    BP
	mov     BP,SP
	mov	CX,P+SIZEPTR[BP]	;CX = file attribute
creat1:
	mov	AH,3Ch			;create file
    if SPTR
	mov	DX,P[BP]		;DX -> name
	bdos
    else
	push	DS
	lds	DX,P[BP]		;DS:DX -> name
	bdos
	pop	DS
    endif
	jnc	creat4			;no error
	mov	errno,AX		;save DOS error number
	sbb	AX,AX			;error
creat4:	pop	bp
	ret
c_endp	dos_creat

;;;;;;;;;;;;;;;;;;;;;;;;;
; Close a file
; Use:
;	int close(fd)
; Returns:
;	-1	error
;	0	successful
;

func	close
	push    BP
	mov     BP,SP
	mov	BX,P[BP]		;file handle
	bdos	3Eh			;write to file or device
	jmp	U2
c_endp	close

;;;;;;;;;;;;;;;;;;;;;;;;
; Rename a file.                J.K.H. 2/15/86
; Use:
;	int rename (from, to)
; Returns:
;       -1      error
;       0       successful
;

func	rename
	push    BP
	mov	BP,SP
	.save	DI
	mov	AH,56h			;DOS rename function
    if SPTR
      ife ESeqDS
	mov	BX,DS
	mov	ES,BX
      endif
        mov     DI,P+SIZEPTR[bp]        ;The new name.
    else    ;LPTR
        les     DI,P+SIZEPTR[bp]        ;The new name.
    endif
	jmps	U1
c_endp	rename

;;;;;;;;;;;;;;;;;;;;;;;;;
; Delete a file
; Use:
;	int remove(char *name)
; Returns:
;	-1	error
;	0	successful
;

func	remove
c_endp	remove

func	unlink
	push    BP
	mov     BP,SP
	.save	DI
	mov	AH,41h			;delete file function
U1:
    if SPTR
	mov	DX,P[BP]		;DX -> name
	bdos
    else
	push	DS
	lds	DX,P[BP]		;DS:DX -> name
	bdos
	pop	DS
    endif
	.restore DI
U2:	pop	BP
	jnc	L7			;no error
L8:	mov	errno,AX
L7:	sbb	AX,AX			;-1 if C, 0 if not
	ret
c_endp	unlink

;;;;;;;;;;;;;;;;;;;;;;;;;
; Seek to specified file position.
; Use:
;	long lseek(int fd,long offset,int mode)
; Input:
;	mode =	SEEK_SET or SEEK_CUR or SEEK_END
; Returns:
;	-1L	error
;	n	new file position
;

func	lseek
	push    BP
	mov     BP,SP
	mov	BX,P[BP]		;file handle
	mov	DX,P+2[BP]		;lsw of offset
	mov	CX,P+4[BP]		;msw of offset
	mov	AL,P+6[BP]		;mode (0,1,2)
	bdos	42h			;write to file or device
	jnc	L9			;no error
	mov	errno,AX		;save DOS error number
	sbb	AX,AX			;AX = -1
	cwd				;DX = -1
L9:	pop     BP
	ret
c_endp	lseek

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Get and return the size of a file.
; Use:
;	long filesize(filename)
;	char *filename;
; Returns:
;	-1L	error

func	filesize
	push	BP
	push	DS
	sub	SP,44		;44 bytes for DTA
	mov	BP,SP

	;Set DTA to the 44 bytes on the stack (SS:BP)
    if LPTR
	push	SS
	pop	DS
    endif
	mov	DX,BP		;DS:DX is DTA
	bdos	1Ah		;set DTA

	;Find first matching file
    if SPTR
	mov	DX,44+2+P[BP]
    else
	lds	DX,44+2+P[BP]
    endif
	mov	CX,6		;find all normal files, plus system and hidden
	bdos	4Eh		;findfirst (DS:DX -> filename)
	jc	L11		;no error

	;Load file size from DTA
	mov	DX,28[BP]
	mov	AX,26[BP]

L12:	add	SP,44
	pop	DS
	pop	BP
	ret

L11:
    if LPTR
	mov	DS,44[BP]	;restore DS
    endif
	mov	errno,AX	;remember error code
	sbb	AX,AX
	cwd			;return -1L on error
	jmp	L12
c_endp	filesize

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Determine if handle is a tty.
; Use:
;	int isatty(fd)
;	int fd;
; Returns:
;	!=0	character device
;	0	not a character device or error

func	isatty
	mov	BX,SP
    if SPTR
	mov	BX,P-2[BX]	;get fd (file handle)
    else
	mov	BX,SS:P-2[BX]	;get fd (file handle)
    endif
	mov	AX,04400h	;get device information
	bdos			;IOCTL
	cmc
	jnc	I4		;error

	;If sign bit is set in DL, it is a character device.
	mov	AL,DL
	cbw			;AH = 0FFh if char dev, else 0
	mov	AL,AH
	ret
c_endp	isatty

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	#include <io.h>
;	int access(char *path,int mode);
; Synopsis:
;	Test file for existence and it's access bits. The access bits are:
;	#define F_OK	0	/* does file exist?	*/
;	#define X_OK	1	/* execute permission?	*/
;	#define W_OK	2	/* write permission?	*/
;	#define R_OK	4	/* read permission?	*/
;	OR these values together to test a combination.
; Bugs:
;	Since MS-DOS only records a write permission bit, the X_OK and
;	R_OK access permissions always succeed. They are included here
;	for unix compatibility.
; Returns:
;	0	file exists and access mode is granted
;	-1	otherwise and errno is set

	c_public access
func	access
	mov	BX,SP
	mov	AX,4300h	;get file's attribute
    if LPTR
	push	DS
	lds	DX,SS:P-2[BX]	;DS:DX = path
	bdos
	pop	DS
	jc	I4
	test	byte ptr SS:P+SIZEPTR-2[BX],2	;is W_OK set?
    else
	mov	DX,P-2[BX]	;DS:DX = path
	bdos
	jc	I4
	test	byte ptr P+SIZEPTR-2[BX],2	;is W_OK set?
    endif
	jz	L7				;no
	shr	CL,1		;is file read-only?
	jnc	L7		;no
	mov	AX,5		;EACCES
I4:	jmp	L8
c_endp	access

    endif ;__OS2__

	endcode	io

	end
