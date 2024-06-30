;*****************************************************************************
;
;  Copyrigth (C) 1984 Logitech. All Rights Reserved.
;
;  Permission is hereby granted to registered users to use or
;  abstract the following program in the implementation of
;  customized versions. This permission does not include the
;  right to redistribute the source code of this program.
;
;  LOGITECH SA.  CH-1143 Apples,  Switzerland
;
; Module:       RTS.ASM
;               Mainline of Modula-2/86(tm) Run Time System
;
; Version:      8086, RAM-based,  MS-DOS 2.0
;
; Release:      1.1 - Dec 84
;
;*****************************************************************************
;
; process descriptors are always allocated at a paragraph address 
;
;*****************************************************************************

CGROUP  group   code
DGROUP  group   data
SGROUP  group   stack

        assume  CS:     CGROUP
        assume  DS:     DGROUP
        assume  ES:     NOTHING
        assume  SS:     SGROUP

        include RTS.INC


;*****************************************************************************

; EXPORT QUALIFIED
;   (* data: variables *)
        public  START_MEM, MEM_SIZE
        public  m2_start_mark
        public  m2_end_mark
        public  RTS_PROCESS
        public  cur_proc_addr
        public  cur_process
        public  BASE_PAGE_PTR;
        public  base_page
        public  SAVED_DISK, RTS_DISK
        public  device_mask
        public  term_proc_addr
        public  old_NMI_vector

;   (* code: procedures, labels *)
        public  DUMMY_ISR
        public  AFTER_RESIDENT
        public  RTS_DS
        public  SYS_RESET
        public  TERMINATE
        public  COMP_STACK
        public  WRITE
        public  WRITE_MSG
        public  WRITE_LN
        public  WRITE_STATUS
        public  NORM_ADDR
        public  GET_CURR_DISK
        public  SELECT_DISK
;
;***********************************************************************
code    segment public  'code'

; FROM LOADER IMPORT
        extrn   LoadProg:NEAR           ; resident loader

; FROM SERVICES IMPORT
        extrn   RTS_BRANCH:NEAR         ; interrupt dispatcher
        extrn   STACK_OVF:NEAR          ; stack overflow
        extrn   DIV_BY_ZERO:NEAR        ; divide by zero handler
; FROM TRANSFER IMPORT
        extrn   REST_I_V:NEAR           ; restore interrupt vectors
        extrn   STOPPED_1B:NEAR         ; break handler interrupt 1bH
        extrn   STOPPED_23:NEAR         ; break handler interrupt 23H
        extrn   GET_INTERRUPT_MASK:NEAR ; reads the current interrupt mask
        extrn   SET_INTERRUPT_MASK:NEAR ; restores the interrupt mask
        extrn   NMI_server:near         ; interrupts from 8087
; FROM DBUG IMPORT
        extrn   DEBUGGER : near

code    ends
;*****************************************************************************



;*****************************************************************************
data    segment public  'data'

; Workspace of the MAIN process, starting with RTS:

                org     0

cur_process     label   ProcessDescriptor

BASE_PAGE       db      100H dup (?)    ; required for the Main-Module
; BASE_PAGE has to be at offset 0 !!!!!!!

; RTS_PROCESS has to be on paragraph boundary. keep it here, and never
; insert any definitions between BASE_PAGE and RTS_PROCESS
RTS_PROCESS     ProcessDescriptor <>

cur_proc_addr   dd      ?       ; pointer to current process

TOP_OF_MEMORY   equ     word ptr BASE_PAGE+2
                        ; last free paragraph, +1. Set up by DOS loader
TRANS_COM_SIZE  equ     440H    ; transient part of COMMAND.COM (in parag)

m2_start_mark   dw      ?       ; this two variables show the region of
m2_end_mark     dw      ?       ; possibly loaded m2 programs

START_MEM       dw      ?       ; points behind the loaded modula program
MEM_SIZE        dw      ?       ; number of free paragraphs at START_MEM
DOS             dd      ?       ; jump to DOS
START_ADDR      dd      ?       ; start address of Modula program (.LOD file)
term_proc_addr  dd      term_procedure  ; termination procedure

