       TITLE   INTERRUPT - BASCOM software interrupt calling routine
        PAGE    56,132
;***
; INTERRUPT - BASCOM software interrupt calling routine
;
;       Copyright <C> 1986, 1987 Microsoft Corporation
;
;Purpose:
;   Allows a BASIC program to invoke an interrupt through a CALL statement.
;
;   INTERRUPT allows BASIC to set AX,BX,CX,DX,BP,SI,DI, and the flags
;   before the call.  INTERRUPTX also allows DS and ES to be set.
;   Both routines will return the values of the registers upon the
;   completion of a successful call.  If the interrupt could not
;   be generated (due to a bad interrupt number or an illegal array)
;   then the interrupt number will be set to -1 to indicate an error.
;
;******************************************************************************
;
;Note:
;   The DOSSEG, .MODEL, .CODE, and .DATA? directives used in this program
;   are part of the simplified segment system of MASM 5.0. If you have
;   an earlier version of MASM, you must modify the source to define
;   the segments required by Microsoft high-level languages. These
;   segments are discussed in Appendix C of "Learning and Using QuickBASIC."
;

        DOSSEG                  ;requires MASM 5.0 or higher
        .MODEL  medium

;       Define all publicly accessible routines.

        PUBLIC  INTERRUPT, INTERRUPTX

;       Frame structure definition

ARG1    =       0AH             ;pointer to first of three arguments
ARG2    =       08H             ;pointer to second of three arguments
ARG3    =       06H             ;pointer to third of three arguments

;       Frame temp variables

UCODE_FLGS =    -02H            ;user code flag register value
UCODE_DS =      -04H            ;user code DS register value
REG_NUM =       -06H            ;number of regs used (INTERRUPT=8, INTERRUPTX=10)
INT_ES  =       -08H            ;INT ES register value
INT_DS  =       -0AH            ;INT DS register value
INT_FLGS =      -0CH            ;INT flags register value
INT_DI  =       -1EH            ;INT DI register value
INT_SI  =       -10H            ;INT SI register value
INT_BP  =       -12H            ;INT BP register value
INT_DX  =       -14H            ;INT DX register value
INT_CX  =       -16H            ;INT CX register value
INT_BX  =       -18H            ;INT BX register value
INT_AX  =       -1AH            ;INT AX register value
OLD_SI  =       -1CH            ;save old SI for interpreter
OLD_DI  =       -1EH            ;save old DI for interpreter

FRM_SIZ =       -1EH            ;negative size of frame temporaries

;       Locations past frame allocation used to recover post-INT BP value.

INT_BP_TMP =    -22H            ;temp location for INT BP register value

;***
; INTERRUPT, and INTERRUPTX - BASCOM software interrupt calling interface
;
; Purpose:
;       To allow a BASIC Compiler program to perform any software
;       interrupt.  The interrupt is executed with the registers
;       set to values specified in a register variable.  The post-
;       interrupt values of the registers are then stored in
;       another register variable.
;
;       CALL INTERRUPT[X] (int_no AS INTEGER,
;                          inreg AS RegType[X],
;                          outreg AS RegType[X])
;
; Inputs:
;       int_no = interrupt number (range 0 to 255) to execute
;       inreg and outreg are register variables of type RegType[X]
;       defined as follows;
;
; TYPE RegType
;     ax    AS INTEGER
;     bx    AS INTEGER
;     cx    AS INTEGER
;     dx    AS INTEGER
;     bp    AS INTEGER
;     si    AS INTEGER
;     di    AS INTEGER
;     flags AS INTEGER
; END TYPE
;
;
; TYPE RegTypeX
;     ax    AS INTEGER
;     bx    AS INTEGER
;     cx    AS INTEGER
;     dx    AS INTEGER
;     bp    AS INTEGER
;     si    AS INTEGER
;     di    AS INTEGER
;     flags AS INTEGER
;     ds    AS INTEGER
;     es    AS INTEGER
; END TYPE
;
; Outputs:
;       If no error:
;               int_no = unchanged (range 0 to 255)
;               outreg: This array will be set to the post-interrupt
;                       register values.  It has the same structure
;                       as inreg.
;       If error:
;               int_no = -1
;               outreg unchanged.  INT call is not performed.
;               error occurs:
;                       first argument not 0 to 255 (2^8-1)
;                       second or third arguments not  0 to 1048575 (2^20-1)
;                               (VARPTR will always be in this range)
;
; Modifies:
;       All, except BP, DS, and flags.
;       Also, possible side effects of INT call.
;
; Exceptions:
;       INT 24H call may result from some INT 21H MS-DOS calls.
;
;******************************************************************************

        .CODE

