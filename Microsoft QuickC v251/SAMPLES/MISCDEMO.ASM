;* MISCDEMO - Invokes many of the QuickAssembler example procedures, most of
;* them demonstrating assembly language instructions and calls to the system
;* BIOS. MISCDEMO demonstrates how to:
;*
;*	   -   determine hardware information
;*	   -   display time and date while waiting for keystrokes
;*	   -   play notes of any frequency on the speaker
;*	   -   change the line mode for EGA or VGA systems
;*	   -   create non-destructive pop-up windows
;*	   -   execute another program as a child process
;*	   -   create primitive handlers for Interrupts 1Bh, 23h, and 24h
;*	   -   use C-callable procedures in assembly programs
;*	   -   use simplified segment directives
;*	   -   write model-independent procedures
;*	   -   declare and initialize data with DUP, DB, DW, and DD
;*	   -   create structures with the STRUCT directive
;*	   -   declare macros
;*	   -   set up a dispatch table
;*
;* MISCDEMO.EXE is built from the following files:
;*    MISCDEMO.ASM - Main program
;*    MISC.ASM	   - QuickAssembler procedures for MISCDEMO
;*    COMMON.ASM   - QuickAssembler procedures shared by other example programs
;*    DEMO.INC	   - Include file with macros, structure declarations
;*
;* Procedures:	GetVidConfig	GetCurPos	VeriPrint	GetPSP
;*		WinOpen 	VeriAnsi	VeriCop 	GetVer
;*		WinClose	StrWrite	SetLineMode	NewBlockSize
;*		SetCurSize	GetKeyClock	BinToHex	IntToAsc
;*		SetCurPos	GetShift	Sound		Colors
;*		GetCurSize	GetMem		Pause		Exec
;*		WriteTTY	Initialize

	DOSSEG
	.MODEL small, c
	INCLUDE demo.inc

PGMSIZE EQU	500h			; Maximum program size in paragraphs
F1	EQU	59			; Extended code for first option key
F7	EQU	65			; Extended code for last option key
CLKRW	EQU	0			; Row for on-screen clock
CLKCL	EQU	62			; Column for on-screen clock

;* Box - Macro to color portion of screen for effect. Not to be confused with
;* the WinOpen procedure, which is far more capable.
;*
;* Params:  row1 - Screen row at top of box
;*	    col1 - Screen column at left side of box
;*	    row2 - Screen row at bottom of box
;*	    col2 - Screen column at right side of box

Box MACRO row1, col1, row2, col2
    LOCAL sk
    mov ax, 0600h			;; Scroll service
    mov bh, filmono			;; Fill attribute
    cmp vconfig.adapter, MDA		;; Monochrome?
    je	sk				;; Yes?  Continue
    mov bh, filcolr			;; No?	Use color fill attribute
sk: mov ch, row1
    mov cl, col1			;; CX = row/col for upper left
    mov dh, row2
    mov dl, col2			;; DX = row/col for lower right
    int 10h				;; Blank window area on screen
ENDM

	.STACK
	.DATA

oldmode DB	?			; Original video mode
oldcurs DW	?			; Original cursor coordinates
keepseg DW	?			; Segment addr, orig screen
buffer	DB	BUFFER_SIZE DUP(?)	; Buffer for diskette read
filcolr DB	1Fh, 20h, 3Bh, 4Eh	; Color fill attributes
filmono DB	70h, 89h, 78h, 1	; Monochrome fill attributes
fill	DB	7			; Default attribute for menu
filsub	DB	?			; Fore/background colors in submenu

presmsg DB	'. . . press a key to continue', 0
yes	DB	'yes'
no	DB	'no '

; Main menu text

menu1	DB	'***  QuickAssembler Misc Demonstration Program  ***', 0
menu2	DB	'F1  System Configuration', 0
menu3	DB	'F2  Speaker Test', 0
menu4	DB	'F3  Toggle Line Mode', 0
menu5	DB	'F4  Windows', 0
menu6	DB	'F5  Screen Colors', 0
menu7	DB	'F6  Exec Program', 0
menu8	DB	'Select an option, or press ESC to quit:', 0

; Option F1 - System Configuration

monostr DB	'monochrome'
clrstr	DB	'color     '
adapstr DB	'MDA CGA MCGAEGA VGA '
vidmsg1 DB	'Adapter:                 xxxx', 0
vidmsg2 DB	'Display:                 xxxxxxxxxx', 0
vidmsg3 DB	'Mode:                    xx', 0
vidmsg4 DB	'Rows:                    xx', 0
memmsg1 DB	'Total memory:            xxxx Kb', 0
memmsg2 DB	'Available memory:        xxxx Kb', 0
prnmsg	DB	'Printer ready:           xxx', 0
ansimsg DB	'ANSI driver installed:   xxx', 0
copmsg	DB	'Coprocessor installed:   xxx', 0
LEN1	EQU	$ - copmsg - 4

