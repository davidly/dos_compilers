;(**************************************************************************)
;(*                                                                        *)
;(*  MODULA-2    Library                                                   *)
;(*                                                                        *)
;(*           LOGITECH Inc,   Fremont,   CA 94555  (USA)                   *)
;(*                                                                        *)
;(*  Module  :                            				   *)
;(*    DynMem : dynamic memory management in fixed block   		   *)
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

        TITLE    DynMem

IFDEF OS2
POPFF   MACRO
	LOCAL	A
	JMP	$+3
A	LABEL	NEAR
	IRET
	PUSH	CS
	CALL	A
	ENDM
ENDIF

        PUBLIC  L__Alloc__DynMem
        PUBLIC  L__DeAlloc__DynMem
        PUBLIC  L__Avail__DynMem
        PUBLIC  L__InstallDynMem__DynMem
        PUBLIC  $OK__16jun87_1952_OF_DynMem
        PUBLIC  KEY__10aug87_2031_OF_DynMem
KEY__10aug87_2031_OF_DynMem EQU 0
        PUBLIC  $INIT__DynMem
        PUBLIC  $BM__DynMem, $EM__DynMem

;====== FROM RTSError    IMPORT

IFDEF OS2
        EXTRN   IntegerOvf_RTSErr  : FAR
RUN_ON_PC = 0
ELSE
        EXTRN   L__Terminate__RTSMain  : FAR
        EXTRN   IntegerOvf__RTSError  : FAR
RUN_ON_PC = 1
ENDIF
        INCLUDE ..\rts\rts.inc


MINSIZ  EQU     8
OSize   EQU     0
OFPtr   EQU     2
OBPtr   EQU     4
OESize  EQU     -2

DMSRCH  EQU     0
DMSize  EQU     DMSRCH + 2 
DMHEAD  EQU     DMSize + 2
DMSTART EQU     DMHEAD + 0AH
DMHDSZ  EQU     DMSTART + 2


MODULE_TABLE_DATA SEGMENT WORD PUBLIC 'FAR_DATA'
$OK__16jun87_1952_OF_DynMem DW 0AED0H,4A8H,0
MODULE_TABLE_DATA ENDS

IFDEF MEDIUM
DGROUP GROUP MODULE_TABLE_DATA;
ENDIF


DynMem_TEXT SEGMENT BYTE PUBLIC 'CODE'
        ASSUME  CS:DynMem_TEXT
        ASSUME  DS:NOTHING
$BM__DynMem:
;-----------------------------------------------------------
L__InstallDynMem__DynMem PROC    FAR
;-----------------------------------------------------------
; in :  ( a : ADDRESS; size : CARDINAL )
;
; We assume that the offset is 0

        PUSH    BP
        MOV     BP,SP
IFDEF OS2
        LDS     DI,8[BP]                  ; DS:DX <= a
        MOV     SI,DI
        ADD     SI,DMSTART
        MOV     BX,DI
        ADD     BX,DMHEAD
ELSE
        LDS     BX,8[BP]                  ; DS:DX <= a
        OR      BX, BX                    ; is realy the offset 0
        JE      I0
        MOV     AX, BAD_OPERAND
        PUSH    AX
        CALL    L__Terminate__RTSMain       ; bad address for DynMem
I0:
        MOV     SI,DMSTART
        MOV     BX,DMHEAD
ENDIF

        MOV     WORD PTR OSize[BX],0
        MOV     WORD PTR OFPtr[BX],SI
        MOV     WORD PTR OBPtr[BX],SI
        MOV     WORD PTR 6[BX],0
        MOV     WORD PTR 8[BX],-1
        MOV     AX, 6[BP]                 ; AX <= size
        CMP     AX, 07FFEH                ; is size correct ( < MaxInt )
        JB      I1
IFDEF OS2
        CALL    IntegerOvf_RTSErr
ELSE
        CALL    IntegerOvf__RTSError
ENDIF

I1:
        SUB     AX, DMHDSZ                ; get the current usable size
IFDEF OS2
        MOV     WORD PTR DMSize[DI], AX   ; save the total free size
ELSE
        MOV     WORD PTR DS:[DMSize], AX  ; save the total free size