; - saved interrupt vectors -
old_NMI_vector  dd      ?
OLD_RTS_VECTOR  dd      ?
OLD_DIV0_VECTOR dd      ?
OLD_INTO_VECTOR dd      ?
OLD_BREAK_VECTOR_23 dd      ?
OLD_BREAK_VECTOR_1B dd      ?
old_interrupt_controller_mask   dw      ?
device_mask     dw      ?       ; initial value is the old interrupt mask
                                ; of the interrupt controller
                                ; a device may be enabled/disabled, by setting
                                ; the corresponding bit to 0/1
                                ; two functions to do operations on this mask
                                ; are provided:
                                ;    get_device_status, set_device_status



set_CW8087      dw      360H    ; init 8087 with interrupts
get_CW8087      dw      0

BASE_PAGE_PTR   dd      BASE_PAGE       ; ptr to program segment prefix
MAIN_SP         dw      ?
MAIN_SS         dw      ?

START_DISK      db      ?
RTS_DISK        db      ?
SAVED_DISK      DB      ?

; string constants and jump or index tables
SOME_ERROR      DB      '===> $'

NORMAL_MSG      DB      'normal termination$'
WARNED_MSG      DB      'warning$'
STOP_MSG        DB      'stopped$'
ASSERT_MSG      DB      'wrong assertion$'
HALT_MSG        DB      'HALT called$'
CASE_MSG        DB      'case-tag error$'
STACK_MSG       DB      'stack overflow$'
HEAP_MSG        DB      'heap overflow$'
FCT_ERR_MSG     DB      'function return error$'
ADDR_OVF_MSG    DB      'address overflow$'
REAL_OVF_MSG    DB      'real overflow$'
real_udf_msg    db      'real underflow$'
bad_op_msg      db      'bad operand$'
CARD_OVF_MSG    DB      'cardinal overflow$'
INTEGER_OVF_MSG DB      'integer overflow$'
RANGE_ERR_MSG   DB      'range error$'
ZERO_DIV_MSG    DB      'division by zero$'
PROC_END_MSG    DB      'coroutine end$'
LOAD_MSG        DB      'cannot load$'
CALL_MSG        DB      'unsuccessfull program call$'
NO_PROG_MSG     DB      'program not found$'
NO_MOD_MSG      DB      'module not found$'
INCOMPAT_MSG    DB      'incompatible module keys$'
BAD_FILE_MSG    DB      'bad structure in file$'
ILL_INSTR_MSG   DB      'illegal instruction encountered$'
ILL_FCT_MSG     DB      'illegal RTS call$'
NO_MORE_ISR     DB      'too many concurrent IO-Processes$'

                even
STATUS_MSG      DW      NORMAL_MSG, WARNED_MSG, STOP_MSG, ASSERT_MSG
                DW      HALT_MSG, CASE_MSG, STACK_MSG, HEAP_MSG
                DW      FCT_ERR_MSG, ADDR_OVF_MSG, REAL_OVF_MSG
                dw      real_udf_msg,bad_op_msg,CARD_OVF_MSG 
                DW      INTEGER_OVF_MSG, RANGE_ERR_MSG, ZERO_DIV_MSG
                DW      PROC_END_MSG, LOAD_MSG, CALL_MSG
                DW      NO_PROG_MSG, NO_MOD_MSG, INCOMPAT_MSG, BAD_FILE_MSG
                DW      ILL_INSTR_MSG, ILL_FCT_MSG, NO_MORE_ISR
data ends
;*****************************************************************************


;*****************************************************************************
stack   segment stack   'stack'

; the stack will be used to load and start the modula-2 program

        dw      400h dup (?)    ; MS-DOS loader will set up stack

stack   ends
;*****************************************************************************


;*****************************************************************************
code segment public     'code'

; We return to DOS through a jump to location 0 of the Program Segment Prefix
; There is no explicit release of memory or stack reset.