INTERRUPT PROC  FAR

        PUSH    BP              ;save BASCOM frame pointer on stack
        MOV     BP,SP           ;establish program frame reference
        ADD     SP,FRM_SIZ      ;allocate working space for frame
        MOV     WORD PTR [BP].REG_NUM,08H ;eight regs used (not DS or ES)
        JMP     SHORT INTERRUPT_COMMON ;jump to common code

INTERRUPT ENDP


INTERRUPTX PROC FAR

        PUSH    BP              ;save BASCOM frame pointer on stack
        MOV     BP,SP           ;establish program frame reference
        ADD     SP,FRM_SIZ      ;allocate working space for frame
        MOV     WORD PTR [BP].REG_NUM,0AH ;ten regs used (including DS and ES)

;       Save a copy of the processor flags, SI, DI, and DS in the stack frame.

INTERRUPT_COMMON:
        MOV     [BP].OLD_SI,SI  ;save old SI for interpreter
        MOV     [BP].OLD_DI,DI  ;save old DI for interpreter
        MOV     [BP].UCODE_DS,DS;save DS for interpreter
        PUSHF                   ;push the flags on the stack
        POP     [BP].UCODE_FLGS ;put value in the stack frame

;       Move eight or ten words (depending if executing INTERRUPT or INTERRUPTX)
;       of the integer input array from the far pointer computed to the frame.

        MOV     SI,[BP].ARG2    ;and array offset - pointer in DS:SI
        LEA     DI,[BP].INT_AX  ;get start of temporary register storage.
        MOV     CX,[BP].REG_NUM ;eight or ten words to move
        CLD                     ;movement is to higher memory
        PUSH    SS
        POP     ES
        REP     MOVSW           ;move the array into the stack frame

;       Save stack frame pointer to recover its value after the INT call.

        PUSH    BP              ;saved to first word past the stack frame

;       Create a two-instruction program on the stack to execute the
;       INT call requested and return with stack cleanup.
;
;       INT     XX      (hex: CD XX)
;       RETF    06      (hex: CA 06 00)
;
;       In the case of INT 25 and 26 (which leave a word of flags on the stack)
;       We generate:
;
;       INT     XX      (hex: CD XX)
;       ADD     SP,2    (hex: 83 C4 02)
;       RETF    08      (hex: CA 08 00)
;
        MOV     SI,[BP].ARG1    ;[SI] = ptr to first CALL arg - interrupt #
        MOV     BX,[SI]         ;[BL] = get integer value of INT type
        OR      BH,BH           ;test if in range, 00 to FFH is legal
        JZ      NO_INT_ERROR    ;if not, then error - jump
        JMP     INT_ERROR       ;long jump to error routine
NO_INT_ERROR:

        CMP     BL,25H          ;Interrupt 25 request?
        JZ      Int2526         ;Jump if so
        CMP     BL,26H          ;Interrupt 26 request?
        JNZ     IntNorm         ;Jump if other, "normal" interrupt
Int2526:
        MOV     AX,8            ;[AX] = argument of RETF instruction
        PUSH    AX
        MOV     AX,0CA02H       ;[AX] = RETF opcode, & arg to ADD SP
        PUSH    AX
        MOV     AX,0C483H       ;[AX] = ADD SP, opcode
        PUSH    AX
        JMP     SHORT IntInstruct

IntNorm:
        XOR     AX,AX           ;value of second word past frame
        PUSH    AX              ;put on stack - 00 byte of RETF and filler
        MOV     AX,06CAH        ;value of third word past frame
        PUSH    AX              ;put on stack - CA 06 bytes of RETF
IntInstruct:
        MOV     AH,BL           ;move interrupt number to upper byte of AX
        MOV     AL,0CDH         ;value of fourth word past frame
        PUSH    AX              ;put on stack - CD XX bytes of INT XX

;       Push far pointer of return address after the stack program
;       executes, which is INT_RET in this code segment.

        PUSH    CS              ;push current code segment for return segment
        MOV     AX,OFFSET INT_RET ;offset just after stack program call
        PUSH    AX              ;push value for return offset

;       Push far pointer pointer to the start of the stack program.
;       The stack program will be entered by executing a RETF after the
;       registers are set up.

        PUSH    SS              ;push current stack segment for starting ptr
        MOV     AX,SP           ;get current stack offset
        ADD     AX,6            ;move past the last three stack entries
        PUSH    AX              ;push offset for starting ptr of stack program

;       Move the input array values from the stack to their actual registers.

        MOV     AX,[BP].INT_FLGS ;get input flag register value
        AND     AX,0000111111010101B ;mask out undefined 8086 flags
        PUSH    AX              ;push masked flag register value

        MOV     AX,[BP].INT_AX  ;set up input AX value
        MOV     BX,[BP].INT_BX  ;set up input BX value
        MOV     CX,[BP].INT_CX  ;set up input CX value
        MOV     DX,[BP].INT_DX  ;set up input DX value

        MOV     SI,[BP].INT_SI  ;set up input SI value
        MOV     DI,[BP].INT_DI  ;set up input DI value