; Option F3 - Toggle Line Mode

linemsg DB	'Line mode reset available only for EGA or VGA', 0

; Option F4 - Windows

winmsg	DB	'WINDOW x', 0
LEN3	EQU	$ - winmsg - 2

; Option F5  Screen Colors

cmsg1	DB	'Toggle                   Step', 0
cmsg2	DB	'컴컴컴컴컴컴컴컴         컴컴컴컴컴컴컴컴컴', 0
cmsg3	DB	'B  blink                 ', 27, 26, '  foreground', 0
cmsg4	DB	'I  intensity             ', 24, 25, '  background', 0
cmsg5	DB	'Foreground:  press F, then color number 0-7', 0
cmsg6	DB	'Background:  press A, then color number 0-7', 0
cmsg7	DB	'Color Numbers', 0
cmsg8	DB	'컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�', 0
cmsg9	DB	'0  black                     4  red', 0
cmsg10	DB	'1  blue                      5  magenta', 0
cmsg11	DB	'2  green                     6  brown', 0
cmsg12	DB	'3  cyan                      7  white', 0
cmsg13	DB	'Toggle', 0
cmsg14	DB	'컴컴컴컴컴컴컴�', 0
cmsg15	DB	'B  blink', 0
cmsg16	DB	'I  intensity', 0
cmsg17	DB	'U  underline', 0
cmsg18	DB	'R  reverse', 0

; Option F6 - Exec Program

retmsg	DB	'Return code:  '
recode	DB	6 DUP (?)		; ASCII string for return code
execmsg DB	'Enter program file spec (including .COM or .EXE):', 0
tailmsg DB	'Enter command-line argument(s):', 0
fspec	DB	50, 50 DUP (?)		; File specification (max length = 50)
tail	DB	50, 50 DUP (?)		; Command-line tail (max length = 50)
fcblk1	DB	0			; Allocate space for 1st FCB
	DB	11 DUP (?)
	DB	25 DUP (0)
fcblk2	DB	0			; Allocate space for 2nd FCB
	DB	11 DUP (?)
	DB	25 DUP (0)
pb	parmblk <>			; Parameter block structure

; Initialize dispatch table with offsets for internal procedures.

table	DW	get_config, speaker, set_lines
	DW	pop_windows, set_attrs, exec_pgm


	.CODE

	EXTRN GetVidConfig:PROC,  GetCurPos:PROC,    VeriPrint:PROC
	EXTRN GetPSP:PROC,        WinOpen:PROC,      VeriAnsi:PROC
	EXTRN VeriCop:PROC,       WinClose:PROC,     WriteTTY:PROC
	EXTRN StrWrite:PROC,      SetLineMode:PROC,  NewBlockSize:PROC
	EXTRN SetCurSize:PROC,    GetKeyClock:PROC,  BinToHex:PROC
	EXTRN SetCurPos:PROC,     GetShift:PROC,     Sound:PROC
	EXTRN GetCurSize:PROC,    GetMem:PROC,       Pause:PROC
	EXTRN IntToAsc:PROC,      Colors:PROC,       GetVer:PROC
	EXTRN Exec:PROC,          Initialize:PROC


	.STARTUP

	call	Initialize		; Initialize _psp and _env variables
	mov	ax, PGMSIZE		; Shrink memory block
	push	ax			;   allocated to program
	push	_psp			; Push PSP segment address
	call	NewBlockSize		; Return unused memory to DOS
	add	sp, 4			; Clean stack
	call	GetVidConfig		; Initialize variables
	mov	al, vconfig.rows
	mov	oldmode, al		; Preserve original line mode
	call	GetCurPos		; Get current cursor position
	mov	oldcurs, ax		; Store it
	mov	ax, 7
	push	ax			; Pass display attribute = 7
	mov	al, 79
	push	ax			; Pass right column
	mov	al, vconfig.rows
	push	ax			; Pass bottom row
	sub	al, al
	push	ax			; Pass left column
	push	ax			;   and top row
	call	WinOpen 		; Preserve original screen
	add	sp, 10			; Clean stack
	mov	keepseg, ax		; Keep segment address
	or	ax, ax			; Window opened successfully?
	jnz	renew			; Yes?	Continue
	.EXIT	1			; No?  Exit with return code = 1

renew:	call	disp_menu		; Display main menu
	Box CLKRW, CLKCL-1, CLKRW, CLKCL+17 ; Highlight on-screen clock
	mov	ax, CLKCL		; Column for clock
	push	ax
	mov	ax, CLKRW		; Row for clock
	push	ax
	call	GetKeyClock		; Poll for keyboard selection
	add	sp, 4			; Clean stack
	cmp	al, ESCAPE		; Esc key?
	je	restr			; Yes?	Quit
	cmp	ah, F1			; No?  Then is scan code for
	jb	renew			;   one of the function keys
	cmp	ah, F7			;   between F1 and F7?
	ja	renew			; No?  Try again
	xchg	al, ah			; Yes?	Make AX = AH
	sub	al, F1			; Normalize to 0
	shl	al, 1			; Double to make word index
	mov	bx, ax			; BX = index to table
	call	table[bx]		; Call procedure
	jmp	SHORT renew		; Loop for another key