ENDIF
        MOV     WORD PTR OSize[SI],AX
        MOV     WORD PTR OFPtr[SI],BX
        MOV     WORD PTR OBPtr[SI],BX
        ADD     SI,AX                     ; SI <= ^upper limit word
        MOV     WORD PTR [SI],-1
        MOV     WORD PTR OESize[SI],AX
IFDEF OS2
        MOV     WORD PTR DMSRCH[DI],BX
ELSE
        MOV     WORD PTR DS:[DMSRCH],BX
ENDIF

IFDEF MEDIUM
        MOV     BX, DGROUP
        MOV     DS, BX
ENDIF

        POP     BP
        RET     6

L__InstallDynMem__DynMem ENDP


;-----------------------------------------------------------
L__Alloc__DynMem PROC    FAR                   
;-----------------------------------------------------------
; in :  ( block : ADDRESS; VAR a : ADDRESS; size : CARDINAL )
;
        PUSH    BP
        MOV     BP,SP
IFDEF OS2
        LDS     SI,0CH[BP]                  ; DS:OFFSET  <= block
ELSE
        LDS     BX,0CH[BP]                  ; DS:0  <= block
        OR      BX,BX
        JE      L0
        MOV     AX, BAD_OPERAND
        PUSH    AX
        CALL    L__Terminate__RTSMain       ; bad address for DynMem
L0:
ENDIF
        MOV     AX,6[BP]                    ; AX    <= size

;       Clear interrupts to prevent access to non reentrant code
        
        PUSHF
IFNDEF OS2
        CLI
ENDIF
;       calculate length of space to allocate

        ADD     AX,4            ; Space for control words
        CMP     AX,MINSIZ       ; The bloc must be a minimum size
        JGE     L4
        MOV     AX,MINSIZ

;       Search for 1st space that is large enough
 
IFDEF OS2
L4:     MOV     DX,DMSRCH[SI]   ; Start of search
ELSE
L4:     MOV     DX,DS:[DMSRCH]  ; Start of search
ENDIF
        MOV     BX,DX           ; Start of list head
L5:     CMP     OSize[BX],AX    ; Is this bloc large enough ?
        JGE     L10
        CMP     WORD PTR OFPtr[BX],DX   ; No, end of memory
        JE      L90
        MOV     BX,OFPtr[BX]            ; Next block
        JMP     L5

;       We have found a block that is large enough

L10:    MOV     CX,OFPtr[BX]            ; Next search begins here
IFDEF OS2
        MOV     DMSRCH[SI],CX
ELSE
        MOV     DS:[DMSRCH],CX
ENDIF
        MOV     CX,OSize[BX]            ; Size of the block
        SUB     CX,AX                   ; Remainder size
        CMP     CX,MINSIZ               ; .. large enough ?
        JGE     L15

;       Allocate all of block

        ADD     AX,CX
        MOV     SI,OFPtr[BX]            ; Remove block from list
        MOV     DI,OBPtr[BX]
        MOV     OFPtr[DI],SI
        MOV     OBPtr[SI],DI
        JMP     L20

;       Link remaining block to list

L15:    MOV     SI,BX                   ; Block address
        ADD     SI,AX                   ; Start address of remaining block
        MOV     OSize[SI],CX
        MOV     DI,SI
        ADD     DI,CX
        SUB     DI,2                    ; Address of end of block
        MOV     OSize[DI],CX
        MOV     DX,OFPtr[BX]            ; Set new block pointers
        MOV     OFPtr[SI],DX
        MOV     DX,OBPtr[BX]
        MOV     OBPtr[SI],DX
        MOV     DI,OFPtr[BX]            ; Update previous and next block pntrs
        MOV     OBPtr[DI],SI
        MOV     DI,OBPtr[BX]
        MOV     OFPtr[DI],SI

;       Allocate block

L20:    MOV     OSize[BX],AX            ; Block size
        NEG     WORD PTR OSize[BX]      ; Mark block unavailable
        MOV     SI,BX
        ADD     SI,AX
        SUB     SI,2                    ; Address of end control word
        MOV     OSize[SI],AX            ; Block size
        NEG     WORD PTR OSize[SI]      ; Set unavailable
        ADD     BX,2                    ; Address of data block allocated

