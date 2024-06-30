	  TITLE	  WHAT

; Program WHAT.ASM
; Purpose Batch	file enhancer
; Input	  Command line consisting of:
;	     Command letter (with optional E for extended)
;	     Optional prompt enclosed in double	quotes
;	     Optional argument
; Output  Number in DOS	ERRORLEVEL and string in WHAT environment variable

	  DOSSEG
	  .MODEL  small
	  PAGE	  60,120
	  INCLUDE DOS.INC

	  .STACK  100h

	  .DATA
help1	  LABEL	  BYTE
DB 13,10,"			WHAT - Batch file enhancer",13,10,13,10
DB "Command			Purpose	    Argument   Environ	   Exit	       Extended",13,10
DB "---------		-------	    --------   -------	   ----	       ------",13,10
DB "C[E] [""prompt""]	[chars]	Get	    Allowable  Character   Character   Echo",13,10
DB "			character   characters",13,10,13,10
DB "S[E] [""prompt""]		Get string  None       String	   Length      Echo",13,10,13,10
DB "D[E]			Check DOS   None       Major	   (Major*10)  Minor",13,10
DB "					       version	   +Minor      version",13,10,13,10
DB "E[E]			Get environ None       Bytes	   Bytes/10    10 bytes",13,10
DB "			bytes left			   bytes       in exit",13,10,13,10
DB "F[E] filespec		Get file    Filespec   Kilobytes   Ks/10Ks     10Ks in",13,10
DB "			size			 (255=directory)       exit",13,10,13,10
DB "K[E] [driveletter]	Get disk    Drive      Kilobytes   Ks/10Ks     10Ks in",13,10
DB "			space					       exit",13,10,13,10
DB "Press a key to continue . . .$"
help2	  LABEL	  BYTE
DB 13,"M[E]			Check	    None       Kilobytes   Ks/10Ks     10Ks in",13,10
DB "			memory					       exit",13,10,13,10
DB "P			Check for   None       1=yes,0=no  1=yes,0=no  None",13,10
DB "			printer",13,10,13,10
DB "V [number]		Get/Set	    New mode   Current or  Current or  None",13,10
DB "			video mode	       last mode   last mode",13,10,13,10
DB "7			Check for   None       1=yes,0=no  1=yes,0=no  None",13,10
DB "			coprocessor",13,10,13,10
DB "A			Check for   None       1=yes,0=no  1=yes,0=no  None",13,10
DB "			ANSI driver",13,10,13,10
DB "Y[E]			Get current None       Directory   Level/Drive Drive",13,10
DB "			directory",13,10,"$"

guess	  DB	  80		 ; Prompt for string
actual	  DB	  ?
string	  DB	  80 DUP (0)

extend	  DB	  0		 ; Flag	for extended command
vid	  DB	  3		 ; Video mode
ans	  DB	  27,"[6n$"	 ; ANSI	string to get current position
overwrt	  DB	  8,8,8,8,"    $"; Overwrite ANSI characters
delete	  DB	  8,8,8,"$"	 ; Delete ANSI characters

what	  DB	  "WHAT="	 ; Variable name
lwhat	  EQU	  $-what

prompt	  DW	  0		 ; Pointer to prompt
lprompt	  DW	  0		 ; Length of prompt
arg	  DW	  0		 ; Pointer to argument
larg	  DW	  0		 ; Length of argument

; Command table

cmds	  DB	  "CSVDMEKFP7AY" ; Command character list
lcmds	  EQU	  $-cmds	 ;   and length	of list
	  EVEN
table	  DW	  GetChar	 ; Command procedure table
	  DW	  GetStr
	  DW	  DoVid
	  DW	  GetDOS
	  DW	  GetMem
	  DW	  GetEnvSz
	  DW	  GetDskSz
	  DW	  GetFilSz
	  DW	  VeriPrint
	  DW	  VeriCop
	  DW	  VerAnsi
	  DW	  GetDir
	  DW	  NoCmd

err1	  DB	  "Invalid command",7,13,10,"$"
err2	  DB	  "Out of environment space",7,13,10,"$"
err3	  DB	  "Must have DOS Version 2.0 or higher",7,13,10,"$"

	  .CODE