restr:	mov	al, oldmode		; Get original line mode
	cmp	al, vconfig.rows	; Same as current mode?
	je	@F			; Yes?	Continue
	inc	ax			; No?  Increment to 25/43/50
	push	ax			; Pass to procedure
	call	SetLineMode		; Restore line mode
	add	sp, 2			; Clean stack
@@:	push	keepseg 		; Segment with screen contents
	call	WinClose		; Restore original screen
	add	sp, 2			; Clean stack
	mov	ax, oldcurs
	push	ax			; Pass old cursor column coord
	mov	al, ah
	push	ax			; Pass old cursor row coord
	call	SetCurPos		; Restore cursor to orig place
	add	sp, 4			; Clean stack

	.EXIT	0			; Exit wih return code 0


;* disp_menu - Displays main menu.
;*
;* Uses:    vconfig - Video configuration structure, declared in the
;*	    DEMO.INC include file. The structure must first be
;*	    initialized by calling the GetVidConfig procedure.
;*
;* Return:  None

disp_menu PROC NEAR

	mov	ax, 0600h		; Scroll screen service
	mov	bh, fill		; Menu display attribute
	sub	cx, cx			; From row 0, col 0
	mov	dh, vconfig.rows	;   to bottom row,
	mov	dl, 79			;   rightmost column
	int	10h			; Clear entire screen
	DispText  4, 15, <OFFSET menu1> ; Display menu
	DispText  8, 28, <OFFSET menu2>
	DispText  9, 28, <OFFSET menu3>
	DispText 10, 28, <OFFSET menu4>
	DispText 11, 28, <OFFSET menu5>
	DispText 12, 28, <OFFSET menu6>
	DispText 13, 28, <OFFSET menu7>
	DispText 17, 15, <OFFSET menu8>
	mov	ax, 56
	push	ax			; Push column
	mov	al, 17
	push	ax			; Push row
	call	SetCurPos		; Park cursor at prompt
	add	sp, 4
	ret

disp_menu ENDP



;* press - Displays a prompt, then waits for a key press.
;*
;* Uses:    vconfig - Video configuration structure, declared in the
;*	    DEMO.INC include file. The structure must first be
;*	    initialized by calling the GetVidConfig procedure.
;*
;* Return:  None

press	PROC NEAR

	mov	dl, vconfig.rows
	DispText dx, 50, <OFFSET presmsg>
	mov	ax, 48
	push	ax
	mov	al, vconfig.rows	; Bottom row of screen
	push	ax
	call	SetCurPos		; Park cursor at prompt
	add	sp, 4			; Clean stack
	mov	ax, CLKCL		; Column for clock
	push	ax
	mov	ax, CLKRW		; Row for clock
	push	ax
	call	GetKeyClock		; Wait for keypress
	add	sp, 4			; Clean stack
	ret

press	ENDP



;* get_vidinfo - Initializes video configuration message for display.
;*
;* Uses:    vconfig - Video configuration structure, declared in the
;*	    DEMO.INC include file. The structure must first be
;*	    initialized by calling the GetVidConfig procedure.
;*
;* Return:  None

get_vidinfo PROC NEAR

	push	ds
	pop	es			; Point ES to data segment
	mov	al, 4			; Find index to 4-character
	mul	vconfig.adapter 	;   group in string
	add	ax, OFFSET adapstr	; Point AX to proper group
	mov	si, ax			; Put pointer in SI
	lea	di, vidmsg1[LEN1]	; Point to 1st line of message
	mov	cx, 2			; Copy 4 letters (adapter
	rep	movsw			;   designation) to message

	mov	si, OFFSET monostr	; Assume display is monochrome
	cmp	vconfig.display, MONO	; Then check with video struct
	je	@F			; Yes?	Continue
	mov	si, OFFSET clrstr	; No?  Point to "color" string
@@:	lea	di, vidmsg2[LEN1]	; Point to 2nd line of message
	mov	cx, 5			; Copy 10 chars ("monochrome"
	rep	movsw			;   or "color     ") to msg

	mov	al, vconfig.mode
	cbw				; AX = video mode
	call	IntToAsc		; Convert AX to ASCII
	xchg	ah, al			; Flip bytes for word write
	mov	WORD PTR vidmsg3[LEN1], ax	; Insert in message string

	mov	al, vconfig.rows
	cbw
	inc	ax			; AX = number of screen rows
	call	IntToAsc		; Convert to ASCII
	xchg	ah, al			; Flip bytes for word write
	mov	WORD PTR vidmsg4[LEN1], ax	; Insert in message string
	ret

