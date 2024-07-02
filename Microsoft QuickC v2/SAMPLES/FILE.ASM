	.MODEL small, c
	INCLUDE demo.inc
	.CODE


;* ReadCharAttr - Reads character and display attribute at cursor location.
;*
;* Shows:   BIOS Interrupt - 10h, Function 8 (Read Character and Attribute
;*			     at Cursor)
;*
;* Uses:    vconfig - Video configuration structure, declared in the
;*	    DEMO.INC include file. The structure must first be
;*	    initialized by calling the GetVidConfig procedure.
;*
;* Params:  attr - Pointer to short integer for display attribute
;*
;* Return:  Short integer with ASCII value of character

ReadCharAttr PROC \
	USES di, \
	attr:PTR WORD

	mov	ah, 8			; Function 8
	mov	bh, vconfig.dpage	; Current page
	int	10h			; Read Character and Attribute
	sub	bh, bh
	mov	bl, ah			; BX = attribute
	cbw				; AX = character
	LoadPtr es, di, attr		; ES:DI = pointer to int
	mov	es:[di], bx		; Copy attribute
	ret

ReadCharAttr ENDP


;* CopyFile - Copies a file from a specified directory to another. Allows
;* two different copy methods. See the OpenFile, CloseFile, ReadFile, and
;* WriteFile procedures for specific examples on opening, closing, reading
;* from, and writing to files.
;*
;* Shows:   DOS Functions - 3Ch (Create File)
;*			    5Bh (Create New File)
;*	    Instruction - clc
;*
;* Params:  imode  - 0 = Create new target file or overwrite existing file
;*		     1 = Abort and return error code if target file already
;*			 exists (only for DOS versions 3.0 and higher)
;*	    fspec1 - Pointer to ASCIIZ source file specification
;*	    fspec2 - Pointer to ASCIIZ target file specification
;*
;* Return:  Short integer with error code
;*	    0 if successful
;*	    1 if error

	.DATA
buffer	DB	BUFFER_SIZE DUP(?)	; Buffer for diskette read

	.CODE
	EXTRN GetVer:PROC

CopyFile PROC \
	USES ds si di, \
	imode:WORD, fspec1:PTR BYTE, fspec2:PTR BYTE

	LOCAL eof_flag:BYTE

; Open source file for read only

	LoadPtr ds, dx, fspec1		; Point DS:DX to source file
	mov	ax, 3D00h		; AH = function #, AL = access code
	int	21h			; Open File (for read only)
	jc	e_exit
	mov	si, ax			; SI = file handle for source

; Open target file according to copy mode

	LoadPtr ds, dx, fspec2		; Point DS:DX to target file
	cmp	imode, 1		; Determine DOS function
	je	check			; Imode = 1?
	mov	ah, 3Ch 		; No?  Request Create File
	jmp	SHORT set		;   (destroy existing)
check:	call	GetVer			; Yes?	First check DOS version
	cmp	ax, 300 		; 3.0 or higher?
	jb	close			; No?  Abort with error code
	mov	ah, 5Bh 		; Request Create New File

set:	sub	cx, cx			; Normal attribute for target
	int	21h			; DOS function for target file
	jc	close			; If open error, abort
	mov	di, ax			; DI = file handle for target

; Both files successfully opened. Now read from source and copy to target.

	mov	ax, @data
	mov	ds, ax			; DS:DX = buffer. Read/write
	mov	dx, OFFSET buffer	;   to and from here.
	mov	eof_flag, 0		; Initialize end-of-file flag
loop1:	mov	bx, si			; Handle for source file
	mov	cx, BUFFER_SIZE 	; CX = number of bytes to read
	mov	ah, 3Fh 		; Request DOS read
	int	21h			; Read from File
	jc	close			; If error, exit
	cmp	ax, cx			; All bytes read successfully?
	je	@F			; Yes?	Continue
	inc	eof_flag		; No?  Raise flag
@@:	mov	bx, di			; Handle for target file
	mov	cx, ax			; Write number of bytes read
	mov	ah, 40h 		; Request DOS write
	int	21h			; Write from buffer to target file
	jc	close			; If error, exit
	cmp	eof_flag, 0		; Finished?
	je	loop1			; No?  Loop to read next block
	clc				; Yes?	Clear CY to indicate
					;   success
