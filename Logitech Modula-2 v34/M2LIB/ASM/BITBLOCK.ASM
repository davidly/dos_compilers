;(**************************************************************************)
;(*                                                                        *)
;(*  MODULA-2    Library                                                   *)
;(*                                                                        *)
;(*           LOGITECH Inc,   Fremont,   CA 94555  (USA)                   *)
;(*                                                                        *)
;(*  Module  :                            				   *)
;(*    BitBlockOps, operations on blocks				   *)
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

        TITLE    BitBlockOps

        PUBLIC  L__BlockAnd__BitBlockOps
        PUBLIC  L__BlockOr__BitBlockOps
        PUBLIC  L__BlockXor__BitBlockOps
        PUBLIC  L__BlockNot__BitBlockOps
        PUBLIC  L__BlockShr__BitBlockOps
        PUBLIC  L__BlockSar__BitBlockOps
        PUBLIC  L__BlockShl__BitBlockOps
        PUBLIC  L__BlockRor__BitBlockOps
        PUBLIC  L__BlockRol__BitBlockOps

        PUBLIC  KEY__10aug87_2030_OF_BitBlockOps
        PUBLIC  $OK__31jul87_1000_OF_BitBlockOps

KEY__10aug87_2030_OF_BitBlockOps EQU 0

        PUBLIC  $INIT__BitBlockOps
        PUBLIC  $BM__BitBlockOps, $EM__BitBlockOps
;        PUBLIC  $BD__BitBlockOps, $ED__BitBlockOps

MODULE_TABLE_DATA SEGMENT WORD PUBLIC 'FAR_DATA'
$OK__31jul87_1000_OF_BitBlockOps DW 0AEFFH,0258H,0
MODULE_TABLE_DATA ENDS

IFDEF MEDIUM
DGROUP	GROUP	MODULE_TABLE_DATA
ENDIF

BitBlockOps_TEXT SEGMENT BYTE PUBLIC 'CODE'
                ASSUME  CS:BitBlockOps_TEXT
                ASSUME  DS:NOTHING
$BM__BitBlockOps:

;-----------------------------------------------------------
L__BlockAnd__BitBlockOps PROC    FAR
;-----------------------------------------------------------
; in : (destination, source : ADDRESS;
;       blocksize           : CARDINAL);

blocksize   = 6
source      = blocksize + 2
destination = source + 4

              PUSH  BP
              MOV   BP, SP
              MOV   CX, [BP + blocksize]
              JCXZ  ANDEPILOG
IFDEF MEDIUM
              MOV   BX, DS
ENDIF
              CLD
              LDS   SI, DWORD PTR [BP + source]
              LES   DI, DWORD PTR [BP + destination]
ANDAGAIN:     LODSB		; MOV AL,DS:[SI]  INC SI
              AND   BYTE PTR ES:[DI], AL
              INC   DI
              LOOP  ANDAGAIN
IFDEF MEDIUM
              MOV   DS, BX
ENDIF

ANDEPILOG:    POP   BP
              RET   10

L__BlockAnd__BitBlockOps ENDP

;-----------------------------------------------------------
L__BlockOr__BitBlockOps PROC    FAR
;-----------------------------------------------------------
; in : (destination, source : ADDRESS;
;       blocksize           : CARDINAL);

blocksize   = 6
source      = blocksize + 2
destination = source + 4

              PUSH  BP
              MOV   BP, SP
              CLD
              MOV   CX, [BP + blocksize]
              JCXZ  OREPILOG
IFDEF MEDIUM
              MOV   BX, DS
ENDIF
              LDS   SI, DWORD PTR [BP + source]
              LES   DI, DWORD PTR [BP + destination]
ORAGAIN:      LODSB
              OR    BYTE PTR ES:[DI], AL
              INC   DI
              LOOP  ORAGAIN
IFDEF MEDIUM
              MOV   DS, BX
ENDIF

OREPILOG:     POP   BP
              RET   10

L__BlockOr__BitBlockOps ENDP