get_vidinfo ENDP



;* get_mem - Initializes memory information message.
;*
;* Return:  None

get_mem PROC NEAR

	call	GetMem			; DX = total memory
	push	ax			; AX = available memory
	mov	ax, dx
	call	IntToAsc		; Convert AX to ASCII
	xchg	dh, dl			; Flip bytes for word write
	xchg	ah, al
	mov	WORD PTR memmsg1[LEN1], dx	; Insert in message
	mov	WORD PTR memmsg1[LEN1+2], ax	;   string
	pop	ax				; Recover avail memory #
	call	IntToAsc			; Convert to ASCII
	xchg	dh, dl				; Flip bytes for word write
	xchg	ah, al
	mov	WORD PTR memmsg2[LEN1], dx	; Insert in message
	mov	WORD PTR memmsg2[LEN1+2], ax	;   string
	ret

get_mem ENDP



;* check_printer - Initializes printer status message.
;*
;* Shows:   Instruction - movsb
;*
;* Return:  None

check_printer PROC NEAR

	push	ds
	pop	es			; Point ES to data segment
	mov	si, OFFSET yes		; Assume answer is "yes"
	call	VeriPrint		; Check if printer ready
	or	al, al			; Ready?
	jnz	@F			; Yes?	Continue
	mov	si, OFFSET no		; No?  Point to "no" answer
@@:	lea	di, prnmsg[LEN1]	; Point to print message
	mov	cx, 3			; Copy 3 letters (either "yes"
	rep	movsb			;   or "no ") to message
	ret

check_printer ENDP



;* check_ansi - Initializes status message for ANSI driver.
;*
;* Return:  None

check_ansi PROC NEAR

	push	ds
	pop	es			; Point ES to data segment
	mov	si, OFFSET yes		; Assume answer is "yes"
	call	VeriAnsi		; Check if driver installed
	or	al, al			; Installed?
	jnz	@F			; Yes?	Continue
	mov	si, OFFSET no		; No?  Point to "no" answer
@@:	lea	di, ansimsg[LEN1]	; Point to ansi message
	mov	cx, 3			; Copy 3 letters (either "yes"
	rep	movsb			;   or "no ") to message
	ret

check_ansi ENDP



;* check_coproc - Initializes coprocessor status message.
;*
;* Return:  None

check_coproc PROC NEAR

	push	ds
	pop	es			; Point ES to data segment
	mov	si, OFFSET yes		; Assume answer is "yes"
	call	VeriCop 		; Check for coprocessor
	or	al, al			; Installed?
	jnz	@F			; Yes?	Continue
	mov	si, OFFSET no		; No?  Point to "no" answer
@@:	lea	di, copmsg[LEN1]	; Point to coprocessor message
	mov	cx, 3			; Copy 3 letters (either "yes"
	rep	movsb			;   or "no ") to message
	ret

check_coproc ENDP



;* get_config - Displays system configuration information.

get_config PROC NEAR

	call	get_vidinfo		; Initialize video message
	call	get_mem 		; Initialize memory message
	call	check_printer		; Initialize printer message
	call	check_ansi		; Initialize ANSI driver msg
	call	check_coproc		; Initialize coprocessor msg
	Box 4, 13, 20, 67		; Clear screen with box
	DispText  6, 23, <OFFSET vidmsg1>
	DispText  7, 23, <OFFSET vidmsg2>
	DispText  8, 23, <OFFSET vidmsg3>
	DispText  9, 23, <OFFSET vidmsg4>
	DispText 11, 23, <OFFSET memmsg1>
	DispText 12, 23, <OFFSET memmsg2>
	DispText 14, 23, <OFFSET prnmsg>
	DispText 16, 23, <OFFSET ansimsg>
	DispText 18, 23, <OFFSET copmsg>
	call	press			; Prompt for keypress
	ret

get_config ENDP



;* speaker - Sounds speaker with ascending frequencies.
;*
;* Return:  None

speaker PROC NEAR

	sub	ax, ax
loop1:	add	ax, 100 		; Sound with frequencies
	cmp	ax, 3000		;   from 100 to 3000
	ja	exit
	push	ax			; Save frequency
	mov	bx, 1			; Use duration = 1 clock
	push	bx			; Pass duration
	push	ax			; Pass frequency
	call	Sound			; Beep speaker
	add	sp, 4			; Clean stack
	pop	ax
	jmp	SHORT loop1
exit:	ret

speaker ENDP



;* set_lines - Toggles between 25/43-line mode for EGA or 25/43/50-line mode
;* for VGA.
;*
;* Uses:    vconfig - Video configuration structure, declared in the
;*	    DEMO.INC include file. The structure must first be
;*	    initialized by calling the GetVidConfig procedure.
;*
;* Return:  None