close:	pushf				; Preserve flags while closing
	mov	bx, di			; Handle for target file
	mov	ah, 3Eh 		; Request DOS Function 3Eh
	int	21h			; Close File
	sub	ax, ax			; Clear error code
	popf				; Recover flags
	jnc	exit			; If successful, exit

e_exit: mov	ax, 1			; Else set error code
exit:	ret

CopyFile ENDP


;* ChangeDrive - Changes default drive.
;*
;* Shows:   DOS Function - 0Eh (Select Disk)
;*
;* Params:  drive - Uppercase letter designation for new drive
;*
;* Return:  None

ChangeDrive PROC \
	drive:WORD

	mov	ah, 0Eh 		; DOS Function 0Eh
	mov	dx, drive		; Drive designation in DL,
	sub	dl, 'A' 		;   0=A, 1=B, 2=C, etc
	int	21h			; Select Disk
	ret

ChangeDrive ENDP


;* GetCurDisk - Gets designation of current disk.
;*
;* Shows:   DOS Function - 19h (Get Current Disk)
;*	    Instruction - cbw
;*
;* Params:  None
;*
;* Return:  Short integer with drive designation
;*	    0 = A, 1 = B, 2 = C, etc.

GetCurDisk PROC

	mov	ah, 19h 		; DOS Function 19h
	int	21h			; Get Current Disk
	cbw				; AX = drive designation
	ret

GetCurDisk ENDP


;* SetDTA - Sets address for new Disk Transfer Area.
;*
;* Shows:   DOS Function - 1Ah (Set DTA Address)
;*
;* Params:  dta - Far pointer to new transfer address
;*
;* Return:  None

SetDTA	PROC \
	USES ds, \
	dta:FAR PTR BYTE

	lds	dx, [dta]		; Point DS:DX to DTA
	mov	ah, 1Ah 		; DOS Function 1Ah
	int	21h			; Set DTA Address
	ret

SetDTA	ENDP


;* GetDTA - Gets address of current Disk Transfer Area.
;*
;* Shows:   DOS Function - 2Fh (Get DTA Address)
;*
;* Params:  dta - Far pointer to receive transfer address
;*
;* Return:  None

GetDTA	PROC \
	dta:FAR PTR BYTE

	mov	ah, 2Fh 		; DOS Function 2Fh
	int	21h			; Get DTA Address in ES:BX
	mov	ax, es			; Save DTA segment
	mov	dx, bx			; Save DTA offset
	les	bx, dta 		; Now ES:BX points to variable
	mov	es:[bx], dx		; Copy DTA address to
	mov	es:[bx+2], ax		;   dta variable
	ret

GetDTA	ENDP


;* CreateFile - Creates file with specified attribute.
;*
;* Shows:   DOS Function - 3Ch (Create File)
;*
;* Params:  attr - Attribute code:  0 = normal	      8 = volume label
;*				    1 = read only    16 = subdirectory
;*				    2 = hidden	     32 = archive
;*				    4 = system
;*	    fspec - Pointer to ASCIIZ file specification
;*
;* Return:  Short integer with file handle or -1 for error

CreateFile PROC \
	USES ds, \
	attr:WORD, fspec:PTR BYTE

	LoadPtr ds, dx, fspec		; Point DS:DX to file spec
	mov	cx, attr		; CX = attribute
	mov	ah, 3Ch 		; AH = function number
	int	21h			; Create file
	jnc	exit			; If ok, return AX = handle
	mov	ax, -1			; Else set error code
exit:	ret

CreateFile ENDP


;* OpenFile - Opens specified file for reading or writing. See the CopyFile
;* procedure for another example of using DOS Function 3Dh to open files.
;*
;* Shows:   DOS Function - 3Dh (Open File)
;*
;* Params:  access - Access code:  0 = read    1 = write    2 = read/write
;*	    fspec - Pointer to ASCIIZ file specification
;*
;* Return:  Short integer with file handle or -1 for error

OpenFile PROC \
	USES ds, \
	access:WORD, fspec:PTR BYTE

	LoadPtr ds, dx, fspec		; Point DS:DX to file spec
	mov	ax, access		; AL = access code
	mov	ah, 3Dh 		; AH = function number
	int	21h			; Open file
	jnc	exit			; If ok, return AX = handle
	mov	ax, -1			; Else set error code
exit:	ret

OpenFile ENDP