;       For DS and ES, leave in the compiler data segment values if:
;       executing INTERRUPT; or executing INTERRUPTX with array values of -1.

        CMP     WORD PTR [BP].REG_NUM,08H ;test if executing INTERRUPT
        JE      INT_ES_DEF      ;if so, then use both default values

        CMP     [BP].INT_DS,0FFFFH ;test if default DS to be used
        JE      INT_DS_DEF      ;if so, then leave it unchanged
        MOV     DS,[BP].INT_DS  ;set up input DS value
INT_DS_DEF:
        CMP     [BP].INT_ES,0FFFFH ;test if default ES to be used
        JE      INT_ES_DEF      ;if so, then leave it unchanged
        MOV     ES,[BP].INT_ES  ;set up input ES value
INT_ES_DEF:

        MOV     BP,[BP].INT_BP  ;set up input BP value
                                ;must be last move using BP

        POPF                    ;set up input flag register value

;       With all registers set according to the input array, execute the
;       stack program.
;
;       The following RETF pops the last two stack entries, which are
;       interpreted as a far pointer to the stack program.
;
;       The stack program executes the INT XX call which changes the
;       registers (flags included) to the values to be put into the
;       output array.
;
;       The stack program then executes the RETF 06 instruction which
;       does two operations.  First, the next two entries on stack are
;       popped and interpreted as a far ptr return address, which points
;       the code at INT_RET in this code segment.  Second, the stack
;       pointer is then adjusted by six bytes to remove the six-byte
;       program from the stack.

        RET                     ;far return to execute stack program, etc.
INT_RET:

;       The stack should now contain only the first entry past the
;       frame, the value of the stack frame pointer itself.  First
;       save the BP value from the INT call, then get the old value
;       to reference the frame.

        PUSH    BP              ;save post-INT value of BP
        MOV     BP,SP           ;temporary frame is second word past frame
        MOV     BP,[BP+02H]     ;get real frame reference value

;       Put post-INT value of all registers into the frame variables
;       to be subsequently written into the output array.

        PUSHF                   ;put flags on the stack
        POP     [BP].INT_FLGS   ;put in post-INT flag register value

        PUSH    [BP].UCODE_FLGS ;get old copy of flags from frame
        POPF                    ;and restore the old flag values

        MOV     [BP].INT_AX,AX  ;put in post-INT AX value
        MOV     [BP].INT_BX,BX  ;put in post-INT BX value
        MOV     [BP].INT_CX,CX  ;put in post-INT CX value
        MOV     [BP].INT_DX,DX  ;put in post-INT DX value

        MOV     AX,[BP].INT_BP_TMP ;get post-INT BP value (one entry past frame)
        MOV     [BP].INT_BP,AX  ;put in post-INT BP value

        MOV     [BP].INT_SI,SI  ;put in post-INT SI value
        MOV     [BP].INT_DI,DI  ;put in post-INT DI value

        MOV     [BP].INT_DS,DS  ;put in post-INT DS value
        MOV     [BP].INT_ES,ES  ;put in post-INT ES value

;       Move frame register values to the output array whose
;       far pointer is in the frame.

        MOV     DS,[BP].UCODE_DS;replace original DS value

        LEA     SI,[BP].INT_AX  ;get start of register area in frame

        PUSH    DS
        POP     ES
        MOV     DI,[BP].ARG3    ;get output array offset
        MOV     CX,[BP].REG_NUM ;eight or ten words to move
        CLD                     ;movement is toward upper memory
        REP     MOVSW           ;perform the transfer

;       Clean up stack to remove frame.  Remove CALL arguments with RETF.

        MOV     SI,[BP].OLD_SI  ;replace old SI for interpreter
        MOV     DI,[BP].OLD_DI  ;replace old DI for interpreter
        MOV     SP,BP           ;deallocate temporary frame variables
        POP     BP              ;return compiler frame pointer
        RET     06              ;remove three CALL arguments and far return

;       If error, then restore DS, set int_no to -1 to report error,
;       clean up, and exit.

INT_ERROR:
        MOV     SI,[BP].ARG1    ;ptr to first CALL arg - interrupt number
        MOV     [SI],0FFFFH     ;set interrupt number to -1 for error
        MOV     SI,[BP].OLD_SI  ;replace old SI for interpreter
        MOV     DI,[BP].OLD_DI  ;replace old DI for interpreter
        MOV     DS,[BP].UCODE_DS;replace original DS value
        MOV     SP,BP           ;deallocate temporary frame variables
        POP     BP              ;return compiler frame pointer
        RET     06              ;remove three CALL arguments and far return

INTERRUPTX ENDP

        END