set_lines PROC NEAR

	mov	al, 25			; Assume toggle to 25 line
	cmp	vconfig.rows, 49	; Current mode 50 lines?
	je	toggle			; Yes?	Toggle VGA to 25-line
	cmp	vconfig.rows, 42	; Current mode 43 lines?
	jne	@F			; No?  Must be 25
	cmp	vconfig.adapter, EGA	; Yes?	And is adapter EGA?
	je	toggle			; Yes?	Then toggle to 25 line
	mov	al, 50			; No?  Toggle VGA to 50 line
	jmp	SHORT toggle
@@:	mov	al, 43			; If currently 25 lines, make
					;   either EGA or VGA 43 lines
toggle: push	ax			; Pass requested mode param
	call	SetLineMode		; Change line mode
	add	sp, 2			; Clean stack
	or	al, al			; Error?
	jnz	e_exit			; Yes?	Display message
	call	GetVidConfig		; No?  Update configuration
	jmp	SHORT exit		;   structure and return

e_exit: Box 16, 13, 20, 67		; Display error message
	DispText 18, 17, <OFFSET linemsg>
	call	press
exit:	ret

set_lines ENDP



;* pop_windows - Demonstrates windowing with the WinOpen and WinClose
;* procedures.
;*
;* Uses:    vconfig - Video configuration structure, declared in the
;*	    DEMO.INC include file. The structure must first be
;*	    initialized by calling the GetVidConfig procedure.
;*
;* Return:  None

pop_windows PROC NEAR

	LOCAL row1:WORD, col1:WORD, row2:WORD, col2:WORD
	LOCAL index:BYTE, addr[4]:WORD, csize:WORD

	call	GetCurSize		; Get current cursor size
	mov	csize, ax		; Store it
	or	al, 100000b		; Set 5th bit for cursor off
	push	ax			; Bottom line (arbitrary)
	push	ax			; Top line (arbitrary)
	call	SetCurSize		; Turn cursor off
	add	sp, 4			; Clean stack
	mov	winmsg[LEN3], '0'	; Initialize window message
	mov	row1, 4 		; Initialize window coords
	mov	col1, 10
	mov	row2, 20
	mov	col2, 34
	mov	index, 0
	mov	cx, 4			; Open 4 windows
open:	push	cx			; Save loop counter
	mov	al, index
	mov	bx, OFFSET filmono	; BX points to fill attributes
	cmp	vconfig.display, MONO	; If monochrome, continue
	je	@F
	mov	bx, OFFSET filcolr	; Else repoint to color attributes
@@:	xlat				; Get attributes in succession
	push	ax			; Push fill attribute
	push	col2			; Push right column
	push	row2			; Push bottom row
	push	col1			; Push left column
	push	row1			; Push top row
	call	WinOpen 		; Open a window
	add	sp, 10			; Clean stack
	pop	di			; Recover counter in DI
	push	di			;   and save it again
	dec	di
	shl	di, 1			; Make DI a word index
	mov	addr[di], ax		; Save address of allocated
					;   block returned by WinOpen
	inc	winmsg[LEN3]		; Increment window number
	mov	bx, row1
	add	bl, 2			; Message row
	mov	cx, col1
	add	cl, 9			; Message column
	DispText bx, cx, <OFFSET winmsg>; Display "Window" message
	mov	ax, 18
	push	ax
	call	Pause			; Pause for approx 1 second
	add	sp, 2			; Clean stack
	add	row1, 2 		; Adjust coordinates for
	add	col1, 13		;   next window
	sub	row2, 2
	add	col2, 13
	inc	index
	pop	cx			; Recover counter
	loop	open

	mov	cx, 4			; Close 4 windows
	sub	di, di			; DI = index to addresses
close:	push	cx			; Save loop counter
	push	addr[di]		; Push allocation address
	call	WinClose		; Close the window associated
	add	sp, 2			;   with allocated block
	mov	ax, 18
	push	ax
	call	Pause			; Pause for 1 second
	add	sp, 2
	add	di, 2			; Point to next address
	pop	cx			; Recover counter
	loop	close			; Close another window

	mov	ax, csize		; Get original cursor size
	push	ax			; Push bottom line number
	mov	al, ah
	push	ax			; Push top line number
	call	SetCurSize		; Restore cursor size
	add	sp, 4			; Clean stack

	ret

pop_windows ENDP



;* set_ attrs - Changes display attributes for the main menu.
;*
;* Uses:    vconfig - Video configuration structure, declared in the
;*	    DEMO.INC include file. The structure must first be
;*	    initialized by calling the GetVidConfig procedure.
;*
;* Return:  None

set_attrs PROC NEAR

	Box 3, 12, 23, 68
	cmp	vconfig.adapter, MDA	; Monochrome?
	jne	@F
	jmp	d_mono