;* CloseFile - Closes an open file, specified by handle. See the CopyFile
;* procedure for another example of using DOS Function 3Eh to close files.
;*
;* Shows:   DOS Function - 3EH (Close File)
;*
;* Params:  handle - File handle
;*
;* Return:  None

CloseFile PROC \
	handle:WORD

	mov	bx, handle		; BX = file handle
	mov	ah, 3Eh 		; DOS Function 3Eh
	int	21h			; Close file
	ret

CloseFile ENDP


;* ReadFile - Read from open file to specified buffer. See the CopyFile
;* procedure for another example of using DOS Function 3Fh to read files.
;*
;* Shows:   DOS Function - 3Fh (Read File or Device)
;*
;* Params:  handle - File handle
;*	    len - Number of bytes to read
;*	    pbuff - Pointer to buffer
;*
;* Return:  Short integer with number of bytes read, or 0 if read error

ReadFile PROC \
	USES ds di, \
	handle:WORD, len:WORD, pbuff:PTR BYTE

	LoadPtr ds, dx, pbuff		; Point DS:DX to buffer
	mov	di, dx			; Keep string offset in DI
	mov	bx, handle		; BX = handle
	mov	cx, len 		; CX = number of bytes to read
	mov	ah, 3Fh 		; Request DOS read
	int	21h			; Read File
	jnc	exit			; If ok, exit with bytes read
	sub	ax, ax			; Else set error code
exit:	ret
	
ReadFile ENDP


;* WriteFile - Write ASCIIZ string to file. If handle = 0, the string is
;* written to STDOUT (console). See the CopyFile procedure for another
;* example of using DOS Function 40h to write to files.
;*
;* Shows:   DOS Function - 40h (Write File or Device)
;*
;* Params:  handle - File handle
;*	    str - Pointer to ASCIIZ string
;*
;* Return:  Short integer with error code
;*	    0 if successful
;*	    1 if write error
;*	    2 if number of bytes written not equal to string length

WriteFile PROC \
	USES ds di, \
	handle:WORD, str:PTR BYTE

	LoadPtr es, di, str		; Point ES:DI to string
	push	di			; Hold on to string pointer
	mov	cx, -1			; Set CX to maximum
	sub	al, al			; AL = 0
	repne	scasb			; Scan string for NULL
	pop	dx			; Recover string pointer
	dec	di
	sub	di, dx			; Get string length (w/o NULL)
	mov	cx, di			; Put it into CX
	mov	bx, handle		; Load BX with handle
	push	es			; Set DS to ES to ensure
	pop	ds			;   DS:DX points to string
	mov	ah, 40h 		; Request DOS write
	int	21h			; Write File or Device
	mov	bx, ax			; Get number of bytes written
	mov	ax, 0			; Set error code, preserve CY
	jc	e_exit			; If error, exit
	cmp	bx, cx			; All bytes written?
	je	exit			; Yes?	Exit, error code = 0
	inc	ax			; Else inc error code twice
e_exit: inc	ax			; Increment error code once
exit:	ret

WriteFile ENDP


;* GetDiskSize - Gets size information from specified disk.
;*
;* Shows:   DOS Function - 36h (Get Drive Allocation Information)
;*
;* Params:  drive - Drive code (0 = default, 1 = A, 2 = B, etc.)
;*	    disk  - Pointer to a structure with 4 short integer members:
;*		    Member 1 - Total clusters on disk
;*		    Member 2 - Number of available clusters
;*		    Member 3 - Sectors/cluster (-1 if invalid drive)
;*		    Member 4 - Bytes/sector
;*
;* Return:  None

GetDiskSize PROC \
	USES di, \
	drive:WORD, disk:PTR WORD

	mov	dx, drive		; DL = drive code
	mov	ah, 36h 		; DOS Function 36h
	int	21h			; Get Drive Allocation Information
	LoadPtr es, di, disk		; ES:DI = disk structure
	mov	es:[di].total, dx	; DX = total clusters
	mov	es:[di].avail, bx	; BX = number of free clusters
	mov	es:[di].sects, ax	; AX = sectors/cluster
	mov	es:[di].bytes, cx	; CX = bytes/sector
	ret

GetDiskSize ENDP


;* MakeDir - Creates a specified subdirectory.
;*
;* Shows:   DOS Function - 39h (Create Directory)
;*
;* Params:  pspec - Pointer to ASCIIZ pathname of new subdirectory
;*
;* Return:  Short integer with error code
;*	    0 if successful
;*	    1 if create error

