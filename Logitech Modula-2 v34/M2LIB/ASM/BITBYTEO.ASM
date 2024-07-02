;(**************************************************************************)
;(*                                                                        *)
;(*  MODULA-2    Library                                                   *)
;(*                                                                        *)
;(*           LOGITECH Inc,   Fremont,   CA 94555  (USA)                   *)
;(*                                                                        *)
;(*  Module  :                            				   *)
;(*    BitByteOps, bitwise operations on bytes				   *)
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

        TITLE    BitByteOps

        PUBLIC  L__GetBits__BitByteOps
        PUBLIC  L__SetBits__BitByteOps
        PUBLIC  L__ByteAnd__BitByteOps
        PUBLIC  L__ByteOr__BitByteOps
        PUBLIC  L__ByteXor__BitByteOps
        PUBLIC  L__ByteNot__BitByteOps
        PUBLIC  L__ByteShr__BitByteOps
        PUBLIC  L__ByteSar__BitByteOps
        PUBLIC  L__ByteShl__BitByteOps
        PUBLIC  L__ByteRor__BitByteOps
        PUBLIC  L__ByteRol__BitByteOps
        PUBLIC  L__HighNibble__BitByteOps
        PUBLIC  L__LowNibble__BitByteOps
        PUBLIC  L__Swap__BitByteOps

        PUBLIC  KEY__10aug87_2030_OF_BitByteOps
        PUBLIC  $OK__31jul87_1100_OF_BitByteOps

KEY__10aug87_2030_OF_BitByteOps EQU 0

        PUBLIC  $INIT__BitByteOps
        PUBLIC  $BM__BitByteOps, $EM__BitByteOps
;        PUBLIC  $BD__BitByteOps, $ED__BitByteOps

MODULE_TABLE_DATA SEGMENT WORD PUBLIC 'FAR_DATA'
$OK__31jul87_1100_OF_BitByteOps DW 0AEFFH,0294H,0
MODULE_TABLE_DATA ENDS

BitByteOps_TEXT SEGMENT BYTE PUBLIC 'CODE'
                ASSUME  CS:BitByteOps_TEXT
                ASSUME  DS:NOTHING
$BM__BitByteOps:
;-----------------------------------------------------------
L__GetBits__BitByteOps PROC    FAR
;-----------------------------------------------------------
; in :  (source: BYTE;
;        firstBit, lastBit : CARDINAL): BYTE;

lastBit  = 6
firstBit = lastBit + 2
source   = firstBit + 2

              PUSH  BP
              MOV   BP, SP
              MOV   AX, [BP + source]
              MOV   CL, 15
              SUB   CL, [BP + lastBit]
              SHL   AX, CL
              ADD   CL, [BP + firstBit]
              SHR   AX, CL
              XOR   AH, AH
              POP   BP
              RET   6

L__GetBits__BitByteOps ENDP

;-----------------------------------------------------------
L__SetBits__BitByteOps PROC    FAR
;-----------------------------------------------------------
; in : (VAR byte         : BYTE; 
;       firstBit, lastBit: CARDINAL;
;       value            : BYTE)

value    = 6
lastBit  = value + 2
firstBit = lastBit + 2
_byte    = firstBit + 2

              PUSH  BP
              MOV   BP, SP
              MOV   BX, [BP + value]
              MOV   AX, 0FFFFH
              MOV   CL, [BP + firstBit]
              SHR   AX, CL
              SHL   AX, CL		; clip mask on right
              SHL   BX, CL		; position value
              MOV   CL, 15
              SUB   CL, [BP + lastBit]
              SHL   AX, CL
              SHR   AX, CL		; clip mask on left
              AND   BX, AX		; mask new value
              NOT   AX
              LES   DI, DWORD PTR [BP + _byte]
              AND   AL, BYTE PTR  ES:[DI] ; get byte, mask out affected bits
              OR    AL, BL		; plug in new value
              MOV   BYTE PTR ES:[DI], AL
              POP   BP
              RET   10

L__SetBits__BitByteOps ENDP

;-----------------------------------------------------------
L__ByteAnd__BitByteOps PROC    FAR
;-----------------------------------------------------------
; in : (left, right : BYTE): BYTE;

right = 6
left  = right + 2

              PUSH  BP
              MOV   BP, SP
              MOV   AX, [BP + left]
              AND   AX, [BP + right]
              XOR   AH, AH
              POP   BP
              RET   4

L__ByteAnd__BitByteOps ENDP

;-----------------------------------------------------------
L__ByteOr__BitByteOps PROC    FAR
;-----------------------------------------------------------
; in : (left, right : BYTE): BYTE;

right = 6
left  = right + 2

              PUSH  BP
              MOV   BP, SP
              MOV   AX, [BP + left]
              OR    AX, [BP + right]
              XOR   AH, AH
              POP   BP
              RET   4

L__ByteOr__BitByteOps ENDP

;-----------------------------------------------------------
L__ByteXor__BitByteOps PROC    FAR
;-----------------------------------------------------------
; in : (left, right : BYTE): BYTE;

