	page	,132
	title	stdargv - standard & wildcard _setargv routine
;***
;stdargv.asm - standard & wildcard _setargv routine
;
;	Copyright (c) 1985-1990, Microsoft Corporation.  All rights reserved.
;
;Purpose:
;	processes program command line, with or without wildcard expansion
;
;*******************************************************************************


ifdef	WILDCARD
	name	_setargv	; wildcard _setargv routine
else
	name	stdargv 	; standard _setargv routine
endif

ifdef	WILDCARD
?DF	=	1		; tell cmacros.inc we want to define our own segments
endif

	.xlist
include version.inc
include cmacros.inc
include msdos.inc
include rterr.inc
	.list


ifdef FARSTACK
ife sizeD
    error <You cannot have a far stack in Small or Medium memory models.>
endif
endif

ifdef	WILDCARD		; **********************************************

createSeg _TEXT, code,	word,	public, CODE,	<>
createSeg _DATA, data,	word,	public, DATA,	DGROUP

createSeg HDR,	nhdr,	byte,	public, MSG,	DGROUP
createSeg MSG,	nmsg,	byte,	public, MSG,	DGROUP
createSeg PAD,	npad,	byte,	common, MSG,	DGROUP
createSeg EPAD, nepad,	byte,	common, MSG,	DGROUP

defGrp	DGROUP			; define DGROUP

dataOFFSET equ	offset DGROUP:

; Message used by ___setargv (wildcard version of __setargv)

sBegin	nmsg
assumes ds,data

	_RTERR	_RT_SPACEARG, 'not enough space for arguments', _RT_STANDARD

sEnd

sBegin	npad
assumes ds,data
	dw	-1
; no padding for now;
; MAX padding would be
;	db	25 dup(0)
sEnd


externP _cwild			; Wildcard Expander
externNP _amsg_exit		; error handler (unable to allocate)

endif				; WILDCARD	; **********************************************


sBegin	data
assumes ds,data

C_CR	equ	0DH		; ASCII carriage return

C_BLANK equ	' '		; ASCII space character
C_TAB	equ	09h		; ASCII horizontal tab character

C_QUOTE equ	'"'		; ASCII (double) Quote Charater
C_BACKSLASH equ '\'             ; ASCII backward slash character

externDP __argv 		; argument string array address
externW __argc			; count of argument strings
externW _psp			; address of Program Segment Prefix
externW _osversion		; address of DOS version
externD _pgmptr 		; far ptr to name of program


staticCP retadr,0		; return address


ifdef	WILDCARD		; **********************************************

dta_flag db	0		; Has DMA been set yet?

file_reserv db	21 dup (0)
file_attrib db	0
file_time dw	0
file_date dw	0
file_sizel dw	0
file_sizeh dw	0
file_name db	13 dup (0)

endif				; WILDCARD	; **********************************************

sEnd

; ****************************************

jmps	MACRO	target
	jmp	short target
	ENDM

lje	MACRO	target
	LOCAL	temp
	jne	temp
	jmp	target
temp:
	ENDM

DELIM	MACRO	target
	cmp	al,C_CR 	;; Test for end-of-line character
	je	target
	or	al,al		;; Either Carriage Return or Null
	je	target
	ENDM

LDELIM	MACRO	target
	cmp	al,C_CR 	;; Test for end-of-line character
	lje	target
	or	al,al		;; Either Carriage Return or Null
	lje	target
	ENDM

; ****************************************

sBegin	code

assumes ds,data
ifdef FARSTACK
assumes ss,nothing
else
assumes ss,data
endif
assumes cs,code