MakeDir PROC \
	USES ds, \
	pspec:PTR BYTE

	LoadPtr ds, dx, pspec		; Point DS:DX to path spec
	mov	ah, 39h 		; DOS Function 39h
	int	21h			; Create Directory
	mov	ax, 0			; Set error code, keep flags
	jnc	exit			; Exit if successful
	inc	ax			; Else set error code to 1
exit:	ret

MakeDir ENDP


;* RemoveDir - Removes a specified subdirectory.
;*
;* Shows:   DOS Function - 3Ah (Delete Directory)
;*
;* Params:  pspec - Pointer to ASCIIZ pathname of subdirectory
;*
;* Return:  Short integer with error code
;*	    0 if successful
;*	    1 if delete error or subdirectory not empty

RemoveDir PROC \
	USES ds, \
	pspec:PTR BYTE

	LoadPtr ds, dx, pspec		; Point DS:DX to path spec
	mov	ah, 3Ah 		; DOS Function 3Ah
	int	21h			; Delete Directory
	mov	ax, 0			; Set error code, keep flags
	jnc	exit			; Exit if successful
	inc	ax			; Else set error code to 1
exit:	ret

RemoveDir ENDP


;* ChangeDir - Changes current (default) directory.
;*
;* Shows:   DOS Function - 3Bh (Set Current Directory)
;*
;* Params:  pspec - Pointer to ASCIIZ pathname of target subdirectory
;*
;* Return:  Short integer with error code
;*	    0 if successful
;*	    1 if delete error or subdirectory not empty

ChangeDir PROC \
	USES ds, \
	pspec:PTR BYTE

	LoadPtr ds, dx, pspec		; Point DS:DX to path spec
	mov	ah, 3Bh 		; DOS Function 3Bh
	int	21h			; Set Current Directory
	mov	ax, 0			; Set error code, keep flags
	jnc	exit			; Exit if successful
	inc	ax			; Else set error code to 1
exit:	ret

ChangeDir ENDP


;* DelFile - Deletes a specified file.
;*
;* Shows:   DOS Function - 41h (Delete File)
;*
;* Params:  fspec - Pointer to ASCIIZ file specification
;*
;* Return:  Short integer with error code
;*	    0 if successful
;*	    1 if delete error

DelFile PROC \
	USES ds, \
	fspec:PTR BYTE

	LoadPtr ds, dx, fspec		; Point DS:DX to file spec
	mov	ah, 41h 		; DOS Function 41h
	int	21h			; Delete File
	mov	ax, 0			; Set error code, keep flags
	jnc	exit			; Exit if successful
	inc	ax			; Else set error code to 1
exit:	ret

DelFile ENDP


;* Rewind - Rewinds an open file, specified by handle. See the GetFileSize
;* procedure for an example of using Function 42h to determine file size.
;*
;* Shows:   DOS Function - 42h (Set File Pointer)
;*
;* Params:  handle - File handle
;*
;* Return:  None

Rewind	PROC \
	handle:WORD

	mov	bx, handle		; BX = file handle
	mov	ax, 4200h		; AH = function #,
					; AL = move to beginning of
	sub	cx, cx			;      file plus offset
	sub	dx, dx			; CX:DX = offset (zero)
	int	21h			; Set File Pointer
	ret

Rewind	ENDP


;* GetFileSize - Gets the size of an open file, specified by handle.
;*
;* Shows:   DOS Function - 42h (Set File Pointer)
;*
;* Params:  handle - File handle
;*
;* Return:  Long integer with file size in bytes

GetFileSize PROC \
	handle:WORD

	mov	bx, handle		; BX = file handle
	mov	ax, 4202h		; AH = function #,
					; AL = move to end of
	sub	cx, cx			;      file plus offset
	sub	dx, dx			; CX:DX = offset (zero)
	int	21h			; Set File Pointer
	mov	ax, dx			; Set DX:AX = file size in
	mov	dx, cx			;   bytes, return long int
	ret

GetFileSize ENDP


;* GetAttribute - Gets the attribute(s) of a specified file.
;*
;* Shows:   DOS Function - 43h (Get or Set File Attributes)
;*
;* Params:  fspec - Pointer to ASCIIZ file specification
;*
;* Return:  Short integer with file attribute bits set as follows:
;*	       bit 0 = read-only	     bit 3 = volume label
;*	       bit 1 = hidden		     bit 4 = subdirectory
;*	       bit 2 = system		     bit 5 = archive
;*	     0 indicates normal data file
;*	    -1 indicates error

