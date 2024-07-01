;
;  --------------------------------------------------
;     free - release a block of heap
;  --------------------------------------------------
;
         IDT  cfree
         DEF  cfree
         DEF  free
         DEF  _nfree
         IF   UPPER
         DEF  CFREE
         DEF  FREE
         ENDIF
         FREF $$FREE$$
;
;  free(ptr)  -  release a block of heap
;
cfree    equ  $
CFREE    EQU  $
free     equ  $
_nfree   equ  $
FREE     MOV  SI,SP
         MOV  BX,[SI][%PARM1-2]
         CALLFAR $$FREE$$
         XOR  AX,AX
         RETSEG
         END
;
;  $_FREE(ptr);
;     ptr is address of a pointer
;     block is released and pointer set to nil
;
         IDT  $_free
         DEF  $_FREE
         FREF $$FREE$$
$_FREE   PUSH BP
         MOV  BP,SP
         MOV  BX,[BP][%PARM1] ; pointer address
         MOV  BX,[BX]         ; value of pointer
         CALLFAR $$FREE$$
         MOV  BX,[BP][%PARM1] ; pointer address
         MOV  [BX],0
         POP  BP
         RETSEG
         END
;
; ------------------------------------------------------------
;
;   FREE$$
;        RELEASE A HEAP PACKET
;  INPUTS:
;    BX - POINTER TO THE PACKET BEGIN RETURNED
;  OUTPUTS:
;    NONE
;  REGISTERS USED:
;    DI, SI, BP ARE PRESERVED
;
;
         IDT  $$FREE$$
         DEF  $$FREE$$
         REF  $$HPTERM
         FREF $_FATAL
         REF  $$HMIN
         REF  $$HMAX
         REF  $$CURH
         REF  $$FREE
         REF  errno
;
;  CHECK FOR SIZE, NIL POINTER
;
$$FREE$$ TEST BX,BX
         JNZ  FREE01
         RETSEG               ; NIL - EXIT
FREE01   SUB  BX,%2           ; POINT TO LENGTH FIELD
;
;  CHECK POINTER AGAINST LOWER BOUND OF HEAP - ERROR IF LESS
;
         CMP  BX,[$$HMIN]
         JB   INVPKT
;
;  GET LENGTH OF THE PACKET
;
FR01     MOV  CX,[BX]
         TEST CL,%1           ; CHECK ALLOCATED FLAG
         JZ   INVPKT          ; NOT ALLOCATED
         AND  CL,%>FE         ; RESET ALLOCATION FLAG
         MOV  AX,BX
         ADD  AX,CX           ; AX POINTS TO NEXT PACKET
;
;  CHECK PTR + SIZE OF PACKET AGAINST HEAP UPPER BOUND
;
         CMP  AX,[$$HMAX]
         JA   INVPKT
;
;  BX = ADDRESS OF RELEASED PACKET
;  CX = SIZE OF RELEASED PACKET
;  AX = ADDRESS OF NEXT PACKET
;
;  PACKET IS VALID, RELEASE IT
;
FR02     SUB  [$$CURH],CX     ; SUBTRACT FROM CURRENT
;
;  IS NEXT PACKET ALLOCATED?
;
         MOV  DX,BX
         MOV  BX,AX
         TEST [BX],%1         ; CHECK ALLOCATION FLAG
         JNZ  FR03            ; ALLOCATED
;
;  NEXT PACKET IS AVAILABLE, MERGE CURRENT AND NEXT PACKETS
;
         MOV  AX,[BX]         ; GET SIZE OF NEXT PACKET
         TEST AX,AX           ; CHECK FOR ZERO
         JZ   FR03            ; DON'T MERGE WITH ANCHOR
         ADD  CX,AX           ; CX = SIZE OF COMBINATION
;
;  ASSIGN FREELIST TO NEW PACKET
;
         MOV  [$$FREE],DX
