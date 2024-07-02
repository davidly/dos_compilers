;(**************************************************************************)
;(*                                                                        *)
;(*  MODULA-2    Library                                                   *)
;(*                                                                        *)
;(*           LOGITECH Inc,   Fremont,   CA 94555  (USA)                   *)
;(*                                                                        *)
;(*  Module  :                            				   *)
;(*    DebugPMD, creates a dump file upon error                            *)
;(*                                                                        *)
;(*    Release :    Dec 89                                                 *)
;(*                                                                        *)
;(*    Copyright (C)  1987, 1989 Logitech, All rights reserved             *)
;(*                                                                        *)
;(*    Permission is hereby granted to registered users to use or abstract *)
;(*    the following program in the implementation of customized versions. *)
;(*    This permission does not include the right to redistribute the      *)
;(*    source code of this program.                                        *)
;(*                                                                        *)
;(**************************************************************************)

               TITLE      DebugPMD

;============= Imports

RTSMain_DATA   SEGMENT WORD PUBLIC 'FAR_DATA'
               EXTRN      blockList__RTSMain      : DWORD
               EXTRN      debuggerRecord__RTSMain : DWORD
               EXTRN      overlayList__RTSMain     : DWORD
               EXTRN      activProcess__RTSMain   : DWORD
RTSMain_DATA   ENDS

               EXTRN L__InstallTermProc__RTSMain  : FAR

               EXTRN Transfer__RTSCoroutine      : FAR
               EXTRN NewProcess__RTSCoroutine    : FAR

               EXTRN $INIT__RTSMain              : FAR
               EXTRN $INIT__RTSCoroutine         : FAR

;============= Exported procedures

               PUBLIC     $INIT__DebugPMD

;============= Exported variables

               PUBLIC     KEY__00xxx00_0000_OF_DebugPMD
               PUBLIC     KEY__10aug87_2031_OF_DebugPMD
               PUBLIC     $OK__16jun87_2059_OF_DebugPMD

;============= Exported misc for rts modules

;============= Constants definitions

RUN_ON_PC = 1
               INCLUDE ..\RTS\RTS.INC
               INCLUDE ..\RTS\RTSOvlS.INC

KEY__00xxx00_0000_OF_DebugPMD EQU 0
KEY__10aug87_2031_OF_DebugPMD EQU 0

TimerIntVector EQU 1CH              ; timer interrupt vector

BWVideoSize    EQU 1000H            ; size of BW screen refresh memory
ColorVideoSize EQU 8000H            ; size of color screen refresh memory

ScreenBuffSize EQU 512

IntVectSize    EQU 0400H            ; size of int vector area

WspSize        EQU 0400H            ; size of dumper's workspace

; Storage block header

ST_nextBlockSeg EQU 0
ST_blockSize    EQU ST_nextBlockSeg+8

BIOSSegment    EQU 0040H
CrtTable       EQU 0049H

;============= Macro definitions

CrtTableStruc  STRUC

CrtMode        DB ?          ; Current Crt mode
CrtCols        DW ?          ; Number of columns on screen
CrtLength      DW ?          ; Length of regen in bytes
CrtStart       DW ?          ; Starting address in regen buffer
CrtCursorPos   DW 8 DUP(?)   ; Cursor position for each of up to 8 pages
CrtCursorMode  DW ?          ; Current cursor mode setting
CrtActivePage  DB ?          ; Current page being displayed
CrtAddr6845    DW ?          ; Base address of active display card
CrtModeSet     DB ?          ; Current setting of the 3x8 registers
CrtPallette    DB ?          ; Current pallette setting color card

CrtTableStruc  ENDS

MODULE_TABLE_DATA SEGMENT WORD PUBLIC 'FAR_DATA'
$OK__16jun87_2059_OF_DebugPMD  DW 0AED0H,4EBH,0
MODULE_TABLE_DATA ENDS


DebugPMD_DATA    SEGMENT WORD 'FAR_DATA'