right = 6
left  = right + 2

              PUSH  BP
              MOV   BP, SP
              MOV   AX, [BP + left]
              XOR   AX, [BP + right]
              XOR   AH, AH
              POP   BP
              RET   4

L__ByteXor__BitByteOps ENDP

;-----------------------------------------------------------
L__ByteNot__BitByteOps PROC    FAR
;-----------------------------------------------------------
; in : (byte : BYTE): BYTE;

_byte = 6

              PUSH  BP
              MOV   BP, SP
              MOV   AX, [BP + _byte]
              NOT   AX
              XOR   AH, AH
              POP   BP
              RET   2

L__ByteNot__BitByteOps ENDP

;-----------------------------------------------------------
L__ByteShr__BitByteOps PROC    FAR
;-----------------------------------------------------------
; in : (byte  : BYTE;
;       count : CARDINAL): BYTE;

count = 6
_byte = count + 2

              PUSH  BP
              MOV   BP, SP
              MOV   AX, [BP + _byte]
              MOV   CX, [BP + count]
              XOR   AH, AH
              SHR   AL, CL
              POP   BP
              RET   4

L__ByteShr__BitByteOps ENDP

;-----------------------------------------------------------
L__ByteSar__BitByteOps PROC    FAR
;-----------------------------------------------------------
; in : (byte  : BYTE;
;       count : CARDINAL): BYTE;

count = 6
_byte = count + 2

              PUSH  BP
              MOV   BP, SP
              MOV   AX, [BP + _byte]
              MOV   CX, [BP + count]
              XOR   AH, AH
              SAR   AL, CL
              POP   BP
              RET   4

L__ByteSar__BitByteOps ENDP

;-----------------------------------------------------------
L__ByteShl__BitByteOps PROC    FAR
;-----------------------------------------------------------
; in : (byte  : BYTE;
;       count : CARDINAL): BYTE;

count = 6
_byte = count + 2

              PUSH  BP
              MOV   BP, SP
              MOV   AX, [BP + _byte]
              MOV   CX, [BP + count]
              XOR   AH, AH
              SHL   AL, CL
              POP   BP
              RET   4

L__ByteShl__BitByteOps ENDP

;-----------------------------------------------------------
L__ByteRor__BitByteOps PROC    FAR
;-----------------------------------------------------------
; in : (byte  : BYTE;
;       count : CARDINAL): BYTE;

count = 6
_byte = count + 2

              PUSH  BP
              MOV   BP, SP
              MOV   AX, [BP + _byte]
              MOV   CX, [BP + count]
              XOR   AH, AH
              ROR   AL, CL
              POP   BP
              RET   4

L__ByteRor__BitByteOps ENDP

;-----------------------------------------------------------
L__ByteRol__BitByteOps PROC    FAR
;-----------------------------------------------------------
; in : (byte  : BYTE;
;       count : CARDINAL): BYTE;

count = 6
_byte = count + 2

              PUSH  BP
              MOV   BP, SP
              MOV   AX, [BP + _byte]
              MOV   CX, [BP + count]
              XOR   AH, AH
              ROL   AL, CL
              POP   BP
              RET   4

L__ByteRol__BitByteOps ENDP

;-----------------------------------------------------------
L__HighNibble__BitByteOps PROC    FAR
;-----------------------------------------------------------
; in : (byte: BYTE): CARDINAL;

_byte   = 6

              PUSH  BP
              MOV   BP, SP
              MOV   AX, [BP + _byte]
              XOR   AH, AH
              MOV   CL, 4
              SHR   AL, CL
              POP   BP
              RET   2

L__HighNibble__BitByteOps ENDP

;-----------------------------------------------------------
L__LowNibble__BitByteOps PROC    FAR
;-----------------------------------------------------------
; in : (byte: BYTE): CARDINAL;

_byte   = 6

              PUSH  BP
              MOV   BP, SP
              MOV   AX, [BP + _byte]
              XOR   AH, AH
              AND   AL, 0FH
              POP   BP
              RET   2

L__LowNibble__BitByteOps ENDP


;-----------------------------------------------------------
L__Swap__BitByteOps PROC    FAR
;-----------------------------------------------------------
; in : (VAR byte: BYTE)

_byte   = 6

              PUSH  BP
              MOV   BP, SP
              LES   DI, DWORD PTR [BP + _byte]
              MOV   CL, 4
              MOV   AL, BYTE PTR ES:[DI]
              ROR   AL, CL
              MOV   BYTE PTR ES:[DI], AL
              POP   BP
              RET   4

L__Swap__BitByteOps ENDP




$INIT__BitByteOps   PROC  FAR
               RET
$INIT__BitByteOps   ENDP

$EM__BitByteOps:
BitByteOps_TEXT ENDS

;BitByteOps_DATA         SEGMENT BYTE PUBLIC 'FAR_BSS'
;                        ASSUME  CS : BitByteOps_TEXT
;$BD__BitByteOps         LABEL   FAR
;
;$ED__BitByteOps         LABEL  FAR
;BitByteOps_DATA         ENDS

        END
