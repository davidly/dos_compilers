	.MODEL	small, c
	INCLUDE demo.inc
	.CODE

;* GetVer - Gets DOS version.
;*
;* Shows:   DOS Function - 30h (Get MS-DOS Version Number)
;*
;* Params:  None
;*
;* Return:  Short integer of form (M*100)+m, where M is major
;*	    version number and m is minor version, or 0 if
;*	    DOS version earlier than 2.0

GetVer	PROC

	mov	ah, 30h 		; DOS Function 30h
	int	21h			; Get MS-DOS Version Number
	cmp	al, 0			; DOS version 2.0 or later?
	jne	@F			; Yes?	Continue
	sub	ax, ax			; No?  Set AX = 0
	jmp	SHORT exit		;   and exit
@@:	sub	ch, ch			; Zero CH and move minor
	mov	cl, ah			;   version number into CX
	mov	bl, 100
	mul	bl			; Multiply major by 10
	add	ax, cx			; Add minor to major*10
exit:	ret				; Return result in AX

GetVer	ENDP

;* GetVidConfig - Determines current video configuration and initializes
;* the vconfig structure.
;*
;* Shows:   BIOS Interrupt - 10h, Function 0 (Set Video Mode)
;*				  10h, Function 0Fh (Get Video Mode)
;*				  10h, Function 1Ah (Get or Set Display
;*					Combination Code)
;*
;* Uses:    vconfig - Video configuration structure, declared in the
;*	    DEMO.INC include file.
;*
;* Params:  None
;*
;* Return:  None

GetVidConfig PROC

	mov	ax, 1A00h		; Request video info for VGA
	int	10h			; Get Display Combination Code

chkVGA: cmp	al, 1Ah 		; Is VGA or MCGA present?
	jne	chkEGA			; No?  Then check for EGA

	cmp	bl, 2			; If VGA exists as secondary adapter,
	je	isCGA			;   check for CGA and mono as primary
	jb	isMONO
	cmp	bl, 5			; If EGA is primary, do normal
	jbe	chkEGA			;   EGA checking

chkMCGA:mov	vconfig.adapter, MCGA	; Yes?	Assume MCGA
	mov	vconfig.display, COLOR
	cmp	bl, 8			; Correct assumption?
	ja	gmode			; Yes?	Continue
isVGA:	mov	vconfig.adapter, VGA	; Assume it's VGA color
	je	gmode			; Yes?	Continue
	mov	vconfig.display, MONO	; No?  Must be VGA mono
	jmp	SHORT gmode		; Finished with VGA, so jump

chkEGA: mov	ah, 12h 		; Call EGA status function
	mov	bl, 10h
	sub	cx, cx			; Clear status bits
	int	10h			; Get Configuration Information
	jcxz	chkCGA			; If CX is unchanged, not EGA

isEGA:	mov	vconfig.adapter, EGA	; Set structure fields for EGA
	mov	vconfig.display, MONO	; Assume EGA mono
	or	bh, bh			; Correct assumption?
	jnz	gmode			; Yes?	Continue
	mov	vconfig.display, COLOR	; No?  Must be EGA color
	jmp	SHORT gmode		; Finished with EGA, so jump

chkCGA: int	11h			; Get equipment list
	and	al, 30h 		; If bits 4-5 set, monochrome
	cmp	al, 30h 		; Monochrome text mode?
	je	isMONO			; Yes?	Continue
isCGA:	mov	vconfig.adapter, CGA	; No?  Must be CGA
	mov	vconfig.display, COLOR
	mov	vconfig.CGAvalue, 29h	; Value for CGA 80x25 text,
	jmp	SHORT gmode		;   color, blink enable

isMONO: mov	vconfig.adapter, MDA	; Set MONO
	mov	vconfig.display, MONO

gmode:	mov	ah, 0Fh
	int	10h			; Get Video Mode
	mov	vconfig.mode, al	; Record mode
	mov	vconfig.dpage, bh	;   and current page
	cmp	al, 7			; Monochrome text mode?
	je	@F			; Yes?	Continue
	cmp	al, 3			; Color text mode?
	je	@F			; Yes?	Continue
	cmp	al, 2			; Black/white 80-col mode?
	je	@F			; Yes?	Continue
	mov	ax, 0003h		; If not 80-col text mode,
	mov	vconfig.mode, al	;   request Function 0, mode 3
	int	10h			; Set Video Mode to 80-col

