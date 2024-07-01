;
; -------------------------------------------------------
;   movmem(source, destination, n) - move block of memory
;   memcpy(destination, source, n) - move block of memory
; -------------------------------------------------------
;
         IDT  movmem
         IF   UPPER
         DEF  MOVMEM
         ENDIF
         DEF  movmem
;        DEF  MEMCPY
;        DEF  memcpy
         DEF  $_MOV
;
movmem   equ  $
MOVMEM   PUSH BP
         MOV  BP,SP
         MOV  SI,[BP][%PARM1]
         MOV  DI,[BP][%PARM2]
COPY1    MOV  CX,[BP][%PARM3]
COPY2    MOV  AX,DI           ; result is pointer to dest
         JCXZ DONE
         CLD
         MOV  DX,DS
         MOV  ES,DX
         CMP  SI,DI
         JAE  COPY
         STD
         ADD  SI,CX
         ADD  DI,CX
         TEST CL,>01
         JZ   EVEN
         DEC  SI
         DEC  DI
         MOVSB
         SHR  CX,1
         JCXZ DONE
         DEC  SI
         DEC  DI
         REP
         MOVSW
         JMPS DONE
EVEN     SUB  SI,%2
         SUB  DI,%2
         SHR  CX,1
         JCXZ DONE
         REP
         MOVSW
         JMPS DONE
COPY     PUSH CX
         SHR  CX,1
         JCXZ LASTCHAR
         REP
         MOVSW
LASTCHAR POP  CX
         AND  CL,>01
         JZ   DONE
         MOVSB
DONE     CLD
         POP  BP
         RETSEG
memcpy   equ  $
MEMCPY   PUSH BP
         MOV  BP,SP
         MOV  SI,[BP][%PARM2]
         MOV  DI,[BP][%PARM1]
         JMPS COPY1
$_MOV    PUSH BP
         MOV  BP,SP
         MOV  SI,[BP][%PARM3]
         MOV  DI,[BP][%PARM2]
         MOV  CX,[BP][%PARM1]
         JMPS  COPY2
         END
;
; -------------------------------------------------------
;   memcpy(destination, source, n) - move block of memory
; -------------------------------------------------------
;
         IDT  memcpy
         IF   UPPER
         DEF  MEMCPY
         ENDIF
         DEF  memcpy
;
memcpy   equ  $
MEMCPY   MOV  BX,SP
         MOV  DI,[BX][%PARM1-2]
         MOV  SI,[BX][%PARM2-2]
         MOV  CX,[BX][%PARM3-2]
         MOV  AX,DI           ; result is pointer to dest
         JCXZ DONE
         CLD
         MOV  DX,DS
         MOV  ES,DX
         CMP  SI,DI
         JAE  COPY
         STD
         ADD  SI,CX
         ADD  DI,CX
         DEC  SI
         DEC  DI
COPY     REP
         MOVSB
         CLD
DONE     RETFAR
         END
;
; -------------------------------------------------------
;   memmove(destination, source, n) - move block of memory
; -------------------------------------------------------
;
         IDT  memmove
         DEF  memmove
;
memmove  MOV  BX,SP
         MOV  DI,[BX][%PARM1-2]
         MOV  SI,[BX][%PARM2-2]
         MOV  CX,[BX][%PARM3-2]
         MOV  AX,DI           ; result is pointer to dest
         JCXZ DONE
         CLD
         MOV  DX,DS
         MOV  ES,DX
         CMP  SI,DI
         JAE  COPY
         STD
         ADD  SI,CX
         ADD  DI,CX
         DEC  SI
         DEC  DI
COPY     REP
         MOVSB
         CLD
DONE     RETFAR
         END
;
; -------------------------------------------------------
;   memswap(addr1, addr2, n) - swap two blocks of memory
; -------------------------------------------------------
;
         IDT  memswap
         IF   UPPER
         DEF  MEMSWAP
         ENDIF
         DEF  memswap
;
memswap  equ  $
MEMSWAP  MOV  BX,SP
         MOV  SI,[BX][%PARM1-2]
         MOV  DI,[BX][%PARM2-2]
         MOV  CX,[BX][%PARM3-2]
         JCXZ DONE
         CLD
         MOV  DX,DS
         MOV  ES,DX
