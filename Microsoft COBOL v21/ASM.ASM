        TITLE   Assembly language interface table and macro (asmnam)

;*********************************************************************
;
;   Contains the skeleton structure asmtab and the count of assembler
;   routines, asmcnt. Contains the definition for macro asmnam, which
;   produces the correct table entries for assembler and other non-COBOL
;   routines.
;

	INCLUDE pseg.mac

        SUBTTL  Build assembler subroutine table macros
        PAGE

ASM86   equ     0
C       equ     1
PASCAL  equ     2
FORTRAN equ     3
last    equ     0		;; only asm86 allowed for now


asmnam  macro   entry,lang
        LOCAL   A,B,language

          ;; asmnam builds a table of routine entry point name string
          ;; lengths, name strings, and long pointers to the entry point
          ;; The entry points must be defined as PUBLIC FAR PROC's

if1
ifb <entry>
	%out    '*** error - Entry point not specified'
else

ifb <lang>
	%out    '*** error - Subroutine language not specified for &entry'
language equ 0ffh            ;; Invalid language type
else

ifndef lang
	%out    '*** error - Invalid language (&lang) specified for &entry'
language equ 0ffh
else

if lang gt last
	%out    '*** error - Invalid language (&lang) specified for &entry'
language equ 0ffh
else
language equ lang
endif

endif ;; ifndef lang
endif ;; ifb <lang>
endif ;; ifb <entry>
endif ;; if1

ifnb <entry>
        EXTRN   entry:FAR
	START_DSEG
COUNT   =       COUNT+1
        DW      B-A        ;; length of program name string
A       LABEL   BYTE
        DB      '&entry'   ;; program name string
B       LABEL   BYTE
	DB      language   ;; declaration of program language
        DD      entry      ;; declaration of program entry point
	END_DSEG
endif
        endm


        SUBTTL  Asmtab and asncnt structures
        PAGE

        START_DSEG
        PUBLIC  _asmtab
        PUBLIC  _asmcnt
COUNT   =       0
_asmtab  LABEL   BYTE
	END_DSEG
        .lall
;   *************************** user routines are entered here  *************
        include userprog.mac
;   *************************** user routines are entered here  *************

        .sall
        START_DSEG
_asmcnt  DW      COUNT	; set by macro asmnam to be the number of invocations
                           ; of asmnam
        END_DSEG

        END