@@:	DispText  4, 18, <OFFSET cmsg1> ; Display "colors" menu for
	DispText  5, 18, <OFFSET cmsg2> ;   color system
	DispText  6, 22, <OFFSET cmsg3>
	DispText  7, 22, <OFFSET cmsg4>
	DispText 10, 18, <OFFSET cmsg5>
	DispText 11, 18, <OFFSET cmsg6>
	DispText 14, 18, <OFFSET cmsg7>
	DispText 15, 18, <OFFSET cmsg8>
	DispText 16, 22, <OFFSET cmsg9>
	DispText 17, 22, <OFFSET cmsg10>
	DispText 18, 22, <OFFSET cmsg11>
	DispText 19, 22, <OFFSET cmsg12>
	mov	al, filcolr		; Initialize filsub variable
	mov	filsub, al		;   for color
	jmp	prompt

d_mono: DispText  8, 32, <OFFSET cmsg13> ; Display "colors" menu for
	DispText  9, 32, <OFFSET cmsg14> ;   monochrome system
	DispText 10, 36, <OFFSET cmsg15>
	DispText 11, 36, <OFFSET cmsg16>
	DispText 12, 36, <OFFSET cmsg17>
	DispText 13, 36, <OFFSET cmsg18>
	mov	al, filmono		; Initialize filsub variable
	mov	filsub, al		;   for monochrome

prompt: DispText 22, 15, <OFFSET menu8>
	mov	ax, 56
	push	ax
	mov	al, 22
	push	ax
	call	SetCurPos		; Park cursor at prompt
	add	sp, 4			; Clean stack

poll:	mov	ax, CLKCL		; Column for clock
	push	ax
	mov	ax, CLKRW		; Row for clock
	push	ax
	call	GetKeyClock		; Wait for keypress
	add	sp, 4			; Clean stack
	cmp	al, ESCAPE		; Esc key?
	jne	@F			; No?  Continue
	jmp	exit			; Yes?	Exit

@@:	cmp	al, 'a' 		; Convert letters to uppercase
	jb	@F			;   to make comparisons easier
	cmp	al, 'z'
	ja	@F
	and	al, 5Fh

@@:	cmp	al, 'B' 		; Request blink toggle?
	je	blink
	cmp	al, 'I' 		; Request intensity toggle?
	je	intens
	mov	bl, filsub		; Get window display attribute
	cmp	vconfig.adapter, MDA	; Monochrome?
	jne	colr			; No?  Jump to color selections
	cmp	al, 'U' 		; Request underline toggle?
	je	under
	cmp	al, 'R' 		; Request reverse toggle?
	jne	poll			; No?  Then skip invalid key

; What with cross-toggling between reverse, normal, and underline, three
; bit settings can exist in monochrome:  x111x000 for reverse, x000x111 for
; normal, and x000x001 for underline. Changing between the three involves
; more than simply XOR-ing the current attribute; each condition must check
; for the other two.

rever:	test	bl, 1			; Reverse video on?
	jz	@F			; Yes?	Go to next step
	or	bl, 00000111b		; No?  Ensure normal bits are on
@@:	xor	bl, 01110111b		; Toggle for reverse/normal
	mov	cl, 6			; Set code for MOV
	jmp	switch
under:	test	bl, 1			; Reverse video on?
	jnz	@F			; No?  Go to next step
	and	bl, 10001111b		; Yes?	Clear bits 4-6 and
	or	bl, 00000111b		;   set bits 0-2
@@:	xor	bl, 00000110b		; Toggle bits 1-2 for underline
	mov	cl, 6			; Set code for MOV
	jmp	switch

; Blink and intensity use the same bits for color and monochrome.

blink:	mov	bl, 10000000b		; Set bit 7 for blink
	mov	cl, 4			; Set code for XOR
	jmp	switch
intens: mov	bl, 00001000b		; Set bit 3 for intensity
	mov	cl, 4			; Set code for XOR
	jmp	switch

; Enter this section only for color displays. First check for arrow keys,
; which increment or decrement the foreground or background bits of the
; current attribute stored in the variable filsub. If arrow keys are not
; pressed, check for the F or A keys, which request specific colors for the
; foreground or background colors.

colr:	mov	ch, bl			; Copy current attribute to CH
	cmp	ah, 72			; Up arrow?
	jne	@F			; No?  Continue check
	mov	cl, 4			; Yes?	Increment bits 4-6
	shr	ch, cl			;   to next background color
	inc	ch
	and	ch, 00000111b
	shl	ch, cl
	mov	dl, 10001111b		; Set background mask
	jmp	SHORT step

@@:	cmp	ah, 75			; Left arrow?
	jne	@F			; No?  Continue check
	inc	ch			; Yes?	Increment bits 0-2
	and	ch, 00000111b		;   to next foreground color
	mov	dl, 11111000b		; Set foreground mask
	jmp	SHORT step

