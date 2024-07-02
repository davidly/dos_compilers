;_ msmouse.asm   Tue Jul 19 1988   Modified by: Walter Bright */
; Copyright (C) 1987-1988 by Walter Bright
; All Rights Reserved
; Written by Walter Bright
; Interface to Microsoft Mouse

; The mouse coordinate system is left-handed for both text and graphics modes,
; with 0,0 being the upper left corner. Note that the display package
; uses a left-handed coordinate system, but Flash Graphics uses a
; right-handed system.
; Also note that the mouse coordinates in text mode are not in character
; coordinates!(?)
;
; To convert from fg coordinates to mouse coords:
;	mouse_x = fg_x;
;	mouse_y = fg_displaybox[FG_Y2] - fg_y;
; To convert from display (character) coordinates to mouse coords:
;	if (40 column mode)
;	    mouse_x = display_x * 16;
;	else
;	    mouse_x = display_x * 8;
;	mouse_y = display_y * 8;
;
; The Microsoft mouse sometimes gets the number of screen rows wrong in text
; mode, so the recommended method of opening the mouse if the display package
; is also used is:
;	disp_open();			/* initialize display		*/
;	msm_init();			/* initialize mouse		*/
;
;	/* Mouse driver sometimes gets the number of screen rows wrong,	*/
;	/* so here we force it to whatever disp_open() discovered.	*/
;	msm_setareay(0,(disp_numrows - 1) * 8);
;
;	msm_showcursor();		/* turn mouse cursor on		*/
;
; For more information refer to the Microsoft Mouse User's Guide.

    ifndef __OS2__	;it's in MOU.C

include	macros.asm

	c_public msm_init,msm_term,msm_showcursor,msm_hidecursor
	c_public msm_getstatus,msm_setcurpos,msm_getpress,msm_getrelease
	c_public msm_setareax,msm_setareay,msm_setgraphcur,msm_settextcur
	c_public msm_readcounters,msm_signal,msm_lightpenon,msm_lightpenoff
	c_public msm_setratio,msm_condoff,msm_setthreshhold


mouse	macro	func
	ifnb	<func>
	 mov	AX,func
	endif
	int	33h
	endm

	begdata

msm_inited	dw	0	;set to !=0 if there is a mouse

	enddata

	begcode	msmouse

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Syntax:
;	int msm_init(void);
; Initialize mouse driver:
;	o Turn off all mouse interrupts
;	o Turn on light pen emulation
;	o If in graphics mode, set cursor to be an arrow, if in text mode,
;	  set cursor to be inverse video
;	o Set cursor to middle of screen
;	o Turn off cursor display
;	o Set min/max cursor position to full screen
;	o Set mickey/pixel to 1/1 in the x direction and 2/1 in the y
; Returns:
;	0	failed
;	-1	success

func	msm_init
L1:	clr	AX
	mov	ES,AX
	;Some versions of DOS have 0 in the vector table for interrupt 33h
	.if	<word ptr ES:0CCh> ne AX, L3
	.if	<word ptr ES:0CEh> e AX, L2
L3:	mouse
L2:	mov	msm_inited,AX
	ret
c_endp	msm_init

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Syntax:
;	void msm_term(void);
; Terminate mouse driver. This should be called before the program is
; exited if the mouse was used.

func	msm_term
	jmp	L1		;the init routine will fix things up
c_endp	msm_term

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Syntax:
;	void msm_showcursor(void);
; Show cursor. That is, increment the cursor flag. If the cursor flag is
; 0, then the cursor is displayed. Since msm_init() sets the value of
; the cursor flag to -1, msm_showcursor() must be called after msm_init()
; in order for the cursor to appear.
; Note that showcursor and hidecursor can be nested. That is, if n
; hidecursors were done, then n showcursors must be done in order to
; show the cursor.
; Generally, the point is to remove the cursor before any screen I/O
; is done, and then restore the cursor.

func	msm_showcursor
	.if	msm_inited e 0, S1
	mouse	1
S1:	ret
c_endp	msm_showcursor

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Syntax:
;	void msm_hidecursor(void);
; Hide cursor. Decrement the cursor flag. Complement to msm_showcursor().

func	msm_hidecursor
	.if	msm_inited e 0, H1
	mouse	2
H1:	ret
c_endp	msm_hidecursor

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Syntax:
;	int msm_getstatus(unsigned *curposx,unsigned *curposy);
; Get status.
; Output:
;	*curposx,*curposy =	mouse position
; Returns:
;	Bit 0:	left button (1 == down, 0 == up)
;	Bit 1:	right button
;	Bit 2:	middle button (for some mice)
;	Ignore other bits.

