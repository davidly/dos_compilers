BUFFER_SIZE	EQU	2048		; Buffer size in bytes for disk I/O
CR		EQU	13		; ASCII code for Return
ESCAPE		EQU	27		; ASCII code for Esc key

MDA		EQU	0		; Adapter constants
CGA		EQU	1
MCGA		EQU	2
EGA		EQU	3
VGA		EQU	4
MONO		EQU	0		; Display constants
COLOR		EQU	1


;* LoadPtr - Macro to load far address into segment:register pair, or
;* near address into register.
;*
;* Params:  sgmnt - Segment to be loaded with segment address
;*	    reg - Register to be loaded with offset address
;*	    ptr - Pointer to address
;*
;* Shows:   Instructions - lds	   les
;*	    Directives - MACRO	   IF	     IFIDNI	ELSE	  ELSEIF
;*			 ENDIF	   .ERR      %OUT	EXITM	  ENDM
;*	    Operators - < >	  ;;

LoadPtr MACRO sgmnt, reg, ptr		;; Macro definition
    IF @DataSize			;; If far pointer, and
	IFIDNI <sgmnt>, <ds>		;;   if 1st argument is DS,
	    lds reg, ptr		;;   load DS:reg with far address
	    EXITM
	ENDIF
	IFIDNI <sgmnt>, <es>		;;   or if 1st argument is ES,
	    les reg, ptr		;;   load ES:reg with far address
	    EXITM
	ENDIF
	.ERR				;; Generate error if not DS or ES
	%OUT 1st macro argument must be DS or ES

    ELSE				;; If near pointer,
	IFIDNI <sgmnt>, <es>		;;   and if segment is ES,
	    push ds			;;   ensure ES points to
	    pop  es			;;   same segment as DS
	ENDIF
	mov reg, ptr			;; Then load reg with near address
    ENDIF
ENDM


;* GetVidOffset - Macro to determine offset in video segment that corresponds
;* to given screen coordinates.
;*
;* Params:  row - Screen row (top line = 0)
;*	    col - Screen column (leftmost column = 0)

GetVidOffset MACRO row, col		;; Macro definition
    mov ax, row
    mov bl, 80				;; Number of columns per row *
    mul bl				;;   current row + current column =
    add ax, col 			;;   character byte #
    shl ax, 1				;; Double to account for cell size
ENDM					;; Result in AX register


;* DispText - Macro to display text at given screen coordinates.
;*
;* Shows:   Equates - @DataSize     @data
;*
;* Params:  row - Screen row (top line = 0)
;*	    col - Screen column (leftmost column = 0)
;*	    str - Pointer to ASCIIZ string

DispText MACRO row, col, str		;; Macro definition
    IF @DataSize			;; If far pointer required,
	mov ax, @data			;;   pass data segment
	push ax
    ENDIF
    mov  ax, str			;; Pointer to ASCIIZ text
    push ax
    mov  ax, col			;; Screen column
    push ax
    mov  ax, row			;; Screen row
    push ax
    call StrWrite
    IF @DataSize
	add sp, 8			;; Clean stack for far data
    ELSE
	add sp, 6			;; Clean stack for near data
    ENDIF
ENDM


;* Vector - Macro to read current interrupt vector, store it, and replace it.
;*
;* Shows:   Equates - @CodeSize     @code
;*
;* Params:  num - Vector number
;*	    old - Pointer to doubleword for storing old vector
;*	    new - Pointer to new handler

Vector MACRO num, old, new		;; Macro definition
    push ds				;; Save DS and ES registers
    push es
    mov ah, 35h 			;; AH = DOS function number
    mov al, num 			;; AL = interrupt number
    int 21h				;; Get Interrupt Vector
    mov WORD PTR old[0], bx		;; Store it
    mov WORD PTR old[2], es
    IF @CodeSize			;; If medium or large model,
	lds dx, new			;;    load DS from parameter
    ELSE
	mov bx, @code			;; Else ensure DS points to
	mov ds, bx			;;    to code segment
	mov dx, new			;; DS:DX equals new vector
    ENDIF
    mov ah, 25h 			;; AH = DOS function number
    int 21h				;; Set Interrupt Vector
    pop es				;; Restore ES and DS
    pop ds
ENDM


;* Declare structure for disk statistics.
disk_stat	STRUC
  total 	DW	?		; total clusters
  avail 	DW	?		; available clusters
  sects 	DW	?		; sectors per cluster
  bytes 	DW	?		; bytes per sector
disk_stat	ENDS


;* Declare structure for parameter block.
parmblk 	STRUC
  env		DW	?		; Segment address of environment block
  taddr 	DD	WORD PTR ?	; Segment:offset address of tail
  fcb1		DD	WORD PTR ?	; Segment:offset address of 1st FCB
  fcb2		DD	WORD PTR ?	; Segment:offset address of 2nd FCB
parmblk 	ENDS


;* Declare structure for video configuration.
;*
;* Shows:   STRUC    ENDS    COMM

vid_config	STRUC
  mode		DB	?		; Current mode
  dpage 	DB	?		; Current display page
  rows		DB	?		; Number of display rows - 1
  display	DB	?		; Either MONO or COLOR
  adapter	DB	?		; Adapter code
  CGAvalue	DB	?		; Enable value for CGA
  sgmnt 	DW	?		; Video segment with page offset
vid_config	ENDS


;* Declare communal variables.

	COMM	NEAR vconfig:vid_config ; Video configuration structure
	COMM	NEAR _psp:WORD		; Segment address of Pgm Segment Prefix
	COMM	NEAR _env:WORD		; Segment address of environment block
