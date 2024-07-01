;
;   Copyright (c) Mix Software 1988
;
         IDT  alloc
         DEF  alloc
         IF   UPPER
         DEF  ALLOC
         ENDIF
         FREF $$ALLOC
alloc    equ  $
ALLOC    JMPFAR $$ALLOC
         END
;
         IDT  calloc
         DEF  calloc
         IF   UPPER
         DEF  CALLOC
         ENDIF
         FREF $$CALLOC
calloc   equ  $
CALLOC   JMPFAR $$CALLOC
         END
;
         IDT  malloc
         DEF  malloc
         IF   UPPER
         DEF  MALLOC
         ENDIF
         FREF $$MALLOC
malloc   equ  $
MALLOC   JMPFAR $$MALLOC
         END
;
;  --------------------------------------------------
;     new - allocate a block of heap
;  --------------------------------------------------
;
         IDT  $$ALLOC
         DEF  $$CALLOC
         DEF  $$MALLOC
         DEF  $$ALLOC
         DEF  _nmalloc
         REF  $$HPTERM
         FREF $_FATAL
         FREF $$NEW$$
         REF  errno
;
;  calloc(number,size)  -  block is number*size bytes in length
;
$$CALLOC PUSH BP
         MOV  BP,SP
         MOV  AX,[BP][%PARM1]
         MUL  [BP][%PARM2]
         JC   NOSPACE         ; multiply overflows
         CALLFAR $$NEW$$
RETURN   TEST AX,AX           ; out of space?
         JZ   NOSPACE
IGNORE   POP  BP
         RETSEG
NOSPACE  MOV  [errno],ENOMEM
         TEST %[$$HPTERM],%>FF  ; teminate on heap full?
         JZ   IGNORE
         MOV  AX,E$HEAP
         PUSH AX
         CALLFAR $_FATAL
         POP  AX
         XOR  AX,AX
         JMPS IGNORE
;
;  alloc(size)  -  block is size bytes in length
;
_nmalloc EQU  $
$$ALLOC  EQU  $
$$MALLOC PUSH BP
         MOV  BP,SP
         MOV  AX,[BP][%PARM1]
         CALLFAR $$NEW$$
         JMPS RETURN
         END
;
;  $_NEW(ptr,size)
;     ptr is address of a pointer to receive the result
;     size is the size of the block in bytes
;
         IDT  $_NEW
         DEF  $_NEW
         REF  $$HPTERM
         FREF $$NEW$$
         FREF $_FATAL
         REF  errno
$_NEW    PUSH BP
         MOV  BP,SP
         MOV  AX,[BP][%PARM1] ; size
         CALLFAR $$NEW$$
         MOV  BX,[BP][%PARM2] ; pointer
         MOV  [BX],AX
         TEST AX,AX           ; out of space?
         JZ   NOSPACE
IGNORE   POP  BP
         RETSEG
NOSPACE  MOV  [errno],ENOMEM
         TEST %[$$HPTERM],%>FF  ; teminate on heap full?
         JZ   IGNORE
         MOV  AX,E$HEAP
         PUSH AX
         CALLFAR $_FATAL
         POP  AX
         XOR  AX,AX
         JMPS IGNORE
         END
;
;
; ----------------------------------------------------------
;   NEW$$ - Allocate a block from the heap
; ----------------------------------------------------------
;  inputs:
;    AX - required length of the packet
;  outputs:
;    AX - pointer to the packet; 0 if none available
;  REGISTERS USED:
;    uses ax, bx, cx, dx, di
;
;
         IDT  $$NEW$$
         DEF  $$NEW$$
         REF  $$FREE
         REF  $$CURH
         REF  $$MAXH
;
$$NEW$$  MOV  CX,AX
         ADD  CX,%3           ; reserve two bytes for length
         AND  CL,%#FE         ; Round up if size is odd
;
;  if size is less than 6, set to 6
;
         CMP  CX,%6
         JAE  NEW01
         MOV  CX,6            ; MINIMUM SIZE IS 6
;
;  SET BX TO POINT TO THE CURRENT FREE LIST
;
NEW01    MOV  BX,[$$FREE]
;
;  SEARCH FREE LIST FOR A PACKET OF SUFFICIENT SIZE
;
NEWLOOP  CMP  CX,[BX]         ; COMPARE LENGTHS
         JBE  NEW02
         JMP  NEW03           ; NOT LARGE ENOUGH
;
;  THE CURRENT PACKET IS LARGE ENOUGH
;    REMOVE NEEDED SPACE & CHECK RESULT FOR > 6
;
NEW02    MOV  AX,[BX]         ; GET PACKET SIZE
         SUB  AX,CX           ; SUBTRACT NEEDED SPACE
         CMP  AX,6            ; LARGE ENOUGH?
         JAE  NEW04
         MOV  CX,[BX]         ; SET SIZE TO WHOLE PACKET
