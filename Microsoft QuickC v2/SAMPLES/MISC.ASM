	.MODEL small, c
	INCLUDE demo.inc
	.CODE


;* DisableCGA - Disables CGA video by reprogramming the control register.
;*
;* Shows:   Instructions - cli     sti     loopz     loopnz
;*
;* Uses:    vconfig - Video configuration structure, declared in the
;*	    DEMO.INC include file. The structure must first be
;*	    initialized by calling the GetVidConfig procedure.
;*
;* Params:  None
;*
;* Return:  None

DisableCGA PROC \
	USES ax cx dx			; Preserve registers

	mov	cx, -1			; Set maximum loop count
	mov	dx, 03DAh		; Address of status register
wait1:	in	al, dx			; Get video status
	test	al, 8			; Vertical retrace active?
	loopnz	wait1			; Yes?	Wait for end/timeout
	cli				; Disallow interruptions
	mov	cx, -1			; Reset loop count
wait2:	in	al, dx			; Get video status
	test	al, 8			; Start of vertical retrace?
	loopz	wait2			; No?  Wait for start/timeout
	sub	dx, 2			; DX = address of control reg
	mov	al, 1			; Value to disable CGA video
	out	dx, al			; Disable video
	sti				; Reenable interrupts
	ret

DisableCGA ENDP


;* EnableCGA - Enables CGA video by reprogramming the control register.
;*
;* Uses:    vconfig - Video configuration structure, declared in the
;*	    DEMO.INC include file. The structure must first be
;*	    initialized by calling the GetVidConfig procedure.
;*
;* Params:  None
;*
;* Return:  None

EnableCGA PROC \
	USES ax dx			; Preserve registers

	mov	dx, 03D8h		; Address of control register
	mov	al, vconfig.CGAvalue	; Reprogram with proper value
	out	dx, al			; Enable video
	ret

EnableCGA ENDP


;* WinOpen - Saves portion of screen to allocated memory, then opens a window
;* with specified fill attribute. See also the WinClose procedure.
;*
;* Shows:   DOS Function - 48h (Allocate Memory Block)
;*	    BIOS Interrupt - 10h, Function 6 (Initialize or Scroll Up Window)
;*	    Instructions - movsw	stosw	  rep
;*
;* Uses:    vconfig - Video configuration structure, declared in the
;*	    DEMO.INC include file. The structure must first be
;*	    initialized by calling the GetVidConfig procedure.
;*
;* Params:  row1 - Row at top of window
;*	    col1 - Column at left edge of window
;*	    row2 - Row at bottom of window
;*	    col2 - Column at right edge of window
;*	    attr - Fill attribute for window
;*
;* Return:  Short integer with segment address of allocated buffer, or
;*	    0 if unable to allocate memory

WinOpen PROC \
	USES ds di si, \
	row1:WORD, col1:WORD, row2:WORD, col2:WORD, attr:WORD

	GetVidOffset row1, col1 	; Get offset in video segment
	mov	si, ax			; SI = video offset for window
	mov	bx, row2
	sub	bx, row1
	inc	bx			; BX = number of window rows
	mov	cx, col2
	sub	cx, col1
	inc	cx			; CX = number of columns

	mov	ax, cx			; Compute number of video
	mul	bl			;   cells in window
	add	ax, 3			; Plus 3 additional entries
	shr	ax, 1			; Shift right 3 times to
	shr	ax, 1			;   multiply by 2 bytes/cell,
	shr	ax, 1			;   divide by 16 bytes/para
	inc	ax			; Add a paragraph
	push	bx			; Save number of rows
	mov	bx, ax			; BX = number of paragraphs
	mov	ah, 48h 		; Request DOS Function 48h
	int	21h			; Allocate Memory Block
	pop	bx
	jnc	@F			; If successful, continue
	sub	ax, ax			; Else return null pointer
	jmp	SHORT exit

@@:	mov	es, ax			; Point ES:DI to allocated
	sub	di, di			;   buffer
	mov	ax, si
	stosw				; Copy video offset to buffer
	mov	ax, bx
	stosw				; Number of rows to buffer
	mov	ax, cx
	stosw				; Number of cols to buffer
	mov	ax, 160 		; Number of video cells/row
	mov	ds, vconfig.sgmnt	; DS = video segment
loop1:	push	si			; Save ptr to start of line
	push	cx			;   and number of columns
	cmp	vconfig.adapter, CGA	; CGA adapter?
	jne	@F			; No?  Skip video disable

; For CGA adapters, WinOpen avoids screen "snow" by disabling the video prior
; to block memory moves, then reenabling it. Although this technique can
; result in brief flickering, it demonstrates the fastest way to access a
; block in the CGA video buffer without causing display snow. See also the
; StrWrite procedure for another solution to the problem of CGA snow.

	call	DisableCGA		; Yes?	Disable video
