;******************************************************************************
;
;       MODULA-2    Run-Time Support   ( RTS )
;
;       In case of stand-alone target systems (without DOS) this
;       program is called "Target Run-Time Support" (TRTS).
;
;              LOGITECH SA,   CH-1122 Romanel    (Switzerland)
;              LOGITECH Inc,  Fremont, CA 94555  (USA)
;
;       Module  :    RTSMain, main module of the (Target) Run-Time Support   
;
;       Release :    3.10a - October 89
;
;       Copyright (C)  1987 - 1989 Logitech, All rights reserved
;
;       Permission is hereby granted to registered users to use or abstract
;       the following program in the implementation of customized versions.
;       This permission does not include the right to redistribute the source
;       code of this program.
;
;       History:
;          Jul-87:      Original version
;       02-May-88/akg:  NOP instruction at $BM__RTSMain removed.
;                       Store entry point for termination after pointer
;                       to debugger record at Modula_entry.
;                       Stack statistic in StackCheck corrected.
;                       Save/Restore/SetHVector become NEAR procedures.
;       05-May-88/akg:  Save interrupt controller mask, initialize device
;                       mask and current process descriptor at the very
;                       beginning. DD_PRIO_MASK must be set equal to
;                       PD_PRIO_MASK in procedure L__Execute__RTSMain.
;                       Use NIL value constants, use M2TRUE.
;       06-May-88/akg:  Use RTSINTCO.INC instead of MACRO.RTS.
;       18-May-88/akg:  Modifications for Target Run-Time Support (TRTS).
;       07-Jul-88/akg:  Declaration of interrupt descriptor table moved
;                       from module RTSInterrupt (necessary for overlays!).
;       14-Sep-88/akg:  NOP instruction at $BM__RTSMain re-introduced.
;       23-Sep-88/akg:  Unnecessary PUBLIC ATco87Vector removed, nested
;                       IFs indented, comment after some ENDIFs added.
;       25-Nov-88/akg:  WriteStatus displays complete error message.
;       20-Dec-88/akg:  ENDMacro defined and definition of segments "Stack"
;                       and "FREE" moved in front of CODE segment to allow
;                       assembling with MASM 5.10.
;       25-Apr-89/akg:  Correct addresses of labels "$ED..." and "$EM...".
;       23-May-89/akg:  Preserve value of interrupt flag: use PUSHF/CLI
;                       followed by POPF instead of CLI followed by STI.
;       22-Jun-89/akg:  Correct ENDMacro.
;       04-Jul-89/akg:  Some labels renamed conformant to usual rules (i.e.
;                       with terminating "__RTSMain"): "StackOvf_RTSMain",
;                       "Error_RTS", "DescInt0", "freeList", "priorityMasks".
;       20-Oct-89/akg:  Change name of stack segment from "Stack" to "STACK",
;                       and other changes for better C compatibility.
;
;******************************************************************************
               TITLE RTSMain


               INCLUDE  CONFIG.RTS

;============= Imports
; 20-Oct-89/akg
IF MCRTS OR CMRTS
               EXTRN   __astart    : FAR
ENDIF
IF M2RTS OR MCRTS
               EXTRN   StartModula : FAR
               EXTRN   $DD         : BYTE
ENDIF
IF   MCRTS
               EXTRN   __psp       : WORD
ENDIF

;============= End macro

; 20-Oct-89/akg: Always define entry of program to in this module, even
;                in the case of MCRTS. This allows to use the Modula-2
;                Run-Time Debugger also for debugging such programs,
;                provided that the entry point in this module is the
;                first entry point encountered by the linker.
; 
;IF MCRTS                ; MCRTS: no do not define entry point
;ENDMacro        MACRO
;                END
;                ENDM
;ELSE                    ; M2RTS OR CMRTS: define entry point
ENDMacro        MACRO
                END     Modula_entry
                ENDM
;ENDIF

               PUBLIC  KEY__00xxx00_0000_OF_RTSMain
               PUBLIC  KEY__12aug87_1620_OF_RTSMain
KEY__12aug87_1620_OF_RTSMain EQU 0
KEY__00xxx00_0000_OF_RTSMain EQU 0
               PUBLIC  $OK__19aug87_1403_OF_RTSMain

;============= Exported procedures

               PUBLIC  $INIT__RTSMain
               PUBLIC  $BODY__RTSMain
               PUBLIC  $BM__RTSMain, $EM__RTSMain
               PUBLIC  $BD__RTSMain, $ED__RTSMain
               PUBLIC  StackCheck__RTSMain
               PUBLIC  StackOvf__RTSMain
               PUBLIC  M2Halt__RTSMain
               PUBLIC  L__GetMessage__RTSMain
               PUBLIC  L__Terminate__RTSMain
               PUBLIC  L__InstallTermProc__RTSMain
               PUBLIC  L__CallTermProc__RTSMain
               PUBLIC  L__InstallInitProc__RTSMain
               PUBLIC  L__CallInitProc__RTSMain
               PUBLIC  L__Execute__RTSMain

;============= Exported variables

               PUBLIC  PSPAddress__RTSMain
               PUBLIC  activProcess__RTSMain
               PUBLIC  curProcess__RTSMain
               PUBLIC  blockList__RTSMain
               PUBLIC  deviceMask__RTSMain
               PUBLIC  errorCode__RTSMain
               PUBLIC  debuggerRecord__RTSMain
               PUBLIC  overlayList__RTSMain
               PUBLIC  overlayInitProc__RTSMain  ; PROC variable
               PUBLIC  overlayTermProc__RTSMain  ; PROC variable
               PUBLIC  dyingOverlay__RTSMain