SWAP     MOV  AL,[DI]
         XCHG AL,[SI]
         STOSB
         INC  SI
         LOOP SWAP
DONE     RETSEG
         END
;
; -------------------------------------------------------
;   memset(addr, value, count) - fill a block with character
; -------------------------------------------------------
;
         IDT  memset
         IF   UPPER
         DEF  MEMSET
         ENDIF
         DEF  memset
;
memset   equ  $
MEMSET   MOV  BX,SP
         MOV  DI,[BX][%PARM1-2]
         MOV  AX,[BX][%PARM2-2]
         MOV  CX,[BX][%PARM3-2]
         JCXZ DONE
         CLD
         MOV  DX,DS
         MOV  ES,DX
         REP
         STOSB
DONE     RETSEG
         END
;
; -------------------------------------------------------
;   swab(source, destination, n) - swap bytes in a block of memory
; -------------------------------------------------------
;
         IDT  swab
         DEF  swab
;
swab     PUSH BP
         MOV  BP,SP
         MOV  SI,[BP][%PARM1]
         MOV  DI,[BP][%PARM2]
         MOV  CX,[BP][%PARM3]
         SHR  CX,1            ; word count
         CLD
         MOV  DX,DS
         MOV  ES,DX
         JCXZ DONE
COPY     LODSW
         XCHG AH,AL
         STOSW
         LOOP COPY
DONE     TEST [BP][%PARM3],1
         JZ   EVEN
         LODSB
         STOSB
EVEN     POP  BP
         RETSEG
         END
;
; -------------------------------------------------------
;   $_movarg(source,dest,n) - move block of memory
;   source is address of last byte of block
; -------------------------------------------------------
;
         IDT  $_MOVARG
         DEF  $_MOVARG
;
$_MOVARG PUSH BP
         MOV  BP,SP
         MOV  CX,[BP][%PARM1]
         JCXZ DONE
         MOV  DI,[BP][%PARM2]
         MOV  SI,[BP][%PARM3]
         SUB  SI,CX
         INC  SI
         CLD
         MOV  DX,DS
         MOV  ES,DX
         REP
         MOVSB
DONE     POP  BP
         RETSEG
         END
;
; -------------------------------------------------------
;   memccpy(dest, src, c, cnt) - copy up to & including c
; -------------------------------------------------------
;
         IDT  memccpy
         IF   UPPER
         DEF  MEMCCPY
         ENDIF
         DEF  memccpy
;
memccpy  equ  $
MEMCCPY  PUSH BP
         MOV  BP,SP
         MOV  DI,[BP][%PARM1]
         MOV  SI,[BP][%PARM2]
         MOV  DX,[BP][%PARM3]
         MOV  CX,[BP][%PARM4]
         JCXZ ENDCOUNT
         MOV  DX,DS
         MOV  ES,DX
         CLD
COPY     LODSB
         STOSB
         CMP  AL,DL
         JZ   FOUND
         LOOP COPY
ENDCOUNT XOR  AX,AX           ; Return null if c not copied
         POP  BP
         RETSEG
FOUND    MOV  AX,DI           ; return address of next after c
         POP  BP
         RETSEG
         END
;
; -------------------------------------------------------
;   memchr(buf, c, cnt) - search for c in buffer
; -------------------------------------------------------
;
         IDT  memchr
         IF   UPPER
         DEF  MEMCHR
         ENDIF
         DEF  memchr
;
memchr   equ  $
MEMCHR   PUSH BP
         MOV  BP,SP
         MOV  DI,[BP][%PARM1]
         MOV  AX,[BP][%PARM2]
         MOV  CX,[BP][%PARM3]
         MOV  DX,DS
         MOV  ES,DX
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
;   memcmp(buf1, buf2, cnt) - compare memory
;   $_cmp(src, dest, cnt) - compare memory (byte result)
; -------------------------------------------------------
;
         IDT  memcmp
         IF   UPPER
         DEF  MEMCMP
         ENDIF
         DEF  memcmp
         DEF  $_CMP