@@:	rep	movsw			; Copy one row to buffer
	cmp	vconfig.adapter, CGA
	jne	@F
	call	EnableCGA		; Reenable CGA video
@@:	pop	cx			; Recover number of columns
	pop	si			;   and start of line
	add	si, ax			; Point to start of next line
	dec	bx			; Decrement row counter
	jnz	loop1			; Loop while rows remain


; Screen contents (including display attributes) are now copied to buffer.
; Next open window, overwriting the screen portion just saved.

	mov	ax, 0600h		; Scroll service
	mov	bh, BYTE PTR attr	; Fill attribute
	mov	cx, col1		; CX = row/col for upper left
	mov	ch, BYTE PTR row1
	mov	dx, col2		; DX = row/col for lower right
	mov	dh, BYTE PTR row2
	int	10h			; Blank window area on screen
	mov	ax, es			; Return address of allocated
exit:	ret				;   segment

WinOpen ENDP


;* WinClose - "Closes" a window previously opened by the WinOpen procedure.
;* See also the WinOpen procedure.
;*
;* Shows:   DOS Function - 49h (Release Memory Block)
;*	    Instructions - lodsw
;*	    Operators - : (segment override)	 SEG
;*
;* Uses:    vconfig - Video configuration structure, declared in the
;*	    DEMO.INC include file. The structure must first be
;*	    initialized by calling the GetVidConfig procedure.
;*
;* Params:  addr - Segment address of buffer that holds screen contents
;*		   saved in WinOpen procedure
;*
;* Return:  None

WinClose PROC \
	USES ds di si, \
	addr:WORD

	mov	ds, addr		; DS:SI points to buffer
	sub	si, si
	lodsw
	mov	di, ax			; DI = video offset of window
	lodsw
	mov	bx, ax			; BX = number of window rows
	lodsw
	mov	cx, ax			; CX = number of columns

	mov	ax, SEG vconfig.sgmnt
	mov	es, ax			; Point ES to data segment
	push	es:vconfig.sgmnt
	pop	es			; ES = video segment
	mov	ax, 160 		; Number of video cells/row
loop1:	push	di			; Save ptr to start of line
	push	cx			;   and number of columns
	cmp	vconfig.adapter, CGA	; CGA adapter?
	jne	@F			; No?  Skip video disable

; Disable CGA video prior to memory move to avoid screen snow. (See the
; WinOpen and StrWrite procedures for further discussions on CGA snow.)

	call	DisableCGA		; Yes?	Disable video
@@:	rep	movsw			; Copy one row to buffer
	cmp	vconfig.adapter, CGA
	jne	@F
	call	EnableCGA		; Reenable CGA video
@@:	pop	cx			; Recover number of columns
	pop	di			;   and start of line
	add	di, ax			; Point to start of next line
	dec	bx			; Decrement row counter
	jnz	loop1			; Loop while rows remain

	mov	ah, 49h 		; Request DOS Function 49h
	mov	es, addr
	int	21h			; Release Memory Block
	ret

WinClose ENDP


;* SetCurSize - Sets cursor size.
;*
;* Shows:   BIOS Interrupt - 10h, Function 1 (Set Cursor Type)
;*
;* Params:  scan1 - Starting scan line
;*	    scan2 - Ending scan line
;*
;* Return:  None

SetCurSize PROC \
	scan1:WORD, scan2:WORD

	mov	cx, scan2		; CL = ending scan line
	mov	ch, BYTE PTR scan1	; CH = starting scan line
	mov	ah, 1			; Function 1
	int	10h			; Set Cursor Type
	ret

SetCurSize ENDP


;* GetCurSize - Gets current cursor size.
;*
;* Shows:   BIOS Interrupt - 10h, Function 3 (Get Cursor Position)
;*
;* Uses:    vconfig - Video configuration structure, declared in the
;*	    DEMO.INC include file. The structure must first be
;*	    initialized by calling the GetVidConfig procedure.
;*
;* Params:  None
;*
;* Return:  Short integer with high byte = top scan line,
;*			       low byte  = bottom scan line

GetCurSize PROC

	mov	ah, 3			; Function 3
	mov	bh, vconfig.dpage
	int	10h			; Get Cursor Position
	mov	ax, cx			; Return cursor size
	ret

GetCurSize ENDP


;* GetCurPos - Gets current cursor position.
;*
;* Shows:   BIOS Interrupt - 10h, Function 3 (Get Cursor Position)
;*
;* Uses:    vconfig - Video configuration structure, declared in the
;*	    DEMO.INC include file. The structure must first be
;*	    initialized by calling the GetVidConfig procedure.
;*
;* Params:  None
;*
;* Return:  Short integer with high byte = row, low byte = column