; After loading of the RTS, memory has the following structure:
; 0000H   .. 03FFH          : interrupt vectors
; 0400H   .. DOS_END        : resident portion of DOS
; DOS_END .. DOS_END + 0FFH : Program Segment Prefix (PSP), set up by DOS
; DOS_END + 100H .. xx      : Code of RTS
; xx .. yy                  : Data of RTS  ( xx = RTS_DS)
; yy .. zz                  : Stack of RTS
; zz .. end_of_memory - 17K : free memory  ( zz = START_MEM)
; last 17K of RAM           : DOS command interpreter (COMMAND.COM)


RTS_DS  DW      ?               ; We need a way to set the DS later on

RTS_START:                      ; start address of the RTS


        push    DS              ; base of PSP
        ; read and store data-segment of RTS:
        mov     ax,DGROUP
        mov     ES,ax           ; point to data segment
        mov     RTS_DS,ax       ; (make it easy to access later, in ISR's)
        ; copy the PSP into the privat variable BASE_PAGE:
        mov     di,offset BASE_PAGE
        mov     si,0
        mov     cx,size BASE_PAGE
        cld
        rep movsb               ; copy PSP into BASE_PAGE
        mov     DS,ax           ; now switch to RTS data segment
        ; store return point:
        pop     word ptr DOS+2  ; set up exit vector, which
        mov     word ptr DOS,0  ; goes to PSP:0
        ; Find the current disk:
        CALL    GET_CURR_DISK
        mov     START_DISK,     al      ; save for Postmortem dump
        mov     RTS_DISK,       al

        STI                     ; Allow interruptions

;-------------------------------------------------------
;             Initial Memory Allocation
;-------------------------------------------------------
        ; find the beginning of not used memory (right after the RTS):
        mov     m2_start_mark,SS        ; bottom of last segment ..
        mov     ax,sp
        mov     cl,4
        shr     ax,cl                   ; plus paragraphs of stack..
        add     ax,10                   ; (plus fudge factor..)
        add     m2_start_mark,ax                ; ..gives first free paragraph
                                        ;   after the RTS
        mov     ax, m2_start_mark
        mov     start_mem, ax           ; initialize start_mem
                                        ; will be updated by loader
        ; now find out, how much memory is available for the Modula program:
        mov     ax,TOP_OF_MEMORY
        sub     ax,m2_start_mark
IF KEEP_COM
        sub     ax,     TRANS_COM_SIZE
ENDIF
        cmp     ax, MAX_MEM_FOR_M2      ; more than we need?
        jbe     N2MUCH                  ;   nope
        mov     ax, MAX_MEM_FOR_M2      ;   yes, just take what is needed
N2MUCH:
        mov     MEM_SIZE,ax             ; compute free paragraphs

; initialize cur_proc_addr with normalized address of RTS_PROCESS
; where the offset is calculated to 0 (if not ERROR !!!!!!!)
        mov     bx,ds
        mov     ax,offset rts_process
        call    norm_addr
        mov     word ptr cur_proc_addr,ax
        mov     word ptr cur_proc_addr + 2,bx

; Load the Modula-2 program to run. It will be loaded at START_MEM and
; START_MEM will be updated to point behind that loaded program:
;
        mov     ax,RTS_PROCESS.PD_PROG_ID       ; AX = current prog id
        mov     dx,word ptr RTS_PROCESS.PD_MOD_TABLE
        mov     cx,word ptr RTS_PROCESS.PD_MOD_TABLE+2  ; CX:DX = old mod tab
        call    LoadProg                        ; load it and return error
                                                ; code in BX (0=ok).
        mov     word ptr RTS_PROCESS.PD_MOD_TABLE,dx
        mov     word ptr RTS_PROCESS.PD_MOD_TABLE+2,cx  ; CX:DX = new mod tab
        mov     word ptr START_ADDR,di
        mov     word ptr START_ADDR+2,ES        ; ES:DI = start address
        test    bx,bx                           ; load ok?
        jz      LOADED                          ;   yes
        jmp     SYS_RESET                               ;   no

LOADED:
; At this point START_MEM is the first free paragraph after code and data
; of the Modula program. This space will be used for heap (starting at
; the lowest address) and for stack (starting at the high end of memory).

; Switch to real run-time stack. The stack of the main process is set
; to the end of the free memory:
        MOV     AX, MEM_SIZE
        MOV     BX, START_MEM
        mov     m2_end_mark, bx         ; upper limit for a m2 codesegment
        add     m2_end_mark, ax
        CALL    COMP_STACK              ; BX becomes SS, AX becomes SP
        MOV     MAIN_SS, BX
        MOV     MAIN_SP, AX
        MOV     SS, BX                  ; No need to disable Interrupts,
        MOV     SP, AX                  ; the processor does it here


;-------------------------------------------------------
; Fill in the Default Process Descriptor:
;-------------------------------------------------------

        ; First we put the Return Address in RTS on the
        ; Stack. It will be used in case of an error
        ; in the Main program.
        PUSHF
        PUSH    CS
        MOV     AX,     OFFSET  AFTER_RESIDENT
        PUSH    AX
        PUSH    BP


        ; Now put all the significant registers at
        ; their places in P.D:
        PUSHF
        POP     RTS_PROCESS.PD_FLAGS
        MOV     RTS_PROCESS.PD_SP, SP
        MOV     RTS_PROCESS.PD_SS, SS
        MOV     RTS_PROCESS.PD_DS, DS

        ; and the initial values for the heap managment:
        MOV     AX,     START_MEM                       ; Paragraph addr
        MOV     word ptr RTS_PROCESS.PD_HEAP_BASE + 2,AX ; first para of heap
        MOV     word ptr RTS_PROCESS.PD_HEAP_TOP + 2,AX ; top para. of heap
        ; Only the minimum is done here, to be as
        ; independant from the implementation of the
        ; heap manager as possible. See also NEW_PROCESS

        ; Set all the values needed for TRANSFER
        ; and error handling:
        MOV     RTS_PROCESS.PD_dbug_status,0    ; for debugger
        MOV     word ptr RTS_PROCESS.PD_PROG_END,       SP
        MOV     word ptr RTS_PROCESS.PD_PROG_END+2,     SS


;-------------------------------------------------------
; Prepare the interrupt system:
;-------------------------------------------------------

        CALL    GET_INTERRUPT_MASK
        MOV     rts_process.PD_PRIO_MASK, 0             ; no priority
        MOV     old_interrupt_controller_mask,AX        ; save it
        mov     device_mask, AX                 ; initial value

        ; Compute physical address of RTS vector:
        mov     bx,RTS_INT*4
        MOV     AX, 0
        MOV     ES, AX

        ; Set entry point for RTS-interrupt-vector:
        MOV     AX,     ES: [BX]                ; Save the old value
        MOV     word ptr OLD_RTS_VECTOR,                AX
        MOV     AX,     ES: 2[BX]
        MOV     word ptr OLD_RTS_VECTOR + 2,    AX
        MOV     ES:word ptr [BX], offset RTS_BRANCH
        MOV     ES:word ptr 2[BX], CS           ; Set the new-one

        ; Interrupt vector 0, used for 'divide by zero':
        mov     bx,0*4
        mov     ax,ES:[bx]      ; Save the old value
        mov     word ptr OLD_DIV0_VECTOR, ax
        mov     ax,ES:2[bx]
        mov     word ptr OLD_DIV0_VECTOR        + 2,ax
        mov     ES:word ptr 2[bx], CS   ; Set the new-one
        mov     ES:word ptr[bx], offset DIV_BY_ZERO

        ; Interrupt vector 4 (used for INTO) has also
        ; to point to the RTS:
        mov     bx,4*4
        MOV     AX, ES:[bx]             ; Save the old value
        MOV     word ptr OLD_INTO_VECTOR, AX
        MOV     AX, ES:2[bx]
        MOV     word ptr OLD_INTO_VECTOR        + 2,    AX
        MOV     ES:word ptr [bx], offset RTS_BRANCH
        MOV     ES:word ptr 2[bx], CS           ; Set the new-one
        ; Note, that there is no special entry for the
        ; interrupt on overflow. The calling program
        ; has to set the function code in AX as for the
        ; other RTS calls. Needed, because an overflow
        ; may occur in several error conditions
        ; (INTEGER, CARDINAL, SUBRANGE...)

        ; Interrupt vector 2, used for '8087 interrupts':
        esc     1cH,BX          ; FNINIT: clear and init 8087
        esc     0DH,set_CW8087  ; FLDCW: set ctrl word interrupt enabled
        esc     0FH,get_CW8087  ; FNSTCW: read it again
; save old value in any case, it is always restored 
        mov     bx,2*4
        mov     ax,ES:[bx]      ; Save the old value
        mov     word ptr old_NMI_vector, ax
        mov     ax,ES:2[bx]
        mov     word ptr old_NMI_vector + 2,ax
        mov     ax,set_CW8087   ; simulate WAIT (dont execute it!!)
        mov     ax,set_CW8087
        mov     ax,set_CW8087
        mov     ax,set_CW8087
        cmp     ax,get_CW8087   ; if equal, the 8087 is assumed present
        jne     No8087
; install interrupt service routine only if 8087 is present
        mov     ES:word ptr 2[bx], CS   ; Set the new-one
        mov     ES:word ptr[bx], offset NMI_server
No8087:

        ; Interrupt vector 1BH (used for BREAK) has also
        ; to point to the RTS:
        mov     bx,4*1BH
        MOV     AX, ES:[bx]             ; Save the old value
        MOV     word ptr OLD_BREAK_VECTOR_1B, AX
        MOV     AX, ES:2[bx]
        MOV     word ptr OLD_BREAK_VECTOR_1B + 2,       AX
        MOV     ES:word ptr [bx], offset STOPPED_1b
        MOV     ES:word ptr 2[bx], CS           ; Set the new-one

        ; Interrupt vector 23H (used for ^C) has also
        ; to point to the RTS:
        mov     bx,4*23H
        MOV     AX, ES:[bx]             ; Save the old value
        MOV     word ptr OLD_BREAK_VECTOR_23, AX
        MOV     AX, ES:2[bx]
        MOV     word ptr OLD_BREAK_VECTOR_23 + 2,       AX
        MOV     ES:word ptr [bx], offset stopped_23
        MOV     ES:word ptr 2[bx], CS           ; Set the new-one



;-------------------------------------------------------
; Call the MODULA program:
;-------------------------------------------------------

                ; For debugger, to detect first
                ; procedure in calling sequence:
        MOV     BP,     0

CALL_RESIDENT:
        CALL    START_ADDR                      ; call loaded program

; We are back from the MODULA program.

AFTER_RESIDENT: 
        ; if program terminated normally, we came here not through
        ; an interrupt, but by a RET instruction (therefore interrupts
        ; are enabled:
        CLI
        MOV     DS, RTS_DS                      ; restore data segment

        ; Restore the old interrupt vectors for every IO-Process,
        ; waiting on an interrupt:
        mov     ax,word ptr cur_proc_addr + 2
        mov     es,ax
        mov     ES:CUR_PROCESS.PD_PROG_ID, 0
                        ; 0 as program id is a sort of a joker.

        ; Restore the old Interrupt Mask:
        mov     ES:CUR_PROCESS.PD_PRIO_MASK, 0  ; no priority
        MOV     AX,     old_interrupt_controller_mask
        CALL    SET_INTERRUPT_MASK

        CALL    REST_I_V

        ; set break vector to a dummy interrupt service routine,
        ; because the following write functions will enable
        ; interrupts; we don't want to be interrupted by a ^break
        mov     ax, 0
        mov     es, ax
        mov     bx,4*1BH
        MOV     ES:word ptr [bx], offset DUMMY_ISR
        MOV     ES:word ptr 2[bx], CS           ; Set the new-one

        mov     ax,word ptr cur_proc_addr + 2
        mov     es,ax
        MOV     AX,ES: CUR_PROCESS.PD_STATUS
        test    ax,ax
        jz      RTS_END                         ; 0 = No error
        CALL    WRITE_LN
        MOV     DX,OFFSET SOME_ERROR
        CALL    WRITE_MSG
        MOV     BX,ES:CUR_PROCESS.PD_STATUS
        CALL    WRITE_STATUS
        CALL    WRITE_LN
        ; It is safer to return to DOS and possibly reload the
        ; RTS rather then restarting its execution, since the
        ; code might have been overwritten.

;-------------------------------------------------------
; Back from the MODULA program:
;-------------------------------------------------------

RTS_END:

CallTermProc:
;============
; this 'procedure' is the equivalent to 'CallTermProc' in module
; 'System'. It has to be repeated here, because the termination
; of the base layer does not pass through module 'Program', and
; therefore 'System.CallTermProc' is not called

        mov     ds,rts_ds       ; set data segment
        mov     ax,word ptr term_proc_addr + 2  ; segement addr
        mov     bx,cs
        cmp     ax,bx
        je      CallTermProc_end        ; OwnTermProc
        call    term_proc_addr  ; invoke termination procedure
        jmp     CallTermProc
CallTermProc_end:

; Restore the modified interrupt vectors
;       mov     ds,rts_ds
        MOV     AX,     0
        MOV     ES,     AX
        MOV     BX,     RTS_INT*4
        MOV     AX,word ptr OLD_RTS_VECTOR              ; The RTS entry
        MOV     ES:word ptr [BX],AX
        MOV     AX,word ptr OLD_RTS_VECTOR + 2
        MOV     ES:word ptr [BX]+2,AX
        MOV     AX,word ptr OLD_DIV0_VECTOR             ; The entry for DIV0
        MOV     ES:word ptr 0, AX
        MOV     AX,word ptr OLD_DIV0_VECTOR     + 2
        MOV     ES:word ptr 2, AX
        MOV     AX,word ptr OLD_INTO_VECTOR             ; The entry for INTO
        MOV     ES:word ptr 16, AX
        MOV     AX,word ptr OLD_INTO_VECTOR     + 2
        MOV     ES:word ptr 18, AX
        MOV     AX,word ptr old_NMI_vector      ; The entry for NMI
        MOV     ES:word ptr 4*2, AX
        MOV     AX,word ptr old_NMI_vector + 2
        MOV     ES:word ptr 4*2 + 2, AX

        MOV     AX,word ptr OLD_BREAK_VECTOR_1B ; The entry for BREAK 1BH
        MOV     ES:word ptr 4*1bH, AX
        MOV     AX,word ptr OLD_BREAK_VECTOR_1B + 2
        MOV     ES:word ptr 4*1bH + 2, AX

        MOV     AX,word ptr OLD_BREAK_VECTOR_23 ; The entry for BREAK 23H
        MOV     ES:word ptr 4*23H, AX
        MOV     AX,word ptr OLD_BREAK_VECTOR_23 + 2
        MOV     ES:word ptr 4*23H + 2, AX

        ; select the same drive that was selected at beginning:
        MOV     DL,     START_DISK
        CALL    SELECT_DISK

SYS_RESET:
        jmp     DOS             ; Back to DOS


;-------------------------------------------------------
;       Termination procedure, called after end of main
;       program. If System announced one, then this is
;       called, else an empty procedure is called
;-------------------------------------------------------
Term_Procedure  proc far                ; MUST be FAR !!!!!
                ret
Term_Procedure  endp


; We arrive here, when a program is terminated (exept level 0) or
; if any error had occured. In the former case, status is 'normal',
; in the latter case the error-code is set in the Status-field of
; Current Process Descriptor.



TERMINATE:
;=========
        MOV     DS, RTS_DS

        ; Free the resources, managed by RTS:
        CALL    REST_I_V                        ; only Interrupt Vectors

        ; Call the debugger in any case. It will take an
        ; action according to status and presence or absence
        ; of a run-time debugger:
        CALL    DEBUGGER

TERMINATION:
        MOV     DS,     CS:RTS_DS
        mov     ax,word ptr cur_proc_addr + 2
        mov     ds,ax
        ; Prepare return:
        MOV     SS,word ptr CUR_PROCESS.PD_PROG_END+2
        MOV     SP,word ptr CUR_PROCESS.PD_PROG_END
        POP     BP      ; BP of Father Program

DUMMY_ISR:      ; we use the following IRET also for
                ; a dummy interrupt service routine

        IRET            ; from here we go either to Get_Old_Program
                        ; or to After_Resident


;------------------------------------------------------
; Some Utilities:
;------------------------------------------------------


;       public  COMP_STACK
COMP_STACK:
        ; Upon Entry:
        ; AX holds size of free memory (in paragraphs)
        ; BX holds (paragraph) start address of free memory
        ; Upon Exit:
        ; AX holds SP and BX holds SS
        ; Policy:
        ;   Set STACK to the end of memory. Check if
        ;   there is room for a minimal stack.
        CMP     AX,     1000H
        JBE     SMALL_MEM
        ; There is more than 64K of free memory:
        SUB     AX,     1000H
        ADD     BX,     AX
                        ; Set SS to end of memory - 64K
        MOV     AX,     0
                        ; and SP to 0
        RET
SMALL_MEM:
        ; Less than 64K of free memory
        ; SS is start of free memory
        MOV     CL,     4
        SHL     AX,     CL
                ; SP is length * 16
        CMP     AX,     SP_INI_SIZE + SP_RESERVE + 4
                ; 4 is for the call of the Modula program
        JAE     LARGE_ENOUGH
        JMP     STACK_OVF
                ; Not enough for initial stack and
                ; for some reserve!
LARGE_ENOUGH:
        RET




;       public  WRITE

WRITE:
; The character to be printed is in DL
        MOV     AH,     2       ; Console Output
        INT     OS
        RET

;       public  WRITE_MSG

WRITE_MSG:
; The address of the message is in CS:DX
        MOV     AH,     9       ; Print String
        INT     OS
        RET

;       public  WRITE_LN

WRITE_LN:
        MOV     DL,     0DH     ; Print CR
        CALL WRITE
        MOV     DL,     0AH     ; Print LF
        CALL WRITE
        RET

;       public  WRITE_STATUS

WRITE_STATUS:
        ; prints on the screen the meaning of a
        ; program status (passed in BL):
        push    bx
        MOV     DL, ' '
        CALL    WRITE
        pop     bx
        xor     bh,bh
        ADD     BX, BX
        MOV     DX, STATUS_MSG [BX]
        CALL    WRITE_MSG
        RET


;       public  NORM_ADDR
        
NORM_ADDR:
        ; To normalize a address with segment and offset,
        ; i.e the segment value is as large as possible
        ; and the offset is smaller than 16.
        ; Upon entry:
        ;  BX holds the old segment and AX the old offset.
        ; Upon exit:
        ;  BX holds the normalized segment and AX the offset.
        ;  If an overflow occurs, the 'CF' flag is set.
        MOV     DX,     AX
        AND     AX,     0FH
        MOV     CL,     4
        SHR     DX,     CL
        ADD     BX,     DX
        RET


;       public  GET_CURR_DISK

GET_CURR_DISK:
        ; gets the currently logged in disk and stores
        ; the value in the variable 'SAVED_DISK'
        mov     ah,     25
        int     OS
        mov     SAVED_DISK,     al
        ret

;       public  SELECT_DISK

SELECT_DISK:
; the drive to be selected is passed in DL
        mov     ah,     14
        int     OS
        ret


code ends

;*****************************************************************************




        end RTS_START   ; defines startaddress of the RTS