start:	  mov	  ax,@DATA		; Starting execution address
	  mov	  ds,ax			; Initialize data segment

	  @GetVer			; Get DOS version
	  or	  al,al			; Is it	0?
	  jne	  DOSOK			; No? Continue
	  @DispStr err3			; Yes? Quit for	1.x
	  int	  20h

DOSOK:	  mov	  si,83h		; Starting point in PSP
	  mov	  ax,WORD PTR es:[5Dh]	; Load command characters
	  cmp	  al,' '		; Is it	space?
	  jne	  isarg			; If no	argument, show help
	  call	  Help

isarg:	  cmp	  ah,'E'		; Extend flag?
	  jne	  noextend		; No? Continue
	  inc	  extend		; Yes? Turn on flag and	adjust pointer
	  inc	  si

noextend: call	  GetArg		; Get argument from command line

	  push	  es			; Save and load	DS into	ES
	  mov	  bx,ds
	  mov	  es,bx
	  mov	  di,OFFSET cmds	; Load pointer to command table
	  mov	  cx,lcmds+1		; Load length
	  repne	  scasb			; Find position	of command character
	  pop	  es
	  sub	  di,(OFFSET cmds)+1	; Point	to procedure
	  shl	  di,1			; Adjust for word addresses
	  call	  table[di]		; Call the selected procedure

	  push	  ax			; Save
	  push	  es
	  call	  DoEnviron		; Put result in	environment string
	  or	  ax,ax			; Test for 0 before
	  pop	  es			;   restore
	  pop	  ax
	  jz	  done

	  cmp	  BYTE PTR es:[5Dh],'E'	; Is it	Environment command
	  je	  done			; Yes? Skip message

error2:	  @DispStr err2			; Error	message

done:	  @Exit				; Quit with AL as return code

; End of program - Start of procedures

; Procedure GetChar
; Purpose   Get	a character from user
; Input	    Allowable characters pointed to by "arg" (optional)
;	    Prompt pointed to by "prompt" (optional)
; Output    Character in AX and	in "string"

GetChar	  PROC

	  call	  ShowPrmpt		; Display prompt if there is one

readkey:  @GetKey 0,1			; Get a	key
	  cmp	  al,13			; Is it	carriage return?
	  jne	  notcr			; Yes? Continue
	  mov	  al,"~"		; Call it tilde
					;   (use tilde in character list
					;    if	you want to accept CR)
notcr:	  or	  al,al			; Is it	0 for extended key?
	  je	  exkey			; Special case

	  mov	  bl,al			; Save a copy and swap
	  xchg	  ah,al

	  call	  UpCase		; Uppercase it

	  xchg	  ah,al			; Swap back
	  mov	  si,arg		; Load pointer and length of argument
	  mov	  cx,larg
	  jcxz	  gotchar		; If no	argument, quit early

; Compare character to argument	to see if it's valid

argcheck: mov	  ah,BYTE PTR es:[si]	; Get character
	  inc	  si			; Increment index

	  call	  UpCase		; Convert to uppercase

	  cmp	  ah,al			; Is it	in argument?
	  je	  gotchar		; Yes? We're done
	  loop	  argcheck		;   else check another
	  @DispCh 7			; Checked all, so ring bell
	  jmp	  SHORT	readkey		;   and	get another character

gotchar:  push	  ax
	  cmp	  extend,0		; Is extend flag set?
	  jne	  noecho		; Yes? Don't echo
	  cmp	  bl,"~"		; Don't echo ~ (alias for CR)
	  je	  noecho
	  @DispCh bl			; Display valid	character
noecho:	  pop	  ax
	  mov	  string,al		; Put the character in string
	  inc	  actual		; Length is one
	  ret

exkey:	  @GetKey 0,1			; Get second key in AL
	  mov	  si,arg		; Load pointer to argument
	  cmp	  BYTE PTR es:[si],"`"	; Is argument grave accent?
					;   (use grave in character list if
					;    you want to accept	extended keys)
	  je	  gotext		; Yes? Extended	character
	  @DispCh 7			; No? Illegal, so ring bell
	  jmp	  SHORT	readkey		;   and	get another