;
$_CMP    PUSH BP
         MOV  BP,SP
         MOV  SI,[BP][%PARM3]
         MOV  DI,[BP][%PARM2]
         MOV  CX,[BP][%PARM1]
         JMPS COMPARE
memcmp   equ  $
MEMCMP   PUSH BP
         MOV  BP,SP
         MOV  SI,[BP][%PARM1]
         MOV  DI,[BP][%PARM2]
         MOV  CX,[BP][%PARM3]
COMPARE  JCXZ EQUAL
         MOV  DX,DS
         MOV  ES,DX
         CLD
         REPZ
         CMPSB
         JZ   EQUAL
         MOV  AL,[SI][%-1]
         SUB  AL,[DI][%-1]
         CBW
         POP  BP
         RETSEG
EQUAL    XOR  AX,AX           ; Return 0 if buffers are equal
         POP  BP
         RETSEG
         END
;
; -------------------------------------------------------
;   memicmp(buf1, buf2, cnt) - compare memory
; -------------------------------------------------------
;
         IDT  memicmp
         IF   UPPER
         DEF  MEMICMP
         ENDIF
         DEF  memicmp
;
memicmp  equ  $
MEMICMP  PUSH BP
         MOV  BP,SP
         MOV  SI,[BP][%PARM1]
         MOV  DI,[BP][%PARM2]
         MOV  CX,[BP][%PARM3]
         JCXZ EQUAL
         MOV  DX,DS
         MOV  ES,DX
         CLD
MATCH    REPZ
         CMPSB
         JZ   EQUAL
         MOV  AL,[SI][%-1]
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
         SUB  AL,[DI][%-1]
         CBW
         POP  BP
         RETSEG
EQUAL    XOR  AX,AX
         POP  BP
         RETSEG
         END
;
; -------------------------------------------------------
;   movedata(srcseg, srcoff, destseg, destoff, nbytes);
;        move a block of data between segments
; -------------------------------------------------------
;
         IDT  movedata
         IF   UPPER
         DEF  MOVEDATA
         ENDIF
         DEF  movedata
;
movedata equ  $
MOVEDATA PUSH BP
         MOV  BP,SP
         MOV  SI,[BP][%PARM2]
         MOV  DI,[BP][%PARM4]
         CLD
         PUSH DS
         MOV  DS,[BP][%PARM1]
         MOV  ES,[BP][%PARM3]
         MOV  CX,[BP][%PARM5]
         JCXZ DONE
         MOV  AX,[BP][%PARM1]
         CMP  AX,[BP][%PARM3]
         JNZ  COPY
         CMP  DI,SI           ; Allow overlap if segments equal
         JBE  COPY
         STD
         DEC  CX
         ADD  SI,CX           ; point to end of data
         ADD  DI,CX
         INC  CX
         REP
         MOVSB
         CLD
         JMPS DONE
COPY     PUSH CX
         SHR  CX,1
         JCXZ LASTCHAR
         REP
         MOVSW
LASTCHAR POP  CX
         AND  CX,>0001
         JCXZ DONE
         MOVSB
DONE     POP  AX
         MOV  DS,AX
         POP  BP
         RETSEG
         END
;
; -------------------------------------------------------
;   xmovmem(xsource, xdest, size);
; -------------------------------------------------------
;
         IDT  xmovmem
         IF   UPPER
         DEF  XMOVMEM
         ENDIF
         DEF  xmovmem
xmovmem  equ  $
XMOVMEM  PUSH BP
         MOV  BP,SP
         MOV  AX,[BP][%PARM1]                  ; lsw of source
         MOV  CL,%4
         MOV  SI,AX
         AND  SI,>000F
         SHR  AX,CL
         ADD  AX,[BP][%PARM2]                  ; msw of source
         MOV  DX,[BP][%PARM3]                  ; lsw of dest
         MOV  CL,%4
         MOV  DI,DX
         AND  DI,>000F
         SHR  DX,CL
         ADD  DX,[BP][%PARM4]                  ; msw of dest
         MOV  ES,DX
         PUSH DS
         MOV  DS,AX
         MOV  CX,[BP][%PARM5]
         JCXZ DONE
         CLD
         REP
         MOVSB
DONE     POP  AX
         MOV  DS,AX
         POP  BP
         RETSEG
         END