;
;  FIND THE PREVIOUS PACKET THAT IS FREE AND CLOSEST
;  TO THE PACKET BEING RELEASED
;
         MOV  AX,[BX][2]      ; GET NEXT FIELD FOR CURRENT
         MOV  BX,[BX][4]      ; PREV LINK OF NEXT FREE PKT
;
;   AT THIS POINT:
;        DX = CURRENT PACKET
;        AX = NEXT PACKET
;        BX = PREVIOUS PACKET
;        CX = LENGTH OF CURRENT
;
         JMPS FR05            ; CHECK FOR LAST PACKET FREE
;
;    NEXT PACKET IS NOT AVAILABLE
;    FIND THE NEXT PACKET THAT IS AVAILABLE TO GET
;    ITS LAST PACKET POINTER
;        BX = NEXT PACKET
;        CX = PACKET SIZE
;        DX = CURRENT PACKET
;
FR03     MOV  AX,[BX]         ; GET SIZE OF NEXT PACKET
         AND  AL,%>FE         ; REMOVE ALLOCATION FLAG
         ADD  BX,AX           ; POINT TO FOLLOWING
         TEST [BX],%1         ; CHECK NEXT PACKET ALLOCATION
         JNZ  FR03            ; LOOP UNTIL FREE
;
;  BX NOW POINTS TO THE NEXT FREE PACKET
;  GET THE LAST POINTER FROM THE NEXT PACKET
;
         MOV  AX,BX
         MOV  BX,[BX][4]      ; GET PREV POINTER
;
;   AT THIS POINT:
;        AX = NEXT PACKET
;        CX = PACKET LENGTH
;        DX = CURRENT PACKET
;        BX = LAST PACKET
;
;
;  CHECK LAST PACKET.  IF THE LAST FREE PACKET IS CONTIGUOUS
;  WITH THE CURRENT PACKET, THEY CAN BE MERGED INTO A SINGLE
;  PACKET.
;
FR05     PUSH AX              ; SAVE
         MOV  AX,[BX]         ; LENGTH OF PREVIOUS PKT
         ADD  AX,BX           ; AX <-- LAST+SIZE(LAST)
         CMP  AX,DX
         JNZ  FR06            ; CAN NOT JOIN
;
;  THE LAST PACKET IS CONTIGUOUS WITH THE CURRENT PACKET,
;  MERGE THEM.
;
         ADD  CX,[BX]         ; ADD LENGTHS
         MOV  [BX],CX         ; SET TOTAL LENGTH
         POP  AX
         MOV  [BX][2],AX      ; SET NEXT PKT POINTER
         XCHG BX,AX
         MOV  [BX][4],AX      ; SET NEXT@.LAST TO MERGED PKT
;
;      SET FREE LIST TO MERGED PACKET
;
         MOV  [$$FREE],AX
         RETSEG               ; DONE
;
;
;  THE LAST PACKET IS NOT CONTIGUOUS WITH THE CURRENT PACKET
;  A NEW PACKET IS CREATED FOR THE PACKET BEING RELEASED.
;
;    TOS = NEXT
;    DX  = CURRENT
;    BX  = PREVIOUS
;    CX  = LENGTH
;
FR06     XCHG BX,DX
         MOV  [BX],CX         ; SET SIZE
         POP  AX
         MOV  [BX][2],AX      ; SET NEXT POINTER
         MOV  [BX][4],DX      ; SET PREVIOUS
         XCHG BX,DX
         MOV  [BX][2],DX      ; SET PREV@.NEXT
         MOV  BX,AX
         MOV  [BX][4],DX      ; SET NEXT@.LAST
;
;  DONE
;
FREEX    RETSEG
;
;  INVALID PACKET POINTER
;
INVPKT   MOV  AX,E$PACKET
         MOV  %[errno],AL
         TEST %[$$HPTERM],%>FF
         JZ   FREEX
         PUSH AX
         CALLFAR $_FATAL
         POP  AX
         RETSEG
         END
