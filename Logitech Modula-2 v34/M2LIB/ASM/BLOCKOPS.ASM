;(**************************************************************************)
;(*                                                                        *)
;(*  MODULA-2    Library                                                   *)
;(*                                                                        *)
;(*           LOGITECH Inc,   Fremont,   CA 94555  (USA)                   *)
;(*                                                                        *)
;(*  Module  :                            				   *)
;(*    BlockOps, operations on blocks					   *)
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

        TITLE    BlockOps

        PUBLIC  L__BlockMoveBackward__BlockOps
        PUBLIC  L__BlockMoveForward__BlockOps
        PUBLIC  L__BlockMove__BlockOps
        PUBLIC  L__BlockClear__BlockOps
        PUBLIC  L__BlockSet__BlockOps
        PUBLIC  L__BlockEqual__BlockOps
        PUBLIC  L__BlockPosition__BlockOps

        PUBLIC  KEY__10aug87_2030_OF_BlockOps
        PUBLIC  $OK__31jul87_1300_OF_BlockOps

KEY__10aug87_2030_OF_BlockOps EQU 0

        PUBLIC  $INIT__BlockOps
        PUBLIC  $BM__BlockOps, $EM__BlockOps
;        PUBLIC  $BD__BlockOps, $ED__BlockOps


MODULE_TABLE_DATA SEGMENT WORD PUBLIC 'FAR_DATA'
$OK__31jul87_1300_OF_BlockOps DW 0AEFFH,030CH,0
MODULE_TABLE_DATA ENDS

IFDEF MEDIUM
DGROUP GROUP MODULE_TABLE_DATA;
ENDIF

BlockOps_TEXT SEGMENT BYTE PUBLIC 'CODE'
                ASSUME  CS:BlockOps_TEXT
                ASSUME  DS:NOTHING
$BM__BlockOps:

;-----------------------------------------------------------
L__BlockMoveForward__BlockOps PROC    FAR
;-----------------------------------------------------------
; in : destination, source : ADDRESS;
;      size                : CARDINAL;

_size       = 6
source      = _size + 2
destination = source + 4

              PUSH  BP
              MOV   BP, SP
IFDEF MEDIUM
              MOV   BX, DS
ENDIF
              CLD
              LDS   SI, DWORD PTR [BP + source]
              LES   DI, DWORD PTR [BP + destination]
              MOV   CX, [BP + _size]
              SHR   CX, 1
              REP   MOVSW		; move words from DS:SI to ES:DI
              ADC   CX, 0		; if byte count was odd..
              REP   MOVSB		; move the odd byte
IFDEF MEDIUM
              MOV   DS, BX
ENDIF
              POP   BP
              RET   10

L__BlockMoveForward__BlockOps ENDP

;-----------------------------------------------------------
L__BlockMoveBackward__BlockOps PROC    FAR
;-----------------------------------------------------------
; in : destination, source : ADDRESS;
;      size                : CARDINAL;

_size       = 6
source      = _size + 2
destination = source + 4

              PUSH  BP
              MOV   BP, SP
IFDEF MEDIUM
              MOV   BX, DS
ENDIF
              LDS   SI, DWORD PTR [BP + source]
              LES   DI, DWORD PTR [BP + destination]
              MOV   CX, [BP + _size]
MoveUp:       STD
              DEC   CX
              ADD   SI, CX		; point to high source byte
              ADD   DI, CX		; point to high dest byte
              INC   CX			; get back byte count
              SHR   CX, 1		; CX = words to move
              JNC    Muppet		; even number of words
              MOVSB			; move highest (odd) byte
Muppet:
              DEC   SI			; point to high source word
              DEC   DI			; point to high dest word
              REP   MOVSW		; move rest of block by words
              CLD
IFDEF MEDIUM
              MOV   DS, BX
ENDIF
              POP   BP
              RET   10

L__BlockMoveBackward__BlockOps ENDP


;-----------------------------------------------------------
L__BlockMove__BlockOps PROC    FAR
;-----------------------------------------------------------
; in : destination, source : ADDRESS;
;      size                : CARDINAL;

_size       = 6
source      = _size + 2
destination = source + 4

              PUSH  BP
              MOV   BP, SP
              CLD

              MOV   CL, 4
              LDS   SI, DWORD PTR [BP + source]
; compute normalized source address in AX:BX   (BX <= 16)
              MOV   BX, SI
              AND   BX, 0FH                     ; offset MOD 16 -> BX
              SHR   SI, CL
              MOV   AX, DS
              ADD   AX, SI                      ; seg + offset DIV 16 -> AX
; compute normalized destination in CX:DX
              LES   DI, DWORD PTR [BP + destination]
              MOV   DX, DI
              AND   DX, 0FH                     ; offset MOD 16 -> DX
              SHR   DI, CL
              MOV   CX, ES
              ADD   CX, DI                      ; seg + offset DIV 16 -> CX

              LDS   SI, DWORD PTR [BP + source]
              LES   DI, DWORD PTR [BP + destination]

              CMP   CX, AX			; destination follows source?
              MOV   CX, [BP + _size]
              JNE   WARD
              CMP   DX, BX			; para are equal, chk offsets
              JE    MVEPILOG			; dst = src, no action