GetCurPos PROC

	mov	ah, 3			; Function 3
	mov	bh, vconfig.dpage
	int	10h			; Get cursor position
	mov	ax, dx			; Return cursor row/column
	ret

GetCurPos ENDP


;* GetShift - Gets current shift status. Checks for extended keyboard,
;* and if available returns additional shift information.
;*
;* Shows:   BIOS Interrupt - 16h, Functions 2 and 12h (Get Keyboard Flags)
;*
;* Params:  None
;*
;* Return:  Long integer
;*	    high word = 0 for non-extended keyboard
;*			1 for extended keyboard
;*	    low word has following bits set when indicated keys are pressed:
;*	    0 - Right shift		      8 - Left Ctrl
;*	    1 - Left shift		      9 - Left Alt
;*	    2 - Ctrl			     10 - Right Ctrl
;*	    3 - Alt			     11 - Right Alt
;*	    4 - Scroll Lock active	     12 - Scroll Lock pressed
;*	    5 - Num Lock active 	     13 - Num Lock pressed
;*	    6 - Caps Lock active	     14 - Caps Lock pressed
;*	    7 - Insert toggled		     15 - Sys Req pressed

GetShift PROC

	sub	dx, dx			; Assume non-extended keyboard
	mov	ah, 2			;   and use Function 2
	mov	es, dx			; Point ES to low memory
	test	BYTE PTR es:[496h], 16	; Extended keyboard installed?
	jz	@F			; No?	Leave AH as Function 2
	inc	dx			; Yes?	Set high word of return code
	mov	ah, 12h 		;   and use Function 12h
@@:	int	16h			; Get Keyboard Flags
	ret

GetShift ENDP


;* GetKeyClock - Waits for keypress while updating time at specified location
;* on screen.
;*
;* Shows:   BIOS Interrupt - 16h, Functions 0 and 10h (Read Character)
;*			     16h, Functions 1 and 11h (Get Keyboard Status)
;*	    DOS Functions - 2Ah (Get Date)
;*			    2Ch (Get Time)
;*
;* Uses:    vconfig - Video configuration structure, declared in the
;*	    DEMO.INC include file. The structure must first be
;*	    initialized by calling the GetVidConfig procedure.
;*
;* Params:  row - Screen row for clock display
;*	    col - Screen column for clock display
;*
;* Return:  Short integer with key scan code in high byte and ASCII
;*	    character code in low byte. Low byte is 0 for special
;*	    keys (such as the "F" keys) which don't generate characters.

	.DATA
	PUBLIC datestr
datestr DB	'  -  -     :  :  ', 0	; Date/time string
	.CODE

	EXTRN StrWrite:PROC

GetKeyClock PROC \
	row:WORD, col:WORD

	LOCAL	service:BYTE

	call	GetShift		; Check for extended keyboard
	mov	service, 11h		; Request for Function 11h
	cmp	dx, 1			; Extended keyboard available?
	je	key1			; Yes?	Set AH appropriately
	mov	service, 1		; No? Set AH for Function 1
key1:	mov	ah, service
	int	16h			; Get Keyboard Status
	jnz	exit			; Ready?  Exit procedure
					; Not ready?  Check text mode
	cmp	vconfig.mode, 7 	; Monochrome text mode?
	je	@F			; Yes?	Continue
	cmp	vconfig.mode, 3 	; Color text mode?
	je	@F			; Yes?	Continue
	cmp	vconfig.mode, 2 	; Black/white?
	jne	key1			; No?  Skip clock update and
					;   poll keyboard again

; If 80-column text, get date and time from DOS before again polling keyboard,
; and display at upper right corner of screen.

@@:	mov	ah, 2Ch 		; Request time
	int	21h			; Get Time
	mov	dl, dh
	push	dx			; Save seconds,
	push	cx			;   minutes,
	mov	cl, ch			;   and
	push	cx			;   hours
	mov	ah, 2Ah 		; Request date
	int	21h			; Get Date
	sub	cx, 1900		; Subtract century, CL = year
	push	cx			; Save year,
	push	dx			;   day,
	mov	dl, dh			;   and
	push	dx			;   month

	mov	cx, 6
	sub	bx, bx
loop1:	pop	ax			; Recover all 6 numbers in AL
	aam				; Convert to unpacked BCD
	xchg	al, ah			; Switch bytes for word move
	or	ax, '00'		; Make ASCII numerals
	mov	WORD PTR datestr[bx], ax; Copy to string
	add	bx, 3			;   at every third byte
	loop	loop1

	DispText row, col, <OFFSET datestr>
	jmp	key1			; Loop again for keypress

exit:	mov	ah, service		; 1 or 11h, depending on keybd
	dec	ah			; Set AH to 0 or 10h
	int	16h			; Get key to remove it from
	ret				;   keyboard buffer

GetKeyClock ENDP