;------------------------------------------------------------------------------
; PMD file header
;------------------------------------------------------------------------------

PMD_header      LABEL WORD

PMD_version     DW 0              ; PMD version
PMD_target      DW 0              ; target ID (0 for resident)
PMD_blkCount    DW 4              ; number of information blocks
PMD_progNamePos DW NamePos        ; potition of the program name
PMD_sysBlockPos DW SysBlockPos    ; position of the system information block
PMD_crtBlockPos DW CrtBlockPos    ; position of the CRT information block
PMD_tablePos    DW TablePos       ; position of the memory block table

PMD_progName    DB 40 DUP(0)      ; name of the crashed program (or overlay)

PMD_sysBlock   LABEL WORD
PMD_activProcess DD ?             ; address of current process's descriptor
PMD_overlayList   DD ?             ; driver & overlay list
PMD_blockList    DD ?             ; list of the blocks allocated by 'Storage'

PMD_crtBlock   DW 17 DUP(?)

PMD_table      LABEL WORD

PMD_blockCount DW ?               ; number of mem. blocks used by the prog.
                                  ; at least 2 (int. vectors and screen)
PMD_firstBlkPos DD FirstEntryPos+2*EntrySize
PMD_firstEntry LABEL WORD

tableEntry     LABEL WORD
filePos        DD 0               ; offset from the beginning of the
                                  ; memory area
beginAddress   DD 0               ; address of first byte in the block
endAddress     DD IntVectSize     ; address after first byte after the block

EntrySize      EQU $-tableEntry

; position in the header of the program name
NamePos         EQU PMD_progName-PMD_header

; position in the header of the system information block
SysBlockPos     EQU PMD_sysBlock-PMD_header

; position in the header of the CRT information block
CrtBlockPos     EQU PMD_crtBlock-PMD_header

; position in the header of the memory block table
TablePos        EQU PMD_table-PMD_header

; position in the header of the memory block count
BlockCountPos   EQU TablePos

; position in the header of the first entry of the table
FirstEntryPos   EQU PMD_firstEntry-PMD_header

;------------------------------------------------------------------------------
; PMD variables
;------------------------------------------------------------------------------

fileHandle     DW ?               ; MS-DOS file handle
fileName       DB 13 DUP(?)       ; file name buffer
extension      DB '.PMD',0        ; extension of the PMD file

takeADump      DB 1
dumpMade       DB 0
               EVEN
dumpProcess    DD ?
savedIntVect   DD ?
savedDumpProc  DD ?

wsp            DB WspSize DUP(?)

               EVEN
screenBuff     DB ScreenBuffSize DUP(?)

curDriver      DD   ?                       ; current Driver Descriptor
pmdLevel       DW   ?                       ; program level of the dumper
activOverlay   DD   ?                       ; ^driverDescriptor of current
                                            ;  ... overlay at crash time

DebugPMD_DATA    ENDS

;------------------------------------------------------------------------------

DebugPMD_TEXT    SEGMENT BYTE 'CODE'

               ASSUME CS : DebugPMD_TEXT

;------------------------------------------------------------------------------

WriteTableEntry PROC NEAR

               ASSUME DS : DebugPMD_DATA

               LEA  DX, tableEntry
               MOV  CX, EntrySize
               MOV  BX, fileHandle
               MOV  AH, 40H               ; Write function code
               INT  OS
               RET

WriteTableEntry ENDP

ParaToByte  PROC NEAR
; on entry: AX     contains a paragraph offset
; on exit : DX:AX  contains the corresponding byte offset
;           CX     is lost

               MOV  DL, AH
               XOR  DH, DH
               MOV  CL, 4
               SHL  AX, CL
               SHR  DX, CL
               RET

ParaToByte  ENDP