;-----------------------------------------------------------
L__BlockXor__BitBlockOps PROC    FAR
;-----------------------------------------------------------
; in : (destination, source : ADDRESS;
;       blocksize           : CARDINAL);

blocksize   = 6
source      = blocksize + 2
destination = source + 4


              PUSH  BP
              MOV   BP, SP
IFDEF MEDIUM
              MOV   BX, DS
ENDIF
              MOV   CX, [BP + blocksize]
              CLD
              LDS   SI, DWORD PTR [BP + source]
              JCXZ  XOREPILOG
              LES   DI, DWORD PTR [BP + destination]
XORAGAIN:     LODSB
              XOR   BYTE PTR ES:[DI], AL
              INC   DI
              LOOP  XORAGAIN
XOREPILOG:
IFDEF MEDIUM
              MOV   DS, BX
ENDIF
	      POP   BP
              RET   10

L__BlockXor__BitBlockOps ENDP

;-----------------------------------------------------------
L__BlockNot__BitBlockOps PROC    FAR
;-----------------------------------------------------------
; in : (block      : ADDRESS;
;       blocksize  : CARDINAL);
blocksize  = 6
block      = blocksize + 2

              PUSH  BP
              MOV   BP, SP
              MOV   CX, [BP + blocksize]
              JCXZ  NOTEPILOG
              LES   DI, DWORD PTR [BP + block]
NOTAGAIN:     NOT   BYTE PTR ES:[DI]
              INC   DI
              LOOP  NOTAGAIN
NOTEPILOG:    POP   BP
              RET   6

L__BlockNot__BitBlockOps ENDP

;-----------------------------------------------------------
L__BlockShr__BitBlockOps PROC    FAR
;-----------------------------------------------------------
; in : (block      : ADDRESS;
;       blocksize  : CARDINAL;
;       count      : CARDINAL);

count      = 6
blocksize  = count + 2
block      = blocksize + 2

              PUSH  BP
              MOV   BP, SP
              LDS   SI, DWORD PTR [BP + block]
              MOV   BX, [BP + blocksize]
              XOR   AH, AH		; fill with 0's from the left
              JMP   RIGHT		; generic right shift

L__BlockShr__BitBlockOps ENDP

;-----------------------------------------------------------
L__BlockSar__BitBlockOps PROC    FAR
;-----------------------------------------------------------
; in : (block      : ADDRESS;
;       blocksize  : CARDINAL;
;       count      : CARDINAL);

count      = 6
blocksize  = count + 2
block      = blocksize + 2

              PUSH  BP
              MOV   BP, SP
              LDS   SI, DWORD PTR [BP + block]
              MOV   BX, [BP + blocksize]
              MOV   AL, BYTE PTR [BX+SI-1]	; get high byte
              CBW			; sign extend

; common right-shift entry point
; BX = blocksize
; DS:SI = block ptr (points to low byte)
; AH = fill byte (bits used to fill on left)
RIGHT:
              MOV   DH, AH		; save fill-byte for later
              CLD			; clear direction flag
              MOV   CX, [BP + count]	; shift count
              AND   CX, 07H		; count MOD 8
              JZ    RGHTEVEN		; shift is by an even number of bytes
              ADD   SI, BX		; point past last byte
RIGHT1:
              DEC   SI			; point to byte[n]
              MOV   AL, BYTE PTR [SI]	; get byte[n]
              MOV   DL, AL		; save it, needed for byte[n-1]
              SHR   AX, CL		; shr, including bits from byte[n+1]
              MOV   BYTE PTR [SI], AL	; update byte[n]
              MOV   AH, DL		; put old value in AX for next iter
              DEC   BX			; was that the last one?
              JNZ   RIGHT1		;   nope
              ; note: DS:SI = block again
              MOV   BX, [BP + blocksize]
              ; shift bytes right by (count DIV 8), extend with DH