GetAttribute PROC \
	USES ds, \
	fspec:PTR BYTE

	LoadPtr ds, dx, fspec		; DS:DX = file specification
	mov	ax, 4300h		; AH = function #
					; AL = 0 (return attribute)
	int	21h			; Get File Attributes
	mov	ax, -1			; Set code, keep flags
	jc	exit			; If read error, exit
	mov	ax, cx			; Else return with
exit:	ret				;   file attribute bits

GetAttribute ENDP


;* SetAttribute - Sets the attribute(s) of a specified file.
;*
;* Shows:   DOS Function - 43h (Get or Set File Attributes)
;*
;* Params:  attr - Attribute bits set as follows:
;*		      bit 0 = read-only 	 bit 3 = volume label
;*		      bit 1 = hidden		 bit 4 = subdirectory
;*		      bit 2 = system		 bit 5 = archive
;*		   (attr = 0 for normal data file)
;*	    fspec - Pointer to ASCIIZ file specification
;*
;* Return:  Short integer with error code
;*	    0 if successful
;*	    1 if delete error

SetAttribute PROC \
	USES ds, \
	attr:WORD, fspec:PTR BYTE

	LoadPtr ds, dx, fspec		; DS:DX = file specification
	mov	cx, attr		; Put attribute code in CX
	mov	ax, 4301h		; AH = function #
					; AL = 1 (set attribute)
	int	21h			; Set File Attributes
	mov	ax, 0			; Clear code, keep flags
	jnc	exit			; If successful, exit
	inc	ax			; Else set error code
exit:	ret

SetAttribute ENDP


;* GetCurDir - Gets the current directory of default drive.
;*
;* Shows:   DOS Function - 47h (Get Current Directory)
;*
;* Params:  spec - Pointer to 64-byte buffer to receive directory
;*	    path. Path terminates with 0 but does not include
;*	    drive and does not begin with backslash.
;*
;* Return:  Short integer with error code
;*	    0 if successful
;*	    1 if delete error or subdirectory not empty

GetCurDir PROC \
	USES ds si, \
	spec:PTR BYTE

	LoadPtr ds, si, spec		; DS:SI = spec address
	mov	ah, 47h 		; AH = function number
	sub	dl, dl			; DL = current drive (0)
	int	21h			; Get Current Directory
	mov	ax, 0			; Set error code, keep flags
	jnc	exit			; Exit if successful
	inc	ax			; Else set error code to 1
exit:	ret

GetCurDir ENDP


;* FindFirst - Finds first entry in given directory matching specification.
;*
;* Shows:   DOS Function - 4Eh (Find First File)
;*	    Keywords - USES
;*	    Instructions - ret	   pushf    popf
;*
;* Params:  attr - Attribute code (see header comments for CreateFile)
;*	    fspec - Pointer to ASCIIZ file specification
;*	    finfo - Pointer to 43-byte buffer to receive
;*		    data from matched entry
;*
;* Return:  Short integer with error code
;*	    0 if successful
;*	    1 if no match found

	.DATA
old_dta DD	WORD PTR ?		; Storage for old DTA address

	.CODE

FindFirst PROC \
	USES ds, \
	attr:WORD, fspec:PTR BYTE, finfo:PTR BYTE

	push	ds			; Pass far pointer
	mov	ax, OFFSET @data:old_dta;   to old_dta
	push	ax
	call	GetDTA			; Get current DTA address
	add	sp, 4			; Adjust stack

	mov	cx, attr		; Load CX with file attribute
	LoadPtr ds, dx, finfo		; DS:DX points to 43-byte buffer
	push	ds			; Make this new DTA
	push	dx
	call	SetDTA			; Set 43-byte buffer as DTA
	add	sp, 4			; Adjust stack
	LoadPtr ds, dx, fspec		; Point DS:DX to file spec
	mov	ah, 4Eh 		; AH = function number
	int	21h			; Find First File

	pushf				; Preserve flags
	push	WORD PTR @data:old_dta[2] ; Pass far pointer to
	push	WORD PTR @data:old_dta[0] ;   SetDTA procedure
	call	SetDTA			; Restore DTA address to orig
	sub	ax, ax			; Set error code
	add	sp, 4			; Adjust stack
	popf				; Recover flags
	jnc	exit			; Exit if successful match
	inc	ax			; Else set error code to 1