WriteBlockTable PROC NEAR

               MOV  AX, SEG overlayList__RTSMain
               MOV  ES, AX

               ASSUME ES : RTSMain_DATA
               ASSUME DS : DebugPMD_DATA

             ; Write an entry for interrupt vectors
               MOV    WORD PTR beginAddress, 0
               MOV    WORD PTR beginAddress+2, 0
               MOV    WORD PTR endAddress, IntVectSize
               MOV    WORD PTR endAddress+2, 0
               CALL   WriteTableEntry
               JNC    $0
               JMP    NEAR PTR WriteBlockTableError
$0:
               MOV    WORD PTR filePos, IntVectSize

             ; Parse driver list
               LES  DI, activProcess__RTSMain
               LES  DI, ES:[DI+PD_CURR_OVL]     ; current Overlay
               MOV  WORD PTR curDriver, DI
               MOV  WORD PTR curDriver+2, ES

WriteBlockTable0:
               INC  PMD_blockCount
               ADD  WORD PTR PMD_firstBlkPos,   EntrySize
               ADC  WORD PTR PMD_firstBlkPos+2, 0

             ; store begin address
               MOV  AX, WORD PTR ES:[DI+DD_MEMORY_ADDR]
               MOV  WORD PTR beginAddress, AX
               MOV  WORD PTR endAddress,   AX
               MOV  AX, WORD PTR ES:[DI+DD_MEMORY_ADDR+2]
               MOV  WORD PTR beginAddress+2, AX
               MOV  WORD PTR endAddress+2,   AX

             ; update end address
               MOV  AX, WORD PTR ES:[DI+DD_MEMORY_SIZE]
               ADD  WORD PTR endAddress+2, AX

               CALL WriteTableEntry
               JNC  $1
               JMP  NEAR PTR WriteBlockTableError
$1:
               MOV  AX, WORD PTR ES:[DI+DD_MEMORY_SIZE]

               CALL ParaToByte                  ; DX,AX <= size in bytes

             ; update block position
               ADD  WORD PTR filePos,   AX
               ADC  WORD PTR filePos+2, DX

               LES  DI, DWORD PTR ES:[DI+DD_PREVIOUS]
               MOV  AX, ES
               CMP  AX, WORD PTR curDriver+2
               JNE  WriteBlockTable0
               CMP  DI, WORD PTR curDriver
               JNE  WriteBlockTable0


               MOV  AX, SEG blockList__RTSMain
               MOV  ES, AX

               ASSUME ES : RTSMain_DATA

             ; Parse block list
               LES  DI, blockList__RTSMain

WriteBlockTable1:
;               CMP  DI, 0FFFFH ; NIL offset
;               JNE  WriteBlockTable2
               MOV  AX, ES
               CMP  AX, 0      ; NIL segment
               JE   WriteBlockTable3

WriteBlockTable2:
               INC  PMD_blockCount
               ADD  WORD PTR PMD_firstBlkPos,   EntrySize
               ADC  WORD PTR PMD_firstBlkPos+2, 0

             ; store begin address
               MOV  WORD PTR beginAddress,   DI
               MOV  WORD PTR endAddress,     DI
               MOV  WORD PTR beginAddress+2, ES
               MOV  WORD PTR endAddress+2,   ES

             ; update end address
               MOV  AX, WORD PTR ES:[DI+ST_blockSize]
               ADD  WORD PTR endAddress+2, AX

               CALL WriteTableEntry
               JC   WriteBlockTableError

               MOV  AX, WORD PTR ES:[DI+ST_blockSize]

               CALL ParaToByte                  ; DX,AX <= size in bytes

             ; update block position
               ADD  WORD PTR filePos,   AX
               ADC  WORD PTR filePos+2, DX      ; file position of the block

               MOV  ES, WORD PTR ES:[DI+ST_nextBlockSeg]
               JMP  WriteBlockTable1

WriteBlockTable3:
             ; output a table entry for the display area

               MOV  AX, BIOSSegment
               MOV  ES, AX

               MOV  AX, 0B800H
               MOV  CX, ColorVideoSize
               CMP  ES:[CrtTable].CrtMode, 7        ; BW mode
               JNE  WriteBlockTable4
               MOV  AX, 0B000H
               MOV  CX, BWVideoSize

