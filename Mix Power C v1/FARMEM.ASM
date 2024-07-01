;
;   Copyright (c) Mix Software 1988
;
; -------------------------------------------------------
;   farrepmem(address,data,datasize, copies)
;      fill memory with copies of a template
; -------------------------------------------------------
;
         IDT  farrepmem
         IF   LONGNAME
         LDEF farrepmem
         ENDIF
         IF   SHORTNAME
         DEF  Frepmem
         ENDIF
;
farrepmem equ $
Frepmem  PUSH BP
         MOV  BP,SP
         MOV  DX,[BP][%PARM6] ; number of copies
         TEST DX,DX
         JZ   DONE
         MOV  CX,[BP][%PARM5] ; size of block
         JCXZ DONE
         MOV  DI,[BP][%PARM1] ; address of data
         MOV  ES,[BP][%PARM2]
         CLD
         PUSH DS
         MOV  DS,[BP][%PARM4]
FILL     MOV  SI,[BP][%PARM3] ; pattern data
         MOV  CX,[BP][%PARM5] ; size of block
         REP
         MOVSB
         DEC  DX
         JNZ  FILL
         POP  CX
         MOV  DS,CX
DONE     POP  BP
         RETSEG
         END
;
; -------------------------------------------------------
;   farmemcpy(destination, source, n) - move block of memory
;        does not test for overlapping blocks
;        size is limited to 64k
;        does not check for segment wrap arround
; -------------------------------------------------------
;
         IDT  farmemcpy
         IF   LONGNAME
         LDEF farmemcpy
         ENDIF
         IF   SHORTNAME
         DEF  Fmemcpy
         ENDIF
farmemcpy equ  $
Fmemcpy  PUSH BP
         MOV  BP,SP
         MOV  CX,[BP][%PARM5]
         JCXZ DONE
         MOV  DI,[BP][%PARM1]
         MOV  ES,[BP][%PARM2]
         PUSH DS
         MOV  SI,[BP][%PARM3]
         MOV  DS,[BP][%PARM4]
         CLD
         REP
         MOVSB
         POP  AX
         MOV  DS,AX
DONE     MOV  AX,[BP][%PARM1] ; Result is ptr to dest
         MOV  DX,[BP][%PARM2]
         POP  BP
         RETSEG
         END
;
; -------------------------------------------------------
;   farmemmove(destination, source, n) - move block of memory
;        checks for overlapping blocks
;        size is limited to 64k
; -------------------------------------------------------
;
         IDT  farmemmove
         IF   LONGNAME
         LDEF farmemmove
         ENDIF
         IF   SHORTNAME
         DEF  Fmemmove
         ENDIF
farmemmove equ  $
Fmemmove PUSH BP
         MOV  BP,SP
         MOV  CX,[BP][%PARM5]
         JCXZ DONE
         MOV  DI,[BP][%PARM2] ; dest segment
         MOV  SI,[BP][%PARM4] ; src segment
         XOR  AX,AX
         XOR  DX,DX
         MOV  CX,4            ; convert to 20 bit
SHIFT1   SHL  DI,1
         RCL  DX,1
         SHL  SI,1
         RCL  AX,1
         LOOP SHIFT1
         ADD  DI,[BP][%PARM1] ; dest offset
         ADC  DX,0
         ADD  SI,[BP][%PARM3] ; src offset
         ADC  AX,0
         CMP  DX,AX
         JB   DSTLOWER
         JA   SRCLOWER
         CMP  DI,SI
         JB   DSTLOWER
         JA   SRCLOWER
DONE     MOV  AX,[BP][%PARM1] ; Result is ptr to dest
         MOV  DX,[BP][%PARM2]
         POP  BP
         RETFAR
DSTLOWER CLD
         MOV  CX,[BP][%PARM5]
         XOR  BX,BX
         JMPS MOVE
SRCLOWER STD
         MOV  CX,[BP][%PARM5]
         MOV  BX,CX
         DEC  BX              ; length - 1
MOVE     PUSH SI
         PUSH DI
         MOV  CX,4
SHIFT2   SHR  DX,1            ; Normalize pointers
         RCR  DI,1
         SHR  AX,1
         RCR  SI,1
         LOOP SHIFT2
         MOV  DX,DI
         MOV  AX,SI
         POP  DI
         AND  DI,>F
         POP  SI
         AND  SI,>F
         ADD  DI,BX
         ADC  DX,0
         ADD  SI,BX
         ADC  AX,0
         MOV  ES,DX
         PUSH DS
         MOV  DS,AX
         MOV  CX,[BP][%PARM5]
         REP
         MOVSB
         POP  AX
         MOV  DS,AX
         CLD
         JMPS DONE
         END
;
; -------------------------------------------------------
;   farmemswap(addr1, addr2, n) - swap two blocks of memory
; -------------------------------------------------------
;
         IDT  farmemswap
         IF   LONGNAME
         LDEF farmemswap
         ENDIF
         IF   SHORTNAME
         DEF  Fmemswap
         ENDIF
;
farmemswap equ  $
Fmemswap MOV  BX,SP
         PUSH DS
         MOV  SI,[BX][%PARM1-2]
         MOV  DS,[BX][%PARM2-2]
         MOV  DI,[BX][%PARM3-2]
         MOV  ES,[BX][%PARM4-2]
         MOV  CX,[BX][%PARM5-2]
         JCXZ DONE
         CLD