exit:	ret

FindFirst ENDP


;* FindNext - Finds next entry in given directory matching specification.
;* (Should be called only after successfully calling the FindFirst procedure.)
;*
;* Shows:   DOS Function - 4Fh (Find Next File)
;*	    Operator - OFFSET
;*
;* Params:  finfo - Pointer to 43-byte buffer. This must be the same buffer
;*		    (or a duplicate) returned from the FindFirst procedure.
;*
;* Return:  Short integer with error code
;*	    0 if successful
;*	    1 if no more matches found

FindNext PROC \
	USES ds, \
	finfo:PTR BYTE

	push	ds			; Pass far pointer
	mov	ax, OFFSET @data:old_dta;   to old_dta
	push	ax
	call	GetDTA			; Get current DTA address
	add	sp, 4			; Adjust stack

	LoadPtr ds, dx, finfo		; DS:DX points to 43-byte buffer
	push	ds			; Make this new DTA
	push	dx
	call	SetDTA			; Set 43-byte buffer as DTA
	add	sp, 4			; Adjust stack
	mov	ah, 4Fh 		; AH = function number
	int	21h			; Find Next File

	pushf				; Preserve flags
	push	WORD PTR @data:old_dta[2] ; Pass far pointer to
	push	WORD PTR @data:old_dta[0] ;   SetDTA procedure
	call	SetDTA			; Restore DTA address to orig
	sub	ax, ax			; Set error code
	add	sp, 4			; Adjust stack
	popf				; Recover flags
	jnc	exit			; Exit if successful match
	inc	ax			; Else set error code to 1
exit:	ret

FindNext ENDP


;* RenameFile - Renames specified file.
;*
;* Shows:   DOS Function - 56h (Rename File)
;*
;* Params:  fspec1 - Pointer to old ASCIIZ file specification
;*	    fspec2 - Pointer to new ASCIIZ file specification
;*
;*	    The drive must be the same for both arguments, but the path
;*	    does not. This allows files to be moved between directories.
;*
;* Return:  Short integer with error code
;*	    0 if successful
;*	    1 if error

RenameFile PROC \
	USES ds di, \
	fspec1:PTR BYTE, fspec2:PTR BYTE

	LoadPtr ds, dx, fspec1		; Point DS:DX to old file spec
	LoadPtr es, di, fspec2		; Point ES:DI to new file spec
	mov	ah, 56h 		; AH = function number
	int	21h			; Rename File
	mov	ax, 0			; Clear error code, keep flags
	jnc	exit			; Return code = 0 if no error
	inc	ax			; Else set error code
exit:	ret

RenameFile ENDP


;* GetFileTime - Gets date/time for open file specified by handle.
;*
;* Shows:   DOS Function - 57h (Get or Set File Date and Time)
;*	    Instructions - shl	   shr
;*
;* Params:  handle - Handle of open file
;*	    str - Pointer to 18-byte buffer to receive date/time
;*
;* Return:  Short integer with error code
;*	    0 if successful
;*	    1 if error

GetFileTime PROC \
	USES di, \
	handle:WORD, str:PTR BYTE

	mov	ax, 5700h		; AH = function number
					; AL = get request
	mov	bx, handle		; BX = file handle
	int	21h			; Get File Date and Time
	mov	ax, 1			; Set error code, keep flags
	jc	exit			; Return code = 1 if no error
	mov	bx, cx			; Else save time in BX
	mov	al, bl			; Get low byte of time
	and	al, 00011111b		; Mask to get 2-second incrs,
	shl	al, 1			;   convert to seconds
	push	ax			; Save seconds
	mov	cl, 5
	shr	bx, cl			; Shift minutes into low byte
	mov	al, bl			; Get new low byte
	and	al, 00111111b		; Mask to get minutes
	push	ax			; Save minutes
	mov	cl, 6
	shr	bx, cl			; Shift hours into low byte
	push	bx			; Save hours

	mov	bl, dl			; Get low byte of date
	and	bl, 00011111b		; Mask to get day in BX
	mov	cl, 5
	shr	dx, cl			; Shift month into low byte
	mov	al, dl			; Get new low byte
	and	al, 00001111b		; Mask to get month
	mov	cl, 4
	shr	dx, cl			; Shift year into low byte
	add	dx, 80			; Year is relative to 1980
	push	dx			; Save year
	push	bx			; Save day
	push	ax			; Save month

	LoadPtr es, di, str		; Point ES:DI to 18-byte
	mov	cx, 6			;   string