;       Updates the pointer parametre : RETURN value
L40:
        LES     AX,8[BP]                ; Address of the pointer
        XCHG    BX,AX
        MOV     ES:[BX],AX
        MOV     ES:2[BX],DS

;       Restore interrupts as they were before

IFDEF OS2
        POPFF
ELSE
        POPF
ENDIF

;       Modula compatible return

IFDEF MEDIUM
        MOV     BX, DGROUP
        MOV     DS, BX
ENDIF

        POP     BP
        RET     0AH

;       Error - no block large enough

L90:
        MOV     BX,0H
        MOV     DS,BX
        DEC     BX               ; DS:BX  <= NIL  = 0:FFFFH
        JMP     L40

L__Alloc__DynMem ENDP


;-----------------------------------------------------------
L__DeAlloc__DynMem PROC    FAR                  
;-----------------------------------------------------------
; in :  ( block : ADDRESS; VAR a : ADDRESS; size: CARDINAL ): BOOLEAN;

        PUSH    BP
        MOV     BP,SP
        
;       Clears interrupt to protect non reentrant code

        PUSHF
IFDEF OS2
        LDS     AX,0CH[BP]                  ; DS:0  <= block
ELSE
        CLI

        LDS     BX,0CH[BP]                  ; DS:0  <= block
        OR      BX,BX
        JE      K0
        MOV     AX, BAD_OPERAND
        PUSH    AX
        CALL    L__Terminate__RTSMain       ; bad address for DynMem
ENDIF
K0:
        LES     BX,8[BP]                    ; Address of the pointer
        MOV     WORD PTR ES:[BX]+2,0H       ; Segment NIL
        MOV     CX,ES:[BX]                  ; Get offset of the block
        MOV     WORD PTR ES:[BX],0FFFFH     ; Offset NIL
        MOV     BX,CX
;        MOV     CX,6[BP]                    ; Size of the block

;       Get address of variable start

        SUB     BX,2
        CMP     WORD PTR OSize[BX],0    ; Is memory allocated
        JL      K2

;       The block is already deallocated

        JMP     K30

K2:
        NEG     WORD PTR OSize[BX]              ; Length of disposed block

;       Merge with previous block if it is available

        CMP     WORD PTR OESize[BX],0
        JL      K10
        MOV     SI,BX                   ; It is available, calculate its addr.
        SUB     SI,OESize[BX]
IFDEF OS2
	XCHG    AX,BX
        CMP     DMSRCH[BX],SI           ; Does search start here
	XCHG    AX,BX
ELSE
        CMP     DS:[DMSRCH],SI          ; Does search start here
ENDIF
        JNE     K5
        MOV     DX,DMHEAD
IFDEF OS2
        ADD     DX,AX
        XCHG    AX,BX
        MOV     DMSRCH[BX],DX
        XCHG    AX,BX
ELSE
        MOV     DS:[DMSRCH],DX
ENDIF
K5:
        MOV     CX,[SI]                 ; Length of previous block
        ADD     CX,[BX]                 ; Length of combined block
        MOV     BX,SI                   ; Address of combined block
        MOV     OSize[BX],CX            ; Load new length
        MOV     SI,OFPtr[BX]
        MOV     DI,OBPtr[BX]
        MOV     OFPtr[DI],SI
        MOV     OBPtr[SI],DI

;       Merge with next block if it is available

K10:    MOV     SI,BX
        ADD     SI,OSize[BX]
        CMP     WORD PTR OSize[SI],0    ; Is it available
        JL      K20
IFDEF OS2
        XCHG    AX,BX
        CMP     DMSRCH[BX],SI           ; Yes - does search start here
        XCHG    AX,BX
ELSE
        CMP     DS:[DMSRCH],SI          ; Yes - does search start here
ENDIF
        JNE     K15
        MOV     DX,DMHEAD               ; Yes - reset search start
IFDEF OS2
	ADD	DX,AX
	XCHG    AX,BX
        MOV     DMSRCH[BX],DX
        XCHG    AX,BX
ELSE
        MOV     DS:[DMSRCH],DX