;
;  LESS THAN 6 BYTES ARE LEFT, SO ALLOCATE THE ENTIRE PACKET
;     LENGTH IS IN CX, LOCATION IS IN BX
;
         MOV  AX,[BX][2]      ; GET SUCCESSOR FIELD
         MOV  [$$FREE],AX     ; NEW FREE LIST
         MOV  DX,[BX][4]      ; DX = PREDECESSOR
;
;   LAST+2 := NEXT
;
         XCHG BX,DX
         MOV  [BX][2],AX      ; SET PRED@.NEXT TO CUR@.NEXT
         XCHG BX,DX
;
;   NEXT+4 := LAST
;
         XCHG BX,AX
         MOV  [BX][4],DX      ; SET NEXT@.LAST TO CUR@.LAST
         XCHG BX,AX
         JMPS NEW05
;
;   THE REMAINDER OF THE CURRENT PACKET IS LONG ENOUGH
;
;  REDUCE THE SIZE OF THE PACKET
;    AX CONTAINS THE NEW LENGTH
;    CX CONTAINS THE LENGTH OF THE REQUESTED PACKET
;    BX CONTAINS THE PACKET ADDRESS
;
NEW04    MOV  DX,BX           ; SAVE CURRENT PACKET ADDR
         ADD  BX,CX           ; BX <-- ADDR OF NEW FREE PKT
         MOV  [BX],AX         ; SET NEW LENGTH
;
;  SET SUCCESSOR OF NEW FREE PACKET TO SUCCESSOR OF OLD
;  FREE PACKET & PREDECESSOR OF NEW TO PREDECESSOR OF OLD
;  IE. MOVE 4 BYTES FROM (DE) TO (HL)
;
         MOV  DI,DX
         MOV  AX,[DI][2]      ; OLD SUCCESSOR
         MOV  [BX][2],AX
         MOV  AX,[DI][4]
         MOV  [BX][4],AX
;
;  DI CONTAINS OLD FREE PACKET
;  BX CONTAINS NEW FREE PACKET
;
         MOV  AX,[BX][2]      ; GET SUCCESSOR
         MOV  [$$FREE],AX     ; NEW FREE LIST POINTER
         XCHG BX,AX
         MOV  [BX][4],AX      ; NEXT@.PRED = NEW FREE PKT
         XCHG AX,BX
         MOV  AX,[BX][4]      ; GET PREDECESSOR
         XCHG AX,BX
         MOV  [BX][2],AX      ; PREV@.SUCC = NEW FREE PKT
         XCHG AX,BX
         MOV  BX,DX
;
;  AT THIS POINT CX CONTAINS THE LENGTH OF THE NEWLY ALLOCATED
;  PACKET, AND BX CONTAINS ITS ADDRESS
;
;  SET THE LENGTH OF THE NEWLY ALLOCATED PACKET.  LENGTH+1, WHICH
;   IS ODD, IS USED TO MARK THE PACKET AS ALLOCATED
;
NEW05    MOV  [BX],CX
         INC  [BX]            ; MAKE LENGTH ODD
         INC  BX              ; POINT TO DATA AREA
         INC  BX
;
;  ADD SIZE OF CURRENT PACKET TO CURRENT HEAP ALLOCATED
;
         ADD  [$$CURH],CX     ; ADD TO CURRENT ALLOCATION
         MOV  AX,[$$CURH]     ; LARGER THAN MAX USED?
         CMP  AX,[$$MAXH]
         JB   NEW08
         MOV  [$$MAXH],AX     ; SET MAXIMUM HEAP USED
NEW08    EQU  $
;        TEST %[$$ZFILL],>FF  ; ZERO FILL?
;        JZ   NEW10           ; NO ZERO FILL
         MOV  DX,BX           ; SAVE POINTER
         MOV  DI,BX
         CLD
         MOV  AX,DS
         MOV  ES,AX
         SHR  CX,1            ; LENGTH IN WORDS
         DEC  CX              ; ALLOW FOR LENGTH FIELD
         MOV  AX,0
         REP
         STOSW
         MOV  AX,DX
         RETSEG
NEW10    MOV  AX,BX
         RETSEG               ; DONE
;
;
;   THE CURRENT PACKET IN THE FREE LIST IS NOT LARGE ENOUGH
;   MOVE TO THE NEXT PACKET
;      BX CONTAINS THE ADDRESS OF THE CURRENT PACKET
;      CX CONTAINS THE REQUIRED SIZE
;
NEW03    MOV  BX,[BX][%2]     ; POINT TO SUCCESSOR
;
;  CHECK THE CURRENT PACKET AGAINST THE FREELIST POINTER.
;  IF CURRENT=FREELIST, THEN ALL PACKETS HAVE BEEN EXAMINED,
;  AND THE REQUEST CANNOT BE SATISFIED
;
         CMP  BX,[$$FREE]
         JZ   NEW11
         JMP  NEWLOOP
;
;  UNABLE TO ALLOCATE
;
NEW11    MOV  AX,0
         RETSEG
         END