loop1:	pop	ax			; Get 6 numbers sequentially in AL
	aam				; Convert to unpacked BCD
	xchg	al, ah			; Switch bytes for word move
	or	ax, '00'		; Make ASCII numerals
	stosw				; Copy to string
	mov	al, '-' 		; Separator for date text
	cmp	cl, 4			; First 3 iters are for date
	jg	@F			; If CX=6 or 5, insert hyphen
	mov	al, ' ' 		; Separator date and time
	je	@F			; If CX = 4, insert hyphen
	mov	al, ':' 		; Separator for time text
	cmp	cl, 1
	je	eloop			; If CX = 1, skip
@@:	stosb				; Copy separator to string
eloop:	loop	loop1

	sub	ax, ax			; Clear return code
	stosb				; Terminate string with null
exit:	ret				;    to make ASCIIZ

GetFileTime ENDP


;* UniqueFile - Creates and opens a new file with a name unique to the
;* specified directory. The name is manufactured from the current time,
;* making it useful for temporary files. For DOS versions 3.0 and higher.
;*
;* Shows:   DOS Function - 5Ah (Create Temporary File)
;*
;* Params:  attr - Attribute code (see header comments for CreateFile)
;*	    fspec - Pointer to ASCIIZ path specification
;*
;* Return:  Short integer with file handle or -1 for error

UniqueFile PROC \
	USES ds, \
	attr:WORD, pspec:PTR BYTE

	call	GetVer			; Get DOS version
	cmp	ax, 300 		; 3.0 or higher?
	jb	e_exit			; No?  Quit with error
	LoadPtr ds, dx, pspec		; Point DS:DX to path spec
	mov	cx, attr		; CX = attribute
	mov	ah, 5Ah 		; AH = function number
	int	21h			; Create Temporary File
	jnc	exit			; Return AX = handle if ok
e_exit: mov	ax, -1			; Else set error code
exit:	ret

UniqueFile ENDP


;* CreateNewFile - Creates a new file with specified attribute. Differs
;* from the CreateFile procedure in that it returns an error if file
;* already exists. For DOS versions 3.0 and higher.
;*
;* Shows:   DOS Function - 5Bh (Create New File)
;*
;* Params:  attr - Attribute code (see header comments for CreateFile)
;*	    fspec - Pointer to ASCIIZ file specification
;*
;* Return:  Short integer with file handle or -1 for error

CreateNewFile PROC \
	USES ds, \
	attr:WORD, fspec:PTR BYTE

	LoadPtr ds, dx, fspec		; Point DS:DX to file spec
	mov	cx, attr		; CX = attribute
	mov	ah, 5Bh 		; AH = function number
	int	21h			; Create New File
	jnc	exit			; Return AX = handle if ok
	mov	ax, -1			; Else set error code
exit:	ret

CreateNewFile ENDP


;* StrCompare - Compares two strings for equality. See StrWrite, StrFindChar,
;* WinOpen, and WinClose procedures for other examples of string instructions.
;*
;* Shows:   Instructions - cmpsb     cmpsw     repe	test	 jcxz
;*
;* Params:  str1 - Pointer to first string
;*	    str2 - Pointer to second string
;*	    len  - Length in bytes for comparison. Strings need not be of
;*		   equal length; however if len is an even number, comparison
;*		   is made on a word-by-word basis and thus is more efficient.
;*
;* Return:  Null pointer if strings match; else pointer to string #1 where
;*	    match failed.

StrCompare PROC \
	USES ds di si, \
	str1:PTR BYTE, str2:PTR BYTE, len:WORD

	LoadPtr es, di, str1		; ES:DI points to string #1
	LoadPtr ds, si, str2		; DS:SI points to string #2
	mov	cx, len 		; Length of search in bytes
	and	al, 0			; Set ZR flag in case CX = 0
	jcxz	nullp			; Assume success if length = 0
	test	cl, 1			; Even number?
	jz	wrdcmp			; Yes?	Compare word-by-word
	repe	cmpsb			; No?  Compare byte-by-byte
	jmp	SHORT nullp

wrdcmp: shr	cx, 1			; Decrease count by half
	repe	cmpsw			; Compare word-by-word
	sub	di, 2			; Back up 2 characters
	sub	si, 2
	cmpsb				; Match?
	jne	nullp			; No?  Then failure
	cmpsb				; Compare last characters