@@:	mov	al, vconfig.display	; Multiply display value
	cbw				;   (which is either 0 or 1)
	mov	bx, 800h		;   by 800h, then add to B000h
	mul	bx			;   for segment address of
	add	ax, 0B000h		;   video buffer
	add	ah, vconfig.dpage	; Adding display page gives
	mov	vconfig.sgmnt, ax	;   address of current page

	mov	vconfig.rows, 24	; Assume bottom row # = 24
	cmp	vconfig.adapter, EGA	; EGA or VGA?
	jl	exit			; No?  Exit
	mov	ax, 1130h		; Yes?	Request character info
	sub	bh, bh			; Set BH to valid value
	push	bp			; BP will change, so save it
	int	10h			; Get number of rows/screen
	mov	vconfig.rows, dl	; Keep in structure
	pop	bp			; Restore BP

exit:	ret

GetVidConfig ENDP

;* SetCurPos - Sets cursor position.
;*
;* Shows:   BIOS Interrupt - 10h, Function 2 (Set Cursor Position)
;*
;* Uses:    vconfig - Video configuration structure, declared in the
;*	    DEMO.INC include file. The structure must first be
;*	    initialized by calling the GetVidConfig procedure.
;*
;* Params:  row - Target row
;*	    col - Target column
;*
;* Return:  None

SetCurPos PROC \
	row:WORD, col:WORD

	mov	dx, col 		; DL = column
	mov	dh, BYTE PTR row	; DH = row
	mov	ah, 2			; Function 2
	mov	bh, vconfig.dpage	; Current page
	int	10h			; Set cursor position
	ret

SetCurPos ENDP

;* StrWrite - Writes ASCIIZ string to video memory at specified row/column.
;*
;* Shows:   Instructions - lodsb     stosb
;*
;* Uses:    vconfig - Video configuration structure, declared in the
;*	    DEMO.INC include file. The structure must first be
;*	    initialized by calling the GetVidConfig procedure.
;*
;* Params:  row - Row coordinate
;*	    col - Column coordinate
;*	    str - Pointer to string
;*
;* Return:  None

StrWrite PROC \
	USES ds di si, \
	row:WORD, col:WORD, str:PTR BYTE

	GetVidOffset row, col		; Get offset in video segment
	mov	di, ax			; Copy to DI
	LoadPtr ds, si, str		; DS:SI points to string
	mov	es, vconfig.sgmnt	; ES:DI points to video RAM
loop1:	lodsb				; Get 1 character from string
	or	al, al			; Null terminator?
	jz	exit			; Yes?	Exit loop
	cmp	vconfig.adapter, CGA	; CGA adapter?
	jne	pchar			; No?  Skip next 10 lines

; For CGA systems, StrWrite waits for the video to begin a horizontal
; retrace before writing a character to memory. This avoids the problem
; of video snow inherent with some (though not all) color/graphics adapters.
; It also demonstrates a somewhat different approach to the problem than the
; one taken in the WinOpen and WinClose procedures.

	push	ax			; Save character
	mov	dx, 3dah		; Address of status register
	cli				; Disallow interruptions
wait1:	in	al, dx			; Read current video status
	test	al, 1			; Horizontal retrace active?
	jnz	wait1			; Yes?	Wait for it to end
wait2:	in	al, dx			; No?  Read status again
	test	al, 1			; Wait for retrace to start
	jz	wait2
	pop	ax			; Recover character
pchar:	stosb				; Write char to video buffer
	sti				; Reenable interrupts
	inc	di			; Skip attribute byte
	jmp	SHORT loop1		; Loop back
exit:	ret

StrWrite ENDP

;* ClearBox - Clears portion of screen with specified fill attribute.
;*
;* Shows:   BIOS Interrupt - 10h, Function 6 (Scroll Up)
;*
;* Params:  attr - Fill attribute
;*	    row1 - Top screen row of cleared section
;*	    col1 - Left column of cleared section
;*	    row2 - Bottom screen row of cleared section
;*	    col2 - Right column of cleared section
;*
;* Return:  None

ClearBox PROC \
	attr:WORD, row1:WORD, col1:WORD, row2:WORD, col2:WORD

	mov	ax, 0600h		; Scroll service
	mov	bh, BYTE PTR attr	; BH = fill attribute
	mov	ch, BYTE PTR row1	; CH = top row of clear area
	mov	cl, BYTE PTR col1	; CL = left column 
	mov	dh, BYTE PTR row2	; DH = bottom row of clear area
	mov	dl, BYTE PTR col2	; DL = right column
	int	10h			; Clear screen by scrolling up
	ret

ClearBox ENDP

	END
