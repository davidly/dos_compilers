        TITLE   ABSOLUTE - helper for assembly routines
;***
; ABSOLUTE - Helper for calling BASIC interpreter assembly routines
;
;       Copyright <C> 1986, Microsoft Corporation
;
;Purpose:
; Allow a BASIC program to call a routine which is located at an
; absolute memory address in the DEF SEG.
;
; The form of the call is:
;
;       CALL ABSOLUTE(<param>,...,<loc>)
;
; where
;       <param>,...   -  zero or more parameters for the assembly routine
;       <loc>         -  an Integer variable that contains the
;                        location in the DEF SEG of the start of
;                        the assembly routine
;
; The location parameter will be removed, and the routine at DEF SEG:<loc>
; will be called with the remaining parameters.
;
; Notes:
;       - The parameters are not checked or verified before being passed
;         to the assembly routine.
;       - CALL must be used.  CALLS will cause execution to jump to a
;         random location.
;       - The DOSSEG, .MODEL, .CODE, and .DATA? directives are part of 
;         the simplified segment system of MASM 5.0. If you have an
;         earlier version of MASM, you must modify the source to define 
;         the segments required by Microsoft high-level languages. These 
;         segments are discussed in Appendix C of "Learning and Using 
;         QuickBASIC."
;
;******************************************************************************
;
        DOSSEG                ;requires MASM 5.0 or higher
        .MODEL  medium

;       Define the routine as public.

        PUBLIC  ABSOLUTE

;       Define the seg segment

        .DATA?

        EXTRN  b$seg:WORD     ;seg segment

;***
; ABSOLUTE - Call absolute address
;
;Purpose:
; Routine which can be directly called from the basic level which in turn
; calls an absolute address.
;
;Entry:
; The actual number of parameters is variable, and depends on the routine
; that ABSOLUTE will in turn call. The LAST parameter pushed MUST be the DS
; offset of an integer variable containing the offset of the routine to be
; called. The current DEF SEG is used as the segment for the call.
;
;Exit:
; Whatever the called routine elects. We do NOT return here.
;
;Uses:
; This routine follows convention, but does no saving or checking of the code
; actually called.
;
;Notes:
; The called routine receives control with all parameters passed to ABSOLUTE,
; except the offset integer, on the stack in Pascal convention. The return
; address present is back to the BASIC level code which CALLed ABSOLUTE.
;
; Stack on call to ABSOLUTE:
;
;
;               \       Variable number of parameters           \
;               |          to routine to be CALLed              |
;               +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
;               |       Near pointer to I2 var containing       |
;               |       the offset of the routine to CALL       |
;               +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
;               |CS                                             |
;               +    Far return address to caller of ABSOLUTE   +
;       [SP] -> |IP                                             |
;               +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
;
; Stack on transfer to called routine:
;
;               \       Variable number of parameters           \
;               |          to routine to be CALLed              |
;               +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
;               |CS                                             |
;               +    Far return address to caller of ABSOLUTE   +
;       [SP] -> |IP                                             |
;               +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
;
;******************************************************************************

        .CODE

ABSOLUTE PROC FAR

        POP     AX              ;return offset
        POP     DX              ;return segment
        POP     BX              ;get pointer to routine address
        PUSH    DX              ;restore return address
        PUSH    AX
        PUSH    [b$seg]         ;stack DEF SEG segment
        PUSH    [BX]            ;stack routine offset

        RET                     ;jump to ABSOLUTE routine

ABSOLUTE ENDP

        END