nullp:	mov	ax, 0			; Set null pointer without
	mov	dx, 0			;   disturbing flags
	je	exit			; If strings match, exit
	dec	di			; Else point to failure
	mov	ax, di
	mov	dx, es
exit:	ret

StrCompare ENDP


;* StrFindChar - Finds first occurence of character in given ASCIIZ string,
;* searching either from beginning or end of string. See StrWrite, WinOpen,
;* WinClose, and StrCompare procedures for other examples of string
;* instructions.
;*
;* Shows:   Instructions - repne     scasb    cld     std
;*
;* Params:  ichar - Character to search for
;*	    str - Pointer to ASCIIZ string in which to search
;*	    direct - Direction flag:
;*		     0 = search from start to end
;*		     1 = search from end to start
;*
;* Return:  Null pointer if character not found, else pointer to string where
;*	    character first encountered

StrFindChar PROC \
	USES ds di si, \
	ichar:BYTE, str:PTR BYTE, direct:WORD

	LoadPtr es, di, str		; ES:DI points to string
	LoadPtr ds, si, str		;   as does DS:SI
	mov	cx, -1			; Set scan counter to maximum
	mov	bx, cx			; BX = max string tail
	cld				; Assume head-to-tail search
	cmp	direct, 0		; Assumption correct?
	je	loop1			; Yes?	Continue
	mov	bx, di			; No?  Set BX to byte before
	dec	bx			;   string head and scan
	sub	al, al			;   string for null terminator
	push	cx			;   to find string tail
	repne	scasb
	pop	cx			; Recover scan counter
	dec	di			; Backup pointer to last
	dec	di			;   character in string and
	mov	si, di			;   begin search from there
	std				; Set direction flag

loop1:	lodsb				; Get first char from string
	cmp	si, bx			; At head limit?
	je	xmatch			; Yes?	Then no match
	or	al, al			; At tail limit?
	je	xmatch			; Yes?	Then no match
	cmp	al, ichar		; Character match?
	je	match			; Yes?	Then exit
	loop	loop1			; No?  Resume search

xmatch: sub	ax, ax			; Set null pointer if no match
	sub	dx, dx
	jmp	SHORT exit

match:	mov	ax, si			; If match, point to first
	dec	ax			;   occurence
	cmp	direct, 0		; Head-to-tail search?
	je	exit			; Yes?	Then exit
	inc	ax			; No?  Then adjust pointer
	inc	ax			;   forward
	mov	dx, ds			; Pointer segment
exit:	ret

StrFindChar ENDP


;* GetStr - Gets a string of up to 128 characters from the user. Since
;* this function uses the DOS input mechanism, it can use the DOS editing
;* keys or the keys of a DOS command-line editor if one is loaded.
;*
;* Shows:   DOS Function - 0Ah (Buffered Keyboard Input)
;*
;* Params:  buffer - Pointer to area where input string will be placed
;*	    maxlen - Maximum length (up to 128 characters) of string
;*
;* Return:  0 if successful, 1 if error (maxlen is too long)

	.DATA
MAXSTR	EQU	128
max	DB	MAXSTR
actual	DB	?
string	DB	MAXSTR DUP (?)

	.CODE
GetStr	PROC \
	USES si di, \
	strbuf:PTR BYTE, maxlen:WORD

	mov	ax, 1			; Assume error
	mov	cx, maxlen		; Copy length to register
	jcxz	exit			; Error if maxlen is zero
	cmp	cx, MAXSTR		
	ja	exit			; Error if maxlen is too long

	mov	max, cl 		; Load maximum length
	mov	ah, 0Ah 		; Request DOS Function 0Ah
	mov	dx, OFFSET max		; Load offset of string
	int	21h			; Buffered Keyboard Input

	mov	bl, actual		; Put number of characters read
	sub	bh, bh			;   in BX
	mov	string[bx], 0		; Null-terminate string
	mov	cx, bx			; Put count in CX
	inc	cx			; Plus one for the null terminator

	LoadPtr es, di, strbuf		; ES:DI points to destination buffer
	mov	si, OFFSET string	; DS:SI points to source string
	rep	movsb			; Copy source to destination
	sub	ax, ax			; Return 0 for success

exit:	ret

GetStr	ENDP

	END
