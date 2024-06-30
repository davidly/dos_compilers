
; name		XCMAIN -- initiate execution of C program
;
; description	This is the main module for a C program on the
;		MS-DOS implementation.  It initializes the segment
;		registers, sets up the stack, and calls the C main
;		function _main with a pointer to the remainder of
;		the command line.
;
;		Also defined in this module is the exit entry point
;		XCEXIT.
;
pgroup	group	base,prog
dgroup	group	data,stack
;
; The following segment serves only to force "pgroup" lower in
; memory.  It also contains the Microsoft C revision number.
;
base	segment	'prog'
	db	"MS-C  V 1.04  "
base	ends
;
; The data segment defines locations which contain the offsets
; of the base and top of the stack.
;
data	segment	byte public 'data'
	public	_top, _base
_top	dw	0
_base	dw	0
data	ends
;
; The stack segment is included to prevent the warning from the
; linker, and also to define the base (lowest address) of the stack.
;
stack	segment stack 'data'
sbase	dw	128 dup (?)
stack	ends
;
; The main program must set up the initial segment registers
; and the stack pointer, and set up a far return to the MS-DOS
; exit point at ES:0.  The command line bytes from the program
; segment prefix are moved onto the stack, and a pointer to
; them supplied to the C main module _main (which calls main).
;
prog	segment	byte public 'prog'
	public	XCMAIN, XCEXIT
	extrn	_main:near
	assume	cs:pgroup, ds:dgroup, ss:dgroup
XCMAIN	proc	far
	cli			;disable interrupts
	mov	ax,dgroup
	mov	ds,ax		;initialize ds and ss 
	mov	ss,ax
	mov	bx,es:2		;total memory size (paragraphs)
	sub	bx,ax
	test	bx,0f000h
	jnz	m1		;branch if more than 64K bytes
	mov	cl,4
	shl	bx,cl		;highest available byte
	jmp	short m2
m1:	mov	bx,0fff0h	
m2:	mov	sp,bx		;set stack pointer
	sti			;enable interrupts
	mov	_top,bx		;save top of stack
	mov	ax,offset dgroup:sbase
	mov	_base,ax	;store ptr to bottom of stack
	push	es		;push ptr to pgm segment prefix
	xor	ax,ax
	push	ax		;instr ptr for far return
	mov	bp,sp		;save in bp
	mov	si,80h		;ptr to command line bytes
	mov	cl,es:[si]	;get number of bytes
	inc	si
	xor	ch,ch		;clear high byte
	mov	bx,cx
	add	bx,4		;3 bytes additional, 1 for rounding
	and	bx,0fffeh	;force even number of bytes
	sub	sp,bx		;allocate space on stack
	mov	di,sp
	mov	byte ptr [di],'c'	;store dummy program name
	inc	di
	jcxz	m4		;skip if no bytes to move
	mov	byte ptr [di],' '
	inc	di
m3:	mov	al,es:[si]	;move bytes to stack
	mov	[di],al
	inc	si
	inc	di
	loop	m3
m4:	xor	ax,ax
	mov	[di],al		;store null byte
	mov	ax,ds
	mov	es,ax		;es, ds, and ss are all equal
	mov	ax,sp
	push	ax		;ptr to command line
	call	_main		;call C main
	mov	sp,bp		;restore ptr to far return
	ret			;return to MS-DOS
XCMAIN	endp
;
; name		XCEXIT -- terminate execution of C program
;
; description	This function terminates execution of the current
;		program by returning to MS-DOS.  The error code
;		argument normally supplied to XCEXIT is ignored 
;		in this implementation.
;
XCEXIT	proc	far
	mov	ax,_top		;load stack ptr with top address
	sub	ax,4
	mov	sp,ax
	ret			;return
XCEXIT	endp
prog	ends
	end	XCMAIN