RGHTEVEN:     MOV   AX, [BP + count]	; get shift count
              SHR   AX, 1
              SHR   AX, 1
              SHR   AX, 1		; compute count DIV 8
              JZ    RIGHTX		; zip: no byte shuffle needed
              LES   DI, DWORD PTR [BP + block]
              MOV   CX, BX		; blocksize again
              CMP   CX, AX		; (count DIV 8) >= blocksize?
              JBE   RGHTFILL		; just fill with sign
              SUB   CX, AX		; blocksize - (count DIV 8)
              ADD   SI, AX		; first byte to keep
              REP   MOVSB		; move CX bytes at DS:[SI] to ES:[DI]
              MOV   CX, AX		; and fill the balance with sign
RGHTFILL:     MOV   AL, DH		; use that saved sign-byte
              REP   STOSB		; fill CX bytes at ES:[DI] with sign
RIGHTX:

IFDEF MEDIUM
              MOV   BX, DGROUP
              MOV   DS, BX
ENDIF
              POP   BP
              RET   8

L__BlockSar__BitBlockOps ENDP

;-----------------------------------------------------------
L__BlockShl__BitBlockOps PROC    FAR
;-----------------------------------------------------------
; in : (block : ADDRESS;
;       blocksize  : CARDINAL;
;       count : CARDINAL);

count      = 6
blocksize  = count + 2
block      = blocksize + 2

              PUSH  BP
              MOV   BP, SP
              CLD
              LDS   SI, DWORD PTR [BP + block]	; point to low byte
              MOV   BX, [BP + blocksize]
              MOV   CX, [BP + count]
              AND   CL, 07H                      
              JZ    SHL8
; shift bytes left by count MOD 8
              XOR   AL, AL			; fill 0's from right
SHLOOP1:      MOV   AH, BYTE PTR [SI]		; get byte n
              MOV   DH, AH			; save it for next iter
              ROL   AX, CL			; shift byte n, n-1
              MOV   AL, DH
              MOV   BYTE PTR [SI], AH		; update byte n
              INC   SI
              DEC   BX
              JNZ   SHLOOP1

              MOV   BX, WORD PTR [BP + blocksize]

              ; Block move of count DIV 8 bytes, and clear of high bytes
SHL8:         MOV   AX, [BP + count]
              SHR   AX, 1
              SHR   AX, 1
              SHR   AX, 1
              JZ    SHLEPILOG
              STD
              LES   SI, DWORD PTR [BP + block]	; load ES, reset SI
              LEA   DI, BYTE PTR [SI + BX - 1]	; ES:DI points to last byte
              MOV   CX, BX
              CMP   CX, AX			; blocksize <= (count DIV 8)?
              JBE   SHLZERO			;   yes, fill the whole thing
              SUB   CX, AX			; CX = bytes to keep
              ADD   SI, CX			;
              DEC   SI				; leftmost byte to keep
              REP   MOVSB			; shuffle bytes left (up)
              MOV   CX, AX
SHLZERO:      XOR   AL, AL
              REP STOSB				; zero the rest (low bytes)

SHLEPILOG:    CLD

IFDEF MEDIUM
              MOV   BX, DGROUP
              MOV   DS, BX
ENDIF

              POP   BP
              RET   8

L__BlockShl__BitBlockOps ENDP

;-----------------------------------------------------------
L__BlockRor__BitBlockOps PROC    FAR
;-----------------------------------------------------------
; in : (block : ADDRESS;
;       blocksize  : CARDINAL;
;       count : CARDINAL);

count      = 6
blocksize  = count + 2
block      = blocksize + 2

              PUSH  BP
              MOV   BP, SP
              CLD
              MOV   BX, [BP + blocksize]
              LDS   SI, DWORD PTR [BP + block]	; point to low byte
              MOV   CX, [BP + count]
              AND   CX, 07H                      
              JZ    ROR8			; (count MOD 8) = 0
; working high to low, rotate the block in-place by (count MOD 8) bits
; taking care to wrap the low bits of the low byte into the high byte
              MOV   AH, BYTE PTR [SI]		; save low byte
              LEA   SI, BYTE PTR [SI + BX - 1]	; point to last (high) byte