page
;***
;_setargv, __setargv - set up "argc" and "argv" for C programs
;
;Purpose:
;	Gets the command line from the PSP and moves the information
;	to its place on the stack.
;
;	SIDE EFFECTS:
;		Allocates space on the stack for the argument strings
;		and a list of pointers to them.
;	ASSUMPTIONS:
;		Under DOS 2, there is no argv[0] string, so we store a null
;		char ('\0').
;
;		Under DOS 3 and later, the argv[0] string is found in the
;		environment segment, after the double null that terminates
;		that segment and after a word of value 1.  The rest of the
;		command line is found in the Program Segment Prefix at
;		offset 81H, and is terminated by a 0DH.  This command "tail"
;		cannot be greater than 126 bytes in length.
;
;		Quote marks and backslashes are treated specially.  A quoted
;		string is passed as a single argument, not including the
;		opening and closing quote characters.  A quote may be imbedded
;		in a string by placing an odd number of backslashes (`\')
;		before it.  Each pair of backslashes which precedes a quote
;		results in a single backslash in the resultant string.
;		An even number of backslashes followed by a quote results in
;		half that many backslashes, and the quote begins or ends the
;		quoted part of the string as is appropriate.  Backslashes not
;		followed by a quote are treated normally.
;
;		[""] ==> []
;		[\"] ==> ["]
;		[" \" "] == [ " ]
;		[" \\"] == [ \]
;		[" \\ "] == [ \\ ]
;		[" \\\" "] == [ \" ]
;		etc.
;		["one two three"] ==> [one two three]
;		[one" two "three] ==> [one two three]
;		[o"ne two t"hree] ==> [one two three]
;		["one \"two\" three"] ==> [one "two" three]
;		["x\\\"x"] ==> [x\"x]
;
;Entry:
;
;Exit:
;	"argv" points to a null-terminated list of pointers to ASCIZ
;	strings, each of which is an argument from the command line.
;	"argc" is the number of arguments.  The strings are copied from
;	the Program Segment Prefix into space allocated on the stack.
;	The list of pointers is also located on the stack.
;
;Uses:
;	All registers except DS, SS, and BP are modified
;	Note especially that SI and DI are NOT preserved!
;
;Exceptions:
;
;*******************************************************************************

ifdef	WILDCARD		; **********************************************

labelP	<PUBLIC,__setargv>

else				; **********************************************

labelP	<PUBLIC,_setargv>

endif				; WILDCARD	; **********************************************

	pop	word ptr [retadr] ; get return address (offset)
if	sizeC
	pop	word ptr [retadr+2] ; get return address (segment)
endif
;
; Check and store DOS version. This is done here because it cannot be done
; in CRT0.ASM (Windows replaces CRT0.ASM with their own code) and _setargv()
; is the only other place in the startup code where the DOS version number
; needed.
;
	callos	VERSION
	mov	[_osversion],ax
	mov	dx,1		; dx = number of bytes in argv[0] if DOS 2.x
	cmp	al,2
	je	dos_two

	mov	es,_psp
	mov	es,es:[DOS_envp] ; get environment segment
	mov	word ptr [_pgmptr+2],es ; set global variable "_pgmptr"
	xor	ax,ax
	cwd			; DX=0
	mov	cx,8000H
	xor	di,di		; scan from beginning of environment
find_env_end:
	repne	scasb
	scasb
	jne	find_env_end
;
	inc	di		; skip count word (always 0x0001)
	inc	di
	mov	word ptr [_pgmptr],di ; set global variable "_pgmptr"
	mov	cx,-1
	repne	scasb
	not	cx
	mov	dx,cx		; DX=number of bytes in argv[0]
dos_two:
ifdef FARSTACK
	push	ds
	pop	es
	assumes es,data 	; set ES=DGROUP
endif
	mov	di,1		; always start with one argument
	mov	si,81H
	mov	ds,_psp


	assumes ds,nothing
;*
;*	Count the command tail arguments
;*
;
;	DI will count the number of arguments
;	DX will count the number of bytes needed for the arguments
;		(not including the null terminators)
;
arg100:
arg110:
	lodsb
	cmp	al,C_BLANK
	je	arg110
	cmp	al,C_TAB
	je	arg110

	DELIM	arg400

	inc	di		; Another argument
;
; Parse an argument
;
arg200:
	dec	si		; back up to reload character
arg210:
	lodsb

	cmp	al,C_BLANK
	je	arg100
	cmp	al,C_TAB
	je	arg100		; white space terminates argument

	DELIM	arg400

	cmp	al,C_QUOTE
	je	arg310

	cmp	al,C_BACKSLASH
	je	arg220

	inc	dx
	jmps	arg210
;
; Count backslashes
;
arg220:
	xor	cx,cx
arg221:
	inc	cx		; CX counts the backslashes
	lodsb
	cmp	al,C_BACKSLASH
	je	arg221
;
	cmp	al,C_QUOTE
	je	arg230

	add	dx,cx		; not followed by `"' -- treat `\'s normally
	jmp	arg200
;
arg230:
	mov	ax,cx
	shr	cx,1
	adc	dx,cx		; add 1 for every pair of backslashes
	test	al,1		; plus 1 for the " if odd number of \
	jnz	arg210		; " was escaped with a \
	jmps	arg310		; " opens a quoted substring
;
; Enter a quoted string
;
arg300:
	dec	si		; back up to reload character
arg310:
	lodsb

	DELIM	arg400

	cmp	al,C_QUOTE
	je	arg210		; end of quoted portion of string

	cmp	al,C_BACKSLASH
	je	arg320

	inc	dx
	jmp	arg310
;
; Count backslashes
;
arg320:
	xor	cx,cx
arg321:
	inc	cx		; CX counts the backslashes
	lodsb
	cmp	al,C_BACKSLASH
	je	arg321
;
	cmp	al,C_QUOTE
	je	arg330

	add	dx,cx		; not followed by `"' -- treat `\'s normally
	jmp	arg300
;
arg330:
	mov	ax,cx
	shr	cx,1
	adc	dx,cx		; add 1 for every pair of backslashes
	test	al,1		; plus 1 for the " if odd number of \
	jnz	arg310		; " was escaped with a \
	jmps	arg210		; " closes a quoted substring
;
; Command line is fully parsed - compute number of bytes needed
;
arg400:
;
;	Number of bytes needed =
;		Number of bytes used to make strings +
;		Number of bytes used to terminate strings +
;		sizeof(DATAPTR) * ( number of arguments + 1 )
;
ifdef FARSTACK
	push	es
else
	push	ss
endif ;FARSTACK
	pop	ds		; Restore DS = DGROUP
	assumes ds,data

	mov	__argc,di	; Store number of arguments

	add	dx,di		; add in terminator bytes
ifdef	WILDCARD
	add	dx,di		; add in Wildcard flag bytes
endif
	inc	di		; add one for NULL pointer
	shl	di,1
if	sizeD
	shl	di,1
endif
	add	dx,di		; add space for pointers to space for chars

	inc	dx
	and	dl,not 1	; Round up to an even number of bytes
;
;	Allocate space on the stack
;
;	DX is the total number of bytes needed for strings and pointers
;	DI is the number of bytes needed for the pointers
;
	sub	sp,dx
	mov	ax,sp

	mov	word ptr (__argv),ax
if	sizeD
	mov	word ptr (__argv+2),ss
endif
;
;	Copy argument strings and addresses onto heap/stack
;		Address table is on the top, strings below that
;
	mov	bx,ax
	add	di,bx

	push	ss		; ES=SS
	pop	es		; ES:DI is where the string copies will go
ifndef FARSTACK
	assumes es,data
endif

;
;	DS:SI	points to the argv[0]
;
;	ES:BX	points to where argv[0],argv[1],argv[2],... go
;	ES:DI	points to where *argv[0],*argv[1],*argv[2],... go
; For wildcard version only:
;	ES:DX	points to the wildcard flag character (prepended to argument)
;		during the creation of each argument
;
	mov	ss:[bx],di	; argv[i] - offset part
if	sizeD
	mov	ss:[bx+2],ss	; argv[i] - segment part
	add	bx,4
else
	inc	bx
	inc	bx
endif

	lds	si,[_pgmptr]	; copy argv[0], either fake or from env seg
	assumes ds,nothing

ifdef	WILDCARD
	movsb
	dec	si		; copy first character as quote flag
endif

copy_argv0:
	lodsb
	stosb
	or	al,al
	jnz	copy_argv0


;
;	DS:SI	points to the raw command tail string
;

ifdef FARSTACK

	mov	si, DGROUP
	mov	ds, si		; DS = DGROUP

	assumes ds, data
	mov	ds, [_psp]
	assumes ds, nothing	; let DS = psp
else
	mov	ds,ss:[_psp]	; DS:SI is where the source strings are
endif ;FARSTACK
	mov	si,81H		; address of strings

	assumes ds,nothing

	jmps	arg510
;
;	Skip blanks
;
arg500:
	xor	ax,ax
	stosb
arg510:
	lodsb
	cmp	al,C_BLANK
	je	arg510
	cmp	al,C_TAB
	je	arg510

ifdef	WILDCARD
	LDELIM	arg810
else
if	sizeD
	LDELIM	arg810
else
	DELIM	arg810
endif
endif

	mov	ss:[bx],di
if	sizeD
	mov	ss:[bx+2],ss
	add	bx,4
else
	inc	bx
	inc	bx
endif

ifdef	WILDCARD
	mov	dx,di
	stosb			; initialize wildcard flag
endif
;
;
; Parse an argument
;
arg600:
	dec	si		; back up to reload character
arg610:
	lodsb

	cmp	al,C_BLANK
	je	arg500
	cmp	al,C_TAB
	je	arg500		; white space terminates argument

	DELIM	arg800

	cmp	al,C_QUOTE
	je	arg710x

	cmp	al,C_BACKSLASH
	je	arg620

	stosb
	jmps	arg610
;
; Count backslashes
;
arg620:
	xor	cx,cx
arg621:
	inc	cx		; CX counts the backslashes
	lodsb
	cmp	al,C_BACKSLASH
	je	arg621
;
	cmp	al,C_QUOTE
	je	arg630

	mov	al,C_BACKSLASH
	rep	stosb		; not followed by `"' -- treat `\'s normally
	jmp	arg600
;
arg630:
	mov	al,C_BACKSLASH
	shr	cx,1
	rep	stosb
	jnc	arg710x 	; " opens a quoted substring
	mov	al,C_QUOTE
	stosb
	jmp	arg610		; " was escaped with a \
;
; Enter a quoted string
;
ifdef	WILDCARD
arg710x:
	inc	si		; undoes the "DEC SI" between arg700 and arg710
endif

arg700x:

ifdef	WILDCARD
	xchg	dx,di		; set the wildcard flag character to `"'
	mov	al,C_QUOTE
	stosb
	dec	di
	xchg	dx,di
endif

arg700:
	dec	si		; back up to reload character

ifndef	WILDCARD
arg710x:
endif

arg710:
	lodsb

	DELIM	arg800

	cmp	al,C_QUOTE
	je	arg610		; end of quoted portion of string

	cmp	al,C_BACKSLASH
	je	arg720

	stosb
	jmp	arg710
;
; Count backslashes
;
arg720:
	xor	cx,cx
arg721:
	inc	cx		; CX counts the backslashes
	lodsb
	cmp	al,C_BACKSLASH
	je	arg721
;
	cmp	al,C_QUOTE
	je	arg730

	mov	al,C_BACKSLASH
	rep	stosb		; not followed by `"' -- treat `\'s normally
	jmp	arg700x
;
arg730:
	mov	al,C_BACKSLASH
	shr	cx,1
	rep	stosb		; store 1 for every pair of backslashes
	jnc	arg610		; " closes a quoted substring
	mov	al,C_QUOTE	; " was escaped with a \
	stosb
	jmps	arg710x
;
; Terminate last argument string, terminate list of argument pointers
;
arg800:
	xor	ax,ax
	stosb			; null-terminate final argument
arg810:

ifdef FARSTACK
	mov	ax, DGROUP
	mov	ds, ax
else
	push	ss		; default is SS == DGROUP
	pop	ds
endif
	assumes ds,data

ifdef FARSTACK
	mov	word ptr ss:[bx],0
	mov	word ptr ss:[bx+2],0
else
	mov	word ptr [bx],0 ; add null pointer to __argv[]
if	sizeD
	mov	word ptr [bx+2],0
endif
endif ;FARSTACK

ifndef	WILDCARD
	jmp	[retadr]	; THE END
else
	call	_cwild
	test	ax,ax
	jz	no_arg_err

	mov	ax,_RT_SPACEARG ; 'not enough space for arguments'
	jmp	_amsg_exit	;

no_arg_err:
	jmp	[retadr]

page
;***
;_find(dir) - find first matching file name against pattern "dir"
;
;Purpose:
;	_find(dir) - Find first matching file name against pattern "dir"
;	If dir == NULL, then get next match for current pattern.
;
;Entry:
;	dir	= DATA PTR of pattern to match
;
;Exit:
;	AX	= the address of a static area containing the file name if a
;		  match was found.  Returns NULL if no match was found.
;
;Uses:
;	CX,DX, [dta_flag].
;
;Exceptions:
;
;*******************************************************************************

cProc	_find,<PUBLIC>
	parmdp	dir
cBegin
	test	[dta_flag],-1
	jnz	not_very_first

	mov	[dta_flag],-1
;
;	Set DTA, where the match structure is returned
;
	mov	dx,dataOFFSET file_reserv
	callos	setdma
;
not_very_first:
	mov	ah,DOS_findnext ; assume not first

if	sizeD
	push	ds
	lds	dx,dir
	mov	cx,ds
	jcxz	find_next
else
	mov	dx,dir
	test	dx,dx
	jz	find_next
endif
	mov	cx,A_D		; match directories as well as files
	mov	ah,DOS_findfirst
find_next:
	callos
if	sizeD
	pop	ds
endif
	mov	ax,dataOFFSET file_name
if	sizeD
	mov	dx,ds
endif
	jnc	retname

	xor	ax,ax		; return 0 for no more matches
if	sizeD
	cwd
endif

retname:

cEnd

endif				;	WILDCARD	; ***********************************************

sEnd	code

	end