func	msm_getstatus
	push	BP
	mov	BP,SP
	.if	msm_inited e 0, G1
	mouse	3
	mov	AX,BX		;button status
	jmps	msm1

G1:	clr	AX
	cwd
	mov	CX,AX
msm1:
    if SPTR
	mov	BX,P[BP]
	mov	[BX],CX		;M3
	mov	BX,P+SIZEPTR[BP]
	mov	[BX],DX		;M4
    else
	les	BX,P[BP]
	mov	ES:[BX],CX	;M3
	les	BX,P+SIZEPTR[BP]
	mov	ES:[BX],DX	;M4
    endif
	pop	BP
	ret
c_endp	msm_getstatus

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Syntax:
;	void msm_setcurpos(unsigned curposx,unsigned curposy);
; Set cursor position.
; The upper left corner of the screen is 0,0. The values for curposx
; and curposy must be within the screen.

func	msm_setcurpos
	mov	AX,4		;mouse function
msm3:	.if	msm_inited e 0, S4
	push	BP
	mov	BP,SP
	mov	CX,P[BP]
	mov	DX,P+2[BP]
	mouse
	pop	BP
S4:	ret
c_endp	msm_setcurpos

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Syntax:
;	int msm_getpress(unsigned *count, unsigned *curposx,unsigned *curposy);
; Get button press information.
; Input:
;	*count =		which button are we refering to
;				(0 = left button, 1 = right button, 2 = middle)
; Output:
;	*count =		count of button presses since last call
;				to msm_getpress. Values can be 0..32767.
;	*curposx,*curposy =	mouse position at last press
; Returns:
;	Bit 0:	left button (1 == down, 0 == up)
;	Bit 1:	right button
;	Bit 2:	middle button
;	Ignore other bits

func	msm_getpress
	mov	AX,5		;mouse function
msm2:	push	BP
	mov	BP,SP
	.save	SI
    if SPTR
	mov	BX,P[BP]
	mov	BX,[BX]
    else
	les	BX,P[BP]
	mov	BX,ES:[BX]
    endif
	shr	BX,1
	.if	msm_inited e 0, G2
	mouse
	jmps	G3

G2:	clr	AX
	cwd
	mov	BX,AX
	mov	CX,AX
G3:
    if SPTR
	mov	SI,P[BP]
	mov	[SI],BX		;*count
	mov	SI,P+SIZEPTR[BP]
	mov	[SI],CX		;*curposx
	mov	SI,P+SIZEPTR+SIZEPTR[BP]
	mov	[SI],DX		;*curposy
    else
	les	SI,P[BP]
	mov	ES:[SI],BX		;*count
	les	SI,P+SIZEPTR[BP]
	mov	ES:[SI],CX		;*curposx
	les	SI,P+SIZEPTR+SIZEPTR[BP]
	mov	ES:[SI],DX		;*curposy
    endif
	.restore SI
	pop	BP
	ret
c_endp	msm_getpress

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Syntax:
;	int msm_getrelease(unsigned *count,
;		unsigned *curposx,unsigned *curposy);
; Get button release information.
; Input:
;	*count =		which button are we refering to
;				(0 = left button, 1 = right button, 2 = middle)
; Output:
;	*count =		count of button releases since last call
;				to msm_getpress. Values can be 0..32767.
;	*curposx,*curposy =	mouse position at last release
; Returns:
;	Bit 0:	left button (1 == down, 0 == up)
;	Bit 1:	right button
;	Bit 2:	middle button
;	Ignore other bits

func	msm_getrelease
	mov	AX,6		;mouse function
	jmp	msm2
c_endp	msm_getrelease

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Syntax:
;	void msm_setareax(unsigned minx,unsigned maxx);
; Set minimum and maximum horizontal position. If maxx < minx, the values
; are exchanged. The mouse horizontal motion will be restricted to be within
; these values.

func	msm_setareax
	mov	AX,7
	jmp	msm3
c_endp	msm_setareax

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Syntax:
;	void msm_setareay(unsigned miny,unsigned maxy);
; Set minimum and maximum vertical position. If maxy < miny, the values
; are exchanged. The mouse vertical motion will be restricted to be within
; these values.

func	msm_setareay
	mov	AX,8
	jmp	msm3