ROR1:
              MOV   AL, BYTE PTR [SI]		; get byte n
              MOV   DL, AL			; save to do byte n-1
              ROR   AX, CL			; shift right with byte n+1
              MOV   BYTE PTR [SI], AL		; store new byte n
              MOV   AH, DL			; recover old byte n
              DEC   SI				; point to byte n-1
              DEC   BX				; more bytes to do?
              JNZ   ROR1			;   yes: repeat blocksize times
              MOV   BX, [BP + blocksize]	; restore BX = blocksize

ROR8:         MOV   DX, [BP + count]
              SHR   DX, 1
              SHR   DX, 1
              SHR   DX, 1
              JZ    ROREPILOG			; (count DIV 8) = 0
; ugh: shuffle right by 1 byte, repeat DX = (count DIV 8) times
              LES   DI, DWORD PTR [BP + block]	; ES:DI points to low byte
ROR3:     
              MOV   SI, DI			; ditto DS:SI (DS loaded above)
              LEA   CX, BYTE PTR [BX - 1]	; CX := blocksize - 1
              LODSB				; save low byte in AL
              REP   MOVSB			; shuffle other bytes down
              STOSB				; put old low byte into high
              SUB   DI, BX			; restore ES:DI to low byte
              DEC   DX
              JNZ   ROR3			; repeat (count DIV 8) times

ROREPILOG:    

IFDEF MEDIUM
              MOV   BX, DGROUP
              MOV   DS, BX
ENDIF
              POP   BP
              RET   8

L__BlockRor__BitBlockOps ENDP

;-----------------------------------------------------------
L__BlockRol__BitBlockOps PROC    FAR
;-----------------------------------------------------------
; in : (block : ADDRESS;
;       blocksize  : CARDINAL;
;       count : CARDINAL);

count      = 6
blocksize  = count + 2
block      = blocksize + 2

              PUSH  BP
              MOV   BP, SP
              MOV   BX, [BP + blocksize]
              LDS   SI, DWORD PTR [BP + block]
              MOV   CX, [BP + count]
              AND   CX, 07H                      
              JZ    ROL8			; (count MOD 8) = 0
              MOV   AH, BYTE PTR [SI + BX - 1]	; save high byte
ROL1:
              MOV   AL, BYTE PTR [SI]		; get byte n
              MOV   DL, AL			; save for n+1
              ROL   AX, CL
              MOV   BYTE PTR [SI], AL		; update byte n
              MOV   AH, DL
              INC   SI
              DEC   BX
              JNZ   ROL1
              MOV   BX, [BP + blocksize]

ROL8:         MOV   DX, [BP + count]
              SHR   DX, 1
              SHR   DX, 1
              SHR   DX, 1
              JZ    ROLX
              STD
              LES   DI, DWORD PTR [BP + block]	; first byte
              LEA   DI, BYTE PTR [DI + BX - 1]	; ES:DI points to last byte
ROL3:
              MOV   SI, DI			; DS:SI ditto, (DS set above)
              LEA   CX, BYTE PTR [BX-1]		; CX = blocksize - 1
              LODSB				; save high byte (AL)
              REP   MOVSB			; shuffle up by one byte!!
              STOSB				; stuff old high into low
              ADD   DI, BX			; reset ES:DI to last byte
              DEC   DX
              JNZ   ROL3			; repeat (count DIV 8) times

ROLX:         CLD

IFDEF MEDIUM
              MOV   BX, DGROUP
              MOV   DS, BX
ENDIF

              POP   BP
              RET   8

L__BlockRol__BitBlockOps ENDP


$INIT__BitBlockOps   PROC  FAR
               RET
$INIT__BitBlockOps   ENDP

$EM__BitBlockOps:
BitBlockOps_TEXT ENDS

;BitBlockOps_DATA         SEGMENT WORD PUBLIC 'FAR_BSS'
;                         ASSUME  CS : BitBlockOps_TEXT
;$BD__BitBlockOps          LABEL   FAR
;
;$ED__BitBlockOps          LABEL  FAR
;BitBlockOps_DATA         ENDS

        END