WARD:         JA    MoveUp			; dst > src
              SHR   CX, 1
              REP   MOVSW
              ADC   CX, 0
              REP   MOVSB			; move last byte, if any
MVEPILOG:

IFDEF MEDIUM
              MOV   BX, DGROUP
              MOV   DS, BX
ENDIF
              POP   BP
              RET   10

L__BlockMove__BlockOps ENDP

;-----------------------------------------------------------
L__BlockClear__BlockOps PROC    FAR
;-----------------------------------------------------------
; in : source : ADDRESS;
;      size   : CARDINAL;

_size  = 6
source = _size + 2

              PUSH  BP
              MOV   BP, SP
              LES   DI, DWORD PTR [BP + source]
              CLD
              XOR   AX, AX
              MOV   CX, [BP + _size]
              SHR   CX, 1
              REP   STOSW
              ADC   CX, 0
              REP   STOSB
              POP   BP
              RET   6

L__BlockClear__BlockOps ENDP

;-----------------------------------------------------------
L__BlockSet__BlockOps PROC    FAR
;-----------------------------------------------------------
; in  : block       : ADDRESS;
;       blockSize   : CARDINAL;
;       pattern     : ADDRESS;
;       patternSize : CARDINAL;

patternSize = 6
pattern     = patternSize + 2
blockSize   = pattern + 4
block       = blockSize + 2

              PUSH  BP
              MOV   BP, SP
              CLD
              MOV   BX, [BP + blockSize]
              LES   DI, DWORD PTR [BP + block]

LOP:          MOV   CX, [BP + patternSize]
              LDS   SI, DWORD PTR [BP + pattern]
              CMP   CX, BX
              JAE   EXIT		; 1 or fewer patterns left to do
              SUB   BX, CX		; reduce total byte count by 1 pattern
              REP   MOVSB		; copy pattern once
              JMP   LOP

EXIT:         MOV   CX, BX		; just do remaining part of block
              REP   MOVSB
IFDEF MEDIUM
              MOV   BX, DGROUP
              MOV   DS, BX
ENDIF
              POP   BP
              RET   12

L__BlockSet__BlockOps ENDP

;-----------------------------------------------------------
L__BlockEqual__BlockOps PROC    FAR
;-----------------------------------------------------------
; in  : left, right : ADDRESS;
;       count       : CARDINAL;
; out : BOOLEAN;

count = 6
right = count + 2
left  = right + 4

              PUSH  BP
              MOV   BP, SP
IFDEF MEDIUM
              MOV   BX, DS
ENDIF
              CLD
              MOV   CX, [BP + count]
              XOR   AX, AX		; assume value is FALSE
              LDS   SI, DWORD PTR [BP + left]
              LES   DI, DWORD PTR [BP + right]
              SHR   CX, 1		; compute word count
              JNC   EQEVN		; even number of words
              CMPSB			; odd - compare the odd bytes
              JNE   EQEPILOG		;   well well well, that was easy
EQEVN:        REPE  CMPSW		; compare by words (CX = 0 falls thru)
              JNE   EQEPILOG		; some word differed
EQT:          MOV   AX, 1		; return TRUE
EQEPILOG:

IFDEF MEDIUM
              MOV   DS, BX
ENDIF
              POP   BP
              RET   10

L__BlockEqual__BlockOps ENDP

;-----------------------------------------------------------
L__BlockPosition__BlockOps PROC    FAR
;-----------------------------------------------------------
; in  : block       : ADDRESS;
;       blockSize   : CARDINAL;
;       pattern     : ADDRESS;
;       patternSize : CARDINAL;
; out : CARDINAL;

patternSize = 6
pattern     = patternSize + 2
blockSize   = pattern + 4
block       = blockSize + 2

              PUSH  BP
              MOV   BP, SP
              CLD
              XOR   AX, AX
              MOV   DX, [BP + patternSize]
              TEST  DX, DX
              JZ    POSEPILOG		; trivial match (null pattern)
              MOV   BX, [BP + blockSize]
              SUB   BX, DX		; BX = last possible position
              JB    NOTFOUND		;   none
WHILE:
              MOV   CX, DX		; CX = patternSize
              LDS   SI, DWORD PTR [BP + pattern]
              LES   DI, DWORD PTR [BP + block]
              ADD   DI, AX		; offset to current position
              REPE  CMPSB
              JE    POSEPILOG		; match
              INC   AX			; try at next position
              CMP   AX, BX
              JBE   WHILE

NOTFOUND:     MOV   AX, 65535

POSEPILOG:

IFDEF MEDIUM
              MOV   BX, DGROUP
              MOV   DS, BX
ENDIF
              POP   BP
              RET   12

L__BlockPosition__BlockOps ENDP


$INIT__BlockOps   PROC  FAR
               RET
$INIT__BlockOps   ENDP

$EM__BlockOps:
BlockOps_TEXT ENDS

;BlockOps_DATA         SEGMENT WORD PUBLIC 'FAR_BSS'
;                      ASSUME  CS : BlockOps_TEXT
;$BD__BlockOps         LABEL   FAR
;
;$ED__BlockOps         LABEL  FAR
;BlockOps_DATA         ENDS

        END