c_endp	msm_setareay

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Syntax:
;	void msm_setgraphcur(int hotx,int hoty,int *pmasks);
; Set graphics cursor block.
; Input:
;	hotx,hoty	Location of 'hot spot' of cursor. Values
;			must be -16..16. Location 0,0 is the upper
;			left corner of the cursor, positive values
;			extend right and down.
;	pmasks		Points to 32 words which contain bit masks
;			defining the cursor.
;			The first 16 words define the mask, that is,
;			which bits of the background 'shine' through
;			the cursor. A 1 means shine through, a 0 means not.
;			The second 16 words define the bitmap of the cursor,
;			1 being on and 0 being off.
;			The cursor is 16*16, the first word forms
;			the top row, bit 15 forms the leftmost column.

func	msm_setgraphcur
	.if	msm_inited e 0, S2
	push	BP
	mov	BP,SP
	mov	BX,P[BP]
	mov	CX,P+2[BP]
    if SPTR
	push	DS
	pop	ES
	mov	DX,P+4[BP]	;put pointer in ES:DX
    else
	les	DX,P+4[BP]
    endif
	mouse	9
	pop	BP
S2:	ret
c_endp	msm_setgraphcur

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Syntax:
;	void msm_settextcur(int select,int scanstart,int scanstop);
; Set text cursor.
; Input:
;	select		If 1, then hardware text cursor. If 0, then
;			attribute cursor.
;	scanstart,
;	scanstop	If select is 1, then these values form the
;			starting and ending scan lines of the hardware
;			text cursor.
;			If select is 0, then these values form the
;			screen mask and cursor mask, respectively, for
;			the attribute cursor.

func	msm_settextcur
	.if	msm_inited e 0, S3
	push	BP
	mov	BP,SP
	mov	BX,P[BP]
	mov	CX,P+2[BP]
	mov	DX,P+4[BP]
	mouse	10
	pop	BP
S3:	ret
c_endp	msm_settextcur

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Syntax:
;	void msm_readcounters(int *countx,int *county);
; Read mouse motion counters in mickeys. A mickey is 1/200 of an inch.
; Output:
;	*countx,*county =	mickey count since last call, values
;				range from -32768 to 32767.

func	msm_readcounters
	push	BP
	mov	BP,SP
	.if	msm_inited e 0, R1
	mouse	11
	jmp	msm1

R1:	jmp	G1
c_endp	msm_readcounters

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Syntax:
;	void msm_signal(unsigned mask,
;		void (*func)(unsigned mask,unsigned state,
;			unsigned curposx,unsigned curposy),
;		void *stack);
; Set user-defined subroutine input mask. Used to set a function
; to be called at interrupt level whenever there is input available
; from the mouse. All the caveats apply to the interrupt service routine.
; Using this function is not for the faint-hearted.
; Input:
;	mask	Mask defining when to call func (1 means yes):
;		Bit 0:	mouse moved
;		Bit 1:	left button is pressed
;		Bit 2:	left button is released
;		Bit 3:	right button is pressed
;		Bit 4:	right button is released
;		Bit 5:	middle button is pressed
;		Bit 6:	middle button is released
;		Other bits are not used.
;	func	Pointer to application-defined interrupt service routine
;		to call whenever a mouse button is
;		pressed or released, or the mouse moves, according to the
;		bits in mask.
;	stack	Value to set stack pointer to when func is called. Should
;		point just past end of area that is at least 256 bytes
;		long.
; When func is called, it is passed the following:
;	mask	Event that occured is indicated with the bit set as defined
;		above.
;	state	If button event, this is the button number of the button that
;		changed (0 = left, 1 = right, 2 = middle).
;	curposx,curposy	Current mouse position.

	begdata
    if LCODE
ptrtoisr	dw	?	;pointer to C interrupt service routine
		dw	?
    else
ptrtoisr	dw	?	;pointer to C interrupt service routine
    endif
stack		dw	?	;value of SP
    if LPTR
		dw	?	;value of SS
    endif
stacksave	dw	?,?	;save stack of msm_isr
	enddata