SWAP     SEGES
         MOV  AL,[DI]
         XCHG AL,[SI]
         STOSB
         INC  SI
         LOOP SWAP
DONE     POP  AX
         MOV  DS,AX
         RETSEG
         END
;
; -------------------------------------------------------
;   farmemset(addr, value, count) - fill a block with character
; -------------------------------------------------------
;
         IDT  farmemset
         IF   LONGNAME
         LDEF farmemset
         ENDIF
         IF   SHORTNAME
         DEF  Fmemset
         ENDIF
;
farmemset equ  $
Fmemset  MOV  BX,SP
         MOV  DI,[BX][%PARM1-2]
         MOV  ES,[BX][%PARM2-2]
         MOV  AX,[BX][%PARM3-2]
         MOV  CX,[BX][%PARM4-2]
         JCXZ DONE
         CLD
         REP
         STOSB
DONE     RETSEG
         END
;
; -------------------------------------------------------
;   farmemccpy(dest, src, c, cnt) - copy up to & including c
; -------------------------------------------------------
;
         IDT  farmemccpy
         IF   LONGNAME
         LDEF farmemccpy
         ENDIF
         IF   SHORTNAME
         DEF  Fmemccpy
         ENDIF
;
farmemccpy equ  $
Fmemccpy PUSH BP
         MOV  BP,SP
         PUSH DS
         MOV  DI,[BP][%PARM1]
         MOV  ES,[BP][%PARM2]
         MOV  SI,[BP][%PARM3]
         MOV  DS,[BP][%PARM4]
         MOV  DX,[BP][%PARM5]
         MOV  CX,[BP][%PARM6]
         JCXZ ENDCOUNT
         CLD
COPY     LODSB
         STOSB
         CMP  AL,DL
         JZ   FOUND
         LOOP COPY
ENDCOUNT XOR  AX,AX           ; Return null if c not copied
EXIT     POP  CX
         MOV  DS,CX
         POP  BP
         RETSEG
FOUND    MOV  AX,DI           ; return address of next after c
         JMPS EXIT
         END
;
; -------------------------------------------------------
;   farmemchr(buf, c, cnt) - search for c in buffer
; -------------------------------------------------------
;
         IDT  farmemchr
         IF   LONGNAME
         LDEF farmemchr
         ENDIF
         IF   SHORTNAME
         DEF  Fmemchr
         ENDIF
;
farmemchr equ  $
Fmemchr  PUSH BP
         MOV  BP,SP
         MOV  DI,[BP][%PARM1]
         MOV  ES,[BP][%PARM2]
         MOV  AX,[BP][%PARM3]
         MOV  CX,[BP][%PARM4]
         CLD
         REPNZ
         SCASB
         JNZ  NOFIND
         DEC  DI
         MOV  AX,DI           ; Return pointer to c in buf
         POP  BP
         RETSEG
NOFIND   XOR  AX,AX           ; Return null if not found
         POP  BP
         RETSEG
         END
;
; -------------------------------------------------------
;   farmemcmp(buf1, buf2, cnt) - compare memory
; -------------------------------------------------------
;
         IDT  farmemcmp
         IF   LONGNAME
         LDEF farmemcmp
         ENDIF
         IF   SHORTNAME
         DEF  Fmemcmp
         ENDIF
;
farmemcmp equ  $
Fmemcmp  PUSH BP
         MOV  BP,SP
         PUSH DS
         MOV  SI,[BP][%PARM1]
         MOV  DS,[BP][%PARM2]
         MOV  DI,[BP][%PARM3]
         MOV  ES,[BP][%PARM4]
         MOV  CX,[BP][%PARM5]
COMPARE  JCXZ EQUAL
         CLD
         REPZ
         CMPSB
         JZ   EQUAL
         MOV  AL,[SI][%-1]
         SEGES
         SUB  AL,[DI][%-1]
         CBW
EXIT     POP  CX
         MOV  DS,CX
         POP  BP
         RETSEG
EQUAL    XOR  AX,AX           ; Return 0 if buffers are equal
         JMPS EXIT
         END
;
; -------------------------------------------------------
;   farmemicmp(buf1, buf2, cnt) - compare memory
; -------------------------------------------------------
;
         IDT  farmemicmp
         IF   LONGNAME
         LDEF farmemicmp
         ENDIF
         IF   SHORTNAME
         DEF  Fmemicmp
         ENDIF
;
farmemicmp equ  $
Fmemicmp PUSH BP
         MOV  BP,SP
         PUSH DS
         MOV  SI,[BP][%PARM1]
         MOV  DS,[BP][%PARM2]
         MOV  DI,[BP][%PARM3]
         MOV  ES,[BP][%PARM4]
         MOV  CX,[BP][%PARM5]
         JCXZ EQUAL
         CLD
MATCH    REPZ
         CMPSB
         JZ   EQUAL
         MOV  AL,[SI][%-1]
         SEGES
         MOV  AH,[DI][%-1]
         CMP  AL,'a'
         JB   X1
         CMP  AL,'z'
         JA   X1
         SUB  AL,>20
X1       CMP  AH,'a'
         JB   X2
         CMP  AH,'z'
         JA   X2
         SUB  AH,>20
X2       CMP  AL,AH
         JZ   MATCH
         MOV  AL,[SI][%-1]
         SEGES
         SUB  AL,[DI][%-1]
         CBW
EXIT     POP  CX
         MOV  DS,CX
         POP  BP
         RETSEG
EQUAL    XOR  AX,AX
         JMPS EXIT
         END