@@:	cmp	ah, 77			; Right arrow?
	jne	@F			; No?  Continue check
	dec	ch			; Yes?	Decrement bits 0-2
	and	ch, 00000111b		;   to previous foreground color
	mov	dl, 11111000b		; Set foreground mask
	jmp	SHORT step

@@:	cmp	ah, 80			; Down arrow?
	jne	chk_fa			; No?  Continue check
	mov	cl, 4			; Yes?	Decrement bits 4-6
	shr	ch, cl			;   to previous background color
	dec	ch
	and	ch, 00000111b
	shl	ch, cl
	mov	dl, 10001111b		; Set background mask

step:	and	bl, dl			; Mask out fore or back bits
	or	bl, ch			; Copy into original attribute
	mov	filsub, bl		; Store the new submenu color
	mov	cl, 6			; Request move operation in
	jmp	SHORT switch		;   Colors procedure

; This section checks for the F or A keys; if found it checks again for
; a number key between 0 and 7, then inserts the correct foreground or
; background bit pattern into the current fill attribute.

chk_fa: sub	cx, cx			; Clear flag for foreground request
	cmp	al, 'F' 		; Request to set foreground color?
	je	@F			; Yes?	Continue
	cmp	al, 'A' 		; Request to set background color?
	jne	gopoll			; No?  Then skip invalid key
	inc	cx			; Set flag for background request
@@:	push	cx			; Save flag
	mov	ax, CLKCL		; Column for clock
	push	ax
	mov	ax, CLKRW		; Row for clock
	push	ax
	call	GetKeyClock		; Get color number from keyboard
	add	sp, 4			; Clean stack
	pop	cx			; Recover flag
	cmp	al, '0' 		; Check for proper number
	jb	gopoll			;   between 0 and 7
	cmp	al, '7'
	jbe	@F
gopoll: jmp	poll			; If not valid key, ignore it

@@:	xor	al, '0' 		; Convert ASCII numeral into binary
	mov	dl, 11111000b		; Set foreground mask
	jcxz	@F			; Skip if foreground request
	mov	cl, 4			; Otherwise shift bits 0-2
	shl	al, cl			;   to positions 4-6
	mov	dl, 10001111b		; Set background mask
@@:	mov	bl, filsub
	and	bl, dl			; Mask out fore or back bits
	or	bl, al			; Insert number into fore or back bits
	mov	filsub, bl		; Store the new submenu color
	mov	cl, 6			; Request move

switch: mov	ax, 68
	push	ax			; Push window right column
	mov	al, 23
	push	ax			; Push window bottom row
	mov	al, 12
	push	ax			; Push window left column
	mov	al, 3
	push	ax			; Push window top row
	push	bx			; Push new attribute
	push	cx			; Push logic code
	call	Colors			; Reset new attributes in window
	add	sp, 12
	mov	ah, 8			; Function 8, get char/attribute
	mov	bh, vconfig.dpage
	int	10h			; Get attribute in AH
	mov	fill, ah		; New fill variable for main menu
	mov	filsub, ah		;   and for submenu
	jmp	poll

exit:	ret

set_attrs ENDP



;* exec_pgm - Executes a specified program as a child process.
;*
;* Uses:    vconfig - Video configuration structure, declared in the
;*	    DEMO.INC include file. The structure must first be
;*	    initialized by calling the GetVidConfig procedure.
;*	    pb - Parameter block structure, declared in the DEMO.INC file
;*
;* Return:  None

exec_pgm PROC NEAR

	Box 16, 13, 20, 67
	DispText 17, 16, <OFFSET execmsg> ; Display prompt for file spec
	mov	ax, 16
	push	ax
	mov	al, 19
	push	ax
	call	SetCurPos		; Park cursor below prompt
	add	sp, 4			; Clean stack
	mov	ah, 0Ah 		; Request DOS to read keyboard
	mov	dx, OFFSET fspec	;   input into fspec string
	int	21h			; Read Buffered Keyboard Input

	Box 16, 13, 20, 67
	DispText 17, 16, <OFFSET tailmsg> ; Display prompt for command tail
	mov	ax, 16
	push	ax
	mov	al, 19
	push	ax
	call	SetCurPos		; Park cursor below prompt
	add	sp, 4			; Clean stack
	mov	ah, 0Ah 		; Request DOS to read keyboard
	mov	dx, OFFSET tail 	;   input into tail string
	int	21h			; Read Buffered Keyboard Input

	sub	bh, bh			; Clear BH
	mov	si, OFFSET fspec	; DS:SI points to file spec string
	mov	bl, [si+1]		; BL = number of chars in spec
	mov	BYTE PTR [si+bx+2], 0	; Terminate string with 0

	mov	ax, _env		; Get segment address of environment
	mov	pb.env, ax		; Copy it to parameter block
	mov	ax, @data		; AX points to data segment
	lea	bx, tail[1]		; BX points to command-line tail
	mov	WORD PTR pb.taddr[0], bx; Copy address of command-line tail
	mov	WORD PTR pb.taddr[2], ax;   to parameter block
	mov	bx, OFFSET fcblk1	; BX points to first FCB
	mov	WORD PTR pb.fcb1[0], bx ; Copy address of first FCB
	mov	WORD PTR pb.fcb1[2], ax ;   to parameter block
	mov	bx, OFFSET fcblk2	; BX points to second FCB
	mov	WORD PTR pb.fcb2[0], bx ; Copy address of second FCB
	mov	WORD PTR pb.fcb2[2], ax ;   to parameter block