WriteBlockTable4:
               MOV  WORD PTR beginAddress,   0
               MOV  WORD PTR endAddress,     CX
               MOV  WORD PTR beginAddress+2, AX
               MOV  WORD PTR endAddress+2,   AX

               CALL WriteTableEntry
WriteBlockTableError:
               RET

WriteBlockTable ENDP

;------------------------------------------------------------------------------

WriteBlock     PROC NEAR

; in :    CX,AX  <= size in bytes
;         DS:DX  <= memory address

               MOV  SI, ES                     ; SI:DI <= memory address
               MOV  BX, DebugPMD_DATA
               MOV  ES, BX                     ; get fileHandle segment
               
               ASSUME ES : DebugPMD_DATA
               ASSUME DS : NOTHING

               MOV  BX, fileHandle             ; BX    <= fileHandle
               MOV  ES, SI                     ; ES:DI <= memory address

               SHL  CX, 1                      ; CX:0  <= CX:0 DIV 8000H 
               JCXZ WriteBlock1
               PUSH AX
WriteBlock0:
               MOV  SI, CX
               MOV  CX, 8000H

               ; BX    file handle
               ; CX    number of bytes to write
               ; DS:DX address of buffer to write

               MOV  AH, 40H               ; Write function code
               INT  OS
               JNC  $5
               CMP  AX, 0
               JE   WriteBlockError
$5:
               MOV  CX, SI

             ; increment segment
               MOV  SI, DS
               ADD  SI, 800H
               MOV  DS, SI

               LOOP WriteBlock0

               POP  AX
WriteBlock1:
               MOV  CX, AX
               MOV  AH, 40H               ; Write function code
               INT  OS
               JNC  WBNoError
               CMP  AX, 0                 ; disk full ?
               JNE  WBNoError
WriteBlockError:
               STC
               RET
WBNoError:
               CLC
               RET

WriteBlock     ENDP

WriteScreenBlock PROC NEAR

               ASSUME ES : DebugPMD_DATA
               ASSUME DS : NOTHING

               PUSH CX
               LEA  DI, screenBuff

               PUSH DS
               MOV  AX, BIOSSegment
               MOV  DS, AX

               MOV  DX, DS:[CrtTable].CrtAddr6845
               ADD  DX, 6;  status register
               POP  DS
WriteScreenBlock0:
               CLI
WriteScreenBlock1:
               IN   AL, DX
               AND  AL, 1
               JNZ  WriteScreenBlock1
WriteScreenBlock2:
               IN   AL, DX
               AND  AL, 1
               JZ   WriteScreenBlock2
               MOVSB
               STI
               LOOP WriteScreenBlock0

               POP  CX
               PUSH DS
               MOV  AX, ES
               MOV  DS, AX
               LEA  DX, screenBuff
               MOV  BX, fileHandle
               MOV  AH, 40H ; Write function code
               INT  OS
               POP  DS
               JC   WSBError
               CMP  AX, 0
               JNE  WSBNoError
WSBError:
               STC
               RET
WSBNoError:
               CLC
               RET
WriteScreenBlock ENDP

DumpScreen     PROC NEAR

               XOR  BH, BH
               MOV  DS, CX
               MOV  CX, DebugPMD_DATA
               MOV  ES, CX
               XOR  SI, SI

               MOV  CX, ScreenBuffSize
               MOV  DX, 0
               DIV  CX

               MOV  CX, AX
               PUSH DX
               JCXZ DumpScreen1

DumpScreen0:
               PUSH CX
               MOV  CX, ScreenBuffSize
               CALL WriteScreenBlock
               JC   DumpScreenError
               POP  CX
               LOOP DumpScreen0

DumpScreen1:
               POP  CX
               JCXZ DumpScreen2

               CALL WriteScreenBlock
DumpScreen2:
               RET
DumpScreenError:
               POP  CX
               POP  CX
               RET