func	msm_signal
	.if	msm_inited e 0, S5
	push	BP
	mov	BP,SP
	mov	CS:dssave,DS	;save our data segment register
	mov	CX,P[BP]	;load call mask
    if SPTR
	push	ES
    endif
    ifdef I8086S
	mov	AX,P+2[BP]
	mov	ptrtoisr,AX
	mov	AX,P+2+SIZEPTR[BP]
	mov	stack,AX
    endif
    ifdef I8086M
	mov	AX,P+2[BP]
	mov	ptrtoisr,AX
	mov	AX,P+2+2[BP]
	mov	ptrtoisr[2],AX
	mov	AX,P+2+2+2[BP]
	mov	stack,AX
    endif
    ifdef I8086P		;funny Lattice C P model
	mov	BX,P+2[BP]
	mov	AX,[BX]
	mov	ptrtoisr,AX
	mov	AX,2[BX]
	mov	ptrtoisr[2],AX
	mov	AX,P+2+SIZEPTR[BP]
	mov	stack,AX
    endif
    ifdef I8086C
	mov	AX,P+2[BP]
	mov	ptrtoisr,AX
	les	AX,P+2+SIZEPTR[BP]
	mov	stack,AX
	mov	stack+2,ES
    endif
    ifdef I8086L
	mov	AX,P+2[BP]
	mov	ptrtoisr,AX
	mov	AX,P+2+2[BP]
	mov	ptrtoisr+2,AX
	les	AX,P+2+SIZEPTR[BP]
	mov	stack,AX
	mov	stack+2,ES
    endif
	mov	DX,offset msm_isr
	push	CS
	pop	ES		;ES:DX = pointer to msm_isr
	mouse	12
    if SPTR
	pop	ES
    endif
	pop	BP
S5:	ret

dssave	dw	?		;place to save DS
c_endp	msm_signal

msm_isr	proc	far
	mov	DS,CS:dssave	;reload data segment
	mov	stacksave,SP
	mov	stacksave+2,SS
    if SPTR
	cli				;for bug in old 8088's
	mov	SS,CS:dssave
	mov	SP,stack
	sti				;for bug in old 8088's
	push	DS
	pop	ES
    else ;LPTR
	cli				;for bug in old 8088's
	mov	SS,stack+2
	mov	SP,stack
	sti				;for bug in old 8088's
    endif
	cld			;no direction flag bugs
	push	DX		;vertical cursor coordinate
	push	CX		;horizontal cursor coordinate
	push	BX		;button state
	push	AX		;condition mask
    if LCODE
	call	dword ptr ptrtoisr
    else
	call	word ptr ptrtoisr
    endif
	cli				;for bug in old 8088's
	mov	SS,stacksave+2
	mov	SP,stacksave
	sti				;for bug in old 8088's
	ret
msm_isr	endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Syntax:
;	void msm_lightpenon(void);
; Light pen emulation mode on. The mouse emulates a light pen, that is,
; the 'pen' is off the screen when both buttons are up, and the 'pen' is
; down when both buttons are down.

func	msm_lightpenon
	.if	msm_inited e 0, P1
	mouse	13
P1:	ret
c_endp	msm_lightpenon

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Syntax:
;	void msm_lightpenoff(void);
; Light pen emulation mode off.

func	msm_lightpenoff
	.if	msm_inited e 0, P1
	mouse	14
	ret
c_endp	msm_lightpenoff

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Syntax:
;	void msm_setratio(unsigned ratiox,unsigned ratioy);
; Set mickey/pixel ratio (the sensitivity of the mouse). Higher values
; mean less cursor movement for corresponding mouse movement.
; The default values are 8,16. The values for
; ratiox and ratioy must be 1..32767.

func	msm_setratio
	mov	AX,15
	jmp	msm3
c_endp	msm_setratio

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Syntax:
;	void msm_condoff(unsigned upperx, unsigned uppery,
;			 unsigned lowerx, unsigned lowery);
; Conditional off.
; The parameters define a rectangular region on the screen. When the
; mouse is in that region, the mouse cursor is hidden. This is useful
; if a portion of the screen is to be updated. A call to msm_showcursor()
; will undo this and turn the mouse cursor back on.

func	msm_condoff
	.if	msm_inited e 0, P1
	push	BP
	mov	BP,SP
	.save	<SI,DI>
	mov	CX,P[BP]
	mov	DX,P+2[BP]
	mov	SI,P+4[BP]
	mov	DI,P+6[BP]
	mouse	16
	.restore <DI,SI>
	pop	BP
	ret
c_endp	msm_condoff

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Syntax:
;	void msm_setthreshhold(unsigned speed);
; Set double speed threshhold, i.e. the speed at which the mickey/pixel
; ratio is temporarilly halved so the mouse apparently moves faster.
; Speed is in mickeys/second. The default is 64.

func	msm_setthreshhold
	.if	msm_inited e 0, P1
	push	BP
	mov	BP,SP
	mov	DX,P[BP]
	mouse	19
	pop	BP
	ret
c_endp	msm_setthreshhold

	endcode	msmouse

    endif ;__OS2__

	end


