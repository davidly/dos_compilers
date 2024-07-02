;(**************************************************************************)
;(*                                                                        *)
;(*  MODULA-2    Library                                                   *)
;(*                                                                        *)
;(*           LOGITECH Inc,   Fremont,   CA 94555  (USA)                   *)
;(*                                                                        *)
;(*  Module  :                            				   *)
;(*    BitWordOps, bitwise operations on words				   *)
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

        TITLE    BitWordOps

        PUBLIC  L__GetBits__BitWordOps
        PUBLIC  L__SetBits__BitWordOps
        PUBLIC  L__WordAnd__BitWordOps
        PUBLIC  L__WordOr__BitWordOps
        PUBLIC  L__WordXor__BitWordOps
        PUBLIC  L__WordNot__BitWordOps
        PUBLIC  L__WordShr__BitWordOps
        PUBLIC  L__WordSar__BitWordOps
        PUBLIC  L__WordShl__BitWordOps
        PUBLIC  L__WordRor__BitWordOps
        PUBLIC  L__WordRol__BitWordOps
        PUBLIC  L__HighByte__BitWordOps
        PUBLIC  L__LowByte__BitWordOps
        PUBLIC  L__Swap__BitWordOps

        PUBLIC  KEY__10aug87_2030_OF_BitWordOps
        PUBLIC  $OK__31jul87_1200_OF_BitWordOps

KEY__10aug87_2030_OF_BitWordOps EQU 0

        PUBLIC  $INIT__BitWordOps
        PUBLIC  $BM__BitWordOps, $EM__BitWordOps
;        PUBLIC  $BD__BitWordOps, $ED__BitWordOps



MODULE_TABLE_DATA SEGMENT WORD PUBLIC 'FAR_DATA'
$OK__31jul87_1200_OF_BitWordOps DW 0AEFFH,02D0H,0
MODULE_TABLE_DATA ENDS

BitWordOps_TEXT SEGMENT BYTE PUBLIC 'CODE'
                ASSUME  CS:BitWordOps_TEXT
                ASSUME  DS:NOTHING
$BM__BitWordOps:
;-----------------------------------------------------------
L__GetBits__BitWordOps PROC    FAR
;-----------------------------------------------------------
; in :  (source, firstBit, lastBit : WORD): WORD;

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
              POP   BP
              RET   6

L__GetBits__BitWordOps ENDP

;-----------------------------------------------------------
L__SetBits__BitWordOps PROC    FAR
;-----------------------------------------------------------
; in : (VAR word         : WORD; 
;       firstBit, lastBit: CARDINAL;
;       value            : WORD)

value    = 6
lastBit  = value + 2
firstBit = lastBit + 2
_word    = firstBit + 2

              PUSH  BP
              MOV   BP, SP
              MOV   BX, [BP + value]

              MOV   AX, 65535               
              MOV   CL, 15
              SUB   CL, [BP + lastBit]
              SHL   AX, CL
              ADD   CL, [BP + firstBit]
              SHR   AX, CL

              MOV   CL, [BP + firstBit]
              SHL   BX, CL
              SHL   AX, CL
              AND   BX, AX
              NOT   AX

              LES   DI, DWORD PTR [BP + _word]
              MOV   CX, WORD PTR ES:[DI]
              AND   CX, AX
              OR    CX, BX
              MOV   WORD PTR ES:[DI], CX

              POP   BP
              RET   10

L__SetBits__BitWordOps ENDP

;-----------------------------------------------------------
L__WordAnd__BitWordOps PROC    FAR
;-----------------------------------------------------------
; in : (left, right : WORD): WORD;

right = 6
left  = right + 2

              PUSH  BP
              MOV   BP, SP
              MOV   AX, [BP + left]
              MOV   BX, [BP + right]
              AND   AX, BX
              POP   BP
              RET   4

L__WordAnd__BitWordOps ENDP

;-----------------------------------------------------------
L__WordOr__BitWordOps PROC    FAR
;-----------------------------------------------------------
; in : (left, right : WORD): WORD;

right = 6
left  = right + 2

              PUSH  BP
              MOV   BP, SP
              MOV   AX, [BP + left]
              MOV   BX, [BP + right]
              OR    AX, BX
              POP   BP
              RET   4

L__WordOr__BitWordOps ENDP

;-----------------------------------------------------------
L__WordXor__BitWordOps PROC    FAR
;-----------------------------------------------------------
; in : (left, right : WORD): WORD;