DumpScreen     ENDP

DumpMemory     PROC NEAR

               MOV  AX, SEG overlayList__RTSMain
               MOV  ES, AX

               ASSUME ES : RTSMain_DATA
               ASSUME DS : NOTHING

             ; Write interrupt vector area
               XOR  DX, DX
               MOV  DS, DX                        ; DS:DX <= 0:0
               MOV  AX, IntVectSize
               MOV  CX, 0                         ; CX,AX <= size in bytes
               CALL WriteBlock
               JNC  $2
               JMP  DumpMemoryError
$2:

             ; Parse driver list

               MOV  AX, DebugPMD_DATA
               MOV  DS, AX
               ASSUME DS : DebugPMD_DATA

               LES  DI, activProcess__RTSMain
               LES  DI, ES:[DI+PD_CURR_OVL]     ; current Overlay
               MOV  WORD PTR curDriver, DI
               MOV  WORD PTR curDriver+2, ES

DumpMemory0:  
               MOV  AX, WORD PTR ES:[DI+DD_MEMORY_SIZE]

               CALL ParaToByte                  ; DX,AX <= size in bytes

               MOV  CX, DX
               LDS  DX, DWORD PTR ES:[DI+DD_MEMORY_ADDR]

               CALL WriteBlock
               JC   DumpMemoryError

               LES  DI, DWORD PTR ES:[DI+DD_PREVIOUS]

               
               MOV  AX, DebugPMD_DATA
               MOV  DS, AX
               ASSUME DS : DebugPMD_DATA

               MOV  AX, ES
               CMP  AX, WORD PTR curDriver+2
               JNE  DumpMemory0
               CMP  DI, WORD PTR curDriver
               JNE  DumpMemory0


               MOV  AX, SEG blockList__RTSMain
               MOV  ES, AX

               ASSUME ES : RTSMain_DATA

             ; Parse block list
               LES  DI, blockList__RTSMain

DumpMemory1:
               MOV  AX, ES                    ; AX <= ES     AR, le 13.4.87
;               CMP  DI, 0FFFFH                ; NIL offset
;               JNE  DumpMemory2
               CMP  AX, 0      ; NIL segment
               JE   DumpMemory3

DumpMemory2:
               MOV  DS, AX                      ; DS    <= ES
               MOV  AX, WORD PTR ES:[DI+ST_blockSize]
               CALL ParaToByte                  ; DX,AX <= size in bytes
               MOV  CX, DX                      ; CX,AX <= size in bytes
               MOV  DX, DI                      ; DS:DX <= memory address

               CALL WriteBlock
               JC   DumpMemoryError

               MOV  ES, WORD PTR ES:[DI+ST_nextBlockSeg]
               JMP  DumpMemory1

DumpMemory3:
             ; output a table entry for the display area

               MOV  AX, BIOSSegment
               MOV  ES, AX

               MOV  CX, 0B800H
               MOV  AX, ColorVideoSize
               MOV  BL, ES:[CrtTable].CrtMode
               CMP  BL, 3
               JBE  TextMode
               CMP  BL, 7            ; BW mode
               JNE  DumpMemory4
               MOV  CX, 0B000H
               MOV  AX, BWVideoSize
DumpMemory4:

               MOV  DS, CX
               MOV  DX, 0
               MOV  CX, 0

               CALL WriteBlock
               JC   DumpMemoryError

TextMode:
               CALL DumpScreen
DumpMemoryError:
               RET

DumpMemory     ENDP

;------------------------------------------------------------------------------