;* GetPSP - Gets address of Program Segment Prefix. For DOS 3.0 or higher.
;*
;* Shows:   DOS Function - 62h (Get PSP Address)
;*	    Instruction - call (See the MISCDEMO.ASM example program
;*			  for an example of a call dispatch table)
;*
;* Params:  None
;*
;* Return:  Short integer with PSP segment address
;*	    or 0 if DOS version below 3.0

	EXTRN GetVer:PROC

GetPSP	PROC

	call	GetVer			; Get DOS version number
	cmp	ax, 300 		; Version 3.0 or higher?
	jb	dos2			; No?  Return error code
	mov	ah, 62h 		; Yes?	Query DOS for PSP
	int	21h			; Get PSP Address
	mov	ax, bx			; Put in AX
	jmp	SHORT exit		; Exit
dos2:	sub	ax, ax			; For version 2, return 0
exit:	ret

GetPSP	ENDP


;* GetMem - Gets total size of memory and determines the largest amount of
;* unallocated memory available. GetMem invokes DOS Function 48h (Allocate
;* Memory) to request an impossibly large memory block. DOS denies the re-
;* quest, but returns instead the size of the largest block available. This
;* is the amount that GetMem returns to the calling program. See the WinOpen
;* procedure for an example of calling Function 48h to allocate unused memory.
;*
;* Shows:   BIOS Interrupt - 12h (Get Conventional Memory Size)
;*
;* Params:  None
;*
;* Return:  Long integer, high word = total memory in kilobytes (KB)
;*			  low word  = largest block of available memory (KB)

GetMem	PROC

	int	12h			; Get total memory in K
	push	ax			; Save size of memory
	mov	ah, 48h 		; Request memory allocation
	mov	bx, 0FFFFh		; Ensure request is denied for
					;   impossibly large block
	int	21h			; Get largest available block in BX
	mov	ax, bx			; Copy to AX
	mov	cl, 6			; Convert paragraphs to kilobytes by
	shr	ax, cl			;   dividing by 64
	pop	dx			; Recover total in DX
	ret				; Return long integer DX:AX

GetMem	ENDP


;* VeriPrint - Checks if LPT1 (PRN) is available.
;*
;* Shows:   BIOS Interrupt - 17h (Parallel Port Printer Driver)
;*
;* Params:  None
;*
;* Return:  Short integer, 1 for yes or 0 for no

VeriPrint PROC

	mov	ah, 2			; Check printer status for 
	sub	dx, dx			;   parallel printer (port 0)
	int	17h
	xchg	dx, ax			; Put 0 (for error) in AX
	test	dh, 00101001b		; Are any error bits on?
	jne	exit			; Yes?	Leave 0
	test	dh, 10010000b		; Are both operation bits on?
	jz	exit			; No?  Leave 0
	inc	ax			; Yes?	Return 1
exit:	ret

VeriPrint ENDP


;* IntToAsc - Converts integer to ASCII string. This procedure is useful
;* only for assembly language, and is not intended to be C-callable.
;*
;* Shows:   Instructions - cwd	   aam     xchg
;*
;* Entry:   AX = integer (9999 max)
;*
;* Return:  DX:AX = 4-digit ASCII number

IntToAsc PROC

	cwd				; Zero DX register
	mov	cx, 100 		; Divide AX by 100, yields
	div	cx			;   AX=quotient, DX=remainder
	aam				; Make digits unpacked BCD
	or	ax, '00'		; Convert to ASCII
	xchg	ax, dx			; Do same thing for DX
	aam
	or	ax, '00'
	ret				; Return DX:AX = ASCII number

IntToAsc ENDP


;* VeriAnsi - Checks for ANSI driver by writing ANSI sequence to report
;* cursor position. If report compares with position returned from
;* GetCurPos procedure, then ANSI driver is operating.
;*
;* Shows:   DOS Functions - 06h (Direct Console I/O)
;*			    0Ch (Flush Input Buffer and then Input)
;*
;* Params:  None
;*
;* Return:  Short integer, 1 for yes or 0 for no

	.DATA
	PUBLIC report
report	DB	ESCAPE, '[6n$'		; ANSI Report Cursor sequence
	.CODE