IF MCRTS
               PUBLIC  _main
ENDIF

IF CMRTS
; 20-Oct-89/akg
; Exporting $DD is not absolutely necessary, but usefull for
; low level debugging.
               PUBLIC  $DD
ENDIF

;============= Exported misc for rts modules
               
               PUBLIC  Error__RTSMain
IF RUN_ON_PC
               PUBLIC  oldNMIvector
; 22-Sep-88/akg: Unnecessary PUBLIC ATco87Vector removed.
ENDIF
IF NOT ISTRTS
               PUBLIC  programSize
ENDIF
               PUBLIC  DescInt0__RTSMain
               PUBLIC  freeList__RTSMain
               PUBLIC  priorityMasks__RTSMain

;============= Constants definitions

               INCLUDE  RTS.INC
               INCLUDE  RTSOvls.INC
               INCLUDE  RTSIntDe.INC

;============= Interrupt controller handling

               INCLUDE  RTSINTCO.INC


MODULE_TABLE_DATA SEGMENT WORD PUBLIC 'FAR_DATA'
IF M2RTS OR MCRTS
$OK__19aug87_1403_OF_RTSMain  DW 0AF13H,34BH,0
ELSE ; assume CMRTS
$DD        LABEL FAR
; definition of the Overlay Descriptor of main program
$OK__19aug87_1403_OF_RTSMain  DW 0AF13H,34BH,0
           DB "_main"
           DB  35  DUP(0)
           DW  PD_CHECK_VALUE
           DB  (DRIVER_DESCR_SIZE - DD_MEMORY_ADDR) DUP (0)
ENDIF
MODULE_TABLE_DATA ENDS


RTSMain_DATA         SEGMENT WORD PUBLIC 'FAR_DATA'
                     ASSUME  CS : RTSMain_TEXT
$BD__RTSMain          LABEL   FAR

errorCode__RTSMain        DW      0           ; return status for DOS
PSPAddress__RTSMain       DD      NIL_ADDRESS ; DS passed to .EXE by DOS
blockList__RTSMain        DD      NIL_ADDRESS ; allocated blocks pointer is NIL
overlayList__RTSMain      DD      $DD
overlayInitProc__RTSMain  DD      RTSMain_TEXT:NormalInitProc_RTSMain
overlayTermProc__RTSMain  DD      RTSMain_TEXT:NormalTermProc_RTSMain

curProcess__RTSMain       DD      RTSMain_DATA:activProcess__RTSMain
                                              ; Address of pointer to current
                                              ; ProcessDescriptor
activProcess__RTSMain     DD      NIL_ADDRESS ; pointer to current ProcessDescriptor
debuggerRecord__RTSMain   LABEL   WORD
debuggerID           DW      PD_CHECK_VALUE         ; debugger ID
debuggerTable        DD      RTSMain_TEXT:RTDDummy  ; before init code
                     DD      RTSMain_TEXT:RTDDummy  ; before prog body
                     DD      RTSMain_TEXT:RTDDummy  ; after prog body end
                     DD      RTSMain_TEXT:RTDDummy  ; after term procedures

deviceMask__RTSMain   DW     ?            ; current device mask
dyingOverlay__RTSMain DD     NIL_ADDRESS  ; overlay that calls CallTermProc

IF   CMRTS
entryPoint           DD      __astart

TopStackSize         EQU     4
saveTopStack         DW      TopStackSize DUP (?)
ELSE
entryPoint           DD      StartModula
ENDIF

IF NOT ISTRTS
programSize          DW      0
ENDIF

IF RUN_ON_PC
oldMask              DW      ?           ; used to save the DOS interrupt mask
criticalSection      DD      ?           ; ptr to critical section flag of DOS
ENDIF

; This ARRAY holds for every priority level the priority mask, which has to
; become effective during execution of a priority module. The values in this
; mask may be modified, to implement any desired priority schema. Priority 0
; corresponds to the first element in this array, priority 7 to the last.
; NO priority corresponds to a mask with all bits zero

priorityMasks__RTSMain  DB   80H,0C0H,0E0H,0F0H,0F8H,0FCH,0FEH,0FFH

; 07-Jul-88/akg: Declaration of int. descr. table moved from RTSInterrupt.ASM.
; Interrupt descriptor table used by IOTRANSFER (see module RTSInterrupt):
DescInt0__RTSMain    DB     ID_LENGTH DUP (?)
DescInt1             DB     ID_LENGTH DUP (?)
DescInt2             DB     ID_LENGTH DUP (?)
DescInt3             DB     ID_LENGTH DUP (?)
DescInt4             DB     ID_LENGTH DUP (?)
DescInt5             DB     ID_LENGTH DUP (?)
DescInt6             DB     ID_LENGTH DUP (?)
DescInt7             DB     ID_LENGTH DUP (?)

DescInt8             DB     ID_LENGTH DUP (?)
DescInt9             DB     ID_LENGTH DUP (?)
DescInt10            DB     ID_LENGTH DUP (?)
DescInt11            DB     ID_LENGTH DUP (?)
DescInt12            DB     ID_LENGTH DUP (?)
DescInt13            DB     ID_LENGTH DUP (?)
DescInt14            DB     ID_LENGTH DUP (?)
DescInt15            DB     ID_LENGTH DUP (?)