; At this point, the program file is specified, the command line tail is set,
; and the parameter block is properly initialized. The Exec procedure will
; take care of loading the FCBs with command-line arguments and resetting
; interrupt vectors. Now blank the screen in preparation for executing the
; process and pass the five pointers to the Exec procedure.

	mov	ax, 0600h		; AH = scroll service, AL = 0
	mov	bh, 7			; Blank with normal attribute
	sub	cx, cx			; From row 0, col 0
	mov	dh, vconfig.rows	;   to bottom row
	mov	dl, 79			;   and rightmost column
	int	10h			; Blank screen
	sub	al, al
	push	ax			; Push column
	push	ax			; Push row
	call	SetCurPos		; Set cursor at top of screen
	add	sp, 4			; Clean stack

	IF @CodeSize			; If medium or large model,
	push	cs			;   pass code segment
	ENDIF
	mov	ax, OFFSET NewCritErr	; Pass pointer to new critical
	push	ax			;   error handler
	IF @CodeSize
	push	cs
	ENDIF
	mov	ax, OFFSET NewCtrlC	; Pass pointer to new Ctrl-C
	push	ax			;   error handler
	IF @CodeSize
	push	cs
	ENDIF
	mov	ax, OFFSET NewBreak	; Pass pointer to new
	push	ax			;   Ctrl-Break handler
	IF @DataSize
	push	ds
	ENDIF
	mov	ax, OFFSET pb		; Pass far pointer to
	push	ax			;   parameter block
	IF @DataSize
	push	ds
	ENDIF
	lea	bx, fspec[2]		; Pass far pointer to
	push	bx			;   file specification

	call	Exec			; Exec specified program
	IF @CodeSize
	add	sp, 6			; Clean stack (far code)
	ENDIF
	IF @DataSize
	add	sp, 4			; Clean stack (far data)
	ENDIF
	add	sp, 10			; Clean remainder of stack

	cmp	ax, -1			; Successful?
	je	e_exit			; No?  Beep speaker and exit
	IF @DataSize			; Yes? Prepare to display return code
	push	ds
	ENDIF
	mov	bx, OFFSET recode
	push	bx			; Pass pointer to 6-byte string
	push	ax			; Pass return code
	call	BinToHex		; Convert return code to string
	IF @DataSize
	add	sp, 6
	ELSE
	add	sp, 4			; Clean stack
	ENDIF
	call	GetVidConfig		; Update video structure
	Box CLKRW, CLKCL-1, CLKRW, CLKCL+17	; Highlight on-screen clock
	Box vconfig.rows, 0, vconfig.rows, 79	; Highlight bottom row
	mov	dl, vconfig.rows
	DispText dx, 0, <OFFSET retmsg> ; Display return code at bottom,
	call	press			;   wait for keypress,
	jmp	SHORT exit		;   and exit

e_exit: mov	ax, 0E07h		; Write ASCII 7 character
	int	10h			;   (bell) to console
exit:	ret

exec_pgm ENDP



;* The following three procedures are primitive handlers for Interrupt 1Bh
;* (Ctrl-Break), Interrupt 23h (Ctrl-C), and Interrupt 24h (Critical Error).
;* The purpose of an interrupt handler in this context is to prevent termina-
;* tion of both parent and child processes when the interrupt is invoked.
;* Such handlers often set flags to signal a process that the interrupt has
;* been called.

;* NewBreak - Handler for Interrupt 1Bh.

NewBreak PROC

	sti				; Reenable interrupts
	push	ax			; Preserve AX register
	mov	al, 20h 		; Send end-of-interrupt signal
	out	20h, al 		;   to interrupt controller
	pop	ax			; Recover AX register
	iret				; Return from handler
					;   without taking action
NewBreak ENDP


;* NewCtrlC - Handler for Interrupt 23h.

NewCtrlC PROC

	iret				; Return from handler
					;   without taking action
NewCtrlC ENDP


;* NewCritErr - Handler for Interrupt 24h.

NewCritErr PROC

	sub	al, al			; Tell DOS to ignore error
	iret				; Return from handler
					;   without taking action
NewCritErr ENDP

	END