VeriAnsi PROC

	call	GetCurPos		; Cursor position from BIOS
	mov	cx, ax			; Save it in CX
	mov	dx, OFFSET report	; ANSI string to get position
	mov	ah, 9			; Request DOS String Output
	int	21h			; Write ANSI escape sequence

	mov	ah, 6			; Skip Esc character in
	mov	dl, 0FFh		;   keyboard buffer
	int	21h
	jz	e_exit			; If no key, ANSI not loaded
	mov	ah, 6			; Skip '[' character
	int	21h
	jz	e_exit			; If no key, ANSI not loaded
	mov	ah, 6			; Get 1st digit of cursor row
	int	21h
	jz	e_exit			; If no key, ANSI not loaded
	mov	bh, al			; Store in BH
	mov	ah, 6			; Get 2nd digit of cursor row
	int	21h
	jz	e_exit			; If no key, ANSI not loaded
	mov	bl, al			; Store in BL
	mov	al, ch			; Get original row # in AL
	cbw				; AX = row # from GetCurPos
	inc	ax			; Add 1 to it
	call	IntToAsc		; Make ASCII digits
	cmp	ax, bx			; ANSI and BIOS reports match?
	jne	e_exit			; No?  Then ANSI not loaded

	mov	ax, 0C06h		; Flush remaining ANSI keys
	mov	dl, 0FFh		;   from buffer
	int	21h
	mov	ax, 1			; Set 1 for true
	jmp	SHORT exit		;   and exit

e_exit: sub	ax, ax			; Set 0 return code if no
exit:	ret				;   ANSI driver installed

VeriAnsi ENDP


;* VeriCop - Checks for coprocessor.
;*
;* Shows:   BIOS Interrupt - 11h (Get Equipment Configuration)
;*
;* Params:  None
;*
;* Return:  Short integer, 1 for yes or 0 for no

VeriCop PROC

	int	11h			; Check peripherals
	test	al, 2			; Coprocessor?
	mov	ax, 0			; Assume no, don't alter flags
	jz	exit			; No?  Done
	inc	ax			; Yes?	Set to 1
exit:	ret

VeriCop ENDP


;* SetLineMode - Sets line mode for EGA or VGA.
;*
;* Shows:   BIOS Interrupt - 10h, Function 11h (Character Generator Interface)
;*			     10h, Function 12h (Video Subsystem Configuration)
;*	    Instruction - cmp
;*
;* Uses:    vconfig - Video configuration structure, declared in the
;*	    DEMO.INC include file. The structure must first be
;*	    initialized by calling the GetVidConfig procedure.
;*
;* Params:  line - Requested line mode (25, 43, or 50)
;*
;* Return:  Short integer with error code
;*	    0 if successful
;*	    1 if error

SetLineMode PROC \
	line:WORD

	cmp	vconfig.adapter, EGA	; EGA or VGA?
	jge	@F			; Yes?	Continue
	jmp	e_exit			; No?  Exit with error
@@:	mov	ax, line		; Check for valid parameter
	cmp	al, 25
	je	line25
	cmp	al, 43
	je	line43
	cmp	al, 50
	je	line50
	jmp	SHORT e_exit		; If not 25, 43, or 50, exit w/ error

line25: mov	al, 11h 		; Set for EGA 25-line mode
	cmp	vconfig.adapter, EGA	; EGA?
	je	lmode			; Yes?	Continue
	mov	ax, 1202h		; No?  Function 12h for VGA
	mov	bl, 30h 		; AL = 2 for 400 scan lines
	int	10h			; Reset to 400 scan lines
	mov	ax, 0003		; Reset mode (Function 0)
	int	10h			;   to mode 3 (80-col text)
	mov	al, 14h 		; Request 8x16 char matrix
	jmp	SHORT lmode

line43: mov	al, 12h 		; Set for EGA 43-line mode
	cmp	vconfig.adapter, EGA	; EGA?
	je	lmode			; Yes?	Continue
	mov	ax, 1201h		; No?  Function 12h for VGA
	mov	bl, 30h 		; AL = 1 for 350 scan lines
	int	10h			; Reset to 350 scan lines
	mov	ax, 0003		; Reset mode (Function 0)
	int	10h			;   to mode 3 (80-col text)
	mov	al, 12h 		; Request 8x8 character matrix
	jmp	SHORT lmode

line50: cmp	vconfig.adapter, VGA	; VGA?
	jne	e_exit			; No?  Exit with error
	mov	ax, 1202h		; Yes?	Function 12h
	mov	bl, 30h 		; AL = 2 for 400 scan lines
	int	10h			; Reset to 400 scan lines
	mov	ax, 0003		; Reset mode (Function 0)
	int	10h			;   to mode 3 (80-col text)
	mov	al, 12h 		; Request 8x8 character matrix

lmode:	sub	bl, bl			; Use table 0
	mov	ah, 11h 		; Request Function 11h
	int	10h			; Set new line mode

	mov	ah, 12h 		; Select alternate print
	mov	bl, 20h 		;    screen for EGA and VGA
	int	10h

	cmp	vconfig.adapter, VGA	; VGA?
	je	exit			; Yes?	Then exit
	cmp	line, 12h		; If EGA 43-line mode, set
	je	port			;   cursor through port to
					;   avoid cursor emulation bug 
	mov	al, 7			; Else use BIOS to set cursor
	push	ax			; Pass bottom scan line
	mov	al, 6
	push	ax			; Pass top scan line
	call	SetCurSize		; Set normal cursor
	add	sp, 4			; Clean stack
	jmp	SHORT exit		; Exit