right = 6
left  = right + 2

              PUSH  BP
              MOV   BP, SP
              MOV   AX, [BP + left]
              MOV   BX, [BP + right]
              XOR   AX, BX
              POP   BP
              RET   4

L__WordXor__BitWordOps ENDP

;-----------------------------------------------------------
L__WordNot__BitWordOps PROC    FAR
;-----------------------------------------------------------
; in : (word : WORD): WORD;

_word= 6

              PUSH  BP
              MOV   BP, SP
              MOV   AX, [BP + _word]
              NOT   AX
              POP   BP
              RET   2

L__WordNot__BitWordOps ENDP

;-----------------------------------------------------------
L__WordShr__BitWordOps PROC    FAR
;-----------------------------------------------------------
; in : (word  : CARDINAL;
;       count : WORD): WORD;

count = 6
_word = count + 2

              PUSH  BP
              MOV   BP, SP
              MOV   AX, [BP + _word]
              MOV   CX, [BP + count]
              SHR   AX, CL
              POP   BP
              RET   4

L__WordShr__BitWordOps ENDP

;-----------------------------------------------------------
L__WordSar__BitWordOps PROC    FAR
;-----------------------------------------------------------
; in : (word  : CARDINAL;
;       count : WORD): WORD;

count = 6
_word = count + 2

              PUSH  BP
              MOV   BP, SP
              MOV   AX, [BP + _word]
              MOV   CX, [BP + count]
              SAR   AX, CL
              POP   BP
              RET   4

L__WordSar__BitWordOps ENDP

;-----------------------------------------------------------
L__WordShl__BitWordOps PROC    FAR
;-----------------------------------------------------------
; in : (word  : CARDINAL;
;       count : WORD): WORD;

count = 6
_word = count + 2

              PUSH  BP
              MOV   BP, SP
              MOV   AX, [BP + _word]
              MOV   CX, [BP + count]
              SHL   AX, CL
              POP   BP
              RET   4

L__WordShl__BitWordOps ENDP

;-----------------------------------------------------------
L__WordRor__BitWordOps PROC    FAR
;-----------------------------------------------------------
; in : (word  : CARDINAL;
;       count : WORD): WORD;

count = 6
_word = count + 2

              PUSH  BP
              MOV   BP, SP
              MOV   AX, [BP + _word]
              MOV   CX, [BP + count]
              ROR   AX, CL
              POP   BP
              RET   4

L__WordRor__BitWordOps ENDP

;-----------------------------------------------------------
L__WordRol__BitWordOps PROC    FAR
;-----------------------------------------------------------
; in : (word  : CARDINAL;
;       count : WORD): WORD;

count = 6
_word = count + 2

              PUSH  BP
              MOV   BP, SP
              MOV   AX, [BP + _word]
              MOV   CX, [BP + count]
              ROL   AX, CL
              POP   BP
              RET   4

L__WordRol__BitWordOps ENDP

;-----------------------------------------------------------
L__HighByte__BitWordOps PROC    FAR
;-----------------------------------------------------------
; in : (word: WORD): CARDINAL;

_word   = 6

              PUSH  BP
              MOV   BP, SP
              MOV   AX, [BP + _word]
              MOV   CL, 8
              SHR   AX, CL
              POP   BP
              RET   2

L__HighByte__BitWordOps ENDP

;-----------------------------------------------------------
L__LowByte__BitWordOps PROC    FAR
;-----------------------------------------------------------
; in : (word: WORD): CARDINAL;

_word   = 6

              PUSH  BP
              MOV   BP, SP
              MOV   AX, [BP + _word]
              XOR   AH, AH
              POP   BP
              RET   2

L__LowByte__BitWordOps ENDP


;-----------------------------------------------------------
L__Swap__BitWordOps PROC    FAR
;-----------------------------------------------------------
; in : (VAR word: WORD)

_word   = 6

              PUSH  BP
              MOV   BP, SP
              LES   DI, DWORD PTR [BP+_word]
              MOV   BX, WORD PTR ES:[DI]
              XCHG  BH, BL
              MOV   WORD PTR ES:[DI], BX
              POP   BP
              RET   4

L__Swap__BitWordOps ENDP




$INIT__BitWordOps   PROC  FAR
               RET
$INIT__BitWordOps   ENDP

$EM__BitWordOps:
BitWordOps_TEXT ENDS

;BitWordOps_DATA         SEGMENT WORD PUBLIC 'FAR_BSS'
;                        ASSUME  CS : BitWordOps_TEXT
;$BD__BitWordOps         LABEL   FAR
;
;$ED__BitWordOps         LABEL  FAR
;BitWordOps_DATA         ENDS

        END