Dumper         PROC FAR

               CLI
               XOR  AX, AX
               MOV  DS, AX

             ; save the timer Int vector and set it to a dummy ISR
               MOV  DX, WORD PTR DS:[4*TimerIntVector]
               MOV  BX, WORD PTR DS:[4*TimerIntVector+2]

               MOV  WORD PTR DS:[4*TimerIntVector],   OFFSET DummyISR
               MOV  WORD PTR DS:[4*TimerIntVector+2], SEG    DummyISR
               STI

               MOV  AX, DebugPMD_DATA
               MOV  ES, AX

               ASSUME ES : DebugPMD_DATA
               ASSUME DS : NOTHING

               MOV  WORD PTR savedIntVect,   DX
               MOV  WORD PTR savedIntVect+2, BX

             ; Fill in the system information block

               MOV  AX, SEG blockList__RTSMain
               MOV  DS, AX

               ASSUME DS : RTSMain_DATA

             ; store block list

               MOV  WORD PTR ES:PMD_blockCount, 2    ; 2 blocks by default 
               MOV  WORD PTR ES:PMD_firstBlkPos, FirstEntryPos+2*EntrySize
               MOV  WORD PTR ES:PMD_firstBlkPos+2, 0
               MOV  WORD PTR ES:filePos, 0
               MOV  WORD PTR ES:filePos+2, 0
               MOV  AX, WORD PTR blockList__RTSMain
               MOV  WORD PTR PMD_blockList, AX
               MOV  AX, WORD PTR blockList__RTSMain+2
               MOV  WORD PTR PMD_blockList+2, AX

             ; store driver list

               MOV  AX, WORD PTR overlayList__RTSMain
               MOV  WORD PTR PMD_overlayList, AX
               MOV  AX, WORD PTR overlayList__RTSMain+2
               MOV  WORD PTR PMD_overlayList+2, AX

               MOV  AX, BIOSSegment
               MOV  DS, AX

             ; DS:SI point to the BIOS video parameter area
               MOV  SI, CrtTable

             ; ES:DI point to the CRT information block
               LEA  DI, PMD_crtBlock

               XOR  AH, AH

               LODSB
               STOSW                      ; align CrtMode

               MOV  CX, 12
               REP  MOVSW                 ; copy from CrtCols to CrtCursorMode

               LODSB
               STOSW                      ; align CrtActivPage

               MOVSW                      ; copy CrtAddr6845

               LODSB
               STOSW                      ; align CrtModeSet

               LODSB                      ; align CrtPallette
               STOSW


               MOV  AX, SEG DebugPMD_DATA
               MOV  DS, AX

               ASSUME DS : DebugPMD_DATA

;------------- Get current overlay ptr

               LDS  BX, DWORD PTR activOverlay

;------------- DS:SI points to the first character of the module name

               LEA  SI, [BX+DD_DRIVER_NAME]

;------------- Copy program name into the header

               LEA  DI, PMD_progName

               MOV  CX, DD_NameSize
Dumper0:
               LODSB
               TEST AL, AL
               JZ   Dumper1
               STOSB
               LOOP Dumper0

Dumper1:
             ; ES:DI points to the file name buffer
               LEA  DI, fileName

             ; DS:SI points to the first character of the module name
               LEA  SI, [BX+DD_DRIVER_NAME]

             ; Copy module name to file name buffer (max. 8 characters)
               MOV  CX, 8
Dumper2:
               LODSB
               TEST AL, AL
               JZ   Dumper3
               STOSB
               LOOP Dumper2

Dumper3:
               MOV  AX, DebugPMD_DATA
               MOV  DS, AX

               ASSUME DS : DebugPMD_DATA

             ; DS:SI point to the first character of extension
               LEA  SI, extension

             ; Copy the extension and the 0C
               MOV  CX, 5
               REP  MOVSB

             ; Try to create the PMD file
               LEA  DX, fileName
               MOV  CX, 0             ; Normal file (no protection)
               MOV  AH, 3CH           ; Create function code
               INT  OS
               JC   CreateFailure

             ; save the file handle returned by MS-DOS
               MOV  fileHandle, AX

             ; Write the header
               LEA  DX, PMD_header
               MOV  BX, AX
               MOV  CX, FirstEntryPos
               MOV  AH, 40H           ; Write function code
               INT  OS
               JC   WriteFailure

               CALL WriteBlockTable
               JC   WriteFailure

               CALL DumpMemory
               JC   WriteFailure
               
               MOV  AX, DebugPMD_DATA
               MOV  DS, AX

             ; fixup blockCount
               MOV  BX, fileHandle
               MOV  CX, 0
               MOV  DX, BlockCountPos
               MOV  AX, 4200H         ; Move file pointer function code
               INT  OS
               JC   WriteFailure

               LEA  DX, PMD_table
               MOV  CX, PMD_firstEntry-PMD_table
               MOV  AH, 40H           ; Write function code
               INT  OS
               JC   WriteFailure

               MOV  BX, fileHandle
               MOV  AH, 3EH           ; Close function code
               INT  OS
               JMP  SHORT ExitDumper