port:	mov	dx, 03D4h		; Video controller address
	mov	ax, 060Ah		; Set AH = 06h (cursor start)
					;     AL = 0Ah (register #)
	out	dx, ax			; Update port
	mov	ax, 000Bh		; Set AH = 00h (cursor end)
					;     AL = 0Bh (register #)
	out	dx, ax			; Update port
	jmp	SHORT exit		; Normal exit

e_exit: mov	ax, 1			; Set error code
	jmp	SHORT @F
exit:	sub	ax, ax			; Clear error code
@@:	ret

SetLineMode ENDP


;* Pause - Waits for specified number of clocks to elapse, then returns.
;*
;* Shows:   BIOS Interrupt - 1Ah, Function 0 (Real-Time Clock Driver)
;*	    Operators - LOCAL	  []
;*
;* Params:  duration - Desired duration in clocks, where
;*		       18 clocks = approx 1 second
;*
;* Return:  None

Pause	PROC \
	duration:WORD

	LOCAL time:DWORD

	sub	ah, ah
	int	1Ah			; Get Clock Count in CX:DX
	add	dx, duration		; Add pause time to it
	adc	cx, 0
	mov	WORD PTR time[0], dx	; Result is target time;
	mov	WORD PTR time[2], cx	;   keep in local variable
loop1:	int	1AH			; Now repeatedly poll clock
	cmp	dx, WORD PTR time[0]	;   count until the target
	jb	loop1			;   time is reached
	cmp	cx, WORD PTR time[2]
	jb	loop1
	ret

Pause	ENDP


;* Sound - Sounds speaker with specified frequency and duration.
;*
;* Shows:   Instructions - in		out
;*
;* Params:  freq - Desired frequency of sound in Hertz
;*	    duration - Desired duration in clocks, where
;*		       18 clocks = approx 1 second
;*
;* Return:  None

Sound	PROC \
	freq:WORD, duration:WORD

	mov	al, 0B6h		; Initialize channel 2 of
	out	43h, al 		;   timer chip
	mov	dx, 12h 		; Divide 1,193,182 Hertz
	mov	ax, 34DEh		;   (clock frequency) by
	div	freq			;   desired frequency
					; Result is timer clock count
	out	42h, al 		; Low byte of count to timer
	mov	al, ah
	out	42h, al 		; High byte of count to timer
	in	al, 61h 		; Read value from port 61h
	or	al, 3			; Set first two bits
	out	61h, al 		; Turn speaker on
	push	duration
	call	Pause			; Pause for specified time
	add	sp, 2			; Clean stack on return
	in	al, 61h 		; Get port value
	xor	al, 3			; Kill bits 0-1 to turn
	out	61h, al 		;   speaker off
	ret

Sound	ENDP


;* WriteTTY - Displays ASCIIZ string at cursor position, in either text
;* or graphics mode.
;*
;* Shows:   BIOS Interrupt - 10h, Function 0Eh (Write Character in TTY Mode)
;*	    Instruction - loop
;*
;* Uses:    vconfig - Video configuration structure, declared in the
;*	    DEMO.INC include file. The structure must first be
;*	    initialized by calling the GetVidConfig procedure.
;*
;* Params:  str - Pointer to ASCIIZ string
;*	    icolor - Color index (for graphics mode only)
;*
;* Return:  None

WriteTTY PROC \
	USES ds si, \
	str:PTR BYTE, icolor:WORD

	mov	bx, icolor		; BL = color index
	mov	bh, vconfig.dpage	; BH = current display page
	LoadPtr ds, si, str
	mov	cx, -1			; Set loop counter to maximum
	mov	ah, 14			; Function 14
loop1:	lodsb				; Get character from string
	or	al, al			; NULL string terminator?
	jz	exit			; Yes?	Exit
	int	10h			; No?  Display, advance cursor
	loop	loop1			; Loop to get next character
exit:	ret

WriteTTY ENDP


;* Colors - Alters screen colors within a specified area by using bit
;* or move operations on display attribute bytes in video memory.
;*
;* Shows:   Instructions - not     rol     ror     and     xor     or
;*
;* Params:  logic - Code number, 0 = NOT    2 = ROR     4 = XOR    6 = MOV   
;*				 1 = ROL    3 = AND     5 = OR
;*	    attr - Attribute mask
;*	    row1 - Row at top of window
;*	    col1 - Column at left edge of window
;*	    row2 - Row at bottom of window
;*	    col2 - Column at right edge of window
;*
;* Return:  None

Colors	PROC \
	USES ds si, \
	logic:WORD, attr:WORD, row1:WORD, col1:WORD, row2:WORD, col2:WORD

	GetVidOffset row1, col1 	; Get offset in video segment
	inc	ax
	mov	si, ax			; SI = offset for 1st attr byte
	mov	bx, row2
	sub	bx, row1
	inc	bx			; BX = number of window rows
	mov	cx, col2
	sub	cx, col1
	inc	cx			; CX = number of columns

	mov	ds, vconfig.sgmnt	; DS = video segment
	mov	ax, attr		; AL = mask for and, xor, and or
loop1:	push	si			; Save ptr to start of line
	push	cx			;   and number of columns
	cmp	vconfig.adapter, CGA	; CGA adapter?
	jne	@F			; No?  Skip video disable

; Disable CGA video prior to memory access to avoid screen snow. (See the
; WinOpen and StrWrite procedures for further discussions on CGA snow.)

	call	DisableCGA		; Yes?	Disable video
@@:	cmp	logic, 1		; Rotate left?
	jl	c_not			; If less, do NOT
	je	c_rol			; If equal, do ROL
	cmp	logic, 3		; And?
	jl	c_ror			; If less, do ROR
	je	c_and			; If equal, do AND
	cmp	logic, 5		; Or?
	jl	c_xor			; If less, do XOR
	je	c_or			; If equal, do OR
					; Otherwise, do MOV
c_mov:	mov	BYTE PTR [si], al	; MOV attr parameter
	add	si, 2			;   into attribute byte
	loop	c_mov
	jmp	SHORT c_done
c_or:	or	BYTE PTR [si], al	; OR with attr parameter
	add	si, 2
	loop	c_or
	jmp	SHORT c_done
c_xor:	xor	BYTE PTR [si], al	; XOR with attr parameter
	add	si, 2
	loop	c_xor
	jmp	SHORT c_done
c_and:	and	BYTE PTR [si], al	; AND with attr parameter
	add	si, 2
	loop	c_and
	jmp	SHORT c_done
c_ror:	ror	BYTE PTR [si], 1	; Rotate right 1 bit
	add	si, 2
	loop	c_ror
	jmp	SHORT c_done
c_rol:	rol	BYTE PTR [si], 1	; Rotate left 1 bit
	add	si, 2
	loop	c_rol
	jmp	SHORT c_done
c_not:	not	BYTE PTR [si]		; Flip bits
	add	si, 2
	loop	c_not

c_done: cmp	vconfig.adapter, CGA
	jne	@F
	call	EnableCGA		; Reenable CGA video
@@:	pop	cx			; Recover number of columns
	pop	si			; Recover offset for start of line
	add	si, 160 		; Point to start of next line
	dec	bx			; Decrement row counter
	jnz	loop1			; Loop while rows remain
	ret				; Exit when all lines complete

Colors	ENDP


;* Exec - Executes a child process.  Exec handles the usual chores associated
;* with spawning a process:  (1) parsing the command line tail and loading the
;* FCBs with the first two arguments; (2) setting and restoring the vectors
;* for Interrupts 1Bh, 23h, and 24h; and (3) querying DOS for the child's
;* return code.
;*
;* Shows:   DOS Functions - 29h (Parse Filename)
;*			    25h (Set Interrupt Vector)
;*			    35h (Get Interrupt Vector)
;*			    4Bh (Execute Program)
;*			    4Dh (Get Return Code)
;*
;* Params:  spec - Pointer to ASCIIZ specification for program file
;*		   (must include .COM or .EXE extension)
;*	    block - Pointer to parameter block structure
;*	    break - Pointer to new Ctrl-Break (Interrupt 1Bh) handler
;*	    ctrlc - Pointer to new Ctrl-C (Interrupt 23h) handler
;*	    criterr - Pointer to new Critical Error (Interrupt 24h) handler
;*
;* Return:  Short integer with child return code, or -1 for EXEC error

Exec	PROC \
	USES ds si di, \
	spec:PTR BYTE, block:PTR parmblk, break:PTR BYTE, \
	ctrlc:PTR BYTE, criterr:PTR BYTE

	jmp	SHORT @F		; Jump over data area

old_1Bh DD	WORD PTR ?		; Keep vectors for Interrupts
old_23h DD	WORD PTR ?		;   1Bh, 23h, and 24h in
old_24h DD	WORD PTR ?		;   code segment
old_stk DD	WORD PTR ?		; Keep stack pointer

@@:	Vector 1Bh, cs:old_1Bh, break	; Save, replace Int 1Bh vector
	Vector 23h, cs:old_23h, ctrlc	; Save, replace Int 23h vector
	Vector 24h, cs:old_24h, criterr ; Save, replace Int 24h vector

	LoadPtr ds, bx, block		; Point DS:BX to parameter block
	push	ds			; Save segment address
	les	di, [bx].fcb1		; Point ES:DI to first FCB
	lds	si, [bx].taddr		; Point DS:SI to command line tail
	inc	si			; Skip over count byte

	mov	ax, 2901h		; Set AH to request Function 29h
					; AL = flag to skip leading blanks
	int	21h			; Parse command-line into first FCB
	pop	es			; Recover seg addr of parameter block
	les	di, es:[bx].fcb2	; Point ES:DI to second FCB
	mov	ax, 2901h		; Request DOS Function #29h again
	int	21h			; Parse command-line into second FCB

	push	bp			; Save only important register
	mov	WORD PTR cs:old_stk[0], sp
	mov	WORD PTR cs:old_stk[2], ss
	LoadPtr es, bx, block		; ES:BX points to param block
	LoadPtr ds, dx, spec		; DS:DX points to path spec
	mov	ax, 4B00h		; AH = DOS Function 4Bh
					; AL = 0 for load and execute
	int	21h			; Execute Program
	mov	sp, WORD PTR cs:old_stk[0] ; Reset stack pointers
	mov	ss, WORD PTR cs:old_stk[2]
	pop	bp			; Recover saved register

; Restore vectors for Interrupts 1Bh, 23h, and 24h.

	mov	ax, 251Bh		; AH = DOS Function 25h
					; AL = interrupt number
	lds	dx, cs:old_1Bh		; DS:DX = original vector
	int	21h			; Set Interrupt 1Bh Vector
	mov	al, 23h 		; AL = interrupt number
	lds	dx, cs:old_23h		; DS:DX = original vector
	int	21h			; Set Interrupt 23h Vector
	mov	al, 24h 		; AL = interrupt number
	lds	dx, cs:old_24h		; DS:DX = original vector
	int	21h			; Set Interrupt 24h Vector

	mov	ax, -1			; Set error code
	jc	exit			; If EXEC error, exit
	mov	ah, 4Dh 		; Else request child's code
	int	21h			; Get Return Code
	sub	ah, ah			; Make short integer
exit:	ret

Exec	ENDP


;* BinToHex - Converts binary word to 6-byte hexadecimal number in
;* ASCIIZ string. String is right-justified and includes "h" radix.
;*
;* Shows:   Instruction - xlat
;*
;* Params:  num - Number to convert to hex string
;*	    str - Pointer to 6-byte string
;*
;* Return:  None

	.DATA
hex	DB	'0123456789ABCDEF'	; String of hex numbers
	.CODE

BinToHex PROC \
	USES di, \
	num:WORD, str:PTR BYTE

	LoadPtr es, di, str		; Point ES:DI to 6-byte string
	mov	bx, OFFSET hex		; Point DS:BX to hex numbers
	mov	ax, num 		; Number in AX
	mov	cx, 2			; Loop twice for two bytes

loop1:	xchg	ah, al			; Switch bytes
	push	ax			; Save number
	shr	al, 1			; Shift high nibble to low
	shr	al, 1
	shr	al, 1
	shr	al, 1
	xlat				; Get equivalent ASCII number in AL
	stosb				; Copy to 6-byte string, increment DI
	pop	ax			; Recover number
	push	ax			; Save it again
	and	al, 00001111b		; Mask out high nibble
	xlat				; Get equivalent ASCII number in AL
	stosb				; Copy to 6-byte string, increment DI
	pop	ax			; Recover number
	loop	loop1			; Do next byte
	mov	ax, 'h' 		; Put null, 'h' radix in AX
	stosw				; Copy to last two bytes in string
	ret

BinToHex ENDP


;* NewBlockSize - Adjusts size of allocated memory block.
;*
;* Shows:   DOS Function - 4Ah (Resize Memory Block)
;*
;* Params:  addr - Segment address of block
;*	    resize - Requested block size in paragraphs
;*
;* Return:  Short integer error code
;*	    0 if successful
;*	    1 if error

NewBlockSize PROC \
	addr:WORD, resize:WORD

	mov	ax, addr		; Get block address
	mov	es, ax			; Point ES to block
	mov	bx, resize		; New block size
	mov	ah, 4Ah 		; Function number
	int	21h			; Resize Memory Block
	ret

NewBlockSize ENDP


;* Initialize - Initializes global variables _psp and _env, which are defined
;* in the DEMO.INC include file. If used with a DOS version less than 3.0,
;* this procedure will not produce valid results unless it is called before
;* changing the ES register. This is because at program entry ES points to
;* the Program Segment Prefix (PSP).
;*
;* Params:  None
;*
;* Return:  None

Initialize PROC

	call	GetPSP			; Get segment address of PSP
	or	ax, ax			; DOS version less than 3.0?
	jz	@F			; Yes?	Assume ES points to PSP
	mov	es, ax			; No?  Reload ES with PSP address
@@:	mov	_psp, es		; Initialize variable with PSP address
	mov	ax, es:[2Ch]		; Get environment seg from PSP
	mov	_env, ax		; Store it
	ret

Initialize ENDP

	END