gotext:	  mov	  string[0],'0'		; Extended flag	value is "0<char>"
	  mov	  string[1],al
	  mov	  actual,2		; Length is 2

	  ret
GetChar	  ENDP

; Procedure GetStr
; Purpose   Get	a string
; Input	    Prompt pointed to by prompt	(optional)
; Output    String in "string";	length to AX

GetStr	  PROC

	  call	  ShowPrmpt		; Display prompt if there is one

	  cmp	  extend,1		; Extend flag true?
	  je	  password		; Yes? Then don't echo

	  @GetStr guess,0		; Get string (null-terminated)
	  jmp	  SHORT	gotstr		; Done

password: mov	  bx,OFFSET string	; Load offset of string	buffer
	  mov	  cx,80			; Maximum count
nextkey:  @GetKey 0,1			; Get key, no echo
	  cmp	  al,13			; Is it	carriage return
	  je	  gotpass		; Yes? Done
	  mov	  [bx],al		; No? Put key in buffer
	  inc	  bx			; Point	to next
	  loop	  nextkey

gotpass:  sub	  bx,OFFSET string	; Adjust pointer to get	count
	  mov	  actual,bl		; Save count

gotstr:	  @DispCh 13,10
	  mov	  ax,bx			; Save string length
	  ret
GetStr	  ENDP

; Procedure GetDOS
; Purpose   Get	DOS version
; Input	    None
; Output    Major or minor version in "string";	(major *10)+minor in AX

GetDOS	  PROC
	  @GetVer			; Get DOS version
	  mov	  string,al		; Put major in string
	  mov	  bh,al			; Save copy
	  mov	  al,ah			; Divide minor to get one digit
	  sub	  ah,ah			; Clear	top
	  mov	  cl,10			; Divide by 10
	  div	  cl
	  xchg	  al,bh			; Exchange major and minor
	  mul	  cl			; Multiply major by 10
	  add	  al,bh			; (Major*10)+Minor - 3.2 is now	32
	  cmp	  extend,1		; Extend?
	  jne	  gotver		; No? Already got it
	  mov	  string,bh		; Save number
gotver:	  mov	  actual,1		; Save length 1
	  add	  string,30h		; Convert to ASCII
	  ret
GetDOS	  ENDP

; Procedure GetEnvSz
; Purpose   Get	environment bytes available
; Input	    None
; Output    Environment	bytes available

GetEnvSz  PROC
	  push	  es			; Save ES
	  call	  GetEnv		; Get the environment size
	  pop	  es			; Restore
	  sub	  ax,cx			; Subtract length used from total
					;   length to get length remaining
	  call	  BinToDec		; Convert to string
	  call	  Byticize		; Handle values	too large for byte
	  ret
GetEnvSz  ENDP

; Procedure GetFilSz
; Purpose   Get	the size of a specified	file
; Input	    Filespec pointed to	by "arg"
; Output    File size

GetFilSz  PROC
	  cmp	  arg,0			; File name argument?
	  jne	  isfile
	  call	  NoCmd
isfile:	  mov	  di,arg		; Point	to start and end of arg
	  mov	  bx,larg
	  mov	  BYTE PTR es:[bx+di],0	; Make null-terminated

	  push	  ds
	  @OpenFil arg,0,es		; Open file for	reading
	  pop	  ds
	  jc	  ferror		; Error	if carry

notdir:	  @GetFilSz ax
	  jc	  ferror		; Error	if carry
	  mov	  cx,1000		; Convert to thousands
	  div	  cx
	  inc	  ax			; Round	up
	  jmp	  SHORT	gotsize

ferror:	  cmp	  ax,5			; Access denied? Probably a directory
	  jne	  nofile		; No file or some other	error
	  mov	  ax,0FFh		; Call directory size 255
	  jmp	  SHORT	gotsize
nofile:	  sub	  ax,ax			; Size of nothing is 0

gotsize:  call	  BinToDec		; Convert to string
	  call	  Byticize		; Handle large values
	  ret
GetFilSz  ENDP

; Procedure GetDskSz
; Purpose   Get	K remaining on specified disk
; Input	    Drive letter pointed to by "arg"
; Output    Disk space remaining