WriteFailure:
               MOV  BX, fileHandle
               MOV  AH, 3EH           ; Close function code
               INT  OS

               MOV  AX, DebugPMD_DATA
               MOV  DS, AX

               LEA  DX, fileName
               MOV  AH, 41H
               INT  OS
CreateFailure:
               MOV  AX, DebugPMD_DATA
               MOV  DS, AX

               MOV  DS, WORD PTR PMD_activProcess+2

               MOV  WORD PTR DS:[PD_STATUS], DUMP_FAILURE_CODE

ExitDumper:
               CLI
               MOV   AX, DebugPMD_DATA
               MOV   DS, AX

               ASSUME DS : DebugPMD_DATA

               MOV   DX, WORD PTR savedIntVect
               MOV   BX, WORD PTR savedIntVect+2

               XOR   SI, SI
               MOV   ES, SI

               MOV   WORD PTR ES:[4*TimerIntVector],   DX
               MOV   WORD PTR ES:[4*TimerIntVector+2], BX

               MOV   ES, AX
               MOV   dumpMade, 1
               LEA   SI, dumpProcess
               LEA   DI, PMD_activProcess
               CALL  Transfer__RTSCoroutine
               JMP   Dumper ; Loop

Dumper         ENDP

Dump           PROC FAR

               MOV  AX, SEG activProcess__RTSMain
               MOV  DS, AX
               ASSUME  DS : RTSMain_DATA
               MOV  DS, WORD PTR activProcess__RTSMain+2

               CMP  WORD PTR DS:[PD_STATUS], STOP_CODE
               JAE  DoIt
                                                         ; strip the param.
               RET  8

;-------------- Get current overlay
DoIt:        
               MOV  CX, WORD PTR DS:[PD_CURR_OVL]
               MOV  BX, WORD PTR DS:[PD_CURR_OVL+2]      ; current overlay
               PUSH CX
               PUSH BX

               PUSH CS
               POP  DS

               ASSUME  DS : DebugPMD_TEXT

               MOV  DX, OFFSET DebugPMD_TEXT:Message
               MOV  AH, 9
               INT  OS

               MOV  AX, DebugPMD_DATA
               MOV  DS, AX
               MOV  ES, AX
               ASSUME DS : DebugPMD_DATA

               POP  BX
               POP  CX
               MOV  WORD PTR activOverlay, CX
               MOV  WORD PTR activOverlay+2, BX   ; save the current overlay

               LEA  SI, PMD_activProcess
               LEA  DI, dumpProcess
               CALL Transfer__RTSCoroutine

               RET

Dump           ENDP

Message        DB  "Writing post mortem dump ...",0DH, 0AH, "$"


TermProc       PROC FAR

               MOV   AX, SEG activProcess__RTSMain
               MOV   DS, AX

               ASSUME DS : RTSMain_DATA

               MOV   DS, WORD PTR activProcess__RTSMain+2
               MOV   CX, WORD PTR DS:[PD_PROG_LEVEL]

               MOV   AX, DebugPMD_DATA
               MOV   DS, AX

               ASSUME DS : DebugPMD_DATA

               MOV   AX, WORD PTR pmdLevel
               CMP   AX, CX                      ; is it the right level ?
               JNE   NoDeinstall

               MOV   AX, SEG debuggerRecord__RTSMain
               MOV   ES, AX

               ASSUME ES : RTSMain_DATA

             ; restore old PMD procedure
               MOV   AX, WORD PTR savedDumpProc
               MOV   DX, WORD PTR savedDumpProc+2
               MOV   WORD PTR debuggerRecord__RTSMain+10, AX
               MOV   WORD PTR debuggerRecord__RTSMain+12, DX