freeList__RTSMain    DW     ?           ; This label shall always follow
                                        ; the interrupt descriptor table
RTSMain_DATA         ENDS


; 20-Oct-89/akg: Segment name changed from "Stack" to "STACK".
;                This makes the M2L linker combine this segment with
;                the C stack (in the DGROUP) when linking in C code.
;
STACK            SEGMENT PARA STACK 'STACK'
                 DB  DefaultStackSize  DUP (?)
STACK            ENDS

; 20-Oct-89/akg
IF MCRTS OR CMRTS
; Define DGROUP and include STACK segment into it:
DGROUP           GROUP   STACK
ENDIF

; 20-Oct-89/akg
IF M2RTS AND NOT ISTRTS
FREE             SEGMENT PARA PUBLIC 'FREE_BSS'
FREE             ENDS
ENDIF


RTSMain_TEXT   SEGMENT BYTE PUBLIC 'CODE'
               ASSUME  CS : RTSMain_TEXT
$BM__RTSMain:
; 14-Sep-88/akg: "Unnecessary" NOP instruction re-introduced, comment added.
; The sole purpose of the following NOP is to force the address of
; the public procedure L__InstallTermProc__RTSMain (declared in the
; include file RTSMainT.ASI) to be larger than the address of the above
; label $BM__RTSMain! If these symbols had the same address, the linker
; could place the L__InstallTermProc__RTSMain before $BM__RTSMain into
; the symbol list of the map file (the one ordered according to symbol
; addresses). This would have the effect, that the Modula-2 debuggers
; could not find all procedures exported from RTSMain and would refuse
; the REF file supplied for RTSMain. This applies to all debugger
; versions older than Sep-88.
               NOP
RTSMain_TEXT   ENDS


               INCLUDE RTSMainT.ASI        ; term and init procedures
               INCLUDE RTSMainM.ASI        ; error messages and display rout.


RTSMain_TEXT   SEGMENT BYTE PUBLIC 'CODE'
               ASSUME  CS : RTSMain_TEXT

;==========================================================================
Modula_entry  PROC  FAR

;==========================================================================
IF ISTRTS
; This is the point where the TMON will start the execution.
; In case of RUN_ON_PC, it will pass a pointer to the MS-DOS PSP
; in ES (TMON under MS-DOS/RUN_ON_PC must take care of passing it).
; The TMON will pass in BX:DI a pointer to the layer header of the
; top layer of the Modula-2 program. For future reference by the
; Modula-2 program (modules "Storage" and "Layers") this value is stored
; in the field "memoryAddr" of the overlay descriptor of the base layer.
; The field "memorySize" will be set to zero: For programs developped
; by means of the ROM tools (and located by means of XLOC) it is
; not possible to compute a reasonable value for the program size,
; because the modules of a layer do not need to be contiguous in
; memory. In this respect, the TMON and the TRTS are not well suited
; to run on a PC under MS-DOS, because they do not release any memory
; to DOS. In a target system without DOS, this is anyway not needed.
; For programs located by means of XLOC the value of field "codeSegment"
; in the overlay descriptor (of any layer) must be set to zero, in order
; to allow the debuggers to work properly with the map (M86) produced
; by XLOC.
ELSE ; NOT ISTRTS
; This is the point where DOS will start the execution.
; We shall save the PSP segment because we cannot assume that the init code
; generated by compiler will not destroy DS before getting into the init
; code of RTSMain.
ENDIF ; NOT ISTRTS
              ASSUME DS: RTSMain_DATA

              JMP   SHORT Start

              ORG   Modula_entry + 2

; M.P. 3/4/87
              DD    RTSMain_DATA:debuggerRecord__RTSMain

; 02-May-88/akg
              ; The following address may be used to terminate
              ; the program properly. First the registers must
              ; be saved onto the stack and the process descriptor
              ; must be updated. Then a jump to the address stored
              ; below may be used to terminate the program (i.e.
              ; the current overlay level). This way of terminating
              ; will also include the execution of the termination
              ; procedures installed. In particular, this way of
              ; terminating the program may be used by a debugger.
              DD    RTSMain_TEXT:Termination

IF ISTRTS
              ; The following two words specify the initial value
              ; for the stack pointer. The stack size (initial SP)
              ; will be adjusted by XLOC to reflect the true stack
              ; size of the program. SS:SP will be initialized to
              ; this value before the TMON passes control the entry
              ; point of the Modula-2 program.
              DW    DefaultStackSize
              DW    SEG Stack

              ; The following word allows the TMON to check whether
              ; this is really a good Target RTS:
              DW    PD_CHECK_VALUE 

Start:
; Parameters passed to application by TMON:
;   BX:DI    pointer to top layer header of the Modula-2 program
;   ES       pointer to MS-DOS PSP segment (in case of RUN_ON_PC only)

              MOV   AX, SEG RTSMain_DATA
              MOV   DS, AX

  IF RUN_ON_PC
             ; Save PSP pointer (passed by TMON in ES):
              MOV   WORD PTR PSPAddress__RTSMain, 0
              MOV   WORD PTR PSPAddress__RTSMain+2, ES
  ENDIF

ELSE ; NOT ISTRTS

Start:
  IF MCRTS
; 20-Oct-89/akg: Jump to C Run-Time support, which will in turn pass
;                control to the label "_main", which is now declared
;                right after the jump.
              JMP   __astart  ; initialize the C Run-Time Support