GetDskSz  PROC
	  sub	  ax,ax			; Assume default drive
	  cmp	  arg,0			; Was there an argument?
	  je	  defdrive		; No? Got drive
	  mov	  al,BYTE PTR es:6Dh	; Yes? Get drive letter
	  sub	  al,'A'-1		; Convert to binary
defdrive: @ChkDrv al			; Get disk space
	  cmp	  ax,0FFFFh		; Is drive valid?
	  jne	  valid
	  call	  NoCmd
valid:	  mul	  bx			; Sectors = sectors/cluster * clusters
	  mul	  cx			; Bytes	= bytes/sector * sectors
	  mov	  cx,1000		; Convert to thousand
	  div	  cx
	  inc	  ax			; Round	up
	  call	  BinToDec		; Convert to string
	  call	  Byticize		; Handle large values

	  ret
GetDskSz  ENDP

; Procedure GetMem
; Purpose   Get	memory available
; Input	    None
; Output    Available memory

GetMem	  PROC
	  int	  12h			; Get memory available in K
	  mov	  bx,es			; Get memory used
	  mov	  cx,6			; Convert to K
	  shr	  bx,cl
	  sub	  ax,bx			; Calculate how	much is	left
	  sub	  dx,dx			; Clear	DX
	  mov	  cx,1024		; Multiply to get bytes
	  mul	  cx
	  mov	  cx,1000		; Divide to get	thousands (not K)
	  div	  cx
	  call	  BinToDec		; Convert to string
	  call	  Byticize		; Handle large values
	  ret
GetMem	  ENDP

; Procedure VeriPrint
; Purpose   See	if LPT1	(PRN) is available
; Input	    None
; Output    1 for yes or 0 for no

VeriPrint PROC
	  mov	  ax,200h		; Check	printer	status
	  sub	  dx,dx			;   for	main parallel printer (port 0)
	  int	  17h
	  xchg	  dx,ax			; Put 0	(for error) in AX
	  test	  dh,00101001b		; Are any error	bits on?
	  jne	  printerr		; Yes? Leave 0
	  test	  dh,10010000b		; Are both operation bits on?
	  jz	  printerr		; No? Leave 0
	  inc	  ax			; Yes? Return 1
printerr: call	  BinToDec		; Convert to string
	  ret
VeriPrint ENDP

; Procedure DoVid
; Purpose   Get	current	video mode and optionally set a	new mode
; Input	    New	video mode pointed to by "arg" (optional)
; Output    Current video mode (before change)

DoVid	  PROC
	  mov	  ah,0Fh		; Get video mode
	  int	  10h

	  cmp	  larg,1		; How many digits in mode?
	  jl	  gotmode		; None?	Get out
	  push	  ax			; Some?	Save mode
	  mov	  bx,arg		; Load address of argument string
	  mov	  ax,es:WORD PTR [bx]	; Get address of mode string
	  je	  one			; One digit - skip the reverse
	  xchg	  ah,al			; Reverse for two digits
	  sub	  ax,'00'		; Adjust from ASCII to numeric
	  aad				; Convert to binary
	  jmp	  SHORT	setmode
one:	  sub	  al,'0'		; Convert to numeric
setmode:  sub	  ah,ah			; Set mode
	  int	  10h
	  pop	  ax			; Restore
gotmode:  cbw				; Extend to AX
	  call	  BinToDec		; Convert to string
	  ret
DoVid	  ENDP

; Procedure VeriCop
; Purpose   Check for coprocessor
; Input	    None
; Output    1 for yes or 0 for no