ENDIF
K15:
        MOV     CX,[SI]                 ; Length of next block
        ADD     OSize[BX],CX            ; Length of combined block
        MOV     DI,OBPtr[SI]
        MOV     SI,OFPtr[SI]
        MOV     OFPtr[DI],SI
        MOV     OBPtr[SI],DI

;       Link resulting block at beginning of free list

K20:
        MOV     SI,BX
        MOV     CX,OSize[BX]
        ADD     SI,CX
        SUB     SI,2
        MOV     [SI],CX                 ; Put size at end of free block
        MOV     SI,DMHEAD               ; List head offset
IFDEF OS2
	ADD     SI,AX
ENDIF
        MOV     CX,OFPtr[SI]
        MOV     OFPtr[BX],CX
        MOV     OFPtr[SI],BX
        MOV     SI,OFPtr[BX]            ; Address of next block
        MOV     CX,OBPtr[SI]            ; Next block backward pointer
        MOV     OBPtr[SI],BX
        MOV     OBPtr[BX],CX            ; Original backward pointer

;       Return
K30:
;        LES     BX, 8[BP]               ; DS:BX <= ^a
;        MOV     WORD PTR ES:[BX],0FFFFH
;        MOV     WORD PTR ES:2[BX],0H    ; a <= NIL

; Test if the block is now empty

IFDEF OS2
	XCHG    AX, SI
        MOV     AX, 0
        MOV     BX, WORD PTR DMSize[SI]  ; get total allocatable size
        CMP     BX, WORD PTR DMSTART[SI] ; is the space totaly free ?
ELSE
        MOV     AX, 0
        MOV     BX, WORD PTR DS:[DMSize]  ; get total allocatable size
        CMP     BX, WORD PTR DS:[DMSTART] ; is the space totaly free ?
ENDIF
        JNE     K40
        INC     AX
K40:
IFDEF OS2
        POPFF
ELSE
        POPF
ENDIF

IFDEF MEDIUM
        MOV     BX, DGROUP
        MOV     DS, BX
ENDIF

        POP     BP
        RET     0AH

L__DeAlloc__DynMem ENDP


;-----------------------------------------------------------
L__Avail__DynMem PROC    FAR                  
;-----------------------------------------------------------
; in :  ( block : ADDRESS; size : CARDINAL ) : BOOLEAN;

        PUSH    BP
        MOV     BP,SP
        LDS     BX, 8[BP]             ; DS:0 <= block
IFNDEF OS2
        OR      BX,BX
        JE      M0
        MOV     AX, BAD_OPERAND
        PUSH    AX
        CALL    L__Terminate__RTSMain       ; bad address for DynMem
ENDIF
M0:
        MOV     AX, 6[BP]

;       Clear interrupts to prevent access to non reentrant code
        
        PUSHF
IFNDEF OS2
        CLI
ENDIF

;       calculate length of space to allocate

        ADD     AX,4                    ; Space for control words
        CMP     AX,MINSIZ               ; The bloc must be a minimum size
        JGE     M4
        MOV     AX,MINSIZ

;       Search for 1st space that is large enough
 
M4:     MOV     DX,DS:[DMSRCH]          ; Start of search
        MOV     BX,DX                   ; Start of list head
M5:     CMP     OSize[BX],AX            ; Is this bloc large enough ?
        JGE     M10
        CMP     WORD PTR OFPtr[BX],DX   ; No, end of memory
        JE      M90
        MOV     BX,OFPtr[BX]            ; Next block
        JMP     M5

;       We have found a block that is large enough

M10:
        MOV     AX,1                    ; TRUE, the space is svailable

;       Restore interrupts as they were before
M80:
IFDEF OS2
        POPFF
ELSE
        POPF
ENDIF

;       Modula compatible return

IFDEF MEDIUM
        MOV     BX, DGROUP
        MOV     DS, BX
ENDIF

        POP     BP
        RET     6

;       No block large enough

M90:
        MOV     AX,0
        JMP     M80

L__Avail__DynMem ENDP


$INIT__DynMem   PROC  FAR
               RET
$INIT__DynMem   ENDP

$EM__DynMem:
DynMem_TEXT ENDS

        END