NoDeinstall:
               RET
TermProc       ENDP

DummyISR       PROC FAR
               IRET
DummyISR       ENDP

DebugPMD_TEXT    ENDS


INIT_FLAG_DATA       SEGMENT WORD PUBLIC 'FAR_DATA'
$FLAG_DebugPMD         DB      0           ; initialization flag of DebugPMD
INIT_FLAG_DATA       ENDS


DebugPMD_INIT_TEXT   SEGMENT BYTE PUBLIC 'CODE'

               ASSUME  CS : DebugPMD_INIT_TEXT
               ASSUME  DS : INIT_FLAG_DATA

$INIT__DebugPMD   PROC  FAR

               MOV   AX, SEG INIT_FLAG_DATA
               MOV   DS, AX
               MOV   AL, TRUE                       ; TRUE
               XCHG  AL, BYTE PTR $FLAG_DebugPMD
               OR    AL, AL                         ; is it FALSE or TRUE ?
               JE    InitPmd0
               JMP   EndInit                        ; skip if TRUE
InitPmd0:
               ; test if the rtd is present and do not install PMD in that case

               MOV   AX, SEG debuggerRecord__RTSMain
               MOV   ES, AX

               ASSUME ES : RTSMain_DATA

               TEST  WORD PTR debuggerRecord__RTSMain, 0FFFFH
               JE    EndInit

;-------------- Get the current programLevel

               LDS   SI, activProcess__RTSMain
               MOV   AX, [SI+PD_PROG_LEVEL]
               PUSH  AX

               CALL  $INIT__RTSMain
               CALL  $INIT__RTSCoroutine

             ; Create the dump process
               MOV   AX, SEG Dumper
               PUSH  AX
               MOV   AX, OFFSET Dumper
               PUSH  AX
               MOV   AX, SEG wsp
               PUSH  AX
               MOV   AX, OFFSET wsp
               PUSH  AX
               MOV   AX, WspSize
               PUSH  AX
               MOV   AX, SEG dumpProcess
               PUSH  AX
               MOV   AX, OFFSET dumpProcess
               PUSH  AX
               CALL  NewProcess__RTSCoroutine

               MOV   AX, DebugPMD_DATA
               MOV   DS, AX

               ASSUME DS : DebugPMD_DATA

               POP   AX                          ; recover the programLevel
               MOV   WORD PTR pmdLevel, AX       ; save it in global variable

               MOV   ES, WORD PTR dumpProcess+2

               MOV   WORD PTR ES:[PD_PRIO_MASK], 039H ;FFFFH ; maximum priority

               MOV   AX, SEG debuggerRecord__RTSMain
               MOV   ES, AX

               ASSUME ES : RTSMain_DATA

             ; save PMD procedure ...
               MOV   AX, WORD PTR debuggerRecord__RTSMain+10
               MOV   DX, WORD PTR debuggerRecord__RTSMain+12
               MOV   WORD PTR savedDumpProc,   AX
               MOV   WORD PTR savedDumpProc+2, DX

             ; ... and install a new one
               MOV   WORD PTR debuggerRecord__RTSMain+10, OFFSET Dump
               MOV   WORD PTR debuggerRecord__RTSMain+12, SEG Dump

               MOV   AX, SEG TermProc
               PUSH  AX
               MOV   AX, OFFSET TermProc
               PUSH  AX

               CALL  L__InstallTermProc__RTSMain
EndInit:
               RET
$INIT__DebugPMD   ENDP

DebugPMD_INIT_TEXT ENDS

               END