VeriCop	  PROC
	  int	  11h			; Check	peripherals
	  test	  al,10b		; Coprocessor
	  mov	  ax,0			; Assume no (don't change flags)
	  jz	  no87			; No? Done
	  inc	  ax			; Yes? Set to 1
no87:	  call	  BinToDec		; Convert to string
	  ret
VeriCop	  ENDP

; Procedure VerAnsi
; Purpose   Check for ANSI driver
; Input	    None
; Output    1 for yes or 0 for no

VerAnsi	  PROC

	  @DispStr ans			; Print	ANSI string to get
					;   cursor position
	  mov	  ah,6			; Check	for key
	  mov	  dl,0FFh		;   in buffer
	  int	  21h
	  jnz	  ansi			; Done if ANSI
	  @DispStr overwrt		; Overwrite ANSI string
	  sub	  ax,ax			; 0 if not ANSI
	  jmp	  SHORT	gotansi
ansi:	  mov	  ax,0C06h		; Clear	returned ANSI keys
	  mov	  dl,0FFh		;   out	of buffer
	  int	  21h
	  @DispStr delete		; Delete ANSI string
	  mov	  ax,1			; Set 1	for true
gotansi:  call	  BinToDec		; Convert to string
	  ret
VerAnsi	  ENDP

; Procedure GetDir
; Purpose   Get	the current directory or drive
; Input	    None
; Output    Current directory or drive in "string"; level or drive number in AX

GetDir	  PROC	  NEAR
	  cmp	  extend,1		; Extend flag true?
	  jne	  directry		; No? Get directory

	  @GetDrv			; Yes? Get drive
	  mov	  ah,al			; Copy
	  add	  ah,'A'		; Convert to drive letter
	  mov	  string,ah		; Put character	in string
	  inc	  actual		; Length 1
	  cbw
	  ret

directry: mov	  si,OFFSET string	; Load address for string
	  mov	  BYTE PTR [si],"\"	; Insert backslash (DOS	doesn't)
	  inc	  si			; Point	to next
	  @GetDir si
	  sub	  cx,cx			; Count	is zero
	  dec	  si			; Move pointer back to start
findback: lodsb				; Load
	  cmp	  al,"\"		; Is it	backslash?
	  jne	  notslash		; No? Continue
	  inc	  dx			; Yes? Increment level counter
notslash: or	  al,al			; Is it	0?
	  loopne  findback		; No? Repeat

	  neg	  cx			; Negate to get	positive count
	  mov	  actual,cl		; Put level in variable
	  xchg	  ax,dx
	  ret
GetDir	  ENDP

; Procedure NoCmd
; Purpose   Return error for invalid command
; Input	    None
; Output    None

NoCmd	  PROC
	  @DispStr err1			; Display error	and quit
	  @Exit	  0
NoCmd	  ENDP

; Procedure Byticize
; Purpose   Adjust word	values to fit in a byte
; Input	    Value in AX
; Output    255	for word values, else value (no	extend)	or value*10 (extend)

Byticize  PROC
	  cmp	  extend,0		; Is extend flag set?
	  je	  sizechk		; No? Check size
	  sub	  dx,dx			; Yes? Clear DX
	  mov	  bx,10			; Divide by 10 to get 10-unit chunks
	  div	  bx

sizechk:  or	  ah,ah			; Is it	255 or less?
	  je	  byteOK
	  mov	  al,0FFh		; No? Call it 255
byteok:	  ret
Byticize  ENDP

; Procedure GetArg
; Purpose   Parse command line for argument and	prompt strings
; Input	    Command line
; Output    Pointer to argument	in "arg"; length (or 0 if none)	in "larg"
;	    Pointer to prompt in "prompt"; length (or 0	if none) in "lprompt"

GetArg	  PROC
	  push	  ax
	  push	  es			; Swap ES and DS
	  push	  ds
	  pop	  es
	  pop	  ds

white:	  lodsb				; Load while white space
	  cmp	  al,' '		; Is it	space?
	  je	  white			; Throw	away
	  cmp	  al,9			; Is it	tab?
	  je	  white			; Throw	away
	  cmp	  al,'"'                ; Is it quote?
	  je	  promptit		; Process
	  cmp	  al,13			; Is it	carriage return?
	  je	  gotarg		; Done

	  sub	  cx,cx
qdone:	  dec	  si			; Adjust
	  mov	  es:arg,si		; Save pointer to argument start

chars:	  lodsb				; Load while not white
	  cmp	  al,' '		; Is it	space?
	  je	  nomore		; Done
	  cmp	  al,9			; Is it	tab?
	  je	  nomore		; Done
	  cmp	  al,13			; Is it	carriage return?
	  loopne  chars			; Throw	away
nomore:	  not	  cx			; Adjust count
	  mov	  es:larg,cx		; Save length
	  jmp	  SHORT	gotarg

promptit: mov	  di,si			; Save pointer to start
	  sub	  cx,cx			; Clear	count
inprompt: lodsb				; Another
	  cmp	  al,13			; Is it	carriage return?
	  je	  oneq			; Yes? Treat one quote like character
	  cmp	  al,'"'                ; Is it quote?
	  loopne  inprompt		; No? Throw away
	  mov	  es:prompt,di		; Save prompt pointer
	  not	  cx
	  mov	  es:lprompt,cx		;   and	length
	  jmp	  SHORT	white		; Get the argument

oneq:	  mov	  si,di			; Restore
	  mov	  cx,-1			; Set count to -1
	  jmp	  SHORT	qdone

gotarg:	  push	  es			; Swap ES and DS back
	  push	  ds
	  pop	  es
	  pop	  ds

	  pop	  ax
	  ret
GetArg	  ENDP

; Procedure ShowPrmpt
; Purpose   If prompt, display it
; Input	    Pointer to prompt
; Output    Prompt to screen

ShowPrmpt PROC
	  cmp	  prompt,0		; Is there a prompt?
	  je	  noshow		; If not, continue
	  push	  ds			; Save and restore DS
	  @Write  prompt,lprompt,,es	; DOS Write function
	  pop	  ds

noshow:	  ret
ShowPrmpt ENDP

; Procedure DoEnviron
; Purpose   Convert a string to	an environment variable
; Input	    String in "string"
; Output    String in "WHAT" environment variable;
;	      AX has 0 for success, nonzero for	failure

DoEnviron PROC
	  call	  GetEnv		; Get environment size,	length,	address
	  mov	  dx,ax			; Save size and	length
	  mov	  bx,cx

; Find "WHAT="

	  sub	  di,di			; Point	to start
	  sub	  al,al			; Search for zero
	  mov	  si, OFFSET what	; Point	source at "WHAT="
findwh:	  repne	  scasb			; Search
	  cmp	  BYTE PTR es:[di],0	; If double null, end of environment
	  je	  gotend
	  jcxz	  noroom		; Error	if not found
	  push	  di			; Save
	  push	  cx
	  mov	  si,OFFSET what	; Load address and length of "what"
	  mov	  cx,lwhat		;   for	comparison
	  repe	  cmpsb			; Compare
	  mov	  si,di			; Make copy
	  pop	  cx			; Restore
	  pop	  di
	  jnz	  findwh

; Find end of "WHAT" variable

	  xchg	  di,si
	  repne	  scasb			; Find end of environment variable
	  xchg	  si,di			; Point	source to next variable

; Calculate characters left to write

	  mov	  cx,bx			; Load total characters
	  sub	  cx,si			; Subtract finished to get left

; Move everything back to overwrite "WHAT="

movenv:	  push	  ds			; Save DS
	  mov	  ax,es			; Copy to ES
	  mov	  ds,ax
	  rep	  movsb			; Copy
	  mov	  BYTE PTR es:[di],0	; Put null at end in case of error
	  pop	  ds			; Restore

; Check	environment space

gotend:	  mov	  al,actual		; Load length of string
	  sub	  ah,ah			; Clear	top
	  add	  ax,lwhat		; Add length of	name
	  add	  ax,di			; Add position to get final length
	  cmp	  ax,dx			; Is it	longer than environment?
	  jge	  noroom		; Yes? Quit

; Put WHAT= at end

	  mov	  si,OFFSET what	; Load address and length of what
	  mov	  cx,lwhat
	  rep	  movsb

; Put new string at end

	  mov	  si,OFFSET string	; Load address and length of string
	  mov	  cl,actual
	  rep	  movsb
	  mov	  WORD PTR es:[di],0	; Put double null at end
	  sub	  ax,ax			; Return 0 for success
	  ret

noroom:	  inc	  ax			; Return nonzero for fail
	  ret
DoEnviron ENDP

; Procedure GetEnv
; Purpose   Find and measure the environment
; Input	    None
; Output    Segment of environment in ES, size in AX, length in	CX

GetEnv	  PROC
	  mov	  dx,es:10h		; Load segment of COMMAND.COM
	  mov	  es,dx			;   into ES
	  mov	  ax,es:2Ch		; Load COMMAND.COM's environment
	  or	  ax,ax			; Is it	0?
	  jnz	  secondry		; No? This is a	secondary command
					;   and	we have	its environment	in AX
	  dec	  dx			; Yes? This is original	COMMAND.COM
	  mov	  es,dx			;   so point ES	to paragraph before PSP
	  add	  dx,es:03		; Offset of environment	is 3 bytes in
	  add	  dx,2			; Adjust it back to PSP
	  mov	  ax,dx			; Put it in AX
secondry:

; Note:
; CodeView cannot debug	the previous section of	code, because the PSP
; addresses checked by the code	are those passed from DOS to CodeView,
; not addresses	passed from DOS	to the program.	To debug with CodeView,
; find the actual address of the environment:

;     S	500:0 L	FFFF "COMSPEC="

; When you find	the actual address, hard code it into your program:

;	  mov	  ax,110Ch		; Debug	line

; Comment the line out for final assembly after	debugging.

	  mov	  si,ax			; Save a copy
	  sub	  dx,dx			; Clear	DX for multiply
	  dec	  ax			; Get paragaraph before	environment
	  mov	  es,ax			; Load into DS
	  mov	  ax,es:03		; Size in paragraphs is	at byte	4
	  mov	  cx,16			; Multiply by 16
	  mul	  cx
	  mov	  es,si			; Restore environment address
	  sub	  di,di			; Point	to start
	  mov	  cx,ax			; Load maximum count (size of
	  mov	  bx,ax			;   environment) and save a copy
	  sub	  ax,ax			; Search for double null
null2:	  repne	  scasb			; Look for null
	  jz	  noerr			; If not out of	space, continue
	  sub	  ax,ax			;   else error (return 0)
	  jmp	  error2
noerr:	  cmp	  BYTE PTR es:[di],0	; Is it	double null?
	  jne	  null2			; No? Look again
	  mov	  cx,di			; Yes? Save length in CX
	  mov	  ax,bx			; Reload size to AX

	  ret
GetEnv	  ENDP

; Procedure BinToDec
; Purpose   Convert binary number in AX	to string
; Input	    Value in AX
; Output    Value string in "string"; length of	string in "actual"

; AL contains number to	be converted

BinToDec  PROC
	  push	  ax
	  push	  es
	  sub	  cx,cx			; Clear	counter
	  mov	  bx,10			; Get ready to divide by 10

getdigit: sub	  dx,dx			; Clear	top
	  div	  bx			; Remainder is last digit
	  add	  dl,'0'		; Convert to ASCII
	  push	  dx			; Put on stack
	  inc	  cx			; Count	character
	  or	  ax,ax			; Is quotient 0?
	  jnz	  getdigit		; No? Get another

	  mov	  actual,cl		; Save number of digits
	  mov	  ax,ds			; Load DS to ES
	  mov	  es,ax
	  mov	  di,OFFSET string	; Load source

putdigit: pop	  ax			; Get a	digit off stack
	  stosb				; Store	it to string
	  loop	  putdigit

	  pop	  es
	  pop	  ax
	  ret
BinToDec  ENDP

; Procedure UpCase
; Purpose   Convert a character	to uppercase
; Input	    Character in AH
; Output    Converted character	in AH

UpCase	  PROC

	  cmp	  ah,"a"		; Is character below lowercase?
	  jl	  ok			; If so, continue
					;   else
	  cmp	  ah,"z"		; Is character above lowercase?
	  jg	  ok			; If so, continue
					;   else
	  sub	  ah,20h		; Make it lowercase
ok:	  ret
UpCase	  ENDP

; Procedure Help
; Purpose   Display syntax screens
; Input	    None
; Output    Help to screen

Help	  PROC
	  @DispStr help1		; First	screen
	  @GetKey			; Pause
	  @DispStr help2		; Second screen
	  @Exit	  0
Help	  ENDP

	  END	 start			; End assembly