_main         LABEL FAR

;------------ C RTS is initialized, DS is at DGROUP, get the PSP segment

              MOV   AX, WORD PTR __psp
              MOV   ES, AX
; pointer to PSP segment is now in ES
  ELSE
; pointer to PSP segment is passed by MS-DOS in ES
  ENDIF

              MOV   AX, SEG RTSMain_DATA
              MOV   DS, AX
              MOV   WORD PTR PSPAddress__RTSMain, 0
              MOV   WORD PTR PSPAddress__RTSMain+2, ES
              MOV   DI, ES                     ; start of program space

  IF M2RTS
;------------ Free unused memory

              MOV   BX, SEG FREE               ; end of program space
              MOV   ES:[2], BX                 ; first free paragraph
              SUB   BX, DI                     ; size used by program
; M.P. 3/10/87
              MOV   programSize, BX
              MOV   AH, 4AH                    ; setblock
              INT   OS
  ELSE
; 20-Oct-89/akg
;------------ Compute program size
    IF MCRTS
; The C run-time support has already adjusted the memory used (DOS
; call 4AH "setblock"), and left the new value for the top of memory
; at offset 2 in the PSP.
              MOV   BX, ES:[2]                 ; first free paragraph
    ELSE ; assume CMRTS
; When including C code, the stack is in the DGROUP at the end of the
; program memory. In order to compute "programSize", we make the same
; computation as is done at the start of the C run-time support (label
; "__astart": DGROUP has a size of 64 K bytes (if possible), and is at
; the end of the memory occupied by the program. Note, however, that
; we leave it to the C run-time support to adjust the memory used (DOS
; call 4AH "setblock").
              MOV   BX, ES:[2]                 ; first free paragraph
              MOV   AX, SEG DGROUP
              SUB   BX, AX
              CMP   BX, 1000H                  ; 1000H paragraphs = 64 K bytes
              JB    SIZE_IN_BX
              MOV   BX, 1000H
SIZE_IN_BX:
              ADD   BX, AX                     ; end of program space
    ENDIF
              SUB   BX, DI                     ; size used by program
              MOV   programSize, BX
  ENDIF ; NOT M2RTS
ENDIF ; NOT ISTRTS

              MOV   BP, 0

; 05-May-88/akg
             ; Save the interrupt controller mask and initialize
             ; the Modula-2 device mask (deviceMask__RTSMain)

              GetInterruptMask                            ; might use DX and ES
              MOV   WORD PTR deviceMask__RTSMain, AX
IF RUN_ON_PC
              MOV   WORD PTR oldMask, AX
ENDIF

              XOR   AX, AX                                ; zero / NIL_SEGMENT
              MOV   CX, NIL_OFFSET

; 05-May-88/akg
             ; Initialize the pointer to the current process

              MOV   WORD PTR activProcess__RTSMain,   AX  ; zero
              MOV   WORD PTR activProcess__RTSMain+2, SS
              MOV   DX, SS
              MOV   DS, DX                                ; process descriptor

              ASSUME DS: NOTHING

              MOV   SI, OFFSET $DD                        ; $DD is the main
              MOV   DX, SEG    $DD                        ; driver descriptor

; 05-May-88/akg
             ; Initialize the main process descriptor

              MOV   WORD PTR DS:[PD_SP],            SP
              MOV   WORD PTR DS:[PD_SS],            SS
              MOV   WORD PTR DS:[PD_STATUS],        AX    ; normal
              MOV   WORD PTR DS:[PD_PRIO_MASK],     AX    ; no priority
              MOV   WORD PTR DS:[PD_PROG_LEVEL],    1
              MOV   WORD PTR DS:[PD_HEAP_DESC],     CX    ; NIL_OFFSET
              MOV   WORD PTR DS:[PD_HEAP_DESC+2],   AX    ; NIL_SEGMENT
              MOV   WORD PTR DS:[PD_ACTIV_OVL],     CX    ; NIL_OFFSET
              MOV   WORD PTR DS:[PD_ACTIV_OVL+2],   AX    ; NIL_SEGMENT
              MOV   WORD PTR DS:[PD_CHECK],         PD_CHECK_VALUE
              MOV   WORD PTR DS:[PD_BOT_STACK],     SP
              MOV   WORD PTR DS:[PD_CURR_OVL],      SI    ; OFFSET $DD
              MOV   WORD PTR DS:[PD_CURR_OVL+2],    DX    ; SEG    $DD
              MOV   WORD PTR DS:[PD_INT_DESC],      AX    ; not installed
              MOV   WORD PTR DS:[PD_PROCESSLIST],   CX    ; NIL_OFFSET
              MOV   WORD PTR DS:[PD_PROCESSLIST+2], AX    ; NIL_SEGMENT

              MOV   DS, DX                                ; SEG    $DD

IF ISTRTS
; Register contents at this point:
;   DS:SI    pointer to main driver descriptor $DD
;   AX       zero / NIL_SEGMENT
;   CX       NIL_OFFSET
;   BX:DI    pointer to top layer header of the Modula-2 program

             ; Initialize the main driver descriptor

              MOV   WORD PTR [SI+DD_CHECKWORD],     PD_CHECK_VALUE
              MOV   WORD PTR [SI+DD_MEMORY_ADDR],   DI  ; save pointer to layer
              MOV   WORD PTR [SI+DD_MEMORY_ADDR+2], BX  ; header of program
              MOV   WORD PTR [SI+DD_MEMORY_SIZE],   AX  ; zero
              MOV   WORD PTR [SI+DD_CODE_SEGMENT],  AX  ; zero, for PMD/XRTD!
ELSE ; NOT ISTRTS
; 05-May-88/akg
; Register contents at this point:
;   DS:SI    pointer to main driver descriptor $DD
;   AX       zero / NIL_SEGMENT
;   CX       NIL_OFFSET
;   DI       pointer to PSP segment
;   BX       size used by program

             ; Initialize the main driver descriptor

              MOV   WORD PTR [SI+DD_CHECKWORD],     PD_CHECK_VALUE
              MOV   WORD PTR [SI+DD_MEMORY_ADDR],   AX  ; zero
              MOV   WORD PTR [SI+DD_MEMORY_ADDR+2], DI  ; PSP segment
              MOV   WORD PTR [SI+DD_MEMORY_SIZE],   BX  ; size used by program
              ADD   DI, 10H                             ; add size of PSP
              MOV   WORD PTR [SI+DD_CODE_SEGMENT],  DI  ; just after PSP
ENDIF ; NOT ISTRTS
              MOV   WORD PTR [SI+DD_PROG_ID],       AX  ; zero
              MOV   WORD PTR [SI+DD_TERM_PROC],     CX  ; NIL_OFFSET
              MOV   WORD PTR [SI+DD_TERM_PROC+2],   AX  ; NIL_SEGMENT
              MOV   WORD PTR [SI+DD_INIT_PROC],     CX  ; NIL_OFFSET
              MOV   WORD PTR [SI+DD_INIT_PROC+2],   AX  ; NIL_SEGMENT
              MOV   WORD PTR [SI+DD_FREE_LIST],     OFFSET ProcTable
              MOV   WORD PTR [SI+DD_FREE_LIST+2],   SEG    ProcTable
              MOV   WORD PTR [SI+DD_NEXT],          SI
              MOV   WORD PTR [SI+DD_NEXT+2],        DS
              MOV   WORD PTR [SI+DD_PREVIOUS],      SI
              MOV   WORD PTR [SI+DD_PREVIOUS+2],    DS
              MOV   WORD PTR [SI+DD_OVERLAY],       1
              MOV   WORD PTR [SI+DD_FATHER],        CX  ; NIL_OFFSET
              MOV   WORD PTR [SI+DD_FATHER+2],      AX  ; NIL_SEGMENT
              MOV   WORD PTR [SI+DD_PARENT],        CX  ; NIL_OFFSET
              MOV   WORD PTR [SI+DD_PARENT+2],      AX  ; NIL_SEGMENT
              MOV   WORD PTR [SI+DD_PROCESS_LIST],  CX  ; NIL_OFFSET
              MOV   WORD PTR [SI+DD_PROCESS_LIST+2],AX  ; NIL_SEGMENT

; 05-May-88/akg
              MOV   AX, SEG RTSMain_DATA
              MOV   ES, AX
              MOV   DI, OFFSET entryPoint

              CALL  FAR PTR L__Execute__RTSMain

              MOV   AX, RTSMain_DATA
              MOV   DS, AX
              ASSUME DS : RTSMain_DATA

IF RUN_ON_PC
             ; Restore initial interrupt mask

              MOV   AX, oldMask
              SetInterruptMask DSset                     ; might use DX and ES

              MOV   BX, SEG $DD
              MOV   ES, BX
              MOV   BX, OFFSET $DD
              MOV   BX, WORD PTR ES:[BX+DD_OVL_STATUS]
              TEST  BX, BX
              JE    NoMessage
              MOV   BYTE PTR errorCode__RTSMain, 1       ; DOS return warned
              CMP   BX, FATAL_CODE
              JB    DispMessage
              MOV   BYTE PTR errorCode__RTSMain, 2       ; all other are fatal
DispMessage:
;25-Nov-88/akg
              CALL  SHORT WriteStatus
NoMessage:
ENDIF ; RUN_ON_PC
             ; Restore hardware interrupt vectors

; 23-May-89/akg
              PUSHF
              CLI
              CALL  RestoreHVector
              POPF

IF ISTRTS
  IF RUN_ON_PC
             ; Check whether program was started from the TMON

              TEST  WORD PTR debuggerRecord__RTSMain, 0FFFFH
              JE    BackToTMON

             ; Return to MS-DOS

              MOV   AH, 4CH
              MOV   AL, BYTE PTR errorCode__RTSMain
              INT   OS
  ENDIF

BackToTMON:
             ; Return to the Target Monitor (TMON)

              RET
ELSE ; NOT ISTRTS
;             ; Check whether program was started from the RTD
;
;              TEST  WORD PTR debuggerRecord__RTSMain, 0FFFFH
;              JNE    BackToRTD

             ; Return to MS-DOS

              MOV   AH, 4CH
              MOV   AL, BYTE PTR errorCode__RTSMain
              INT   OS

;BackToRTD:
;             ; Return to RTD
;
;              RET
ENDIF ; NOT ISTRTS

Modula_entry   ENDP


RTSMain_TEXT   ENDS

RTSMain_TEXT   SEGMENT BYTE PUBLIC 'CODE'
               ASSUME  CS : RTSMain_TEXT


;---------------------------------------------------------------------------
L__Execute__RTSMain    PROC FAR
;---------------------------------------------------------------------------
; Executes the main program or an overlay. On entry, ES:DI point to a
; DWORD containing the entry point of the program to execute.
;

              POP   AX
              POP   BX
              PUSHF                   ; save interrupt flag
              PUSH  BX
              PUSH  AX                ; return address

            ; reserve space for locale variables

              PUSH  BP
              MOV   BP, SP

; 20-Oct-89/akg
IF CMRTS
              LES   DI, DWORD PTR ES:[DI]  ; load entry point
              PUSH  ES                     ; and save it in local variable
              PUSH  DI                     ; on stack
ELSE
              PUSH  ES                ; save pointer to variable giving
              PUSH  DI                ; entry point of program to execute
ENDIF

              ASSUME  DS : RTSMain_DATA

              MOV   AX, SEG RTSMain_DATA
              MOV   DS, AX

              LES   DI, activProcess__RTSMain     ; ES:DI = current process

              LDS   SI, ES:[DI+PD_CURR_OVL]       ; get addr. of curr. overlay

              ; save current process informations

              MOV   WORD PTR [SI+DD_SP], BP       ; SP is already modified!
              MOV   WORD PTR [SI+DD_SS], SS
              MOV   WORD PTR [SI+DD_BP], BP

; 05-May-88/akg
              MOV   AX, WORD PTR ES:[DI+PD_PRIO_MASK]
              MOV   WORD PTR [SI+DD_PRIO_MASK], AX
              MOV   WORD PTR [SI+DD_LOADER_PROCESS], DI
              MOV   WORD PTR [SI+DD_LOADER_PROCESS+2], ES

;------------ Call debugger procedure No 0

              PUSH  ES                            ; current process
              PUSH  DI
              PUSH  DS                            ; current overlay
              PUSH  SI
              MOV   AX, SEG RTSMain_DATA
              MOV   DS, AX
              CALL  DWORD PTR debuggerRecord__RTSMain+2

              MOV   AX, SEG RTSMain_DATA
              MOV   DS, AX
              CALL  L__CallInitProc__RTSMain

             ; Call debugger procedure No 1

              MOV   AX, SEG RTSMain_DATA
              MOV   DS, AX
              LES   SI, DWORD PTR activProcess__RTSMain
              PUSH  ES
              PUSH  SI
              LES   SI, DWORD PTR ES:[SI+PD_CURR_OVL]
              PUSH  ES
              PUSH  SI
              CALL  DWORD PTR debuggerRecord__RTSMain+6

; 20-Oct-89/akg
IF CMRTS
;------------ Init the Modula-2 RTSMain anyway

              CALL  FAR PTR $INIT__RTSMain

;------------ If "L__Execute__RTSMain" has been called from "Modula_entry"
;             then the following goes to "__astart". This will initialize
;             the C RTS, which in turn will call the C main program "_main".
;             In this case, DS and ES must be set to point to the PSP.
;             If "L__Execute__RTSMain" has been called to start an overlay,
;             then this setting of DS and ES will not hurt.

              ASSUME   DS:RTSMain_DATA

              MOV   AX, SEG RTSMain_DATA
              MOV   DS, AX

IF CMRTS
              LES   SI, DWORD PTR activProcess__RTSMain
              CMP   WORD PTR ES:[SI+PD_CURR_OVL], OFFSET $DD
              JNE   $$1
              CMP   WORD PTR ES:[SI+PD_CURR_OVL + 2], SEG $DD
              JNE   $$1
; When starting up the main overlay, the CALL following below goes to the
; C run-time support (__astart), which will also set up the stack. In fact,
; it will destroy the information on the current stack. Therefore, we save
; the current top of the Modula-2 stack as far as necessary.
              MOV   ES, AX
              MOV   DI, OFFSET saveTopStack
              PUSH  SS
              POP   DS
              MOV   SI, BP
              MOV   CX, TopStackSize
              CLD
              REP   MOVSW
              MOV   DS, AX
$$1:
ENDIF
              MOV   AX, WORD PTR PSPAddress__RTSMain+2
              MOV   DS, AX
              MOV   ES, AX

              CALL  DWORD PTR SS:[BP-4]  ; call Program module, entry point
                                         ; of program to execute is given
                                         ; by local variable on stack
ELSE
              POP   DI                   ; restore pointer to variable giving
              POP   ES                   ; entry point of program to execute

              CALL  DWORD PTR ES:[DI]    ; call Program module
ENDIF
;===========================================================================
;====================   termination of the program   =======================
;===========================================================================
; We come here after a normal termination of the program module by the RET
; from the call here before.
; Otherwise, we may arrive from Error__RTSMain that will save the process
; descriptor for the Debugger to allow the analyze of program state.

Termination   LABEL FAR

              MOV   AX, SEG RTSMain_DATA
              MOV   DS, AX

              ASSUME  DS : RTSMain_DATA

;------------ Call debugger procedure No 2 with current context

              LES   SI, DWORD PTR activProcess__RTSMain
              PUSH  ES
              PUSH  SI
              LES   SI, DWORD PTR ES:[SI+PD_CURR_OVL]
              PUSH  ES
              PUSH  SI
              CALL  DWORD PTR debuggerRecord__RTSMain+10


;------------- Restore the Modula-2 loader process & overlay descriptor
              
              MOV   AX, RTSMain_DATA
              MOV   DS, AX
              ASSUME   DS : RTSMain_DATA
              LES   DI, activProcess__RTSMain     ; dying process

              ASSUME   DS : NOTHING
              ASSUME   ES : NOTHING

              LDS   SI, ES:[DI+PD_CURR_OVL]       ; get addr. of curr. overlay


;------------ AR, 87.07.31  saves the ^dying overlay
              MOV      DX, DS
              MOV      CX, SI
              MOV      SI, SEG RTSMain_DATA
              MOV      DS, SI
              ASSUME   DS : RTSMain_DATA
              CMP      WORD PTR dyingOverlay__RTSMain, NIL_OFFSET
              JNE      $$2
              CMP      WORD PTR dyingOverlay__RTSMain+2, NIL_SEGMENT
              JNE      $$2

;------------ saves the dying overlay only once, it must stay until all
;------------ termination procedures have been executed with or without
;------------ error.

              MOV      WORD PTR dyingOverlay__RTSMain, CX
              MOV      WORD PTR dyingOverlay__RTSMain+2, DX

;------------ Restores always the context of the dyingOverlay, even if
;------------ termination procedures of another level have errors              
$$2:
              MOV      SI, WORD PTR dyingOverlay__RTSMain
              MOV      DS, WORD PTR dyingOverlay__RTSMain+2
              
              ASSUME    DS : NOTHING                            
;------------

              MOV   AX, ES:[DI+PD_STATUS]         ; dying process status
              MOV   WORD PTR [SI+DD_OVL_STATUS], AX
                                                  ; into the overlay status
;------------ Reset the Interrupt Controller mask

              MOV   AX, WORD PTR [SI+DD_PRIO_MASK]
              PUSH  DS
              PUSH  DX
              PUSH  CX
              MOV   DX, SEG RTSMain_DATA
              MOV   DS, DX
              SetInterruptMask  DSset             ; might use DX and ES
              POP   CX
              POP   DX
              POP   DS

;------------ Restore context (registers are not restored)

              MOV   BP, WORD PTR [SI+DD_BP]
              MOV   SS, WORD PTR [SI+DD_SS]
              MOV   SP, WORD PTR [SI+DD_SP]
              LES   DI, DWORD PTR [SI+DD_LOADER_PROCESS]

IF CMRTS
              MOV   AX, DS
ENDIF
              ASSUME  DS : RTSMain_DATA

              MOV   BX, SEG RTSMain_DATA
              MOV   DS, BX

              MOV   WORD PTR activProcess__RTSMain, DI
              MOV   WORD PTR activProcess__RTSMain+2, ES

;------------ AR, 87.07.31 sets the ^dying overlay in the PD

              MOV   ES:[DI+PD_ACTIV_OVL], CX      ; offset of ^dying overlay
              MOV   ES:[DI+PD_ACTIV_OVL+2], DX    ; segment of ^dying overlay

IF CMRTS
              CMP   SI, OFFSET $DD
              JNE   $$3
              CMP   AX, SEG $DD
              JNE   $$3
; Restore top of Modula-2 stack destroyed by C run-time support (__astart)
              MOV   SI, OFFSET saveTopStack
              PUSH  SS
              POP   ES
              MOV   DI, SP
              MOV   CX, TopStackSize
              CLD
              REP   MOVSW
$$3:
ENDIF

;------------ Execute the termination procedures

              CALL  L__CallTermProc__RTSMain

;------------ Termination is done, there is no more dyingOverlay

              MOV   AX, SEG RTSMain_DATA
              MOV   DS, AX
              ASSUME DS : RTSMain_DATA
              MOV   WORD PTR dyingOverlay__RTSMain, NIL_OFFSET
              MOV   WORD PTR dyingOverlay__RTSMain+2, NIL_SEGMENT

              ; Call the debugger (procedure No 3)

              LES   SI, DWORD PTR activProcess__RTSMain
              PUSH  ES
              PUSH  SI
              LES   SI, DWORD PTR ES:[SI+PD_CURR_OVL]
              PUSH  ES
              PUSH  SI
              CALL  DWORD PTR debuggerRecord__RTSMain+14

              POP   BP
              IRET
L__Execute__RTSMain    ENDP


;-----------------------------------------------------------
Error__RTSMain  PROC   FAR
;-----------------------------------------------------------
; We assume that we get here by a JUMP from an error routine
; that has saved Flags and AX on the stack and put the error
; in AX.
;
; We could have a problem if we arrive here from a non-modula
; stack. It would be better to restore a good stack before
; executing the Termination procedures that can use a lot of
; stack. But the only way is to override the main program stack
; and this must be done after the Dump is done or the RTD has
; got the hand to do its job.
;
; in :     AX      error number

                PUSH  CX
                PUSH  DX
                PUSH  BX
                PUSH  AX
                PUSH  BP

                ; exchange the Flags and the return address on stack

                MOV   BP, SP
                MOV   BX, 12[BP]     ; Flags
                MOV   CX, 14[BP]     ; IP
                MOV   DX, 16[BP]     ; CS
                MOV   16[BP], BX     ; Flags
                MOV   14[BP], DX     ; CS
                MOV   12[BP], CX     ; IP
ComError:
                PUSH  SI
                PUSH  DI
                PUSH  DS
                PUSH  ES

                ASSUME  DS : RTSMain_DATA

                MOV   BX, SEG RTSMain_DATA
                MOV   DS, BX
                LES   DI, activProcess__RTSMain   ; ES:DI = current process
                MOV   WORD PTR ES:[DI+PD_STATUS], AX
                MOV   WORD PTR ES:[DI+PD_SP], SP
                MOV   WORD PTR ES:[DI+PD_SS], SS
                JMP   Termination
Error__RTSMain  ENDP

;-----------------------------------------------------------
IError_RTS      PROC   FAR
;-----------------------------------------------------------
                PUSH  CX
                PUSH  DX
                PUSH  BX
                PUSH  AX
                PUSH  BP
                JMP   SHORT ComError
IError_RTS      ENDP

;-----------------------------------------------------------
StackCheck__RTSMain   PROC   FAR
;-----------------------------------------------------------
;
; in :     BX      stack clearance requested, in bytes

        ADD     BX, SP_RESERVE                 ; BX is space required on stack
        CMP     BX, SP
        JA      STACK_BOO                      ;    oops, wrap thru 0

        ; if stack grows towards 0 then it is good now

IF    StackStatistic
; 02-May-88/akg
        MOV     AX, SEG RTSMain_DATA
        MOV     DS, AX
        LDS     SI, activProcess__RTSMain
        MOV     CX, DS
        MOV     AX, SS
        CMP     AX, CX
        JNE     SP_OK                  ; non Modula-2 stack, no statistic!
        MOV     AX, SP
        SUB     AX, BX                 ; AX := SP - space required on stack
        CMP     AX, WORD PTR [SI + PD_BOT_STACK]
        JA      SP_OK
        MOV     WORD PTR [SI + PD_BOT_STACK], AX
ENDIF
SP_OK:
        RET

STACK_BOO:
;;        JMP     StackOvf__RTSMain
StackCheck__RTSMain ENDP

;-----------------------------------------------------------
StackOvf__RTSMain    PROC    FAR
;-----------------------------------------------------------
;
        PUSHF
        PUSH    AX
        MOV     AX, STACK_OVF_CODE
        JMP     SHORT Error__RTSMain
StackOvf__RTSMain    ENDP


;-----------------------------------------------------------
M2Halt__RTSMain      PROC    FAR
;-----------------------------------------------------------
;
        PUSHF
        PUSH    AX
        MOV     AX, HALT_CODE
        JMP     SHORT Error__RTSMain
M2Halt__RTSMain      ENDP


;-----------------------------------------------------------
L__Terminate__RTSMain   PROC  FAR
;-----------------------------------------------------------
; here we come in case of System.Terminate
;
; on stack : status as normal modula-2 parameter

        PUSH    BP
        MOV     BP, SP
        PUSHF
        PUSH    CS
        PUSH    AX
        PUSH    AX                         ; save register used
        MOV     AX, OFFSET $
        MOV     [BP-6], AX                 ; IP into this code
        MOV     AX, [BP+6]                 ; get status value
        XOR     AH, AH
        JMP     SHORT IError_RTS
L__Terminate__RTSMain   ENDP


;-----------------------------------------------------------
RTDDummy     PROC  FAR
;-----------------------------------------------------------
;
; dummy call to debugger

             RET   8
RTDDummy     ENDP


RTSMain_TEXT   ENDS


             INCLUDE RTSMainI.ASI        ; hardware interrupts


RTSMain_TEXT   SEGMENT BYTE PUBLIC 'CODE'

               ASSUME  CS : RTSMain_TEXT
               ASSUME  DS : INIT_FLAG_DATA

$INIT__RTSMain   PROC  FAR

               MOV   AX, SEG INIT_FLAG_DATA
               MOV   DS, AX
               MOV   AL, M2TRUE                     ; TRUE
               XCHG  AL, BYTE PTR $FLAG__RTSMain
               OR    AL, AL                         ; is it FALSE or TRUE ?
               JE    M_RTSMain0
               JMP   NEAR PTR End_init              ; skip if TRUE
M_RTSMain0:
$BODY__RTSMain   LABEL FAR
               ASSUME   DS : RTSMain_DATA

               MOV   AX, SEG RTSMain_DATA
               MOV   DS, AX

; 05-May-88/akg
               ; It is better to save the interrupt controller mask
               ; and to set up the current process and its descriptor
               ; at the very beginning of RTSMain!

               ; reset error code

               XOR   AL, AL
               MOV   BYTE PTR errorCode__RTSMain, AL     ; still no error

IF RUN_ON_PC
               ; get the critical section flag address

               MOV   AH, 34H
               INT   OS
               MOV   WORD PTR criticalSection, BX
               MOV   WORD PTR criticalSection+2, ES
ENDIF

               ; save hardware interrupt vectors 0, 2, 23H, 1BH, and 75H

               CALL  SaveHVector

IF RUN_ON_PC
               ; set up ^C and BREAK interrupts

               MOV   BX, SEG RTSMain_TEXT
               MOV   DX, OFFSET RTSMain_TEXT:Stopped_23
               MOV   AL, 23H
               CALL  SetHVector
               MOV   DX, OFFSET RTSMain_TEXT:BREAK
               MOV   AL, 1BH
               CALL  SetHVector
ENDIF

End_init:
               RET

$INIT__RTSMain   ENDP
$EM__RTSMain   EQU $-1               ; address of last code byte
RTSMain_TEXT   ENDS


RTSMain_DATA   SEGMENT WORD PUBLIC 'FAR_DATA'
$ED__RTSMain   EQU $-1               ; address of last data byte
RTSMain_DATA   ENDS

INIT_FLAG_DATA   SEGMENT WORD PUBLIC 'FAR_DATA'
$FLAG__RTSMain   DB      0           ; initialization flag of RTSMain
INIT_FLAG_DATA   ENDS


ENDMacro
